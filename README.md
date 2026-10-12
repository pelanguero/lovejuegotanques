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

## Pruebas

```
love . --pruebas
```

Juega cada modo simulando teclas (movimiento, dano, respawn, objetivo, limites del mapa, rondas y victoria) e imprime el resultado. Termina con codigo 1 si alguna prueba falla.
