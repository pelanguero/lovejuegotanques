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

-- Linea divisoria entre las vistas de pantalla dividida
function hud.divisor(ancho,alto)
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(4)
    love.graphics.line(math.floor(ancho/2),0,math.floor(ancho/2),alto)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1)
end

return hud
