local entidadesCTF={jugadores={},proyectiles={},powerUps={},spawns={},banderas={},ancho=850,alto=850,puntuaciones={}}
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
function entidadesCTF.agregarEquipo()
local equipo={}

table.insert(entidadesCTF.equipos, equipo)
end

function entidadesCTF.agregarSpawn(spx,spy)
local spawn={}
spawn.x=spx
spawn.y=spy
table.insert( entidadesCTF.spawns,spawn )
end

function entidadesCTF.agregarBandera(spx,spy)
    local bandera={}
    bandera.x=spx
    bandera.y=spy
    bandera.posX=spx
    bandera.posY=spy
    bandera.vida=12
    bandera.is=true
    bandera.jugador=0
    bandera.equipo=#entidadesCTF.banderas+1
    print(bandera.equipo)
    table.insert(entidadesCTF.banderas,bandera)
end

function entidadesCTF.resetBandera(band)
    band.jugador=0
    band.posX=band.x
    band.posY=band.y
    band.is=true
    band.vida=12
end    

--tipo:1=tanque de energia plus,2=Sobreescudo,3=modificador de minas,4=velocidad plus

function entidadesCTF.agregarPowerUp(pwx,pwy)
    local tipo=math.random(1,4)
    local pw={}
    pw.posX=pwx
    pw.posY=pwy
    pw.vida=70
    pw.tipo=tipo
    table.insert( entidadesCTF.powerUps,pw)
end

--equipo,--entidad=posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg
function entidadesCTF.agregarJugador(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,anco,larg)
    local  ju={}
    if entidadesCTF.puntuaciones[nEqu]==nil then
        local ro={}
        ro.puntos=0
        table.insert( entidadesCTF.puntuaciones,ro)
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
    table.insert( entidadesCTF.jugadores,ju)
    print("jugadorAgregado")
end


function entidadesCTF.agregarProyectil(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho,tipo)
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
    table.insert( entidadesCTF.proyectiles,ju)
end
local son =require(".//sonido")
function entidadesCTF.disparar(rrr)
    --crea un proyectil con el angulo y direccion
    local px=rrr.posX-24*math.cos(rrr.angulo-ssangulo)
    local py=rrr.posY-24*math.sin(rrr.angulo-ssangulo)
    --nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
    if rrr.energia>rrr.danhoproyectil then
        entidadesCTF.agregarProyectil(rrr.equipo,px,py,1,nil,rrr.angulo,300,rrr.danhoproyectil,10,"ninguno",4,7,1,1)
        son.play(son.sun[3])
        rrr.energia=rrr.energia-rrr.danhoproyectil
    end
end

function entidadesCTF.plantarMina(rrr)
    if rrr.energia>rrr.danhomina then
        entidadesCTF.agregarProyectil(rrr.equipo,rrr.posX,rrr.posY,1,nil,0,0,rrr.danhomina,10,"ninguno",12,12,1,2)
        rrr.energia=rrr.energia-rrr.danhomina
        son.play(son.mina[1])
    end
end

function entidadesCTF.eliminarProyectiles(limitex,limitey)
    if #entidadesCTF.proyectiles>0 then
        for i=1,#entidadesCTF.proyectiles do
            if entidadesCTF.proyectiles[i]~=nil then
                local prro=entidadesCTF.proyectiles[i].posX>limitex or #entidadesCTF.proyectiles[i].posX<0
                local qrro=entidadesCTF.proyectiles[i].posY>limitey or #entidadesCTF.proyectiles[i].posY<0
                local errd=prro or qrro
                if errd or entidadesCTF.proyectiles[i].vida<1 then
                    table.remove( entidadesCTF.proyectiles,i)
                end
            end
        end
    end
end

function entidadesCTF.actualizarProyectiles(dt)
    if #entidadesCTF.proyectiles>0 then
        for i=1,#entidadesCTF.proyectiles do
            if  entidadesCTF.proyectiles[i]~=nil then
            if  entidadesCTF.proyectiles[i].vida<1 then
            table.remove( entidadesCTF.proyectiles, i)
            end
            end
        end

        for i=1,#entidadesCTF.proyectiles do 
            if entidadesCTF.proyectiles[i].tipo ==1 then
            entidadesCTF.proyectiles[i].posY=entidadesCTF.proyectiles[i].posY-entidadesCTF.proyectiles[i].magnitud*math.sin(entidadesCTF.proyectiles[i].angulo-ssangulo)*dt
            entidadesCTF.proyectiles[i].posX=entidadesCTF.proyectiles[i].posX-entidadesCTF.proyectiles[i].magnitud*math.cos(entidadesCTF.proyectiles[i].angulo-ssangulo)*dt
            else
                entidadesCTF.proyectiles[i].vida=entidadesCTF.proyectiles[i].vida-1*dt
            end    
        end
    end
    for i=1,#entidadesCTF.powerUps do
        if entidadesCTF.powerUps[i].vida<61 and entidadesCTF.powerUps[i].vida>1 then
            entidadesCTF.powerUps[i].vida=entidadesCTF.powerUps[i].vida-1*dt
        elseif entidadesCTF.powerUps[i].vida<1 then
            entidadesCTF.powerUps[i].vida=70
        end
    end

    for i=1,#entidadesCTF.banderas do
        if entidadesCTF.banderas[i].vida<0 then
            entidadesCTF.resetBandera(entidadesCTF.banderas[i])
        else
            local lol= entidadesCTF.banderas[i].posX~=entidadesCTF.banderas[i].x and entidadesCTF.banderas[i].posY~=entidadesCTF.banderas[i].y
            if entidadesCTF.banderas[i].is and lol then
                entidadesCTF.banderas[i].vida=entidadesCTF.banderas[i].vida-1*dt
            end
        end
    end

