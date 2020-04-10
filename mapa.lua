mapa={tablamapa=nil,tilex=0,tiley=0,tiles="terrainTiles_default",smapa={},quads={}}

function mapa.cargarMapa(ruta)
mapa.tablamapa=require(ruta)
end
function mapa.calcularQuads()

for i=1,10 do 
  for j=1,4 do 
    local proq=love.graphics.newQuad((i-1)*64,(j-1)*64 , 64, 64, sw (number), sh (number))
    table.insert(mapa.quads,proq)
  end

end

end
function mapa.cargarlocal()
for i=1,10000 do
iy=math.floor(i/100)+1
ix=i+100-math.floor(i/100)*100
end
end

function mapa.dibujar(x,y)

end

return mapa

