# Dino Runner — Brief de diseño para Claude Design

> **Para Claude Design.** Necesito que hagas más bonitos los **10 mapas** (biomas), sus **10 bosses**, los **obstáculos** y la **interfaz** de un juego de navegador en pixel art. Abajo tienes cómo es cada cosa ahora, qué no se puede cambiar (porque afecta al juego) y en qué formato entregar el trabajo para que Claude Code lo pueda meter en el juego después.
>
> En la carpeta `capturas/` hay una captura de cada mapa (`mapa-…`), de cada mapa con su boss (`boss-…`) y de cada pantalla de la interfaz (`ui-…`). Son el punto de partida.

---

## 1. Qué es el juego (en 30 segundos)

- Un velociraptor corre solo hacia la derecha; el escenario se mueve hacia la izquierda (parallax).
- Hay **2 carriles** con perspectiva: el de arriba está más atrás (escala 0,8) y el de abajo más cerca (escala 1).
- Cada 1000 puntos cambia el **mapa**. Hay 10 y luego se repiten. A mitad de cada mapa aparece un **boss** que ataca mientras el raptor sigue corriendo.
- Todo es **pixel art** de bloques limpios, contorno oscuro, sin degradados suaves dentro de los sprites. El raptor (protagonista) es un sprite de **24 × 20 píxeles** dibujado a escala ×3. **El raptor y sus 16 skins no se rediseñan**: el resto del arte debe combinar con él.

---

## 2. Reglas técnicas (obligatorias)

### 2.1 Lienzo y escala
- Lienzo lógico del juego: **900 × 360** (proporción 2,5 : 1). Se pinta a la resolución real de la pantalla (hasta 3600 px de ancho), así que el arte tiene que verse bien ampliado.
- **Rejilla de píxel**:
  - **Fondos**: 1 píxel de arte = **2 px lógicos** → un fondo completo mide **450 × 180 píxeles de arte**.
  - **Sprites** (obstáculos, bosses, objetos): 1 píxel de arte = **3 px lógicos**, igual que el raptor.
- Exporta los PNG **a tamaño de arte real** (sin escalar, sin suavizado). El juego los amplía con "vecino más cercano".

### 2.2 Zonas de la pantalla (coordenadas lógicas, y hacia abajo)
| Zona | Posición | Notas |
|---|---|---|
| Cielo | y 0 – 215 | Degradado de 2 colores (`skyTop` → `skyBot`). Sol/luna/planeta en x ≈ 760, y ≈ 64, radio 22–44. |
| Capa lejana | base en y 214, alturas 30–130 | Parallax 0,05 (casi quieta). Siluetas de montañas, ciudad, arrecife… |
| Capa media | base en y 216 | Parallax 0,18–0,22. Árboles, edificios, setas gigantes… |
| Capa cercana | base en y 222, alturas 10–50 | Parallax 0,15. |
| Franja del horizonte | y 204 – 213 | Opcional: lava, mar, río… (animada por código). |
| Suelo | y 212 – 360 | Color `ground` con dos **bandas de carril**. |
| Carril de arriba | línea de suelo y = 236, escala 0,8 | Banda de 26×0,8 px de alto. |
| Carril de abajo | línea de suelo y = 318, escala 1 | Banda de 26 px de alto. |
| Punto de fuga | x = 450 | Los carriles se escalan hacia él. |

- **Mosaico horizontal sin costuras**: cada capa se repite en bucle. Anchos actuales (lógicos): lejana 960, media 1200, cercana 1100. Puedes elegir otros, pero cada capa debe empalmar consigo misma sin que se note.

### 2.3 Zonas que la interfaz tapa (no pongas nada importante ahí)
- **Arriba a la izquierda** (x 0–330, y 0–140): puntos, récord, monedas, huevos, corazones y power-ups.
- **Arriba al centro** (x 280–620, y 0–70): nombre del nivel, cuenta atrás del boss o barra de vida del boss.
- **Arriba a la derecha** (x 800–900, y 0–80): indicador circular del rugido.
- **Abajo al centro** (y 334–354): pista de cómo vencer al boss.
- **El raptor** corre en x 130–202. Esa columna tiene que leerse siempre bien.

