-- Capa de red: conexion ENet (incluido en LOVE) y serializacion de mensajes.
-- Un anfitrion y un cliente. Los mensajes son tablas Lua con numeros,
-- textos, booleanos y subtablas; nunca se ejecuta codigo recibido.
local enet = require "enet"

local red = {PUERTO = 22122, host = nil, par = nil, rol = nil, pendiente = nil}

-- canales: 0 = confiable (eventos), 1 = no confiable (estado frecuente)
local CANALES = 2

------------------------------------------------------------------ serializacion
-- Formato: n<numero>;  s<largo>:<texto>  T  F  t<campos>e
-- Cada campo de tabla va como <clave><valor>.

local function codificar(v, partes)
    local tipo = type(v)
    if tipo == "number" then
        -- %.17g conserva el valor exacto; los enteros quedan cortos
        if v == math.floor(v) and math.abs(v) < 2^53 then
            partes[#partes + 1] = "n" .. string.format("%d", v) .. ";"
        else
            partes[#partes + 1] = "n" .. string.format("%.6g", v) .. ";"
        end
    elseif tipo == "string" then
        partes[#partes + 1] = "s" .. #v .. ":" .. v
    elseif tipo == "boolean" then
        partes[#partes + 1] = v and "T" or "F"
    elseif tipo == "table" then
        partes[#partes + 1] = "t"
        for k, val in pairs(v) do
            local tk = type(k)
            if (tk == "number" or tk == "string") and type(val) ~= "function" then
                codificar(k, partes)
                codificar(val, partes)
            end
        end
        partes[#partes + 1] = "e"
    else
        error("no se puede enviar un valor de tipo " .. tipo)
    end
end

function red.codificar(v)
    local partes = {}
    codificar(v, partes)
    return table.concat(partes)
end

local MAX_PROFUNDIDAD = 16

local function decodificar(s, i, prof)
    if prof > MAX_PROFUNDIDAD then error("mensaje demasiado anidado") end
    local c = s:sub(i, i)
    if c == "n" then
        local fin = s:find(";", i + 1, true)
        if not fin then error("numero sin terminar") end
        local n = tonumber(s:sub(i + 1, fin - 1))
        if not n then error("numero invalido") end
        return n, fin + 1
    elseif c == "s" then
        local dp = s:find(":", i + 1, true)
        if not dp then error("texto sin largo") end
        local largo = tonumber(s:sub(i + 1, dp - 1))
        if not largo or largo < 0 or dp + largo > #s then error("texto invalido") end
        return s:sub(dp + 1, dp + largo), dp + largo + 1
    elseif c == "T" then
        return true, i + 1
    elseif c == "F" then
        return false, i + 1
    elseif c == "t" then
        local t = {}
        i = i + 1
        while s:sub(i, i) ~= "e" do
            if i > #s then error("tabla sin terminar") end
            local k, v
            k, i = decodificar(s, i, prof + 1)
            if type(k) == "table" or type(k) == "boolean" then error("clave invalida") end
            v, i = decodificar(s, i, prof + 1)
            t[k] = v
        end
        return t, i + 1
    end
    error("tipo desconocido '" .. c .. "'")
end

-- Devuelve el valor o nil + mensaje de error si el texto no es valido
function red.decodificar(s)
    local ok, v, fin = pcall(decodificar, s, 1, 0)
    if not ok then return nil, v end
    if fin ~= #s + 1 then return nil, "datos sobrantes" end
    return v
end

------------------------------------------------------------------ conexion

function red.hospedar(puerto)
    red.cerrar()
    -- un solo par: el segundo jugador
    local host, err = enet.host_create("*:" .. (puerto or red.PUERTO), 1, CANALES)
    if not host then return false, err or "no se pudo abrir el puerto" end
    red.host, red.rol = host, "anfitrion"
    return true
end

function red.unirse(ip, puerto)
    red.cerrar()
    local host = enet.host_create(nil, 1, CANALES)
    if not host then return false, "no se pudo crear la conexion" end
    local ok, par = pcall(host.connect, host, ip .. ":" .. (puerto or red.PUERTO), CANALES)
    if not ok or not par then
        host:destroy()
        return false, "direccion invalida"
    end
    red.host, red.rol, red.pendiente = host, "cliente", par
    return true
end

function red.conectado()
    return red.par ~= nil
end

-- confiable=true para eventos (inicio, disparos); false para estado frecuente
function red.enviar(mensaje, confiable)
    if not red.par then return end
    if confiable then
        red.par:send(red.codificar(mensaje), 0, "reliable")
    else
        red.par:send(red.codificar(mensaje), 1, "unsequenced")
    end
end

-- Procesa los eventos pendientes. manejador(evento, mensaje):
-- evento = "conectado" | "desconectado" | "mensaje"
function red.actualizar(manejador)
    if not red.host then return end
    local ev = red.host:service(0)
    while ev do
        if ev.type == "connect" then
            if red.par and red.par ~= ev.peer then
                ev.peer:disconnect_now() -- ya hay un jugador
            else
                red.par, red.pendiente = ev.peer, nil
                manejador("conectado")
            end
        elseif ev.type == "disconnect" then
            -- tambien avisa si falla una conexion que no llego a completarse
            if ev.peer == red.par or ev.peer == red.pendiente then
                red.par, red.pendiente = nil, nil
                manejador("desconectado")
            end
        elseif ev.type == "receive" and ev.peer == red.par then
            local msg = red.decodificar(ev.data)
            if type(msg) == "table" then manejador("mensaje", msg) end
        end
        if not red.host then return end -- el manejador pudo cerrar la conexion
        ev = red.host:service(0)
    end
end

function red.cerrar()
    if red.host then
        if red.par then
            red.par:disconnect_now()
        end
        red.host:flush()
        red.host:destroy()
    end
    red.host, red.par, red.rol, red.pendiente = nil, nil, nil, nil
end

-- IP de esta maquina en la red local (sin enviar paquetes: solo consulta la ruta)
function red.ipLocal()
    local ok, socket = pcall(require, "socket")
    if not ok then return "?" end
    local u = socket.udp()
    u:setpeername("8.8.8.8", 80)
    local ip = u:getsockname()
    u:close()
    return ip or "?"
end

return red
