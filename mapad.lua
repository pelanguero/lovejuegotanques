local mapad={tiles="terrainTiles_default.png",quads={},tablamapa=nil,canvas1=nil,canvas2=nil,anchoo=0}

function mapad.cargarMapa(ruta)
mapad.tablamapa=require (ruta)
end

function mapad.calcularQuads()
    a=0
    for i=1,4 do 
      for j=1,10 do 
        a=a+1
        mapad.quads[a]=love.graphics.newQuad((j-1)*64,(i-1)*64 , 64, 64, 640, 256)
      end
    end
end

function mapad:new(prro)
    mapad.cargarMapa("mapadeprueba")
    mapad.calcularQuads()
    mapad.tilless=love.graphics.newImage(mapad.tiles)
    anchoo=mapad.tablamapa.width*64
end

function mapad.dibujar(xd,yd,zcanvas)
    local qpx=math.floor(xd/64)+1
    local qpy=math.floor(yd/64)+1
    local ofx=64*math.floor(xd/64)-xd
    local ofy=64*math.floor(yd/64)-yd
    local subi=(qpy-1)*mapad.tablamapa.width+qpx
    --
    love.graphics.setCanvas(zcanvas)
    for i=1,11 do 
      for j=1,11 do
        love.graphics.draw(mapad.tilless,mapad.quads[mapad.tablamapa.layers[1].data[subi]],ofx+(j-1)*64,ofy+(i-1)*64)
        subi=subi+1
      end
      subi=subi+mapad.tablamapa.width-11
    end
    love.graphics.setCanvas()
  end

return mapad
