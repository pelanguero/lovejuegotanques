pantallaActual=1
juego=require "juego"

------------------
velocidad = 130
vida = 0 --- 10 opciones desde el 0
-------------
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end
juego.new()
pantallas[1]=juego
xd=0
yd=10
eventoss={}
ifr=nil

function love.load()
ifr=love.graphics.newImage("terrainTiles_default.png")
xd=0
yd=0
end

function love.update(dt)
    --eventos de mouse para elegir la opcion en el menu
    if love.keyboard.isDown("w") then
        if juego.ey~=0 then
            juego.ey=juego.ey-velocidad*dt
        end   
    elseif love.keyboard.isDown("s") then
            juego.ey=juego.ey+velocidad*dt
    elseif love.keyboard.isDown("a") then
        if juego.ex~=0 then
            juego.ex=juego.ex-velocidad*dt
        end  
    elseif love.keyboard.isDown("d") then
        juego.ex=juego.ex+velocidad*dt
    end
    juego.vi=vida
end

function love.draw()
pantallas[pantallaActual].dibujarCapas()
end
