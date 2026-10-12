-- Interfaz de menus: principal, configuracion de partida y pausa.
-- Los widgets se construyen una sola vez por pantalla (no en cada frame)
-- y cachean sus objetos Text.

interf = {
    elementos = {},
    seleccionado = 1,
    -- pantallas
    MENU = 1, CONFIG = 2, PAUSA = 3, JUGANDO = 4, FIN = 5,
    even = 1,
    ini = {jugadores = 1, modo = 2, numMuertes = 20, capturas = 3, rondas = 1, time = 120},
    -- callbacks que asigna main.lua
    alIniciar = nil,
    alSalir = nil,
    mensajeError = nil,
    resultado = nil,
}

local font = love.graphics.newFont("arial_/arial_narrow_7.ttf", 22)
local fontTitulo = love.graphics.newFont("arial_/arial_narrow_7.ttf", 48)

local colores = {
    fondo = {46/255, 64/255, 83/255},
    texto = {1, 1, 1},
    tenue = {0.7, 0.75, 0.8},
    acento = {244/255, 208/255, 63/255},
    caja = {1, 1, 1, 0.08},
    cajaHover = {244/255, 208/255, 63/255, 0.2},
    error = {1, 0.45, 0.4},
}

local modos = {"Team Slayer", "Capture The Flag", "King Of The Hill", "Crazy Ball"}

local ANCHO_BOTON = 300
local ALTO_FILA = 40
local PAD = 8

local titulo = nil

------------------------------------------------------------------ widgets

local function nuevoTexto(txt, f)
    return love.graphics.newText(f or font, txt)
end

local function boton(texto, accion)
    return {tipo = "boton", texto = nuevoTexto(texto), accion = accion,
            w = ANCHO_BOTON, h = ALTO_FILA}
end

-- Selector con valor numerico: [etiqueta]  < valor >
local function selector(texto, campo, paso, min, max)
    return {tipo = "selector", texto = nuevoTexto(texto), campo = campo,
            paso = paso, min = min, max = max, w = ANCHO_BOTON + 200, h = ALTO_FILA}
end

-- Selector de opciones de una lista (modo de juego)
local function opciones(texto, campo, lista)
    return {tipo = "opciones", texto = nuevoTexto(texto), campo = campo,
            lista = lista, w = ANCHO_BOTON + 200, h = ALTO_FILA}
end

local function cambiar(ele, dir)
    local ini = interf.ini
    if ele.tipo == "selector" then
        local v = ini[ele.campo] + dir * ele.paso
        ini[ele.campo] = math.max(ele.min, math.min(ele.max, v))
    elseif ele.tipo == "opciones" then
        local n = #ele.lista
        ini[ele.campo] = (ini[ele.campo] - 1 + dir) % n + 1
        interf.irA(interf.CONFIG, true) -- las opciones dependen del modo
    end
end

local function valorTexto(ele)
    local v = interf.ini[ele.campo]
    if ele.tipo == "opciones" then return ele.lista[v] end
    if ele.campo == "time" then
        return string.format("%d:%02d", math.floor(v / 60), v % 60)
    end
    return tostring(v)
end

-- Zonas de las flechas < > de un selector
local function zonasFlechas(ele)
    local x = ele.x + ele.w - 240
    return {x = x, y = ele.y, w = 30, h = ele.h},
           {x = x + 210, y = ele.y, w = 30, h = ele.h}
end

local function dentro(px, py, r)
    return px >= r.x and px <= r.x + r.w and py >= r.y and py <= r.y + r.h
end

------------------------------------------------------------------ pantallas

local function construir(lista)
    -- inicio fijo: las filas no se mueven al cambiar de modo (5 o 6 filas)
    local y = 170
    local cx = love.graphics.getWidth() / 2
    for _, ele in ipairs(lista) do
        ele.x = math.floor(cx - ele.w / 2)
        ele.y = math.floor(y)
        y = y + ALTO_FILA + PAD
    end
    interf.elementos = lista
end

local paginas = {}

paginas[interf.MENU] = function()
    titulo = nuevoTexto("TANQUES 2D", fontTitulo)
    construir({
        boton("Jugar", function() interf.irA(interf.CONFIG) end),
        boton("Salir", function() if interf.alSalir then interf.alSalir() end end),
    })
end

paginas[interf.CONFIG] = function()
    titulo = nuevoTexto("Nueva partida", fontTitulo)
    local lista = {
        opciones("Modo de juego", "modo", modos),
        selector("Jugadores", "jugadores", 1, 1, 4),
    }
    local modo = interf.ini.modo
    if modo == 1 then
        table.insert(lista, selector("Muertes para ganar", "numMuertes", 5, 20, 100))
    elseif modo == 2 then
        table.insert(lista, selector("Capturas por ronda", "capturas", 1, 3, 6))
        table.insert(lista, selector("Rondas para ganar", "rondas", 1, 1, 3))
    else
        table.insert(lista, selector("Tiempo por ronda", "time", 30, 120, 600))
        table.insert(lista, selector("Rondas para ganar", "rondas", 1, 1, 3))
    end
    table.insert(lista, boton("Comenzar", function() paginas.iniciarPartida() end))
    table.insert(lista, boton("Volver", function() interf.irA(interf.MENU) end))
    construir(lista)
end

