local entidadesTS={jugadores={},proyectiles={},powerUps={},spawns={},ancho=850,alto=850,puntuaciones={},particulas={},pantallas={}}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png","//assets/tanques/tank_blue.png"}
local proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}
local proyectilesImages={love.graphics.newImage(proyectiles[1]),love.graphics.newImage(proyectiles[2]),love.graphics.newImage(proyectiles[3]),love.graphics.newImage(proyectiles[4])}
local mascaras={tonumber("1110",2),tonumber("1101",2),tonumber("1011",2),tonumber("0111",2)}
local categorias={tonumber("0001",2),tonumber("0010",2),tonumber("0100",2),tonumber("1000",2)}
local mina=love.graphics.newImage("//assets/mina.png")
local ssangulo=math.rad(90)
local cbs=60
local mcbs=cbs/2
local world=love.physics.newWorld(0,0,false)
local calavera=love.graphics.newImage("//assets/skull.png")
local llantas=love.graphics.newImage("//assets/tracksLarge.png")
local particulas=love.graphics.newImage("//assets/explosion3.png")
local caja=love.graphics.newImage("//assets/crateMetal.png")
function entidadesTS.agregarEquipo()
local equipo={}
table.insert(entidadesTS.equipos, equipo)
end

local begin_contact_callback = function(fixture_a, fixture_b, contact)
    print("empezo colision")
end
  
local end_contact_callback = function(fixture_a, fixture_b, contact)
    print("termino colision")
end
  
