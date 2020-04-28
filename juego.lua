
--terreno, jugador
juego={map=require "mapa",capas={},ex=0,ey=0,angulo=0,tanque="tank_green.png",tank=nil,magnitud=54,jugador=require "jugador",entidades=require "entidades",hud=require "hud"}

function juego:agregarcapa(per)
table.insert(juego.capas,per)
end

function juego:new()
    -- body
    juego.tank=love.graphics.newImage(juego.tanque)
    juego.map.new("mapadeprueba..lua")    
    juego:agregarcapa(juego.map)
    juego.jugador.new(800,900,juego.tanque)    
    juego.entidades.agregar(juego.jugador)   
    juego.agregarcapa(juego.entidades)               
    
    

end

function juego:calcularexy()
local rex=juego.entidades.entidadess[1].posX-400
local rey=juego.entidades.entidadess[1].posY-300
if rex<0 then
   juego.ex=0
else
    juego.ex=rex
end
if rey<0 then
   juego.ey=0
else
    juego.ey=rey
end

end

function juego:dibujarCapas()
    juego.calcularexy()
    for i=1,table.maxn(juego.capas) do 
        juego.capas[i].dibujar(juego.ex,juego.ey)
        juego.hud.dibujar(juego.ex,juego.ey)
    end
    juego.entidades.dibujar(juego.ex,juego.ey)

--love.graphics.draw(juego.tank,379,268,juego.angulo,1,1,21,23,0,0)
end

return juego

