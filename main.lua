local juego=require "juego"
local inter= require "interf"
local online=require "online"
local red=require "red"
-- despues de online: su envoltura de love.keyboard.isDown debe ir por fuera
local demo=require "demo"

local ANCHO, ALTO = 1200, 600

------------------------------------------------------------------ ventanas separadas
-- LOVE solo maneja una ventana por proceso: la segunda ventana es otra
-- instancia del juego, abierta con "--ventana2 <puerto>", que se conecta
-- a esta por 127.0.0.1 igual que un cliente en linea.

-- Ancho de cada ventana para que las dos quepan lado a lado, y su posicion
local function geometriaVentana(numero)
    local dw, dh = love.window.getDesktopDimensions()
    local w = math.min(ANCHO, math.floor(dw / 2))
    local x = math.floor((dw - 2 * w) / 2) + (numero - 1) * w
    local y = math.max(0, math.floor((dh - ALTO) / 2))
    return w, x, y
end

local function colocarVentana(numero)
    local w, x, y = geometriaVentana(numero)
    if love.graphics.getWidth() ~= w then
        love.window.updateMode(w, ALTO)
    end
    love.window.setPosition(x, y)
    love.window.setTitle("Tanks - Jugador " .. numero)
end

local function restaurarVentana()
    if love.graphics.getWidth() ~= ANCHO then
        love.window.updateMode(ANCHO, ALTO)
    end
    love.window.setTitle("Tanks")
end

local function comillas(s)
    if love.system.getOS() == "Windows" then return '"' .. s .. '"' end
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Abre otra instancia del juego como ventana del jugador 2
local function abrirSegundaVentana()
    local comando
    if love.filesystem.isFused() then
        comando = comillas(love.filesystem.getSource())
    else
        comando = comillas(arg[-2] or "love") .. " " .. comillas(love.filesystem.getSource())
    end
    comando = comando .. " --ventana2 " .. red.PUERTO_LOCAL
    if love.system.getOS() == "Windows" then
        os.execute('start "" ' .. comando)
    else
        os.execute(comando .. " &")
    end
end

local function iniciarVentanas(ini)
    local ok, err = online.crearLocal()
    if not ok then error("no se pudo abrir el puerto local " .. red.PUERTO_LOCAL .. " (" .. tostring(err) .. ")") end
    colocarVentana(1)
    abrirSegundaVentana()
    inter.esperar("Abriendo ventana", "Esperando la ventana del jugador 2")
    return "esperando"
end

-- En linea el anfitrion es el jugador 1 y el cliente el jugador 2
local function textoResultado()
    if not online.activo() or online.esLocal() then
        return "Gana el Equipo "..juego.ganador
    end
    local mio = online.esAnfitrion() and 1 or 2
    return juego.ganador==mio and "Ganaste" or "Gano el rival"
end

