hud={tilles=nil,tiles="terrainTiles_default.png",smapa={},tablam=nil,barrav="",vida=3,imagen,px=1,py=1,barra="barra_v.png",quads={}}

function hud.cargarMapa()
   hud.tablam=require("mapadeprueba")
 end
 function hud.calcularQuads()
   a=0
   for i=1,4 do
     for j=1,10 do 
       a=a+1
       hud.quads[a]=love.graphics.newQuad((j-1)*64,(i-1)*64 , 64, 64, 640, 256)
     end
   end
 
 end


hud.imagen=love.graphics.newImage(hud.barra)
hud.py=math.floor(45*hud.vida)
hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)
hud.cargarMapa()
hud.calcularQuads()
hud.tilless=love.graphics.newImage(hud.tiles)


function hud.dibujar(x,y)  
   love.graphics.draw(hud.imagen,hud.qbarra,1,1)
   p=1   
   for  i=1,100 do 
      for j=1, 100 do
        love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],(j-1)*1.28,(i-1)*1.28,0,0.02,0.02)    
        p=p+1
      end 
    end 
end
return hud