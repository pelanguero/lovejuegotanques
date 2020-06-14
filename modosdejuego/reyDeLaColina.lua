local rey={entidades=require "../entidades/entidadesrey",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=1200,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0


function rey.new()
    rey.mapa.new("../mapas/rey","//assets/terrainTiles_default.png")
    ancho=rey.mapa.tablamapa.width*64
    alto=rey.mapa.tablamapa.height*64
    
    for i=1,#rey.mapa.puntos do 
       if rey.mapa.puntos[i].val==1 then
         rey.entidades.agregarSpawn(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)
       elseif rey.mapa.puntos[i].val==2 then        
        rey.entidades.agregarPowerUp(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)       
        elseif rey.mapa.puntos[i].val==3 then        
        rey.entidades.agregarColina(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)
       end

    end

    rey.entidades.agregarJugador(1,rey.entidades.spawns[4].x,rey.entidades.spawns[4].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)
    rey.entidades.agregarJugador(2,rey.entidades.spawns[2].x,rey.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)

end

function rey.dibujar()
rey.camara(1,1,nil)
end

function rey.camara(equipo,jugador,canvasss)
    local xsx=rey.entidades.jugadores[jugador].posX-rey.mdx
    --print(rey.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-rey.ancho then
        xsx=ancho-rey.ancho
    end
    local ysy=rey.entidades.jugadores[jugador].posY-rey.mdy
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-rey.alto then
        ysy=alto-rey.alto
    end
    rey.mapa.dibujar(xsx,ysy,rey.ancho,rey.alto,canvasss)
    rey.entidades.dibujar(xsx,ysy,canvasss,rey.ancho,rey.alto)
    
end
--Mantiene a la entidad dentro de los limites del mapa
function rey.corregirPosicion(entt)
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

function rey.inputP(dt,jugador,avanzar,retroceder,izquierda,derecha,disparar,mina)
    if love.keyboard.isDown(avanzar) then
        rey.entidades.jugadores[jugador].posY=rey.entidades.jugadores[jugador].posY-rey.entidades.jugadores[jugador].magnitud*math.sin(rey.entidades.jugadores[jugador].angulo-ssangulo)*dt
        rey.entidades.jugadores[jugador].posX=rey.entidades.jugadores[jugador].posX-rey.entidades.jugadores[jugador].magnitud*math.cos(rey.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(retroceder) then
        rey.entidades.jugadores[jugador].posY=rey.entidades.jugadores[jugador].posY+rey.entidades.jugadores[jugador].magnitud*math.sin(rey.entidades.jugadores[jugador].angulo-ssangulo)*dt
        rey.entidades.jugadores[jugador].posX=rey.entidades.jugadores[jugador].posX+rey.entidades.jugadores[jugador].magnitud*math.cos(rey.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(izquierda) then
        rey.entidades.jugadores[jugador].angulo=rey.entidades.jugadores[jugador].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown(derecha) then
        rey.entidades.jugadores[jugador].angulo=rey.entidades.jugadores[jugador].angulo+math.rad(100)*dt
    end
    if love.keyboard.isDown(disparar) then
    rey.entidades.disparar(rey.entidades.jugadores[jugador])
    end
    if love.keyboard.isDown(mina) then
        rey.entidades.plantarMina(rey.entidades.jugadores[jugador])
    end
end

function rey.proupdate(dt)
rey.inputP(dt,1,"w","s","a","d","q","e")
rey.inputP(dt,2,"i","k","j","l","u","o")
rey.corregirPosicion(rey.entidades.jugadores[1])
rey.entidades.actualizarJugadores(dt)
rey.entidades.actualizarProyectiles(dt)
rey.entidades.detectarColision(dt)
end

return rey