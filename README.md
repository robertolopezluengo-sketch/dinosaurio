# Dino Runner

Endless runner protagonizado por un velociraptor, en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Se abre con doble clic. El canvas se dibuja a la resolución real de la pantalla.

El raptor viene del kit **Dino Runner**: `skins-engine.js` (`DinoSkinsEngine`, 16 skins de velociraptor) y sus datos (`const SKINS_DATA = {…}`) van incrustados en `index.html`. Los 10 jefes se dibujan por piezas (cuerpo, eslabones y pieza final con su pivote) con los PNG de `diseno/bosses/` (encargo `diseno/JEFES_PIEZAS.md`), incrustados como `data:` URIs. Todo lo demás (obstáculos, fondos, power-ups, huevos e interfaz) es pixel art propio. Desde la versión 7, la interfaz, los 10 escenarios y los obstáculos siguen la propuesta de estilo «Expedición arcade» de Claude Design (carpeta `diseno/`), con sus dos fuentes pixel (Raptor Pixel y Raptor Pixel Display) incrustadas.

## Cómo jugar

Menú: **Jugar** (modo Normal, Fácil o Difícil y nivel inicial si tienes checkpoints), **Multijugador**, **Tienda**, **Ruleta**, **Logros**, **Manual** y silenciar.

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | W (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida | S | Deslizar hacia abajo |
| Carril de arriba / de abajo | A / D | Botones ▲ ▼ |
| Rugido | E | Botón «Rugido» |
| Pausa (con acceso al manual) | P | Botón ❚❚ |

- **Niveles:** 10 niveles de 1000 puntos (hasta 10 000), cada uno con su bioma: Desierto, Selva, Volcán, Glaciar, Noche estrellada, Playa tropical, Bosque de setas, Fondo marino, Cementerio encantado y Base lunar. Después el viaje vuelve a empezar, más difícil.
- **Multijugador (2 jugadores, mismo teclado):** se elige dificultad (Normal: 1 vida cada uno; Fácil: 3 vidas cada uno y más lento; Difícil: 1 vida, más rápido y obstáculos más juntos). Sin jefes, power-ups ni huevos. El J1 corre por el carril de arriba (W saltar, S deslizarse, E o D rugido) y el J2 por el de abajo (↑ saltar, ↓ deslizarse, → o Intro rugido). Los dos carriles reciben los mismos obstáculos y gana quien aguante más. Cada 6 s cada jugador gana una **trampa** (máx. 2) que lanza al carril del rival con A (J1) o ← (J2): doble obstáculo, pájaro, roca gigante o tinta que le oscurece el carril. Las monedas van al monedero; no cuenta para récords ni logros.
- **Modos:** Normal; Fácil (3 vidas, más lento, bosses con la mitad de vida, monedas ×0,5); Difícil (20 % más rápido, obstáculos en ambos carriles y pájaros rápidos desde el nivel 2, menos power-ups, rugido de 8 s, bosses con +25 % de vida y más rápidos, monedas ×1,5). Cada modo guarda su récord. Los bosses se vencen igual en los tres modos.
- **Huevos bonus:** 2 por nivel, 50 monedas cada uno (25 en Fácil, 75 en Difícil). El imán no los atrae. Además se guardan en un **monedero de huevos** que se gasta en la pestaña «Huevos» de la tienda: Huevo de arena (15), de cristal (40) y dorado (80), que al abrirse dan una de 9 skins que solo salen de los huevos (comunes, raras y legendarias, estas con rugido especial). Las partidas antiguas reciben los huevos que ya habían recogido.
- **Portales:** al final de cada nivel aparece un portal hacia el bioma siguiente; el raptor lo cruza y cambia el mapa.
- **Bosses:** a mitad de cada nivel (500, 1500… 9500 puntos) llega un boss que te ataca mientras sigues corriendo (40 s para vencerlo). **Cada uno se vence de una forma distinta**: Escorpión gigante (pisotón), Serpiente de lianas (rugido), Golem de lava (devolverle las rocas), Mamut de hielo (saltar por encima), Pterodáctilo sombra (cabezazo desde abajo), Rey cangrejo (rugido para voltear + pisotón), Sapo gigante (setas explosivas), Kraken abisal (deslizarse contra el tentáculo), Rey de los huesos (romper su escudo y pisarle) y Nave nodriza (boss final con 3 fases). La forma de dañar al boss aparece abajo en la pantalla. Al bajar al 50 % de vida (30 % en Fácil; la Nave, en su fase 3) cada boss entra en **forma furiosa**: se tiñe de rojo, ataca un 25 % más rápido con avisos más cortos y añade una mecánica nueva que obliga a cambiar de estrategia (pinchos en los dos carriles, charcos de veneno, carril en llamas, embestida que cambia de carril, lluvia de plumas, burbujas que rebotan, ondas al aterrizar, tinta que oscurece la pantalla, fuegos que persiguen y rayo abductor que te levanta). En Normal y Difícil sigue habiendo una sola vida.
- **Tienda:** 16 skins del kit, 3 exclusivas de logros, checkpoints y editor de skins propias (3 ranuras). Los skins Épicos, Legendarios, el Supremo y los exclusivos tienen un rugido especial con pose animada.
- **Ruleta:** apuestas de 10 a 500 monedas del juego y un giro gratis diario.
- **Logros:** 44 logros con recompensas en monedas y skins exclusivas.
- Todo se guarda en `localStorage` (clave `dinoRunner.save.v2`; las monedas de versiones anteriores se conservan).

## Ajustes

Todas las constantes de balance están comentadas en `CONFIG`, al principio del último `<script>`: niveles y jefe de cada nivel (`LEVELS`), velocidades, modos Fácil (`EASY`) y Difícil (`HARD`), bosses (`BOSS_*`), huevos (`EGG_*`), checkpoints, editor, ruleta (`ROULETTE_*`, `FREE_SPIN_PRIZES`) y monedas. Los logros están en `ACHIEVEMENTS`. El manual lee estos valores, así que se actualiza solo.

Modo prueba: pon `const DEBUG = true;` para tener 5000 monedas y todos los niveles completados; las teclas 1–9 y 0 saltan a los niveles 1–10 y B lanza el boss del nivel actual. Con DEBUG no se consiguen logros.
