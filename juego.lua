
--terreno, jugador
local juego={mododejuego=require("./modosdejuego/TEAMSLAYER")}

function juego:new(mdj)
    -- body
    if mdj==1 then
    juego.mododejuego=require("./modosdejuego/TEAMSLAYER")
    end
    juego.mododejuego.new()
end



function juego:dibujarCapas()
juego.mododejuego.dibujar()
end
return juego

