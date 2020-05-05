local ts={entidades=require "../entidades/entidadesTS",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=800,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0


function ts.new()
    ts.mapa.new("../mapas/TS","//assets/terrainTiles_default.png")
    ancho=ts.mapa.tablamapa.width*64
    alto=ts.mapa.tablamapa.height*64
    print(alto)
    for i=1,#ts.mapa.puntos do 
       if ts.mapa.puntos[i].val==1 then
         ts.entidades.agregarSpawn(ts.mapa.puntos[i].x,ts.mapa.puntos[i].y)
       end
    end

    ts.entidades.agregarJugador(3,ts.entidades.spawns[3].x,ts.entidades.spawns[3].y,"nada",nil,0,300,20,100,"ninguno",21,23,1)
    ts.entidades.agregarJugador(2,ts.entidades.spawns[2].x,ts.entidades.spawns[2].y,"nada",nil,0,100,20,100,"ninguno",21,23,1)

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
    print(xsx)
    ts.mapa.dibujar(xsx,ysy,800,600,canvasss)
    ts.entidades.dibujar(xsx,ysy,canvasss)
    
end

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


function ts.proupdate(dt)
if love.keyboard.isDown("w") then
    ts.entidades.jugadores[1].posY=ts.entidades.jugadores[1].posY-ts.entidades.jugadores[1].magnitud*math.sin(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    ts.entidades.jugadores[1].posX=ts.entidades.jugadores[1].posX-ts.entidades.jugadores[1].magnitud*math.cos(ts.entidades.jugadores[1].angulo-ssangulo)*dt
elseif love.keyboard.isDown("s") then
    ts.entidades.jugadores[1].posY=ts.entidades.jugadores[1].posY+ts.entidades.jugadores[1].magnitud*math.sin(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    ts.entidades.jugadores[1].posX=ts.entidades.jugadores[1].posX+ts.entidades.jugadores[1].magnitud*math.cos(ts.entidades.jugadores[1].angulo-ssangulo)*dt
elseif love.keyboard.isDown("a") then
    ts.entidades.jugadores[1].angulo=ts.entidades.jugadores[1].angulo-math.rad(100)*dt
elseif love.keyboard.isDown("d") then
    ts.entidades.jugadores[1].angulo=ts.entidades.jugadores[1].angulo+math.rad(100)*dt
end
if love.keyboard.isDown("q") then
ts.entidades.disparar(ts.entidades.jugadores[1])
end
if love.keyboard.isDown("u") then
    ts.entidades.disparar(ts.entidades.jugadores[2])
end

ts.corregirPosicion(ts.entidades.jugadores[1])
ts.entidades.actualizarProyectiles(dt)
ts.entidades.detectarColision(dt)
end

return ts