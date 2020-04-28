pantallaActual=1
juego=require "juego"
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end
local ssangulo = math.rad(90)
juego.new()
pantallas[1]=juego
eventoss={}
ifr=nil

function love.load()
ifr=love.graphics.newImage("terrainTiles_default.png")
xd=0
yd=0
end
hud=require("hud")

function love.update(dt)
    --eventos de mouse para elegir la opcion en el menu

    if love.keyboard.isDown("w") then
            juego.entidades.entidadess[1].posY=juego.entidades.entidadess[1].posY-juego.entidades.entidadess[1].magnitud*math.sin(juego.entidades.entidadess[1].angulo-ssangulo)*dt
            if juego.entidades.entidadess[1].posY<0 then
                juego.entidades.entidadess[1].posY=0
            end
            juego.entidades.entidadess[1].posX=juego.entidades.entidadess[1].posX-juego.entidades.entidadess[1].magnitud*math.cos(juego.entidades.entidadess[1].angulo-ssangulo)*dt
            if juego.entidades.entidadess[1].posX<0 then
                juego.entidades.entidadess[1].posX=0
            end
    elseif love.keyboard.isDown("s") then
        juego.entidades.entidadess[1].posY=juego.entidades.entidadess[1].posY+juego.entidades.entidadess[1].magnitud*math.sin(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if juego.entidades.entidadess[1].posY<0 then
            juego.entidades.entidadess[1].posY=0
        end
        juego.entidades.entidadess[1].posX=juego.entidades.entidadess[1].posX+juego.entidades.entidadess[1].magnitud*math.cos(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if juego.entidades.entidadess[1].posX<0 then
            juego.entidades.entidadess[1].posX=0
        end
    elseif love.keyboard.isDown("a") then
        juego.entidades.entidadess[1].angulo=juego.entidades.entidadess[1].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown("d") then
        juego.entidades.entidadess[1].angulo=juego.entidades.entidadess[1].angulo+math.rad(100)*dt
    end
    
end

function love.draw()
pantallas[pantallaActual].dibujarCapas()
--love.graphics.draw(ifr,0,0)
end