function love.load(args)
        love.window.setTitle("Tanks")
        love.window.setMode(ANCHO, ALTO,{resizable=false,vsync=true})
        love.keyboard.setKeyRepeat(true)
        inter.alIniciar = function(ini)
            if online.esAnfitrion() then
                online.iniciarPartida(ini,love.graphics.getDimensions())
            elseif ini.pantalla==2 then
                return iniciarVentanas(ini)
            else
                juego.vistaJugador=nil
                juego.nuevaPartida(ini,ANCHO,ALTO)
            end
        end
        inter.alSalir = function() love.event.quit(0) end
        inter.infoRed = "Tu IP: "..red.ipLocal().."  -  puerto "..red.PUERTO.." (UDP)"
        inter.alCrearOnline = function() return online.crear() end
        inter.alUnirseOnline = function(ip) return online.unirse(ip) end
        inter.alVolverAlMenu = function()
            online.salir()
            juego.jugando=false
            -- la segunda ventana solo existe mientras dura la partida
            if inter.esVentana2 then love.event.quit(0) return end
            restaurarVentana()
        end

        online.alConectar = function()
            if online.esLocal() then
                if online.esAnfitrion() then
                    inter.enLinea = "anfitrion"
                    online.iniciarPartida(inter.ini,love.graphics.getDimensions())
                    inter.irA(inter.JUGANDO)
                else
                    inter.enLinea = "cliente"
                    inter.esperar("Jugador 2", "Esperando que empiece la partida")
                end
            elseif online.esAnfitrion() then
                inter.enLinea = "anfitrion"
                inter.irA(inter.CONFIG)
            else
                inter.enLinea = "cliente"
                inter.esperar("Conectado", "Esperando a que el anfitrion inicie la partida")
            end
        end
        online.alDesconectar = function(eraLocal)
            juego.jugando=false
            if eraLocal and inter.esVentana2 then
                -- la ventana del jugador 1 se cerro o volvio al menu
                love.event.quit(0)
                return
            end
            inter.enLinea=nil
            if inter.even==inter.ESPERA and inter.tituloEspera=="Conectando" then
                inter.irA(inter.ONLINE)
                inter.mensajeError="No se pudo conectar con el anfitrion"
            elseif inter.even~=inter.MENU and inter.even~=inter.ONLINE then
                inter.mostrarResultado("Conexion perdida",
                    eraLocal and "Se cerro la ventana del jugador 2" or "El otro jugador se desconecto",false)
            end
        end
        online.alIniciarCliente = function(config)
            juego.vistaJugador=2
            local ok, err = pcall(juego.nuevaPartida,config,love.graphics.getDimensions())
            if ok then
                inter.irA(inter.JUGANDO)
            else
                print("No se pudo iniciar la partida en linea: "..tostring(err))
                inter.irA(inter.MENU)
            end
        end

        inter.irA(inter.MENU)
        args = args or {}
        for i, a in ipairs(args) do
            -- love . --pruebas : corre las pruebas automaticas de los modos
            if a == "--pruebas" then require("pruebas.modos").correr() end
            -- segunda ventana de la pantalla dividida (la abre el juego)
            if a == "--ventana2" then
                inter.esVentana2 = true
                colocarVentana(2)
                local ok = online.unirseLocal(tonumber(args[i+1]))
                if not ok then love.event.quit(1) return end
                inter.esperar("Conectando", "Conectando con la ventana del jugador 1...")
            end
        end
end

function love.update(dt)
    online.bloquearTeclas(inter.enMenu())
    online.actualizar(dt, inter.enMenu())
    -- fuera de partida, los menus tienen de fondo una demo del juego
    if inter.enMenu() and not juego.jugando then
        demo.actualizar(dt)
    else
        demo.detener()
    end
    if not juego.jugando then return end
    -- un menu pausa la partida local; en linea la partida sigue corriendo
    if inter.enMenu() and not (online.activo() and inter.even==inter.PAUSA) then return end
    if not online.esCliente() then
        local joysticks = love.joystick.getJoysticks()
        juego.actualizar(dt,joysticks)
    end
    if online.esAnfitrion() then
        online.enviarEstado()
    end
    if juego.estado=="fin" then
        juego.jugando=false
        if online.esAnfitrion() then
            online.enviarFin()
            inter.mostrarResultado(textoResultado(), nil, online.conectado())
        elseif online.esCliente() then
            inter.mostrarResultado(textoResultado(), "Esperando revancha del anfitrion", false)
        else
            inter.mostrarResultado(textoResultado())
        end
    end
end

function love.draw()
    if inter.enMenu() then
        if juego.jugando then
            -- pausa: el menu va sobre la partida detenida
            juego.dibujarCapas()
            inter.dibijarElementos(true)
        elseif demo.activa() then
            demo.dibujar()
            inter.dibijarElementos(true)
        else
            inter.dibijarElementos()
        end
    else
        juego.dibujarCapas()
    end
end

function love.joystickpressed( joystick, button )
    if inter.enMenu() or online.esCliente() or juego.estado~="jugando" then return end
    if juego.mododejuego.joystickpressed then
        juego.mododejuego.joystickpressed( joystick, button )
    end
end

function love.keypressed(key,scancode,isrepeat)
    if key=="x" and not inter.escribiendo() then
    love.event.quit(0)
    end
    if inter.enMenu() then
        inter.keypressed(key)
    elseif isrepeat then
        -- la repeticion de teclas solo sirve en los menus (borrar texto)
        return
    elseif key=="escape" then
        inter.irA(inter.PAUSA)
    elseif online.esCliente() then
        online.teclaPresionada(key)
    elseif juego.estado=="jugando" then
        juego.mododejuego.keypressed( key,scancode,isrepeat)
    end
end

function love.textinput(t)
    if inter.enMenu() then inter.textinput(t) end
end

function love.mousemoved(x, y)
    if inter.enMenu() then inter.mousemoved(x,y) end
end

function love.mousereleased(x, y, button)
    if inter.enMenu() then inter.mousehandler(x,y,button) end
end

function love.quit()
    red.cerrar()
end
