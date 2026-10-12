-- Partida en linea para 2 jugadores: anfitrion autoritativo.
-- El anfitrion simula todo (es el jugador 1) y envia el estado cada frame.
-- El cliente (jugador 2) solo envia sus teclas y dibuja el estado recibido.
local red = require "red"
local juego = require "juego"

local online = {modo = nil}

-- callbacks que asigna main.lua
online.alConectar = nil
online.alDesconectar = nil
online.alIniciarCliente = nil

-- teclas del jugador remoto (las lee el anfitrion con "red:<accion>")
local remoto = {}
local bloqueoLocal = false
local ultimasTeclas = {}

local ACCIONES = {disparar = true, mina = true}
local MOVIMIENTOS = {"adelante", "atras", "izquierda", "derecha"}
local TECLAS_CLIENTE = {adelante = "w", atras = "s", izquierda = "a", derecha = "d", disparar = "q", mina = "e"}

-- Las entidades leen love.keyboard.isDown(input.adelante); el jugador 2 del
-- anfitrion usa nombres "red:..." que se responden con las teclas remotas.
local isDownOriginal = love.keyboard.isDown
love.keyboard.isDown = function(...)
    for _, k in ipairs({...}) do
        if type(k) == "string" and k:sub(1, 4) == "red:" then
            if remoto[k:sub(5)] then return true end
        elseif not bloqueoLocal and isDownOriginal(k) then
            return true
        end
    end
    return false
end

-- Con un menu abierto las teclas locales no mueven tanques
function online.bloquearTeclas(b)
    bloqueoLocal = b
end

function online.activo() return online.modo ~= nil end
function online.esAnfitrion() return online.modo == "anfitrion" end
function online.esCliente() return online.modo == "cliente" end
function online.conectado() return red.conectado() end

function online.crear()
    local ok, err = red.hospedar()
    if ok then online.modo = "anfitrion" end
    return ok, err
end

function online.unirse(ip)
    local ok, err = red.unirse(ip)
    if ok then online.modo = "cliente" end
    return ok, err
end

function online.salir()
    red.cerrar()
    online.modo = nil
    remoto = {}
    ultimasTeclas = {}
    juego.vistaJugador = nil
    juego.alNuevaRonda = nil
end

------------------------------------------------------------------ anfitrion

-- El jugador 2 pasa a leer las teclas remotas (se repite en cada ronda,
-- porque cada ronda vuelve a crear las entidades)
local function conectarJugadorRemoto()
    local j2 = juego.mododejuego.entidades.jugadores[2]
    j2.input = {adelante = "red:adelante", atras = "red:atras", izquierda = "red:izquierda",
                derecha = "red:derecha", disparar = "red:disparar", mina = "red:mina", joystick = false}
end

function online.iniciarPartida(ini, ancho, alto)
    remoto = {}
    juego.vistaJugador = 1
    juego.alNuevaRonda = conectarJugadorRemoto
    juego.nuevaPartida(ini, ancho, alto)
    local config = {}
    for k, v in pairs(ini) do config[k] = v end
    red.enviar({tipo = "inicio", config = config}, true)
end

local function r1(x) return math.floor(x * 10 + 0.5) / 10 end

function online.enviarEstado()
    local E = juego.mododejuego.entidades
    local est = {
        tipo = "estado",
        j = {juego.estado, juego.ronda, juego.rondasGanadas[1], juego.rondasGanadas[2],
             juego.tiempoRestante or -1, juego.ganador or 0, juego.ganadorRonda or 0},
        p = {}, ju = {}, pr = {}, pu = {}, ba = {},
    }
    for i, p in ipairs(E.puntuaciones) do est.p[i] = r1(p.puntos) end
    for i, j in ipairs(E.jugadores) do
        local x, y = j.body:getPosition()
        est.ju[i] = {r1(x), r1(y), r1(j.angulo * 100) / 100, r1(j.vida), j.banderaa and true or false}
    end
    for i, p in ipairs(E.proyectiles) do
        est.pr[i] = {r1(p.posX), r1(p.posY), r1(p.angulo * 100) / 100, p.equipo, p.tipo}
    end
    for i, p in ipairs(E.powerUps) do est.pu[i] = r1(p.vida) end
    for i, b in ipairs(E.banderas or {}) do est.ba[i] = {r1(b.posX), r1(b.posY), b.is and true or false} end
    red.enviar(est, false)
end

-- El final se envia confiable: el ultimo estado podria perderse
function online.enviarFin()
    red.enviar({tipo = "fin", ganador = juego.ganador or 0}, true)
end

------------------------------------------------------------------ cliente

local imgBala = {
    love.graphics.newImage("assets/proyectiles/bulletDark1_outline.png"),
    love.graphics.newImage("assets/proyectiles/bulletRed1_outline.png"),
}
local imgMina = love.graphics.newImage("assets/mina.png")
local ESTADOS = {jugando = true, entreRondas = true, terminando = true, fin = true}

local function num(v, defecto) if type(v) == "number" then return v end return defecto end

