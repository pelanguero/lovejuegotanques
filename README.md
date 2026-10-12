# lovejuegotanques
juego de tanques en love lua 2d

## Controles

| | Mover | Disparar | Mina |
|---|---|---|---|
| Jugador 1 | W A S D | Q | E |
| Jugador 2 | I J K L | U | O |

Esc pausa la partida.

## Menu

Mientras estas en los menus, el fondo es una demo del juego: un modo al azar con dos
bots (nivel normal o dificil) peleando. Cambia de modo cada 25 segundos y no tiene sonido.

## Jugar contra la computadora

En **Jugar**, la opcion **Rival** elige quien maneja el tanque del Equipo 2:

- **Jugador 2**: otra persona en el mismo teclado (I J K L, U, O).
- **Bot facil**: reacciona tarde, apunta mal, no esquiva ni usa minas y a veces se distrae.
- **Bot normal**: anticipa el movimiento del rival al disparar, esquiva algunas balas,
  evita minas, deja minas cuando lo persiguen y toma cajas cercanas.
- **Bot dificil**: reacciona casi al instante, apunta con precision, esquiva casi todas las
  balas, se mueve de lado mientras recarga energia y busca power-ups cuando esta herido.

Los bots juegan con las mismas reglas que una persona (giro, inercia y energia) y siguen el
objetivo de cada modo: robar y llevar la bandera, ocupar la colina o quedarse con la bola.
Contra un bot, el jugador 1 ve la partida a pantalla completa.

## Pantalla dividida o ventanas separadas

En **Jugar**, la opcion **Pantalla** elige entre:

- **Dividida**: los dos jugadores comparten una ventana partida a la mitad.
- **Ventanas separadas**: el juego abre una segunda ventana (otra instancia del juego,
  conectada por 127.0.0.1, puerto 22123) y cada jugador ve su tanque en su propia ventana.
  Las ventanas se colocan lado a lado. Los controles funcionan sin importar que ventana
  tenga el foco. Al volver al menu o cerrar la primera ventana, la segunda se cierra sola.

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

Juega cada modo simulando teclas (movimiento, dano, respawn, objetivo, limites del mapa, rondas y victoria), pone a jugar a los bots (cada nivel en cada modo, contra un rival quieto y entre ellos, comprobando que el nivel mas alto gane), prueba la serializacion de red e imprime el resultado. Termina con codigo 1 si alguna prueba falla.