end

function entidadesCTF.actualizarJugadores(dt)
    entidadesCTF.matarJugadores()
    for i=1,#entidadesCTF.jugadores do
        entidadesCTF.jugadores[i].energia=entidadesCTF.jugadores[i].energia+entidadesCTF.jugadores[i].ratio*dt
        if entidadesCTF.jugadores[i].energia>entidadesCTF.jugadores[i].limite then
            entidadesCTF.jugadores[i].energia=entidadesCTF.jugadores[i].limite
        end
    end
end


function entidadesCTF.estaDentro(exx,eyy,entt,xa,ya)
    local retorno=false
    local erer=entt.posX>exx and entt.posX<exx+xa
    local rr=entt.posY>eyy and entt.posY<eyy+ya
    if rr and erer then
    retorno=true
    end

    return retorno
end

function entidadesCTF.detectarColision(dt)
    --jugadores v proyectiles
    for i=1,#entidadesCTF.jugadores do
        for j=1,#entidadesCTF.proyectiles do
            if entidadesCTF.proyectiles[j].equipo~=entidadesCTF.jugadores[i].equipo then
                local corX=entidadesCTF.jugadores[i].posX-mcbs
                local corY=entidadesCTF.jugadores[i].posY-mcbs
                local sx=corX<entidadesCTF.proyectiles[j].posX and corX+cbs>entidadesCTF.proyectiles[j].posX
                local sy=corY<entidadesCTF.proyectiles[j].posY and corY+cbs>entidadesCTF.proyectiles[j].posY
                if sx and sy then
                    entidadesCTF.jugadores[i].vida=entidadesCTF.jugadores[i].vida-entidadesCTF.proyectiles[j].danho
                    entidadesCTF.jugadores[i].eqimpac=entidadesCTF.proyectiles[j].equipo
                    --print(entidadesCTF.jugadores[i].eqimpac)
                    print(entidadesCTF.jugadores[i].vida)
                    entidadesCTF.proyectiles[j].vida=entidadesCTF.proyectiles[j].vida-entidadesCTF.jugadores[i].danho
                    son.play(son.imp[1])
                    print(entidadesCTF.jugadores[i].vida)
                end
            end
        end
    end
    --jugadores v powerUPs
    for i=1,#entidadesCTF.jugadores do
        for j=1,#entidadesCTF.powerUps do
            local corX=entidadesCTF.jugadores[i].posX-mcbs
            local corY=entidadesCTF.jugadores[i].posY-mcbs
            local sx=corX<entidadesCTF.powerUps[j].posX and corX+cbs>entidadesCTF.powerUps[j].posX
            local sy=corY<entidadesCTF.powerUps[j].posY and corY+cbs>entidadesCTF.powerUps[j].posY
            if sx and sy and entidadesCTF.powerUps[j].vida>60 then
                entidadesCTF.procesarColPow(entidadesCTF.powerUps[j],entidadesCTF.jugadores[i])
                entidadesCTF.powerUps[j].vida=60
            end
        end
    end

    --jugadores v banderas

    for j=1,#entidadesCTF.banderas do
        for i=1,#entidadesCTF.jugadores do
            local corX=entidadesCTF.banderas[j].posX-mcbs
            local corY=entidadesCTF.banderas[j].posY-mcbs
            local scorX=entidadesCTF.banderas[j].x-mcbs
            local scorY=entidadesCTF.banderas[j].y-mcbs
            local cerd=entidadesCTF.estaDentro(corX,corY,entidadesCTF.jugadores[i],cbs,cbs)
            local ord= entidadesCTF.banderas[j].equipo~=entidadesCTF.jugadores[i].equipo and entidadesCTF.banderas[j].is
            local orr= entidadesCTF.estaDentro(scorX,scorY,entidadesCTF.jugadores[i],cbs,cbs)
            if cerd and ord then 
                entidadesCTF.banderas[j].is=false
                entidadesCTF.jugadores[i].banderaa=true
                entidadesCTF.jugadores[i].band=entidadesCTF.banderas[j].equipo
                print("bandera tomada")
            elseif orr and entidadesCTF.jugadores[i].banderaa and entidadesCTF.banderas[j].equipo==entidadesCTF.jugadores[i].equipo  then
                entidadesCTF.puntuaciones[entidadesCTF.jugadores[i].equipo].puntos=entidadesCTF.puntuaciones[entidadesCTF.jugadores[i].equipo].puntos+1
                entidadesCTF.resetBandera(entidadesCTF.banderas[entidadesCTF.jugadores[i].band])
                entidadesCTF.jugadores[i].banderaa=false
                entidadesCTF.jugadores[i].band=0
            end
        end
    end



