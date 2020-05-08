local entidades={entidadess={}}

function entidades.agregar(ent)
table.insert(entidades.entidadess,ent)
end
function entidades.dibujar(eex,eey)
  for i=1,#entidades.entidadess do
      entidades.entidadess[i].dibujar()
  end

end

return entidades

