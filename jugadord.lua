local jugadord={proyectiles=require "proyectil", strImagen="",angulo=0,tamanho=1,magnitud=100,imagen=nil,posX=0,posY=0,vida=100,powerUp="ninguno",fx=0,fy=0,medx=0,medy=0}


function jugadord.new(rx,ry,tanq)
    jugadord.posX=rx
    jugadord.posY=ry
    jugadord.strImagen=tanq
    jugadord.imagen=love.graphics.newImage(tanq)
end
function jugadord.calxy()
local ewx=jugadord.posX-jugadord.medx
local ewy=jugadord.posY-jugadord.medy
if ewx<0 then
    jugadord.fx=jugadord.medx+ewx 
else
    jugadord.fx=jugadord.medx
end
if ewy<0 then
    jugadord.fy=jugadord.medy+ewy
else
    jugadord.fy=jugadord.medy
end
end

function jugadord.disparar(tee)
    local ror={}
    ror.angulo=jugadord.angulo
    ror.imagen=love.graphics.newImage("bulletDark1_outline.png")
    ror.posX=jugadord.posX
    ror.posY=jugadord.posY
    ror.dibujar=jugadord.proyectiles.dibujar
    
    --jugadord.proyectiles.new("bulletDark1_outline.png",jugadord.angulo,jugadord.posX,jugadord.posY,10)
    tee.agregar(ror)
end

function jugadord.morir()

end

function jugadord.dibujar(dx,dy,canvv)
    if canvv~=nil then
        love.graphics.setCanvas(canvv)
    end
jugadord.fx=jugadord.posX-dx
jugadord.fy=jugadord.posY-dy
love.graphics.draw(jugadord.imagen,jugadord.fx,jugadord.fy,jugadord.angulo,1,1,21,23,0,0)
love.graphics.setCanvas()

end

return jugadord