end

function entidadesCTF.matarJugadores()
    for i=1,#entidadesCTF.jugadores do
        if entidadesCTF.jugadores[i].vida<1 then
            son.play(son.dead[1])
            if entidadesCTF.jugadores[i].banderaa then
            entidadesCTF.banderas[entidadesCTF.jugadores[i].band].posX=entidadesCTF.jugadores[i].posX
            entidadesCTF.banderas[entidadesCTF.jugadores[i].band].posY=entidadesCTF.jugadores[i].posY
            entidadesCTF.banderas[entidadesCTF.jugadores[i].band].is=true
            end
            if entidadesCTF.jugadores[i].spawnear then
            entidadesCTF.spawnearJugadores(entidadesCTF.jugadores[i])
            else
            entidadesCTF.jugadores[i].imagen=calavera
            entidadesCTF.jugadores[i].magnitud=0   
            end
            print(entidadesCTF.puntuaciones[1].puntos)
        end
    end
end

function entidadesCTF.procesarColPow(pU,ply)
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

function entidadesCTF.desactivarPu(tipo,ply)
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

function entidadesCTF.spawnearJugadores(ent)
    ent.posX=entidadesCTF.spawns[ent.equipo].x
    ent.posY=entidadesCTF.spawns[ent.equipo].y
    ent.energia=100
    ent.limite=100
    ent.vida=100
    ent.ratio=50
end



function entidadesCTF.dibujar(eex,eey,canv,xa,ya)
    --dibuja a los proyectiles
    if canv~=nil then
        love.graphics.setCanvas(canv)
    end
    for i=1,#entidadesCTF.proyectiles do
        if entidadesCTF.estaDentro(eex,eey,entidadesCTF.proyectiles[i],xa,ya) then
            local fx=entidadesCTF.proyectiles[i].posX-eex
            local fy=entidadesCTF.proyectiles[i].posY-eey
            love.graphics.draw(entidadesCTF.proyectiles[i].imagen,fx,fy,entidadesCTF.proyectiles[i].angulo,entidadesCTF.proyectiles[i].tamanho,entidadesCTF.proyectiles[i].tamanho,entidadesCTF.proyectiles[i].medX,entidadesCTF.proyectiles[i].medY,0,0)
            --dibuja la caja de colision
        end
    
    end
    
    --dibuja los power Ups
    for i=1,#entidadesCTF.powerUps do
        if entidadesCTF.estaDentro(eex,eey,entidadesCTF.powerUps[i],xa,ya) then
            local fx=entidadesCTF.powerUps[i].posX-eex
            local fy=entidadesCTF.powerUps[i].posY-eey
            if entidadesCTF.powerUps[i].vida>61 then
                love.graphics.draw(caja,fx,fy,0,1,1,14,14,0,0)
            else
                love.graphics.setColor(0,255,0)
                --math.rad(entidadesCTF.powerUps[i].vida*60)
                love.graphics.arc("fill",fx,fy,30,0,math.rad(entidadesCTF.powerUps[i].vida*6))
                love.graphics.setColor(255,255,255)
            end
        end
    end

    --dibuja banderas
    for i=1,#entidadesCTF.banderas do
        if entidadesCTF.banderas[i].is then
            if entidadesCTF.estaDentro(eex,eey,entidadesCTF.banderas[i],xa,ya) then
                local fx=entidadesCTF.banderas[i].posX-eex
                local fy=entidadesCTF.banderas[i].posY-eey  
                love.graphics.draw(cajam,fx,fy,0,1,1,14,14,0,0)
            end
        end
    end

    --dibuja a los jugadores
    for i=1,#entidadesCTF.jugadores do
            if entidadesCTF.estaDentro(eex,eey,entidadesCTF.jugadores[i],xa,ya) then
                local fx=entidadesCTF.jugadores[i].posX-eex
                local fy=entidadesCTF.jugadores[i].posY-eey
                love.graphics.draw(entidadesCTF.jugadores[i].imagen,fx,fy,entidadesCTF.jugadores[i].angulo,entidadesCTF.jugadores[i].tamanho,entidadesCTF.jugadores[i].tamanho,entidadesCTF.jugadores[i].medX,entidadesCTF.jugadores[i].medY,0,0)
                --dibuja la caja de colision
            end
    end

    love.graphics.print(tostring(entidadesCTF.puntuaciones[1].puntos),50,500)
    love.graphics.print(tostring(entidadesCTF.puntuaciones[2].puntos),50,550)

    love.graphics.setCanvas()
end  

return entidadesCTF