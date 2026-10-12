-- Demos de fondo del menu principal (al estilo de Factorio): un modo al azar
-- con los dos tanques manejados por bots (nivel normal o dificil) y una
-- camara que sigue la accion. Cada cierto tiempo cambia de modo con un fundido a negro.
local juego = require "juego"
local bot = require "bot"

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

local function tamMapa()
    local t = modo.mapa.tablamapa
    return t.width * 64, t.height * 64
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
    modo, numModo, tiempo = m, n, 0
    for i = 1, 2 do
        bots[i] = bot.nuevo(modo, n, i, math.random(2, 3))
    end
    for _ = 1, PRECALENTAR * 60 do demo.paso(1 / 60) end
    camX, camY = objetivoCamara(w / ZOOM, h / ZOOM)
end

function demo.paso(dt)
    bots[1]:actualizar(dt)
    bots[2]:actualizar(dt)
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
    modo, numModo, bots = nil, 0, {}
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
