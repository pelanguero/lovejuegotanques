hud={vida=10,imagen_v,px=1,py=1,barra="barra_v.png"}


hud.imagen_v=love.graphics.newImage(hud.barra)
hud.py=math.floor(40.5*hud.vida)

hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)

function hud.dibujar()
   love.graphics.draw(hud.imagen_v,hud.qbarra,1,1) 
end