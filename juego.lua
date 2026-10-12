
--terreno, jugador
--require("./modosdejuego/TEAMSLAYER")
local juego={mododejuego=nil,jugando=false}

local modulosPartida={}

-- Descarga los modulos cargados por la partida anterior para que
-- una nueva partida empiece con entidades y mapa limpios.
local function descargarPartida()
    for nombre in pairs(modulosPartida) do
        package.loaded[nombre]=nil
    end
    modulosPartida={}
end

function juego.new(mdj,jancho,jalto,njugadores)
    descargarPartida()
    local antes={}
    for nombre in pairs(package.loaded) do antes[nombre]=true end
    if mdj==1 then
        juego.mododejuego=require("./modosdejuego/TEAMSLAYER")
    elseif mdj==2 then
        juego.mododejuego=require("./modosdejuego/CTF")
    elseif mdj==3 then
        juego.mododejuego=require("./modosdejuego/reyDeLaColina")
    elseif mdj==4 then
        juego.mododejuego=require("./modosdejuego/bolaL")
    end
    juego.mododejuego.new(jancho,jalto,njugadores)
    for nombre in pairs(package.loaded) do
        if not antes[nombre] then modulosPartida[nombre]=true end
    end
    juego.jugando=true
end

function juego.actualizar(dt)
    if juego.mododejuego~=nil then
    juego.jugando=juego.proupdate(dt)
    else
        
    end
end

function juego.dibujarCapas()
juego.mododejuego.dibujar()
end
return juego