### 2.4 Legibilidad (lo más importante)
1. **Los fondos van por detrás**: menos contraste y menos saturación que los obstáculos, el raptor y los bosses. Si dudas, oscurece o "aneblina" el fondo.
2. **Colores reservados para avisos**: rojo `#ff3b3b` = peligro y amarillo `#ffd23f` / `#ffe14d` = punto débil / vulnerable. No uses esos tonos muy saturados en el fondo cerca de los carriles.
3. Los obstáculos deben ocupar su **hitbox** (tabla 4.1) con un margen de ±10 %. Si el dibujo es mucho más grande o más pequeño que la caja de choque, el juego parece injusto.
4. Todo lo que se mueve por código (nieve, ceniza, hojas, esporas, burbujas, estrellas fugaces, aurora, lava, espuma, lianas) se describe en la ficha de cada mapa. Diseña su aspecto (colores, tamaño, forma), no un vídeo.

---

## 3. Los 10 mapas

Para cada mapa: estado actual, colores actuales (claves que usa el código) y qué me gustaría que mejoraras. Puedes cambiar los colores; si lo haces, entrégame la paleta nueva con **las mismas claves**.

Claves de paleta: `skyTop`, `skyBot` (cielo), `far`, `near` (siluetas), `ground` (tierra), `band` (carril), `bandHi` (borde de luz del carril), `bandEdge` (borde oscuro del carril), `pebble` (piedrecitas / brillos del suelo), `accent` (color del título del nivel).

### Mapa 1 — Desierto (0–999 puntos) · Boss: Escorpión gigante
- **Ahora**: cielo azul a crema (`#5fb4ea` → `#fde9b8`), sol amarillo grande, nubes blancas planas, dunas en dos capas (`#e8c07e`, `#d9a35e`), suelo arena `#ecd49a`, carriles `#dcbf80`. Captura: `mapa-01-desierto.jpg`.
- **Obstáculos**: cactus (suelo), rocas grises (destructibles), pterodáctilos morados (voladores).
- **Mejora deseada**: calor y amplitud. Mesetas o rocas de arenisca a lo lejos, dunas con luz rasante, huesos o calaveras de animales semienterrados, calima (aire que tiembla) cerca del horizonte, cielo con más matices (tarde dorada). Cactus con más carácter (flores, sombra lateral).
- **Animado por código**: nubes que pasan, piedrecitas del suelo.

### Mapa 2 — Selva (1000–1999) · Boss: Serpiente de lianas
- **Ahora**: cielo verde claro (`#bfe3a0` → `#e8f6d6`), colinas `#6aa860` / `#3f7d3f`, árboles cuadrados (tronco `#4a3420`, copa `#2f7a3c`), lianas que cuelgan desde arriba, hojas que caen, suelo tierra oscura `#3a2a1a`, carriles verdes `#2e6b2a`. Captura: `mapa-02-selva.jpg`.
- **Obstáculos**: troncos (suelo), rocas con musgo, pterodáctilos.
- **Mejora deseada**: selva densa por capas (helechos delante, árboles enormes con raíces, rayos de luz entre hojas, algo de bruma). Las copas ahora son rectángulos: dales forma orgánica.
- **Animado por código**: hojas que caen, lianas que se balancean.

### Mapa 3 — Volcán (2000–2999) · Boss: Golem de lava
- **Ahora**: cielo rojo oscuro (`#3a1410` → `#7a2a14`), volcán al fondo con humo, río de lava naranja en el horizonte (`#ff6a1a` / `#ffd05a`), siluetas casi negras, suelo `#3b2a28`, piedrecitas que brillan naranja, ceniza que cae. Captura: `mapa-03-volcan.jpg`.
- **Obstáculos**: pinchos de obsidiana con vetas de lava, rocas volcánicas, pterodáctilos.
- **Mejora deseada**: volcán imponente con columna de humo y brillo en su base, grietas de lava en el suelo lejano, contraluz rojo. El suelo debe seguir siendo oscuro para que los obstáculos se vean.
- **Animado por código**: ceniza, brillo de la lava, humo.

