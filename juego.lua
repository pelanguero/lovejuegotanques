
--terreno, jugador
juego={map=require "mapa",capas={},ex=0,ey=0}

function juego:agregarcapa(per)
table.insert(juego.capas,per)
end

function juego:new()
    -- body
    juego.map.new("mapadeprueba..lua")
    juego:agregarcapa(juego.map)
end

function juego:dibujarCapas()
for i=1,table.maxn(juego.capas) do 
    if juego.ex<0 then 
    juego.ex=0
    end
    if juego.ey<0 then
    juego.ey=0
    end
    juego.capas[i].dibujar(juego.ex,juego.ey)
end
end
return juego

