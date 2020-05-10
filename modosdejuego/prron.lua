local prron={mapa=nil,subcanvas=nil,drwmapa=nil}
local ancho = 0
local alto = 0
local escalax =0
local escalay =0

function  prron.new(pmapa)
    -- deberia recibir como parametro el tamaño de la pantalla (pmapa,x,y)
    ancho=pmapa.tablamapa.width*64
    alto=pmapa.tablamapa.height*64
    escalax=600/ancho
    escalay=600/alto
    local subcanvas=love.graphics.newCanvas(ancho,alto)
    pmapa.dibujar(0,0,ancho,alto,subcanvas)
    prron.drwmapa=love.graphics.newImage(subcanvas:newImageData())

end

function prron.dibujar(xx,yy)
    if love.keyboard.isDown("v") then
        love.graphics.setColor(255,255,255,0.7)
        love.graphics.draw(prron.drwmapa,300,0,0,escalax,escalay,0,0,0,0)
        love.graphics.setColor(255,0,0,0.7)
        love.graphics.rectangle("line",xx*escalax+300,yy*escalay,1200*escalax,600*escalay)
        love.graphics.setColor(255,255,255)
    end
end

return prron