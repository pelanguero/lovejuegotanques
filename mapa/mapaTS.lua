local mapats={tablamapa=nil,quads={},puntos={},tilless=nil}

function mapats.calcularQuads()
    local a=0
    for i=1,4 do 
      for j=1,10 do 
        a=a+1
        --se puede remplazar el 64 por tablamapa.width
        mapats.quads[a]=love.graphics.newQuad((j-1)*64,(i-1)*64 , 64, 64, 640, 256)
      end
    
    end
end

function mapats.calcularPuntos()
    local anc=mapats.tablamapa.width*mapats.tablamapa.height
    for i=1,anc do
      if mapats.tablamapa.layers[2].data[i]~=0 then
        mapats.agregarPunto(i,mapats.tablamapa.layers[2].data[i])
      end
    end
end

function mapats.agregarPunto(xy,valor)
  local cally=0
  local callx=0
    if math.floor(xy/mapats.tablamapa.width)==xy/mapats.tablamapa.width then
      cally=xy/mapats.tablamapa.width
      callx=mapats.tablamapa.width
    else
      cally=math.floor(xy/mapats.tablamapa.width)+1
      callx=xy-mapats.tablamapa.width*(cally-1)
    end 
    local add={}
    add.x=callx*64-32
    add.y=cally*64-32
    add.val=valor
    table.insert(mapats.puntos,add)

end

--xd,yd es la esquina superior izquierda de la seccion de mapa a renderizar
function mapats.dibujar(xd,yd,anch,alt,canv)
    if canv~=nil then
        love.graphics.setCanvas(canv)
    end
    local sancho=math.floor(anch/64)+2
    local salto=math.floor(alt/64)+2
    local qpx=math.floor(xd/64)+1
    local qpy=math.floor(yd/64)+1
    local ofx=64*math.floor(xd/64)-xd
    local ofy=64*math.floor(yd/64)-yd
    local subi=(qpy-1)*mapats.tablamapa.width+qpx
    --
    for i=1,salto do 
      for j=1,sancho do
        if mapats.quads[mapats.tablamapa.layers[1].data[subi]]~=nil then
          love.graphics.draw(mapats.tilless,mapats.quads[mapats.tablamapa.layers[1].data[subi]],ofx+(j-1)*64,ofy+(i-1)*64)
        else
          love.graphics.draw(mapats.tilless,mapats.quads[mapats.tablamapa.layers[1].data[1]],ofx+(j-1)*64,ofy+(i-1)*64)
        end
        subi=subi+1
      end
      subi=subi+mapats.tablamapa.width-sancho
    end
    love.graphics.setCanvas()
end

function mapats.new(ruta,rutaI)
    mapats.tilless=love.graphics.newImage(rutaI)
    mapats.tablamapa= require (ruta)
    mapats.calcularQuads()
    mapats.calcularPuntos()
end

return mapats