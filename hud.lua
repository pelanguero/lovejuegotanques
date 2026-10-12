-- Elementos de pantalla comunes a todos los modos de juego
local hud={}
local fuente=love.graphics.newFont("arial_/arial_narrow_7.ttf",22)
local coloresEquipo={{0.85,0.85,0.85},{1,0.45,0.4},{0.5,0.9,0.5},{0.5,0.7,1}}

-- Marcador centrado arriba: "Equipo 1  3  -  1  Equipo 2"
function hud.marcador(puntuaciones,ancho)
    local partes={}
    for i=1,#puntuaciones do
        partes[i]=love.graphics.newText(fuente,"Equipo "..i..": "..math.floor(puntuaciones[i].puntos))
    end
    local sep=30
    local total=-sep
    for i=1,#partes do total=total+partes[i]:getWidth()+sep end
    local x=math.floor((ancho-total)/2)
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill",x-14,6,total+28,fuente:getHeight()+8,6,6)
    for i=1,#partes do
        love.graphics.setColor(coloresEquipo[i] or {1,1,1})
        love.graphics.draw(partes[i],x,10)
        x=x+partes[i]:getWidth()+sep
    end
    love.graphics.setColor(1,1,1)
end

local fuentePeq=love.graphics.newFont("arial_/arial_narrow_7.ttf",18)
local fuenteAviso=love.graphics.newFont("arial_/arial_narrow_7.ttf",48)

-- Segunda linea bajo el marcador: ronda, rondas ganadas y meta o tiempo
function hud.estadoPartida(j)
    local partes={}
    local paraGanar=j.rondasParaGanar()
    if paraGanar>1 then
        table.insert(partes,"Ronda "..j.ronda)
        table.insert(partes,"Rondas "..j.rondasGanadas[1].." - "..j.rondasGanadas[2].." (gana con "..paraGanar..")")
    end
    if j.config.modo==1 then
        table.insert(partes,"Meta: "..j.meta().." muertes")
    elseif j.config.modo==2 then
        table.insert(partes,"Meta: "..j.meta().." capturas")
    else
        local t=math.ceil(j.tiempoRestante)
        table.insert(partes,string.format("Tiempo %d:%02d",math.floor(t/60),t%60))
    end
    local texto=love.graphics.newText(fuentePeq,table.concat(partes,"   |   "))
    local ancho=love.graphics.getWidth()
    local x=math.floor((ancho-texto:getWidth())/2)
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill",x-10,42,texto:getWidth()+20,texto:getHeight()+6,6,6)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(texto,x,45)
end

-- Mensaje grande en el centro (fin de ronda o de partida)
function hud.aviso(mensaje)
    local w,h=love.graphics.getDimensions()
    love.graphics.setColor(0,0,0,0.55)
    love.graphics.rectangle("fill",0,h/2-50,w,100)
    love.graphics.setColor(244/255,208/255,63/255)
    love.graphics.printf(mensaje,fuenteAviso,0,h/2-fuenteAviso:getHeight()/2,w,"center")
    love.graphics.setColor(1,1,1)
end

local powerups=require "powerups"
local fuentePU=love.graphics.newFont("arial_/arial_narrow_7.ttf",14)

-- Una ranura del indicador: icono con anillo de tiempo, puntos de cargas
-- o barra de escudo, y lo que queda escrito debajo
local function ranuraPowerUp(ply,tipo,e,x,y,t)
    local lg=love.graphics
    local def=powerups.TIPOS[tipo]
    local c=def.color
    local r=20
    -- aparece con un pequeno rebote al recogerlo
    local escala=1
    if e.aparicion then
        local p=(t-e.aparicion)/0.4
        if p>=0 and p<1 then escala=1+0.5*math.sin(p*math.pi)*(1-p) end
    end
    local fraccion,texto=1,""
    if e.tiempo then
        fraccion=math.max(0,e.tiempo/e.total)
        texto=string.format("%.0fs",math.ceil(e.tiempo))
    elseif e.cargas then
        fraccion=e.cargas/e.total
        texto="x"..e.cargas
    else
        local esc=powerups.escudoRestante(ply)
        fraccion=math.min(1,esc/def.escudo)
        texto=tostring(math.ceil(esc))
    end
    -- parpadea cuando esta por acabarse
    local alfa=1
    if e.tiempo and e.tiempo<3 then alfa=0.55+0.45*math.abs(math.sin(t*8)) end
    lg.push()
    lg.translate(x,y)
    lg.scale(escala)
    lg.setColor(0,0,0,0.65)
    lg.circle("fill",0,0,r+4)
    lg.setColor(c[1],c[2],c[3],0.25)
    lg.setLineWidth(4)
    lg.circle("line",0,0,r)
    lg.setColor(c[1],c[2],c[3],alfa)
    if e.cargas then
        -- un segmento por carga
        local seg=2*math.pi/e.total
        for k=0,e.cargas-1 do
            local a=-math.pi/2+k*seg
            lg.arc("line","open",0,0,r,a+0.12,a+seg-0.12)
        end
    elseif fraccion>0 then
        lg.arc("line","open",0,0,r,-math.pi/2,-math.pi/2+2*math.pi*fraccion)
    end
    lg.setLineWidth(1)
    powerups.icono(tipo,0,0,10)
    lg.pop()
    lg.setColor(0,0,0,0.6)
    local w=fuentePU:getWidth(texto)
    lg.rectangle("fill",x-w/2-4,y+r+6,w+8,fuentePU:getHeight()+2,4,4)
    lg.setColor(c[1],c[2],c[3],alfa)
    lg.print(texto,fuentePU,x-w/2,y+r+7)
end

-- Power-ups activos del tanque, abajo a la izquierda de su vista
function hud.powerups(ply,canvas,ancho,alto)
    if not ply or not ply.efectos or next(ply.efectos)==nil then return end
    if canvas then love.graphics.setCanvas(canvas) end
    local t=love.timer.getTime()
    local x=36
    local y=alto-52
    for tipo=1,#powerups.TIPOS do
        local e=ply.efectos[tipo]
        if e then
            ranuraPowerUp(ply,tipo,e,x,y,t)
            x=x+58
        end
    end
    love.graphics.setColor(1,1,1)
    if canvas then love.graphics.setCanvas() end
end

-- Linea divisoria entre las vistas de pantalla dividida
function hud.divisor(ancho,alto)
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(4)
    love.graphics.line(math.floor(ancho/2),0,math.floor(ancho/2),alto)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1)
end

return hud
