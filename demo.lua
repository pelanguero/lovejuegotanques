-- Demos de fondo del menu principal (al estilo de Factorio): un modo al azar
-- con los dos tanques manejados por una IA sencilla y una camara que sigue
-- la accion. Cada cierto tiempo cambia de modo con un fundido a negro.
local juego = require "juego"

local demo = {}

local DURACION = 25   -- segundos por demo
local FUNDIDO = 1     -- segundos del fundido de entrada/salida
local ZOOM = 0.85     -- un poco alejada para ver mas del mapa
local PRECALENTAR = 2 -- segundos simulados al cargar, para empezar con accion
local FOCO_Y = 0.7    -- la accion se ve abajo, para que no la tape el menu

local modo = nil      -- modulo del modo cargado (nil = sin demo)
local numModo = 0
local tiempo = 0
local camX, camY = 0, 0
local bots = {}

-- Los tanques de la demo leen teclas virtuales "demo<n>:<accion>"
local teclas = {}
local isDownAnterior = love.keyboard.isDown
love.keyboard.isDown = function(...)
    local reales = {}
    for _, k in ipairs({...}) do
        if type(k) == "string" and k:sub(1, 5) == "demo:" then
            if teclas[k] then return true end
        else
            reales[#reales + 1] = k
        end
    end
    return #reales > 0 and isDownAnterior(unpack(reales)) or false
end

local function controles(n)
    local p = "demo:" .. n .. ":"
    return {adelante = p .. "adelante", atras = p .. "atras", izquierda = p .. "izquierda",
            derecha = p .. "derecha", disparar = p .. "disparar", mina = p .. "mina",
            joystick = false, njoystick = 0}
end

local function tamMapa()
    local t = modo.mapa.tablamapa
    return t.width * 64, t.height * 64
end

------------------------------------------------------------------ IA

local function normalizar(a)
    return (a + math.pi) % (2 * math.pi) - math.pi
end

-- Angulo del tanque para mirar hacia (dx, dy); angulo 0 apunta hacia +Y
local function anguloHacia(dx, dy)
    return math.atan2(-dx, dy)
end

-- Punto al que va un bot segun el modo, si no hay un rival cerca
local function objetivo(j, rival)
    local E = modo.entidades
    if numModo == 2 and E.banderas then
        if j.banderaa then
            local base = E.banderas[j.equipo]
            return base.x, base.y
        end
        for _, b in ipairs(E.banderas) do
            if b.equipo ~= j.equipo then return b.posX, b.posY end
        end
    elseif numModo == 3 and E.colina and E.colina[1] then
        return E.colina[1].posX, E.colina[1].posY
    elseif numModo == 4 and E.banderas and E.banderas[1] and not j.banderaa then
        local b = E.banderas[1]
        if b.is then return b.posX, b.posY end
    end
    return rival.body:getPosition()
end

local function actualizarBot(n, dt)
    local E = modo.entidades
    local j, rival = E.jugadores[n], E.jugadores[3 - n]
    local b = bots[n]
    local p = "demo:" .. n .. ":"
    for _, a in ipairs({"adelante", "atras", "izquierda", "derecha"}) do teclas[p .. a] = false end

    local x, y = j.body:getPosition()
    local rx, ry = rival.body:getPosition()
    local distRival = math.sqrt((rx - x) ^ 2 + (ry - y) ^ 2)

    -- atascado contra una pared: retrocede y gira un momento
    b.reloj = b.reloj + dt
    if b.reloj > 1 then
        local movido = math.sqrt((x - b.ultX) ^ 2 + (y - b.ultY) ^ 2)
        if b.empujando and movido < 15 then
            b.maniobra = 0.8
            b.giro = math.random() < 0.5 and "izquierda" or "derecha"
        end
        b.reloj, b.ultX, b.ultY, b.empujando = 0, x, y, false
        -- cambia un poco el rumbo para que no se vea mecanico
        b.desvioX, b.desvioY = math.random(-90, 90), math.random(-90, 90)
    end
    if b.maniobra > 0 then
        b.maniobra = b.maniobra - dt
        teclas[p .. (b.maniobra > 0.4 and "atras" or b.giro)] = true
        return
    end

    -- pelea si el rival esta cerca, salvo que lleve la bandera a casa
    local combate = distRival < 380 and not (numModo == 2 and j.banderaa)
    local tx, ty
    if combate then
        tx, ty = rx, ry
    else
        tx, ty = objetivo(j, rival)
        tx, ty = tx + b.desvioX, ty + b.desvioY
    end
    local dif = normalizar(anguloHacia(tx - x, ty - y) - j.angulo)
    if math.abs(dif) > 0.2 then
        teclas[p .. (dif < 0 and "izquierda" or "derecha")] = true
    elseif not combate or distRival > 170 then
        teclas[p .. "adelante"] = true
        b.empujando = true
    end

    -- dispara cuando apunta al rival; de vez en cuando deja una mina
    b.cadencia = b.cadencia - dt
    local difRival = normalizar(anguloHacia(rx - x, ry - y) - j.angulo)
    if b.cadencia <= 0 and distRival < 500 and math.abs(difRival) < 0.15 then
        modo.keypressed(p .. "disparar", nil, false)
        b.cadencia = 0.35 + math.random() * 0.5
    elseif b.cadencia <= 0 and math.random() < 0.002 then
        modo.keypressed(p .. "mina", nil, false)
        b.cadencia = 0.5
    end
end

------------------------------------------------------------------ camara

-- Sigue el punto medio entre los tanques (o al primero si estan lejos)
local function objetivoCamara(vw, vh)
    local E = modo.entidades
    local x1, y1 = E.jugadores[1].body:getPosition()
    local x2, y2 = E.jugadores[2].body:getPosition()
    local x, y
    if math.abs(x1 - x2) < vw * 0.8 and math.abs(y1 - y2) < vh * 0.8 then
        x, y = (x1 + x2) / 2, (y1 + y2) / 2
    else
        x, y = x1, y1
    end
    local mw, mh = tamMapa()
    return math.max(0, math.min(mw - vw, x - vw / 2)),
           math.max(0, math.min(mh - vh, y - vh * FOCO_Y))
end

------------------------------------------------------------------ ciclo

local function siguiente()
    local n
    repeat n = math.random(1, 4) until n ~= numModo
    local w, h = love.graphics.getDimensions()
    local ok, m = pcall(juego.cargarModo, n, w, h, 2)
    if not ok then
        print("No se pudo cargar la demo: " .. tostring(m))
        modo = nil
        return
    end
    modo, numModo, tiempo, teclas = m, n, 0, {}
    local E = modo.entidades
    for i = 1, 2 do
        E.jugadores[i].input = controles(i)
        local x, y = E.jugadores[i].body:getPosition()
        bots[i] = {reloj = 0, ultX = x, ultY = y, empujando = false, maniobra = 0,
                   giro = "izquierda", cadencia = 1, desvioX = 0, desvioY = 0}
    end
    for _ = 1, PRECALENTAR * 60 do demo.paso(1 / 60) end
    camX, camY = objetivoCamara(w / ZOOM, h / ZOOM)
end

function demo.paso(dt)
    actualizarBot(1, dt)
    actualizarBot(2, dt)
    modo.proupdate(dt, {})
end

function demo.activa()
    return modo ~= nil
end

function demo.actualizar(dt)
    if not modo then
        -- sin sonido: es solo un fondo
        love.audio.setVolume(0)
        siguiente()
        if not modo then return end
    end
    dt = math.min(dt, 1 / 30)
    tiempo = tiempo + dt
    if tiempo >= DURACION then
        siguiente()
        if not modo then return end
    end
    demo.paso(dt)
    local w, h = love.graphics.getDimensions()
    local ox, oy = objetivoCamara(w / ZOOM, h / ZOOM)
    local k = 1 - math.exp(-2 * dt)
    camX, camY = camX + (ox - camX) * k, camY + (oy - camY) * k
end

-- Libera la demo (la partida real va a cargar su propio modo)
function demo.detener()
    if not modo then return end
    modo, numModo, teclas = nil, 0, {}
    love.audio.setVolume(1)
end

function demo.dibujar()
    local w, h = love.graphics.getDimensions()
    love.graphics.clear(0, 0, 0)
    if not modo then return end
    local vw, vh = w / ZOOM, h / ZOOM
    local x, y = math.floor(camX), math.floor(camY)
    love.graphics.push()
    love.graphics.scale(ZOOM)
    modo.mapa.dibujar(x, y, vw, vh, nil)
    modo.entidades.dibujar(x, y, nil, vw, vh)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
    -- fundido al empezar y al terminar cada demo
    local alfa = math.max(0, 1 - tiempo / FUNDIDO, 1 - (DURACION - tiempo) / FUNDIDO)
    if alfa > 0 then
        love.graphics.setColor(0, 0, 0, math.min(1, alfa))
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
    end
end

return demo
