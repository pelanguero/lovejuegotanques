--terreno, jugador
--require("./modosdejuego/TEAMSLAYER")
local hud=require "hud"
local juego={mododejuego=nil,jugando=false,
    -- estado de la partida: "jugando", "entreRondas", "terminando" o "fin"
    estado="jugando",config=nil,ronda=1,rondasGanadas={0,0},
    tiempoRestante=nil,ganadorRonda=nil,ganador=nil,espera=0,
    -- en linea: jugador que se ve a pantalla completa (nil = pantalla dividida)
    vistaJugador=nil,
    -- se llama al crear cada ronda (en linea reasigna los controles del jugador 2)
    alNuevaRonda=nil}

local ESPERA_ENTRE_RONDAS=3

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

-- Empieza una partida completa con la configuracion del menu (interf.ini)
function juego.nuevaPartida(ini,jancho,jalto)
    juego.config={}
    for k,v in pairs(ini) do juego.config[k]=v end
    juego.ancho=jancho
    juego.alto=jalto
    juego.ronda=1
    juego.rondasGanadas={0,0}
    juego.ganador=nil
    juego.iniciarRonda()
end

function juego.iniciarRonda()
    local c=juego.config
    juego.new(c.modo,juego.ancho,juego.alto,c.jugadores)
    juego.estado="jugando"
    juego.ganadorRonda=nil
    if juego.alNuevaRonda then juego.alNuevaRonda() end
    if c.modo==3 or c.modo==4 then
        juego.tiempoRestante=c.time
    else
        juego.tiempoRestante=nil
    end
end

-- Team Slayer se juega a una sola ronda
function juego.rondasParaGanar()
    if juego.config.modo==1 then return 1 end
    return juego.config.rondas
end

-- Puntos que cierran la ronda: muertes (TS) o capturas (CTF); nil si es por tiempo
function juego.meta()
    if juego.config.modo==1 then return juego.config.numMuertes end
    if juego.config.modo==2 then return juego.config.capturas end
    return nil
end

local function puntos(equipo)
    local p=juego.mododejuego.entidades.puntuaciones[equipo]
    return p and p.puntos or 0
end

-- Equipo que gano la ronda, 0 si fue empate o nil si la ronda sigue
local function revisarRonda(dt)
    local meta=juego.meta()
    if meta then
        for i=1,2 do
            if puntos(i)>=meta then return i end
        end
        return nil
    end
    juego.tiempoRestante=juego.tiempoRestante-dt
    if juego.tiempoRestante<=0 then
        juego.tiempoRestante=0
        if puntos(1)>puntos(2) then return 1 end
        if puntos(2)>puntos(1) then return 2 end
        return 0
    end
    return nil
end

function juego.actualizar(dt,joysticks)
    if juego.estado=="jugando" then
        juego.mododejuego.proupdate(dt,joysticks)
        local g=revisarRonda(dt)
        if g then
            juego.ganadorRonda=g
            juego.espera=ESPERA_ENTRE_RONDAS
            if g>0 then
                juego.rondasGanadas[g]=juego.rondasGanadas[g]+1
            end
            if g>0 and juego.rondasGanadas[g]>=juego.rondasParaGanar() then
                juego.ganador=g
                juego.estado="terminando"
            else
                juego.estado="entreRondas"
            end
        end
    elseif juego.estado=="entreRondas" or juego.estado=="terminando" then
        juego.espera=juego.espera-dt
        if juego.espera<=0 then
            if juego.estado=="terminando" then
                juego.estado="fin"
            else
                juego.ronda=juego.ronda+1
                juego.iniciarRonda()
            end
        end
    end
end

function juego.dibujarCapas()
    if juego.vistaJugador then
        juego.mododejuego.camara(1,juego.vistaJugador,nil,juego.ancho,juego.alto)
        hud.marcador(juego.mododejuego.entidades.puntuaciones,juego.ancho)
    else
        juego.mododejuego.dibujar()
    end
    hud.estadoPartida(juego)
    if juego.estado=="terminando" then
        hud.aviso("Gana el Equipo "..juego.ganador)
    elseif juego.estado=="entreRondas" then
        if juego.ganadorRonda>0 then
            hud.aviso("Ronda para el Equipo "..juego.ganadorRonda)
        else
            hud.aviso("Ronda empatada")
        end
    end
end
return juego
