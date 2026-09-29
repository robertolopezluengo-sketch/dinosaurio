# Dino Runner

Endless runner de un dinosaurio en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). Todos los gráficos son pixel art propio.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic) y pulsa **Jugar**.

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | Espacio o ↑ (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida | ↓ | Deslizar hacia abajo |
| Cambiar de carril | W / S | Botones ▲ ▼ (o dos dedos ↕) |
| Rugido (rompe rocas y pájaros) | X | Botón «Rugido» |
| Pausa | P / Esc | Botón ❚❚ |
| Tienda (menú / game over) | T | Botón «Tienda» |
| Sonido | M | — |

- **Niveles:** cada 1000 puntos sube el nivel, cambia el bioma (Desierto → Selva → Volcán → Glaciar → Noche estrellada → Ciudad futurista, y vuelta a empezar) y aumenta la dificultad.
- **Power-ups:** Escudo, Imán, Cámara lenta y Turbo.
- **Tienda:** las monedas recogidas se guardan en un monedero permanente para comprar 9 skins estéticas.
- Se guardan en `localStorage` el récord, las monedas, las skins compradas y la equipada.

## Ajustes

- Dificultad, duraciones y frecuencia de monedas: objeto `CONFIG` al principio del `<script>`.
- Precios y diseño de las skins: array `SKINS` justo debajo.
- Biomas: array `BIOMES`. Patrones de obstáculos: array `PATTERNS`.