world:setCallbacks(begin_contact_callback, end_contact_callback, nil, nil)

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
    pw.posX=pwx
    pw.posY=pwy
    pw.vida=70
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
    ju.eparticula=1
    ju.velocidad=magnitud
    ju.antvelocidad=25
    ju.auvel=100
    ju.input=anco
    ju.equipo=nEqu
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
    ju.body=love.physics.newBody(world,posX,posY,"dynamic")
    ju.body:setMass(20)
    --ju.body:setBullet(true)
    ju.shape=love.physics.newRectangleShape(40,40)
    ju.fixture=love.physics.newFixture(ju.body,ju.shape,1)
    ju.categoria=categorias[ju.equipo]
    ju.mascara=mascaras[ju.equipo]
    ju.posX=ju.body:getX()
    ju.posY=ju.body:getY()
    ju.fixture:setFilterData(ju.categoria, ju.mascara,0)
    ju.fixture:setUserData(ju)
    table.insert( entidadesTS.jugadores,ju)
    print(type(entidadesTS.jugadores[#entidadesTS.jugadores].input.adelante))
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
    ju.body=love.physics.newBody(world,posX,posY,"dynamic")
    ju.body:setBullet(true)
    ju.body:setMass(1)
    if tipo==2 then
        ju.imagen=mina
        ju.shape=love.physics.newCircleShape(12)
    else
        ju.shape=love.physics.newRectangleShape(8,14)
    end
    ju.fixture=love.physics.newFixture(ju.body,ju.shape,1)
    ju.categoria=categorias[ju.equipo]
    ju.mascara=mascaras[ju.equipo]
    ju.fixture:setFilterData(ju.categoria, ju.mascara,0)
    ju.fixture:setUserData(ju)
    ju.body:setLinearVelocity(-magnitud*math.cos(ju.angulo-ssangulo),-magnitud*math.sin(ju.angulo-ssangulo))
    ju.posX=ju.body:getX()
    ju.posY=ju.body:getY()
    table.insert( entidadesTS.proyectiles,ju)
end

function entidadesTS.disparar(rrr)
    --crea un proyectil con el angulo y direccion
    local px=rrr.body:getX()-24*math.cos(rrr.angulo-ssangulo)
    local py=rrr.body:getY()-24*math.sin(rrr.angulo-ssangulo)
    --nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
    if rrr.energia>rrr.danhoproyectil then
        entidadesTS.agregarProyectil(rrr.equipo,px,py,1,nil,rrr.angulo,300,rrr.danhoproyectil,10,"ninguno",4,7,1,1)
        rrr.energia=rrr.energia-rrr.danhoproyectil
    end
end

function entidadesTS.plantarMina(rrr)
    if rrr.energia>rrr.danhomina then
        entidadesTS.agregarProyectil(rrr.equipo,rrr.body:getX(),rrr.body:getY(),1,nil,0,0,rrr.danhomina,10,"ninguno",12,12,1,2)
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

function entidadesTS.eliminarParticulas()
    if #entidadesTS.particulas>0 then
        for i=1,#entidadesTS.proyectiles do
            if entidadesTS.particulas[i]~=nil then
                if entidadesTS.proyectiles[i].vida<=0 then
                    table.remove( entidadesTS.particulas,i)
                end
            end
        end
    end
end

function entidadesTS.actualizarProyectiles(dt)
    entidadesTS.eliminarParticulas()
    for i=1,#entidadesTS.particulas do
       
        entidadesTS.particulas[i].vida=entidadesTS.particulas[i].vida-1*dt
    
    end
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
    for i=1,#entidadesTS.powerUps do
        if entidadesTS.powerUps[i].vida<61 and entidadesTS.powerUps[i].vida>1 then
            entidadesTS.powerUps[i].vida=entidadesTS.powerUps[i].vida-1*dt
        elseif entidadesTS.powerUps[i].vida<1 then
            entidadesTS.powerUps[i].vida=70
        end
    end
end
--[[
function entidadesTS.actualizarJugadorMando(dt,pllayer,jjoys)
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
        if jjoys[pllayer.input.njoystick]:getAxis(2)<0 and jjoys[pllayer.input.njoystick]:getAxis(2)~=0 then
            pllayer.magnitud=pllayer.magnitud+pllayer.auvel*dt
            if pllayer.magnitud>pllayer.velocidad then
                pllayer.magnitud=pllayer.velocidad
            end
        elseif jjoys[pllayer.input.njoystick]:getAxis(2)>0 and jjoys[pllayer.input.njoystick]:getAxis(2)~=0 then
            pllayer.magnitud=pllayer.magnitud-pllayer.auvel*dt-20*dt
            if pllayer.magnitud<-pllayer.velocidad then
                pllayer.magnitud=-pllayer.velocidad
            end
        elseif jjoys[pllayer.input.njoystick]:getAxis(1)<0 and jjoys[pllayer.input.njoystick]:getAxis(1)~=0 then
            pllayer.angulo=pllayer.angulo-math.rad(100)*dt
        elseif jjoys[pllayer.input.njoystick]:getAxis(1)>0 and jjoys[pllayer.input.njoystick]:getAxis(1)~=0 then
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
            entidadesTS.añadirParticulas(pllayer,10)
            pllayer.eparticula=pllayer.eparticula-9.4*dt
        end
        if pllayer.banderaa then
            entidadesBol.puntuaciones[pllayer.equipo].puntos=entidadesBol.puntuaciones[pllayer.equipo].puntos+1*dt
        end
        pllayer.body:setX(pllayer.posX)
        pllayer.body:setY(pllayer.posY)
end
]]
function entidadesTS.actualizarJugadorTeclado(dt,pllayer)
        local limiteVelocidad=100
        local tempx,tempy=pllayer.body:getLinearVelocity()
        local magnitud=math.sqrt((tempx*tempx)+(tempy*tempy))
        --restar valores absolutos podria ser mejor
        
        if love.keyboard.isDown(pllayer.input.adelante) then
            if magnitud<limiteVelocidad then 
                pllayer.body:applyLinearImpulse((-250)*math.cos(pllayer.angulo-ssangulo)*dt,(-250)*math.sin(pllayer.angulo-ssangulo)*dt)
            end
        elseif love.keyboard.isDown(pllayer.input.atras) then
            if magnitud<limiteVelocidad then 
                pllayer.body:applyLinearImpulse((250)*math.cos(pllayer.angulo-ssangulo)*dt,(250)*math.sin(pllayer.angulo-ssangulo)*dt)
            end
        elseif love.keyboard.isDown(pllayer.input.izquierda) then
            pllayer.angulo=pllayer.angulo-math.rad(100)*dt
        elseif love.keyboard.isDown(pllayer.input.derecha) then
            pllayer.angulo=pllayer.angulo+math.rad(100)*dt
            if tempx>0 then
                pllayer.body:applyLinearImpulse(-30*dt,0)
            else
                pllayer.body:applyLinearImpulse(30*dt,0)
            end
            if tempy>0 then
                pllayer.body:applyLinearImpulse(0,-30*dt)
            else
                pllayer.body:applyLinearImpulse(0,30*dt)
            end
        else
        if tempx>0 then
            pllayer.body:applyLinearImpulse(-100*dt,0)
        else
            pllayer.body:applyLinearImpulse(100*dt,0)
        end
        if tempy>0 then
            pllayer.body:applyLinearImpulse(0,-100*dt)
        else
            pllayer.body:applyLinearImpulse(0,100*dt)
        end
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
            entidadesTS.añadirParticulas(pllayer,10)
            pllayer.eparticula=pllayer.eparticula-9.4*dt
        end
        if pllayer.banderaa then
            entidadesBol.puntuaciones[pllayer.equipo].puntos=entidadesBol.puntuaciones[pllayer.equipo].puntos+1*dt
        end
end

function entidadesTS.joystickpressed(jost,boton)
    for i=1,#entidadesTS.jugadores do
        if entidadesTS.jugadores[i].input.njoystick== jost:getConnectedIndex() then
            if boton==1 then
                entidadesTS.disparar(entidadesTS.jugadores[i])
            end
            if boton==2 then
                entidadesTS.plantarMina(entidadesTS.jugadores[i])
            end
        end
    end
end

function entidadesTS.actualizarphy(dt)
    world:update(dt)
end

function entidadesTS.actualizarJugadores(dt,joys)
    entidadesTS.matarJugadores()
    for i=1,#entidadesTS.jugadores do
        --[[if entidadesTS.jugadores[i].input.joystick then
            entidadesTS.actualizarJugadorMando(dt,entidadesTS.jugadores[i],joys)
        else]]
            entidadesTS.actualizarJugadorTeclado(dt,entidadesTS.jugadores[i])
            --print(joys[1]:getAxis(2))
        --end
    end
end

function entidadesTS.añadirParticulas(jugadorr,duracion)
    local ju={}
    ju.posX=jugadorr.body:getX()
    ju.posY=jugadorr.body:getY()
    ju.angulo=jugadorr.angulo
    ju.vida=duracion
    ju.vidamax=duracion+0
    table.insert( entidadesTS.particulas, ju)
end 

function entidadesTS.estaDentro(exx,eyy,entt,xa,ya)
    local retorno=false
    local erer=entt.posX>exx and entt.posX<exx+xa
    local rr=entt.posY>eyy and entt.posY<eyy+ya
    if rr and erer then
        retorno=true
    end

    return retorno
end

function entidadesTS.estaDentrod(exx,eyy,entt,xa,ya)
    local retorno=false
    local erer=entt.body:getX()>exx and entt.body:getX()<exx+xa
    local rr=entt.body:getY()>eyy and entt.body:getY()<eyy+ya
    if rr and erer then
    retorno=true
    end

    return retorno
end

function entidadesTS.detectarColision(dt)
    --jugadores v proyectiles
    
    --jugadores v powerUPs
    for i=1,#entidadesTS.jugadores do
        for j=1,#entidadesTS.powerUps do
            local corX=entidadesTS.jugadores[i].posX-mcbs
            local corY=entidadesTS.jugadores[i].posY-mcbs
            local sx=corX<entidadesTS.powerUps[j].posX and corX+cbs>entidadesTS.powerUps[j].posX
            local sy=corY<entidadesTS.powerUps[j].posY and corY+cbs>entidadesTS.powerUps[j].posY
            if sx and sy and entidadesTS.powerUps[j].vida>60 then
                entidadesTS.procesarColPow(entidadesTS.powerUps[j],entidadesTS.jugadores[i])
                entidadesTS.powerUps[j].vida=60
            end
        end
    end

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
    ent.body:setX(entidadesTS.spawns[ent.equipo].x)
    ent.body:setY(entidadesTS.spawns[ent.equipo].y)
    ent.posX=entidadesTS.spawns[ent.equipo].x
    ent.posY=entidadesTS.spawns[ent.equipo].y
    ent.banderaa=false
    ent.energia=100
    ent.limite=100
    ent.vida=100
    ent.ratio=50
end

function entidadesTS.keypressed( key,scancode,isrepeat)
    -- body
    for i=1,#entidadesTS.jugadores do
        if key==entidadesTS.jugadores[i].input.disparar then
            entidadesTS.disparar(entidadesTS.jugadores[i])
        end
        if key==entidadesTS.jugadores[i].input.mina then
            entidadesTS.plantarMina(entidadesTS.jugadores[i])
        end
    end
end

function entidadesTS.dibujar(eex,eey,canv,xa,ya)
    --dibuja a los proyectiles
    if canv~=nil then
        love.graphics.setCanvas(canv)
    end
     --dibuja los efectos
     for i=1,#entidadesTS.particulas do
        if entidadesTS.estaDentro(eex,eey,entidadesTS.particulas[i],xa,ya) then
            local fx=entidadesTS.particulas[i].posX-eex
            local fy=entidadesTS.particulas[i].posY-eey
            love.graphics.setColor(255,255,255,entidadesTS.particulas[i].vida/entidadesTS.particulas[i].vidamax)
            love.graphics.draw(llantas,fx,fy,entidadesTS.particulas[i].angulo,1,1,20,26,0,0)
            --dibuja la caja de colision
        end
    
    end

    love.graphics.setColor(255,255,255,1)

    for i=1,#entidadesTS.proyectiles do
        if entidadesTS.estaDentro(eex,eey,entidadesTS.proyectiles[i],xa,ya) then
            local fx=entidadesTS.proyectiles[i].posX-eex
            local fy=entidadesTS.proyectiles[i].posY-eey
            love.graphics.draw(entidadesTS.proyectiles[i].imagen,fx,fy,entidadesTS.proyectiles[i].angulo,entidadesTS.proyectiles[i].tamanho,entidadesTS.proyectiles[i].tamanho,entidadesTS.proyectiles[i].medX,entidadesTS.proyectiles[i].medY,0,0)
            --dibuja la caja de colision
        end
    
    end
    
    --dibuja los power Ups
    for i=1,#entidadesTS.powerUps do
        if entidadesTS.estaDentro(eex,eey,entidadesTS.powerUps[i],xa,ya) then
            local fx=entidadesTS.powerUps[i].posX-eex
            local fy=entidadesTS.powerUps[i].posY-eey
            if entidadesTS.powerUps[i].vida>61 then
                love.graphics.draw(caja,fx,fy,0,1,1,14,14,0,0)
            else
                --love.graphics.setColor(1,1,0)
                --math.rad(entidadesTS.powerUps[i].vida*60)
                love.graphics.arc("fill",fx,fy,30,0,math.rad(entidadesTS.powerUps[i].vida*6))
            end
        end
    end

    --dibuja a los jugadores
    for i=1,#entidadesTS.jugadores do
            if entidadesTS.estaDentrod(eex,eey,entidadesTS.jugadores[i],xa,ya) then
                local fx=entidadesTS.jugadores[i].body:getX()-eex
                local fy=entidadesTS.jugadores[i].body:getY()-eey
                love.graphics.draw(entidadesTS.jugadores[i].imagen,fx,fy,entidadesTS.jugadores[i].angulo,entidadesTS.jugadores[i].tamanho,entidadesTS.jugadores[i].tamanho,entidadesTS.jugadores[i].medX,entidadesTS.jugadores[i].medY,0,0)
                --dibuja la caja de colision
            end
    end
    love.graphics.setCanvas()
end  

return entidadesTS