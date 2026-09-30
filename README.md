# Dino Runner

Endless runner de un dinosaurio en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Todos los gráficos son pixel art propio.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic). En el menú: **Jugar** (eliges modo Normal/Fácil y, si has comprado checkpoints, el nivel inicial), **Tienda**, **Ruleta** y **Manual** (explicación completa de todo el juego).

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | W (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida / pisotón | S | Deslizar hacia abajo |
| Carril de arriba / de abajo | A / D | Botones ▲ ▼ |
| Rugido | E | Botón «Rugido» |
| Pausa (con acceso al manual) | P | Botón ❚❚ |

- **Modos:** Normal y Fácil (3 vidas, más lento, bosses más débiles, monedas a mitad de valor). Récord separado para cada uno.
- **Niveles y biomas:** cada 1000 puntos (Desierto, Selva, Volcán, Glaciar, Noche estrellada, Ciudad futurista, y vuelta a empezar).
- **Bosses:** a mitad de cada nivel (500, 1500…). El manual tiene la ficha y la estrategia de cada uno.
- **Tienda:** skins y checkpoints (500 × (nivel − 1) monedas; se desbloquean al completar el nivel anterior).
- **Ruleta:** apuestas de 10 a 500 monedas del juego (a la larga se pierde) y un giro gratis diario.
- Todo se guarda en `localStorage`.

## Ajustes

Todas las constantes de balance están comentadas en `CONFIG`, al principio del `<script>`: velocidades, modo Fácil (`EASY`), bosses (`BOSS_*`), checkpoints (`CHECKPOINT_*`), ruleta (`ROULETTE_*`, `FREE_SPIN_PRIZES`) y monedas. Las skins están en `SKINS`. El manual lee estos valores, así que se actualiza solo.

Modo prueba: pon `const DEBUG = true;` para tener 5000 monedas, todos los niveles completados y las teclas 1–6 (bioma) o Mayús + 1–6 (boss).
