local entidadesTS={jugadores={},proyectiles={},ancho=850,alto=850}
local tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"}
local proyectiles={}
local ssangulo=math.rad(90)

function entidadesTS.agregarEquipo()
local equipo={}
table.insert(entidadesTS.equipos, equipo)
end

--equipo,--entidad=posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho
function entidadesTS.agregarJugador(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho)
local  ju={}
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
table.insert( entidadesTS.jugadores,ju)
print("jugadorAgregado")
end

function entidadesTS.agregarSjugador()

end

function entidadesTS.agregarProyectil(nEqu,posX,posY,strimagen,imagen,angulo,magnitud,danho,vida,powerUp,medX,medY,tamanho)
    local  ju={}
    ju.equipo=nEqu
    ju.posX=posX
    ju.posY=posY
    ju.strimagen=strimagen
    ju.imagen=love.graphics.newImage(strimagen)
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

function entidadesTS.eliminarProyectiles(limitex,limitey)
    if #entidadesTS.proyectiles>0 then
        for i=1,#entidadesTS.proyectiles do
            if entidadesTS.proyectiles[i]~=nil then
                local prro=entidadesTS.proyectiles[i].posX>limitex or #entidadesTS.proyectiles[i].posX<0
                local qrro=entidadesTS.proyectiles[i].posY>limitey or #entidadesTS.proyectiles[i].posY<0
                if prro or qrro then
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

function entidadesTS.estaDentro(exx,eyy,entt)
    local retorno=false
    local erer=entt.posX>exx and entt.posX<exx+entidadesTS.ancho
    local rr=entt.posY>eyy and entt.posY<eyy+entidadesTS.ancho

    if rr and erer then
    retorno=true
    end

    return retorno
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

end    
return entidadesTS