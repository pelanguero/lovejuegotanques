hud={modo=1,capm,pmx ,pmy,pmx2,pmy2 ,anchop=800,altop=600,tilles=nil,tiles="terrainTiles_default.png",smapa={},tablam=nil,barrav="",vida=3,imagen,px=1,py=1,barra="barra_v.png",quads={}}

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
 function hud.cargarQuad()
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
            end 
          end
        end);
    end
    love.graphics.rectangle( "line",hud.anchop+bordeD,bordeR, x*an, y*alc )
 end 