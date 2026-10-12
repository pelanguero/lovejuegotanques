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

-- Linea divisoria entre las vistas de pantalla dividida
function hud.divisor(ancho,alto)
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(4)
    love.graphics.line(math.floor(ancho/2),0,math.floor(ancho/2),alto)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1)
end

return hud
