--entidadess=jugadores, entidadesG=proyectiles,orbes,etc
local entidades={entidadess={},entidadesG={},ancho=850,alto=850}
hud = require("hud")

function entidades.agregar(tipo,pX,pY,stri,ang,mag,danh,vid,power,tamanh)
--entidad=posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
local ed={}
ed.posX=pX
ed.posY=pY

ed.strimagen=stri
ed.imagen=love.graphics.newImage(stri)
ed.angulo=ang
ed.magnitud=mag
ed.danho=danh
ed.vida=vid
ed.powerUp=power
ed.tamanho=tamanh
ed.energia=100
ed.limite=100

if tipo==1 then
  ed.medX=21
  ed.medY=23
  table.insert(entidades.entidadess,ed)
elseif tipo==2 then
  ed.medX=4
  ed.medY=7
  table.insert(entidades.entidadesG,ed)
end

end
function entidades.dibujar(eex,eey,canv)
  
  --eex,eey esquina superior izquierda de la camara
  if love.keyboard.isDown("m")then    
    hud.dibujar(2)
  end
  for i=1,#entidades.entidadess do
    if entidades.estaDentro(eex,eey,entidades.entidadess[i]) then
      if canv~=nil then
      love.graphics.setCanvas(canv)
      end
      local fx=entidades.entidadess[i].posX-eex
      local fy=entidades.entidadess[i].posY-eey
      love.graphics.draw(entidades.entidadess[i].imagen,fx,fy,entidades.entidadess[i].angulo,entidades.entidadess[i].tamanho,entidades.entidadess[i].tamanho,entidades.entidadess[i].medX,entidades.entidadess[i].medY,0,0)
      --dibuja la caja de colision
      local rnx=fx-entidades.entidadess[i].medX
      local rny=fy-juego.entidades.entidadess[i].medY
      love.graphics.polygon("line",rnx,rny,rnx+23,rny,rnx+23,rny+23,rnx,rny+23)
      love.graphics.setCanvas()
      
    end
  end
  for i=1,#entidades.entidadesG do
    if entidades.estaDentro(eex,eey,entidades.entidadesG[i]) then
      if canv~=nil then
      love.graphics.setCanvas(canv)
      end
      local fx=entidades.entidadesG[i].posX-eex
      local fy=entidades.entidadesG[i].posY-eey
      love.graphics.draw(entidades.entidadesG[i].imagen,fx,fy,entidades.entidadesG[i].angulo,entidades.entidadesG[i].tamanho,entidades.entidadesG[i].tamanho,entidades.entidadesG[i].medX,entidades.entidadesG[i].medY,0,0)
      love.graphics.setCanvas()
    end
  end
  
end

function entidades.morir(endd)
entidades.respawn(endd,640,640)
end

function entidades.respawn(entdd,npx,npy)
entdd.vida=100
entdd.posX=npx
entdd.posY=npy

end

function entidades.estaDentro(ax,ay,entidadd)
  local retorno=false
  if entidadd.posX-ax<entidades.ancho and entidadd.posY-ay<entidades.alto then
  retorno=true
  end
  return retorno
end


return entidades

