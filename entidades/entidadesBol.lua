local entidadesBol={bolal={},jugadores={},proyectiles={},powerUps={},spawns={},banderas={},ancho=850,alto=850,puntuaciones={}}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"}
local proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}
local mina=love.graphics.newImage("//assets/mina.png")
local ssangulo=math.rad(90)
local cbs=60
local mcbs=cbs/2
local calavera=love.graphics.newImage("//assets/skull.png")
local particulas=love.graphics.newImage("//assets/explosion3.png")
local caja=love.graphics.newImage("//assets/crateMetal.png")
local cajam=love.graphics.newImage("//assets/crateWood.png")
function entidadesBol.agregarEquipo()
local equipo={}
table.insert(entidadesBol.equipos, equipo)
end

function entidadesBol.agregarSpawn(spx,spy)
    local spawn={}
    spawn.x=spx
    spawn.y=spy
    table.insert( entidadesBol.spawns,spawn )
end

function entidadesBol.agregarBola(spx,spy)
    local bola={}
    bandera.x=spx
    bandera.y=spy
    bandera.posX=spx
    bandera.posY=spy
    bandera.vida=12
    bandera.is=true
    bandera.jugador=0
    table.insert( entidadesBol.bola,bola)
end

function entidadesBol.resetBandera(band)
    band.jugador=0
    band.posX=band.x
    band.posY=band.y
    band.is=true
    bandera.vida=12
end    

--tipo:1=tanque de energia plus,2=Sobreescudo,3=modificador de minas,4=velocidad plus

function entidadesBol.agregarPowerUp(pwx,pwy)
    local tipo=math.random(1,4)
    local pw={}
    pw.posX=pwx
    pw.posY=pwy
    pw.vida=70
    pw.tipo=tipo
    table.insert( entidadesBol.powerUps,pw)
end

--equipo,--entidad=posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg
function entidadesBol.agregarJugador(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg)
    local  ju={}
    if entidadesBol.puntuaciones[nEqu]==nil then
        local ro={}
        ro.puntos=0
        table.insert( entidadesBol.puntuaciones,ro)
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
    ju.banderaa=false
    ju.band=0
    table.insert( entidadesBol.jugadores,ju)
    print("jugadorAgregado")
end


function entidadesBol.agregarProyectil(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,tipo)
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
    table.insert( entidadesBol.proyectiles,ju)
end

function entidadesBol.disparar(rrr)
    --crea un proyectil con el angulo y direccion
    local px=rrr.posX-24*math.cos(rrr.angulo-ssangulo)
    local py=rrr.posY-24*math.sin(rrr.angulo-ssangulo)
    --nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
    if rrr.energia>rrr.danhoproyectil then
        entidadesBol.agregarProyectil(rrr.equipo,px,py,1,nil,rrr.angulo,300,rrr.danhoproyectil,10,"ninguno",4,7,1,1)
        rrr.energia=rrr.energia-rrr.danhoproyectil
    end
end

function entidadesBol.plantarMina(rrr)
    if rrr.energia>rrr.danhomina then
        entidadesBol.agregarProyectil(rrr.equipo,rrr.posX,rrr.posY,1,nil,0,0,rrr.danhomina,10,"ninguno",12,12,1,2)
        rrr.energia=rrr.energia-rrr.danhomina
    end
end

function entidadesBol.eliminarProyectiles(limitex,limitey)
    if #entidadesBol.proyectiles>0 then
        for i=1,#entidadesBol.proyectiles do
            if entidadesBol.proyectiles[i]~=nil then
                local prro=entidadesBol.proyectiles[i].posX>limitex or #entidadesBol.proyectiles[i].posX<0
                local qrro=entidadesBol.proyectiles[i].posY>limitey or #entidadesBol.proyectiles[i].posY<0
                local errd=prro or qrro
                if errd or entidadesBol.proyectiles[i].vida<1 then
                    table.remove( entidadesBol.proyectiles,i)
                end
            end
        end
    end
end

