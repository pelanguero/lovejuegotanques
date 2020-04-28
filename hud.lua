hud={anchop,altop,tilles=nil,tiles="terrainTiles_default.png",smapa={},tablam=nil,barrav="",vida=3,imagen,px=1,py=1,barra="barra_v.png",quads={}}
an,al,tx,ty=nil

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
function hud.calculapw()
hud.anchop,hud.altop =  love.window.getMode( )
hud.anchop = hud.anchop/3

an = (((hud.anchop*2)/100)/64) 
al = (((hud.altop)/100)/64)
tx =  64*an
ty = 64*al
end


hud.imagen=love.graphics.newImage(hud.barra)
hud.py=math.floor(45*hud.vida)
hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)
hud.cargarMapa()
hud.calcularQuads()
hud.tilless=love.graphics.newImage(hud.tiles)
hud.calculapw()

function hud.mapa()  
 
end



function hud.dibujar(x,y)  
   love.graphics.draw(hud.imagen,hud.qbarra,1,1)
   if love.keyboard.isDown("m") then
    p=1   
    for  i=1,100 do 
       for j=1, 100 do
         love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],hud.anchop+(j-1)*tx,(i-1)*ty,0,an,al)          
         p=p+1
       end 
     end
end
end
return hud