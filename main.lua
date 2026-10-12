local juego=require "juego"
local inter= require "interf"
local online=require "online"
local red=require "red"

local ANCHO, ALTO = 1200, 600

-- En linea el anfitrion es el jugador 1 y el cliente el jugador 2
local function textoResultado()
    if not online.activo() then
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
                online.iniciarPartida(ini,ANCHO,ALTO)
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
        end

        online.alConectar = function()
            if online.esAnfitrion() then
                inter.enLinea = "anfitrion"
                inter.irA(inter.CONFIG)
            else
                inter.enLinea = "cliente"
                inter.esperar("Conectado", "Esperando a que el anfitrion inicie la partida")
            end
        end
        online.alDesconectar = function()
            juego.jugando=false
            inter.enLinea=nil
            if inter.even==inter.ESPERA and inter.tituloEspera=="Conectando" then
                inter.irA(inter.ONLINE)
                inter.mensajeError="No se pudo conectar con el anfitrion"
            elseif inter.even~=inter.MENU and inter.even~=inter.ONLINE then
                inter.mostrarResultado("Conexion perdida","El otro jugador se desconecto",false)
            end
        end
        online.alIniciarCliente = function(config)
            juego.vistaJugador=2
            local ok, err = pcall(juego.nuevaPartida,config,ANCHO,ALTO)
            if ok then
                inter.irA(inter.JUGANDO)
            else
                print("No se pudo iniciar la partida en linea: "..tostring(err))
                inter.irA(inter.MENU)
            end
        end

        inter.irA(inter.MENU)
        -- love . --pruebas : corre las pruebas automaticas de los modos
        for _, a in ipairs(args or {}) do
            if a == "--pruebas" then require("pruebas.modos").correr() end
        end
end

function love.update(dt)
    online.bloquearTeclas(inter.enMenu())
    online.actualizar(dt, inter.enMenu())
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
        inter.dibijarElementos()
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
