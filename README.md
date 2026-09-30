# Dino Runner

Endless runner de un dinosaurio en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Todos los gráficos son pixel art propio.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic) y pulsa **Jugar** (o W).

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | W (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida / pisotón | S | Deslizar hacia abajo |
| Cambiar de carril (alterna) | A | Botones ▲ ▼ (o dos dedos ↕) |
| Rugido (rompe rocas y pájaros) | D | Botón «Rugido» |
| Pausa | P / Esc | Botón ❚❚ |
| Tienda (menú / game over) | T | Botón «Tienda» |
| Sonido | M | — |

- **Niveles:** cada 1000 puntos sube el nivel, cambia el bioma (Desierto → Selva → Volcán → Glaciar → Noche estrellada → Ciudad futurista, y vuelta a empezar) y aumenta la dificultad.
- **Bosses:** a mitad de cada bioma (500, 1500, 2500…) aparece un boss (Escorpión gigante, Serpiente de lianas, Golem de lava, Mamut de hielo, Pterodáctilo sombra y Robot-rex). Tras cada ataque tiene ~1,5 s de vulnerabilidad: ruge (1), pisa su punto débil con S en el aire (3), devuelve proyectiles rugiendo en el último momento (2, «¡PERFECTO!»), chócate con turbo (3) o activa la trampa del escenario (4). Derrotarlo da +100 monedas y +250 puntos; si aguantas 30 s sin vencerlo, se retira.
- **Power-ups:** Escudo, Imán, Cámara lenta y Turbo.
- **Tienda:** las monedas recogidas se guardan en un monedero permanente para comprar 9 skins estéticas.
- Se guardan en `localStorage` el récord, las monedas, las skins compradas y la equipada.

## Ajustes

- Dificultad, duraciones y frecuencia de monedas: objeto `CONFIG` al principio del `<script>`.
- Precios y diseño de las skins: array `SKINS` justo debajo.
- Bosses: constantes `BOSS_*` en `CONFIG` (vida, rapidez por ciclo, ventanas de vulnerabilidad, daño, recompensas).
- Modo prueba: pon `const DEBUG = true;` para tener 5000 monedas y usar las teclas 1–6 (bioma) o Mayús + 1–6 (boss).
- Biomas: array `BIOMES`. Patrones de obstáculos: array `PATTERNS`.
