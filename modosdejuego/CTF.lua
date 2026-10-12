local ctf={temud=require "../modosdejuego/prron",entidades=require "../entidades/entidadesCTF",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=600,mdy=300,ancho=1200,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)
local ancho=0
local alto=0
local inputUno={}
local inputDos={}

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
end

function ctf.dibujar()
ctf.camara(1,1,nil)
end

function ctf.camara(equipo,jugador,canvasss)
    local xsx=ctf.entidades.jugadores[jugador].posX-ctf.mdx
    --print(ctf.entidades.jugadores[2].vida)
    if xsx<0 then 
        xsx=0
    elseif xsx>ancho-ctf.ancho then
        xsx=ancho-ctf.ancho
    end
    local ysy=ctf.entidades.jugadores[jugador].posY-ctf.mdy
    if ysy<0 then 
        ysy=0
    elseif ysy>alto-ctf.alto then
        ysy=alto-ctf.alto
    end
    ctf.mapa.dibujar(xsx,ysy,ctf.ancho,ctf.alto,canvasss)
    ctf.entidades.dibujar(xsx,ysy,canvasss,ctf.ancho,ctf.alto)
    ctf.temud.dibujar(xsx,ysy)
    
end
--Mantiene a la entidad dentro de los limites del mapa
function ctf.corregirPosicion(entt)
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



function ctf.keypressed( key,scancode,isrepeat)
    -- body
    ctf.entidades.keypressed( key,scancode,isrepeat)
end

function ctf.proupdate(dt)
    ctf.entidades.actualizarphy(dt)
ctf.entidades.actualizarJugadores(dt)
ctf.entidades.actualizarProyectiles(dt)
ctf.entidades.detectarColision(dt)
end

return ctf