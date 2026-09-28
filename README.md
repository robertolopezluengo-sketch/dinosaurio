# Dino Runner

Endless runner de un dinosaurio en un único `index.html` (HTML + CSS + JavaScript puro con `<canvas>`, sin librerías ni conexión a internet). El dinosaurio y el resto de gráficos son pixel art propio.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic).

| Acción | Teclado | Móvil |
|---|---|---|
| Saltar / doble salto | Espacio o ↑ (otra vez en el aire) | Tocar |
| Deslizarse / caída rápida | ↓ | Deslizar hacia abajo |
| Cambiar de carril | W / S | Deslizar con dos dedos ↕ o botones ▲ ▼ |
| Rugido (rompe rocas y pájaros) | X | Botón «Rugido» |
| Pausa | P / Esc | Botón ❚❚ |
| Sonido | M | — |

**Power-ups:** Escudo (absorbe un golpe, 5 s), Imán (atrae monedas, 8 s), Cámara lenta (50 %, 5 s) y Turbo (x2 e invencible, 4 s).

## Ajustar la dificultad

Todas las constantes de balance están en el objeto `CONFIG`, al principio del `<script>` de `index.html`, comentadas una a una.
