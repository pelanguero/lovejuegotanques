jugador={strImagen="",angulo=0,tamanho=1,magnitud=100,imagen=nil,posX=800,posY=800,vida=100,powerUp="ninguno",fx=0,fy=0}

function jugador.new(rx,ry,tanq)
    jugador.posX=rx
    jugador.posY=ry
    jugador.strImagen=tanq
    jugador.imagen=love.graphics.newImage(tanq)
end
function jugador.calxy()
local ewx=jugador.posX-400
local ewy=jugador.posY-300
if ewx<0 then
    jugador.fx=400+ewx 
else
    jugador.fx=400
end
if ewy<0 then
    jugador.fy=300+ewy
else
    jugador.fy=300
end
end

function jugador.morir()

end

function jugador.dibujar()
jugador.calxy()
love.graphics.draw(jugador.imagen,jugador.fx,jugador.fy,jugador.angulo,1,1,21,23,0,0)
end

return jugador 