### Mapa 4 — Glaciar (3000–3999) · Boss: Mamut de hielo
- **Ahora**: noche azul (`#0b1a33` → `#1d3a66`) con estrellas y **aurora boreal** (bandas verde, cian y morado), montañas azules con cumbres nevadas, suelo hielo claro `#9fd8ff`, carriles `#bfe6ff` con destellos, nieve que cae. Captura: `mapa-04-glaciar.jpg`.
- **Obstáculos**: bloques de hielo, rocas heladas, pterodáctilos y **estalactitas** que cuelgan de arriba (exclusivas de este mapa).
- **Mejora deseada**: icebergs, grietas azules, reflejos en el hielo y una aurora más elegante. Cuidado: el suelo es muy claro, así que los obstáculos de hielo necesitan buen contorno.
- **Animado por código**: aurora, nieve, destellos del suelo.

### Mapa 5 — Noche estrellada (4000–4999) · Boss: Pterodáctilo sombra
- **Ahora**: cielo azul noche (`#050820` → `#262a5c`), luna crema con cráteres, estrellas que titilan, estrellas fugaces, colinas oscuras, suelo `#2c2a45`. Es el mapa "tranquilo" con más monedas. Captura: `mapa-05-noche.jpg`.
- **Obstáculos**: cristales morados (suelo), meteoritos que caen del cielo (rocas), pterodáctilos.
- **Mejora deseada**: vía láctea, luciérnagas, siluetas de árboles o rocas con borde de luz de luna, un lago que refleje la luna. Ambiente mágico pero oscuro.
- **Animado por código**: estrellas, estrellas fugaces.

### Mapa 6 — Playa tropical (5000–5999) · Boss: Rey cangrejo
- **Ahora**: cielo celeste (`#3fb8f0` → `#c8f0ff`), sol, colinas verdes, palmeras hechas con los árboles cuadrados, mar azul en el horizonte con brillos, arena `#f3dca0`. Captura: `mapa-06-playa.jpg`.
- **Obstáculos**: troncos a la deriva, rocas, pterodáctilos (podrían pasar a ser gaviotas).
- **Mejora deseada**: **palmeras de verdad** (troncos curvos, hojas en abanico), islas al fondo, espuma de olas, conchas y estrellas de mar en la arena, agua turquesa. Es el mapa más luminoso.
- **Animado por código**: brillo del mar, nubes.

### Mapa 7 — Bosque de setas (6000–6999) · Boss: Sapo gigante
- **Ahora**: crepúsculo morado (`#2a1450` → `#a85ac0`), luna, setas gigantes (pie crema `#f3e2b8`, sombrero rojo `#d23a4a` con una raya blanca), colinas moradas, suelo marrón, carriles morados `#5a3a7a`, esporas de colores flotando. Captura: `mapa-07-setas.jpg`.
- **Obstáculos**: troncos, rocas con musgo, pterodáctilos.
- **Mejora deseada**: setas de varias formas y tamaños **con lunares y bioluminiscencia** (cian, rosa, amarillo), hierba alta y rizada, bruma de esporas. Ahora mismo las setas son rectángulos: es el mapa que más gana con un rediseño.
- **Animado por código**: esporas flotantes (rosa `#ff7ad0`, cian `#7df9ff`, amarillo `#ffe14d`).

### Mapa 8 — Fondo marino (7000–7999) · Boss: Kraken abisal
- **Ahora**: "cielo" azul profundo (`#04203a` → `#1a6a9a`), arrecife en silueta azul oscuro, fondo de arena `#c8b88a`, burbujas que suben, destellos rosas en el suelo. Captura: `mapa-08-fondo-marino.jpg`.
- **Obstáculos**: cristales morados (hacen de coral), rocas con musgo, **peces naranjas** (voladores).
- **Mejora deseada**: rayos de luz desde la superficie, corales y anémonas de colores, algas que se mecen, un barco hundido o ruinas al fondo, partículas en suspensión. Los obstáculos de suelo deberían parecer **corales** de verdad.
- **Animado por código**: burbujas que suben, algas.

