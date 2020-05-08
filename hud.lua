hud={modo=1,capm,caprec,anchop=800,altop=600,tilles=nil,tiles=nil,smapa={},tablam=nil,barrav="",vida=100,imagen,imagen2,px=1,py=1,barra="/assets/barra_v.png",quads={}}

    
function hud.cargarMapa()
  hud.anchop = hud.anchop/8
    an = (((hud.anchop*6)/100)/64) 
    alc= (((hud.altop)/100)/64)
    al = (((hud.altop)/100)/64)
    tx =  64*an
    ty = 64*al
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

function hud.cargarQuad(mp)
    hud.cargarMapa()
    hud.calcularQuads()
    if hud.modo==2 then  
        hud.anchop = 600 
    end
        hud.capm=love.graphics.newCanvas(anchop,altop)                            
          x,y=hud.capm:getDimensions()
          p=1   
          love.graphics.setCanvas(mp)
          for  i=1,hud.tablam.width do 
            for j=1, hud.tablam.height do
              love.graphics.draw(hud.tilless,hud.quads[hud.tablam.layers[1].data[p]],(j-1)*tx,(i-1)*ty,0,an,al)               
              p=p+1             
            end 
          end                           
          love.graphics.setCanvas()
  end 
function hud.calculapw(pmx,pmy)        
    if (hud.pmx*an)-((anchop*an)/2)< 0 then
      bordeD = 0
    else
      bordeD = (hud.pmx*an)-((anchop*an)/2)
    end
    if hud.pmy*alc-((altop*alc)/2) < 0 then
      bordeR = 0
    else
     bordeR = hud.pmy*alc-((altop*alc)/2)  
    end
  end

function hud.rect(pmx,pmy) 
    hud.caprec=love.graphics.newCanvas(anchop,altop)    
    hud.calculapw(pmx,pmy)      
    hud.caprec:renderTo(function ()
        love.graphics.rectangle( "line",bordeD,bordeR, x*an, y*alc )
                    end);
  end
function hud.vida(vi)--numero del araque 
    hud.imagen=love.graphics.newImage(hud.barra)        
    hud.py=(45*(vi))
    hud.qbarra=love.graphics.newQuad(hud.px,hud.py,197,45,197,450)
    if modo == 1 then
        love.graphics.draw(hud.imagen,hud.qbarra,1,1)
    elseif modo == 2 then
        love.graphics.draw(hud.imagen,hud.qbarra,1,1)
        love.graphics.draw(hud.imagen2,hud.qbarra,600,1)
    end       
  end 
function hud.new(jug,mp)
    hud.vida(jug.vida)
    hud.tiles = mp
    hud.tilless=love.graphics.newImage(hud.tiles)    
 end
function hud.dibujar(modo,jug,can)
    hud.cargarQuad(can)          
 end
return hud