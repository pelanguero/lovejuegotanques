
--terreno, jugador
juego={map=require "mapa",pantalla=require "pantalla"}

function juego:new()
    -- body
    juego.map:new("test.txt")
    juego.pantalla.agregarcapa(juego.mapa)
end




