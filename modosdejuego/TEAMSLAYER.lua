local ts={entidades=require "../entidades/entidadesTS",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=800,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0


function ts.new()
    ts.mapa.new("../mapas/TS","//assets/terrainTiles_default.png")
    ancho=ts.mapa.tablamapa.width*64
    alto=ts.mapa.tablamapa.height*64
    
    for i=1,#ts.mapa.puntos do 
       if ts.mapa.puntos[i].val==1 then
         ts.entidades.agregarSpawn(ts.mapa.puntos[i].x,ts.mapa.puntos[i].y)
       else
        ts.entidades.agregarPowerUp(ts.mapa.puntos[i].x,ts.mapa.puntos[i].y)
       end
    end

    ts.entidades.agregarJugador(1,ts.entidades.spawns[4].x,ts.entidades.spawns[4].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)
    ts.entidades.agregarJugador(2,ts.entidades.spawns[2].x,ts.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)

end

function ts.dibujar()
ts.camara(1,1,nil)
end

function ts.camara(equipo,jugador,canvasss)
    local xsx=ts.entidades.jugadores[jugador].posX-ts.mdx
    --print(ts.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-ts.ancho then
        xsx=ancho-ts.ancho
    end
    local ysy=ts.entidades.jugadores[jugador].posY-ts.mdy
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-ts.alto then
        ysy=alto-ts.alto
    end
    ts.mapa.dibujar(xsx,ysy,800,600,canvasss)
    ts.entidades.dibujar(xsx,ysy,canvasss)
    
end
--Mantiene a la entidad dentro de los limites del mapa
function ts.corregirPosicion(entt)
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

function ts.inputP(dt,jugador,avanzar,retroceder,izquierda,derecha,disparar,mina)
    if love.keyboard.isDown(avanzar) then
        ts.entidades.jugadores[jugador].posY=ts.entidades.jugadores[jugador].posY-ts.entidades.jugadores[jugador].magnitud*math.sin(ts.entidades.jugadores[jugador].angulo-ssangulo)*dt
        ts.entidades.jugadores[jugador].posX=ts.entidades.jugadores[jugador].posX-ts.entidades.jugadores[jugador].magnitud*math.cos(ts.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(retroceder) then
        ts.entidades.jugadores[jugador].posY=ts.entidades.jugadores[jugador].posY+ts.entidades.jugadores[jugador].magnitud*math.sin(ts.entidades.jugadores[jugador].angulo-ssangulo)*dt
        ts.entidades.jugadores[jugador].posX=ts.entidades.jugadores[jugador].posX+ts.entidades.jugadores[jugador].magnitud*math.cos(ts.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(izquierda) then
        ts.entidades.jugadores[jugador].angulo=ts.entidades.jugadores[jugador].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown(derecha) then
        ts.entidades.jugadores[jugador].angulo=ts.entidades.jugadores[jugador].angulo+math.rad(100)*dt
    end
    if love.keyboard.isDown(disparar) then
    ts.entidades.disparar(ts.entidades.jugadores[jugador])
    end
    if love.keyboard.isDown(mina) then
        ts.entidades.plantarMina(ts.entidades.jugadores[jugador])
    end
end

function ts.proupdate(dt)
ts.inputP(dt,1,"w","s","a","d","q","e")
ts.inputP(dt,2,"i","k","j","l","u","o")
ts.corregirPosicion(ts.entidades.jugadores[1])
ts.entidades.actualizarJugadores(dt)
ts.entidades.actualizarProyectiles(dt)
ts.entidades.detectarColision(dt)
end

return ts