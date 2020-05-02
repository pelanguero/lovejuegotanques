local proyectil={strImagen="",angulo=0,tamanho=1,magnitud=800,imagen=nil,posX=0,posY=0,powerUp="ninguno",fx=0,fy=0,danho=10}

function proyectil.new(str,ang,posxx,posyy,danhoo)
    local pro={}
    proyectil.strImagen=str
    proyectil.imagen=love.graphics.newImage(proyectil.strImagen)
    proyectil.posX=posxx
    proyectil.posY=posyy
    proyectil.angulo=ang
    pro=proyectil
    return pro
end

function proyectil.dibujar(dx,dy,canvv)
    if canvv~=nil then
        love.graphics.setCanvas(canvv)
    end
proyectil.fx=proyectil.posX-dx
proyectil.fy=proyectil.posY-dy
love.graphics.draw(proyectil.imagen,proyectil.fx,proyectil.fy,proyectil.angulo,1,1,4,7,0,0)
love.graphics.setCanvas()
end


return proyectil