-- Pruebas automaticas de los modos de juego.
-- Uso: love . --pruebas
-- Simula teclas y avanza el juego con un dt fijo; imprime OK/FALLA por
-- comprobacion y termina con codigo 1 si algo falla.
local juego = require "juego"
local pruebas = {}

local teclas = {}
local resultados = {}
local fallas = 0

local nombres = {"Team Slayer", "Capture The Flag", "King Of The Hill", "Crazy Ball"}
local DT = 1/60

local function pos(j) return j.body:getX(), j.body:getY() end

local function teleport(j, x, y)
    j.body:setPosition(x, y); j.body:setLinearVelocity(0, 0); j.posX, j.posY = x, y
end

-- avanza solo el modo (sin reglas de partida)
local function correrModo(m, seg)
    for _ = 1, math.floor(seg / DT) do m.proupdate(DT, {}) end
end

-- avanza la partida completa (rondas, tiempo, ganador)
local function correrPartida(seg, hasta)
    for _ = 1, math.floor(seg / DT) do
        juego.actualizar(DT, {})
        if hasta and hasta() then return end
    end
end

local function dibujar(m)
    love.graphics.setCanvas(love.graphics.newCanvas(1200, 600)); m.dibujar(); love.graphics.setCanvas()
end

local function check(modo, nombre, ok, detalle)
    if not ok then fallas = fallas + 1 end
    table.insert(resultados, string.format("%-18s %-38s %s %s", modo, nombre, ok and "OK   " or "FALLA", detalle or ""))
end

local function config(modo, extra)
    local c = {jugadores = 2, modo = modo, numMuertes = 20, capturas = 3, rondas = 1, time = 120}
    for k, v in pairs(extra or {}) do c[k] = v end
    return c
end

local function disparar(tecla) love.keypressed(tecla, tecla, false) end

-- j1 dispara a j2, que esta justo delante (angulo 0 = hacia abajo, +Y)
local function enfrentar(m)
    local E = m.entidades
    local j1, j2 = E.jugadores[1], E.jugadores[2]
    local w, h = m.mapa.tablamapa.width * 64, m.mapa.tablamapa.height * 64
    j1.angulo = 0; j2.angulo = 0
    teleport(j1, w/2, h/2); teleport(j2, w/2, h/2 + 120)
    j1.energia = 100
end

------------------------------------------------------------ mecanica de cada modo

