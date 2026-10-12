-- Power-ups comunes a todos los modos: efectos sobre el tanque, cajas del
-- mapa, animacion al recogerlos e iconos que usa el HUD.
--
-- Cada caja tiene .vida: >60 = disponible; 60..1 = reapareciendo (cuenta
-- regresiva en segundos). Al reaparecer cambia de tipo al azar.
--
-- En el tanque los efectos activos viven en ply.efectos[tipo]:
--   {tiempo=seg, total=seg}   efectos por tiempo (energia, turbo)
--   {cargas=n, total=n}       efectos por cargas (minas pesadas, misiles)
--   {}                        sobreescudo: dura mientras ply.vida > VIDA_BASE
local powerups={}

local ENERGIA,ESCUDO,MINAS,TURBO,MISIL=1,2,3,4,5
powerups.ENERGIA,powerups.ESCUDO,powerups.MINAS,powerups.TURBO,powerups.MISIL=ENERGIA,ESCUDO,MINAS,TURBO,MISIL

local VIDA_BASE=100
local DURACION_ANUNCIO=1.6

powerups.TIPOS={
    [ENERGIA]={nombre="Energia+",color={0.30,0.80,1.00},duracion=15},
    [ESCUDO]={nombre="Sobreescudo",color={0.45,1.00,0.55},escudo=100},
    [MINAS]={nombre="Minas pesadas",color={1.00,0.50,0.20},cargas=3},
    [TURBO]={nombre="Turbo",color={1.00,0.88,0.20},duracion=10},
    [MISIL]={nombre="Misil teledirigido",color={1.00,0.35,0.45},cargas=2},
}

-- Misil: proyectil tipo 3 que persigue al rival mas cercano
powerups.TIPO_MISIL=3
powerups.DANHO_MISIL=50
powerups.DURACION_MISIL=6     -- segundos de vuelo
local FACTOR_MISIL=1.25       -- respecto a la velocidad maxima de un tanque
-- radio de giro en pixeles: igual en todos los modos aunque cambie la
-- velocidad. Se va cerrando con el vuelo para no quedar orbitando al rival
local RADIO_GIRO_MISIL=110
powerups.imagenMisil=love.graphics.newImage("//assets/proyectiles/bulletSand1_outline.png")
powerups.ESCALA_MISIL=1.7

local caja=love.graphics.newImage("//assets/crateMetal.png")
local fuente=love.graphics.newFont("arial_/arial_narrow_7.ttf",18)
powerups.fuente=fuente

local function reloj()
    return love.timer and love.timer.getTime() or 0
end

------------------------------------------------------------------ cajas

