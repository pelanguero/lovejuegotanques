local entidadesTS={jugadores={},proyectiles={},powerUps={},spawns={},ancho=850,alto=850,puntuaciones={}}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"}
local proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}
local ssangulo=math.rad(90)
local cbs=60
local mcbs=cbs/2
local calavera=love.graphics.newImage("//assets/skull.png")
function entidadesTS.agregarEquipo()
local equipo={}
table.insert(entidadesTS.equipos, equipo)
end
hud =require"hud"

function entidadesTS.agregarSpawn(spx,spy)
local spawn={}
spawn.x=spx
spawn.y=spy
table.insert( entidadesTS.spawns,spawn )
end
--tipo:1=tanque de energia plus,2=Sobreescudo,3=modificador de minas,4=velocidad plus

function entidadesTS.agregarPowerUp(pwx,pwy)
    local tipo=math.random(1,4)
    local pw={}
    pw.x=pwx
    pw.y=pwy
    pw.tipo=tipo
    table.insert( entidadesTS.powerUps,pw)
end

--equipo,--entidad=posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg
function entidadesTS.agregarJugador(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg)
    local  ju={}
    if entidadesTS.puntuaciones[nEqu]==nil then
        local ro={}
        ro.puntos=0
        table.insert( entidadesTS.puntuaciones,ro)
    end
    ju.equipo=nEqu
    ju.posX=posX
    ju.posY=posY
    ju.strimagen=tanques[nEqu]
    ju.imagen=love.graphics.newImage(ju.strimagen)
    ju.angulo=angulo
    ju.magnitud=magnitud
    ju.danho=danho
    ju.vida=vida
    ju.powerup=powerUp
    ju.medX=medX
    ju.medY=medY
    ju.tamanho=tamanho
    ju.energia=100
    ju.limite=100
    ju.ratio=50
    ju.eqimpac=0
    ju.spawnear=true
    table.insert( entidadesTS.jugadores,ju)
    print("jugadorAgregado")   
end


function entidadesTS.agregarProyectil(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho)
    local  ju={}
    ju.equipo=nEqu
    ju.posX=posX
    ju.posY=posY
    ju.strimagen=proyectiles[nEqu]
    ju.imagen=love.graphics.newImage(ju.strimagen)
    ju.angulo=angulo
    ju.magnitud=magnitud
    ju.danho=danho
    ju.vida=vida
    ju.powerup=powerUp
    ju.medX=medX
    ju.medY=medY
    ju.tamanho=tamanho
    table.insert( entidadesTS.proyectiles,ju)
end

function entidadesTS.disparar(rrr)
    --crea un proyectil con el angulo y direccion
    local px=rrr.posX-24*math.cos(rrr.angulo-ssangulo)
    local py=rrr.posY-24*math.sin(rrr.angulo-ssangulo)
    --nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
    if rrr.energia>90 then
        entidadesTS.agregarProyectil(rrr.equipo,px,py,1,nil,rrr.angulo,300,50,10,"ninguno",4,7,1)
        --rrr.energia=rrr.energia-90
    end
end

function entidadesTS.eliminarProyectiles(limitex,limitey)
    if #entidadesTS.proyectiles>0 then
        for i=1,#entidadesTS.proyectiles do
            if entidadesTS.proyectiles[i]~=nil then
                local prro=entidadesTS.proyectiles[i].posX>limitex or #entidadesTS.proyectiles[i].posX<0
                local qrro=entidadesTS.proyectiles[i].posY>limitey or #entidadesTS.proyectiles[i].posY<0
                local errd=prro or qrro
                if errd or entidadesTS.proyectiles[i].vida<1 then
                    table.remove( entidadesTS.proyectiles,i)
                end
            end
        end
    end
end

function entidadesTS.actualizarProyectiles(dt)
    if #entidadesTS.proyectiles>0 then
        for i=1,#entidadesTS.proyectiles do 
            entidadesTS.proyectiles[i].posY=entidadesTS.proyectiles[i].posY-entidadesTS.proyectiles[i].magnitud*math.sin(entidadesTS.proyectiles[i].angulo-ssangulo)*dt
            entidadesTS.proyectiles[i].posX=entidadesTS.proyectiles[i].posX-entidadesTS.proyectiles[i].magnitud*math.cos(entidadesTS.proyectiles[i].angulo-ssangulo)*dt
        end
    end
