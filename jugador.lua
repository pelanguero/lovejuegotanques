local jugador={strImagen="",angulo=0,tamanho=1,magnitud=100,imagen=nil,posX=0,posY=0,vida=100,powerUp="ninguno",fx=0,fy=0,medx=0,medy=0,proyectiles=require "proyectil"}

function jugador.disparar(tee)
    local ror={}
    
    --proyectil.new("bulletDark1_outline",jugador.angulo,jugador.posX,jugador.posY,10)
    tee.agregar(ror)
end

function jugador.new(rx,ry,tanq)
    jugador.posX=rx
    jugador.posY=ry
    jugador.strImagen=tanq
    jugador.imagen=love.graphics.newImage(tanq)
end

function jugador.morir()

end

function jugador.dibujar(dx,dy,canvv)
    if canvv~=nil then
        love.graphics.setCanvas(canvv)
    end
jugador.fx=jugador.posX-dx
jugador.fy=jugador.posY-dy
love.graphics.draw(jugador.imagen,jugador.fx,jugador.fy,jugador.angulo,1,1,21,23,0,0)
love.graphics.setCanvas()

end

return jugador 