### Mapa 9 — Cementerio encantado (8000–8999) · Boss: Rey de los huesos
- **Ahora**: cielo casi negro (`#0a0a18` → `#2a3a3a`), luna, estrellas, colinas negras, suelo `#1e1e24`, fuegos fatuos verdes (`#6aff8a`) flotando. Captura: `mapa-09-cementerio.jpg`.
- **Obstáculos**: **lápidas** grises con cruz (suelo), rocas, pterodáctilos (podrían ser murciélagos).
- **Mejora deseada**: verjas de hierro, árboles secos retorcidos, una cripta o iglesia al fondo, niebla verde baja a ras de suelo, cuervos. Que dé un poco de miedo sin perder legibilidad.
- **Animado por código**: fuegos fatuos, estrellas fugaces.

### Mapa 10 — Base lunar (9000–9999, mapa final) · Boss: Nave nodriza
- **Ahora**: espacio negro con estrellas, **la Tierra** en el cielo (azul con continentes verdes), montañas lunares grises con cumbres claras, suelo gris `#9a9ea8`, estrellas fugaces. Captura: `mapa-10-base-lunar.jpg`.
- **Obstáculos**: cristales (suelo), meteoritos que caen, drones (voladores).
- **Mejora deseada**: cráteres en el suelo y en el fondo, una base científica con cúpulas y antenas (luces parpadeantes), una bandera, polvo lunar. Es el final del viaje: que se sienta épico.
- **Animado por código**: estrellas fugaces, luces de la base.

### Fondos de las ventanas (menús)
Detrás de los menús se ve el mapa del Desierto con el raptor corriendo. Puedes proponer otro fondo para el menú principal (por ejemplo, un collage de los 10 mapas).

---

## 4. Obstáculos y objetos (comunes a todos los mapas)

### 4.1 Tamaños (px lógicos; divide entre 3 para sacar los píxeles de arte)
| Tipo | Tamaño (an × al) | Variantes por mapa |
|---|---|---|
| Suelo pequeño / grande / alto | 24×46 · 32×64 · 34×86 (pueden ir 2–3 seguidos) | cactus, tronco, obsidiana, bloque de hielo, cristal, lápida, (coral) |
| Roca pequeña / alta (destructible con el rugido) | 44×32 · 48×112 | roca, roca con musgo, volcánica, helada, meteorito |
| Volador (a 0, 34 o 90 px del suelo) | 66×36 | pterodáctilo, pez, dron (+ gaviota y murciélago si te animas) |
| Estalactita (cuelga) | 36×218 | solo Glaciar |
| Moneda | 18×18 (gira) | — |
| Huevo bonus | 30×33 (brilla y se balancea; se abre al cogerlo) | — |
| Power-ups | círculo de 32 con icono | escudo (azul), imán (rojo), cámara lenta (morado), turbo (naranja) |

### 4.2 Qué entregar
- Un PNG por obstáculo y variante, a tamaño de arte, con fondo transparente: `obstaculos/<tipo>_<mapa>_<tamaño>.png` (por ejemplo `suelo_desierto_grande.png`).
- Los voladores con **2 fotogramas** de aleteo o nado.

---

## 5. Los 10 bosses

Los bosses están hechos de **piezas** que el código mueve por separado: cuerpo, cadena de segmentos (cola, cuello, brazo o tentáculo) y una pieza final (aguijón, puño, pinza, cabeza…). **Mantén esa estructura**: dibuja cada pieza por separado e indica su punto de giro (pivote). Ahora mismo están hechos con rectángulos sombreados; se pueden mejorar mucho.

Cada boss tiene un **punto débil** que debe distinguirse claramente: el juego le pone un contorno y una flecha amarilla cuando es vulnerable.

