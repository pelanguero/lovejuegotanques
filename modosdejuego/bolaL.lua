local bol={entidades=require "../entidades/entidadesBol",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=600,mdy=300,ancho=1200,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0


function bol.new()
    bol.mapa.new("../mapas/bola","//assets/terrainTiles_default.png")
    ancho=bol.mapa.tablamapa.width*64
    alto=bol.mapa.tablamapa.height*64
    
    for i=1,#bol.mapa.puntos do 
       if bol.mapa.puntos[i].val==1 then
         bol.entidades.agregarSpawn(bol.mapa.puntos[i].x,bol.mapa.puntos[i].y)
       elseif bol.mapa.puntos[i].val==2 then
        bol.entidades.agregarPowerUp(bol.mapa.puntos[i].x,bol.mapa.puntos[i].y)
       elseif bol.mapa.puntos[i].val==3 then
        bol.entidades.agregarBandera(bol.mapa.puntos[i].x,bol.mapa.puntos[i].y)
       end
    end

    bol.entidades.agregarJugador(1,bol.entidades.spawns[1].x,bol.entidades.spawns[1].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)
    bol.entidades.agregarJugador(2,bol.entidades.spawns[2].x,bol.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)
    bol.entidades.ancho=bol.ancho+50
    bol.entidades.alto=bol.alto+50
end

function bol.dibujar()
bol.camara(1,1,nil)
end

function bol.camara(equipo,jugador,canvasss)
    local xsx=bol.entidades.jugadores[jugador].posX-bol.mdx
    --print(bol.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-bol.ancho then
        xsx=ancho-bol.ancho
    end
    local ysy=bol.entidades.jugadores[jugador].posY-bol.mdy
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-bol.alto then
        ysy=alto-bol.alto
    end
    bol.mapa.dibujar(xsx,ysy,bol.ancho,bol.alto,canvasss)
    bol.entidades.dibujar(xsx,ysy,canvasss,bol.ancho,bol.alto)
    
end
--Mantiene a la entidad dentro de los limites del mapa
function bol.corregirPosicion(entt)
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

function bol.inputP(dt,jugador,avanzar,retroceder,izquierda,derecha,disparar,mina)
    if love.keyboard.isDown(avanzar) then
        bol.entidades.jugadores[jugador].posY=bol.entidades.jugadores[jugador].posY-bol.entidades.jugadores[jugador].magnitud*math.sin(bol.entidades.jugadores[jugador].angulo-ssangulo)*dt
        bol.entidades.jugadores[jugador].posX=bol.entidades.jugadores[jugador].posX-bol.entidades.jugadores[jugador].magnitud*math.cos(bol.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(retroceder) then
        bol.entidades.jugadores[jugador].posY=bol.entidades.jugadores[jugador].posY+bol.entidades.jugadores[jugador].magnitud*math.sin(bol.entidades.jugadores[jugador].angulo-ssangulo)*dt
        bol.entidades.jugadores[jugador].posX=bol.entidades.jugadores[jugador].posX+bol.entidades.jugadores[jugador].magnitud*math.cos(bol.entidades.jugadores[jugador].angulo-ssangulo)*dt
    elseif love.keyboard.isDown(izquierda) then
        bol.entidades.jugadores[jugador].angulo=bol.entidades.jugadores[jugador].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown(derecha) then
        bol.entidades.jugadores[jugador].angulo=bol.entidades.jugadores[jugador].angulo+math.rad(100)*dt
    end
    if love.keyboard.isDown(disparar) then
    bol.entidades.disparar(bol.entidades.jugadores[jugador])
    end
    if love.keyboard.isDown(mina) then
        bol.entidades.plantarMina(bol.entidades.jugadores[jugador])
    end
end

function bol.proupdate(dt)
bol.inputP(dt,1,"w","s","a","d","q","e")
bol.inputP(dt,2,"i","k","j","l","u","o")
bol.corregirPosicion(bol.entidades.jugadores[1])
bol.entidades.actualizarJugadores(dt)
bol.entidades.actualizarProyectiles(dt)
bol.entidades.detectarColision(dt)
end

return bol