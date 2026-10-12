local entidadesCTF={jugadores={},proyectiles={},powerUps={},spawns={},banderas={},ancho=850,alto=850,puntuaciones={},particulas={}}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"}
local proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}
local mina=love.graphics.newImage("//assets/mina.png")
local ssangulo=math.rad(90)
local cbs=60
local world=love.physics.newWorld(0,0,false)
local mcbs=cbs/2
local calavera=love.graphics.newImage("//assets/skull.png")
local particulas=love.graphics.newImage("//assets/explosion3.png")
local llantas=love.graphics.newImage("//assets/tracksLarge.png")
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

local begin_contact_callback = function(fixture_a, fixture_b, contact)
    print("empezo colision")
end
  
local end_contact_callback = function(fixture_a, fixture_b, contact)
    print("termino colision")
end
  
world:setCallbacks(begin_contact_callback, end_contact_callback, nil, nil)

function entidadesCTF.actualizarphy(dt)
    world:update(dt)
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
    ju.eparticula=1
    ju.velocidad=magnitud
    ju.antvelocidad=25
    ju.auvel=100
    ju.input=anco
    ju.equipo=nEqu
    ju.posX=posX
    ju.posY=posY
    ju.rposX=0
    ju.rposY=0
    ju.strimagen=tanques[nEqu]
    ju.imagen=love.graphics.newImage(ju.strimagen)
    ju.angulo=angulo
    ju.magnitud=0
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
    ju.body=love.physics.newBody(world,ju.posX,ju.posY,"dynamic")
    --ju.body:setBullet(true)
    ju.shape=love.physics.newRectangleShape(40,40)
    ju.fixture=love.physics.newFixture(ju.body,ju.shape,1)
    table.insert( entidadesCTF.jugadores,ju)
    print(type(entidadesCTF.jugadores[#entidadesCTF.jugadores].input.adelante))
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

function entidadesCTF.keypressed( key,scancode,isrepeat)
    -- body
    for i=1,#entidadesCTF.jugadores do
        if key==entidadesCTF.jugadores[i].input.disparar then
            entidadesCTF.disparar(entidadesCTF.jugadores[i])
        end
        if key==entidadesCTF.jugadores[i].input.mina then
            entidadesCTF.plantarMina(entidadesCTF.jugadores[i])
        end
    end
end

function entidadesCTF.eliminarParticulas()
    for i=#entidadesCTF.particulas,1,-1 do
        if entidadesCTF.particulas[i].vida<=0 then
            table.remove(entidadesCTF.particulas,i)
        end
    end
end

function entidadesCTF.actualizarProyectiles(dt)
    entidadesCTF.eliminarParticulas()
    for i=1,#entidadesCTF.particulas do
        entidadesCTF.particulas[i].vida=entidadesCTF.particulas[i].vida-1*dt
    end
    -- elimina balas y minas agotadas (recorrido inverso para no saltar elementos)
    for i=#entidadesCTF.proyectiles,1,-1 do
        if entidadesCTF.proyectiles[i].vida<1 then
            table.remove(entidadesCTF.proyectiles,i)
        end
    end
    for i=1,#entidadesCTF.proyectiles do
        local p=entidadesCTF.proyectiles[i]
        if p.tipo==1 then
            p.posY=p.posY-p.magnitud*math.sin(p.angulo-ssangulo)*dt
            p.posX=p.posX-p.magnitud*math.cos(p.angulo-ssangulo)*dt
        end
        -- balas y minas duran `vida` segundos
        p.vida=p.vida-1*dt
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

function entidadesCTF.actualizarJugadorTeclado(dt,pllayer)
    pllayer.posY=pllayer.body:getY()
    pllayer.posX=pllayer.body:getX()
    pllayer.posY=pllayer.posY-pllayer.magnitud*math.sin(pllayer.angulo-ssangulo)*dt
        pllayer.posX=pllayer.posX-pllayer.magnitud*math.cos(pllayer.angulo-ssangulo)*dt
        --restar valores absolutos podria ser mejor
        if pllayer.magnitud>0 then
            pllayer.magnitud=pllayer.magnitud-pllayer.antvelocidad*dt
        elseif pllayer.magnitud<0 then
            pllayer.magnitud=pllayer.magnitud+pllayer.antvelocidad*dt
        end
        if love.keyboard.isDown(pllayer.input.adelante) then
            pllayer.magnitud=pllayer.magnitud+pllayer.auvel*dt
            if pllayer.magnitud>pllayer.velocidad then
                pllayer.magnitud=pllayer.velocidad
            end
        elseif love.keyboard.isDown(pllayer.input.atras) then
            pllayer.magnitud=pllayer.magnitud-pllayer.auvel*dt-20*dt
            if pllayer.magnitud<-pllayer.velocidad then
                pllayer.magnitud=-pllayer.velocidad
            end
        elseif love.keyboard.isDown(pllayer.input.izquierda) then
            pllayer.angulo=pllayer.angulo-math.rad(100)*dt
        elseif love.keyboard.isDown(pllayer.input.derecha) then
            pllayer.angulo=pllayer.angulo+math.rad(100)*dt
        end
        
        pllayer.energia=pllayer.energia+pllayer.ratio*dt
        if pllayer.energia>pllayer.limite then
            pllayer.energia=pllayer.limite
        end
        pllayer.eparticula=pllayer.eparticula+1*dt
        if pllayer.eparticula>1 then
            pllayer.eparticula=1
        end
        if pllayer.magnitud == pllayer.velocidad and pllayer.eparticula>=1 then
            entidadesCTF.añadirParticulas(pllayer,10)
            pllayer.eparticula=pllayer.eparticula-9.4*dt
        end
        
        pllayer.body:setX(pllayer.posX)
        pllayer.body:setY(pllayer.posY)
end

function entidadesCTF.actualizarJugadores(dt,joys)
    entidadesCTF.matarJugadores()
    for i=1,#entidadesCTF.jugadores do
        if entidadesCTF.jugadores[i].input.joystick then
            --entidadesCTF.actualizarJugadorMando(dt,entidadesCTF.jugadores[i])
        else
            entidadesCTF.actualizarJugadorTeclado(dt,entidadesCTF.jugadores[i])
            --print(joys[1]:getAxis(1))
        end
    end
end

function entidadesCTF.añadirParticulas(jugadorr,duracion)
    local ju={}
    ju.posX=jugadorr.posX
    ju.posY=jugadorr.posY
    ju.angulo=jugadorr.angulo
    ju.vida=duracion
    ju.vidamax=duracion+0
    table.insert( entidadesCTF.particulas, ju)
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
    ent.body:setLinearVelocity(0,0)
    ent.magnitud=0
    ent.body:setX(entidadesCTF.spawns[ent.equipo].x)
    ent.body:setY(entidadesCTF.spawns[ent.equipo].y)
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

    for i=1,#entidadesCTF.particulas do
        if entidadesCTF.estaDentro(eex,eey,entidadesCTF.particulas[i],xa,ya) then
            local fx=entidadesCTF.particulas[i].posX-eex
            local fy=entidadesCTF.particulas[i].posY-eey
            love.graphics.setColor(255,255,255,entidadesCTF.particulas[i].vida/entidadesCTF.particulas[i].vidamax)
            love.graphics.draw(llantas,fx,fy,entidadesCTF.particulas[i].angulo,1,1,20,26,0,0)
            --dibuja la caja de colision
        end
    
    end

    love.graphics.setColor(255,255,255,1)

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


    love.graphics.setCanvas()
end  

return entidadesCTF