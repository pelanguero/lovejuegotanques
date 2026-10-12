local juego=require "juego"
local inter= require "interf"

local ANCHO, ALTO = 1200, 600

function love.load(args)
        love.window.setTitle("Tanks")
        love.window.setMode(ANCHO, ALTO,{resizable=false,vsync=true})
        inter.alIniciar = function(ini)
            juego.nuevaPartida(ini,ANCHO,ALTO)
        end
        inter.alSalir = function() love.event.quit(0) end
        inter.irA(inter.MENU)
        -- love . --pruebas : corre las pruebas automaticas de los modos
        for _, a in ipairs(args or {}) do
            if a == "--pruebas" then require("pruebas.modos").correr() end
        end
end

function love.update(dt)
    -- el juego solo avanza mientras no hay un menu abierto (pausa real)
    if inter.enMenu() or not juego.jugando then return end
    local joysticks = love.joystick.getJoysticks()
    juego.actualizar(dt,joysticks)
    if juego.estado=="fin" then
        juego.jugando=false
        inter.mostrarResultado("Gana el Equipo "..juego.ganador)
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
    if inter.enMenu() or juego.estado~="jugando" then return end
    if juego.mododejuego.joystickpressed then
        juego.mododejuego.joystickpressed( joystick, button )
    end
end

function love.keypressed(key,scancode,isrepeat)
    if key=="x" then
    love.event.quit(0)
    end
    if inter.enMenu() then
        inter.keypressed(key)
    elseif key=="escape" then
        inter.irA(inter.PAUSA)
    elseif juego.estado=="jugando" then
        juego.mododejuego.keypressed( key,scancode,isrepeat)
    end
end

function love.mousemoved(x, y)
    if inter.enMenu() then inter.mousemoved(x,y) end
end

function love.mousereleased(x, y, button)
    if inter.enMenu() then inter.mousehandler(x,y,button) end
end
