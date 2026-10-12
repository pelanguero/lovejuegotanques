local nohud = {anchocanvas=0,altocanvas=0,quads={}}
local imagen=love.graphics.newImage("/assets/barra_v.png")

function nohud.calularQuads()
    for i=1,9 do 
        quads[i]=love.graphics.newQuad(0,(i-1)*50,197,50,197,450)
    end
end


function nohud.dibujar(juggador,aancho,aalto)
    
end