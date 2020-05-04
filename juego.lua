
--terreno, jugador
local juego={ hud=require"hud",map=require "mapa",capas={},exd=0,eyd=0,ex=0,ey=0,angulo=0,magnitud=54,entidades=require "entidades",mapd=require "mapad",modo=1,jugadord=require "jugador",sscanvas=nil,ssdcanvas=nil,mdx=0,mdy=0}
local tanques={tanqueR="tank_red.png",tanqueA="tank_blue.png",tanqueV="tank_green.png",tanqueN="tank_dark.png",tanqueGR="tank_bigRed.png",tanqueGO="tank_darkLarge.png",tanqueH="tank_huge.png",tanqueS="tank_sand.png"}
local ssangulo = math.rad(90)
function juego:agregarcapa(per)
table.insert(juego.capas,per)

end
hud=require"hud"
function juego:new()
    -- body
    juego.map.new("mapadeprueba")
    juego:agregarcapa(juego.map)
    juego.calcularmdn(nil)
    juego.entidades.agregar(1,940,940,tanques.tanqueN,0,500,10,100,"ninguno",1)    
    juego.agregarcapa(juego.entidades)
end


function juego:calcularmdn(cvs)
if cvs==nil then 
juego.mdx=400
juego.mdy=300
else
    juego.mdx=cvs.getWidth/2
    juego.mdy=cvs.getHeight/2
end

end


function juego.cambiarModo()
    if juego.modo==1 then
        juego.modo=2 
        love.window.setMode(1200, 600, {resizable=false, vsync=true})
        juego.mapd.new("mapadeprueba")
        juego.entidades.agregar(1,512,828,tanques.tanqueS,0,500,30,100,"ninguno",1)
        juego.sscanvas=love.graphics.newCanvas(600,600)
        juego.ssdcanvas=love.graphics.newCanvas(600,600)
        juego.mdx=300
        juego.mdy=300
    else
        juego.modo=1
        love.window.setMode(800, 600, {resizable=false, vsync=true})
    end
end

function juego.camara(entidad,canvasss)
local xsx=juego.entidades.entidadess[entidad].posX-juego.mdx
if xsx<0 then 
xsx=0
end
local ysy=juego.entidades.entidadess[entidad].posY-juego.mdy
if ysy<0 then 
    ysy=0
end
if canvasss==nil then
juego.map.dibujar(xsx,ysy)
else
    juego.mapd.dibujar(xsx,ysy,canvasss)
end
juego.entidades.dibujar(xsx,ysy,canvasss)


end


function juego:dibujarCapas()

if juego.modo==1 then
      juego.camara(1,nil)
else
    juego.camara(1,juego.sscanvas)
    juego.camara(2,juego.ssdcanvas)
    love.graphics.draw(juego.sscanvas)
    love.graphics.draw(juego.ssdcanvas,600,0)    
end

--love.graphics.draw(juego.tank,379,268,juego.angulo,1,1,21,23,0,0)
end

function juego.disparar(rrr)    
    
    if rrr.energia>90 then
        juego.entidades.agregar(2,rrr.posX-24*math.cos(rrr.angulo-ssangulo),rrr.posY-24*math.sin(rrr.angulo-ssangulo),"bulletDark1_outline.png",rrr.angulo,800,20,10,"ninguno",1)
        rrr.energia=rrr.energia-90
    end
end

function juego.procesarCo()
    if #juego.entidades.entidadess>0 and #juego.entidades.entidadesG>0 then
        for i=1,#juego.entidades.entidadess do
            local rnx=juego.entidades.entidadess[i].posX-juego.entidades.entidadess[i].medX
            local rny=juego.entidades.entidadess[i].posY-juego.entidades.entidadess[i].medY
            for j=1,#juego.entidades.entidadesG do
                local conx=rnx<juego.entidades.entidadesG[j].posX and rnx+23>juego.entidades.entidadesG[j].posX
                local cony=rny<juego.entidades.entidadesG[j].posY and rny+23>juego.entidades.entidadesG[j].posY
                if  conx and cony then
                    juego.entidades.entidadess[i].vida=juego.entidades.entidadess[i].vida-juego.entidades.entidadesG[j].danho
                    juego.entidades.entidadesG[j].vida=juego.entidades.entidadesG[j].vida-juego.entidades.entidadess[i].danho
                end
            end
        end
    end
end

function juego.procesarEnt(dt)
    print(juego.entidades.entidadess[1].vida)
if #juego.entidades.entidadess>0 then
for i=1,#juego.entidades.entidadess do
    if juego.entidades.entidadess[i].vida<1 then
        juego.entidades.morir(juego.entidades.entidadess[i])
    end   
    juego.entidades.entidadess[i].energia=juego.entidades.entidadess[i].energia+200*dt
    if juego.entidades.entidadess[i].energia>juego.entidades.entidadess[i].limite then
        juego.entidades.entidadess[i].energia=juego.entidades.entidadess[i].limite
    end
    
