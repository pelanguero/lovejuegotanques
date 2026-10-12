# lovejuegotanques
juego de tanques en love lua 2d

## Controles

| | Mover | Disparar | Mina |
|---|---|---|---|
| Jugador 1 | W A S D | Q | E |
| Jugador 2 | I J K L | U | O |

Esc pausa la partida.

## Modos de juego

- **Team Slayer**: gana el primer equipo que llega a las muertes configuradas.
- **Capture The Flag**: cada ronda la gana quien llega a las capturas configuradas.
- **King Of The Hill** / **Crazy Ball**: cada ronda dura el tiempo configurado y la gana el equipo con mas puntos.

En los modos por rondas gana la partida el primer equipo que gana las rondas configuradas.

## Jugar en linea (2 jugadores)

1. Un jugador elige **Jugar en linea -> Crear partida**. La pantalla muestra su IP y el puerto (22122, UDP).
2. El otro elige **Jugar en linea**, escribe esa IP y pulsa **Unirse**.
3. Cuando se conecta, el anfitrion elige el modo y pulsa **Comenzar**.

Los dos usan W A S D, Q y E. El anfitrion es el Equipo 1 y el que se une el Equipo 2.
En la misma red local basta con la IP que muestra el juego. Por internet el anfitrion
tiene que abrir el puerto 22122 UDP en su router, o ambos usar una VPN como Tailscale o ZeroTier.

El anfitrion simula la partida y envia el estado al otro jugador, que solo manda sus teclas.

## Pruebas

```
love . --pruebas
```

Juega cada modo simulando teclas (movimiento, dano, respawn, objetivo, limites del mapa, rondas y victoria), prueba la serializacion de red e imprime el resultado. Termina con codigo 1 si alguna prueba falla.
