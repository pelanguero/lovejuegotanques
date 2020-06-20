
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0
local inputUno={}
local inputDos={}

function bolaL.new(ancc,altt)
    bolaL.mapa.new("../mapas/bola","//assets/terrainTiles_default.png")
    bolaL.ancho=ancc
    bolaL.alto=altt
    bolaL.mdx=math.floor(ancc/2)
    bolaL.mdy=math.floor(altt/2)
    inputUno.adelante="w"
    inputUno.atras="s"
    inputUno.derecha="d"
    inputUno.izquierda="a"
    inputUno.disparar="q"
    inputUno.mina="e"
    inputUno.joystick=false
    inputDos.adelante="i"
    inputDos.atras="k"
    inputDos.derecha="l"
    inputDos.izquierda="j"
    inputDos.joystick=false
    inputDos.disparar="u"
    inputDos.mina="o"
    ancho=bolaL.mapa.tablamapa.width*64
    alto=bolaL.mapa.tablamapa.height*64
    bolaL.temud.new(bolaL.mapa,ancc,altt)
    for i=1,#bolaL.mapa.puntos do 
       if bolaL.mapa.puntos[i].val==1 then
         bolaL.entidades.agregarSpawn(bolaL.mapa.puntos[i].x,bolaL.mapa.puntos[i].y)
       elseif bolaL.mapa.puntos[i].val==2 then
        bolaL.entidades.agregarPowerUp(bolaL.mapa.puntos[i].x,bolaL.mapa.puntos[i].y)
       elseif bolaL.mapa.puntos[i].val==3 then
        bolaL.entidades.agregarBandera(bolaL.mapa.puntos[i].x,bolaL.mapa.puntos[i].y)
       end
    end
    bolaL.entidades.agregarJugador(1,bolaL.entidades.spawns[1].x,bolaL.entidades.spawns[1].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputUno)
    bolaL.entidades.agregarJugador(2,bolaL.entidades.spawns[2].x,bolaL.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputDos)
    bolaL.entidades.ancho=bolaL.ancho+50
    bolaL.entidades.alto=bolaL.alto+50
end

function bolaL.dibujar()
bolaL.camara(1,1,nil)
end

function bolaL.camara(equipo,jugador,canvasss)
    local xsx=bolaL.entidades.jugadores[jugador].posX-bolaL.mdx
    --print(bolaL.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-bolaL.ancho then
        xsx=ancho-bolaL.ancho
    end
    local ysy=bolaL.entidades.jugadores[jugador].posY-bolaL.mdy
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-bolaL.alto then
        ysy=alto-bolaL.alto
    end
    bolaL.mapa.dibujar(xsx,ysy,bolaL.ancho,bolaL.alto,canvasss)
    bolaL.entidades.dibujar(xsx,ysy,canvasss,bolaL.ancho,bolaL.alto)
    bolaL.temud.dibujar(xsx,ysy)
    
end
--Mantiene a la entidad dentro de los limites del mapa
function bolaL.corregirPosicion(entt)
if entt.posX>ancho-entt.medX then
    entt.posX=ancho-entt.medX
elseif entt.posX<entt.medX then
    entt.posX=entt.medX
end
if entt.posY>ancho-entt.medY then
    entt.posY=ancho-entt.medY
elseif entt.posY<entt.medY then
    entt.posY=entt.medY
end

end

function bolaL.inputP(dt,jugador,avanzar,retroceder,izquierda,derecha,disparar,mina,pusa)
    if love.keyboard.isDown(avanzar) then
        bolaL.entidades.jugadores[jugador].posY=bolaL.entidades.jugadores[jugador].posY-bolaL.entidades.jugadores[jugador].magnitud*math.sin(bolaL.entidades.jugadores[jugador].angulo-ssangulo)*dt
        bolaL.entidades.jugadores[jugador].posX=bolaL.entidades.jugadores[jugador].posX-bolaL.entidades.jugadores[jugador].magnitud*math.cos(bolaL.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(retroceder) then
        bolaL.entidades.jugadores[jugador].posY=bolaL.entidades.jugadores[jugador].posY+bolaL.entidades.jugadores[jugador].magnitud*math.sin(bolaL.entidades.jugadores[jugador].angulo-ssangulo)*dt
        bolaL.entidades.jugadores[jugador].posX=bolaL.entidades.jugadores[jugador].posX+bolaL.entidades.jugadores[jugador].magnitud*math.cos(bolaL.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(izquierda) then
        bolaL.entidades.jugadores[jugador].angulo=bolaL.entidades.jugadores[jugador].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown(derecha) then
        bolaL.entidades.jugadores[jugador].angulo=bolaL.entidades.jugadores[jugador].angulo+math.rad(100)*dt
    end
    if love.keyboard.isDown(disparar) then
        bolaL.entidades.disparar(bolaL.entidades.jugadores[jugador])
    end
    if love.keyboard.isDown(mina) then
        bolaL.entidades.plantarMina(bolaL.entidades.jugadores[jugador])
    end
    if love.keyboard.isDown(pusa) then
        inter.even = 3
    end 

end


bolaL.entidades.actualizarJugadores(dt)
bolaL.entidades.actualizarProyectiles(dt)
bolaL.entidades.detectarColision(dt)
end

function bolaL.keypressed( key,scancode,isrepeat)
    -- body
    bolaL.entidades.keypressed( key,scancode,isrepeat)
end

return bolaL