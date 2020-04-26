hud={barrav="",vida=3,imagen,px=1,py=1,barra="barra_v.png",mapa=require "mapa",
tablamapa=nil,tiles="terrainTiles_default.png",quads={}}

function hud.cargarMapa()
   hud.tablamapa = require("mapadeprueba")
end
a=0
  for i=1,4 do 
    for j=1,10 do 
      a=a+1
      hud.quads[a]=love.graphics.newQuad((j-1)*64,(i-1)*64 , 64, 64, 640, 256)
    end
  end
hud.imagen=love.graphics.newImage(hud.barra)
hud.py=math.floor(45*hud.vida)
hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)

function hud.dibujar()
   for i=1,11 do 
      for j=1,14 do
        love.graphics.draw(hud.tiles,mapa.quads[mapa.tablamapa.layers[1].data[subi$],ofx+(j-1)*64,ofy+(i-1)*64)
        subi=subi+1
      end
      subi=subi+mapa.tablamapa.width-14
    end
  end]]
   love.graphics.draw(hud.imagen,hud.qbarra,1,1) 
end
return hud