function paginas.iniciarPartida()
    local ok, err = true, nil
    if interf.alIniciar then ok, err = pcall(interf.alIniciar, interf.ini) end
    if ok then
        interf.irA(interf.JUGANDO)
    else
        interf.mensajeError = "No se pudo iniciar " .. modos[interf.ini.modo] .. ": " .. tostring(err)
        print(interf.mensajeError)
    end
end

paginas[interf.FIN] = function()
    titulo = nuevoTexto(interf.resultado or "Fin de la partida", fontTitulo)
    construir({
        boton("Jugar de nuevo", function() paginas.iniciarPartida() end),
        boton("Menu principal", function() interf.irA(interf.MENU) end),
    })
end

-- Muestra la pantalla de resultados al terminar una partida
function interf.mostrarResultado(texto)
    interf.resultado = texto
    interf.irA(interf.FIN)
end

paginas[interf.PAUSA] = function()
    titulo = nuevoTexto("Pausa", fontTitulo)
    construir({
        boton("Seguir jugando", function() interf.irA(interf.JUGANDO) end),
        boton("Menu principal", function() interf.irA(interf.MENU) end),
    })
end

-- Cambia de pantalla y reconstruye sus elementos.
-- mantenerSeleccion conserva el elemento resaltado (util al refrescar CONFIG).
function interf.irA(pantalla, mantenerSeleccion)
    interf.even = pantalla
    interf.mensajeError = nil
    interf.elementos = {}
    if paginas[pantalla] then paginas[pantalla]() end
    if not mantenerSeleccion then interf.seleccionado = 1 end
    interf.seleccionado = math.min(interf.seleccionado, math.max(1, #interf.elementos))
end

function interf.enMenu()
    return interf.even ~= interf.JUGANDO
end

------------------------------------------------------------------ dibujo

local function dibujarElemento(ele, activo)
    love.graphics.setColor(activo and colores.cajaHover or colores.caja)
    love.graphics.rectangle("fill", ele.x, ele.y, ele.w, ele.h, 6, 6)
    if activo then
        love.graphics.setColor(colores.acento)
        love.graphics.rectangle("line", ele.x, ele.y, ele.w, ele.h, 6, 6)
    end

    local th = ele.texto:getHeight()
    local ty = ele.y + (ele.h - th) / 2
    love.graphics.setColor(activo and colores.acento or colores.texto)

    if ele.tipo == "boton" then
        love.graphics.draw(ele.texto, ele.x + (ele.w - ele.texto:getWidth()) / 2, ty)
        return
    end

    love.graphics.draw(ele.texto, ele.x + 12, ty)
    local izq, der = zonasFlechas(ele)
    love.graphics.setColor(colores.tenue)
    love.graphics.printf("<", font, izq.x, ty, izq.w, "center")
    love.graphics.printf(">", font, der.x, ty, der.w, "center")
    love.graphics.setColor(colores.texto)
    love.graphics.printf(valorTexto(ele), font, izq.x + izq.w, ty, der.x - izq.x - izq.w, "center")
end

function interf.dibijarElementos()
    love.graphics.clear(colores.fondo)
    if titulo then
        love.graphics.setColor(colores.acento)
        love.graphics.draw(titulo, math.floor((love.graphics.getWidth() - titulo:getWidth()) / 2), 50)
    end
    for i, ele in ipairs(interf.elementos) do
        dibujarElemento(ele, i == interf.seleccionado)
    end
    if interf.mensajeError then
        love.graphics.setColor(colores.error)
        love.graphics.printf(interf.mensajeError, font, 40, love.graphics.getHeight() - 90,
            love.graphics.getWidth() - 80, "center")
    end
    love.graphics.setColor(colores.tenue)
    love.graphics.print("Flechas/raton para navegar - Enter para elegir - Esc para volver",
        font, 20, love.graphics.getHeight() - 36)
    love.graphics.setColor(1, 1, 1)
end

------------------------------------------------------------------ entrada

local function activar(ele)
    if not ele then return end
    if ele.tipo == "boton" then
        ele.accion()
    else
        cambiar(ele, 1)
    end
end

function interf.mousemoved(x, y)
    for i, ele in ipairs(interf.elementos) do
        if dentro(x, y, ele) then interf.seleccionado = i end
    end
end

function interf.mousehandler(x, y, button)
    if button ~= 1 then return end
    for i, ele in ipairs(interf.elementos) do
        if dentro(x, y, ele) then
            interf.seleccionado = i
            if ele.tipo == "boton" then
                ele.accion()
            else
                local izq = zonasFlechas(ele)
                cambiar(ele, x < izq.x + izq.w and -1 or 1)
            end
            return
        end
    end
end

function interf.keypressed(key)
    local n = #interf.elementos
    local ele = interf.elementos[interf.seleccionado]
    if key == "up" or key == "w" then
        interf.seleccionado = (interf.seleccionado - 2) % n + 1
    elseif key == "down" or key == "s" then
        interf.seleccionado = interf.seleccionado % n + 1
    elseif (key == "left" or key == "a") and ele and ele.tipo ~= "boton" then
        cambiar(ele, -1)
    elseif (key == "right" or key == "d") and ele and ele.tipo ~= "boton" then
        cambiar(ele, 1)
    elseif key == "return" or key == "kpenter" or key == "space" then
        activar(ele)
    elseif key == "escape" then
        if interf.even == interf.PAUSA then
            interf.irA(interf.JUGANDO)
        elseif interf.even == interf.CONFIG or interf.even == interf.FIN then
            interf.irA(interf.MENU)
        end
    end
end

return interf
