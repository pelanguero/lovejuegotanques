local rey={entidades=require "../entidades/entidadesRey",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=1200,alto=600,pantallas={}}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0
local inputUno={}
local inputDos={}
local inputTres={}
local inputCuatro={}
local pausa=true
local modo=0
function rey.new(ancc,altt,nju,tblcontroles)
    rey.mapa.new("../mapas/rey","//assets/terrainTiles_default.png")
    ancho=rey.mapa.tablamapa.width*64
    alto=rey.mapa.tablamapa.height*64
    rey.ancho=ancc
    rey.alto=altt
    rey.mdx=math.floor(ancc/2)
    rey.mdy=math.floor(altt/2)
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
    
    for i=1,#rey.mapa.puntos do 
       if rey.mapa.puntos[i].val==1 then
         rey.entidades.agregarSpawn(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)
       elseif rey.mapa.puntos[i].val==2 then        
        rey.entidades.agregarPowerUp(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)       
        elseif rey.mapa.puntos[i].val==3 then        
        rey.entidades.agregarColina(rey.mapa.puntos[i].x,rey.mapa.puntos[i].y)
       end

    end

    rey.entidades.agregarJugador(1,rey.entidades.spawns[1].x,rey.entidades.spawns[1].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputUno)
    rey.entidades.agregarJugador(2,rey.entidades.spawns[2].x,rey.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputDos)
    rey.configurarVideo(rey.ancho,rey.alto)
end

function rey.configurarVideo(width,height)
    --ya sé que puedo usar un ciclo para ésto
    --TODO:USAR UN CICLO
    if #rey.entidades.jugadores==2 then 
        rey.pantallas[1]={}
        rey.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height)
        rey.pantallas[1].x=0
        rey.pantallas[1].y=0
        rey.pantallas[2]={}
        rey.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height)
        rey.pantallas[2].x=math.floor(width/2)
        rey.pantallas[2].y=0
        
    elseif #rey.entidades.jugadores==3 then 
        rey.pantallas[1]={}
        rey.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[1].x=0
        rey.pantallas[1].y=0
        rey.pantallas[2]={}
        rey.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[2].x=math.floor(width/2)
        rey.pantallas[2].y=0
        rey.pantallas[3]={}
        rey.pantallas[3].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[3].x=0
        rey.pantallas[3].y=math.floor(height/2)
    elseif #rey.entidades.jugadores==4 then
        rey.pantallas[1]={}
        rey.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[1].x=0
        rey.pantallas[1].y=0
        rey.pantallas[2]={}
        rey.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[2].x=math.floor(width/2)
        rey.pantallas[2].y=0
        rey.pantallas[3]={}
        rey.pantallas[3].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[3].x=0
        rey.pantallas[3].y=math.floor(height/2)
        rey.pantallas[4]={}
        rey.pantallas[4].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        rey.pantallas[4].x=math.floor(width/2)
        rey.pantallas[4].y=math.floor(height/2)
    else
         rey.pantallas=nil 
    end
    modo=#rey.entidades.jugadores
end

function rey.dibujar()
    --aqui tambien podría usar un ciclo
    if modo==1 then
        rey.camara(1,1,nil,rey.ancho,rey.alto)
        print("pelanguero")
    elseif modo==2 then
        rey.camara(1,1,rey.pantallas[1].canvas,rey.ancho/2,rey.alto)
        rey.camara(1,2,rey.pantallas[2].canvas,rey.ancho/2,rey.alto)
        love.graphics.draw(rey.pantallas[1].canvas,rey.pantallas[1].x,rey.pantallas[1].y)
        love.graphics.draw(rey.pantallas[2].canvas,rey.pantallas[2].x,rey.pantallas[2].y)
    elseif modo==3 then
        rey.camara(1,2,rey.pantallas[1].canvas,rey.ancho/2,rey.alto/2)
        rey.camara(1,1,rey.pantallas[2].canvas,rey.ancho/2,rey.alto/2)
        rey.camara(1,3,rey.pantallas[2].canvas,rey.ancho/2,rey.alto/2)
        love.graphics.draw(rey.pantallas[1].canvas,rey.pantallas[1].x,rey.pantallas[1].y)
        love.graphics.draw(rey.pantallas[2].canvas,rey.pantallas[2].x,rey.pantallas[2].y)
        love.graphics.draw(rey.pantallas[3].canvas,rey.pantallas[3].x,rey.pantallas[3].y)
    elseif modo==4 then
        rey.camara(1,2,rey.pantallas[1].canvas,rey.ancho/2,rey.alto/2)
        rey.camara(1,1,rey.pantallas[2].canvas,rey.ancho/2,rey.alto/2)
        rey.camara(1,3,rey.pantallas[3].canvas,rey.ancho/2,rey.alto/2)
        rey.camara(1,4,rey.pantallas[4].canvas,rey.ancho/2,rey.alto/2)
        love.graphics.draw(rey.pantallas[1].canvas,rey.pantallas[1].x,rey.pantallas[1].y)
        love.graphics.draw(rey.pantallas[2].canvas,rey.pantallas[2].x,rey.pantallas[2].y)
        love.graphics.draw(rey.pantallas[3].canvas,rey.pantallas[3].x,rey.pantallas[3].y)
        love.graphics.draw(rey.pantallas[4].canvas,rey.pantallas[4].x,rey.pantallas[4].y)
    end
    
end

function rey.camara(equipo,jugador,canvasss,llancho,llalto)
    local xsx=rey.entidades.jugadores[jugador].posX-math.floor(llancho/2)
    --print(rey.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-llancho then
        xsx=ancho-llancho
    end
    local ysy=rey.entidades.jugadores[jugador].posY-math.floor(llalto/2)
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-llalto then
        ysy=alto-llalto
    end
    rey.mapa.dibujar(xsx,ysy,llancho,llalto,canvasss)
    rey.entidades.dibujar(xsx,ysy,canvasss,llancho,llalto)
    
end

--[[function rey.dibujar()
rey.camara(1,1,nil)
end]]

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
rey.entidades.actualizarphy(dt)
rey.entidades.actualizarJugadores(dt)
rey.entidades.actualizarProyectiles(dt)
rey.entidades.detectarColision(dt)
end
function rey.keypressed( key,scancode,isrepeat)
    -- body
    rey.entidades.keypressed( key,scancode,isrepeat)
end

return rey