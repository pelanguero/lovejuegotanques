
--terreno, jugador
--require("./modosdejuego/TEAMSLAYER")
local juego={mododejuego=nil,jugando=false}

function juego.new(mdj,jancho,jalto)
    -- body
    if mdj==1 then
        juego.mododejuego=require("./modosdejuego/TEAMSLAYER")
    elseif mdj==2 then
        juego.mododejuego=require("./modosdejuego/CTF")
    elseif mdj==3 then
        juego.mododejuego=require("./modosdejuego/reyDeLaColina")
    elseif mdj==2 then
        juego.mododejuego=require("./modosdejuego/CTF")
    elseif mdj==4 then
        juego.mododejuego=require("./modosdejuego/bolaL")
    end
    juego.mododejuego.new(jancho,jalto)
    juego.jugando=true
end

function juego.actualizar(dt)
    if juego.mododejuego~=nil then
    juego.jugando=juego.proupdate(dt)
    else
        
    end
end

function juego:dibujarCapas()
juego.mododejuego.dibujar()
end
return juego

