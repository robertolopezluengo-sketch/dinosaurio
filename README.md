# Dino Runner

Endless runner protagonizado por un velociraptor, en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Se abre con doble clic.

El raptor y los jefes vienen del kit **Dino Runner** (incrustado en `index.html`, en este orden):

1. `skins-engine.js` → `DinoSkinsEngine` (16 skins de velociraptor).
2. `boss-engine.js` → `DinoBossEngine` (4 jefes con su combate). Único cambio: el cartel final dice «Continuando…».
3. Datos: `const SKINS_DATA = {…}` y `const BOSSES_DATA = {…}`.

Todo lo demás (obstáculos, fondos, power-ups, huevos e interfaz) es pixel art propio.

## Cómo jugar

Menú: **Jugar** (modo Normal/Fácil y nivel inicial si tienes checkpoints), **Tienda**, **Ruleta**, **Logros**, **Manual** y silenciar.

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | W (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida | S | Deslizar hacia abajo |
| Carril de arriba / de abajo | A / D | Botones ▲ ▼ |
| Rugido | E | Botón «Rugido» |
| Pausa (con acceso al manual) | P | Botón ❚❚ |
| **Combate contra un jefe** | solo W | Tocar |

- **Niveles:** cada 1000 puntos cambia el bioma: Desierto, Selva, Volcán, Glaciar, Noche estrellada y Ciudad futurista (y vuelta a empezar).
- **Huevos bonus:** 2 por nivel, 50 monedas cada uno (25 en Fácil). El imán no los atrae.
- **Jefes:** Mandrágora Reina (1900), Coloso de Magma (2900), Wyrm Glacial (3900) y MECHA-REX Ω (5900). Hay que vencerlos para pasar de nivel.
- **Tienda:** 16 skins del kit, 3 exclusivas de logros, checkpoints y editor de skins propias (3 ranuras).
- **Ruleta:** apuestas de 10 a 500 monedas del juego y un giro gratis diario.
- **Logros:** 42 logros con recompensas en monedas y skins exclusivas.
- Todo se guarda en `localStorage` (clave `dinoRunner.save.v2`; las monedas de versiones anteriores se conservan).

## Ajustes

Todas las constantes de balance están comentadas en `CONFIG`, al principio del último `<script>`: velocidades, modo Fácil (`EASY`), jefes (`BOSS_*`), huevos (`EGG_*`), checkpoints, editor, ruleta (`ROULETTE_*`, `FREE_SPIN_PRIZES`) y monedas. Los logros están en `ACHIEVEMENTS`. El manual lee estos valores, así que se actualiza solo.

Modo prueba: pon `const DEBUG = true;` para tener 5000 monedas y todos los niveles completados; las teclas 1–6 saltan a cada bioma y B lanza el jefe del bioma actual. Con DEBUG no se consiguen logros.
