# Dino Runner

Endless runner protagonizado por un velociraptor, en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Se abre con doble clic. El canvas se dibuja a la resolución real de la pantalla.

El raptor viene del kit **Dino Runner**: `skins-engine.js` (`DinoSkinsEngine`, 16 skins de velociraptor) y sus datos (`const SKINS_DATA = {…}`) van incrustados en `index.html`. Todo lo demás (bosses, obstáculos, fondos, power-ups, huevos e interfaz) es pixel art propio.

## Cómo jugar

Menú: **Jugar** (modo Normal/Fácil y nivel inicial si tienes checkpoints), **Tienda**, **Ruleta**, **Logros**, **Manual** y silenciar.

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | W (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida | S | Deslizar hacia abajo |
| Carril de arriba / de abajo | A / D | Botones ▲ ▼ |
| Rugido | E | Botón «Rugido» |
| Pausa (con acceso al manual) | P | Botón ❚❚ |

- **Niveles:** 10 niveles de 1000 puntos (hasta 10 000), cada uno con su bioma: Desierto, Selva, Volcán, Glaciar, Noche estrellada, Playa tropical, Bosque de setas, Fondo marino, Cementerio encantado y Base lunar. Después el viaje vuelve a empezar, más difícil.
- **Huevos bonus:** 2 por nivel, 50 monedas cada uno (25 en Fácil). El imán no los atrae.
- **Bosses:** a mitad de cada nivel (500, 1500… 9500 puntos) llega un boss que te ataca mientras sigues corriendo (40 s para vencerlo). **Cada uno se vence de una forma distinta**: Escorpión gigante (pisotón), Serpiente de lianas (rugido), Golem de lava (devolverle las rocas), Mamut de hielo (saltar por encima), Pterodáctilo sombra (cabezazo desde abajo), Rey cangrejo (rugido para voltear + pisotón), Sapo gigante (setas explosivas), Kraken abisal (deslizarse contra el tentáculo), Rey de los huesos (romper su escudo y pisarle) y Nave nodriza (boss final con 3 fases). La forma de dañar al boss aparece abajo en la pantalla.
- **Tienda:** 16 skins del kit, 3 exclusivas de logros, checkpoints y editor de skins propias (3 ranuras). Los skins Épicos, Legendarios, el Supremo y los exclusivos tienen un rugido especial con pose animada.
- **Ruleta:** apuestas de 10 a 500 monedas del juego y un giro gratis diario.
- **Logros:** 42 logros con recompensas en monedas y skins exclusivas.
- Todo se guarda en `localStorage` (clave `dinoRunner.save.v2`; las monedas de versiones anteriores se conservan).

## Ajustes

Todas las constantes de balance están comentadas en `CONFIG`, al principio del último `<script>`: niveles y jefe de cada nivel (`LEVELS`), velocidades, modo Fácil (`EASY`), bosses (`BOSS_*`), huevos (`EGG_*`), checkpoints, editor, ruleta (`ROULETTE_*`, `FREE_SPIN_PRIZES`) y monedas. Los logros están en `ACHIEVEMENTS`. El manual lee estos valores, así que se actualiza solo.

Modo prueba: pon `const DEBUG = true;` para tener 5000 monedas y todos los niveles completados; las teclas 1–9 y 0 saltan a los niveles 1–10 y B lanza el boss del nivel actual. Con DEBUG no se consiguen logros.
