local ts={entidades=require "../entidades/entidadesTS",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=800,alto=600,pantallas={}}
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
function ts.new(ancc,altt)
    ts.mapa.new("../mapas/TS","//assets/terrainTiles_default.png")
    ancho=ts.mapa.tablamapa.width*64
    alto=ts.mapa.tablamapa.height*64
    ts.ancho=ancc
    ts.alto=altt
    ts.mdx=math.floor(ancc/2)
    ts.mdy=math.floor(altt/2)
    inputUno.adelante="w"
    inputUno.atras="s"
    inputUno.derecha="d"
    inputUno.izquierda="a"
    inputUno.disparar="q"
    inputUno.mina="e"
    inputUno.joystick=false
    inputUno.njoystick=1
    inputDos.adelante="i"
    inputDos.atras="k"
    inputDos.derecha="l"
    inputDos.izquierda="j"
    inputDos.joystick=false
    inputDos.njoystick=2
    inputDos.disparar="u"
    inputDos.mina="o"
    
    for i=1,#ts.mapa.puntos do 
       if ts.mapa.puntos[i].val==1 then
         ts.entidades.agregarSpawn(ts.mapa.puntos[i].x,ts.mapa.puntos[i].y)
       else
        ts.entidades.agregarPowerUp(ts.mapa.puntos[i].x,ts.mapa.puntos[i].y)
       end
    end
    ts.entidades.agregarJugador(1,ts.entidades.spawns[1].x,ts.entidades.spawns[1].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputUno)
    ts.entidades.agregarJugador(2,ts.entidades.spawns[2].x,ts.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputDos)
    ts.configurarVideo(ts.ancho,ts.alto)
end

function ts.configurarVideo(width,height)
    --ya sé que puedo usar un ciclo para ésto
    --TODO:USAR UN CICLO
    if #ts.entidades.jugadores==2 then 
        ts.pantallas[1]={}
        ts.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height)
        ts.pantallas[1].x=0
        ts.pantallas[1].y=0
        ts.pantallas[2]={}
        ts.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height)
        ts.pantallas[2].x=math.floor(width/2)
        ts.pantallas[2].y=0
        
    elseif #ts.entidades.jugadores==3 then 
        ts.pantallas[1]={}
        ts.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[1].x=0
        ts.pantallas[1].y=0
        ts.pantallas[2]={}
        ts.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[2].x=math.floor(width/2)
        ts.pantallas[2].y=0
        ts.pantallas[3]={}
        ts.pantallas[3].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[3].x=0
        ts.pantallas[3].y=math.floor(height/2)
    elseif #ts.entidades.jugadores==4 then
        ts.pantallas[1]={}
        ts.pantallas[1].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[1].x=0
        ts.pantallas[1].y=0
        ts.pantallas[2]={}
        ts.pantallas[2].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[2].x=math.floor(width/2)
        ts.pantallas[2].y=0
        ts.pantallas[3]={}
        ts.pantallas[3].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[3].x=0
        ts.pantallas[3].y=math.floor(height/2)
        ts.pantallas[4]={}
        ts.pantallas[4].canvas=love.graphics.newCanvas(math.floor(width/2),height/2)
        ts.pantallas[4].x=math.floor(width/2)
        ts.pantallas[4].y=math.floor(height/2)
    else
         ts.pantallas=nil 
    end
    modo=#ts.entidades.jugadores
end

function ts.dibujar()

    --aqui tambien podría usar un ciclo

    if modo==1 then
        ts.camara(1,1,nil,ts.ancho,ts.alto)
    elseif modo==2 then
        ts.camara(1,1,ts.pantallas[1].canvas,ts.ancho/2,ts.alto)
        ts.camara(1,2,ts.pantallas[2].canvas,ts.ancho/2,ts.alto)
        love.graphics.draw(ts.pantallas[1].canvas,ts.pantallas[1].x,ts.pantallas[1].y)
        love.graphics.draw(ts.pantallas[2].canvas,ts.pantallas[2].x,ts.pantallas[2].y)
    elseif modo==3 then
        ts.camara(1,2,ts.pantallas[1].canvas,ts.ancho/2,ts.alto/2)
        ts.camara(1,1,ts.pantallas[2].canvas,ts.ancho/2,ts.alto/2)
        ts.camara(1,3,ts.pantallas[2].canvas,ts.ancho/2,ts.alto/2)
        love.graphics.draw(ts.pantallas[1].canvas,ts.pantallas[1].x,ts.pantallas[1].y)
        love.graphics.draw(ts.pantallas[2].canvas,ts.pantallas[2].x,ts.pantallas[2].y)
        love.graphics.draw(ts.pantallas[3].canvas,ts.pantallas[3].x,ts.pantallas[3].y)
    elseif modo==4 then
        ts.camara(1,2,ts.pantallas[1].canvas,ts.ancho/2,ts.alto/2)
        ts.camara(1,1,ts.pantallas[2].canvas,ts.ancho/2,ts.alto/2)
        ts.camara(1,3,ts.pantallas[3].canvas,ts.ancho/2,ts.alto/2)
        ts.camara(1,4,ts.pantallas[4].canvas,ts.ancho/2,ts.alto/2)
        love.graphics.draw(ts.pantallas[1].canvas,ts.pantallas[1].x,ts.pantallas[1].y)
        love.graphics.draw(ts.pantallas[2].canvas,ts.pantallas[2].x,ts.pantallas[2].y)
        love.graphics.draw(ts.pantallas[3].canvas,ts.pantallas[3].x,ts.pantallas[3].y)
        love.graphics.draw(ts.pantallas[4].canvas,ts.pantallas[4].x,ts.pantallas[4].y)
    end
    
end

function ts.camara(equipo,jugador,canvasss,llancho,llalto)
    local xsx=ts.entidades.jugadores[jugador].body:getX()-math.floor(llancho/2)
    --print(ts.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-llancho then
        xsx=ancho-llancho
    end
    local ysy=ts.entidades.jugadores[jugador].body:getY()-math.floor(llalto/2)
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-llalto then
        ysy=alto-llalto
    end
    ts.mapa.dibujar(xsx,ysy,llancho,llalto,canvasss)
    ts.entidades.dibujar(xsx,ysy,canvasss,llancho,llalto)
    
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

function ts.proupdate(dt,joyss)
    if pausa then
        ts.entidades.actualizarphy(dt)
        ts.entidades.actualizarJugadores(dt,joyss)
        ts.entidades.actualizarProyectiles(dt)
        ts.entidades.detectarColision(dt)
    end
end

function ts.joystickpressed(joystick,boton)
    ts.entidades.joystickpressed(joystick,boton)
end

function ts.keypressed( key,scancode,isrepeat)
    -- body
    if key == "escape" then 
        if pausa then
            pausa=false
        else
            pausa=true
        end
    end
    ts.entidades.keypressed(key,scancode,isrepeat)
end

return ts