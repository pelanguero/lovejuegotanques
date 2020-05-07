local entidadesTS={jugadores={},proyectiles={},powerUps={},spawns={},ancho=850,alto=850,puntuaciones={}}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"}
local proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}
local mina=love.graphics.newImage("//assets/mina.png")
local ssangulo=math.rad(90)
local cbs=60
local mcbs=cbs/2
local calavera=love.graphics.newImage("//assets/skull.png")
local particulas=love.graphics.newImage("//assets/explosion3.png")
function entidadesTS.agregarEquipo()
local equipo={}
table.insert(entidadesTS.equipos, equipo)
end

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
    pw.vida=60
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
    ju.ratio=15
    ju.eqimpac=0
    ju.spawnear=true
    ju.danhomina=50
    ju.danhoproyectil=20
    table.insert( entidadesTS.jugadores,ju)
    print("jugadorAgregado")
end


function entidadesTS.agregarProyectil(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,tipo)
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
    ju.tipo=tipo
    if tipo==2 then
    ju.imagen=mina
    end
    table.insert( entidadesTS.proyectiles,ju)
end

function entidadesTS.disparar(rrr)
    --crea un proyectil con el angulo y direccion
    local px=rrr.posX-24*math.cos(rrr.angulo-ssangulo)
    local py=rrr.posY-24*math.sin(rrr.angulo-ssangulo)
    --nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
    if rrr.energia>rrr.danhoproyectil then
        entidadesTS.agregarProyectil(rrr.equipo,px,py,1,nil,rrr.angulo,300,rrr.danhoproyectil,10,"ninguno",4,7,1,1)
        rrr.energia=rrr.energia-rrr.danhoproyectil
    end
end

function entidadesTS.plantarMina(rrr)
    if rrr.energia>rrr.danhomina then
        entidadesTS.agregarProyectil(rrr.equipo,rrr.posX,rrr.posY,1,nil,0,0,rrr.danhomina,10,"ninguno",12,12,1,2)
        rrr.energia=rrr.energia-rrr.danhomina
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
            if  entidadesTS.proyectiles[i]~=nil then
            if  entidadesTS.proyectiles[i].vida<1 then
            table.remove( entidadesTS.proyectiles, i)
            end
            end
        end

        for i=1,#entidadesTS.proyectiles do 
            if entidadesTS.proyectiles[i].tipo ==1 then
            entidadesTS.proyectiles[i].posY=entidadesTS.proyectiles[i].posY-entidadesTS.proyectiles[i].magnitud*math.sin(entidadesTS.proyectiles[i].angulo-ssangulo)*dt
            entidadesTS.proyectiles[i].posX=entidadesTS.proyectiles[i].posX-entidadesTS.proyectiles[i].magnitud*math.cos(entidadesTS.proyectiles[i].angulo-ssangulo)*dt
            else
                entidadesTS.proyectiles[i].vida=entidadesTS.proyectiles[i].vida-1*dt
            end    
        end
    end
end

function entidadesTS.actualizarJugadores(dt)
    entidadesTS.matarJugadores()
    for i=1,#entidadesTS.jugadores do
        entidadesTS.jugadores[i].energia=entidadesTS.jugadores[i].energia+entidadesTS.jugadores[i].ratio*dt
        if entidadesTS.jugadores[i].energia>entidadesTS.jugadores[i].limite then
            entidadesTS.jugadores[i].energia=entidadesTS.jugadores[i].limite
        end
    end
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
                    entidadesTS.jugadores[i].vida=entidadesTS.jugadores[i].vida-entidadesTS.proyectiles[j].danho
                    entidadesTS.jugadores[i].eqimpac=entidadesTS.proyectiles[j].equipo
                    --print(entidadesTS.jugadores[i].eqimpac)
                    print(entidadesTS.jugadores[i].vida)
                    entidadesTS.proyectiles[j].vida=entidadesTS.proyectiles[j].vida-entidadesTS.jugadores[i].danho
                    print(entidadesTS.jugadores[i].vida)
                end
            end
        end
    end
    --jugadores v powerUPs
end

function entidadesTS.matarJugadores()
    for i=1,#entidadesTS.jugadores do
        if entidadesTS.jugadores[i].vida<1 then
            entidadesTS.puntuaciones[entidadesTS.jugadores[i].eqimpac].puntos=entidadesTS.puntuaciones[entidadesTS.jugadores[i].eqimpac].puntos+1
            if entidadesTS.jugadores[i].spawnear then
            entidadesTS.spawnearJugadores(entidadesTS.jugadores[i])
            else
            entidadesTS.jugadores[i].imagen=calavera
            entidadesTS.jugadores[i].magnitud=0   
            end
            print(entidadesTS.puntuaciones[1].puntos)
        end
    end
end

function entidadesTS.procesarColPow(pU,ply)
    if pU.tipo == 1 then
        ply.energia=300
        ply.limite=300
        ply.ratio=80
    elseif pU.tipo == 2 then
        ply.vida=200
    elseif pU.tipo == 3 then
        ply.danhomina=200
    elseif pU.tipo == 4 then
        ply.magnitud=500
    end
end

function entidadesTS.desactivarPu(tipo,ply)
    if tipo == 1 then
        if ply.energia>100 then
            ply.energia=100
        end
        ply.limite=100
        ply.ratio=50
    elseif tipo == 2 then
        if ply.vida>100 then
            ply.vida=100
        end
    elseif tipo == 3 then
        ply.danhomina=50
    elseif tipo == 4 then
        ply.magnitud=300
    end
end

function entidadesTS.spawnearJugadores(ent)
    ent.posX=entidadesTS.spawns[ent.equipo].x
    ent.posY=entidadesTS.spawns[ent.equipo].y
    ent.energia=100
    ent.limite=100
    ent.vida=100
    ent.ratio=50
end



function entidadesTS.dibujar(eex,eey,canv)
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
end  

return entidadesTS