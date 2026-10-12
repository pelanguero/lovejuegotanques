pantallaActual=1
local juego=require "juego"
local inter= require "interf"
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end
local ssangulo = math.rad(90)

pantallas[1]=juego
eventoss={}
ifr=nil

function love.load()    
        love.window.setTitle("Tanks")
        love.window.setMode(1200, 600,{resizable=false,vsync=true})
        juego.new(inter.ini.modo,1200,600)     
end

function love.update(dt)   
        --eventos de mouse para elegir la opcion en el menu
    local joysticks = love.joystick.getJoysticks()
    juego.mododejuego.proupdate(dt,joysticks)
    
end

function love.draw()

    
    if inter.even == 4 then 
        pantallas[pantallaActual].dibujarCapas()
        --love.graphics.draw(ifr,0,0)
    else
        inter.dibijarElementos()
    end
end

function love.joystickpressed( joystick, button ) 
    juego.mododejuego.joystickpressed( joystick, button ) 
end

function love.keypressed(key,scancode,isrepeat)
    if key=="x" then
    love.event.quit(0)
    end
    juego.mododejuego.keypressed( key,scancode,isrepeat)
end
function love.mousereleased(x, y, button)
    inter.mousehandler(x,y,button)      
end 