function powerups.tipoAlAzar()
    return math.random(1,#powerups.TIPOS)
end

-- Avanza la cuenta regresiva de las cajas recogidas
function powerups.actualizarCajas(lista,dt)
    for _,pw in ipairs(lista) do
        if pw.vida<61 and pw.vida>1 then
            pw.vida=pw.vida-dt
        elseif pw.vida<=1 then
            pw.vida=70
            pw.tipo=powerups.tipoAlAzar()
        end
    end
end

------------------------------------------------------------------ efectos

-- Valores del tanque sin power-ups, guardados la primera vez
local function base(ply)
    if not ply.basePU then
        ply.basePU={velocidad=ply.velocidad,auvel=ply.auvel,danhomina=ply.danhomina}
    end
    return ply.basePU
end

local function quitar(ply,tipo)
    local b=base(ply)
    if tipo==ENERGIA then
        ply.limite=100
        ply.ratio=50
        if ply.energia>ply.limite then ply.energia=ply.limite end
    elseif tipo==ESCUDO then
        if ply.vida>VIDA_BASE then ply.vida=VIDA_BASE end
    elseif tipo==MINAS then
        ply.danhomina=b.danhomina
    elseif tipo==TURBO then
        ply.velocidad=b.velocidad
        ply.auvel=b.auvel
        ply.multVelocidad=1
    end
    ply.efectos[tipo]=nil
end

-- El tanque recoge una caja de `tipo`
function powerups.aplicar(ply,tipo)
    local b=base(ply)
    local def=powerups.TIPOS[tipo]
    ply.efectos=ply.efectos or {}
    if tipo==ENERGIA then
        ply.limite=300
        ply.ratio=80
        ply.energia=300
    elseif tipo==ESCUDO then
        ply.vida=VIDA_BASE+def.escudo
    elseif tipo==MINAS then
        ply.danhomina=200
    elseif tipo==TURBO then
        ply.velocidad=b.velocidad*1.6
        ply.auvel=b.auvel*1.8
        ply.multVelocidad=1.6
    end
    if def.duracion then
        ply.efectos[tipo]={tiempo=def.duracion,total=def.duracion}
    elseif def.cargas then
        ply.efectos[tipo]={cargas=def.cargas,total=def.cargas}
    else
        ply.efectos[tipo]={}
    end
    powerups.anunciar(ply,tipo)
    ply.seqPU=(ply.seqPU or 0)+1
end

-- Descuenta tiempos y apaga los efectos agotados
function powerups.actualizar(ply,dt)
    if not ply.efectos then return end
    for tipo,e in pairs(ply.efectos) do
        if e.tiempo then
            e.tiempo=e.tiempo-dt
            if e.tiempo<=0 then quitar(ply,tipo) end
        elseif e.cargas then
            if e.cargas<=0 then quitar(ply,tipo) end
        elseif tipo==ESCUDO and ply.vida<=VIDA_BASE then
            ply.efectos[tipo]=nil
        end
    end
end

-- Se planto una mina: gasta una carga de minas pesadas
function powerups.minaPlantada(ply)
    local e=ply.efectos and ply.efectos[MINAS]
    if e then
        e.cargas=e.cargas-1
        if e.cargas<=0 then quitar(ply,MINAS) end
    end
end

-- Si le quedan misiles gasta uno y devuelve true: el disparo sale como misil
function powerups.usarMisil(ply)
    local e=ply.efectos and ply.efectos[MISIL]
    if not e then return false end
    e.cargas=e.cargas-1
    if e.cargas<=0 then quitar(ply,MISIL) end
    return true
end

-- Velocidad del misil: 1.25 veces la velocidad maxima de un tanque del modo
function powerups.velocidadMisil(E)
    return FACTOR_MISIL*E.velMaxJugador
end

-- Ajusta un proyectil recien creado para que se vea como misil
function powerups.prepararMisil(p)
    p.imagen=powerups.imagenMisil
    p.tamanho=powerups.ESCALA_MISIL
    p.estela={}
end

local function normalizar(a)
    return (a+math.pi)%(2*math.pi)-math.pi
end

local function posicionDe(e)
    if e.body then return e.body:getPosition() end
    return e.posX,e.posY
end

-- Gira cada misil hacia el rival vivo mas cercano (con giro limitado: al
-- principio se puede esquivar cerrando la curva) y lo hace avanzar
function powerups.guiarMisiles(E,dt)
    for _,p in ipairs(E.proyectiles) do
        if p.tipo==powerups.TIPO_MISIL and p.vida>=1 then
            local px,py=posicionDe(p)
            local mejor,md
            for _,j in ipairs(E.jugadores) do
                if j.equipo~=p.equipo and j.vida>=1 then
                    local jx,jy=posicionDe(j)
                    local d=(jx-px)^2+(jy-py)^2
                    if not md or d<md then mejor,md=j,d end
                end
            end
            if mejor then
                local jx,jy=posicionDe(mejor)
                local dif=normalizar(math.atan2(-(jx-px),jy-py)-p.angulo)
                local edad=powerups.DURACION_MISIL-p.vida
                local giro=p.magnitud/RADIO_GIRO_MISIL*(1+0.6*edad)*dt
                p.angulo=p.angulo+math.max(-giro,math.min(giro,dif))
            end
            local fx,fy=-math.sin(p.angulo),math.cos(p.angulo)
            if p.body then
                p.body:setLinearVelocity(fx*p.magnitud,fy*p.magnitud)
            else
                p.posX=p.posX+fx*p.magnitud*dt
                p.posY=p.posY+fy*p.magnitud*dt
            end
            -- puntos recientes para dibujar el humo
            p.estela=p.estela or {}
            table.insert(p.estela,1,{x=px,y=py})
            if #p.estela>14 then table.remove(p.estela) end
        end
    end
end

-- Humo y llama detras del misil; (x,y) es su posicion en pantalla
function powerups.dibujarEstelaMisil(p,x,y)
    local lg=love.graphics
    local ox,oy=x-p.posX,y-p.posY
    local estela=p.estela or {}
    for k,e in ipairs(estela) do
        local f=1-k/(#estela+1)
        lg.setColor(0.75,0.75,0.75,0.35*f)
        lg.circle("fill",e.x+ox,e.y+oy,3+5*(1-f))
    end
    local fx,fy=-math.sin(p.angulo),math.cos(p.angulo)
    local parpadeo=0.8+0.2*math.sin(reloj()*40)
    local c=powerups.TIPOS[MISIL].color
    lg.setColor(1,0.8,0.3,0.9)
    lg.circle("fill",x-fx*13,y-fy*13,5*parpadeo)
    lg.setColor(c[1],c[2],c[3],0.35)
    lg.circle("fill",x,y,13)
    lg.setColor(1,1,1,1)
end

-- Al reaparecer el tanque pierde todos los efectos
function powerups.reiniciar(ply)
    ply.efectos=ply.efectos or {}
    for tipo in pairs(ply.efectos) do quitar(ply,tipo) end
    local b=base(ply)
    ply.velocidad,ply.auvel,ply.danhomina,ply.multVelocidad=b.velocidad,b.auvel,b.danhomina,1
end

-- Puntos de sobreescudo que le quedan al tanque
function powerups.escudoRestante(ply)
    return math.max(0,ply.vida-VIDA_BASE)
end

------------------------------------------------------------------ red

-- Efectos en una lista plana para enviarlos por red:
-- {seq, ultimoTipo, valor del tipo 1, valor del tipo 2, ...} donde el valor
-- es el tiempo, las cargas o 1 (sobreescudo), y 0 si no esta activo
function powerups.codificar(ply)
    local e=ply.efectos or {}
    local function r1(x) return math.floor(x*10+0.5)/10 end
    local d={ply.seqPU or 0, ply.anuncio and ply.anuncio.tipo or 0}
    for tipo=1,#powerups.TIPOS do
        local v=0
        if e[tipo] then v=e[tipo].tiempo and r1(e[tipo].tiempo) or e[tipo].cargas or 1 end
        d[2+tipo]=v
    end
    return d
end

function powerups.decodificar(ply,d)
    if type(d)~="table" then return end
    local function num(v) return type(v)=="number" and v or 0 end
    local ef={}
    for tipo,def in ipairs(powerups.TIPOS) do
        local v=num(d[2+tipo])
        if v>0 then
            local anterior=ply.efectos and ply.efectos[tipo]
            if def.duracion then
                ef[tipo]={tiempo=v,total=def.duracion}
            elseif def.cargas then
                ef[tipo]={cargas=v,total=def.cargas}
            else
                ef[tipo]={}
            end
            if anterior then ef[tipo].aparicion=anterior.aparicion end
        end
    end
    ply.efectos=ef
    -- una recogida nueva en el anfitrion dispara la animacion aqui
    local seq,tipo=num(d[1]),num(d[2])
    if seq~=(ply.seqPU or 0) then
        ply.seqPU=seq
        if powerups.TIPOS[tipo] then powerups.anunciar(ply,tipo) end
    end
end

------------------------------------------------------------------ dibujo

-- Icono del power-up centrado en (x,y) con radio r, en el color actual
function powerups.icono(tipo,x,y,r)
    local lg=love.graphics
    if tipo==ENERGIA then
        -- rayo
        lg.polygon("fill",x+0.15*r,y-r, x-0.55*r,y+0.15*r, x-0.05*r,y+0.15*r, x-0.15*r,y+r,
            x+0.55*r,y-0.15*r, x+0.05*r,y-0.15*r)
    elseif tipo==ESCUDO then
        -- escudo
        lg.polygon("fill",x-0.75*r,y-0.8*r, x+0.75*r,y-0.8*r, x+0.75*r,y-0.05*r, x,y+r, x-0.75*r,y-0.05*r)
    elseif tipo==MINAS then
        -- mina con puas
        lg.circle("fill",x,y,r*0.55)
        lg.setLineWidth(math.max(1.5,r*0.18))
        for k=0,7 do
            local a=k*math.pi/4
            lg.line(x+math.cos(a)*r*0.45,y+math.sin(a)*r*0.45,x+math.cos(a)*r*0.95,y+math.sin(a)*r*0.95)
        end
        lg.setLineWidth(1)
    elseif tipo==MISIL then
        -- cohete apuntando arriba
        lg.polygon("fill",x,y-r, x+0.35*r,y-0.45*r, x+0.35*r,y+0.45*r, x-0.35*r,y+0.45*r, x-0.35*r,y-0.45*r)
        lg.polygon("fill",x-0.35*r,y+0.05*r, x-0.75*r,y+0.6*r, x-0.35*r,y+0.45*r)
        lg.polygon("fill",x+0.35*r,y+0.05*r, x+0.75*r,y+0.6*r, x+0.35*r,y+0.45*r)
        lg.polygon("fill",x-0.2*r,y+0.55*r, x+0.2*r,y+0.55*r, x,y+r)
    elseif tipo==TURBO then
        -- doble flecha
        for k=0,1 do
            local dx=(k-0.5)*0.75*r
            lg.polygon("fill",x+dx-0.45*r,y-0.8*r, x+dx-0.05*r,y-0.8*r, x+dx+0.5*r,y,
                x+dx-0.05*r,y+0.8*r, x+dx-0.45*r,y+0.8*r, x+dx+0.1*r,y)
        end
    end
end

local function setColor(c,a)
    love.graphics.setColor(c[1],c[2],c[3],a or 1)
end

-- Caja del mapa en coordenadas de pantalla (x,y)
function powerups.dibujarCaja(pw,x,y)
    local lg=love.graphics
    local def=powerups.TIPOS[pw.tipo] or powerups.TIPOS[ENERGIA]
    local t=reloj()
    if pw.vida>60 then
        -- halo que late, caja flotando e icono girando lento encima
        local pulso=0.5+0.5*math.sin(t*4+pw.posX)
        local flota=math.sin(t*3+pw.posY)*3
        setColor(def.color,0.18+0.17*pulso)
        lg.circle("fill",x,y,26+5*pulso)
        setColor(def.color,0.8)
        lg.setLineWidth(2)
        lg.circle("line",x,y,24+5*pulso)
        lg.setLineWidth(1)
        lg.setColor(1,1,1,1)
        lg.draw(caja,x,y+flota,0,1.15,1.15,14,14)
        lg.setColor(0,0,0,0.55)
        lg.circle("fill",x,y+flota,11)
        setColor(def.color)
        powerups.icono(pw.tipo,x,y+flota,8)
    else
        -- reapareciendo: base apagada con un anillo que se va llenando
        local falta=math.max(0,pw.vida-1)/59
        lg.setColor(0,0,0,0.35)
        lg.circle("fill",x,y,18)
        lg.setColor(1,1,1,0.25)
        lg.setLineWidth(3)
        lg.circle("line",x,y,18)
        lg.setColor(1,1,1,0.75)
        lg.arc("line","open",x,y,18,-math.pi/2,-math.pi/2+2*math.pi*(1-falta))
        lg.setLineWidth(1)
        lg.setColor(1,1,1,0.8)
        lg.printf(tostring(math.ceil(pw.vida)),fuente,x-20,y-fuente:getHeight()/2,40,"center")
    end
    lg.setColor(1,1,1,1)
end

-- Empieza la animacion de recogida sobre el tanque
function powerups.anunciar(ply,tipo)
    ply.anuncio={tipo=tipo,inicio=reloj()}
    ply.efectos=ply.efectos or {}
    if ply.efectos[tipo] then ply.efectos[tipo].aparicion=reloj() end
end

-- Efectos visibles sobre el tanque (escudo, turbo) y animacion de recogida.
-- Se llama despues de dibujar el tanque, con su posicion en pantalla.
function powerups.dibujarJugador(ply,x,y)
    local lg=love.graphics
    local t=reloj()
    local ef=ply.efectos or {}
    if ef[ESCUDO] and ply.vida>VIDA_BASE then
        local c=powerups.TIPOS[ESCUDO].color
        local fuerza=math.min(1,powerups.escudoRestante(ply)/100)
        setColor(c,0.12+0.1*fuerza)
        lg.circle("fill",x,y,34)
        setColor(c,0.35+0.4*fuerza+0.1*math.sin(t*6))
        lg.setLineWidth(2)
        lg.circle("line",x,y,34)
        lg.setLineWidth(1)
    end
    if ef[TURBO] then
        local c=powerups.TIPOS[TURBO].color
        setColor(c,0.5)
        lg.setLineWidth(2)
        local a=t*8
        lg.arc("line","open",x,y,30,a,a+1.2)
        lg.arc("line","open",x,y,30,a+math.pi,a+math.pi+1.2)
        lg.setLineWidth(1)
    end
    local an=ply.anuncio
    if an then
        local p=(t-an.inicio)/DURACION_ANUNCIO
        if p>=1 or p<0 then
            ply.anuncio=nil
        else
            local def=powerups.TIPOS[an.tipo]
            -- onda que se expande desde el tanque
            local onda=math.min(1,p*2.5)
            setColor(def.color,(1-onda)*0.9)
            lg.setLineWidth(4*(1-onda)+1)
            lg.circle("line",x,y,20+60*onda)
            lg.setLineWidth(1)
            -- icono y nombre que suben y se desvanecen
            local entra=math.min(1,p*6)
            local escala=1+0.6*(1-entra)
            local alfa=p<0.7 and 1 or (1-p)/0.3
            local iy=y-44-24*p
            lg.setColor(0,0,0,0.6*alfa)
            lg.circle("fill",x,iy,15*escala)
            setColor(def.color,alfa)
            lg.setLineWidth(2)
            lg.circle("line",x,iy,15*escala)
            lg.setLineWidth(1)
            powerups.icono(an.tipo,x,iy,9*escala)
            local w=fuente:getWidth(def.nombre)
            lg.setColor(0,0,0,0.6*alfa)
            lg.print(def.nombre,fuente,x-w/2+1,iy-38+1)
            setColor(def.color,alfa)
            lg.print(def.nombre,fuente,x-w/2,iy-38)
        end
    end
    lg.setColor(1,1,1,1)
end

return powerups