function entidadesBol.actualizarProyectiles(dt)
    if #entidadesBol.proyectiles>0 then
        for i=1,#entidadesBol.proyectiles do
            if  entidadesBol.proyectiles[i]~=nil then
            if  entidadesBol.proyectiles[i].vida<1 then
            table.remove( entidadesBol.proyectiles, i)
            end
            end
        end

        for i=1,#entidadesBol.proyectiles do 
            if entidadesBol.proyectiles[i].tipo ==1 then
            entidadesBol.proyectiles[i].posY=entidadesBol.proyectiles[i].posY-entidadesBol.proyectiles[i].magnitud*math.sin(entidadesBol.proyectiles[i].angulo-ssangulo)*dt
            entidadesBol.proyectiles[i].posX=entidadesBol.proyectiles[i].posX-entidadesBol.proyectiles[i].magnitud*math.cos(entidadesBol.proyectiles[i].angulo-ssangulo)*dt
            else
                entidadesBol.proyectiles[i].vida=entidadesBol.proyectiles[i].vida-1*dt
            end    
        end
    end
    for i=1,#entidadesBol.powerUps do
        if entidadesBol.powerUps[i].vida<61 and entidadesBol.powerUps[i].vida>1 then
            entidadesBol.powerUps[i].vida=entidadesBol.powerUps[i].vida-1*dt
        elseif entidadesBol.powerUps[i].vida<1 then
            entidadesBol.powerUps[i].vida=70
        end
    end
end

function entidadesBol.actualizarJugadores(dt)
    entidadesBol.matarJugadores()
    for i=1,#entidadesBol.jugadores do
        entidadesBol.jugadores[i].energia=entidadesBol.jugadores[i].energia+entidadesBol.jugadores[i].ratio*dt
        if entidadesBol.jugadores[i].energia>entidadesBol.jugadores[i].limite then
            entidadesBol.jugadores[i].energia=entidadesBol.jugadores[i].limite
        end
    end
end


function entidadesBol.estaDentro(exx,eyy,entt,xa,ya)
    local retorno=false
    local erer=entt.posX>exx and entt.posX<exx+xa
    local rr=entt.posY>eyy and entt.posY<eyy+ya
    if rr and erer then
    retorno=true
    end

    return retorno
end

function entidadesBol.detectarColision(dt)
    --jugadores v proyectiles
    for i=1,#entidadesBol.jugadores do
        for j=1,#entidadesBol.proyectiles do
            if entidadesBol.proyectiles[j].equipo~=entidadesBol.jugadores[i].equipo then
                local corX=entidadesBol.jugadores[i].posX-mcbs
                local corY=entidadesBol.jugadores[i].posY-mcbs
                local sx=corX<entidadesBol.proyectiles[j].posX and corX+cbs>entidadesBol.proyectiles[j].posX
                local sy=corY<entidadesBol.proyectiles[j].posY and corY+cbs>entidadesBol.proyectiles[j].posY
                if sx and sy then
                    entidadesBol.jugadores[i].vida=entidadesBol.jugadores[i].vida-entidadesBol.proyectiles[j].danho
                    entidadesBol.jugadores[i].eqimpac=entidadesBol.proyectiles[j].equipo
                    --print(entidadesBol.jugadores[i].eqimpac)
                    print(entidadesBol.jugadores[i].vida)
                    entidadesBol.proyectiles[j].vida=entidadesBol.proyectiles[j].vida-entidadesBol.jugadores[i].danho
                    print(entidadesBol.jugadores[i].vida)
                end
            end
        end
    end
    --jugadores v powerUPs
    for i=1,#entidadesBol.jugadores do
        for j=1,#entidadesBol.powerUps do
            local corX=entidadesBol.jugadores[i].posX-mcbs
            local corY=entidadesBol.jugadores[i].posY-mcbs
            local sx=corX<entidadesBol.powerUps[j].posX and corX+cbs>entidadesBol.powerUps[j].posX
            local sy=corY<entidadesBol.powerUps[j].posY and corY+cbs>entidadesBol.powerUps[j].posY
            if sx and sy and entidadesBol.powerUps[j].vida>60 then
                entidadesBol.procesarColPow(entidadesBol.powerUps[j],entidadesBol.jugadores[i])
                entidadesBol.powerUps[j].vida=60
            end
        end
    end

    --jugadores v banderas

    for i=1,#entidadesBol.jugadores do
        for j=1,#entidadesBol.banderas do
            local corX=entidadesBol.banderas[j].posX-mcbs
            local corY=entidadesBol.banderas[j].posY-mcbs
            local sx=corX<entidadesBol.jugadores[i].posX and corX+cbs>entidadesBol.jugadores[i].posX
            local sy=corY<entidadesBol.jugadores[i].posY and corY+cbs>entidadesBol.jugadores[j].posY
            local cerd=sx and sy
            local ord= j~=entidadesBol.jugadores[i].equipo and entidadesBol.banderas[j].is
            local orr= entidadesBol.banderas[j].posX==entidadesBol.banderas[j].x and entidadesBol.banderas[j].posY==entidadesBol.banderas[j].y
            if cerd and ord  then 
                entidadesBol.banderas[j].is=false
                entidadesBol.jugadores[i].banderaa=true
                entidadesBol.jugadores[i].band=j
            elseif cerd and entidadesBol.jugadores[i].banderaa and orr then
                entidadesBol.puntos[entidadesBol.jugadores[i].equipo]=entidadesBol.puntos[entidadesBol.jugadores[i].equipo]+1
                entidadesBol.resetBandera(entidadesBol.banderas[entidadesBol.jugadores[i].band])
                entidadesBol.jugadores[i].banderaa=false
                entidadesBol.jugadores[i].band=0
            end
        end
    end



