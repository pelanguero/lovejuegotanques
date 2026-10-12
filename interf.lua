-- Interfaz de menus: principal, en linea, configuracion de partida y pausa.
-- Los widgets se construyen una sola vez por pantalla (no en cada frame)
-- y cachean sus objetos Text.

interf = {
    elementos = {},
    seleccionado = 1,
    -- pantallas
    MENU = 1, CONFIG = 2, PAUSA = 3, JUGANDO = 4, FIN = 5, ONLINE = 6, ESPERA = 7,
    even = 1,
    -- pantalla: 1 = dividida en una ventana, 2 = una ventana por jugador
    ini = {jugadores = 1, modo = 2, pantalla = 1, numMuertes = 20, capturas = 3, rondas = 1, time = 120},
    -- nil en partida local; "anfitrion" o "cliente" en linea
    enLinea = nil,
    ipDestino = "127.0.0.1",
    -- callbacks que asigna main.lua
    alIniciar = nil,
    alSalir = nil,
    alCrearOnline = nil,
    alUnirseOnline = nil,
    alVolverAlMenu = nil,
    mensajeError = nil,
    subtitulo = nil,
    resultado = nil,
    revancha = true,
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
local pantallas = {"Dividida", "Ventanas separadas"}

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

-- Campo de texto editable (guarda el valor en interf[campo])
local function campoTexto(texto, campo)
    return {tipo = "texto", texto = nuevoTexto(texto), campo = campo,
            w = ANCHO_BOTON + 200, h = ALTO_FILA}
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
        boton("Jugar", function()
            interf.enLinea = nil
            interf.irA(interf.CONFIG)
        end),
        boton("Jugar en linea", function() interf.irA(interf.ONLINE) end),
        boton("Salir", function() if interf.alSalir then interf.alSalir() end end),
    })
end

paginas[interf.CONFIG] = function()
    titulo = nuevoTexto("Nueva partida", fontTitulo)
    local lista = {opciones("Modo de juego", "modo", modos)}
    if interf.enLinea then
        interf.subtitulo = "En linea: el jugador 2 esta conectado"
    else
        table.insert(lista, selector("Jugadores", "jugadores", 1, 1, 4))
        table.insert(lista, opciones("Pantalla", "pantalla", pantallas))
    end
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

-- alIniciar devuelve "esperando" si la partida empieza mas tarde
-- (ventanas separadas: falta que se conecte la segunda ventana)
function paginas.iniciarPartida()
    local ok, err = true, nil
    if interf.alIniciar then ok, err = pcall(interf.alIniciar, interf.ini) end
    if ok and err == "esperando" then return end
    if ok then
        interf.irA(interf.JUGANDO)
    else
        interf.mensajeError = "No se pudo iniciar " .. modos[interf.ini.modo] .. ": " .. tostring(err)
        print(interf.mensajeError)
    end
end

paginas[interf.FIN] = function()
    titulo = nuevoTexto(interf.resultado or "Fin de la partida", fontTitulo)
    local lista = {}
    if interf.revancha then
        table.insert(lista, boton("Jugar de nuevo", function() paginas.iniciarPartida() end))
    end
    table.insert(lista, boton("Menu principal", function() interf.irA(interf.MENU) end))
    construir(lista)
end

-- Muestra la pantalla de resultados al terminar una partida.
-- revancha=false oculta "Jugar de nuevo" (cliente en linea o conexion perdida)
function interf.mostrarResultado(texto, subtitulo, revancha)
    interf.resultado = texto
    interf.revancha = revancha ~= false
    interf.irA(interf.FIN)
    interf.subtitulo = subtitulo
end

paginas[interf.PAUSA] = function()
    titulo = nuevoTexto("Pausa", fontTitulo)
    if interf.enLinea then
        interf.subtitulo = "La partida sigue corriendo"
    end
    construir({
        boton("Seguir jugando", function() interf.irA(interf.JUGANDO) end),
        boton(interf.enLinea and "Abandonar partida" or "Menu principal", function() interf.irA(interf.MENU) end),
    })
end

paginas[interf.ONLINE] = function()
    titulo = nuevoTexto("Jugar en linea", fontTitulo)
    interf.subtitulo = interf.infoRed
    construir({
        boton("Crear partida", function()
            local ok, err = interf.alCrearOnline()
            if ok then
                interf.esperar("Esperando jugador", interf.infoRed)
            else
                interf.mensajeError = "No se pudo crear la partida: " .. tostring(err)
            end
        end),
        campoTexto("IP del anfitrion", "ipDestino"),
        boton("Unirse", paginas.unirse),
        boton("Volver", function() interf.irA(interf.MENU) end),
    })
end

function paginas.unirse()
    local ip = interf.ipDestino
    if ip == "" then
        interf.mensajeError = "Escribe la IP del anfitrion"
        return
    end
    local ok, err = interf.alUnirseOnline(ip)
    if ok then
        interf.esperar("Conectando", "Conectando con " .. ip .. "...")
    else
        interf.mensajeError = "No se pudo conectar: " .. tostring(err)
    end
end

paginas[interf.ESPERA] = function()
    titulo = nuevoTexto(interf.tituloEspera or "", fontTitulo)
    construir({
        boton("Cancelar", function() interf.irA(interf.MENU) end),
    })
end

-- Pantalla de espera en linea (crear partida, conectando, esperando inicio)
function interf.esperar(tituloEspera, subtitulo)
    interf.tituloEspera = tituloEspera
    interf.irA(interf.ESPERA)
    interf.subtitulo = subtitulo
end

