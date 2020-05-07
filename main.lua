pantallaActual=1
local juego=require "juego"
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end
local ssangulo = math.rad(90)

pantallas[1]=juego
eventoss={}
ifr=nil

function love.load()
    juego.new(1)
end

function love.update(dt)
    --eventos de mouse para elegir la opcion en el menu
    juego.mododejuego.proupdate(dt)
    
    
end

function love.draw()
pantallas[pantallaActual].dibujarCapas()
--love.graphics.draw(ifr,0,0)
end