end

function entidadesTS.actualizarJugadores(dt)

end


function entidadesTS.estaDentro(exx,eyy,entt)
    local retorno=false
    local erer=entt.posX>exx and entt.posX<exx+entidadesTS.ancho
    local rr=entt.posY>eyy and entt.posY<eyy+entidadesTS.ancho

    if rr and erer then
    retorno=true
    end

    return retorno
end

function entidadesTS.detectarColision(dt)
    --jugadores v proyectiles
    for i=1,#entidadesTS.jugadores do
        for j=1,#entidadesTS.proyectiles do
            if entidadesTS.proyectiles[j].equipo~=entidadesTS.jugadores[i].equipo then
                local corX=entidadesTS.jugadores[i].posX-mcbs
                local corY=entidadesTS.jugadores[i].posY-mcbs
                local sx=corX<entidadesTS.proyectiles[j].posX and corX+cbs>entidadesTS.proyectiles[j].posX
                local sy=corY<entidadesTS.proyectiles[j].posY and corY+cbs>entidadesTS.proyectiles[j].posY
                if sx and sy then
                    entidadesTS.jugadores[i].vida=entidadesTS.jugadores[i].vida-entidadesTS.proyectiles[j].danho*dt
                    entidadesTS.jugadores[i].eqimpac=entidadesTS.proyectiles[j].equipo
                    entidadesTS.proyectiles[j].vida=entidadesTS.proyectiles[j].vida-entidadesTS.jugadores[i].danho*dt
                end
            end
        end
    end
    --jugadores v powerUPs
end

function entidadesTS.matarJugadores()
    for i=1,#entidadesTS.jugadores do
        if entidadesTS.jugadores[i].vida<1 then
            entidadesTS.puntuaciones[entidadesTS.jugadores[i].eqimpac]=entidadesTS.puntuaciones[entidadesTS.jugadores[i].eqimpac]+1
            if entidadesTS.jugadores[i].spawnear then
            entidadesTS.spawnearJugadores(entidadesTS.jugadores[i])
            else
            entidadesTS.jugadores[i].imagen=calavera
            entidadesTS.jugadores[i].magnitud=0    
            end
        end
    end
end

function entidadesTS.spawnearJugadores(ent)
    ent.posX=entidadesTS.spawns[ent.equipo].x
    ent.posY=entidadesTS.spawns[ent.equipo].y
    ent.energia=100
    ent.limite=100
    ent.ratio=50
    ent.eqimpac=0
    
end



function entidadesTS.dibujar(eex,eey,canv)
    

    --dibuja a los jugadores
    for i=1,#entidadesTS.jugadores do
            if entidadesTS.estaDentro(eex,eey,entidadesTS.jugadores[i]) then
                if canv~=nil then
                    love.graphics.setCanvas(canv)
                end
                local fx=entidadesTS.jugadores[i].posX-eex
                local fy=entidadesTS.jugadores[i].posY-eey
                love.graphics.draw(entidadesTS.jugadores[i].imagen,fx,fy,entidadesTS.jugadores[i].angulo,entidadesTS.jugadores[i].tamanho,entidadesTS.jugadores[i].tamanho,entidadesTS.jugadores[i].medX,entidadesTS.jugadores[i].medY,0,0)
                --dibuja la caja de colision
                love.graphics.setCanvas()
            end
        
    end

    --dibuja a los proyectiles
    for i=1,#entidadesTS.proyectiles do
        if entidadesTS.estaDentro(eex,eey,entidadesTS.proyectiles[i]) then
            if canv~=nil then
                love.graphics.setCanvas(canv)
            end
            local fx=entidadesTS.proyectiles[i].posX-eex
            local fy=entidadesTS.proyectiles[i].posY-eey
            love.graphics.draw(entidadesTS.proyectiles[i].imagen,fx,fy,entidadesTS.proyectiles[i].angulo,entidadesTS.proyectiles[i].tamanho,entidadesTS.proyectiles[i].tamanho,entidadesTS.proyectiles[i].medX,entidadesTS.proyectiles[i].medY,0,0)
            --dibuja la caja de colision
            love.graphics.setCanvas()
        end
    
    end
    ----------------------------------------------------------------------------
    if love.keyboard.isDown("c") then
        hud.dibujar(1,entidadesTS.jugadores[1],canv)
    end
end    
return entidadesTS