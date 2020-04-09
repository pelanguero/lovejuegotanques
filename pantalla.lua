local pantalla={}

pantalla.capas={}



function pantalla.dibujarCapas()
for i=1,#pantalla.capas do
    pantalla.capas[i].dibujar()
end
end

return pantalla
