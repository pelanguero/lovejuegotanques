local ctf={temud=require "../modosdejuego/prron",entidades=require "../entidades/entidadesCTF",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=600,mdy=300,ancho=1200,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0
local inputUno={}
local inputDos={}
local hud=require "hud"
local pantallas={}

function ctf.new(ancc,altt)
    ctf.mapa.new("../mapas/capturarlabandera","//assets/terrainTiles_default.png")
    ctf.ancho=ancc
    ctf.alto=altt
    ctf.mdx=math.floor(ancc/2)
    ctf.mdy=math.floor(altt/2)
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
    ancho=ctf.mapa.tablamapa.width*64
    alto=ctf.mapa.tablamapa.height*64
    ctf.temud.new(ctf.mapa,ancc,altt)
    for i=1,#ctf.mapa.puntos do 
       if ctf.mapa.puntos[i].val==1 then
         ctf.entidades.agregarSpawn(ctf.mapa.puntos[i].x,ctf.mapa.puntos[i].y)
       elseif ctf.mapa.puntos[i].val==2 then
        ctf.entidades.agregarPowerUp(ctf.mapa.puntos[i].x,ctf.mapa.puntos[i].y)
       elseif ctf.mapa.puntos[i].val==3 then
        ctf.entidades.agregarBandera(ctf.mapa.puntos[i].x,ctf.mapa.puntos[i].y)
       end
    end

    ctf.entidades.agregarJugador(1,ctf.entidades.spawns[1].x,ctf.entidades.spawns[1].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputUno)
    ctf.entidades.agregarJugador(2,ctf.entidades.spawns[2].x,ctf.entidades.spawns[2].y,"nada",nil,0,300,20,100,"ninguno",21,23,1,inputDos)
    ctf.entidades.ancho=ctf.ancho+50
    ctf.entidades.alto=ctf.alto+50
    -- pantalla dividida: una vista por jugador
    local mitad=math.floor(ancc/2)
    pantallas[1]=love.graphics.newCanvas(mitad,altt)
    pantallas[2]=love.graphics.newCanvas(mitad,altt)
end

function ctf.dibujar()
    local mitad=math.floor(ctf.ancho/2)
    local vistaX,vistaY={},{}
    for i=1,#pantallas do
        vistaX[i],vistaY[i]=ctf.camara(1,i,pantallas[i],mitad,ctf.alto)
        love.graphics.draw(pantallas[i],(i-1)*mitad,0)
    end
    hud.divisor(ctf.ancho,ctf.alto)
    hud.marcador(ctf.entidades.puntuaciones,ctf.ancho)
    ctf.temud.dibujar(vistaX[1],vistaY[1])
end

function ctf.camara(equipo,jugador,canvasss,llancho,llalto)
    local xsx=ctf.entidades.jugadores[jugador].posX-math.floor(llancho/2)
    if xsx<0 then
        xsx=0
    elseif xsx>ancho-llancho then
        xsx=ancho-llancho
    end
    local ysy=ctf.entidades.jugadores[jugador].posY-math.floor(llalto/2)
    if ysy<0 then
        ysy=0
    elseif ysy>alto-llalto then
        ysy=alto-llalto
    end
    ctf.mapa.dibujar(xsx,ysy,llancho,llalto,canvasss)
    ctf.entidades.dibujar(xsx,ysy,canvasss,llancho,llalto)
    hud.powerups(ctf.entidades.jugadores[jugador],canvasss,llancho,llalto)
    return xsx,ysy
end
--Mantiene a la entidad dentro de los limites del mapa
function ctf.corregirPosicion(entt)
    local x,y=entt.body:getPosition()
    local cx=math.max(entt.medX,math.min(ancho-entt.medX,x))
    local cy=math.max(entt.medY,math.min(alto-entt.medY,y))
    if cx~=x or cy~=y then
        entt.body:setPosition(cx,cy)
        entt.posX,entt.posY=cx,cy
    end
end



function ctf.keypressed( key,scancode,isrepeat)
    -- body
    ctf.entidades.keypressed( key,scancode,isrepeat)
end

function ctf.proupdate(dt)
    ctf.entidades.actualizarphy(dt)
ctf.entidades.actualizarJugadores(dt)
for i=1,#ctf.entidades.jugadores do
    ctf.corregirPosicion(ctf.entidades.jugadores[i])
end
ctf.entidades.actualizarProyectiles(dt)
ctf.entidades.detectarColision(dt)
end

return ctf