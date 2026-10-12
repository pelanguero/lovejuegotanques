-- Bots: tanques manejados por la computadora, con tres niveles de dificultad.
--
-- Un bot juega con las mismas reglas que una persona: "pulsa" teclas virtuales
-- "bot:<n>:<accion>" que las entidades leen con love.keyboard.isDown, y envia
-- disparos y minas como keypressed. Asi respeta el giro (solo se gira sin
-- acelerar), la inercia y la energia igual que un jugador humano.
--
-- Lo que lo hace jugar bien (segun el nivel):
--  * ve al rival con un retraso (tiempo de reaccion) y estima su velocidad
--  * apunta donde va a estar el rival cuando llegue la bala, con algo de error
--  * esquiva las balas que vienen hacia el y evita las minas del rival
--  * mientras recarga energia se mueve de lado para que no le acierten
--  * deja minas cuando lo persiguen o cuando defiende la colina
--  * va por las cajas de power-up, sobre todo si esta herido
--  * persigue el objetivo de cada modo (bandera, colina, bola)
local bot = {}

bot.NIVELES = {"Facil", "Normal", "Dificil"}

local NIVELES = {
    { -- facil: reacciona tarde, apunta mal, no esquiva ni usa minas
        reaccion = 0.45,    -- segundos de retraso con que ve al rival
        error = 0.3,        -- error de punteria (radianes)
        anticipar = 0,      -- cuanto adelanta el disparo al movimiento del rival (0..1)
        tolDisparo = 0.22,  -- radianes; nil = el ancho real del tanque rival
        cadencia = 0.9,     -- segundos minimos entre disparos
        alcance = 450,      -- distancia maxima a la que dispara
        vision = 420,       -- distancia a la que se pone a pelear
        distancia = 140,    -- distancia preferida al pelear
        esquivar = 0,       -- probabilidad de esquivar cada bala
        minas = 0,          -- probabilidad de poner una mina cuando conviene
        powerUps = 0,       -- radio en el que va por cajas
        evitarMinas = false,
        reversa = false,    -- retrocede para mantener la distancia
        flanquear = false,  -- se mueve de lado mientras recarga energia
        distraccion = 0.12, -- probabilidad por segundo de quedarse quieto un momento
    },
    { -- normal
        reaccion = 0.22, error = 0.12, anticipar = 0.6, tolDisparo = nil, cadencia = 0.45,
        alcance = 600, vision = 550, distancia = 230, esquivar = 0.45, minas = 0.5,
        powerUps = 350, evitarMinas = true, reversa = true, flanquear = false, distraccion = 0,
    },
    { -- dificil
        reaccion = 0.08, error = 0.03, anticipar = 1, tolDisparo = nil, cadencia = 0.22,
        alcance = 750, vision = 700, distancia = 300, esquivar = 0.9, minas = 1,
        powerUps = 800, evitarMinas = true, reversa = true, flanquear = true, distraccion = 0,
    },
}

local VEL_BALA = 300
local MOVIMIENTOS = {"adelante", "atras", "izquierda", "derecha"}

------------------------------------------------------------------ teclas virtuales