local function probarMecanica(modo)
    local nm = nombres[modo]
    juego.nuevaPartida(config(modo), 1200, 600)
    interf.irA(interf.JUGANDO)
    local m = juego.mododejuego
    local E = m.entidades
    local j1, j2 = E.jugadores[1], E.jugadores[2]
    local mapaW, mapaH = m.mapa.tablamapa.width * 64, m.mapa.tablamapa.height * 64
    correrModo(m, 0.2)

    local x0, y0 = pos(j1)
    teclas.w = true; correrModo(m, 1); teclas.w = nil
    local x1, y1 = pos(j1)
    local d = math.sqrt((x1-x0)^2 + (y1-y0)^2)
    check(nm, "jugador 1 se mueve (W 1s)", d > 20, string.format("dist=%.0f", d))
    local okd, errd = pcall(dibujar, m)
    check(nm, "dibujar sin error", okd, errd)

    -- la bala recorre velBala por segundo
    enfrentar(m)
    teleport(j2, E.spawns[2].x, E.spawns[2].y)
    disparar("q")
    local bala = E.proyectiles[#E.proyectiles]
    local bx0, by0 = bala.posX, bala.posY
    correrModo(m, 0.5)
    local recorrido = math.sqrt((bala.posX - bx0)^2 + (bala.posY - by0)^2)
    check(nm, "bala a 600 px/s", math.abs(recorrido - 300) < 25, string.format("%.0f px en 0.5s", recorrido))

    -- tras acelerar y girar, el tanque avanza hacia donde apunta (sin derrapar)
    teleport(j1, mapaW/2, mapaH/2); j1.angulo = 0; j1.magnitud = 0
    teclas.w = true; correrModo(m, 2); teclas.w = nil
    teclas.a = true; correrModo(m, 0.6); teclas.a = nil
    teclas.w = true; correrModo(m, 0.2)
    local ax, ay = pos(j1); correrModo(m, 0.3); teclas.w = nil
    local bx, by = pos(j1)
    local dx, dy = bx - ax, by - ay
    local dd = math.sqrt(dx*dx + dy*dy)
    local alineado = dd > 1 and (dx * -math.sin(j1.angulo) + dy * math.cos(j1.angulo)) / dd or 0
    check(nm, "sin derrape: avanza hacia donde apunta", alineado > 0.98, string.format("alineacion=%.2f", alineado))

    enfrentar(m)
    local vida0 = j2.vida
    disparar("q"); correrModo(m, 0.6)
    check(nm, "disparo dana al rival", j2.vida < vida0, string.format("vida %s -> %s", vida0, j2.vida))

    enfrentar(m)
    local okm, errm = pcall(function()
        j2.vida = 5
        disparar("q"); correrModo(m, 0.6)
    end)
    local x2, y2 = pos(j2)
    local resp = math.abs(x2 - E.spawns[2].x) < 40 and math.abs(y2 - E.spawns[2].y) < 40
    check(nm, "muerte -> respawn sin crash", okm and resp,
        okm and string.format("vida=%s en (%.0f,%.0f)", j2.vida, x2, y2) or tostring(errm))
    if modo == 1 then
        check(nm, "muerte suma punto al equipo 1", E.puntuaciones[1].puntos >= 1, "puntos1=" .. tostring(E.puntuaciones[1].puntos))
    end

    if modo == 2 then
        local b2, b1 = E.banderas[2], E.banderas[1]
        teleport(j1, b2.posX, b2.posY); correrModo(m, 0.1)
        local tomada = j1.banderaa
        teleport(j1, b1.x, b1.y); correrModo(m, 0.1)
        check(nm, "capturar bandera suma punto", tomada and E.puntuaciones[1].puntos == 1,
            string.format("tomada=%s puntos=%s", tostring(tomada), E.puntuaciones[1].puntos))
    elseif modo == 3 then
        local c = E.colina[1]
        teleport(j2, E.spawns[2].x, E.spawns[2].y)
        teleport(j1, c.posX, c.posY); local p0 = E.puntuaciones[1].puntos; correrModo(m, 2)
        check(nm, "estar en la colina suma puntos", E.puntuaciones[1].puntos > p0 + 1,
            string.format("%.2f -> %.2f", p0, E.puntuaciones[1].puntos))
        teleport(j2, c.posX + 30, c.posY); local p1 = E.puntuaciones[1].puntos; correrModo(m, 1)
        check(nm, "colina disputada no suma", E.puntuaciones[1].puntos == p1,
            string.format("%.2f -> %.2f", p1, E.puntuaciones[1].puntos))
    elseif modo == 4 then
        local b = E.banderas[1]
        teleport(j2, E.spawns[2].x, E.spawns[2].y)
        teleport(j1, b.posX, b.posY); correrModo(m, 0.1)
        local p0 = E.puntuaciones[1].puntos; correrModo(m, 2)
        check(nm, "tener la bola suma puntos", j1.banderaa and E.puntuaciones[1].puntos > p0 + 1,
            string.format("tiene=%s %.2f -> %.2f", tostring(j1.banderaa), p0, E.puntuaciones[1].puntos))
    end

    teleport(j1, mapaW/2, mapaH/2); j1.angulo = 0
    teclas.w = true; correrModo(m, 20); teclas.w = nil
    local xf, yf = pos(j1)
    check(nm, "no sale del mapa (W 20s)", xf >= 0 and xf <= mapaW and yf >= 0 and yf <= mapaH,
        string.format("(%.0f,%.0f) mapa %dx%d", xf, yf, mapaW, mapaH))

    local oke, erre = pcall(function()
        for s = 1, 60 do
            teclas = {w = (s % 3 ~= 0) or nil, d = (s % 4 == 0) or nil, i = (s % 2 == 0) or nil, j = (s % 5 == 0) or nil}
            disparar("q"); disparar("u")
            if s % 7 == 0 then disparar("e") end
            correrModo(m, 1)
            if s % 10 == 0 then dibujar(m) end
        end
        teclas = {}
    end)
    check(nm, "60s de juego sin crash", oke, erre)
    check(nm, "proyectiles acotados", #E.proyectiles < 40, "#proyectiles=" .. #E.proyectiles)
    check(nm, "particulas acotadas", #E.particulas < 200, "#particulas=" .. #E.particulas)
end

------------------------------------------------------------ power-ups

local function probarPowerUps(modo)
    local nm = nombres[modo]
    local pu = require "powerups"
    local red = require "red"
    juego.nuevaPartida(config(modo), 1200, 600)
    local m = juego.mododejuego
    local E = m.entidades
    local j1, j2 = E.jugadores[1], E.jugadores[2]
    local mapaW, mapaH = m.mapa.tablamapa.width * 64, m.mapa.tablamapa.height * 64
    correrModo(m, 0.2)
    teleport(j2, E.spawns[2].x, E.spawns[2].y)

    -- recoger una caja
    local caja = E.powerUps[1]
    caja.tipo = pu.TURBO
    teleport(j1, caja.posX, caja.posY); correrModo(m, 0.1)
    check(nm, "recoger caja activa el efecto", j1.efectos[pu.TURBO] ~= nil and caja.vida <= 60 and j1.anuncio ~= nil,
        string.format("turbo=%s caja=%.1f", tostring(j1.efectos[pu.TURBO] ~= nil), caja.vida))

    -- el turbo acelera y se acaba solo
    local function recorrido()
        teleport(j1, mapaW/2, mapaH/2); j1.angulo = 0; j1.magnitud = 0
        local x0, y0 = pos(j1)
        teclas.w = true; correrModo(m, 2); teclas.w = nil
        local x1, y1 = pos(j1)
        return math.sqrt((x1-x0)^2 + (y1-y0)^2)
    end
    local conTurbo = recorrido()
    correrModo(m, pu.TIPOS[pu.TURBO].duracion)
    local sinTurbo = recorrido()
    check(nm, "turbo: mas rapido y expira", conTurbo > sinTurbo * 1.2 and j1.efectos[pu.TURBO] == nil,
        string.format("dist %.0f vs %.0f", conTurbo, sinTurbo))

    -- minas pesadas: 3 cargas
    teleport(j1, mapaW/2, mapaH/2)
    pu.aplicar(j1, pu.MINAS)
    j1.energia = 100
    disparar("e"); correrModo(m, 0.05)
    local ultima = E.proyectiles[#E.proyectiles]
    local fuerte = ultima and ultima.tipo == 2 and ultima.danho == 200
    for _ = 1, 2 do j1.energia = 100; disparar("e"); correrModo(m, 0.05) end
    check(nm, "minas pesadas gastan 3 cargas", fuerte and j1.efectos[pu.MINAS] == nil and j1.danhomina == 50,
        string.format("fuerte=%s danhomina=%s", tostring(fuerte), j1.danhomina))

    -- sobreescudo hasta perder la vida extra
    pu.aplicar(j1, pu.ESCUDO)
    local conEscudo = j1.vida == 200 and j1.efectos[pu.ESCUDO] ~= nil
    j1.vida = 90; correrModo(m, 0.05)
    check(nm, "sobreescudo se va con la vida extra", conEscudo and j1.efectos[pu.ESCUDO] == nil)

    -- misil: sale al disparar, va a 1.25x la velocidad maxima y persigue al rival
    teleport(j1, mapaW/2, mapaH/2); j1.angulo = 0
    teleport(j2, mapaW/2 + 250, mapaH/2 + 60)
    j2.vida = 100
    pu.aplicar(j1, pu.MISIL)
    j1.energia = 100
    local n0 = #E.proyectiles
    disparar("q"); correrModo(m, 0.05)
    local misil = E.proyectiles[#E.proyectiles]
    local esMisil = #E.proyectiles > n0 and misil.tipo == pu.TIPO_MISIL
    local esperada = 1.25 * E.velMaxJugador
    check(nm, "misil: velocidad 1.25x del tanque", esMisil and math.abs(misil.magnitud - esperada) < 0.01
        and j1.efectos[pu.MISIL].cargas == 1,
        string.format("misil=%s vel=%s esperada=%s", tostring(esMisil), tostring(misil and misil.magnitud), esperada))
    -- el rival esta a un lado: una bala recta no le daria
    local vida0 = j2.vida
    for _ = 1, math.floor(5 / DT) do
        teleport(j2, mapaW/2 + 250, mapaH/2 + 60)
        m.proupdate(DT, {})
        if j2.vida < vida0 then break end
    end
    check(nm, "misil persigue y golpea al rival", j2.vida == vida0 - pu.DANHO_MISIL,
        string.format("vida %s -> %s", vida0, j2.vida))
    j1.energia = 100; disparar("q"); correrModo(m, 0.05)
    local segundo = E.proyectiles[#E.proyectiles]
    j1.energia = 100; disparar("q"); correrModo(m, 0.05)
    local tercero = E.proyectiles[#E.proyectiles]
    check(nm, "misil: 2 cargas y luego balas normales", segundo.tipo == pu.TIPO_MISIL and tercero.tipo == 1
        and j1.efectos[pu.MISIL] == nil and tercero.magnitud == E.velBala)
    teleport(j2, E.spawns[2].x, E.spawns[2].y)

    -- todos los efectos activos: dibujar mapa, tanque, misil y HUD
    for t = 1, #pu.TIPOS do pu.aplicar(j1, t) end
    j1.energia = 100; disparar("q"); correrModo(m, 0.2)
    local okd, errd = pcall(dibujar, m)
    check(nm, "dibujar con todos los efectos activos", okd, errd)

    -- por red: el cliente ve los mismos efectos y la animacion
    local copia = {vida = j1.vida}
    pu.decodificar(copia, red.decodificar(red.codificar(pu.codificar(j1))))
    local iguales = copia.anuncio ~= nil
    for t = 1, #pu.TIPOS do iguales = iguales and (copia.efectos[t] ~= nil) end
    check(nm, "efectos viajan por red", iguales)

    -- morir borra los efectos
    j1.vida = 0; correrModo(m, 0.05)
    check(nm, "al reaparecer no quedan efectos", next(j1.efectos) == nil and j1.limite == 100
        and (j1.multVelocidad or 1) == 1, "limite=" .. tostring(j1.limite))

    -- la caja reaparece
    caja.vida = 1.5; correrModo(m, 1)
    check(nm, "caja reaparece con tipo valido", caja.vida > 60 and pu.TIPOS[caja.tipo] ~= nil,
        string.format("vida=%.1f tipo=%s", caja.vida, tostring(caja.tipo)))
end

------------------------------------------------------------ reglas de victoria

local function terminado() return juego.estado ~= "jugando" end

local function probarVictoria()
    -- Team Slayer: la muerte numero numMuertes da la partida
    local nm = nombres[1]
    juego.nuevaPartida(config(1, {numMuertes = 20}), 1200, 600)
    local m = juego.mododejuego
    m.entidades.puntuaciones[1].puntos = 19
    enfrentar(m); m.entidades.jugadores[2].vida = 5
    disparar("q"); correrPartida(1, terminado)
    check(nm, "muerte 20 de 20 gana la partida", juego.estado == "terminando" and juego.ganador == 1,
        "estado=" .. juego.estado .. " ganador=" .. tostring(juego.ganador))
    correrPartida(3.5)
    check(nm, "tras el aviso pasa a fin", juego.estado == "fin", "estado=" .. juego.estado)

    -- CTF: 1 captura por ronda, 2 rondas para ganar
    nm = nombres[2]
    juego.nuevaPartida(config(2, {capturas = 1, rondas = 2}), 1200, 600)
    local function capturar()
        local E = juego.mododejuego.entidades
        local j1 = E.jugadores[1]
        teleport(j1, E.banderas[2].posX, E.banderas[2].posY); correrPartida(0.1)
        teleport(j1, E.banderas[1].x, E.banderas[1].y); correrPartida(0.2, terminado)
    end
    capturar()
    check(nm, "captura gana la ronda 1", juego.estado == "entreRondas" and juego.rondasGanadas[1] == 1,
        "estado=" .. juego.estado .. " rondas=" .. juego.rondasGanadas[1])
    correrPartida(3.5)
    local E = juego.mododejuego.entidades
    check(nm, "empieza ronda 2 con marcador a 0", juego.estado == "jugando" and juego.ronda == 2 and E.puntuaciones[1].puntos == 0,
        string.format("estado=%s ronda=%d puntos=%s", juego.estado, juego.ronda, E.puntuaciones[1].puntos))
    capturar()
    check(nm, "segunda ronda gana la partida", juego.estado == "terminando" and juego.ganador == 1,
        "estado=" .. juego.estado .. " ganador=" .. tostring(juego.ganador))

    -- KOTH y Crazy Ball: gana la ronda quien tiene mas puntos al acabar el tiempo
    for _, modo in ipairs({3, 4}) do
        nm = nombres[modo]
        juego.nuevaPartida(config(modo, {time = 3, rondas = 1}), 1200, 600)
        E = juego.mododejuego.entidades
        local obj = modo == 3 and E.colina[1] or E.banderas[1]
        teleport(E.jugadores[1], obj.posX, obj.posY)
        correrPartida(3.5, terminado)
        check(nm, "fin del tiempo: gana quien suma mas", juego.estado == "terminando" and juego.ganador == 1,
            string.format("estado=%s ganador=%s puntos=%.1f-%.1f", juego.estado, tostring(juego.ganador),
                E.puntuaciones[1].puntos, E.puntuaciones[2].puntos))
    end

    nm = nombres[3]
    juego.nuevaPartida(config(3, {time = 1, rondas = 1}), 1200, 600)
    correrPartida(1.5, terminado)
    check(nm, "empate: ronda sin ganador", juego.estado == "entreRondas" and juego.ganadorRonda == 0
        and juego.rondasGanadas[1] == 0 and juego.rondasGanadas[2] == 0,
        "estado=" .. juego.estado .. " ganadorRonda=" .. tostring(juego.ganadorRonda))

    local okd, errd = pcall(function()
        love.graphics.setCanvas(love.graphics.newCanvas(1200, 600)); juego.dibujarCapas(); love.graphics.setCanvas()
    end)
    check(nm, "dibujar aviso entre rondas", okd, errd)
end

------------------------------------------------------------ bots

local function puntos(i)
    local p = juego.mododejuego.entidades.puntuaciones[i]
    return p and p.puntos or 0
end

local function probarBots()
    local bot = require "bot"
    math.randomseed(7)
    local sinFin = {time = 600, numMuertes = 1000, capturas = 1000}
    -- puntos minimos que el bot dificil debe sumar en 90 s contra un rival quieto
    local metas = {5, 1, 30, 30}
    for modo = 1, 4 do
        local nm = nombres[modo]
        for nivel = 1, 3 do
            sinFin.rival = nivel + 1
            local ok, err = pcall(function()
                juego.nuevaPartida(config(modo, sinFin), 1200, 600)
                correrPartida(30)
            end)
            check(nm, "bot " .. bot.NIVELES[nivel] .. " juega 30s sin error", ok, err)
        end
        sinFin.rival = 4
        juego.nuevaPartida(config(modo, sinFin), 1200, 600)
        correrPartida(90)
        check(nm, "bot dificil gana a un rival quieto", puntos(2) >= metas[modo] and puntos(2) > puntos(1),
            string.format("puntos %.1f - %.1f", puntos(1), puntos(2)))
        -- contra un bot el jugador 1 juega a pantalla completa
        local okd, errd = pcall(function()
            juego.vistaJugador = 1
            love.graphics.setCanvas(love.graphics.newCanvas(1200, 600)); juego.dibujarCapas(); love.graphics.setCanvas()
        end)
        juego.vistaJugador = nil
        check(nm, "dibujar contra bot (pantalla completa)", okd, errd)
    end

    -- bot contra bot: el de mas nivel debe ganar la mayoria de los modos.
    -- (CTF entre bots suele empatar: el mapa es simetrico y es una carrera)
    for _, par in ipairs({{3, 1}, {2, 1}, {3, 2}}) do
        local fuerte, debil = par[1], par[2]
        local ganadas, perdidas = 0, 0
        for modo = 1, 4 do
            sinFin.rival = fuerte + 1
            juego.nuevaPartida(config(modo, sinFin), 1200, 600)
            juego.bots[2] = bot.nuevo(juego.mododejuego, modo, 1, debil)
            correrPartida(120)
            if puntos(2) > puntos(1) then ganadas = ganadas + 1 end
            if puntos(2) < puntos(1) then perdidas = perdidas + 1 end
            print(string.format("%s vs %s en %s: %.1f - %.1f", bot.NIVELES[debil], bot.NIVELES[fuerte],
                nombres[modo], puntos(1), puntos(2)))
        end
        check("Bots", bot.NIVELES[fuerte] .. " le gana a " .. bot.NIVELES[debil], ganadas >= 2 and perdidas <= 1,
            string.format("gana %d, pierde %d de 4 modos", ganadas, perdidas))
    end
end

------------------------------------------------------------ red (serializacion)

local function probarRed()
    local red = require "red"
    local nm = "Red"
    local orig = {tipo = "estado", n = -12.5, e = 7, b = true, f = false, txt = "a:b;c\0z",
                  lista = {{1, 2, {x = 3}}, "s"}}
    local v = red.decodificar(red.codificar(orig))
    local ok = type(v) == "table" and v.tipo == "estado" and v.n == -12.5 and v.e == 7 and v.b == true
        and v.f == false and v.txt == orig.txt and v.lista[1][3].x == 3 and v.lista[2] == "s"
    check(nm, "codificar/decodificar ida y vuelta", ok)
    local malos = {"", "x", "n12", "nabc;", "s99:abc", "s-1:", "tn1;", "tn1;n2;", "n1;n2;",
                   "ttee", string.rep("t", 100) .. string.rep("e", 100), "tTn1;e", "ttes1:ae"}
    local rechazados = 0
    for _, m in ipairs(malos) do
        local okd, val = pcall(red.decodificar, m)
        if okd and val == nil then rechazados = rechazados + 1 end
    end
    check(nm, "mensajes invalidos se rechazan sin error", rechazados == #malos,
        rechazados .. "/" .. #malos)
end

function pruebas.correr()
    -- las teclas virtuales de los bots siguen pasando por bot.lua
    local isDownBots = love.keyboard.isDown
    love.keyboard.isDown = function(...)
        for _, k in ipairs({...}) do
            if teclas[k] then return true end
            if type(k) == "string" and k:sub(1, 4) == "bot:" and isDownBots(k) then return true end
        end
        return false
    end
    love.audio.play = function() end
    interf.irA(interf.JUGANDO)

    for modo = 1, 4 do
        local ok, err = pcall(probarMecanica, modo)
        if not ok then check(nombres[modo], "iniciar / probar modo", false, tostring(err)) end
        teclas = {}
        ok, err = pcall(probarPowerUps, modo)
        if not ok then check(nombres[modo], "probar power-ups", false, tostring(err)) end
        teclas = {}
    end
    local ok, err = pcall(probarVictoria)
    if not ok then check("Partida", "reglas de victoria", false, tostring(err)) end
    ok, err = pcall(probarBots)
    if not ok then check("Bots", "probar bots", false, tostring(err)) end
    ok, err = pcall(probarRed)
    if not ok then check("Red", "serializacion", false, tostring(err)) end

    print("\n" .. table.concat(resultados, "\n"))
    print(string.format("\n%d comprobaciones, %d fallas", #resultados, fallas))
    io.stdout:flush()
    love.event.quit(fallas > 0 and 1 or 0)
end

return pruebas