end
end
if #juego.entidades.entidadesG>0 then
for i=1,#juego.entidades.entidadesG do 
    juego.entidades.entidadesG[i].posY=juego.entidades.entidadesG[i].posY-juego.entidades.entidadesG[i].magnitud*math.sin(juego.entidades.entidadesG[i].angulo-ssangulo)*dt
    juego.entidades.entidadesG[i].posX=juego.entidades.entidadesG[i].posX-juego.entidades.entidadesG[i].magnitud*math.cos(juego.entidades.entidadesG[i].angulo-ssangulo)*dt
     
end
for i=1,#juego.entidades.entidadesG do
    if juego.entidades.entidadesG[i]~=nil then
    if juego.entidades.entidadesG[i].posY>juego.map.anchoo or juego.entidades.entidadesG[i].posY<0 then
        table.remove(juego.entidades.entidadesG,i)
    elseif juego.entidades.entidadesG[i].posX>juego.map.anchoo or juego.entidades.entidadesG[i].posX<0 then
        table.remove(juego.entidades.entidadesG,i)
    end 
    end
end
end
end

function juego.procesarInput(dt)
    --juego.hud=juego.modo
    
    if love.keyboard.isDown("y") then
      hud.modo=2  
    juego.cambiarModo()
    end    
    if love.keyboard.isDown("w") then
        local tempy=juego.entidades.entidadess[1].posY-juego.entidades.entidadess[1].magnitud*math.sin(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if tempy<23 then
            juego.entidades.entidadess[1].posY=23
        else 
            juego.entidades.entidadess[1].posY=tempy
        end
        local tempx=juego.entidades.entidadess[1].posX-juego.entidades.entidadess[1].magnitud*math.cos(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if tempx<21 then
            juego.entidades.entidadess[1].posX=21
        else
            juego.entidades.entidadess[1].posX=tempx
        end
    elseif love.keyboard.isDown("s") then
        local tempy=juego.entidades.entidadess[1].posY+juego.entidades.entidadess[1].magnitud*math.sin(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if tempy<23 then
        juego.entidades.entidadess[1].posY=23
        else
            juego.entidades.entidadess[1].posY=tempy
        end
        local tempx=juego.entidades.entidadess[1].posX+juego.entidades.entidadess[1].magnitud*math.cos(juego.entidades.entidadess[1].angulo-ssangulo)*dt
        if tempx<21 then
        juego.entidades.entidadess[1].posX=21
        else
            juego.entidades.entidadess[1].posX=tempx
        end
    
    elseif love.keyboard.isDown("a") then
        juego.entidades.entidadess[1].angulo=juego.entidades.entidadess[1].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown("d") then
        juego.entidades.entidadess[1].angulo=juego.entidades.entidadess[1].angulo+math.rad(100)*dt
    elseif love.keyboard.isDown("q") then
        juego.disparar(juego.entidades.entidadess[1])
    end

    if love.keyboard.isDown("i") then
        juego.entidades.entidadess[2].posY=juego.entidades.entidadess[2].posY-juego.entidades.entidadess[2].magnitud*math.sin(juego.entidades.entidadess[2].angulo-ssangulo)*dt
        if juego.entidades.entidadess[2].posY<23 then
            juego.entidades.entidadess[2].posY=23
        end
        juego.entidades.entidadess[2].posX=juego.entidades.entidadess[2].posX-juego.entidades.entidadess[2].magnitud*math.cos(juego.entidades.entidadess[2].angulo-ssangulo)*dt
        if juego.entidades.entidadess[2].posX<21 then
            juego.entidades.entidadess[2].posX=21
        end
    elseif love.keyboard.isDown("k") then
        juego.entidades.entidadess[2].posY=juego.entidades.entidadess[2].posY+juego.entidades.entidadess[2].magnitud*math.sin(juego.entidades.entidadess[2].angulo-ssangulo)*dt
        if juego.entidades.entidadess[2].posY<23 then
        juego.entidades.entidadess[2].posY=23
        end
        juego.entidades.entidadess[2].posX=juego.entidades.entidadess[2].posX+juego.entidades.entidadess[2].magnitud*math.cos(juego.entidades.entidadess[2].angulo-ssangulo)*dt
        if juego.entidades.entidadess[2].posX<21 then
        juego.entidades.entidadess[2].posX=21
        end
    elseif love.keyboard.isDown("j") then
        juego.entidades.entidadess[2].angulo=juego.entidades.entidadess[2].angulo-math.rad(100)*dt
    elseif love.keyboard.isDown("l") then
        juego.entidades.entidadess[2].angulo=juego.entidades.entidadess[2].angulo+math.rad(100)*dt
    elseif love.keyboard.isDown("u") then
        juego.disparar(juego.entidades.entidadess[2])
    end
    hud.pmx=juego.entidades.entidadess[1].posX
    hud.pmy=juego.entidades.entidadess[1].posY
    if love.keyboard.isDown("m")then
        hud.pmx2=juego.entidades.entidadess[2].posX
        hud.pmy2=juego.entidades.entidadess[2].posY
        hud.dibujar(2)
        end
    
end
return juego

