local pantalla={capas={}}

function pantalla:cargar()
    
end

function pantalla:agregarCapa(capa)
table.insert(capas,capa)
end



function pantalla:dibujarCapas(x,y,eventos)
for i=1,#pantalla.capas do
    --pantalla.capas[i].actualizar(eventos)
    pantalla.capas[i].dibujar(x,y)
    end
end

return pantalla
