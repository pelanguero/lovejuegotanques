
--terreno, jugador
local juego={mododejuego=nil}

function juego.new(mdj)
    -- body
    if mdj==1 then
    juego.mododejuego=require("./modosdejuego/TEAMSLAYER")
    elseif mdj==2 then
    juego.mododejuego=require("./modosdejuego/reyDeLaColina")
    end
    juego.mododejuego.new()
end



function juego:dibujarCapas()
juego.mododejuego.dibujar()
end
return juego

