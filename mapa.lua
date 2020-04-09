local mapa={}
local Rmapa
local Umapa={}
local spritesheet=""
Quads={}
prueba="abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMN"
local lspritesheet
local tille={}


function mapa.setup()
    lspritesheet=love.graphics.newImage(spritesheet)
    tilesize=64
    for i=1,10 do
        Quads[i]={}
        for a=1,4 do
          Quads[i][a]=love.graphics.newQuad(0*(i-1)*64,0*(a-1)*64,64,64,640,256)
        end
    end
    for j=1,string.len( prueba ) do
    tille[prueb[j]]=j
    end
end

function mapa.cargar(ruta)
    Rmapa=io.open(ruta,"r")
    local f=Rmapa:read("*line")
    local ind=1
    while f!=nil do
      Umapa[ind]=f
      f=Rmapa:read("*line")
    end 
    Rmapa:close()   
end

--poss se refiere a la esquina superior izquierda
function mapa.dibujar(poss)
--800,12.5
--600,9.375





end


return mapa