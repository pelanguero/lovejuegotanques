mapa={tablamapa=nil,tilex=0,tiley=0,tiles="terrainTiles_default.png",smapa={},quads={},quads_mm={},tilles=nil}

function mapa.cargarMapa(ruta)
mapa.tablamapa=require("mapadeprueba")
end
function mapa.calcularQuads()
      a=0
      for i=1,4 do 
        for j=1,10 do 
          a=a+1
          mapa.quads[a]=love.graphics.newQuad((j-1)*64,(i-1)*64 , 64, 64, 640, 256)          
        end
      end


end
function mapa.cargarlocal()
  for u=1,100 do 
  mapa.smapa[u]={}
    for v=1,100 do
      mapa.smapa[u][v]=0
    end
  end
  for i=1,10000 do
  iy=math.floor(i/100)+1
  ix=i-math.floor(i/100)*100+1
  if ix==0 then 
   ix=100
  end
erer=mapa.tablamapa.layers[1].data[i] 
  mapa.smapa[ix][iy]=mapa.tablamapa.layers[1].data[i]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
  end
  end
  
function mapa:new(prro)
  mapa.cargarMapa(prro)
  mapa.calcularQuads()
  mapa.cargarlocal()
  mapa.tilless=love.graphics.newImage(mapa.tiles)
end
function mapa.dibujar(xd,yd,vi)
  qpx=math.floor(xd/64)+1
  qpy=math.floor(yd/64)+1
  ofx=64*math.floor(xd/64)-xd
  ofy=64*math.floor(yd/64)-yd
  subi=(qpy-1)*100+qpx  
 
  --------------------------     
  
  qy=math.floor(vi*45)+1
   
  quad_v = love.graphics.newQuad( 1, qy, 197, 45, 197, 450)
  barra = love.graphics.newImage("barra_v.png")  
  -----------------------------------
  for i=1,11 do 
    for j=1,14 do
      love.graphics.draw(mapa.tilless,mapa.quads[mapa.tablamapa.layers[1].data[subi]],ofx+(j-1)*64,ofy+(i-1)*64)        
      subi=subi+1
      
    end
    subi=subi+86    
  end
  

  love.graphics.draw( barra,quad_v,1,1 )
end

return mapa

