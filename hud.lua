hud={modo=1,capm,caprec,anchop=800,altop=600,tilles=nil,tiles=nil,smapa={},tablam=nil,barrav="",vida=3,imagen,px=1,py=1,barra="./assets/barra_v.png",quads={}}

    hud.anchop = hud.anchop/8
    an = (((hud.anchop*6)/100)/64) 
    alc= (((hud.altop)/100)/64)
    al = (((hud.altop)/100)/64)
    tx =  64*an
    ty = 64*al
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

 function hud.calculapw(pmx,pmy)    
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

 function hud.cargarQuad()
    hud.cargarMapa()
    if hud.modo==2 then  
        hud.anchop = 600 
    end
        hud.capm=love.graphics.newCanvas(anchop,altop)                   
        hud.capm:renderTo(function ()  
          x,y=hud.capm:getDimensions()
          p=1   
          for  i=1,hud.tablam.width do 
            for j=1, hud.tablam.height do
              love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],hud.anchop+(j-1)*tx,(i-1)*ty,0,an,al)               
              p=p+1             
            end 
          end
        end);                   
 end 

 function hud.rect(pmx,pmy) 
    hud.caprec=love.graphics.newCanvas(anchop,altop)    
    hud.calculapw(pmx,pmy)      
    hud.capm:renderTo(function ()
        love.graphics.rectangle( "line",bordeD,bordeR, x*an, y*alc )
                    end);
 end

 function hud.new(pmx,pmy,til)
    hud.tiles = til
    hud.rect(pmx,pmy)    
    hud.rect(pmx,pmy)
 end
 function hud.dibujar()
    love.graphics.draw(hud.capm)
    love.graphics.draw(hud.caprec)    
 end