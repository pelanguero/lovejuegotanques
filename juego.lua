
--terreno, jugador
local juego={mododejuego=require("./modosdejuego/TEAMSLAYER")}
hud =require"hud"
function juego:new(mdj)
    -- body
    if mdj==1 then
    juego.mododejuego=require("./modosdejuego/TEAMSLAYER")
    end
    juego.mododejuego.new()
    hud.new(juego.mododejuego.entidades.jugadores[1],"/assets/barra_v.png")
end



function juego:dibujarCapas()
juego.mododejuego.dibujar()
end
return juego