-- Cambia de pantalla y reconstruye sus elementos.
-- mantenerSeleccion conserva el elemento resaltado (util al refrescar CONFIG).
function interf.irA(pantalla, mantenerSeleccion)
    if pantalla == interf.MENU and interf.alVolverAlMenu then
        interf.alVolverAlMenu() -- cierra la conexion en linea, si la hay
        interf.enLinea = nil
    end
    interf.even = pantalla
    interf.mensajeError = nil
    interf.subtitulo = nil
    interf.elementos = {}
    if paginas[pantalla] then paginas[pantalla]() end
    if not mantenerSeleccion then interf.seleccionado = 1 end
    interf.seleccionado = math.min(interf.seleccionado, math.max(1, #interf.elementos))
end

function interf.enMenu()
    return interf.even ~= interf.JUGANDO
end

-- true si el foco esta en un campo de texto (las letras se escriben)
function interf.escribiendo()
    local ele = interf.elementos[interf.seleccionado]
    return interf.enMenu() and ele ~= nil and ele.tipo == "texto"
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
    if ele.tipo == "texto" then
        local x = ele.x + ele.w - 250
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x, ele.y + 5, 240, ele.h - 10, 4, 4)
        love.graphics.setColor(colores.texto)
        local cursor = (activo and love.timer.getTime() % 1 < 0.5) and "_" or ""
        love.graphics.print(interf[ele.campo] .. cursor, font, x + 8, ty)
        return
    end
    local izq, der = zonasFlechas(ele)
    love.graphics.setColor(colores.tenue)
    love.graphics.printf("<", font, izq.x, ty, izq.w, "center")
    love.graphics.printf(">", font, der.x, ty, der.w, "center")
    love.graphics.setColor(colores.texto)
    love.graphics.printf(valorTexto(ele), font, izq.x + izq.w, ty, der.x - izq.x - izq.w, "center")
end

-- Panel oscuro detras del titulo y los elementos, para leerlos sobre el juego
local function dibujarPanel()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, w, h)
    local ancho = titulo and titulo:getWidth() or 0
    local abajo = 160
    for _, ele in ipairs(interf.elementos) do
        ancho = math.max(ancho, ele.w)
        abajo = math.max(abajo, ele.y + ele.h)
    end
    if interf.subtitulo then
        ancho = math.max(ancho, math.min(font:getWidth(interf.subtitulo), w - 80))
    end
    ancho = ancho + 60
    local x = math.floor((w - ancho) / 2)
    love.graphics.setColor(colores.fondo[1], colores.fondo[2], colores.fondo[3], 0.88)
    love.graphics.rectangle("fill", x, 30, ancho, abajo - 30 + 24, 10, 10)
    love.graphics.setColor(colores.acento[1], colores.acento[2], colores.acento[3], 0.35)
    love.graphics.rectangle("line", x, 30, ancho, abajo - 30 + 24, 10, 10)
    -- franja inferior para la ayuda y los errores
    local franja = interf.mensajeError and 100 or 46
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, h - franja, w, franja)
end

-- sobreFondo=true: algo ya se dibujo detras (demo o partida en pausa)
function interf.dibijarElementos(sobreFondo)
    if sobreFondo then
        dibujarPanel()
    else
        love.graphics.clear(colores.fondo)
    end
    if titulo then
        love.graphics.setColor(colores.acento)
        love.graphics.draw(titulo, math.floor((love.graphics.getWidth() - titulo:getWidth()) / 2), 50)
    end
    if interf.subtitulo then
        love.graphics.setColor(colores.tenue)
        love.graphics.printf(interf.subtitulo, font, 40, 112, love.graphics.getWidth() - 80, "center")
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
    elseif ele.tipo == "texto" then
        paginas.unirse() -- Enter en el campo de IP
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
            elseif ele.tipo ~= "texto" then
                local izq = zonasFlechas(ele)
                cambiar(ele, x < izq.x + izq.w and -1 or 1)
            end
            return
        end
    end
end

function interf.textinput(t)
    local ele = interf.elementos[interf.seleccionado]
    if not interf.escribiendo() then return end
    local v = interf[ele.campo]
    -- solo caracteres validos en una IP o nombre de equipo
    if #v < 64 and t:match("^[%w%.%-:]$") then
        interf[ele.campo] = v .. t
    end
end

function interf.keypressed(key)
    local n = #interf.elementos
    local ele = interf.elementos[interf.seleccionado]
    if interf.escribiendo() then
        if key == "backspace" then
            interf[ele.campo] = interf[ele.campo]:sub(1, -2)
            return
        end
        -- las letras van al campo (textinput); solo flechas navegan
        if #key == 1 then return end
    end
    if key == "up" or key == "w" then
        interf.seleccionado = (interf.seleccionado - 2) % n + 1
    elseif key == "down" or key == "s" then
        interf.seleccionado = interf.seleccionado % n + 1
    elseif (key == "left" or key == "a") and ele and (ele.tipo == "selector" or ele.tipo == "opciones") then
        cambiar(ele, -1)
    elseif (key == "right" or key == "d") and ele and (ele.tipo == "selector" or ele.tipo == "opciones") then
        cambiar(ele, 1)
    elseif key == "return" or key == "kpenter" or key == "space" then
        activar(ele)
    elseif key == "escape" then
        if interf.even == interf.PAUSA then
            interf.irA(interf.JUGANDO)
        elseif interf.even == interf.CONFIG or interf.even == interf.FIN
            or interf.even == interf.ONLINE or interf.even == interf.ESPERA then
            interf.irA(interf.MENU)
        end
    end
end

return interf
