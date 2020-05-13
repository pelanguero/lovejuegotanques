local mainmenu={}
local fuente="./assets/fuente/Platinum Sign Over.ttf"
local titulo=love.graphics.newText(fuente,"TANQUES 2D")
local opcionuno=love.graphics.newText(fuente,"JUGAR")
local imagen=love.graphics.newImage("./assets/Sample.png")
--local opciondos=love.graphics.newText(fuente,"")
local salir=love.graphics.newText(fuente,"SALIR")



function mainmenu.dibujar()
    love.graphics.draw(imagen,0,0,0)
    love.graphics.draw(titulo,400,100,0,100,100)
    love.graphics.draw(opcionuno,400,200,0,100,100)
    love.graphics.draw(salir,400,300,0,100,100)
end

function mainmenu.update()
    
    --if  then
    --end
end
return mainmenu