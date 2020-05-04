local ts={entidades=require "../entidades/entidadesTS",mapa=require "../mapa/mapaTS",puntosEquipos={},mdx=400,mdy=300,ancho=800,alto=600}
--corregir a nuevos parametros
local ssangulo=math.rad(90)

function ts.new()
    ts.mapa.new("../mapas/TS","//assets/terrainTiles_default.png")
    local xsw=-1
    local ysw=-1
    local xsww=-1
    local ysww=-1
    for i=1,#ts.mapa.puntos do 
       if ts.mapa.puntos[i].val==1 and xsw<0 then
            xsw=ts.mapa.puntos[i].x
            ysw=ts.mapa.puntos[i].y
       elseif ts.mapa.puntos[i].val==1 and xsww<0 then
            xsww=ts.mapa.puntos[i].x
            ysww=ts.mapa.puntos[i].y
       end
    end
    ts.entidades.agregarJugador(1,xsw,ysw,"nada",nil,0,100,20,100,"ninguno",21,23,1)
    ts.entidades.agregarJugador(2,xsww,ysww,"nada",nil,0,100,20,100,"ninguno",21,23,1)

end

function ts.dibujar()
ts.camara(1,1,nil)
end

function ts.camara(equipo,jugador,canvasss)
    local xsx=ts.entidades.jugadores[jugador].posX-ts.mdx
    print(ts.entidades.jugadores[jugador].posX)
    if xsx<0 then 
    xsx=0
    end
    local ysy=ts.entidades.jugadores[jugador].posY-ts.mdy
    if ysy<0 then 
        ysy=0
    end
    ts.mapa.dibujar(xsx,ysy,800,600,canvasss)
    ts.entidades.dibujar(xsx,ysy,canvasss)
    
end

function ts.proupdate(dt)
if love.keyboard.isDown("w") then
    ts.entidades.jugadores[1].posY=ts.entidades.jugadores[1].posY-ts.entidades.jugadores[1].magnitud*math.sin(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    if ts.entidades.jugadores[1].posY<23 then
    ts.entidades.jugadores[1].posY=23
    end
    ts.entidades.jugadores[1].posX=ts.entidades.jugadores[1].posX-ts.entidades.jugadores[1].magnitud*math.cos(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    if ts.entidades.jugadores[1].posX<21 then
        ts.entidades.jugadores[1].posX=21
    end
elseif love.keyboard.isDown("s") then
    ts.entidades.jugadores[1].posY=ts.entidades.jugadores[1].posY+ts.entidades.jugadores[1].magnitud*math.sin(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    if ts.entidades.jugadores[1].posY<23 then
    ts.entidades.jugadores[1].posY=23
    end
    ts.entidades.jugadores[1].posX=ts.entidades.jugadores[1].posX+ts.entidades.jugadores[1].magnitud*math.cos(ts.entidades.jugadores[1].angulo-ssangulo)*dt
    if ts.entidades.jugadores[1].posX<21 then
        ts.entidades.jugadores[1].posX=21
    end
elseif love.keyboard.isDown("a") then
    ts.entidades.jugadores[1].angulo=ts.entidades.jugadores[1].angulo-math.rad(100)*dt
elseif love.keyboard.isDown("d") then
    ts.entidades.jugadores[1].angulo=ts.entidades.jugadores[1].angulo+math.rad(100)*dt
end
end

return ts