local teclas = {}
local isDownAnterior = love.keyboard.isDown
love.keyboard.isDown = function(...)
    local reales = {}
    for _, k in ipairs({...}) do
        if type(k) == "string" and k:sub(1, 4) == "bot:" then
            if teclas[k] then return true end
        else
            reales[#reales + 1] = k
        end
    end
    return #reales > 0 and isDownAnterior(unpack(reales)) or false
end

------------------------------------------------------------------ geometria

local pi = math.pi

local function normalizar(a)
    return (a + pi) % (2 * pi) - pi
end

-- El angulo 0 apunta hacia +Y: tanques y balas avanzan en (-sen a, cos a)
local function anguloHacia(dx, dy)
    return math.atan2(-dx, dy)
end

local function frente(a)
    return -math.sin(a), math.cos(a)
end

local function largo(x, y)
    return math.sqrt(x * x + y * y)
end

local function posicion(e)
    if e.body then return e.body:getPosition() end
    return e.posX, e.posY
end

-- Punto donde una bala disparada desde (x, y) alcanza a un blanco en (tx, ty)
-- que se mueve a (vx, vy). Si no lo alcanza, apunta adonde estara el blanco
-- cuando la bala llegue a su posicion actual.
local function intercepcion(x, y, tx, ty, vx, vy)
    local dx, dy = tx - x, ty - y
    local a = vx * vx + vy * vy - VEL_BALA * VEL_BALA
    local b = 2 * (dx * vx + dy * vy)
    local c = dx * dx + dy * dy
    local t
    if math.abs(a) < 1e-6 then
        if b < 0 then t = -c / b end
    else
        local disc = b * b - 4 * a * c
        if disc >= 0 then
            local r = math.sqrt(disc)
            local t1, t2 = (-b - r) / (2 * a), (-b + r) / (2 * a)
            if t1 > 0 and (t2 <= 0 or t1 < t2) then
                t = t1
            elseif t2 > 0 then
                t = t2
            end
        end
    end
    t = math.min(t or math.sqrt(c) / VEL_BALA, 3)
    return tx + vx * t, ty + vy * t
end

------------------------------------------------------------------ bot

local Bot = {}
Bot.__index = Bot

-- Pone al jugador n del modo cargado bajo el control de un bot.
-- numModo: 1 Team Slayer, 2 CTF, 3 King Of The Hill, 4 Crazy Ball
function bot.nuevo(modo, numModo, n, nivel)
    local prefijo = "bot:" .. n .. ":"
    for _, a in ipairs(MOVIMIENTOS) do teclas[prefijo .. a] = nil end
    local j = modo.entidades.jugadores[n]
    j.input = {adelante = prefijo .. "adelante", atras = prefijo .. "atras",
               izquierda = prefijo .. "izquierda", derecha = prefijo .. "derecha",
               disparar = prefijo .. "disparar", mina = prefijo .. "mina",
               joystick = false, njoystick = 0}
    local x, y = j.body:getPosition()
    local t = modo.mapa.tablamapa
    return setmetatable({
        modo = modo, numModo = numModo, n = n, nivel = nivel, p = NIVELES[nivel],
        prefijo = prefijo, mapaW = t.width * 64, mapaH = t.height * 64,
        t = 0, historial = {}, cadencia = 1, minaEspera = 2,
        errorAng = 0, errorEspera = 0, recargando = false,
        lado = 1, ladoEspera = 0, quieto = 0, huidaEspera = 0,
        ultX = x, ultY = y, relojAtasco = 0, empujando = false, maniobra = 0,
        -- balas que ya decidio si esquivar (claves debiles: se van con la bala)
        decididas = setmetatable({}, {__mode = "k"}),
    }, Bot)
end

function Bot:pulsar(accion)
    teclas[self.prefijo .. accion] = true
    if accion == "adelante" or accion == "atras" then self.empujando = true end
end

function Bot:girar(dif)
    self:pulsar(dif < 0 and "izquierda" or "derecha")
end

function Bot:accion(accion)
    self.modo.keypressed(self.prefijo .. accion, nil, false)
end

function Bot:rival()
    for _, r in ipairs(self.modo.entidades.jugadores) do
        if r.equipo ~= self.j.equipo then return r end
    end
end

------------------------------------------------------------------ percepcion

-- Posicion y velocidad del rival tal como las ve el bot: con `reaccion`
-- segundos de retraso.
function Bot:verRival(rival)
    local h = self.historial
    local x, y = rival.body:getPosition()
    local ultimo = h[#h]
    if ultimo and largo(x - ultimo.x, y - ultimo.y) > 150 then
        -- reaparecio en su base: lo que vio antes ya no sirve
        h = {}
        self.historial = h
    end
    h[#h + 1] = {t = self.t, x = x, y = y}
    local limite = self.t - self.p.reaccion
    while h[2] and h[2].t <= limite - 0.25 do table.remove(h, 1) end
    local visto = h[#h]
    for i = 1, #h do
        if h[i].t >= limite then visto = h[i] break end
    end
    local antes = h[1]
    for i = #h, 1, -1 do
        if h[i].t <= visto.t - 0.2 then antes = h[i] break end
    end
    local vx, vy = 0, 0
    local dt = visto.t - antes.t
    if dt > 0.05 then
        vx, vy = (visto.x - antes.x) / dt, (visto.y - antes.y) / dt
    end
    return visto.x, visto.y, vx, vy
end

-- Punto al que apunta: donde estara el rival, girado un poco por el error
-- de punteria (que cambia cada tanto, como el pulso de una persona)
function Bot:apuntar(dt, rx, ry, rvx, rvy)
    local p = self.p
    self.errorEspera = self.errorEspera - dt
    if self.errorEspera <= 0 then
        self.errorAng = (math.random() * 2 - 1) * p.error
        self.errorEspera = 0.6 + math.random() * 0.6
    end
    local ix, iy = intercepcion(self.x, self.y, rx, ry, rvx * p.anticipar, rvy * p.anticipar)
    local dx, dy = ix - self.x, iy - self.y
    local c, s = math.cos(self.errorAng), math.sin(self.errorAng)
    return self.x + dx * c - dy * s, self.y + dx * s + dy * c
end

-- La bala del rival que va a pasar mas pronto cerca del bot, si decide
-- esquivarla (cada bala se decide una sola vez, con probabilidad `esquivar`).
-- Tiene en cuenta que el bot tambien se mueve: una bala que lo sigue por
-- detras mientras huye a toda velocidad no lo alcanza.
function Bot:amenaza()
    local p = self.p
    if p.esquivar <= 0 then return nil end
    local tx, ty = frente(self.j.angulo)
    local tvx, tvy = tx * self.j.magnitud, ty * self.j.magnitud
    local mejor, mejorT
    for _, pr in ipairs(self.modo.entidades.proyectiles) do
        if pr.tipo == 1 and pr.equipo ~= self.j.equipo then
            local bx, by = posicion(pr)
            local fx, fy = frente(pr.angulo)
            -- movimiento de la bala visto desde el tanque
            local wx, wy = fx * VEL_BALA - tvx, fy * VEL_BALA - tvy
            local w2 = wx * wx + wy * wy
            local rx, ry = self.x - bx, self.y - by
            local t = w2 > 100 and (rx * wx + ry * wy) / w2 or -1
            if t > 0 and t < 1.5 then
                local cx, cy = bx + wx * t, by + wy * t
                if largo(self.x - cx, self.y - cy) < 48 then
                    if self.decididas[pr] == nil then
                        self.decididas[pr] = math.random() < p.esquivar
                    end
                    if self.decididas[pr] and (not mejorT or t < mejorT) then
                        mejor, mejorT = {cx = cx, cy = cy, fx = fx, fy = fy}, t
                    end
                end
            end
        end
    end
    return mejor
end

-- Caja de power-up disponible mas cercana dentro del radio
function Bot:cajaCercana(radio)
    local mejor, md
    for _, pw in ipairs(self.modo.entidades.powerUps) do
        if pw.vida > 60 then
            local d = largo(pw.posX - self.x, pw.posY - self.y)
            if d < radio and (not md or d < md) then mejor, md = pw, d end
        end
    end
    return mejor
end

------------------------------------------------------------------ movimiento

function Bot:frenar()
    local m = self.j.magnitud
    if m > 25 then
        teclas[self.prefijo .. "atras"] = true
    elseif m < -25 then
        teclas[self.prefijo .. "adelante"] = true
    end
end

-- Avanza en la direccion (dx, dy); con permitirReversa, si la direccion
-- queda detras del tanque, retrocede en lugar de dar la vuelta
function Bot:moverEnDireccion(dx, dy, dist, permitirReversa)
    local j = self.j
    local dif = normalizar(anguloHacia(dx, dy) - j.angulo)
    local tecla = "adelante"
    if permitirReversa and math.abs(dif) > 2 then
        dif = normalizar(dif + pi)
        tecla = "atras"
    end
    -- de cerca hace falta mas precision para no pasarse de largo
    local tol = math.max(0.12, math.min(0.35, math.atan2(40, dist)))
    local lento = math.abs(j.magnitud) < 60 + dist * 0.8
    if math.abs(dif) <= math.atan2(25, dist) or (math.abs(dif) <= tol and lento) then
        self:pulsar(tecla)
    elseif math.abs(dif) <= tol then
        -- rapido y un poco desviado de un punto chico (bandera, caja):
        -- corrige sin acelerar para no pasarse de largo
        self:girar(dif)
    elseif math.abs(dif) > 1 and math.abs(j.magnitud) > 150 and dist < 300 then
        -- va muy rapido para girar sin dar una vuelta enorme: primero frena
        self:frenar()
    else
        self:girar(dif)
    end
end

-- Desvia la direccion (dx, dy) para no pisar las minas del rival que hay delante
function Bot:evitarMinas(dx, dy)
    local d = largo(dx, dy)
    if d < 1 then return dx, dy end
    dx, dy = dx / d, dy / d
    local ox, oy = 0, 0
    for _, pr in ipairs(self.modo.entidades.proyectiles) do
        if pr.tipo == 2 and pr.equipo ~= self.j.equipo then
            local mx, my = posicion(pr)
            local rx, ry = mx - self.x, my - self.y
            local delante = rx * dx + ry * dy
            local lateral = -rx * dy + ry * dx
            if delante > -20 and delante < 260 and math.abs(lateral) < 75 then
                local s = lateral >= 0 and -1 or 1
                local fuerza = 1.6 * (1 - math.max(0, delante) / 260)
                ox, oy = ox - s * dy * fuerza, oy + s * dx * fuerza
            end
        end
    end
    return dx + ox, dy + oy
end

-- Maneja hacia (tx, ty); dentro de radioLlegada frena y se queda
function Bot:irHacia(tx, ty, radioLlegada)
    local dx, dy = tx - self.x, ty - self.y
    local dist = largo(dx, dy)
    if radioLlegada and dist < radioLlegada then
        self:frenar()
        return
    end
    if self.p.evitarMinas then dx, dy = self:evitarMinas(dx, dy) end
    self:moverEnDireccion(dx, dy, dist, self.p.reversa and dist < 250)
end

-- Se aparta de la linea de una bala que viene hacia el
function Bot:esquivar(a)
    local fx, fy = frente(self.j.angulo)
    local ex, ey = self.x - a.cx, self.y - a.cy
    if largo(ex, ey) < 5 then
        -- viene derecha al centro: hacia el lado al que ya mira
        ex, ey = -a.fy, a.fx
        if ex * fx + ey * fy < 0 then ex, ey = -ex, -ey end
    end
    local alineado = (ex * fx + ey * fy) / largo(ex, ey)
    if alineado > 0.3 then
        self:pulsar("adelante")
    elseif alineado < -0.3 then
        self:pulsar("atras")
    else
        -- de frente o de espaldas a la salida: gira lo minimo para poder moverse
        local dif = normalizar(anguloHacia(ex, ey) - self.j.angulo)
        if math.abs(dif) > pi / 2 then dif = normalizar(dif + pi) end
        self:girar(dif)
    end
end

-- Pelea con el rival: apunta, mantiene la distancia y, si sabe, se mueve
-- de lado mientras recarga energia. ancla: zona que no quiere abandonar
function Bot:combatir(rx, ry, dist, ax, ay, ancla)
    local p, j = self.p, self.j
    if j.energia < 25 then
        self.recargando = true
    elseif j.energia >= 70 then
        self.recargando = false
    end
    if p.flanquear and self.recargando and dist > 180 and dist < p.alcance and not ancla then
        local ux, uy = (rx - self.x) / dist, (ry - self.y) / dist
        local radial = 0
        if dist > p.distancia + 100 then radial = 0.6 elseif dist < p.distancia - 100 then radial = -0.6 end
        local mx, my = -uy * self.lado + ux * radial, ux * self.lado + uy * radial
        -- cambia de lado cada tanto, o antes de chocar con el borde del mapa
        local fx, fy = self.x + mx * 200, self.y + my * 200
        if self.ladoEspera <= 0 or fx < 100 or fy < 100 or fx > self.mapaW - 100 or fy > self.mapaH - 100 then
            self.lado = -self.lado
            self.ladoEspera = 1.5 + math.random() * 1.5
            mx, my = -uy * self.lado + ux * radial, ux * self.lado + uy * radial
        end
        self:moverEnDireccion(mx, my, 1000, false)
        return
    end
    local dif = normalizar(anguloHacia(ax - self.x, ay - self.y) - j.angulo)
    local fuera = ancla and largo(self.x - ancla.x, self.y - ancla.y) > ancla.r
    if math.abs(dif) > math.max(0.02, math.atan2(14, dist)) then
        self:girar(dif)
    elseif dist > p.distancia + 80 and not fuera then
        self:pulsar("adelante")
    elseif dist < p.distancia - 60 and p.reversa then
        self:pulsar("atras")
    else
        self:frenar()
    end
end

-- Punto lejos del rival (y dentro del mapa) al que huir con la bola
function Bot:puntoDeHuida(rx, ry)
    if self.huidaEspera > 0 and self.huidaX then return self.huidaX, self.huidaY end
    local mejor, mx, my = -math.huge, self.x, self.y
    for i = 0, 7 do
        local a = i * pi / 4
        local px = math.max(120, math.min(self.mapaW - 120, self.x + math.cos(a) * 350))
        local py = math.max(120, math.min(self.mapaH - 120, self.y + math.sin(a) * 350))
        -- lejos del rival, y mejor si no hay que dar la vuelta
        local giro = math.cos(normalizar(anguloHacia(px - self.x, py - self.y) - self.j.angulo))
        local puntaje = largo(px - rx, py - ry) + 80 * giro + largo(px - self.x, py - self.y) * 0.3
        if puntaje > mejor then mejor, mx, my = puntaje, px, py end
    end
    self.huidaX, self.huidaY, self.huidaEspera = mx, my, 0.5
    return mx, my
end

------------------------------------------------------------------ decisiones

-- Que hacer segun el modo: a donde ir, si pelear y en que situacion esta.
function Bot:planear(rival, rx, ry, dist)
    local p, j, E = self.p, self.j, self.modo.entidades
    local plan = {x = rx, y = ry, pelear = dist < p.vision}
    local m = self.numModo
    if m == 2 and E.banderas then
        local base, suya = E.banderas[j.equipo], nil
        for _, b in ipairs(E.banderas) do
            if b.equipo ~= j.equipo then suya = b end
        end
        if j.banderaa and base then
            -- lleva la bandera: a casa sin entretenerse, salvo para matar al
            -- rival si se cruzan llevando la nuestra (la bandera vuelve a casa
            -- y el rival reaparece lejos)
            plan.x, plan.y, plan.situacion = base.x, base.y, "huir"
            plan.pelear = rival.banderaa and dist < p.vision * 0.6
        elseif rival.banderaa and dist < p.vision then
            -- el rival lleva nuestra bandera y esta a tiro: a cazarlo (si ya
            -- se escapo no lo alcanza: mejor ir por la suya, que es adonde vuelve)
            plan.pelear = true
        elseif suya and suya.is then
            -- es una carrera: no se entretiene salvo que el rival se le eche encima
            plan.x, plan.y = suya.posX, suya.posY
            plan.pelear = dist < 220
        end
    elseif m == 3 and E.colina and E.colina[1] then
        local c, r = E.colina[1], E.rcolina or 250
        local dentro = largo(self.x - c.posX, self.y - c.posY) < r * 0.6
        plan.x, plan.y, plan.llegar = c.posX, c.posY, r * 0.3
        -- afuera no suma: entra a la colina (disparando de paso) y pelea desde
        -- adentro; solo se detiene a pelear si el rival se le echa encima
        plan.pelear = dist < 200 or (dentro and dist < p.vision)
        if dentro then
            plan.situacion = "defender"
            plan.ancla = {x = c.posX, y = c.posY, r = r * 0.7}
        end
    elseif m == 4 and E.banderas then
        local bola = E.banderas[1]
        if j.banderaa then
            -- tiene la bola: suma puntos mientras no lo alcancen
            plan.x, plan.y = self:puntoDeHuida(rx, ry)
            plan.pelear, plan.situacion = false, "huir"
        elseif bola and bola.is then
            -- matar no da puntos: solo pelea si el rival se le echa encima
            -- o le va a ganar la bola
            local db = largo(bola.posX - self.x, bola.posY - self.y)
            local rb = largo(bola.posX - rx, bola.posY - ry)
            plan.x, plan.y = bola.posX, bola.posY
            plan.pelear = dist < 200 or (rb < db and dist < p.vision)
        else
            plan.pelear = true -- el rival tiene la bola: a quitarsela
        end
    end
    -- power-ups: en Team Slayer, si esta herido, va a buscarlos aunque haya
    -- pelea; si no (o en los modos con objetivo), solo los toma de paso
    if p.powerUps > 0 and plan.situacion ~= "huir" then
        local herido = j.vida <= 40 and p.flanquear and m == 1
        if not plan.pelear or herido then
            local caja = self:cajaCercana(herido and p.powerUps or p.powerUps * 0.3)
            if caja then
                plan.x, plan.y, plan.pelear, plan.llegar, plan.ancla = caja.posX, caja.posY, false, nil, nil
            end
        end
    end
    return plan
end

function Bot:intentarDisparar(dt, ax, ay, dist)
    local p, j = self.p, self.j
    self.cadencia = self.cadencia - dt
    if self.cadencia > 0 or dist > p.alcance or j.energia <= (j.danhoproyectil or 20) then return end
    local dif = normalizar(anguloHacia(ax - self.x, ay - self.y) - j.angulo)
    if math.abs(dif) < (p.tolDisparo or math.atan2(26, dist)) then
        self:accion("disparar")
        self.cadencia = p.cadencia * (0.8 + math.random() * 0.6)
    end
end

-- Minas: detras de si cuando lo persiguen, o en la colina que defiende
function Bot:usarMinas(dt, rx, ry, rvx, rvy, dist, situacion)
    local p, j = self.p, self.j
    self.minaEspera = self.minaEspera - dt
    if p.minas <= 0 or self.minaEspera > 0 or j.energia <= (j.danhomina or 50) then return end
    local detras = math.abs(normalizar(anguloHacia(rx - self.x, ry - self.y) - j.angulo)) > 2.2
    local acercandose = (self.x - rx) * rvx + (self.y - ry) * rvy > 0
    local conviene = (dist < 280 and detras and acercandose and j.magnitud > 60)
        or (situacion == "defender" and dist > 200 and dist < 600 and acercandose and j.energia > 85)
    if conviene then
        self.minaEspera = 1.5
        if math.random() < p.minas then
            self:accion("mina")
            self.minaEspera = 3
        end
    end
end

-- Si lleva un rato empujando sin moverse (borde del mapa o el otro
-- tanque), gira hacia el centro del mapa y sale. Devuelve true mientras maniobra.
function Bot:atascado(dt)
    self.relojAtasco = self.relojAtasco + dt
    if self.relojAtasco > 1 then
        if self.empujando and largo(self.x - self.ultX, self.y - self.ultY) < 15 then
            self.maniobra = 1.2
        end
        self.relojAtasco, self.ultX, self.ultY, self.empujando = 0, self.x, self.y, false
    end
    if self.maniobra <= 0 then return false end
    self.maniobra = self.maniobra - dt
    local cx, cy = self.mapaW / 2 - self.x, self.mapaH / 2 - self.y
    self:moverEnDireccion(cx, cy, largo(cx, cy), false)
    self.empujando = false
    return true
end

-- El bot facil a veces se distrae y deja de manejar un momento
function Bot:distraido(dt)
    if self.quieto > 0 then
        self.quieto = self.quieto - dt
        return true
    end
    if self.p.distraccion > 0 and math.random() < self.p.distraccion * dt then
        self.quieto = 0.5 + math.random() * 0.8
    end
    return false
end

function Bot:actualizar(dt)
    local j = self.modo.entidades.jugadores[self.n]
    self.j = j
    for _, a in ipairs(MOVIMIENTOS) do teclas[self.prefijo .. a] = false end
    self.t = self.t + dt
    self.ladoEspera = self.ladoEspera - dt
    self.huidaEspera = self.huidaEspera - dt
    local rival = self:rival()
    if not rival then return end
    self.x, self.y = j.body:getPosition()
    local rx, ry, rvx, rvy = self:verRival(rival)
    local dist = largo(rx - self.x, ry - self.y)

    if self:atascado(dt) or self:distraido(dt) then return end

    local ax, ay = self:apuntar(dt, rx, ry, rvx, rvy)
    local plan = self:planear(rival, rx, ry, dist)
    local a = self:amenaza()
    if a then
        self:esquivar(a)
    elseif plan.pelear then
        self:combatir(rx, ry, dist, ax, ay, plan.ancla)
    else
        self:irHacia(plan.x, plan.y, plan.llegar)
    end
    -- dispara si tiene al rival en la mira, aunque este haciendo otra cosa
    self:intentarDisparar(dt, ax, ay, dist)
    self:usarMinas(dt, rx, ry, rvx, rvy, dist, plan.situacion)
end

return bot
