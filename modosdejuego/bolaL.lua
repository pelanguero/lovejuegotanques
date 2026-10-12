
local bolaL={temud=require "../modosdejuego/prron",entidades=require "../entidades/entidadesBol",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=600,mdy=300,ancho=1200,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0
local inputUno={}
local inputDos={}
local hud=require "hud"
local pantallas={}

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
    -- pantalla dividida: una vista por jugador
    local mitad=math.floor(ancc/2)
    pantallas[1]=love.graphics.newCanvas(mitad,altt)
    pantallas[2]=love.graphics.newCanvas(mitad,altt)
end

function bolaL.dibujar()
    local mitad=math.floor(bolaL.ancho/2)
    local vistaX,vistaY={},{}
    for i=1,#pantallas do
        vistaX[i],vistaY[i]=bolaL.camara(1,i,pantallas[i],mitad,bolaL.alto)
        love.graphics.draw(pantallas[i],(i-1)*mitad,0)
    end
    hud.divisor(bolaL.ancho,bolaL.alto)
    hud.marcador(bolaL.entidades.puntuaciones,bolaL.ancho)
    bolaL.temud.dibujar(vistaX[1],vistaY[1])
end

function bolaL.camara(equipo,jugador,canvasss,llancho,llalto)
    local xsx=bolaL.entidades.jugadores[jugador].posX-math.floor(llancho/2)
    if xsx<0 then
        xsx=0
    elseif xsx>ancho-llancho then
        xsx=ancho-llancho
    end
    local ysy=bolaL.entidades.jugadores[jugador].posY-math.floor(llalto/2)
    if ysy<0 then
        ysy=0
    elseif ysy>alto-llalto then
        ysy=alto-llalto
    end
    bolaL.mapa.dibujar(xsx,ysy,llancho,llalto,canvasss)
    bolaL.entidades.dibujar(xsx,ysy,canvasss,llancho,llalto)
    hud.powerups(bolaL.entidades.jugadores[jugador],canvasss,llancho,llalto)
    return xsx,ysy
end
--Mantiene a la entidad dentro de los limites del mapa
function bolaL.corregirPosicion(entt)
    local x,y=entt.body:getPosition()
    local cx=math.max(entt.medX,math.min(ancho-entt.medX,x))
    local cy=math.max(entt.medY,math.min(alto-entt.medY,y))
    if cx~=x or cy~=y then
        entt.body:setPosition(cx,cy)
        entt.posX,entt.posY=cx,cy
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
        interf.irA(interf.PAUSA)
    end 

end

function bolaL.proupdate(dt)
bolaL.entidades.actualizarphy(dt)
bolaL.entidades.actualizarJugadores(dt)
for i=1,#bolaL.entidades.jugadores do
    bolaL.corregirPosicion(bolaL.entidades.jugadores[i])
end
bolaL.entidades.actualizarProyectiles(dt)
bolaL.entidades.detectarColision(dt)
end

function bolaL.keypressed( key,scancode,isrepeat)
    -- body
    bolaL.entidades.keypressed( key,scancode,isrepeat)
end

return bolaL