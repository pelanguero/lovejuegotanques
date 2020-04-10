pantallaActual=1
require "juego"
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end
juego.new()
pantallas[1]=juego.pantalla
xd=0
yd=0
eventoss={}

function love.load()

end

function love.update(dt)
if pantallaActual==1 then
    --eventos de mouse para elegir la opcion en el menu
    if love.keyboard.isDown("w") then
        if yd~=0 then
            yd=yd+16*dt
        end   
    elseif love.keyboard.isDown("s") then
            yd=yd-16*dt
    elseif love.keyboard.isDown("a") then
        if xd~=0 then
            xd=xd-16*dt
        end  
    elseif love.keyboard.isDown("d") then
        xd=xd+16*dt
    end
end
end

function love.draw()
pantallas[pantallaActual].dibujarCapas(xd,yd,eventoss)
end