| # | Boss | Mapa | Piezas actuales (px lógicos aprox.) | Estados que necesito |
|---|---|---|---|---|
| 1 | **Escorpión gigante** | Desierto | Cuerpo 190×56 que entra **por la izquierda, detrás del raptor**; cola de 10 segmentos (22→14 px) que se arquea por encima; aguijón 32×24 (punto débil cuando se clava); pinzas delante. Colores `#b5542a`, `#5a2210`, `#e07a3f`. | reposo, cola preparada, aguijón clavado (vulnerable), herido, derrota |
| 2 | **Serpiente de lianas** | Selva | Cuelga desde arriba a la derecha: cuerpo de 16 segmentos (16→22 px) con hojas; cabeza 62×30 con ojos amarillos, lengua y **pinchos debajo** (no se puede pisar). Colores `#3f8f3a`, `#1f4a1c`, `#8bdc3a`. | colgando, ataque desde arriba, escupir veneno, cabeza apoyada (vulnerable a rugidos), herida |
| 3 | **Golem de lava** | Volcán | De pie al fondo a la derecha: cuerpo 135×100 con grietas de lava y núcleo brillante 28×28, cabeza 56×40, piernas 34×52; brazo-cadena con **puño 56×36** que golpea. Colores `#4a3430`, `#ff6a1a`, `#1a1010`. | reposo, lanzar roca, puñetazo, puño apoyado (quema), herido |
| 4 | **Mamut de hielo** | Glaciar | Cuerpo 150×62, cabeza 50×44, colmillos blancos, 4 patas, ojo que se pone rojo al embestir. Embiste por un carril y se queda aturdido con estrellitas. Colores `#a9cde6`, `#2c4a63`, `#e8f7ff`. | reposo, preparar embestida, embestida, aturdido, herido |
| 5 | **Pterodáctilo sombra** | Noche | Envergadura ~150, cuerpo morado oscuro, ojo rojo. Vuela en círculos en el cielo, se lanza en picado y a veces pasa **rasante y brillando** (vulnerable). Colores `#140a24`, `#6a3aa0`, `#ff3355`. | vuelo (2–3 fotogramas de aleteo), picado, rasante brillante, herido |
| 6 | **Rey cangrejo** | Playa | Cuerpo 150×62 con ojos en pedúnculos y 3 pares de patas; **pinza gigante** en una cadena (62×34) que golpea y se apoya. Al rugirle, la pinza se **voltea** y enseña la barriga rosa. Colores `#e0452e`, `#7a1a10`, `#ffb08a`. | reposo, pinzazo, pinza apoyada, pinza volteada, herido |
| 7 | **Sapo gigante** | Setas | Cuerpo 110×56, ojos amarillos arriba, barriga clara, manchas. Salta en parábola hasta tu carril y lanza la lengua rosa. Su piel es venenosa. Colores `#4caf50`, `#1f3a14`, `#d8f0a0`. | sentado, salto (en el aire), aterrizaje, lengua, herido |
| 8 | **Kraken abisal** | Fondo marino | **Cabeza enorme** (144×100) asomando arriba a la derecha, con 5 tentáculos colgando y ojos amarillos; un tentáculo largo de 14 segmentos con punta 44×24 que golpea y se apoya; tentáculo barredor 90×26; manchas de tinta. Colores `#8a3aa0`, `#2a0a3a`, `#e0a0ff`. | cabeza en reposo, tentáculo arriba, golpe, tentáculo apoyado (se corta), herido |
| 9 | **Rey de los huesos** | Cementerio | T-rex esqueleto: patas, costillas, columna, cola de 8 vértebras, bracitos; **cráneo** (80×34 + mandíbula 70×12) con ojo verde en una cadena-cuello. Lo rodea un **escudo de almas** verde (elipse) con 3 cargas. Colores `#e8dcc0`, `#2a2418`, `#6aff8a`. | reposo, mordisco, cráneo apoyado, escudo activo / roto, herido |
| 10 | **Nave nodriza** (final) | Base lunar | Platillo 124×26 con cúpula cian 60×28 y 6 luces que parpadean. Vuela, dispara un **rayo abductor** verde, láseres rosas y mininaves, y aterriza para recargar. Tiene 3 fases (podría cambiar de color o perder piezas en cada una). Colores `#8792ab`, `#7df9ff`, `#ffe14d`. | vuelo, disparo, rayo abductor, aterrizada, fases 1-2-3, herida |

**Proyectiles y avisos** (diseña también estos): pinchos que caen, veneno verde, rocas de lava, fragmentos de hielo, plumas, burbujas, tinta, huesos, fuegos fantasma verdes, mininaves, láser (rosa), rayo abductor (verde), lengua del sapo. Avisos: sombra roja con «!», flecha roja, diana roja y línea roja parpadeante (pueden ganar estilo, pero deben seguir siendo **rojos** y entenderse al instante).

**Qué entregar por boss**: `bosses/<id>/<pieza>_<estado>.png` (a tamaño de arte, ×3), un `pivotes.json` con el punto de giro de cada pieza y de dónde sale la cadena, y una lámina con el boss montado en su mapa.

