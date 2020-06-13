local entidadesTeamtest={entidades={},puntuaciones={},efectos={},spawns={},tanques=nil,imagenes={},mundo=nil,proyectiles=nil}
entidadesTeamtest.tanques ={"//assets/tanques/tank_dark.png","//assets/tanques/tank_red.png","//assets/tanques/tank_green.png"} 
entidadesTeamtest.mundo = love.physics.newWorld(0,0,true)
entidadesTeamtest.proyectiles={"//assets/proyectiles/bulletDark1_outline.png","//assets/proyectiles/bulletRed1_outline.png","//assets/proyectiles/bulletGreen1_outline.png"}

function agregarJugador(jugadorX,jugadorY,jugador)
    -- body
end