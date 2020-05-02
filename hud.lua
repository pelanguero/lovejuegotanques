hud={modo=2,capm,pmx ,pmy ,anchop,altop,tilles=nil,tiles="terrainTiles_default.png",smapa={},tablam=nil,barrav="",vida=3,imagen,px=1,py=1,barra="barra_v.png",quads={}}
an,al,tx,ty=nil
local bordeD
local bordeR

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
  hud.anchop = hud.anchop/8
  an = (((hud.anchop*6)/100)/64) 
  alc= (((hud.altop)/100)/64)
  al = (((hud.altop)/100)/64)
  tx =  64*an
  ty = 64*al
  x,y=hud.capm:getDimensions( )
  if (hud.pmx*an)-((x*an)/2)< 0 then
    bordeD = 0
  else
    bordeD = (hud.pmx*an)-((x*an)/2)
  end
  if hud.pmy*alc-((y*alc)/2) < 0 then
    bordeR = 0
  else
   bordeR = hud.pmy*alc-((y*alc)/2)  
  end
end


hud.imagen=love.graphics.newImage(hud.barra)
hud.py=math.floor(45*hud.vida)
hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)
hud.cargarMapa()
hud.calcularQuads()
hud.tilless=love.graphics.newImage(hud.tiles)



function hud.mapa()
  if hud.modo==1 then  
    hud.capm=love.graphics.newCanvas(800,600)
    hud.anchop,hud.altop = hud.capm:getDimensions( )
    hud.calculapw()      
    hud.capm:renderTo(function ()  
      x,y=hud.capm:getDimensions( )
      p=1   
      for  i=1,100 do 
        for j=1, 100 do
          love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],hud.anchop+(j-1)*tx,(i-1)*ty,0,an,al)               
          p=p+1
          love.graphics.rectangle( "line",hud.anchop+bordeD,bordeR, x*an, y*alc )
        end 
      end
    end);
  elseif hud.modo==2 then
    hud.capm=love.graphics.newCanvas(600,600)
    hud.anchop,hud.altop = hud.capm:getDimensions( )
    hud.calculapw()    
    hud.capm:renderTo(function ()  
      x,y= hud.capm:getDimensions( )
      p=1   
      for  i=1,100 do 
        for j=1, 100 do
          love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],hud.anchop+(j-1)*tx,(i-1)*ty,0,an,al)               
          p=p+1
          love.graphics.rectangle( "line",hud.anchop+bordeD,bordeR, x*an, y*alc )
        end 
      end
    end);
  end
  
end

function hud.vida(nivel)
  love.graphics.draw(hud.imagen,hud.qbarra,1,1)
end

  function hud.dibujar()     
   
   hud.mapa()
    love.graphics.draw(hud.capm)         
      
    
end
return hud