---

## 6. Interfaz

La interfaz son **ventanas HTML/CSS** encima del juego, más un **marcador (HUD)** que se pinta en el canvas. Ahora usa tarjetas azul marino con borde grueso, botones "pixel" con bisel, y la fuente es Courier New. Funciona, pero es sosa y poco coherente. Capturas: `ui-01` … `ui-13`.

### 6.1 Pantallas (contenido que **no puede faltar**)
1. **Menú principal** (`ui-01`): título DINO RUNNER, subtítulo y versión; récord Normal, récord Fácil, monedas, skin equipado y logros (x/42); botones **Jugar, Tienda, Ruleta, Logros, Manual**; los controles (W, S, A, D, E, P); botón de sonido.
2. **Elegir modo** (`ui-02`): tarjetas Normal / Fácil con su descripción; "Empezar desde" con los niveles comprados (nivel + mapa + puntos); botones ¡A correr! y Volver.
3. **HUD en partida** (`ui-03`): puntos, récord, monedas, "Huevos x/2", corazones (solo en Fácil) con el texto MODO FÁCIL, power-ups activos con barra de tiempo, título del nivel, cuenta atrás "BOSS: … EN n PTS", indicador circular del **rugido** (cuenta atrás), cartel grande "¡NIVEL n! – Mapa" y cartel rojo "¡PELIGRO!" al llegar un boss. Con boss: nombre, barra de vida (cambia de color si es vulnerable), segundos restantes, "¡VULNERABLE!" y la **pista de cómo vencerlo** abajo.
4. **Pausa** (`ui-04`): Continuar, Manual, Menú.
5. **Game Over** (`ui-05`): modo, puntos (grande), ¡NUEVO RÉCORD!, nivel, monedas ganadas, huevos, jefes, logros, total de monedas, récord, lista de logros conseguidos; Reintentar, Tienda, Menú.
6. **Tienda** (`ui-06`–`ui-08`): monedero, botón Ruleta, Volver y pestañas **Skins / Checkpoints / Editor**.
   - **Skins**: 16 tarjetas con vista previa animada, nombre, etiqueta de rareza con su color (Común `#d6d3cb`, Raro `#9cc9ff`, Épico `#c9a6ff`, Legendario `#ffd23f`, Supremo `#ff9de6`), efecto, rugido especial, precio y botón (Comprar / Bloqueada / Equipar / Equipada). El Emperador Solar va destacado. Debajo, las secciones "Exclusivas de logros" (con candado) y "Mis diseños".
   - **Checkpoints**: tarjeta por nivel con estados Bloqueado / Comprar / Sin monedas / Comprado.
   - **Editor**: vista previa grande, ranuras, nombre, patrones, colores por parte, fondo y suelo, efecto; Aleatorio, Deshacer, Restablecer y Guardar.
7. **Ruleta** (`ui-09`): rueda de 8 casillas (tamaño según su probabilidad), apuesta, +10 / +50 / +100 / Máximo / Reiniciar, Girar, mensaje de resultado, tabla de probabilidades, giro gratis diario con cuenta atrás y aviso de "solo monedas del juego".
8. **Logros** (`ui-10`): contador "Logros x/42 (n %)", filtros por categoría, cuadrícula de tarjetas (icono, nombre, descripción, recompensa, barra de progreso, fecha; los ocultos salen como «???») y botón Reiniciar progreso. Notificación pequeña en la esquina al desbloquear uno.
9. **Manual** (`ui-11`): índice de 12 secciones, contenido con tablas y mini animaciones, Anterior / Siguiente.
10. **Móvil** (`ui-12`, `ui-13`): todo debe funcionar en vertical a 390 px de ancho; en partida hay botones táctiles ▲ Carril, ▼ Carril, Rugido y ❚❚.