end

function entidadesBol.matarJugadores()
    for i=1,#entidadesBol.jugadores do
        if entidadesBol.jugadores[i].vida<1 then
            if entidadesBol.jugadores[i].spawnear then
            entidadesBol.spawnearJugadores(entidadesBol.jugadores[i])
            else
            entidadesBol.jugadores[i].imagen=calavera
            entidadesBol.jugadores[i].magnitud=0   
            end
            print(entidadesBol.puntuaciones[1].puntos)
        end
    end
end

function entidadesBol.procesarColPow(pU,ply)
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

function entidadesBol.desactivarPu(tipo,ply)
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

function entidadesBol.spawnearJugadores(ent)
    ent.posX=entidadesBol.spawns[ent.equipo].x
    ent.posY=entidadesBol.spawns[ent.equipo].y
    ent.energia=100
    ent.limite=100
    ent.vida=100
    ent.ratio=50
end



function entidadesBol.dibujar(eex,eey,canv,xa,ya)
    --dibuja a los proyectiles
    if canv~=nil then
        love.graphics.setCanvas(canv)
    end
    for i=1,#entidadesBol.proyectiles do
        if entidadesBol.estaDentro(eex,eey,entidadesBol.proyectiles[i],xa,ya) then
            local fx=entidadesBol.proyectiles[i].posX-eex
            local fy=entidadesBol.proyectiles[i].posY-eey
            love.graphics.draw(entidadesBol.proyectiles[i].imagen,fx,fy,entidadesBol.proyectiles[i].angulo,entidadesBol.proyectiles[i].tamanho,entidadesBol.proyectiles[i].tamanho,entidadesBol.proyectiles[i].medX,entidadesBol.proyectiles[i].medY,0,0)
            --dibuja la caja de colision
        end
    
    end
    
    --dibuja los power Ups
    for i=1,#entidadesBol.powerUps do
        if entidadesBol.estaDentro(eex,eey,entidadesBol.powerUps[i],xa,ya) then
            local fx=entidadesBol.powerUps[i].posX-eex
            local fy=entidadesBol.powerUps[i].posY-eey
            if entidadesBol.powerUps[i].vida>61 then
                love.graphics.draw(cajam,fx,fy,0,1,1,14,14,0,0)
            else
                --love.graphics.setColor(1,1,0)
                --math.rad(entidadesBol.powerUps[i].vida*60)
                love.graphics.arc("fill",fx,fy,30,0,math.rad(entidadesBol.powerUps[i].vida*6))
            end
        end
    end

    --dibuja banderas
    for i=1,#entidadesBol.banderas do
        --if #entidadesBol.banderas[i].is then
            --if entidadesBol.estaDentro(eex,eey,entidadesBol.banderas[i],xa,ya) then
                local fx=entidadesBol.banderas[i].posX-eex
                local fy=entidadesBol.banderas[i].posY-eey  
                love.graphics.draw(cajam,fx,fy,0,1,1,14,14,0,0)
            --end
        --end
    end

    --dibuja a los jugadores
    for i=1,#entidadesBol.jugadores do
            if entidadesBol.estaDentro(eex,eey,entidadesBol.jugadores[i],xa,ya) then
                local fx=entidadesBol.jugadores[i].posX-eex
                local fy=entidadesBol.jugadores[i].posY-eey
                love.graphics.draw(entidadesBol.jugadores[i].imagen,fx,fy,entidadesBol.jugadores[i].angulo,entidadesBol.jugadores[i].tamanho,entidadesBol.jugadores[i].tamanho,entidadesBol.jugadores[i].medX,entidadesBol.jugadores[i].medY,0,0)
                --dibuja la caja de colision
            end
    end
    love.graphics.setCanvas()
end  

return entidadesBol