local function aplicarEstado(msg)
    if not juego.jugando or not juego.mododejuego then return end
    local E = juego.mododejuego.entidades
    local j = msg.j
    if type(j) == "table" and ESTADOS[j[1]] then
        juego.estado = j[1]
        juego.ronda = num(j[2], juego.ronda)
        juego.rondasGanadas = {num(j[3], 0), num(j[4], 0)}
        local t = num(j[5], -1)
        juego.tiempoRestante = t >= 0 and t or nil
        juego.ganador = num(j[6], 0) > 0 and j[6] or nil
        juego.ganadorRonda = num(j[7], 0)
    end
    for i, p in ipairs(type(msg.p) == "table" and msg.p or {}) do
        if E.puntuaciones[i] then E.puntuaciones[i].puntos = num(p, 0) end
    end
    for i, d in ipairs(type(msg.ju) == "table" and msg.ju or {}) do
        local jug = E.jugadores[i]
        if jug and type(d) == "table" then
            local x, y = num(d[1], jug.posX), num(d[2], jug.posY)
            jug.body:setPosition(x, y)
            jug.posX, jug.posY = x, y
            jug.angulo = num(d[3], jug.angulo)
            jug.vida = num(d[4], jug.vida)
            jug.banderaa = d[5] == true
        end
    end
    -- proyectiles: solo lo necesario para dibujarlos
    local lista = {}
    for _, d in ipairs(type(msg.pr) == "table" and msg.pr or {}) do
        if type(d) == "table" then
            local mina = d[5] == 2
            table.insert(lista, {posX = num(d[1], 0), posY = num(d[2], 0), angulo = num(d[3], 0),
                equipo = num(d[4], 1), tipo = mina and 2 or 1, tamanho = 1, vida = 10,
                imagen = mina and imgMina or (imgBala[d[4]] or imgBala[1]),
                medX = mina and 12 or 4, medY = mina and 12 or 7})
        end
    end
    E.proyectiles = lista
    for i, v in ipairs(type(msg.pu) == "table" and msg.pu or {}) do
        if E.powerUps[i] then E.powerUps[i].vida = num(v, E.powerUps[i].vida) end
    end
    for i, d in ipairs(type(msg.ba) == "table" and msg.ba or {}) do
        local b = E.banderas and E.banderas[i]
        if b and type(d) == "table" then
            b.posX, b.posY = num(d[1], b.posX), num(d[2], b.posY)
            b.is = d[3] == true
        end
    end
end

-- Solo se aceptan configuraciones dentro de los rangos del menu
local function configValida(c)
    if type(c) ~= "table" then return nil end
    local function rango(v, a, b) return type(v) == "number" and v >= a and v <= b and v == math.floor(v) end
    if not (rango(c.modo, 1, 4) and rango(c.numMuertes, 1, 1000) and rango(c.capturas, 1, 100)
        and rango(c.rondas, 1, 10) and rango(c.time, 1, 3600)) then
        return nil
    end
    return {modo = c.modo, numMuertes = c.numMuertes, capturas = c.capturas, rondas = c.rondas,
            time = c.time, jugadores = 2}
end

local function enviarTeclas(enMenu)
    local t = {}
    local cambio = false
    for _, a in ipairs(MOVIMIENTOS) do
        t[a] = (not enMenu) and isDownOriginal(TECLAS_CLIENTE[a]) or false
        if t[a] ~= ultimasTeclas[a] then cambio = true end
    end
    if cambio then
        ultimasTeclas = t
        red.enviar({tipo = "teclas", t = t}, true)
    end
end

-- El cliente envia disparos y minas como eventos
function online.teclaPresionada(key)
    if not online.esCliente() then return end
    for accion, tecla in pairs(TECLAS_CLIENTE) do
        if ACCIONES[accion] and key == tecla then
            red.enviar({tipo = "accion", accion = accion}, true)
        end
    end
end

------------------------------------------------------------------ eventos

local function manejar(evento, msg)
    if evento == "conectado" then
        if online.alConectar then online.alConectar() end
    elseif evento == "desconectado" then
        online.salir()
        if online.alDesconectar then online.alDesconectar() end
    elseif online.esAnfitrion() then
        if msg.tipo == "teclas" and type(msg.t) == "table" then
            for _, a in ipairs(MOVIMIENTOS) do remoto[a] = msg.t[a] == true end
        elseif msg.tipo == "accion" and ACCIONES[msg.accion] then
            if juego.jugando and juego.estado == "jugando" then
                juego.mododejuego.keypressed("red:" .. msg.accion, nil, false)
            end
        end
    elseif online.esCliente() then
        if msg.tipo == "inicio" then
            local c = configValida(msg.config)
            if c and online.alIniciarCliente then online.alIniciarCliente(c) end
        elseif msg.tipo == "estado" then
            aplicarEstado(msg)
        elseif msg.tipo == "fin" and juego.jugando then
            juego.estado = "fin"
            juego.ganador = num(msg.ganador, 0) > 0 and msg.ganador or nil
        end
    end
end

function online.actualizar(dt, enMenu)
    if not online.activo() then return end
    red.actualizar(manejar)
    if online.esCliente() and red.conectado() and juego.jugando then
        enviarTeclas(enMenu)
    end
end

return online
