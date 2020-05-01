local entidades={entidadess={},ancho=800,alto=600}

function entidades.agregar(ent)
table.insert(entidades.entidadess,ent)
end
function entidades.dibujar(eex,eey,canv)
  --eex,eey esquina superior izquierda de la camara
  for i=1,#entidades.entidadess do
    if entidades.estaDentro(eex,eey,entidades.entidadess[i]) then
      entidades.entidadess[i].dibujar(eex,eey,canv)
    end
        
  end
  
end
function entidades.estaDentro(ax,ay,entidadd)
  local retorno=false
  if entidadd.posX-ax<entidades.ancho and entidadd.posY-ay<entidades.alto then
  retorno=true
  end
  return retorno
end

return entidades

