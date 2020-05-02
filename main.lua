pantallaActual=1
juego=require "juego"
pantallas={}
hud=require"hud"
pantallas[1]=0
pantallas[2]=0
juego.new()
pantallas[1]=juego
eventoss={}
ifr=nil

function love.load()
ifr=love.graphics.newImage("terrainTiles_default.png")
love.window.setTitle("Tanks")
xd=0
yd=0
end

function love.update(dt)
    --eventos de mouse para elegir la opcion en el menu
    juego.procesarInput(dt)
    juego.procesarEnt(dt)
    juego.procesarCo()
end

function love.draw()
pantallas[pantallaActual].dibujarCapas()
hud.vida(1)
if love.keyboard.isDown("m") then
    hud.dibujar()     
    end

--love.graphics.draw(ifr,0,0)
end