### 6.2 Qué necesito
- **Sistema de diseño**: colores (fondo, superficie, borde, texto, texto secundario, éxito, oro, peligro, morado, colores de rareza), tipografía y espaciados como **variables CSS**.
- **Tipografía pixel con licencia libre (OFL)**, por ejemplo Press Start 2P, Silkscreen, VT323 o Pixelify Sans. El juego funciona **sin internet**, así que la fuente irá incrustada en el archivo: elige una ligera y dime cuál. Usa una fuente para títulos y otra, más legible, para textos largos (manual, descripciones).
- **Componentes con todos sus estados** (normal, encima, pulsado, deshabilitado, seleccionado): botón (principal, oro, morado, fantasma, Equipada), tarjeta, pestaña, caja de estadística, etiqueta de rareza, tarjeta de skin (y la destacada), tarjeta de logro, barra de progreso, notificación y campo de texto.
- **HUD**: estilo de los textos del canvas (ahora llevan contorno negro), barra de boss, píldora de pista, anillo del rugido, corazones, iconos de power-up, carteles de nivel y de ¡PELIGRO!, y textos flotantes (+50, ¡PISOTÓN!, ¡PERFECTO!…).
- **Iconos pixel 16×16**: moneda, huevo, corazón lleno/vacío, escudo, imán, cámara lenta, turbo, rugido, trofeo, candado, sonido sí/no, pausa, flecha arriba/abajo, ruleta, libro (manual) e iconos de las 7 categorías de logros (Carrera, Jefes, Habilidad, Colección, Ruleta, Modos, Secretos).
- **Mockups** de cada pantalla a **1440 × 810** y **390 × 844**.

---

## 7. Formato de entrega (para que Claude Code lo pueda implementar)

```
diseno/
  tokens.css                      ← variables CSS (colores, fuentes, espaciados, sombras)
  fuentes/<fuente>.woff2 + LICENCIA
  ui/<pantalla>.html              ← maqueta HTML/CSS estática de cada pantalla (sin JavaScript)
  ui/iconos/<icono>.png           ← 16×16
  mockups/<pantalla>_1440.png y _390.png
  biomas/<id>/paleta.json         ← mismas claves que en la sección 3
  biomas/<id>/cielo.png           ← 450×108 (o un degradado en paleta.json)
  biomas/<id>/lejana.png          ← mosaico sin costuras, fondo transparente
  biomas/<id>/media.png
  biomas/<id>/cercana.png
  biomas/<id>/suelo.png           ← textura de suelo/carril en mosaico (opcional)
  biomas/<id>/animados.md         ← colores, tamaños y velocidad de partículas y animaciones
  biomas/<id>/mockup.png          ← el mapa montado a 1800×720 con raptor, obstáculos y HUD
  obstaculos/<tipo>_<mapa>_<tamaño>.png
  bosses/<id>/<pieza>_<estado>.png + pivotes.json + lamina.png
```

Ids de los mapas: `desert`, `jungle`, `volcano`, `glacier`, `night`, `beach`, `mushroom`, `ocean`, `graveyard`, `moon`.
Ids de los bosses: `escorpion`, `serpiente`, `golem`, `mamut`, `ptero`, `cangrejo`, `sapo`, `kraken`, `huesos`, `nave`.

### Límites
- Todo acabará **dentro de un único archivo HTML** que se abre con doble clic: nada de librerías, CDNs ni enlaces externos.
- **Presupuesto de peso**: unos 300 KB por mapa (todas sus capas), 150 KB por boss y 4–5 MB en total como mucho. Usa pocos colores por imagen (16–32) para que los PNG pesen poco.
- Con 60 fps, lo que se mueve lo anima el código: entrégalo como capas o fotogramas sueltos, no como GIF o vídeo.

### Si vas justo de tiempo, en este orden
1. `tokens.css` + fuente + mockups de **Menú, HUD y Tienda** (lo que más se ve).
2. `paleta.json` + `mockup.png` de los **10 mapas** (con solo esto ya puedo mejorar mucho el dibujo por código).
3. Capas PNG de los mapas.
4. Obstáculos.
5. Bosses por piezas.

---

## 8. Cosas que NO se pueden cambiar

- El **raptor y sus skins** (vienen de un kit aparte; solo pueden cambiar sus marcos en la tienda).
- El **tamaño de las cajas de choque** y la posición de los carriles (tabla 2.2 y 4.1).
- Rojo = peligro y amarillo = vulnerable.
- El contenido de cada pantalla (sección 6.1): se puede reorganizar, pero no quitar.
- El juego tiene que verse bien tanto en pantalla grande como en móvil vertical.
