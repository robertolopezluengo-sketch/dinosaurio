# Dino Runner · Jefes por piezas · Encargo para Claude Code

Sprites nuevos para los **10 bosses** de `dino-runner-v6.html`, hechos **por piezas** como pide el brief (sección 5): cuerpo, eslabones de cadena (cola, cuello, brazo, tentáculo) y pieza final (aguijón, puño, pinza, cabeza…), cada uno en su PNG y con su **pivote**.

**Solo cambia el dibujo.** La lógica de cada boss, sus estados, tiempos, cajas de choque, vidas y carriles se quedan **exactamente igual**.

## Paso 0: extraer los archivos

Guarda este documento en la carpeta del juego como `JEFES_PIEZAS.md` y ejecuta este script de Node para crear `diseno/bosses/`:

```js
const fs = require("fs"), path = require("path");
const md = fs.readFileSync("JEFES_PIEZAS.md", "utf8"), F = "`".repeat(3);
const re = new RegExp("### archivo: (\\S+)\\n\\n" + F + "\\w+\\n([\\s\\S]*?)\\n" + F + "\\n", "g");
for (const m of md.matchAll(re)) { fs.mkdirSync(path.dirname(m[1]), { recursive: true }); fs.writeFileSync(m[1], m[2] + "\n"); }
const block = md.split("<!-- PNG-" + "START -->")[1].split("<!-- PNG-" + "END -->")[0];
for (const line of block.split("\n")) {
  const m = line.match(/^(\S+\.png) ([A-Za-z0-9+/=]+)$/); if (!m) continue;
  fs.mkdirSync(path.dirname(m[1]), { recursive: true }); fs.writeFileSync(m[1], Buffer.from(m[2], "base64"));
}
```

Resultado (la estructura de la sección 7 del brief):

```
diseno/bosses/<id>/<pieza>_<estado>.png    ← una imagen por pieza y estado (o <pieza>.png si solo tiene uno)
diseno/bosses/<id>/pivotes.json            ← tamaños, pivotes, estados, cadenas y punto débil
diseno/bosses/comun/<proyectil|aviso>.png  ← proyectiles y avisos
diseno/bosses/comun/pivotes.json
```
Ids: `escorpion`, `serpiente`, `golem`, `mamut`, `ptero`, `cangrejo`, `sapo`, `kraken`, `huesos`, `nave`. Las láminas de referencia (`lamina.png`, cada boss montado en su mapa con todas sus piezas) van en el zip aparte.

## Cómo dibujar las piezas

1. **Escala:** 1 px de arte = **3 px lógicos**, como el raptor. Dibuja con `ctx.imageSmoothingEnabled = false`. En el carril de arriba, multiplica por 0,8 como ya hace el juego.
2. **Pivote:** cada pieza tiene `pivote_arte` (y `pivote_logico` = ×3) en su `pivotes.json`. Coloca la imagen de forma que **su pivote caiga en el punto donde el código ya pone esa pieza**:
   ```js
   ctx.drawImage(img, x - piv.x * 3 * esc, y - piv.y * 3 * esc, img.width * 3 * esc, img.height * 3 * esc);
   ```
   - Cuerpos: el pivote es la base (pies o cadera).
   - Eslabones: el centro.
   - Piezas finales: la unión con la cadena.
3. **Cadenas** (`cadenas` en pivotes.json): el código ya calcula la posición de cada eslabón. Dibuja en cada punto el eslabón indicado en `piezas`, en orden desde el ancla, que va de más grueso a más fino según `tamanos_logicos`. Al final va `pieza_final`. `punto_ancla` es el punto del cuerpo, en px de arte, de donde sale la cadena.
4. **Sin rotación:** los eslabones son redondos y las piezas finales cambian de **estado** en vez de girar. Si el código actual rota alguna pieza, quita esa rotación o deja solo pasos de 90°: rotar pixel art en ángulos libres lo emborrona.
5. **Estados:** usa la tabla de cada boss (`estados` en pivotes.json) para elegir qué PNG va con cada estado que ya existe en el código.
6. **Punto débil:** `punto_debil_en_estados` dice qué pieza y qué estado es vulnerable. El juego ya le pone el contorno y la flecha amarilla: mantenlo.
7. **Brillo opcional:** `emisivos` lista los colores que brillan (ojos, lava, almas, neón). Si quieres, dibuja detrás un halo de 3×3 px de arte de ese color al 20 % que lata con `sin(t/7)`.
8. **Orden de dibujo:** primero las cadenas y piezas de atrás (patas lejanas, cola), luego el cuerpo y por último la cabeza o pieza final y las piezas de delante. Las láminas muestran el montaje correcto.
9. **Cajas de choque:** no las toques. Los tamaños de las piezas ya siguen la tabla del brief (cuerpo, cabeza, puño, pinza…). Si algo queda desplazado respecto a su caja, ajusta solo el punto de dibujo y dímelo.
10. **Rendimiento:** carga las imágenes una vez al iniciar, desde `data:` URIs incrustadas en el HTML porque el juego funciona sin internet. Pesan unos 260 KB en total.

## Los 10 bosses

### Escorpión gigante · `escorpion` · mapa `desert` · mira a la derecha

| Estado del juego | Qué dibujar |
| --- | --- |
| reposo | cuerpo reposo/reposo_b + aguijon reposo |
| cola preparada | aguijon preparado (cola alzada) |
| aguijón clavado (vulnerable) | aguijon clavado |
| herido | cuerpo herido |
| derrota | cuerpo derrota (boca arriba), sin cola |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | reposo, reposo_b, herido, derrota | 189×57 | 0,18 | Base: esquina inferior izquierda (pies). Entra por la izquierda, detrás del raptor. |
| `segmento_cola_g` | unico | 21×21 | 3,3 | Segmento de la cola; pivote = centro |
| `segmento_cola_m` | unico | 18×18 | 3,3 | Segmento de la cola; pivote = centro |
| `segmento_cola_p` | unico | 15×15 | 2,2 | Segmento de la cola; pivote = centro |
| `aguijon` | reposo, preparado, **clavado** | 33×24 | 3,3 | Pieza final de la cola; pivote = donde se une al último segmento. «clavado» = PUNTO DÉBIL (el juego añade contorno y flecha amarilla) |
| `pinza` | reposo, abierta | 36×27 | 1,4 | Pinzas delante de la cabeza; pivote = muñeca |

Cadena **cola**: desde `cuerpo` punto [3, 4], 10 eslabones (22 → 14 px), termina en `aguijon`. La cola sale de la parte trasera-alta del cuerpo y se arquea por encima hacia la derecha.

Cadena **pinzas**: desde `cuerpo` punto [60, 10], 0 eslabones, termina en `pinza`. Dos pinzas: una en (60,7) y otra en (60,13) del cuerpo.

### Serpiente de lianas · `serpiente` · mapa `jungle` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| colgando | cabeza reposo |
| ataque desde arriba | cabeza ataque |
| escupir veneno | cabeza escupir |
| cabeza apoyada (vulnerable) | cabeza apoyada |
| herida | cabeza herida |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `segmento_g` | liso, hoja | 21×21 | 3,3 | Segmento del cuerpo; pivote = centro |
| `segmento_m` | liso, hoja | 18×18 | 3,3 | Segmento del cuerpo; pivote = centro |
| `segmento_p` | liso, hoja | 15×15 | 2,2 | Segmento del cuerpo; pivote = centro |
| `cabeza` | reposo, ataque, escupir, **apoyada**, herida | 63×33 | 19,4 | Pivote = nuca (lado derecho, donde se une al último segmento). Pinchos DEBAJO: no se puede pisar. «apoyada» = vulnerable al rugido |

Cadena **cuerpo**: desde `arriba-derecha de la pantalla`, 16 eslabones (16 → 22 (del techo hacia la cabeza) px), termina en `cabeza`. Alterna «liso» y «hoja» (1 de cada 3 con hoja).

### Golem de lava · `golem` · mapa `volcano` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| reposo | cabeza reposo + nucleo reposo + puno reposo |
| lanzar roca | cabeza enfadado + nucleo brillo + puno cerrado + roca |
| puñetazo | puno cerrado bajando |
| puño apoyado (quema) | puno ardiendo |
| herido | cuerpo herido + cabeza herido + nucleo apagado |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | reposo, herido | 135×99 | 22,32 | Pivote = centro de la base (cadera). El núcleo va encima, en (22,18) |
| `nucleo` | reposo, brillo, apagado | 27×27 | 4,4 | Núcleo brillante 28×28 lógicos; pivote = centro. «brillo» al cargar ataques, «apagado» al recibir daño |
| `cabeza` | reposo, enfadado, herido | 57×39 | 9,12 | Pivote = cuello (centro abajo) |
| `pierna` | unico | 33×51 | 5,0 | Dos piernas bajo el cuerpo; pivote = cadera (centro arriba) |
| `segmento_brazo` | unico | 24×24 | 4,4 | Eslabón del brazo-cadena; pivote = centro |
| `puno` | reposo, cerrado, ardiendo | 57×36 | 16,6 | Puño 56×36 lógicos; pivote = muñeca (lado derecho). «ardiendo» = puño apoyado: QUEMA, no pisar |
| `roca` | unico | 30×30 | 5,5 | Roca que lanza (y que el raptor devuelve con el rugido) |

Cadena **brazo**: desde `cuerpo` punto [4, 10], 5 eslabones, termina en `puno`. Brazo izquierdo (hacia el jugador). El derecho puede ser igual y quedarse quieto.

### Mamut de hielo · `mamut` · mapa `glacier` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| reposo | cabeza reposo |
| preparar embestida | cabeza carga |
| embestida | cabeza carga + patas a/b alternando |
| aturdido | cabeza aturdido + estrellas |
| herido | cuerpo herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | reposo, herido | 150×63 | 25,20 | Pivote = centro de la base. Cabeza en (2,6), patas en x 8/18/32/42 |
| `cabeza` | reposo, carga, aturdido | 51×45 | 15,6 | Pivote = cuello (derecha). «carga» = ojo ROJO (prepara/embiste) |
| `colmillo` | unico | 30×18 | 9,1 | Se dibuja delante de la cabeza en (4,9); pivote = raíz |
| `pata` | a, b | 18×30 | 3,0 | 4 patas; pivote = cadera. Alterna a/b al embestir |
| `estrellas` | unico | 39×15 | 6,4 | Aturdido: gira sobre la cabeza |

### Pterodáctilo sombra · `ptero` · mapa `night` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| vuelo | vuelo_1 → vuelo_2 → vuelo_3 → vuelo_2 (cada 6 frames) |
| picado | picado |
| rasante brillante | rasante |
| herido | herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | vuelo_1, vuelo_2, vuelo_3, picado, **rasante**, herido | 150×66 | 25,11 | Sprite completo (envergadura 150 lógicos). Pivote = centro del cuerpo. «rasante» brillante = VULNERABLE (cabezazo desde abajo) |

### Rey cangrejo · `cangrejo` · mapa `beach` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| reposo | cuerpo reposo/reposo_b + pinza reposo |
| pinzazo | pinza abierta (sube) → apoyada (golpea) |
| pinza apoyada | pinza apoyada |
| pinza volteada | pinza volteada |
| herido | cuerpo herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | reposo, reposo_b, herido | 150×63 | 26,20 | Ojos en pedúnculos, corona y 3 pares de patas. Pivote = centro de la base |
| `segmento_brazo` | unico | 21×18 | 3,3 | Eslabón del brazo de la pinza |
| `pinza` | reposo, abierta, apoyada, **volteada** | 63×33 | 19,5 | Pinza gigante 62×34 lógicos; pivote = muñeca (derecha). «volteada» enseña la barriga rosa = VULNERABLE al pisotón |

Cadena **brazo**: desde `cuerpo` punto [6, 10], 4 eslabones, termina en `pinza`

### Sapo gigante · `sapo` · mapa `mushroom` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| sentado | sentado |
| salto (aire) | salto |
| aterrizaje | aterrizaje |
| lengua | lengua + cadena de lengua |
| herido | herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | sentado, salto, aterrizaje, lengua, herido | 111×57 | 18,18 | Cuerpo 110×56 lógicos. Verrugas moradas brillantes = piel venenosa (no tocar). Pivote = centro de la base |
| `lengua_segmento` | unico | 9×9 | 1,1 | Se repite en línea desde la boca (2,9) |
| `lengua_punta` | unico | 15×15 | 4,2 |  |

Cadena **lengua**: desde `cuerpo` punto [2, 9], variable (hasta 30) eslabones, termina en `lengua_punta`

### Kraken abisal · `kraken` · mapa `ocean` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| cabeza en reposo | cabeza reposo |
| tentáculo arriba | punta reposo (cadena alzada) |
| golpe | cabeza enfadado + punta golpe |
| tentáculo apoyado (se corta) | punta apoyada → cortada |
| herido | cabeza herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cabeza` | reposo, enfadado, herido | 144×99 | 26,0 | Cabeza 144×100 lógicos asomando arriba a la derecha, con 5 tentáculos colgando. Pivote = centro arriba |
| `segmento_g` | unico | 21×21 | 3,3 |  |
| `segmento_m` | unico | 18×18 | 3,3 |  |
| `segmento_p` | unico | 15×15 | 2,2 |  |
| `punta` | reposo, golpe, **apoyada**, cortada | 45×24 | 14,3 | Punta 44×24 lógicos; pivote = unión (derecha). «apoyada» = VULNERABLE al corte deslizándose; «cortada» tras el corte |
| `barredor` | unico | 90×27 | 29,2 | Tentáculo barredor 90×26 lógicos (a ras de suelo) |
| `tinta` | unico | 30×24 | 5,4 | Mancha de tinta |

Cadena **tentaculo_largo**: desde `cabeza` punto [12, 26], 14 eslabones, termina en `punta`

### Rey de los huesos · `huesos` · mapa `graveyard` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| reposo | craneo reposo + mandibula cerrada + escudo cargas_3 |
| mordisco | craneo mordisco + mandibula abierta |
| cráneo apoyado | craneo apoyado |
| escudo activo / roto | escudo cargas_3/2/1 → roto |
| herido | cuerpo herido + craneo herido |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `cuerpo` | reposo, herido | 120×72 | 20,23 | Patas, costillas y columna. Cola desde (38,6); cuello desde (4,3). Pivote = centro de la base |
| `vertebra_g` | unico | 15×15 | 2,2 |  |
| `vertebra_m` | unico | 12×12 | 2,2 |  |
| `vertebra_p` | unico | 9×9 | 1,1 |  |
| `bracito` | unico | 18×15 | 5,0 | Bracito bajo el cuello, en (6,9) del cuerpo |
| `craneo` | reposo, mordisco, **apoyado**, herido | 81×33 | 25,6 | Cráneo 80×34 lógicos, con corona y ojo verde; pivote = unión con el cuello (derecha). «apoyado» con el escudo roto = VULNERABLE a pisarlo |
| `mandibula` | cerrada, abierta | 69×12 | 21,0 | Mandíbula 70×12 lógicos bajo el cráneo, en (2,10); «abierta» = baja 4 px de arte al morder |
| `escudo` | cargas_3, cargas_2, cargas_1, roto | 183×135 | 30,22 | Escudo de almas (elipse) centrado en el pecho; un orbe por carga. «roto» = discontinuo |

Cadena **cuello**: desde `cuerpo` punto [4, 3], 4 eslabones, termina en `craneo`

Cadena **cola**: desde `cuerpo` punto [38, 6], 8 eslabones

### Nave nodriza · `nave` · mapa `moon` · mira a la izquierda

| Estado del juego | Qué dibujar |
| --- | --- |
| vuelo | platillo fase1 + cupula normal + luces on/off alternando |
| disparo | canon disparo |
| rayo abductor | emisor + proyectil rayo |
| aterrizada | patas aterrizada |
| fases 1-2-3 | platillo fase1/fase2/fase3 |
| herida | platillo herido + luces alerta |

| Pieza | Estados | Tamaño (lógico) | Pivote (arte) | Nota |
| --- | --- | --- | --- | --- |
| `platillo` | fase1, fase2, fase3, herido | 123×27 | 20,4 | Platillo 124×26 lógicos; pivote = centro. fase2 con grietas, fase3 pierde una placa y enseña un chispazo rojo |
| `cupula` | normal, **agrietada**, **brillante** | 60×27 | 10,8 | Cúpula 60×28 lógicos sobre el platillo en (20,0). Fase 2: pisarla («agrietada» tras el golpe). Fase 3: «brillante» al pasar rasante |
| `luz` | on, off, alerta | 9×9 | 1,1 | 6 luces en x 6,12,18,24,30,36 del platillo (y 4); parpadean |
| `patas` | aterrizada | 123×24 | 20,0 | Al aterrizar, bajo el platillo |
| `canon` | reposo, disparo | 24×12 | 7,1 | Cañón láser bajo el platillo (izquierda) |
| `emisor` | rayo | 24×9 | 4,0 | Emisor del rayo abductor bajo el centro |

Los estados en **negrita** son el punto débil.

### Proyectiles y avisos (`comun/`)

| Archivo | Tamaño (lógico) | Uso |
| --- | --- | --- |
| `pincho.png` | 27×15 | Escorpión: pinchos que caen |
| `veneno.png` | 27×18 | Serpiente: veneno verde |
| `roca_lava.png` | 30×30 | Golem: roca de lava |
| `fragmento_hielo.png` | 30×21 | Mamut: fragmentos de hielo |
| `pluma.png` | 30×18 | Pterodáctilo: plumas |
| `burbuja.png` | 21×21 | Cangrejo: burbujas |
| `tinta.png` | 30×24 | Kraken: tinta |
| `hueso.png` | 33×15 | Rey de los huesos: huesos en arco |
| `fuego_fantasma.png` | 21×27 | Rey de los huesos: fuegos fantasma |
| `mininave.png` | 39×18 | Nave: mininaves |
| `laser_tramo.png` | 24×9 | Nave: láser rosa (tramo que se repite en horizontal) |
| `rayo_tramo.png` | 72×12 | Nave: rayo abductor verde (tramo que se repite en vertical) |
| `aviso_sombra.png` | 60×24 | Aviso: sombra roja con «!» (golpe desde arriba) |
| `aviso_flecha.png` | 36×27 | Aviso: flecha roja (algo viene por ese carril) |
| `aviso_diana.png` | 39×39 | Aviso: diana roja (proyectil en arco) |
| `aviso_linea.png` | 24×6 | Aviso: línea roja parpadeante (láser); tramo de 8 px de arte que se repite |

Los avisos siguen siendo **rojos**. `laser_tramo`, `rayo_tramo` y `aviso_linea` son tramos que se repiten para formar líneas de cualquier longitud.

## Comprobación

- [ ] Los 10 bosses se ven con las piezas nuevas, montados como en sus láminas.
- [ ] Cada estado del juego muestra su PNG (aguijón clavado, cabeza apoyada, puño ardiendo, ojo rojo del mamut, rasante dorado, pinza volteada, lengua, tentáculo apoyado o cortado, escudo con 3/2/1 cargas o roto, fases de la nave).
- [ ] El contorno y la flecha amarilla del punto débil siguen apareciendo.
- [ ] Cajas de choque, tiempos y carriles idénticos a antes. Sin errores en consola y a 60 fps.

---

## Archivos

### archivo: diseno/bosses/escorpion/pivotes.json

```json
{
 "boss": "escorpion",
 "nombre": "Escorpión gigante",
 "mapa": "desert",
 "mira": "derecha",
 "estados": {
  "reposo": "cuerpo reposo/reposo_b + aguijon reposo",
  "cola preparada": "aguijon preparado (cola alzada)",
  "aguijón clavado (vulnerable)": "aguijon clavado",
  "herido": "cuerpo herido",
  "derrota": "cuerpo derrota (boca arriba), sin cola"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "reposo": "cuerpo_reposo.png",
    "reposo_b": "cuerpo_reposo_b.png",
    "herido": "cuerpo_herido.png",
    "derrota": "cuerpo_derrota.png"
   },
   "tamano_arte": [
    63,
    19
   ],
   "tamano_logico": [
    189,
    57
   ],
   "pivote_arte": [
    0,
    18
   ],
   "pivote_logico": [
    0,
    54
   ],
   "emisivos": {
    "reposo": [
     "#ffc0a0",
     "#ffffff"
    ],
    "reposo_b": [
     "#ffc0a0",
     "#ffffff"
    ]
   },
   "nota": "Base: esquina inferior izquierda (pies). Entra por la izquierda, detrás del raptor."
  },
  "segmento_cola_g": {
   "archivos": {
    "unico": "segmento_cola_g.png"
   },
   "tamano_arte": [
    7,
    7
   ],
   "tamano_logico": [
    21,
    21
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {},
   "nota": "Segmento de la cola; pivote = centro"
  },
  "segmento_cola_m": {
   "archivos": {
    "unico": "segmento_cola_m.png"
   },
   "tamano_arte": [
    6,
    6
   ],
   "tamano_logico": [
    18,
    18
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {},
   "nota": "Segmento de la cola; pivote = centro"
  },
  "segmento_cola_p": {
   "archivos": {
    "unico": "segmento_cola_p.png"
   },
   "tamano_arte": [
    5,
    5
   ],
   "tamano_logico": [
    15,
    15
   ],
   "pivote_arte": [
    2,
    2
   ],
   "pivote_logico": [
    6,
    6
   ],
   "emisivos": {},
   "nota": "Segmento de la cola; pivote = centro"
  },
  "aguijon": {
   "archivos": {
    "reposo": "aguijon_reposo.png",
    "preparado": "aguijon_preparado.png",
    "clavado": "aguijon_clavado.png"
   },
   "tamano_arte": [
    11,
    8
   ],
   "tamano_logico": [
    33,
    24
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {
    "reposo": [
     "#f0b8ff",
     "#ffffff"
    ],
    "preparado": [
     "#f0b8ff",
     "#ffffff"
    ],
    "clavado": [
     "#f0b8ff"
    ]
   },
   "punto_debil_en_estados": [
    "clavado"
   ],
   "nota": "Pieza final de la cola; pivote = donde se une al último segmento. «clavado» = PUNTO DÉBIL (el juego añade contorno y flecha amarilla)"
  },
  "pinza": {
   "archivos": {
    "reposo": "pinza_reposo.png",
    "abierta": "pinza_abierta.png"
   },
   "tamano_arte": [
    12,
    9
   ],
   "tamano_logico": [
    36,
    27
   ],
   "pivote_arte": [
    1,
    4
   ],
   "pivote_logico": [
    3,
    12
   ],
   "emisivos": {},
   "nota": "Pinzas delante de la cabeza; pivote = muñeca"
  }
 },
 "cadenas": {
  "cola": {
   "ancla": "cuerpo",
   "punto_ancla": [
    3,
    4
   ],
   "segmentos": 10,
   "piezas": [
    "segmento_cola_g",
    "segmento_cola_g",
    "segmento_cola_g",
    "segmento_cola_m",
    "segmento_cola_m",
    "segmento_cola_m",
    "segmento_cola_m",
    "segmento_cola_p",
    "segmento_cola_p",
    "segmento_cola_p"
   ],
   "tamanos_logicos": "22 → 14",
   "pieza_final": "aguijon",
   "nota": "La cola sale de la parte trasera-alta del cuerpo y se arquea por encima hacia la derecha."
  },
  "pinzas": {
   "ancla": "cuerpo",
   "punto_ancla": [
    60,
    10
   ],
   "segmentos": 0,
   "pieza_final": "pinza",
   "nota": "Dos pinzas: una en (60,7) y otra en (60,13) del cuerpo."
  }
 }
}
```

### archivo: diseno/bosses/serpiente/pivotes.json

```json
{
 "boss": "serpiente",
 "nombre": "Serpiente de lianas",
 "mapa": "jungle",
 "mira": "izquierda",
 "estados": {
  "colgando": "cabeza reposo",
  "ataque desde arriba": "cabeza ataque",
  "escupir veneno": "cabeza escupir",
  "cabeza apoyada (vulnerable)": "cabeza apoyada",
  "herida": "cabeza herida"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "segmento_g": {
   "archivos": {
    "liso": "segmento_g_liso.png",
    "hoja": "segmento_g_hoja.png"
   },
   "tamano_arte": [
    7,
    7
   ],
   "tamano_logico": [
    21,
    21
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {},
   "nota": "Segmento del cuerpo; pivote = centro"
  },
  "segmento_m": {
   "archivos": {
    "liso": "segmento_m_liso.png",
    "hoja": "segmento_m_hoja.png"
   },
   "tamano_arte": [
    6,
    6
   ],
   "tamano_logico": [
    18,
    18
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {},
   "nota": "Segmento del cuerpo; pivote = centro"
  },
  "segmento_p": {
   "archivos": {
    "liso": "segmento_p_liso.png",
    "hoja": "segmento_p_hoja.png"
   },
   "tamano_arte": [
    5,
    5
   ],
   "tamano_logico": [
    15,
    15
   ],
   "pivote_arte": [
    2,
    2
   ],
   "pivote_logico": [
    6,
    6
   ],
   "emisivos": {},
   "nota": "Segmento del cuerpo; pivote = centro"
  },
  "cabeza": {
   "archivos": {
    "reposo": "cabeza_reposo.png",
    "ataque": "cabeza_ataque.png",
    "escupir": "cabeza_escupir.png",
    "apoyada": "cabeza_apoyada.png",
    "herida": "cabeza_herida.png"
   },
   "tamano_arte": [
    21,
    11
   ],
   "tamano_logico": [
    63,
    33
   ],
   "pivote_arte": [
    19,
    4
   ],
   "pivote_logico": [
    57,
    12
   ],
   "emisivos": {
    "reposo": [
     "#fff08a"
    ],
    "ataque": [
     "#fff08a"
    ],
    "escupir": [
     "#fff08a",
     "#dcff9a",
     "#ffffff"
    ]
   },
   "punto_debil_en_estados": [
    "apoyada"
   ],
   "nota": "Pivote = nuca (lado derecho, donde se une al último segmento). Pinchos DEBAJO: no se puede pisar. «apoyada» = vulnerable al rugido"
  }
 },
 "cadenas": {
  "cuerpo": {
   "ancla": "arriba-derecha de la pantalla",
   "segmentos": 16,
   "piezas": [
    "segmento_p",
    "segmento_p",
    "segmento_p",
    "segmento_p",
    "segmento_p",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_g",
    "segmento_g",
    "segmento_g",
    "segmento_g",
    "segmento_g"
   ],
   "tamanos_logicos": "16 → 22 (del techo hacia la cabeza)",
   "pieza_final": "cabeza",
   "nota": "Alterna «liso» y «hoja» (1 de cada 3 con hoja)."
  }
 }
}
```

### archivo: diseno/bosses/golem/pivotes.json

```json
{
 "boss": "golem",
 "nombre": "Golem de lava",
 "mapa": "volcano",
 "mira": "izquierda",
 "estados": {
  "reposo": "cabeza reposo + nucleo reposo + puno reposo",
  "lanzar roca": "cabeza enfadado + nucleo brillo + puno cerrado + roca",
  "puñetazo": "puno cerrado bajando",
  "puño apoyado (quema)": "puno ardiendo",
  "herido": "cuerpo herido + cabeza herido + nucleo apagado"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "reposo": "cuerpo_reposo.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    45,
    33
   ],
   "tamano_logico": [
    135,
    99
   ],
   "pivote_arte": [
    22,
    32
   ],
   "pivote_logico": [
    66,
    96
   ],
   "emisivos": {
    "reposo": [
     "#ff9a2e"
    ]
   },
   "nota": "Pivote = centro de la base (cadera). El núcleo va encima, en (22,18)"
  },
  "nucleo": {
   "archivos": {
    "reposo": "nucleo_reposo.png",
    "brillo": "nucleo_brillo.png",
    "apagado": "nucleo_apagado.png"
   },
   "tamano_arte": [
    9,
    9
   ],
   "tamano_logico": [
    27,
    27
   ],
   "pivote_arte": [
    4,
    4
   ],
   "pivote_logico": [
    12,
    12
   ],
   "emisivos": {
    "reposo": [
     "#ff9a2e",
     "#ffe066"
    ],
    "brillo": [
     "#ff9a2e",
     "#ffe066",
     "#fff08a",
     "#ffffff"
    ]
   },
   "nota": "Núcleo brillante 28×28 lógicos; pivote = centro. «brillo» al cargar ataques, «apagado» al recibir daño"
  },
  "cabeza": {
   "archivos": {
    "reposo": "cabeza_reposo.png",
    "enfadado": "cabeza_enfadado.png",
    "herido": "cabeza_herido.png"
   },
   "tamano_arte": [
    19,
    13
   ],
   "tamano_logico": [
    57,
    39
   ],
   "pivote_arte": [
    9,
    12
   ],
   "pivote_logico": [
    27,
    36
   ],
   "emisivos": {
    "reposo": [
     "#ff9a2e"
    ],
    "enfadado": [
     "#ff9a2e",
     "#fff08a"
    ],
    "herido": [
     "#ff9a2e"
    ]
   },
   "nota": "Pivote = cuello (centro abajo)"
  },
  "pierna": {
   "archivos": {
    "unico": "pierna.png"
   },
   "tamano_arte": [
    11,
    17
   ],
   "tamano_logico": [
    33,
    51
   ],
   "pivote_arte": [
    5,
    0
   ],
   "pivote_logico": [
    15,
    0
   ],
   "emisivos": {
    "unico": [
     "#ff9a2e"
    ]
   },
   "nota": "Dos piernas bajo el cuerpo; pivote = cadera (centro arriba)"
  },
  "segmento_brazo": {
   "archivos": {
    "unico": "segmento_brazo.png"
   },
   "tamano_arte": [
    8,
    8
   ],
   "tamano_logico": [
    24,
    24
   ],
   "pivote_arte": [
    4,
    4
   ],
   "pivote_logico": [
    12,
    12
   ],
   "emisivos": {
    "unico": [
     "#ff9a2e"
    ]
   },
   "nota": "Eslabón del brazo-cadena; pivote = centro"
  },
  "puno": {
   "archivos": {
    "reposo": "puno_reposo.png",
    "cerrado": "puno_cerrado.png",
    "ardiendo": "puno_ardiendo.png"
   },
   "tamano_arte": [
    19,
    12
   ],
   "tamano_logico": [
    57,
    36
   ],
   "pivote_arte": [
    16,
    6
   ],
   "pivote_logico": [
    48,
    18
   ],
   "emisivos": {
    "reposo": [
     "#ff9a2e"
    ],
    "cerrado": [
     "#ff9a2e"
    ],
    "ardiendo": [
     "#ff9a2e",
     "#ffe066"
    ]
   },
   "nota": "Puño 56×36 lógicos; pivote = muñeca (lado derecho). «ardiendo» = puño apoyado: QUEMA, no pisar"
  },
  "roca": {
   "archivos": {
    "unico": "roca.png"
   },
   "tamano_arte": [
    10,
    10
   ],
   "tamano_logico": [
    30,
    30
   ],
   "pivote_arte": [
    5,
    5
   ],
   "pivote_logico": [
    15,
    15
   ],
   "emisivos": {
    "unico": [
     "#ff9a2e"
    ]
   },
   "nota": "Roca que lanza (y que el raptor devuelve con el rugido)"
  }
 },
 "cadenas": {
  "brazo": {
   "ancla": "cuerpo",
   "punto_ancla": [
    4,
    10
   ],
   "segmentos": 5,
   "piezas": [
    "segmento_brazo",
    "segmento_brazo",
    "segmento_brazo",
    "segmento_brazo",
    "segmento_brazo"
   ],
   "pieza_final": "puno",
   "nota": "Brazo izquierdo (hacia el jugador). El derecho puede ser igual y quedarse quieto."
  }
 }
}
```

### archivo: diseno/bosses/mamut/pivotes.json

```json
{
 "boss": "mamut",
 "nombre": "Mamut de hielo",
 "mapa": "glacier",
 "mira": "izquierda",
 "estados": {
  "reposo": "cabeza reposo",
  "preparar embestida": "cabeza carga",
  "embestida": "cabeza carga + patas a/b alternando",
  "aturdido": "cabeza aturdido + estrellas",
  "herido": "cuerpo herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "reposo": "cuerpo_reposo.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    50,
    21
   ],
   "tamano_logico": [
    150,
    63
   ],
   "pivote_arte": [
    25,
    20
   ],
   "pivote_logico": [
    75,
    60
   ],
   "emisivos": {},
   "nota": "Pivote = centro de la base. Cabeza en (2,6), patas en x 8/18/32/42"
  },
  "cabeza": {
   "archivos": {
    "reposo": "cabeza_reposo.png",
    "carga": "cabeza_carga.png",
    "aturdido": "cabeza_aturdido.png"
   },
   "tamano_arte": [
    17,
    15
   ],
   "tamano_logico": [
    51,
    45
   ],
   "pivote_arte": [
    15,
    6
   ],
   "pivote_logico": [
    45,
    18
   ],
   "emisivos": {
    "reposo": [
     "#dcffff"
    ],
    "carga": [
     "#ffb0b0"
    ]
   },
   "nota": "Pivote = cuello (derecha). «carga» = ojo ROJO (prepara/embiste)"
  },
  "colmillo": {
   "archivos": {
    "unico": "colmillo.png"
   },
   "tamano_arte": [
    10,
    6
   ],
   "tamano_logico": [
    30,
    18
   ],
   "pivote_arte": [
    9,
    1
   ],
   "pivote_logico": [
    27,
    3
   ],
   "emisivos": {},
   "nota": "Se dibuja delante de la cabeza en (4,9); pivote = raíz"
  },
  "pata": {
   "archivos": {
    "a": "pata_a.png",
    "b": "pata_b.png"
   },
   "tamano_arte": [
    6,
    10
   ],
   "tamano_logico": [
    18,
    30
   ],
   "pivote_arte": [
    3,
    0
   ],
   "pivote_logico": [
    9,
    0
   ],
   "emisivos": {},
   "nota": "4 patas; pivote = cadera. Alterna a/b al embestir"
  },
  "estrellas": {
   "archivos": {
    "unico": "estrellas.png"
   },
   "tamano_arte": [
    13,
    5
   ],
   "tamano_logico": [
    39,
    15
   ],
   "pivote_arte": [
    6,
    4
   ],
   "pivote_logico": [
    18,
    12
   ],
   "emisivos": {
    "unico": [
     "#ffffff",
     "#ffffff"
    ]
   },
   "nota": "Aturdido: gira sobre la cabeza"
  }
 },
 "cadenas": {}
}
```

### archivo: diseno/bosses/ptero/pivotes.json

```json
{
 "boss": "ptero",
 "nombre": "Pterodáctilo sombra",
 "mapa": "night",
 "mira": "izquierda",
 "estados": {
  "vuelo": "vuelo_1 → vuelo_2 → vuelo_3 → vuelo_2 (cada 6 frames)",
  "picado": "picado",
  "rasante brillante": "rasante",
  "herido": "herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "vuelo_1": "cuerpo_vuelo_1.png",
    "vuelo_2": "cuerpo_vuelo_2.png",
    "vuelo_3": "cuerpo_vuelo_3.png",
    "picado": "cuerpo_picado.png",
    "rasante": "cuerpo_rasante.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    50,
    22
   ],
   "tamano_logico": [
    150,
    66
   ],
   "pivote_arte": [
    25,
    11
   ],
   "pivote_logico": [
    75,
    33
   ],
   "emisivos": {
    "vuelo_1": [
     "#e8c0ff",
     "#ffc0c8",
     "#ffffff"
    ],
    "vuelo_2": [
     "#ffc0c8",
     "#e8c0ff",
     "#ffffff"
    ],
    "vuelo_3": [
     "#ffc0c8",
     "#ffffff",
     "#e8c0ff"
    ],
    "picado": [
     "#e8c0ff",
     "#ffc0c8",
     "#ffffff"
    ],
    "rasante": [
     "#ffc0c8",
     "#ffffff",
     "#fff08a"
    ],
    "herido": [
     "#e8c0ff"
    ]
   },
   "punto_debil_en_estados": [
    "rasante"
   ],
   "nota": "Sprite completo (envergadura 150 lógicos). Pivote = centro del cuerpo. «rasante» brillante = VULNERABLE (cabezazo desde abajo)"
  }
 },
 "cadenas": {}
}
```

### archivo: diseno/bosses/cangrejo/pivotes.json

```json
{
 "boss": "cangrejo",
 "nombre": "Rey cangrejo",
 "mapa": "beach",
 "mira": "izquierda",
 "estados": {
  "reposo": "cuerpo reposo/reposo_b + pinza reposo",
  "pinzazo": "pinza abierta (sube) → apoyada (golpea)",
  "pinza apoyada": "pinza apoyada",
  "pinza volteada": "pinza volteada",
  "herido": "cuerpo herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "reposo": "cuerpo_reposo.png",
    "reposo_b": "cuerpo_reposo_b.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    50,
    21
   ],
   "tamano_logico": [
    150,
    63
   ],
   "pivote_arte": [
    26,
    20
   ],
   "pivote_logico": [
    78,
    60
   ],
   "emisivos": {
    "reposo": [
     "#fff08a",
     "#ffffff",
     "#aef6ff"
    ],
    "reposo_b": [
     "#fff08a",
     "#ffffff",
     "#aef6ff"
    ],
    "herido": [
     "#fff08a",
     "#ffffff",
     "#aef6ff"
    ]
   },
   "nota": "Ojos en pedúnculos, corona y 3 pares de patas. Pivote = centro de la base"
  },
  "segmento_brazo": {
   "archivos": {
    "unico": "segmento_brazo.png"
   },
   "tamano_arte": [
    7,
    6
   ],
   "tamano_logico": [
    21,
    18
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {},
   "nota": "Eslabón del brazo de la pinza"
  },
  "pinza": {
   "archivos": {
    "reposo": "pinza_reposo.png",
    "abierta": "pinza_abierta.png",
    "apoyada": "pinza_apoyada.png",
    "volteada": "pinza_volteada.png"
   },
   "tamano_arte": [
    21,
    11
   ],
   "tamano_logico": [
    63,
    33
   ],
   "pivote_arte": [
    19,
    5
   ],
   "pivote_logico": [
    57,
    15
   ],
   "emisivos": {},
   "punto_debil_en_estados": [
    "volteada"
   ],
   "nota": "Pinza gigante 62×34 lógicos; pivote = muñeca (derecha). «volteada» enseña la barriga rosa = VULNERABLE al pisotón"
  }
 },
 "cadenas": {
  "brazo": {
   "ancla": "cuerpo",
   "punto_ancla": [
    6,
    10
   ],
   "segmentos": 4,
   "piezas": [
    "segmento_brazo",
    "segmento_brazo",
    "segmento_brazo",
    "segmento_brazo"
   ],
   "pieza_final": "pinza"
  }
 }
}
```

### archivo: diseno/bosses/sapo/pivotes.json

```json
{
 "boss": "sapo",
 "nombre": "Sapo gigante",
 "mapa": "mushroom",
 "mira": "izquierda",
 "estados": {
  "sentado": "sentado",
  "salto (aire)": "salto",
  "aterrizaje": "aterrizaje",
  "lengua": "lengua + cadena de lengua",
  "herido": "herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "sentado": "cuerpo_sentado.png",
    "salto": "cuerpo_salto.png",
    "aterrizaje": "cuerpo_aterrizaje.png",
    "lengua": "cuerpo_lengua.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    37,
    19
   ],
   "tamano_logico": [
    111,
    57
   ],
   "pivote_arte": [
    18,
    18
   ],
   "pivote_logico": [
    54,
    54
   ],
   "emisivos": {
    "sentado": [
     "#fff08a",
     "#f0b0ff",
     "#ffffff"
    ],
    "salto": [
     "#fff08a",
     "#f0b0ff",
     "#ffffff"
    ],
    "aterrizaje": [
     "#fff08a",
     "#f0b0ff",
     "#ffffff"
    ],
    "lengua": [
     "#fff08a",
     "#f0b0ff",
     "#ffffff"
    ],
    "herido": [
     "#fff08a",
     "#f0b0ff",
     "#ffffff"
    ]
   },
   "nota": "Cuerpo 110×56 lógicos. Verrugas moradas brillantes = piel venenosa (no tocar). Pivote = centro de la base"
  },
  "lengua_segmento": {
   "archivos": {
    "unico": "lengua_segmento.png"
   },
   "tamano_arte": [
    3,
    3
   ],
   "tamano_logico": [
    9,
    9
   ],
   "pivote_arte": [
    1,
    1
   ],
   "pivote_logico": [
    3,
    3
   ],
   "emisivos": {},
   "nota": "Se repite en línea desde la boca (2,9)"
  },
  "lengua_punta": {
   "archivos": {
    "unico": "lengua_punta.png"
   },
   "tamano_arte": [
    5,
    5
   ],
   "tamano_logico": [
    15,
    15
   ],
   "pivote_arte": [
    4,
    2
   ],
   "pivote_logico": [
    12,
    6
   ],
   "emisivos": {}
  }
 },
 "cadenas": {
  "lengua": {
   "ancla": "cuerpo",
   "punto_ancla": [
    2,
    9
   ],
   "segmentos": "variable (hasta 30)",
   "piezas": [
    "lengua_segmento"
   ],
   "pieza_final": "lengua_punta"
  }
 }
}
```

### archivo: diseno/bosses/kraken/pivotes.json

```json
{
 "boss": "kraken",
 "nombre": "Kraken abisal",
 "mapa": "ocean",
 "mira": "izquierda",
 "estados": {
  "cabeza en reposo": "cabeza reposo",
  "tentáculo arriba": "punta reposo (cadena alzada)",
  "golpe": "cabeza enfadado + punta golpe",
  "tentáculo apoyado (se corta)": "punta apoyada → cortada",
  "herido": "cabeza herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cabeza": {
   "archivos": {
    "reposo": "cabeza_reposo.png",
    "enfadado": "cabeza_enfadado.png",
    "herido": "cabeza_herido.png"
   },
   "tamano_arte": [
    48,
    33
   ],
   "tamano_logico": [
    144,
    99
   ],
   "pivote_arte": [
    26,
    0
   ],
   "pivote_logico": [
    78,
    0
   ],
   "emisivos": {
    "reposo": [
     "#b0fff2",
     "#ffffff",
     "#fff08a",
     "#ffffff"
    ],
    "enfadado": [
     "#b0fff2",
     "#ffffff",
     "#fff08a",
     "#ffffff"
    ],
    "herido": [
     "#b0fff2",
     "#ffffff",
     "#fff08a",
     "#ffffff"
    ]
   },
   "nota": "Cabeza 144×100 lógicos asomando arriba a la derecha, con 5 tentáculos colgando. Pivote = centro arriba"
  },
  "segmento_g": {
   "archivos": {
    "unico": "segmento_g.png"
   },
   "tamano_arte": [
    7,
    7
   ],
   "tamano_logico": [
    21,
    21
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {}
  },
  "segmento_m": {
   "archivos": {
    "unico": "segmento_m.png"
   },
   "tamano_arte": [
    6,
    6
   ],
   "tamano_logico": [
    18,
    18
   ],
   "pivote_arte": [
    3,
    3
   ],
   "pivote_logico": [
    9,
    9
   ],
   "emisivos": {}
  },
  "segmento_p": {
   "archivos": {
    "unico": "segmento_p.png"
   },
   "tamano_arte": [
    5,
    5
   ],
   "tamano_logico": [
    15,
    15
   ],
   "pivote_arte": [
    2,
    2
   ],
   "pivote_logico": [
    6,
    6
   ],
   "emisivos": {}
  },
  "punta": {
   "archivos": {
    "reposo": "punta_reposo.png",
    "golpe": "punta_golpe.png",
    "apoyada": "punta_apoyada.png",
    "cortada": "punta_cortada.png"
   },
   "tamano_arte": [
    15,
    8
   ],
   "tamano_logico": [
    45,
    24
   ],
   "pivote_arte": [
    14,
    3
   ],
   "pivote_logico": [
    42,
    9
   ],
   "emisivos": {},
   "punto_debil_en_estados": [
    "apoyada"
   ],
   "nota": "Punta 44×24 lógicos; pivote = unión (derecha). «apoyada» = VULNERABLE al corte deslizándose; «cortada» tras el corte"
  },
  "barredor": {
   "archivos": {
    "unico": "barredor.png"
   },
   "tamano_arte": [
    30,
    9
   ],
   "tamano_logico": [
    90,
    27
   ],
   "pivote_arte": [
    29,
    2
   ],
   "pivote_logico": [
    87,
    6
   ],
   "emisivos": {},
   "nota": "Tentáculo barredor 90×26 lógicos (a ras de suelo)"
  },
  "tinta": {
   "archivos": {
    "unico": "tinta.png"
   },
   "tamano_arte": [
    10,
    8
   ],
   "tamano_logico": [
    30,
    24
   ],
   "pivote_arte": [
    5,
    4
   ],
   "pivote_logico": [
    15,
    12
   ],
   "emisivos": {},
   "nota": "Mancha de tinta"
  }
 },
 "cadenas": {
  "tentaculo_largo": {
   "ancla": "cabeza",
   "punto_ancla": [
    12,
    26
   ],
   "segmentos": 14,
   "piezas": [
    "segmento_g",
    "segmento_g",
    "segmento_g",
    "segmento_g",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_m",
    "segmento_p",
    "segmento_p",
    "segmento_p",
    "segmento_p",
    "segmento_p"
   ],
   "pieza_final": "punta"
  }
 }
}
```

### archivo: diseno/bosses/huesos/pivotes.json

```json
{
 "boss": "huesos",
 "nombre": "Rey de los huesos",
 "mapa": "graveyard",
 "mira": "izquierda",
 "estados": {
  "reposo": "craneo reposo + mandibula cerrada + escudo cargas_3",
  "mordisco": "craneo mordisco + mandibula abierta",
  "cráneo apoyado": "craneo apoyado",
  "escudo activo / roto": "escudo cargas_3/2/1 → roto",
  "herido": "cuerpo herido + craneo herido"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "cuerpo": {
   "archivos": {
    "reposo": "cuerpo_reposo.png",
    "herido": "cuerpo_herido.png"
   },
   "tamano_arte": [
    40,
    24
   ],
   "tamano_logico": [
    120,
    72
   ],
   "pivote_arte": [
    20,
    23
   ],
   "pivote_logico": [
    60,
    69
   ],
   "emisivos": {},
   "nota": "Patas, costillas y columna. Cola desde (38,6); cuello desde (4,3). Pivote = centro de la base"
  },
  "vertebra_g": {
   "archivos": {
    "unico": "vertebra_g.png"
   },
   "tamano_arte": [
    5,
    5
   ],
   "tamano_logico": [
    15,
    15
   ],
   "pivote_arte": [
    2,
    2
   ],
   "pivote_logico": [
    6,
    6
   ],
   "emisivos": {}
  },
  "vertebra_m": {
   "archivos": {
    "unico": "vertebra_m.png"
   },
   "tamano_arte": [
    4,
    4
   ],
   "tamano_logico": [
    12,
    12
   ],
   "pivote_arte": [
    2,
    2
   ],
   "pivote_logico": [
    6,
    6
   ],
   "emisivos": {}
  },
  "vertebra_p": {
   "archivos": {
    "unico": "vertebra_p.png"
   },
   "tamano_arte": [
    3,
    3
   ],
   "tamano_logico": [
    9,
    9
   ],
   "pivote_arte": [
    1,
    1
   ],
   "pivote_logico": [
    3,
    3
   ],
   "emisivos": {}
  },
  "bracito": {
   "archivos": {
    "unico": "bracito.png"
   },
   "tamano_arte": [
    6,
    5
   ],
   "tamano_logico": [
    18,
    15
   ],
   "pivote_arte": [
    5,
    0
   ],
   "pivote_logico": [
    15,
    0
   ],
   "emisivos": {},
   "nota": "Bracito bajo el cuello, en (6,9) del cuerpo"
  },
  "craneo": {
   "archivos": {
    "reposo": "craneo_reposo.png",
    "mordisco": "craneo_mordisco.png",
    "apoyado": "craneo_apoyado.png",
    "herido": "craneo_herido.png"
   },
   "tamano_arte": [
    27,
    11
   ],
   "tamano_logico": [
    81,
    33
   ],
   "pivote_arte": [
    25,
    6
   ],
   "pivote_logico": [
    75,
    18
   ],
   "emisivos": {
    "reposo": [
     "#b0ffc8",
     "#ffffff"
    ],
    "mordisco": [
     "#b0ffc8",
     "#ffffff"
    ],
    "apoyado": [
     "#b0ffc8",
     "#ffffff"
    ],
    "herido": [
     "#b0ffc8"
    ]
   },
   "punto_debil_en_estados": [
    "apoyado"
   ],
   "nota": "Cráneo 80×34 lógicos, con corona y ojo verde; pivote = unión con el cuello (derecha). «apoyado» con el escudo roto = VULNERABLE a pisarlo"
  },
  "mandibula": {
   "archivos": {
    "cerrada": "mandibula_cerrada.png",
    "abierta": "mandibula_abierta.png"
   },
   "tamano_arte": [
    23,
    4
   ],
   "tamano_logico": [
    69,
    12
   ],
   "pivote_arte": [
    21,
    0
   ],
   "pivote_logico": [
    63,
    0
   ],
   "emisivos": {},
   "nota": "Mandíbula 70×12 lógicos bajo el cráneo, en (2,10); «abierta» = baja 4 px de arte al morder"
  },
  "escudo": {
   "archivos": {
    "cargas_3": "escudo_cargas_3.png",
    "cargas_2": "escudo_cargas_2.png",
    "cargas_1": "escudo_cargas_1.png",
    "roto": "escudo_roto.png"
   },
   "tamano_arte": [
    61,
    45
   ],
   "tamano_logico": [
    183,
    135
   ],
   "pivote_arte": [
    30,
    22
   ],
   "pivote_logico": [
    90,
    66
   ],
   "emisivos": {
    "cargas_3": [
     "#b0ffc8",
     "#ffffff"
    ],
    "cargas_2": [
     "#b0ffc8",
     "#ffffff"
    ],
    "cargas_1": [
     "#b0ffc8",
     "#ffffff"
    ],
    "roto": [
     "#b0ffc8"
    ]
   },
   "nota": "Escudo de almas (elipse) centrado en el pecho; un orbe por carga. «roto» = discontinuo"
  }
 },
 "cadenas": {
  "cuello": {
   "ancla": "cuerpo",
   "punto_ancla": [
    4,
    3
   ],
   "segmentos": 4,
   "piezas": [
    "vertebra_g",
    "vertebra_g",
    "vertebra_g",
    "vertebra_g"
   ],
   "pieza_final": "craneo"
  },
  "cola": {
   "ancla": "cuerpo",
   "punto_ancla": [
    38,
    6
   ],
   "segmentos": 8,
   "piezas": [
    "vertebra_m",
    "vertebra_m",
    "vertebra_m",
    "vertebra_m",
    "vertebra_p",
    "vertebra_p",
    "vertebra_p",
    "vertebra_p"
   ],
   "pieza_final": null
  }
 }
}
```

### archivo: diseno/bosses/nave/pivotes.json

```json
{
 "boss": "nave",
 "nombre": "Nave nodriza",
 "mapa": "moon",
 "mira": "izquierda",
 "estados": {
  "vuelo": "platillo fase1 + cupula normal + luces on/off alternando",
  "disparo": "canon disparo",
  "rayo abductor": "emisor + proyectil rayo",
  "aterrizada": "patas aterrizada",
  "fases 1-2-3": "platillo fase1/fase2/fase3",
  "herida": "platillo herido + luces alerta"
 },
 "escala": "1 px de arte = 3 px lógicos; dibujar con vecino más cercano",
 "piezas": {
  "platillo": {
   "archivos": {
    "fase1": "platillo_fase1.png",
    "fase2": "platillo_fase2.png",
    "fase3": "platillo_fase3.png",
    "herido": "platillo_herido.png"
   },
   "tamano_arte": [
    41,
    9
   ],
   "tamano_logico": [
    123,
    27
   ],
   "pivote_arte": [
    20,
    4
   ],
   "pivote_logico": [
    60,
    12
   ],
   "emisivos": {
    "fase3": [
     "#ff9a9a"
    ],
    "herido": [
     "#ff9a9a"
    ]
   },
   "nota": "Platillo 124×26 lógicos; pivote = centro. fase2 con grietas, fase3 pierde una placa y enseña un chispazo rojo"
  },
  "cupula": {
   "archivos": {
    "normal": "cupula_normal.png",
    "agrietada": "cupula_agrietada.png",
    "brillante": "cupula_brillante.png"
   },
   "tamano_arte": [
    20,
    9
   ],
   "tamano_logico": [
    60,
    27
   ],
   "pivote_arte": [
    10,
    8
   ],
   "pivote_logico": [
    30,
    24
   ],
   "emisivos": {
    "brillante": [
     "#fff6b0"
    ]
   },
   "punto_debil_en_estados": [
    "agrietada",
    "brillante"
   ],
   "nota": "Cúpula 60×28 lógicos sobre el platillo en (20,0). Fase 2: pisarla («agrietada» tras el golpe). Fase 3: «brillante» al pasar rasante"
  },
  "luz": {
   "archivos": {
    "on": "luz_on.png",
    "off": "luz_off.png",
    "alerta": "luz_alerta.png"
   },
   "tamano_arte": [
    3,
    3
   ],
   "tamano_logico": [
    9,
    9
   ],
   "pivote_arte": [
    1,
    1
   ],
   "pivote_logico": [
    3,
    3
   ],
   "emisivos": {
    "on": [
     "#fff6b0",
     "#ffffff"
    ],
    "alerta": [
     "#ff9a9a",
     "#ffffff"
    ]
   },
   "nota": "6 luces en x 6,12,18,24,30,36 del platillo (y 4); parpadean"
  },
  "patas": {
   "archivos": {
    "aterrizada": "patas_aterrizada.png"
   },
   "tamano_arte": [
    41,
    8
   ],
   "tamano_logico": [
    123,
    24
   ],
   "pivote_arte": [
    20,
    0
   ],
   "pivote_logico": [
    60,
    0
   ],
   "emisivos": {},
   "nota": "Al aterrizar, bajo el platillo"
  },
  "canon": {
   "archivos": {
    "reposo": "canon_reposo.png",
    "disparo": "canon_disparo.png"
   },
   "tamano_arte": [
    8,
    4
   ],
   "tamano_logico": [
    24,
    12
   ],
   "pivote_arte": [
    7,
    1
   ],
   "pivote_logico": [
    21,
    3
   ],
   "emisivos": {
    "disparo": [
     "#ffd0ea",
     "#ffffff"
    ]
   },
   "nota": "Cañón láser bajo el platillo (izquierda)"
  },
  "emisor": {
   "archivos": {
    "rayo": "emisor_rayo.png"
   },
   "tamano_arte": [
    8,
    3
   ],
   "tamano_logico": [
    24,
    9
   ],
   "pivote_arte": [
    4,
    0
   ],
   "pivote_logico": [
    12,
    0
   ],
   "emisivos": {
    "rayo": [
     "#d0ffe0"
    ]
   },
   "nota": "Emisor del rayo abductor bajo el centro"
  }
 },
 "cadenas": {}
}
```

### archivo: diseno/bosses/comun/pivotes.json

```json
{
 "piezas": {
  "pincho": {
   "archivo": "pincho.png",
   "tamano_arte": [
    9,
    5
   ],
   "tamano_logico": [
    27,
    15
   ],
   "pivote_arte": [
    4,
    2
   ],
   "nota": "Escorpión: pinchos que caen"
  },
  "veneno": {
   "archivo": "veneno.png",
   "tamano_arte": [
    9,
    6
   ],
   "tamano_logico": [
    27,
    18
   ],
   "pivote_arte": [
    4,
    3
   ],
   "nota": "Serpiente: veneno verde"
  },
  "roca_lava": {
   "archivo": "roca_lava.png",
   "tamano_arte": [
    10,
    10
   ],
   "tamano_logico": [
    30,
    30
   ],
   "pivote_arte": [
    5,
    5
   ],
   "nota": "Golem: roca de lava"
  },
  "fragmento_hielo": {
   "archivo": "fragmento_hielo.png",
   "tamano_arte": [
    10,
    7
   ],
   "tamano_logico": [
    30,
    21
   ],
   "pivote_arte": [
    5,
    3
   ],
   "nota": "Mamut: fragmentos de hielo"
  },
  "pluma": {
   "archivo": "pluma.png",
   "tamano_arte": [
    10,
    6
   ],
   "tamano_logico": [
    30,
    18
   ],
   "pivote_arte": [
    5,
    3
   ],
   "nota": "Pterodáctilo: plumas"
  },
  "burbuja": {
   "archivo": "burbuja.png",
   "tamano_arte": [
    7,
    7
   ],
   "tamano_logico": [
    21,
    21
   ],
   "pivote_arte": [
    3,
    3
   ],
   "nota": "Cangrejo: burbujas"
  },
  "tinta": {
   "archivo": "tinta.png",
   "tamano_arte": [
    10,
    8
   ],
   "tamano_logico": [
    30,
    24
   ],
   "pivote_arte": [
    5,
    4
   ],
   "nota": "Kraken: tinta"
  },
  "hueso": {
   "archivo": "hueso.png",
   "tamano_arte": [
    11,
    5
   ],
   "tamano_logico": [
    33,
    15
   ],
   "pivote_arte": [
    5,
    2
   ],
   "nota": "Rey de los huesos: huesos en arco"
  },
  "fuego_fantasma": {
   "archivo": "fuego_fantasma.png",
   "tamano_arte": [
    7,
    9
   ],
   "tamano_logico": [
    21,
    27
   ],
   "pivote_arte": [
    3,
    4
   ],
   "nota": "Rey de los huesos: fuegos fantasma"
  },
  "mininave": {
   "archivo": "mininave.png",
   "tamano_arte": [
    13,
    6
   ],
   "tamano_logico": [
    39,
    18
   ],
   "pivote_arte": [
    6,
    3
   ],
   "nota": "Nave: mininaves"
  },
  "laser_tramo": {
   "archivo": "laser_tramo.png",
   "tamano_arte": [
    8,
    3
   ],
   "tamano_logico": [
    24,
    9
   ],
   "pivote_arte": [
    4,
    1
   ],
   "nota": "Nave: láser rosa (tramo que se repite en horizontal)"
  },
  "rayo_tramo": {
   "archivo": "rayo_tramo.png",
   "tamano_arte": [
    24,
    4
   ],
   "tamano_logico": [
    72,
    12
   ],
   "pivote_arte": [
    12,
    2
   ],
   "nota": "Nave: rayo abductor verde (tramo que se repite en vertical)"
  },
  "aviso_sombra": {
   "archivo": "aviso_sombra.png",
   "tamano_arte": [
    20,
    8
   ],
   "tamano_logico": [
    60,
    24
   ],
   "pivote_arte": [
    10,
    4
   ],
   "nota": "Aviso: sombra roja con «!» (golpe desde arriba)"
  },
  "aviso_flecha": {
   "archivo": "aviso_flecha.png",
   "tamano_arte": [
    12,
    9
   ],
   "tamano_logico": [
    36,
    27
   ],
   "pivote_arte": [
    6,
    4
   ],
   "nota": "Aviso: flecha roja (algo viene por ese carril)"
  },
  "aviso_diana": {
   "archivo": "aviso_diana.png",
   "tamano_arte": [
    13,
    13
   ],
   "tamano_logico": [
    39,
    39
   ],
   "pivote_arte": [
    6,
    6
   ],
   "nota": "Aviso: diana roja (proyectil en arco)"
  },
  "aviso_linea": {
   "archivo": "aviso_linea.png",
   "tamano_arte": [
    8,
    2
   ],
   "tamano_logico": [
    24,
    6
   ],
   "pivote_arte": [
    4,
    1
   ],
   "nota": "Aviso: línea roja parpadeante (láser); tramo de 8 px de arte que se repite"
  }
 }
}
```

## PNG (base64)

<!-- PNG-START -->
```
diseno/bosses/escorpion/aguijon_clavado.png iVBORw0KGgoAAAANSUhEUgAAAAsAAAAICAYAAAAvOAWIAAAAjElEQVR42mNkgAIrMY7/MLaDDB/DgSefYFyGY69+MDIwMDAwwhTu6oqDSx7ccoRBW02UQURNnaFt0gaGA08+MRx79YOR0UqM47+DDB+DtZIIw9F7bxjQAUz8wJNPDCxQK/4zMDAwlLW9RFF4dI42XCHMKShu/rDj//8PO/7/h4kh+4UF3RPIAJsYbQAAg0I97Wv/+6sAAAAASUVORK5CYII=
diseno/bosses/escorpion/aguijon_preparado.png iVBORw0KGgoAAAANSUhEUgAAAAsAAAAICAYAAAAvOAWIAAAAsklEQVR42m2QoQ6CYBSFv98ZSM7ASCYiNiM4NRqMPILjITTzFgYfQjZsyoQ3sP7JxAjoCLRrgqFw0gnfPefeCx25liEMqIxFAMZd6LiyCRMtWV6rBuA/rToHUp0DOSwsiXxHylhadYdGjblfHni2SaoL0tOc97W/jop8p1eX6gLPNvH2T6ZbpdrkMNGsd0tSXbQgQJjoHxBAuZYhm9mkV3l7fcjyWg0e6VqGRL4jjR964ReTX1OzkOyi1wAAAABJRU5ErkJggg==
diseno/bosses/escorpion/aguijon_reposo.png iVBORw0KGgoAAAANSUhEUgAAAAsAAAAICAYAAAAvOAWIAAAAhUlEQVR42mNkgAIrMY7/MPaxVz8YGbAAFpjCXV1xDAwMDAxtkzYwMDAw/MemgQWm8OCWIwxH771hYGBgYNi26DuDgAem4UwOMnwMB7ccYWBgYGCwVhKBS3zY8f8/huIDTz7BTYTRDAwMDPzuEA3ImligbsMw5eNOBgYBD0YUtzCSEhokAQCKGTahgiNykgAAAABJRU5ErkJggg==
diseno/bosses/escorpion/cuerpo_derrota.png iVBORw0KGgoAAAANSUhEUgAAAD8AAAATCAYAAAAnMdWSAAACT0lEQVR42t1XMWvbUBD+JEoQIQ2hGOHBhGKMyahJNmpo8wOE6dAsHjKFTBlLloZszRA6FJPJP8BDaoopHoInOzhCeBKhpFCEKUVDESIUNxjhoa+DkfKsSNSyFUvtB49Dd+/u3Xd3D56ACLC+zBJaxuUfFmwUxOWnaxMyLv+Fkl9fZsm+kIZmDQEAmjVEmESi9g+LR/N2vqHfwLgd4fvwNwOMSLz+C+q8U3UvXuaeILOy9NfuPZT/Qu+8Xyfi9A8DZp7OZ1aWYNyOsJnnXX33qwk/vRdB+2bxn2Xkp77zZSFNvAfvC2k09BtctyoTe5u1Oi7aVwCA6umhbzxL13FWPYvE3y8/AKhpP5iZydMB/ZI42DtC6+O7e/qiKEAuv8LB3lFg4mpPw7ef9oP4OwUEQOhCSDxHFNNmAsc+iLCl6/cOSOVyvvqk2dWehkpdxVZmFW1j4NoV02ZYmnj19BDOsnTdXV6oPc0N7Hx7ZRx2Or9mrY4UhiiuEdR2C+MJ2C2gdbKDrcwqJJ4jDE2cJqr2NBRFwVdGhcemiV88H1k8Oj9ZzOO40sD7z3fdvn5dQPX8y93Yl4U0KUkbUxOUxXxkyXaaXbyQNyOLRRdSFvMT8TvNLrY/9V37h1IWbudL0sZUJDvNLpIKupB+edL240pjTF7iOdI62flnSM6Ly741HnuJ58ib51lc9i08y6Zc+T8Td3iyimkzby/6roKuTJBMekenkW1jMH7bOwVoGwN3hQmUdOnwofkpps0EPgElnvP9q3KuSBJBP2JoKKbt+8L7AyPqJVZTZ4k6AAAAAElFTkSuQmCC
diseno/bosses/escorpion/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAAD8AAAATCAYAAAAnMdWSAAACw0lEQVR42u1Xv2vbQBh9EsYYY4wISihFpEYUhyYdTCkt2CX1FDpkCB26FDxmKqVD6ZBAt2ToVDJ08JC/wYMpJUNRQuzZQ+MSY4QJmmxhhBFBGGN1MHe9s+SftRMX8i3yx3fP9753d9I74C7uYqJYjwbcYfXkSsi9Tfw4ERh3YHIl5FpOh+YJOQLApgSkEP9XaSUKABzBeeLLrY4wSrRi3RHYXBhX8bQSxe7rpzQ3agYAQIkp2DsuIiYFsfd+h9bNyiUAQI6v4fAoBwBzxZdMG1IogJMvGd/GT/PnODjTORGE/sb7wYdHOeSqTXz/tEUnZOPbzysAQPbzG0qYjeyP35T4vPGsaABwUWmgoJtIqTI24stUSM1ooVh3BKG/cbNyiYtKAxvxZW7iE63smVjTLY44wS0aHgB2Xz3ics1oQWAbP82f02JBN8eemMUtEv7rrxbNPzyOenJx0MshpcpDX4BpVRpaXwR8+eNz1LMZ1LMZTw4AgeRKyN3fVD3qEeUHBVF+UNw2npx5VBoDc7FYd4SDMx0vt1/8NytPGo9JQd8tPyqIsPTMp5UoNyEZULPavkRZAn5EbwKfViVsPXvQW9EpBBDJd08zWnRC8nkAgLdP7vtuMUIothT23aI3gdd0C3J8beqVF1n30y8AeZZMmxJgiRACbANsIylVRkE3uQZmhSdPYoAmCSLsWA6vWHeE9WjA7VlKnvhfeypyFpUQZ62p5XRnjk+rEmrNa248+d3/ZGua0fJ6+37/y3tnmxOmZNoAALvThRIJYufhEnLVJmckqB2129iOSYhJIdQsB5puzQRPbO0kW97j8Ka51ZHLBACshkVXiQQpUSUS9Ai5Ghbdd4l7yFWbMOw2rq67M8OTHbu/qQ78TBIxfb39vwZpICGHka9ZHDm/BgfVp8VPeqsLzLL5Hpm2O6pOGpg1ftix9Ys/ELmONPiyF4gAAAAASUVORK5CYII=
diseno/bosses/escorpion/cuerpo_reposo.png iVBORw0KGgoAAAANSUhEUgAAAD8AAAATCAYAAAAnMdWSAAAC30lEQVR42u1XMWvbQBh9MsYIY4wIiilFpEYUB5IllNLBLomnTBlChy6FdutUOmTIEEM3Z/CQIYQOGVryDzwYUzIUOcSasyQlJgg3aHKEEUYNwpioQ7jznSU7dmonKeQt8sfp6d77fHd6Ah7xiJEwFw97g8bTCdG7T/4wCA97YzoherbbofWCHAPgUAGSyD8qq8QBgBM4Sf5JqyPc1DS94QpsLQzb8awSx8c3L2lt1k0AgJJUsPFNR1KKYOPzKh23aqcAADk1i83tIgBMlH9kOZDEMPYL7wONV0qHyB8YXBOEXuO95M3tIopnTZTXl+mELL7+PAcA7H55SwWz2P3xiwqfNJ9tGgAc1y5QNSxkVBnzqWnaSM1sQW+4gtBr3Kqd4rh2gfnUNDfxvnbim1gzbE444T0EPgBUDQv5rQLKOwWuzq2tQzNbEFjjldIhfXDVsIaemOU9JH5+qwAsfQAqe8itrfvqUL/DIaPKAw/ArCoNHH8I/PJOAajs4U9d99UAEE4nRC+3qPq6RzrfD6Tz/XDffILf+9/pNuitQ3rDFfIHBpZWXv83/zwxnpQigUueBWucPQTpaZ9OiF5WiXMTkhvqdjtQKCsgSOhd8LOqhOVXz3wGh0HVsK73vN5wBc1s0QnJ6wEA3r14GrjEiKDkVDRwid4FXzNsyKnZWxkH0D3wghpArkeWQwWwQogA1gBrJKPKqBoWZ2BcfHIlAWgUkMYOlfD0hivMxcPedaTkhXfjaYiLqEQ4G01t92rs/Kwqod685O4nv3uv7JhmtvzZvjf/8tnZ4RpzZDkAAKdzBSUWwerzKRTPmt19aba6cdRpYyUpISmJqNsuNMMeC5/E2lGWvC/h3earjnxMAMBMNOQpsQgVqsQivkbOREPep4UnKJ41YTptnF9ejY1PVmxuUe37miTNDMz2/wpiYEGOolS3OXFBBvuN35Y/6lddeJzmr8W0vZvGiYFx8wdt2yD8BcAWn2oeV3r+AAAAAElFTkSuQmCC
diseno/bosses/escorpion/cuerpo_reposo_b.png iVBORw0KGgoAAAANSUhEUgAAAD8AAAATCAYAAAAnMdWSAAAC10lEQVR42u1XsWrbUBQ9MsKIYIwIiilFtEYUB5IllNLBKYmnTBlChy6FdutUOmTIEEM3Z/CQIYQOGVryBx5MKBmKHGLNWZISY4QbNDnCCKMGYULUIbyX9yTZtVM7cSFnkS5XR/ecq6enK+ABDxgIM0nR75XPpiT/Pvn9QOz3wmxK8h3vksZzSgKASwXIEn+rnJoEAE7gKPkn7Uvhb00zmp7AxkK/Hc+pSXx4/YLGVsMCAKhpFetfDaTlONY/rdC8XTsFACiZaWxslQBgpPwj24Usidgvvos0XikfonBgck0QgsaD5I2tEkr1FvbWlmhBFl9+nAEAdj6/oYJZ7Hz/SYWPms82DQCOa+eomjbmNQWzmSnaSN1qw2h6ghA0btdOcVw7x2xmiiu8r5+ECuumwwknvHHgA0DVtFHYLGJvu8jF+dU16FYbAmu8Uj6kN66adt+FWd448QubRWDxPVDZRX51LRTHum0O85rScwPMaXLP/Djw97aLQGUXvxtGKAYAMZuS/PyCFuoe6Xw3kM53w33zCX7tf6OvQTCOGU1PKByYWFx+9d88eWI8LccjlzwL1ji7CdLdPpuS/Jya5AqSCxpOJ1IoKyBK6F3wc5qMpZdPQwb7QdW0r995o+kJutWmBcnnAQDePn8cucSIoPTkROQSvQu+bjpQMtO3Mg7gZsOLagA5HtkuFcAKIQJYA6yReU1B1bQ5A8PikyMZgAYBaWxfE57R9ISZpOhfj5S88JvxNMaNqEQ4O5o63tXQ+TlNRqN1wV1PzoNHNqdb7fBsH5x/+dnZ5RpzZLv03L28wnJaRlqW0HA8WgAALLcDNRHHyrNJlOotOqMPg0/G2kGWfGjCu81fHfmZIHgyEfM/zj1Cqd6C5XZwdnElsDk1EadmEmIMw+STFZtf0Lp+JkkzI2f7f0VQICuezc8pEyg3nK752/IH/asTh2n+WkyHGuiWHxW/12sbhT/Ab6U0VbKWsAAAAABJRU5ErkJggg==
diseno/bosses/escorpion/pinza_abierta.png iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAAo0lEQVR42oWQIQ7CQBBF3zYrqpAbBBpFOEAVsqfgHBswSE7AASoqq1cSmu4JVqERTSWqblGTlLBZvpr8eTPzM/BHlSljdJf4OO5jZcqol43UwNBY+rbDhREALfDQ2OSFJQygBO7bLjngwsj99QbAT7PSufwC+2lW4hU5OKUC4Hy6fUEujNS7NamHKDEOm9XPNsl+rbdY98RPs1K5t0r2ypRR6g8kKUlEKOOD7QAAAABJRU5ErkJggg==
diseno/bosses/escorpion/pinza_reposo.png iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAAiElEQVR42mNgIAJYiXH8txLj+M/AwMDAgiyIS8PRRRUM1VXTGBgYGP6zwBQfXVSB0waoYgYGBgYGRpjiw8vWYVW848oLhgNPPjEwMDAwHHv1g5EFn9thio+9+sEIE2PCpxgbYEJ2I0zRjisvGDx0JLBqYIR52kGGD0MS3TlwDbiCFV0xAwMDAwDX+zZp3nQ87gAAAABJRU5ErkJggg==
diseno/bosses/escorpion/segmento_cola_g.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAAcElEQVR42mNkYGBgsBLj+M+ABo69+sHIaCXG8X9ZijlccNaO6wzWSiIMrYfuMTBuDdH6f/TeGxRdaR6aDFdvvWZg/LIgDcPIg1uOMBy994aBBcawVhJBoRkYGBgYrcQ4/lfbKTGgG33gyScGRnyuBQBCyjF0efhDzAAAAABJRU5ErkJggg==
diseno/bosses/escorpion/segmento_cola_m.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAa0lEQVR42mNkYGBgsBLj+M+ABI69+sHIYiXG8f/oogoGBgYGhsPL1jHsuPKCgYGB4T/j1hCt/0fvvYGrrsoLYGibtIGB5ei9NwxVeQFwibZJGxgYGBgYGK3EOP47yPAhW8Fw4MknBkZclgMAz60idGAjvy4AAAAASUVORK5CYII=
diseno/bosses/escorpion/segmento_cola_p.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAXElEQVR42mNkYGBgsBLj+M8ABcde/WBktBLj+O8gw8fAwMDAYK0kwtB66B4D49YQrf/2PjYMDAwMDG2TNjBYK4kwMFqJcfyvtlNiOHrvDQMDAwPDgSefGBixmQkAvUkY5ida0JEAAAAASUVORK5CYII=
diseno/bosses/serpiente/cabeza_apoyada.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABEElEQVR42mNkIALwafH8J6Tm07UvjDA2IzGG1W7Sw2vgls0MDOdnX4IbzojPNTDDpuQ9got5l2G3QFHmA8OUvEcM7x98gLiUT4vnPzbXbNnMwPBg9yOG13vewMUSdjkxXD3/AaerH+x+xMAIM3DLZlQJBVc5OK1tKMCgKPMBxSIFVzmsBjIwMCAMnZKHMIhYgGwxssEs6DadXDaFKAMfvLjAUL59F4bP4C41TNVj8OZmw9BoZ+fAcOjQAZx8GNj69RfcwPcPPjAwfbr2hfH87EsMW7/+Ypi64Q6Dn1kBA8MzBbgB+Pgw9d4f1Rikn7EwvH/wAXuS0mETgQhIQWP4mQBO/pUHf+Dqj114wMhASwAAeK+T/j59GfIAAAAASUVORK5CYII=
diseno/bosses/serpiente/cabeza_ataque.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABUklEQVR42rWSP0hCURTGfy+kIUUMosFCrkuDhNjiKG9xqqS5lhxaxakmHYK2BgebmnMWNYJcRFBoSYlsCrw8SiIEX5ENIdhgPtTnv6Vvueccvvvj49yrMIfsHlt3lufz6Uvp18o8sK0jLzKvIYIudnbNvlwWKpcPBlyZliaW8ZLLQiG8Z8zOm2nqLw4T2L2uk4xotKSOpQ+MZbxjE8i8BmGwrsZpv58CUKvoJm+tAiLogjxY7B5bd1k4SEa0qTvrAwFjFaOS+R5D2V8SXYCrdp0Dq5vRuqR2EEGXAepfBIbmg2DLrFe9SyV7RZihU75VObm5HUpuSjpJvoQw6kBApVgsmDzX7R8D2JI6C6lvqeREk9czJyW1Q7ycwHesErk/xJcQhPxRaAgDONhfpJ8J+aNsf2yw1rDQkvr4L7W5uNIbOP9euOGY2D/KjuEvV6XCf+oX4XuVIg9dI5oAAAAASUVORK5CYII=
diseno/bosses/serpiente/cabeza_escupir.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABYklEQVR42rWSP0hCURTGfy8eDSliEA0W8iRosBBrcAwXp/7QXEsOriINBYEOQU0NDjY15xxqBLmIoNCSEdlUeJGSiMBX9BpCsMHeJXtWLp3lfufw3R8f516FPsrhtbf/8rxcvyqmVvqBzUR8iHwdLeRmYdHqy2WhcnAp4cpvaeIZH7ksFMLLcrb3dETtzmkBe8Z1UtE6TaGjmsB4xtczgcjXIQy20QTG4zYA1Ypu8VYroIXckAfV4bW3hzUnqWj9152ZQECu4nuJfIehrAxp7W1jiwkirNo8ABwaNalLwRZayC1B5kWga/4VrJrAWw56JjxLpzoiTNcpHi7YPDntSm5JmrDt9oT6k5rUc3NBisWCxXNsvEtgU+gMpN+EMju1zv2Oi1KwRaKcxL8RJHq+hj+psRSIQUOTwK/9/tENS4EY88+TjDVUmkLv/aWmB0c6A9fnCzecP/ZXoiX95Quh8J/1AVqHmyJNDZvsAAAAAElFTkSuQmCC
diseno/bosses/serpiente/cabeza_herida.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABTklEQVR42rWSvWvCYBDGn1fEpSFk6NQGSZYOUgINpGMoBV2E/gUO7dBVujk5OGZPu7g4dS5+UDBFikOhCCpSMhV8CRIKLZiKLlKwQ5qA+VCX3nLv3T387u7lCHYwNsOstmlm5px4b7ILrHCnQuQdjCccRN4J6ZoNYFAd+XCyaZpyXcJ4wqGW6+CyfY5aroOKKWM84UJgkXegFy1MqeNOymaYVbkuRU5ADQtCNo1eqQ9Fk7d+FTUsEA/YbKwXhGwa1LAAAJ9PX1A0Gb1SHxVThl5061FAAEgEE0EPAIomgxoWFM0Fxum8Rslgp9d7PXqvq3VPP4YoPbYjNyNshlmdXEvI76VCHFU9Q7f7HBt71losfeCUOkjMzDkZVEdoLZa4fXjHxekNYAs+YFPs6fPfRzi0k5hSJ/qkjlP7buLg7x5tLjZ+oz++/mVICf7TfgFjjaVyR5ArtQAAAABJRU5ErkJggg==
diseno/bosses/serpiente/cabeza_reposo.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABPUlEQVR42rWSv0vDQBzF30no0lI6iINKiYtDkYCLY+nSqSr+Cx1cHKqbUx2cHevUwc25NCmCWUIHwSml2EyCX0IJIkJiaZYgxEHvPJq2ZvFN93337nPf+8GQQvlSLv4rM3GmjI9ZGtjusQYyXajVIvYPkjlDB+z2UMDZsm6aXQ2GDlj1I+FdvXfwMi4kwFubAVoNFz4FUDiw2dXmdkCmC9SB7NoFwrdLAMDIDhLZkQ2o1SJgAgoHGvpvgB+VTFd4HCjPz4rnWb6Ui+U7k0Fc3J+dl30ZzKhyElvk4OY0ApkuHm9baT4E6HWA87t7sYm8oei0ls0kFpbLFfT71sKaqxdGAuhTgJWJM2V2e4heGOG684zDvTPAUwVgWc3ztY9tbHgKfArmf6mdzOq3sf7zwl5hYf1EnyL/MCCG/9QXvaKmvexrA4QAAAAASUVORK5CYII=
diseno/bosses/serpiente/segmento_g_hoja.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAAl0lEQVR42m2OoQrCUBiFv19uvIxZjOMG04IPsCIIexC7LNitFkFBljQs+AbWPYFJMJgMl4vJsiEmyzWM3eQpBw4fH0cAolR7gKGJaWyLihUAEqXar84TAMrCsdgnAFTbF7J5ZL4sHACX9ZjZ4UkfBWDyjj7pL/PlKFhkusu8rV0AAGzdmQbX4w2TJ2Hou7Et8u8twPv+kR9Q4DHKXAthfQAAAABJRU5ErkJggg==
diseno/bosses/serpiente/segmento_g_liso.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAAkklEQVR42n2OIQ7CMABFXxtk08AFlgpUxRIsArdbYLG7wSwGu2CQu8FatxNMkSBQiKYX2EJQM0UsARTy5b+fPAGgrUoAK7NkCCMAz/tLSG1Vqtqcqs0B2J93bA452qokTo9tqssIQH9c06iJuoyYImMBYIoMgEZNeDdz6CLSOwjd/PQO4Mvyerl9zN9hCCPiX+0bmas4HFHctfgAAAAASUVORK5CYII=
diseno/bosses/serpiente/segmento_m_hoja.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAh0lEQVR42j2NIQvCQBhA34HxOE7zsU0wTRCsFwXLfovsH1gNrsmSP2NqMpgFs2lhHPYdYv8MMl98PHgAmFxL1XpJCycm1zLxVpTJtWybBXUZ2BwSAG4PUFXrpS4D992M1fHFgEoLJ9k6Yb60TF0E4HyCUd9FuP6qyz4A0HcRNczHmf3L9/Ojvur3K1Fc22+NAAAAAElFTkSuQmCC
diseno/bosses/serpiente/segmento_m_liso.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAe0lEQVR42j3NIQ6DMBhA4dekamka5glUoEqyZHYew2F2g5mJGSwnwfYEKBRTEw0XoFnm/6liv+TlAWC9keFzk7ovxXojANp6I4/pwnjfcF0FAQDRGedXwzOdACCAqvtSXFfRXgvWJRHDBoDeY8r5gXtMqDw/u+LA7/un/mJDK58+wk/vAAAAAElFTkSuQmCC
diseno/bosses/serpiente/segmento_p_hoja.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAaUlEQVR42jXBIQrCUAAA0Df2g0HEcywIVg9g0mPMc9gFL7CwQ2jzDn4YWLaFYVTEFYvlm3wvmxXTBMtyIVaNMA+yQ79K5xObLVAfHwIMl7u6m/jL2z7tYb0rfL655/UlvIcR3OIoVg34AeibH1H3vfU0AAAAAElFTkSuQmCC
diseno/bosses/serpiente/segmento_p_liso.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAYElEQVR42mPk0+L5z8DAwGCYqsdwfvYlBgYGBgbmluMmDZ95xBlWOrIxCMSLMFw+/pOBiYGBgeHB7kcMi3l+MUzJe8TAwMDAwCjvJfOfAQ0wvX/wgeH9gw8MCq5yDDA2AJ36HnXB9SneAAAAAElFTkSuQmCC
diseno/bosses/golem/cabeza_enfadado.png iVBORw0KGgoAAAANSUhEUgAAABMAAAANCAYAAABLjFUnAAABX0lEQVR42p2TP0tCURjGf1ccRO5wiMvlYiJncJBo8AM0NDgENTZE+AGCFgeJpsYWoc9gQ9EHaJAmcYoGcVBwkLhJhIjIHS5yiYu3pSPeP4b0wOHA+573eZ/34T0aCcgJERyW93g4d2O53asxX46jJdWloyQAtxdn3D09c/9+EiswxBwgAGKk2jqR0LOk0ym2ge8vcdxFiHBV6X17CF3HcRfomSy+v8T3l1QrB6ujYiVZwPU8pGWyk80EoTFzQgS10yMA2r0hfXtM3jD4nM0AaLY6ALieR94weO0P2ZcFeiOb+cLTEj1rtjoM+rXQOI16F2mZ2JMpH6PrUO648ggjO1CjbmWQPZluFQ8pk5bJZfUFaRkhtUpZo979s2k63m32e6YxBco7aZnJZMr8dm8YKhzcGBsVNN5KK+J1pKIebOoahXpXLsrVsms5IYJyUSaarLyK3lGo5dXWv9F/oVbjByBipAqD3AUdAAAAAElFTkSuQmCC
diseno/bosses/golem/cabeza_herido.png iVBORw0KGgoAAAANSUhEUgAAABMAAAANCAYAAABLjFUnAAABIElEQVR42p1TMUsDMRT+IplEJEM4wumQoUPplNmhdOzg6CBOjo5O/gRHf0M7FPoDHDqW/oKbSgeR4FCO45AMxfVczPXykkPxg/Agee/L+77HY0ggF6KZmBEWd4fo7eLpA3vnWKqOUxIAeH64xcvyFfP366hAik8AaABEpKxLJM5OwfkJ/oJLKVG82YAw6Ox+OoYta2glfyWbrTZpmbkQzePNFOtiBwBYF1tolcGWFSZm1H7QvU8h0uQTj7Em8UhkBrr1OZJpywrmPCQ3ZthKom8F6TAg0yqDUDLwbLbatNLM1TgkI77xWGb9c6pIuu9QqyzpGafm+0IqqU967wBsWfX+SuHzukNguRCNGejkuL1XNFK4wxf2zjHWXaP/wm/BN2JRhzGY+Z1CAAAAAElFTkSuQmCC
diseno/bosses/golem/cabeza_reposo.png iVBORw0KGgoAAAANSUhEUgAAABMAAAANCAYAAABLjFUnAAABK0lEQVR42mNkwAKkBAT+OxhoMSyN+oIhJ132iOHZhw+M2PSxoBvCwMDA0JYRwdC3YgvDwns+GBpEBN4xMDAw/GdgYMAwlBHZIAEeLgYWFiYGYoCMiAjDhTsPUAxEcVmChx3DgxdvGBQkRAgatmDHIezelBIQ+F8Q4sFw4MINhgcvXqEocDDQgltw4MI1vBaguOzBi1cMV+tQXZW9CUIfuHANQ857FhMDw50H/2FeJRhAChIiGK5FthynyxQkxBiyN4mghNmCHYcYFCTEGB68eMXQfUoLzbhDuA2D2PYGil9huAAW6AoSYtjDDDnwkTWihw8y6D6lgTU2mdDDAJetmGEJUWegogBP7IxSAgL/DVQUsAYyLKzQaXTw4cs3hmcfPjAyImcjcgEsaQAAPTqBXuQ/WJkAAAAASUVORK5CYII=
diseno/bosses/golem/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAAC0AAAAhCAYAAABN2CLhAAAD10lEQVR42u2YMWvbQBTH/zaegjEahBDBGGE0BONBZCwmZAilU8nQoUM+QIcOnUo/Qcd8howZM2QImUSGkKGDCMZ4CEUYE4TQcAThqbQdlHe+k+6kc9wOhR6Ew5Lu3e/+9967dwH+t3+87VrWr79lu6Ob8JGx1jZgVncHALTvTezrWDoqANvqShOKg8TvPr17o50sTjIAgOfalXdnVzda++U5DoMRwmgmfduij75+eM8HfV8kAIDhwMXp+SUylkMFSmAvbZ5r4+zqBixfSc/LLMOBCwC4vrtHGM3QIuDviwQPjyn8XUfqAWAaL9C3bRwGe1uDNi3g88lbXN/dVzj8XQcXt98w9gZonX358Ov67r7R6DRe4ORo8leg4yRDnKQcuImjbWJ0Gi8w3vmJs6ubPw5NwEHPjAOAGfTYG2C6aiPoAXGSSv68TS8CT1ftRpXH3sAcmlYIQFJke/C1wn3bhr/rmCl9en5ppDQAsB2nMWusd0Ludd8BQPDqAHGS4uL2mySQVumM5fzD8gDxeRGExUTWKsVhsFcLbHW7WnD6Le6a5zr48eNnZV5Vz/P084Gy9mFhASdHE4TRfH3arVJET8VEIsjY95QKLZMMLM8r3we9QmXRdpyk6HT0XpuxvMjT4oERRnMsswwnRxPpWVmpoAdYwxEPJh0wANxN5+jbNgen8eWFiznbc+0KCx1EHRVYWVkVMBkPoxnGvodljZ/3bRvLLEPfLmBE97BcuxIjlFkAYDLeQxjNJRdT7kMdsBg8zzWEUSNwqkUoqFW1ibqGceqh9UetU/u7ri2zjG8xuYhQPBkcQoLSge9pldW5hjUc8S2zut1a1xCVLkrWrqRu0GtWWxQo8D20o4dYmb7qVkqTeK4DlufoG0xKSh9P9vmWm7qIOH/0EJu5hyqv1h0cdUqLym3iIkY+LSvrSAFI7kTPl0nGlWxSWhnUPZOALGWP8krJd0VDnutwXy4rwPKcZwcCpD8R+OPx68qCTV1EUvqRsRbLV3yQynebbioq8LLCInAluEqnok5plq/wyFirIwKG0Yxvl4mhMoDn2jie7COM5mD5CseT/cbc3/ROFTsdXXCYF/GpNI52I/AHtTA0zlQQ7Yn4EmC5vk6NLr2qmNlE6Ur2EF1DVxtT77kOoqei6iN4GTxVPlsfULNa++I8jf+sMTEkgVOZ+QweCVuvAhaD3HSeWqWt4WijQohfDIYjnr7Eu6TokwS8abFVVrpdjeTZi27VYTQrwF4dIHoqwA+D0dbVYaNP04q26amKowtCOVbo/UvsU+PXrcD3Ns4em5a129qnw+U30yv4S8akCbkAAAAASUVORK5CYII=
diseno/bosses/golem/cuerpo_reposo.png iVBORw0KGgoAAAANSUhEUgAAAC0AAAAhCAYAAABN2CLhAAAD6klEQVR42u2XsWsbMRTGPwdPxYMp4jiCMaLcEBxDTWYPGUIpFEqGDh0yh4A7dCqlg4cMWQL9Azpl7FhMAyHTkaGE0OEaYuMhlMOYcBwi3HBkKmkHV4p0J93JcTsUKjDCd9LTT5/ee3oH/G//eFuu13/+LdtV04JXSVJZBKxeewAAxvc29k0sVR0AqdeUBeVJ8rjXL54aFwsjBgCgLsm9Ozg6MdrPrrHeacEPRsrYCh+0t/NSTPo+iQAAj5ou3n/8DJak0IFysPs26hIcHJ0gSW+U51mWR00XAHB8eg4/GKHCgb9PIlxexfCWHaUHgItwggYhWO+sLAxatoE3W89xfHqe4/CWHXz68hVt2kTl4O3Oz+PT81KjF+EEWxvdvwIdRgxhFAvgMo4lG6MX4QTf3j3EwdHJH4fmwMM+seIAYAfdpk083rvGsE8QRrHiz4v0MvDjvetSldu0aQ/NdwhAUWRx8DuFG4TAW3bslH7/8bOV0gDw7MNSada4Owm1N40DgP2zFsIoxqcvXxWBjEqzJBUDsxPk57MgnC10uH2L9c5KIXC9VjOC8//yqVHXwY8ft7l1db3I078vFLEjeQNbG134wVj8P9y+xeouA3UdBaTtUa1C04ghSdPc+GGfYP+spdgOoxjVqtlrWZLO8rR8YfjBGFPGsLXRVZ5llRr2CXoDRwSTCRgATi/GaBAiwPn87MblnE1dkmPhF1FVB5ZVVgfMjfvBCG2PYlrg5w1CMGUMDTKDkd2jNyC5GOGZBQC67RX4wVhxMe05FAHLwfO7hrBqHJzXIjyodbWJvoZxiqHNV61T+L+oTRkTR8xdRCqeLC4hSemOR43KmlyjN3DEkdVrtULXkJWelaw1Rd1hn5SqLQvU8SiWgstQm76KdsoXoa6DJE3RsFiUK73ZXRNHbusi8vrBZWjnHrq8WnRxFCktKzePi1j5tKqsowQgdyf+fBoxoWSZ0jr7Ni6Syx7ZnXLflQ1R1xG+nFUgSVORHTgg/8nArzaf5DZs6yKK0ldJUknSGzFJ57tlXyo68KzCMnAWJHsrmpRO0htcJUmlKgP6wUgcl42hLAB1CTa7a/CDMZL0BpvdtdLcX/ZOFztVU3DYF/GxMo+fRsdrFsLwebaCGG/E+wCr9XVs9dGri5l5lM5lD9k1TLUx76nrYHWX4XD7VsCr4LH22d0FNSq0L69TCF1WzMs9P+LVXSY2LH+SmYDlILddpxC6N3DmKoS4wd7AEekrCy6Xo/cptkqV5kc2b/ODEcIoxv5ZC6u7DMM+wXqntXB1WOrTfEeL9LyK4x8I2Vjh7+9jnzfxudXx6NzZY96ydlH7/HL5BdDxLQ4q4MHSAAAAAElFTkSuQmCC
diseno/bosses/golem/nucleo_apagado.png iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAQElEQVR42mNgQANRWlL/0cUY8Ukuu/aMkYGBgYEJlwJkcSYGIgAjLlOQARPMXlxg2bVnjERZx4TsC1y+YyAmnAAKaRWqiVbv8gAAAABJRU5ErkJggg==
diseno/bosses/golem/nucleo_brillo.png iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAdklEQVR42mNkQAL/Z+n9h7EZ0y4xwthMKArcLCAcNwsUDUwoCnadYGAIi4HQyAr/z9L7//9B2v//s/T+///Q9f////8QGkmcEa46LIaBgb8U4cCP3QwMq5YgucnNAiLwsRtVAcyNWK1E4jOgex+uEE0BIzHhBABXnmakZv1zWgAAAABJRU5ErkJggg==
diseno/bosses/golem/nucleo_reposo.png iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAWUlEQVR42mNkQAL/Z+n9h7EZ0y4xwtgsKArcLJA0MPyHKWTCpoCBgYGBwc0CbjIjVgXIYNcJiEmEAHGKGNMuMTLsOoHTKsa0S4xMcO+iK4QqYGBgYGAkJpwAGy8lZs/I03IAAAAASUVORK5CYII=
diseno/bosses/golem/pierna.png iVBORw0KGgoAAAANSUhEUgAAAAsAAAARCAYAAAAL4VbbAAAA3ElEQVR42mMU4uL472JmxIAPnLhyg+HLt28MTAwEwIkrN+BsJlwSMCAjIoKp+MmLNygaYPwnb95gUfzmDcPDNhkGGRERhMIXb7CbDANHizgYZCQQCrCaLCMiwmDd9wOvm1kwTZCBOwOvydicgtPN2JyC1WRkEL6MB+4UnCbDTEEOY4ImIytANplRiIvjv4acHIoCHQU5hisPHqEY8OXbNwYWDjYOhgAb1FR34MINhpwANzh/wY5DDH/+/GNg1JKR+q8gIcbw4MUrBkI0o5SAwH8BHi5CKZXhw5dvDADaqnDroujDAgAAAABJRU5ErkJggg==
diseno/bosses/golem/puno_ardiendo.png iVBORw0KGgoAAAANSUhEUgAAABMAAAAMCAYAAACA0IaCAAABRElEQVR42p2TsUtCURTGfzcaIhwu4iAvEGmKh5ijRIM0ODk0xYPWeDQ7NLgEDY7+AW4t4djg5OQUDg36EMcQB3F4xB0erbfheW89s4f1weXynXPPOfB956K7Zc03GO5Iqbed394D7JuA8APhSKkNf3w7YxODUQBE6G5ZH90tEg2FHwhhAo6Uun3rAdDp9SkVC0znix9302vQ6fXtHaqIpVICQJhGtYrLdB5PyxwcUsznduamoXCk1DmZYdLK8l+ctt8JVRRr1vQa3A9XHBfyDEYB81WIf3lhdUrjMfqxAbWKuxYWnl9eAVDRh9UujZs6gFrFZW84nlGvlgEoFQsAPNxcWRMAzksnCW7ygNVtOJ5hNTNubcOkleX6KbM1b+pCFX25mWpCvQqDUar4S6XiPbNbXK/+3cr1kMTSbn6NXSH8wPb4BBe0vQqMIp5ZAAAAAElFTkSuQmCC
diseno/bosses/golem/puno_cerrado.png iVBORw0KGgoAAAANSUhEUgAAABMAAAAMCAYAAACA0IaCAAABH0lEQVR42pWTIWvDQBTHf1cixqgIJWJUlDBZyqicLBNTFVMjMDvGdOXMYGIyH2PkA0RFRUZ2IVRNHBFhIuLEUZuZ5biuuUHPPP533O/97957Asea+n7nOmuUEkP7ngvw/hwNguIkBeiGwMIG9YA4SVmEMypZO+MmWhMnKa3SBihsUFaUVLJmfHZOeBFQyRrAqQEqWRug9xf0+TL59aqBifXAY/2aXxog0B382SKc8fAB8rvl6e4GgKwonfqrKY1bAG+1nJMVpZ0Bpff2Zzt1b6CSNavlnFG+3XF7fWUOAN4e700R/tO2gXy7Q0x9vwv8sclw6urvtUozapQSrdKmikrvT4p2NQ/6zHa4idZON3YfHvXZ0AQE/tgJa5UeHK0f9TLOBtmPBx8AAAAASUVORK5CYII=
diseno/bosses/golem/puno_reposo.png iVBORw0KGgoAAAANSUhEUgAAABMAAAAMCAYAAACA0IaCAAABDElEQVR42p2TIU/EMBTHf71MEDKxXCYIYlmQl4WcRF4QKATyEjxBIzE45D4G2QeYmkLOskwimokFUVHRYIeALuWuDReeefm3ye/9+/qeIBCnSTKF7kathe88CgGe77deUFnVAJMPLFyQBZRVTZFn9HII5oftNWVVo7SZgcIFNW1HLwfio2Pyk5ReDgBBDdDLYQZGu6C3x+WPVwMsnQfu66fXsxkITL96VuQZty8gPxR3N5cANG0X1O9jN7sFiDbrFU3buRXQ5tNtdlBbA70c2KxXCPeZNq4uzg/W1oDS5huWJjFFnvHfsJ+wGLUWSpu5gtuDvwC7v7mwg+cDHpL35sy3AWkSB10pbbyr9QVXecwHUs1Z5wAAAABJRU5ErkJggg==
diseno/bosses/golem/roca.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAA10lEQVR42o2QsYrCQBRFz2QVLGRBhCCpJEWKhYWYysLC0jKVX7BdGqvU1vb+x3xCCoVUIXWKkMYBs7BIsEgXm51ZZS281Xtw3jtwBb9x3gcdT6KaVgAIDW3Wq39QpWrkIUM1rehpSCYpAOFybuZjbAMB8pB1YvcVdjJJOcY2kRySFyW+5wIwdWxkkuJ7LpbWRHLIPrziey55URq13i3ALPewjj6yKlUb3T08dWz0E4C30/l7u5x9PMA//U9kkjIZj8iLkqq+/NUTLgKjeaiovqCaVohXC78BI3toGyFDPcQAAAAASUVORK5CYII=
diseno/bosses/golem/segmento_brazo.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAm0lEQVR42mWPKw7DMBBEn6OCyCqyDAIswyo4IKA4Z+vZeoCC0FoLDFZFkVXmgnxaqUt2pbczmjEAzrYVYBoHJCtzSgC8ytsYZ9s6jQMAkpXQeQDuj5mlFE5sI1kR1fXeNkCz24oqz1sgdJ7gV5c+Rsy1v9T9O3QeyV+1qNLMKa1A9Q8upWCcbevZ2gME748MSymY35p9jIdyr/kBTaFLTkEjBMkAAAAASUVORK5CYII=
diseno/bosses/mamut/cabeza_aturdido.png iVBORw0KGgoAAAANSUhEUgAAABEAAAAPCAYAAAACsSQRAAAB1ElEQVR42oWTz0sbQRSAvzW5lISNgRwq6BKC9NIf9JCDWsmpYFF6KtRLDpWQi6de4q2lNH9Aeio9tAoSBIWCUI0rCYJliTksQbQNociy3WoVKahroSkV0kOZdeNm6bvMDDPzve89ZiR8Qkk+aL989abr3kJxiaa+gaWrEkDw6oFb45m2fXyAHwBgaHRETNuWrkqBq4Bn+Tzfjs4JyRHWVlRu37npgUR7ZUJyhNZFkD8EXgTcgMr7t7wulph8/JAPy6sA7O58JiRHODm1OTm1WVtRCckRAPqVAVoXQXq66U4NJ8hk02izzxkaHaGmVQGcUYRY97gtNhuHAMxtGUwNJ5jbMph+dI9MNk1NqzJfyHFdUUjE+zt602Gyuv7RMREgEfOFHDOFRX8TERNjKQCMs1/OKOwE4MiyMMz9/5uICwLgTpDJpp1yPCYzhUXisTDxWBh+/uBGX6+n4RNjKSeRx8T+/pV4LIxpmpimyV6zQV/0mgciAAvFJf+eAOw1G74v1V1STatemih377efTD91DAAGkyk2G4cd6sJElCRATX3j8u8IwL7xBbv1u+tFsa5rZepaGfv4AEtXpSBARS05AGu7IrH973O5Lepa2Zl/Kr2T3Ht/AQfs3Fj83W5VAAAAAElFTkSuQmCC
diseno/bosses/mamut/cabeza_carga.png iVBORw0KGgoAAAANSUhEUgAAABEAAAAPCAYAAAACsSQRAAABz0lEQVR42oWTz2vTYBjHP1kLTjLSDXpwMrMisos/GLLDmKUnpcMxPAyqhx2EsstOXtabKO4PiCfx0F1GGTYgCG5dxspYpZQiYQd/lB5ESuboHMJGnFBxUC++Idlr2AOBvOR5P+/n+yRRCCl9bLL77PnL/z5bKZg07S0c21IAoqcbrt3Ndt2DPcIAAOPJCXHbdWxLiZwGPF5cZHf/J6oWY33V4vqNqxJkoF9D1WJ0TqL8IfI04geUX+d5UShxPzPN2zdrAHz88BlVi3F45HJ45LK+aqFqMQCG9Et0TqJyHIDM7nsykyMAPDmOU6/WGE9OUK/WAn1i3eO3qDTaAKiZB17j/MwtsnOz1Ks1lo0FLug6lxNDgdn0+MlrG+8A+GW+kuyWjQVyRjHcRNRUOgXA9/Q97xJ2ArDvOHxtfTvbJGcUqTTaHsB/QHZu1osjmeSMIol4H4l4Hxz/YGSwX4o0lU55B0kmn0pLyraZB6DVavGl2WBw4LwEEYCVgimb6KO3uw/nH3mAsPJHEq89EMcPuDKWotJoB9SFiYgkQE17C8X74f7ZlK0Sbuc3N5N3QmexU90EwD3Yw7EtJfDFlq0SAFrvObbNPNrFYWmjmKF/318pC87uLo8+uQAAAABJRU5ErkJggg==
diseno/bosses/mamut/cabeza_reposo.png iVBORw0KGgoAAAANSUhEUgAAABEAAAAPCAYAAAACsSQRAAAB1klEQVR42oWTz0sbQRxH3yaBIgkbhRwM2CWU0kutSPUgVnIqWCo9FdqLh0Lw4slLciuU+gdsT20P9hJSIYIgVOOWBCFlG3JYgth2CUVku/6ISEFZC41USA9l1o3r0oGFGeY7b95ndkYioCmjDzovX729cm6xsETT2MA2NAkgcrlg8GGm4xztEwQAGJsYF92ObWhS+DLg+fw8u4enROU466sad4Zu+yB9vTJROU77PMIfwi/CXkBleYHXhRJPnzziw8oaAF+2vhGV4xyfOByfOKyvakTlOAADynXa5xF/HICRu0lG3mQByL//TF2vMTYxTl2vddWJcchrUTVbAAxd63ELZx/fIzMzTV2vkVez9CsKN1IDXWcT8pLXPn4CYOvst88ur2bJqcVgE9GmJtMAxNoXn7ATgEPbZsfa+79JTi1SNVsuwLtBZmbajeMzyalFUokYqUQMfv3kVrLXF2lqMu1u5DNxDn6QSsSwLAvLsthumiT7enwQAVgsLAWfCcB20wy8qd5I4rcDhJTh+51ns3OuAcDN0TRVs9WlLkxEJAFqGhsXl00A9na+47TPrlwoxg29TEMv4xztYxuaFAGoaCUXYG9WJDb/PS6vRUMvu/2vpXeSd+4vJhDWYR8FwVwAAAAASUVORK5CYII=
diseno/bosses/mamut/colmillo.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAZ0lEQVR42o2OuwmAMBgGT3AaC2vHyAQhpMw+2ikhCxhX0Ca2Fq7zW8UXCF593wNnlfCBs0qcVZLmKKU2BkAAuiEWWQBo+xGAdZkog/doY6jq5gzchczZkOV9S4/54P0l3ufe5Du/OQC/myiYFBqqlAAAAABJRU5ErkJggg==
diseno/bosses/mamut/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAVCAYAAAAElr0/AAAC9ElEQVR42tWXT2gTQRTGv41FvCl4KoS0SumhFA+lSGlDWoTQklAPFtqLByUWpPdKEeKhuXjbQi8FEwhpKFgJSHWDS4qaZak9lAiSJloxTZbIBiu0SiHH9aCzzuwfsmli1Q/C7L59M+/9mPdmN0Cb5QksaLW6pr2qaZonsKB5Bid+/mj74IT2ICmb7Xb+gQWtUdyOVpLuD4SYAN+/fNavn7z+gMX7dwEApXIVc1MjKH77ZV9aAQAsLq1gLblu8gfA2J2IayXxzVRUv77HP0ZNUdAzdp2Zc9V9DmvJ9ZbtzxNxKOmH3IlB6OTpxAFAPayDj28AAK75hlAqV3G52834lMpVAGjZvpZcx/udl1B2XnBNgRAAOnn1sM74GCH+tLblLVuYDjsIAmBM3ghRUxSUym6choa8w+RSM8K47CDUwzqyBRUAsKcemcbguA8AEJq9iW1561RAtuUtJPh5jN24ZepXlxVEtqBaJk+PgighOO6DIEoMTLuh6HUT/DyyBRXBcR8GvH4GxmUF0UiCKKHb424IY4Sye+7Ej0AQGWG4ZiFo7RZLKCtVvcxG+zoBANmCitijpKm2G+2W0S/Bz+vP7HITRAk5OXOyF6IgSnqjD3mH0dt5AXvqEROMJEFD0bbdYglzUyNMolZ+TvIAgDP9gZAWjkRQOTh2DNLb04WPnyqYmZ7Es6cC8vs19PZ0MT6Vg2NUDo4hiBJmpifxNvcOb4pVnD1/EQDgvXIJuf2vDf2c5HFn9jZc+XSMi4TDelk4Fd0bNUWxnW/nRw6NZtez2pFIOPy7Rwa8fr3Wm9VoX6ej/mq3H90jHH1qtQLzN0Qg8ukYpx+/+XSMy8mZ/xKC+daiXy6r0WVTDf/LEPoLkZTVZiqKzVQUfHwDgigxxxt9f9ojHZ+2WX799gdC2mp0GXx8A6TEyM7Qk8npQsZ2y7i+VRzjbpi+tYzlRCBycgY5OcMsSoKQ4O0arXaFju/ojxXpE0Jrd0804PW3fUesDhy7fGj9ALFKd9TOxZeJAAAAAElFTkSuQmCC
diseno/bosses/mamut/cuerpo_reposo.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAVCAYAAAAElr0/AAACpklEQVR42tVXT4gSURj/TQl1q+uC60aIh/AkSyyt2BKIy0gdWqhLhwUJYm8dXCQoavfSbRb2spCCuCKsIYQ1kiiVMoiHxS7m9gdEBmNkIaxYMIh4HbY3+2Z0ym10wB/I9+bzzfu+H7/3fe8NMGI4+Ajp9Ah53SHEwUeIY3bx8Mf6ZxfJg6TU7zeaz0fIv+LazCTt5kOaAN/3P6vjp28+YO3eHQBAs9XGytI89r798W9sAQDWNraQSqb75gPQ+IcBZybxYiaqjleFHXRkGc6Fa5p3LtpPI5VMm/a/SMQh5x5z/02ETZ5NHACUbg9CPAsAuOKbQ7PVxvlzds2cZqsNAKb9qWQa73dfQd59yR2LCCXAJq90e5o5ehLjRlWqGJKxGZGgBPTJ60l0ZBnNlh1WYM57iQ6JnswJIxJKt4dSQwEAfFS+9tm7y4d7OHT7FqpSxRIiVamChBDGwvXlvno9OYhEqaHgy8EPAPirdTlnIObLuHnjKp4/E2F3TKMqVWB3TI80ebpuQgij1FDgcs7g4KcNv06debj/6e0jjSIsieMgGPBBzJc1yozDUhJsXI/XryrDmSGhx+ULUwCAUkNB7EnStBoJIayOjXIT82XUpIK5A1EPNhibxKB57/aaWFmaH3o9IxJq+3XzIXJ/fR1WwzV1Vm0eZiDmywgGfKPdWlaDKlKTCkfFvirsYNIQDPi0B2I9F+MAEP2fk6BITSqgnotxqiL1XIyrSYWJJKG5a7En5XZ0cySFaBUJ9UB08yHi8fpRzERRzEQhxLMQ82VNe2OfrbZsfNY38Pbr5kNkO7oJIZ4F3WJUGfZlepJTO44CZtcfFEevRt+lUb+dKImaVEBNKmgWpUHYBjEKO0gVNv5QH1a0Tihbo2cKj9c/ckUGNRyjfFj8BkPvEKIZ9duXAAAAAElFTkSuQmCC
diseno/bosses/mamut/estrellas.png iVBORw0KGgoAAAANSUhEUgAAAA0AAAAFCAYAAACeuGYRAAAAJ0lEQVR42mNgYGBg+P///38GJECIzwQTIJZmYGBgYGIgF5DqPLIAAPDDL9Vq5xinAAAAAElFTkSuQmCC
diseno/bosses/mamut/pata_a.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAKCAYAAACXDi8zAAAAZElEQVR42mPQ8Ur+/+L7fxQc17biPwsDFDx//52BgYGBoX/BJgYGBgYGJpjErecfGG49/8Dg7W6HKgEDW3cewi5Bmo6tOw+h6jh47TlcJYxmrJu15T+6cXt2bGNg2bNjGwM2AAAmdzT6HMKFewAAAABJRU5ErkJggg==
diseno/bosses/mamut/pata_b.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAKCAYAAACXDi8zAAAAW0lEQVR42mOUM/H43zRhBgMyWLZkFQMTAxpYtmQVAwMDA0Li3oMnDPcePGGwsLFClYCBE0eOYZcgTceJI8dQddx78ASuEkYz1s3a8h/duD07tjGw7NmxjQEbAABXfSPpiscjAwAAAABJRU5ErkJggg==
diseno/bosses/ptero/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAACKklEQVR42u1Wv2vbQBh9CsIYEVwNwgQjjDCJBuPBeMhgTHBLJ9MheOiUKQRTOmXKXxDyB2QItEPo1KFDyRA6dKmH0CFD0BA6qCVoMMIUE5QQRBGGr0M55WQZ/4h8KiV9i+4+ifu+p/e+uwP+45FDy5RJxLpLaZMwtYYQMlKaKphaA/bgDIPgm/TP2UjLlOnta4vqhQ6JstXCFMnKuViBy0s6DnbeAwDenRwJV0JaBInt9cNI7LN9jL2Xh7AsC5bzNRU7SUlJbFS2cWGfhjFVKcDzXZjqMwBIrScelCCXNSgYXkNXq3BvzyPvGuVX4fiqd4GeZ+HX8FZixNk4dSK5rBHz/1Z7FwDQPTtFU9+K2YrB813cBT/v+yaTj8wZFkFOnkZCz6/C0E0YhhnGHceG07PHFs9DVQqomS+wqlTD7/g5AHyw9gEgsVIzK9KotSLFMwR+AM93w95QlcLcRYwq9xClpHn6Ylyc9YrnuxEl5kVJr8WUYuRmIbSQxlNkjarFNj4evwEAVFprEYVGlRqNT3vyG4YwIv0uhUqtNKVwd1rO5Mf2DK8cw+Wn76i01mJxYYr0HaIV40+x4whMPe0n7Fr8esbzJ3B+3IDlEoJ+l4hPmvQqM2rRotqkJDlmKr7fJaqXOqTImrDLHyNTL3WIz5vIWvwC65tPMbi7BAD4w4HQKwf7UdViG71rG+cnXzDJxjOpUC91qKg2haowiRCfP5HlFFn7KyTmzf8bMu5B8AH1zG8AAAAASUVORK5CYII=
diseno/bosses/ptero/cuerpo_picado.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAACWUlEQVR42s2VP2jbQBjFn4wwRgQhignBCCNMMcV0EBnaYgw1HTqEDCVDhlBKCMFLls4hQ4eQwWMpGUumDKEEDyGDCdQBE9IM5oYMRjFBFGGMKcY1QTXC5DrdERkbO7YV6QOhk+4Q76f3/REQgJDEKGXrezgIIcz3vqwW+Prb6Q6uCj+xkBUEBCUkMUrZlV8r07iSpelEjkal5zSdyNG4kqX5tTJNJ3L8uVGidNj3RL8g9PgKPrz5xP/0cmodADAnSwCAcOceplkDAFgtY6QTvoDYvT8C+X1Mmcjl1DpqNuH7t1YFbbsO0rjgEKPC11yLiDLdePXVBdEPc+c0YZ79HVkXIb8hisZ3LpzdGURy4d1YEL450g/RH227DgC4Pr0Zu0OFggzxmAgFEeLOaQLAo+aFECQIBjBuXTxp+42IMp0LqUhGMwPFK1KMQ3R7HaFRonSSyS14DhGex6q+AwAuN1gasVTq9jpTafHMkWg4Rfc2DwEAB4V96Fp6aC1MC+GJIyyV9jYPQQgBMS+ga2nuxkOIWQB40rUiokxVRXdBDOtKs4SYKQgtXVJV0dG26zgo7HMn+ruSFxBTp5Yc0ajTa+HfWRF4+xo4/4Wt7SpqNsGtVcF8+AWaTtXVlbyqSWES8WydWVzCFSlCkWK4+ZHH1nbVVQuKFIPVJjMr6KlBHor/uPKZvy+VT6CpSRjGNd4nN3BEdl1z4SkARoIMEm+aBkzLGHheffYSFePEs2KeCESOaDSzuATTMqCpSS7eatb4GafXAht2R2R35nPBE0dYdLqmMGhy+wnA4j+jsXBinsmlcAAAAABJRU5ErkJggg==
diseno/bosses/ptero/cuerpo_rasante.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAACSklEQVR42u2WP2gTcRTHPxfCUY4QQjlCKaEEKTeUDsFBSygqGXRxKB1KBilSpEK7OHUoGRzEoToUKYIOQTqIiEgGKbSDOLShU7khSDmhZDiOEo9wyHHIEXIOJWcvCbVpmkAx3+Xxe79/7/v7vvfuYID/HLI44fXi3FC/SSjydE/ICP1UQZGn0cxdTPe7cOXSSBYnvLdLqpceXfR6lVaXpshQONoSYCSU4Pmj9wC8K7zuuRLCZZBIxFLcVRZ8346WZ2XuFaqqopaLfUknoVsStyYX2F7Pcu/JBwCO9AMsx0CJZQD6VhMX6lrRoaTXUGJ7PQu3b7K9nmVcSgEQk0aJxCUq7iF2XT8zBZshhWXvwop41lpHm5eXRAC+7X7BdVx+fFpjefWQHS0fWGc5BrZb+Vs3YjwwbuB37ZfQIJEam2XvYLxzIlJY9p7OFQLOwv4mn7++YTbzGKt2BMCd6fv+fLmsUda1E3/igV8X7XAtcd1XakfLB8YAH9Vn/DQWA3teLKVbzmnEtLm6F/BvbOUw7dIJETkySWJYCSyYmZqnsL/JzNQ8G1s5ItFw20ArZtlPJ8sxiEmjHb+m5RgoIxn0qkZiWEGvav7c6bhSI2nU46I/1qsapl3CqZmCL+nDGy9Rj4uBw07b1EiaZLJV8o2tHGK4juUYvu8iZNop1Uyu2QKtRFJjs4GX6ASmXaKOG6iF0wp1a91a6My7fSLddAsAp2YKzW05IsbPvd92K7Rb32gMIcR/3n3u/t5pZ7vUj11s5Wr9mw0wwAC9wx/Bshs4CLCjQwAAAABJRU5ErkJggg==
diseno/bosses/ptero/cuerpo_vuelo_1.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAAC40lEQVR42u2WT2jTUBzHP5UQSimljFCKFAlSi5Qeyi6OMXDsoDB2GB7GDjJkDDx48eRh7CAiO3gaMgR3GNrDEJHRgxS2g9thK2MHyaHIyESKhFJGKUVKkFAaD5rYP0nbuD9e9oXwyEte3u/zvt+XBBwUECQzIEjmtfC4Wd41Tf6jWusICJJrLT6ngU9nsgBkDzJoVZXD7A4A0XGf76JBrIV8tvgWpZxH+b4JgN6o+FxBLIhi8WvXA5Vyns3116cGksSkWTG++Ho5oDcqPgsgs7YPYNcky3FWc0tU6oU2mC4QKZgiNpTomkCrqsSGEqeCkcSkmZDGUCt7OMFY81sJyKztkz3IdNUB9AbpBwMwPTLHam7JU9wkMWkC9ILojJEsxweGcAQZBEarqkwlH/SNmwWwvLDBm+yrLginGHUWPwgEwBWnQXqj4qvUC/bg1odpVZVDZQdZjqNVVe7NP7RX0y+E7EMSk+bywkZPCCmYohViNbfE5qfXpKOjniBcHennzPTInL1yWlVFFJrcSczb17fVdZ7MvERRFJRi3jFObjFKR0dRynlPEH1B3GCsja9VVW7KabZWZrn7+B0A37TP1PQSifAEgA3h9jZyi5IXCNdo9YpZaysKTbZWZuH2LbZWZokH0gAMJ6YIRgKcGEfUm5prjKzv1GkhBnIk5JdNgEajjhRMATA1OQ3A7t5HDN3g+MMLHi0esa2ut42t6SUKuWP7PDV5g0R0wrV4y2VLg0L0BQn5ZTMWiSPHEsjy32gViypF7feE47H79r5w0vXYsO3Utrredg7wXnluw7WCeIHw5MjY8KRdfKsM3aCmlwgHrtqtV9X0UptTlXqBJgY/Gz/ODqQTqAukUSUWTlPTS3bfv8A4OVU3TgAGAjqTn0C/EGqDDIqRNoc6ners79dqNaUvzLn8zfqFkBkUI139VnGdqhsnON3vxRHhPED+TOwYRau4Qe73skcuVJ0RvNSlLnVx+gVIKgy07g7hfAAAAABJRU5ErkJggg==
diseno/bosses/ptero/cuerpo_vuelo_2.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAACZklEQVR42u2WMWgTURjHfxdCKCGEUEIJ4ZAi5YbSIXRRStGSQUE6SIfSQRyKKFgHJ4fSQaQ4OFUphXYokkFEJGSQQIpoh7YUh3KDSDkhBDlCCSGcEg45Qs8h3nnJXdLYNgEx/+V473333v933/e+BPr6zxUNjJrd2NfXawgpOtkVGKGXWZCikyjlHcrGF+GfK6NoYNTcuC+bE/G7ZrfK6twyMuAPuwyGfCJP77wC4GVmreuZEM4DQowkuCbN23NbyiaPZl8gyzJyYa8n5SScFeLK2Dy5lTmuP3wNQF49QNOLSJEkQM/uhB/gaNtsWbuxKcFlIjwwbBq1CmIkQW5lDq5eIrcCC4uH5DlgXJq2oarHagP4z9qPU0O18ykE/VHz8WzGtZDZT5HeXPd86cnGcwC2d95h6AZf3z5jYfGQLWWzIU7Ti1SN0p97Exiyx4X3308Fk9rYdfmUv6XrIIkLM/aCWlEA+CR/ZCZ5D62WB2BqctqOKRQUCmo9bkq8Zd8LL10UxxkJJuwY5xjgjbyMFEty8/LttgCZ/RTpD+ukFnfJ7Kdsn+XqZ/RauV42VlZWs0uIgxJqReHBjWVWs0v2MxT2ex5QKhcAiATjaHqRSDD+119Z04tIsaRtzinLjzgokYhNIB/t2WO1orhBoqGxlgdZmwwPj7jWVrNLBPzHaHrRnjsNTKtMecE51QBiwbT8YWsDaW12jNFwF5wZas5U8/xJT1WT8RHwPFuvlYWO2287SOdmzu4UCgy54ixzzaoaJbzircbQSafzdwLSbPQk/T7YE97ZxU6KP0ur7qq8/sr01VdfvdEvhtUwSl0Z6FYAAAAASUVORK5CYII=
diseno/bosses/ptero/cuerpo_vuelo_3.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAWCAYAAACCAs+RAAAChElEQVR42u2VT4gSURzHv7OIyCAmMYgsgwzizmHxIF4CkZKIAunkIWTZk4RBddhTh9jj0sGTxBK0B4k9RESEhxCUIA8W0SHmILHMwuJhELFBZBmGZZBeJ5+OOrr+GSG2HwyP92X4vffh+/u9H/A/rnhwzm1iR96NdUOIXNwWGGadLohcHLJag2r8Yv65MuKc2+TosURim1liV1mtzBGXwzN2QfcGjxcP3wIA3hRf2e4EswoI3hvBXTFDtYpcwLMHLyFJEqTGt7WUE7MsxM1wBuV8Gvf23gEAzpSf6OpNiN7bALC2nljo1fK4BNJ3opxPA7duoJxPI8RGAABR8T7cPhZt4wTaH2VqCa7NEY9LGDt8N7UHAKjWPsHQDZx+yOHJ8xNU5ILpv67ehGa0B33j9Jn2/bjonTO2gnhcAuF9IQi8CEEQqd5oyGgoMgAgwe/SvpgUQT5KnarIBdMeAN5LB9CM9tIwl3YkHk3Syw+HoRvo6k142U26zhujzi3iFDNPX0zSjV4HbqfPpC0CY+XUZYGWrk3WwRHOHcaP4heqhZNbJodGnRrVZ61KV5oJsxRIq0qoS/4Ewwy/TqMu9Z3q6s0xvV46RTi5Naav3JFWgxC/MLioFcDMaW/xam3AiUgghY+F11QT7lzDRe+cGT176WhVCel/uZ0aCXgThHVwc82FaXOEdXAkFsyS3E6NxIJZMnzeSpp9ONHx0VcAwGFpH6pWh95TVzqxWQdHIoEUlI6Mp8kDHJb2Tb1n5b4lyKTLA0Dx+zGUjmwLxCQY/rqIiD8GQQjNhGKsIFKZRzTZ8GonhBWM0hnML1Wr4+zz7zEYZloyAODcYVMSuyEmwahanepW5/8F04Rsbl+fwNwAAAAASUVORK5CYII=
diseno/bosses/cangrejo/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAVCAYAAAAElr0/AAACoElEQVR42s1WP2gaURj/PREpt+QKDkUFnaRIqDc0Ih2Ks0NIlk6BdOrQgHSxw2WOgy5SyA0OBSWU4hLoIB2lg4RK4QxGitMp6lAcLhCOEoTXwbzL3WlOzz+pP5DH3Xff9/1+3/e+5wNWDEopXca+KMgqg3GeJzpJ7fYvcWrfGFADAICqWX2lanZsuFtXndu9ymDH/qcI8xzaqjYWsZUGVUEB4NyTxv51DthKA9c5bJQQ0cdPVDbh96KtdscPBsL7tznTu2m+RmQGKlnbjFiTn0ji5Ec/ZSAmLFXdzukZClddR8KIE/JG4p3TM1u/an+IhN+7sB0AgkcHAICimEdb1WxFkVkirOSr/SEAQNhNIBoXJgStyx7c2QZigi7KKobYdeFEEh+sfPDowLYr67RX+0O9Q0wQsevCrO3zPxHc2Uan3kThqovMQCUuu4HbZHTqTX0bAoDL2o0wz80lggVZ92qHhN+LMM9B9PF0+tZ6m0Sn3nzwpJkniRWHmQ8oinnHfizftBOOzUpmoBK3XduMztZKHX757IyRcunIp/G1BP5X05R3Gp+5Tq0wz+kVmSChXK5/EEIvTPmKYl7nM/PUmjYzwm4CABCNC2hcyIjGhUcbapavcSEDAORv1an/I65Z952y8gflUkUPuujKfsvEKZcqeMZ5IKs3zq4oSc5Npb0YfrcH+DFQIas3EIQAAODN61dr7wbfVVCotvS8stwD4/Op1UNFGxFHt18moqKNSKWmIMm56buQAgB6UGMiY3L9nvbxPY6zkimuLPeQigTwPOwzxWE2aS92vztqCklybsqKmooEgFaPMjFLXeMZYaNA09asKfcdz0rU9MzQ6tHUXbGMPoy0ERVtRNDq0VQkoH8/F5Kcm35/GaJWgk7fP0aef0vfEpTIlAnjAAAAAElFTkSuQmCC
diseno/bosses/cangrejo/cuerpo_reposo.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAVCAYAAAAElr0/AAACn0lEQVR42s1WPWgaYRh+Pjmk3JIrOBQVdJIiod7QiHQozg4hWToF0qlDA9LFDpc5DrpIITc4FJRQikugw9FROkioFM5gpDidog7F4QLBoQhfB/Nd7vRyev6keeD4uHvvfd/ned/vD1gzKKV0Ffuy8KwzGO99Qp3IzrM/GlATAIDqOWOkem5iuB3XnZtbZ7DjwFNEBB5tfTQRsZUB1UEB4Nybwf51HtjKANd5PCohkl+YqWwy4ENb705eTIT3/+Yt3+x8zcgOdOKGC1mF+Ikszf70UwXi4krV7ZyeoXjVdSWMuCFvJt45PXP0q/aHSAZ8S9sBIHR0AAAoSQW09ZGjKDJPxDT5an8IABB3k4glxBlBm7KHdraBuGiImhZDnLpwIkv3Vj50dODYlU3aq/2h0SEmiDh1Yd70+Z8I7WyjU2+ieNVFdqATj9OCe8zo1JvGNJw52SW/QCMCv5AIFmTToxOSAR8iAg/JL1D7qfU2hU69ee9Os0iSaRxmP6AkFVz7sXx2OxxbK9mBTjintpmdpyt1+OWzO0bapSufxtcyhF9NS147PgvtWhGBNyoyQ0K73PxCCL+w5CtJBYPP3F3Lbs2Iu0kAQCwhonGhIpYQH2xRs3yNCxUAoH6r2p4jnnn3nYr2B5WyYgRddmTPKnEqZQXPeC9U/cbdFSXFc1Tei+N3e4AfAx2qfgNRDAIA3rx+tfFuCF0NxWrLyKuqPTA+n1o9KKMxcXX7ZSKU0ZgoNQ0pnqPvwhoAGEHNiczJjXvax/c4zsmWuKraQzoaxPOI3xKH2eS9+N3sqGkkxXOUFTUdDQKtHmViVrrGM8JmgZapWdPuOp6TqeWdodWj6dtimX0YaTOU0Zig1aPpaND4fyGkeI5+fxmm0wTdfn+IPP8AUmoUuzuDyNMAAAAASUVORK5CYII=
diseno/bosses/cangrejo/cuerpo_reposo_b.png iVBORw0KGgoAAAANSUhEUgAAADIAAAAVCAYAAAAElr0/AAACoElEQVR42s1WP2gaURj/nRyhHIVcwUkFnRwkNDc0EjoEZ4eSLJ0CdsrQQMhih8usgy4SiINDwRBK6RLoIB06iIOUSuESjMhNp+jRweEFxKEEXgd7j/Pucnr+Sf3B8bj73vd9v9/3vffuAUsGpZQuYp8XvmUGEzaeUTey0+xrA2oCAFCSYyMlubHh37js3Pwyg50FXyAqClDJaCxiMw1KQAHgeiONg/s8sJkG7vNYKyFyQLRVNhH0QyXd8YuJ8MGf/MQ3J18zsjrhvHDhFiGeKcr2ST8VIC4tVN3OxRVKd11Pwjgv5M3EOxdXrn7V/gCJoH9uOwCEjw8BAGW5AJWMXEVx00RYyVf7AwCA9CaB7V3JJmhV9vDOFhCXmCirGM6tC5mi/Gjlw8eHrl1Zpb3aH7AOGYI4ty5MWz7/E+GdLXQaTZTuusjqhPO5bbh1RqfRZMvQ9meXAyKNisJMIowgqx7dkAj6ERUFyAGROi+td0l0Gs1HT5pZkliRyp6iLBc8+xn5nE44Y69kdcLxbm0zO1srlfr00Rsj7daTz83nS4i/mhN5nfjMdGpFRYFVxEZCu139Roi8nMhXlguMz9RTy2nPpLKnuPmhYHtXYuNTwZwXAJSvVcf/iG/afUclI5zliizovKPxLBLny2UFCSkCAEgKPPV0RUkKPC3ux1GqtqCQISQpBAB4u/d65d34/b2O81aP5VSUHiTxOfYCImo6gUKGqIweuKm3X7MI1qW6xiUFnh5FNJs4RemhuB8HALRVfYJE5sN71lkzDB/zfEXp4SQWQk0nOImFcK70GGFgSI8SMdR0Mt813qzetgTrGmdutyGwMnrgKnVtPClXpMY8a7Haqs6IsTmtHjXEWNFWdW+tTQo8/fYqQq3r0ev3p8jzF/o8DrNSC2sMAAAAAElFTkSuQmCC
diseno/bosses/cangrejo/pinza_abierta.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABDklEQVR42p2ToW7DMBRFjweLwjoZFVQB+wCDgOF+wcBIeUBVbN7gqWC4IfuGwKEAf8FkFRRFCjMK9cDk1Enaqt0ltvWe73vv+lr474Mvc836syCgzDXWdf25aJwIey0TzwhxHEAcXqRfF1uwJyZQalJg9/UxSInjgVxomfg0mfVJq1RS2YZVKgGYZ6ovAIAxtLVhnql+BWhrw94cKRonRDzSRi2pbDMocC9CI3tzZKDFWK80mf2LWNxK0jLxu+07bW0eIn66RTjQ8k5CYNppIAuvXOb6YQnO/ssWnpMbkMUYu+KSlpVtsK77I9XZwr+9Zjz/2H6E2Jvh0S4ViN1iXXe2VNzptV9yzXZxA+HOL/vplAtiibnYAAAAAElFTkSuQmCC
diseno/bosses/cangrejo/pinza_apoyada.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABE0lEQVR42pWRoU/DQBTGf7cQxDJxDtJMTFVMVSwVEwsSRdAY/MSCQpxv9bIQ/Ax/AAqBQFWcmr5UoJrVnSC1h2rXLu22fuYlL9/7vZf3CQDlSceR4swKWnSJ90p50kUf64YpX7+BTl0b9Ni7XSoUuDpc7B9n7stk3PseZb2ZhxCGtErr1naeaDY6Jc6sEGo+cdHrkq06XFBfcKlK/0anCAA1nzh+bWXw5bCxoC/4bBjRyxN5onuBB2ddXb/tAAKHSxvX1RLeLlXvF4gS6Mshz+9xBTpWPbxT1dgCUQKDhzt2nz8VxNiCnf0DIJCjRnhdKmcGC09ibMH+O8HYgtvhNcYWLDxJIEespmOAqn+qAqymY/4BiRKRB3GaI9AAAAAASUVORK5CYII=
diseno/bosses/cangrejo/pinza_reposo.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABEUlEQVR42p2TrU7EQBSFvyEEgaqDjEKQhvAAI1agK1EIDOgKgh6/1ZsND7A1aGSfoGKegEwqUBPqRtUWAdPtDtvsz3UzOTnn3nPPFVom/fx9AUCZa6zvGFfhvBi/tUx6oooxYnUre4Cn5/v1r1IAtIs3lqbZIAgNhBo3EshPbXLGw90MlKLMNVkqqVYfg0hMgjG0teFipmhrM+Da2oBp+sJ5IbRM+hd1TWVdPBVZKtm3KuvIUsnSNIgpn4LQMcRiChCE5q+Pv6MdQHyyE/W3tH0JASbjMo7ZoRZseDredJnrf0ub8jj8V9Zhfcew/e+blMtPO4wQH0GanG8VGKfG+o7CebHu9CqBL7/zkrbFLw7/D1aikwvGhf4dAAAAAElFTkSuQmCC
diseno/bosses/cangrejo/pinza_volteada.png iVBORw0KGgoAAAANSUhEUgAAABUAAAALCAYAAACQy8Z9AAABB0lEQVR42pWTIWzCQBSGvyMoVB2kqmJppmgVIRUEtaAmZ+fJQlATRYNAoQgWFEFOTS6IBtmilqoqMonCdoLcUeBK4Tfv8t697/57uRNo5HtWqsu/tTxW60BXYhQkQq6FDjacznhIyZbBeKrgIgtUsGRLtAkBcJrufWCrTrRcsFoHR6cKmIGFXz+8j/o8qmgTUrpMZp3N/QlY9bOGIiBAyfesdPjZJVouVMFpurivbW3DrSgNHa9vGmmv8cTfs33TiRxJkeOyXFT7H1QL5lX7jSFOcDovV7V511cHnjn9jnd0bDM3ShXtOz0p00gBbKOS61Q25ineH64ffxauk21UVKP2V+32AuAfdCKE2bmOGxwAAAAASUVORK5CYII=
diseno/bosses/cangrejo/segmento_brazo.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAGCAYAAAAPDoR2AAAAd0lEQVR42l2JoQ3DMBAA76OiIOMfwLNklo5gXuOADtCSzhBYVOARXsWWwh6ZflGrqIdOdwJQNAVATjPmA4DaXU5FU1weKwC0BsD+atDeIfG8xb5eObJZZ8nKdD+XXziOzTpSNEVOM/+YD6baXcwH5oMlK1+v3eUDJVk34RGQ3/sAAAAASUVORK5CYII=
diseno/bosses/sapo/cuerpo_aterrizaje.png iVBORw0KGgoAAAANSUhEUgAAACUAAAATCAYAAAAXvcSzAAAC5ElEQVR42u2VTUgUYRjHf5MSQqWLCElKLouBmMp40Gwz0E4ahn1cQrwWkbdQiQ4invwIiSDwGCGySmB+BNGlRWUY3YOLISwIw2ysi8X4sYEosTkdbKaZ2R2/6BL0wPKw78fz/ub/f94Z+B//cAiHLSjy5+nOsaikCcdd89eiyJ+nB7RePaD16k3jt81shbCuKX0mmjkd6FEj8yCgvsl2egYDACx3tnDrk4QSUinvqIWBOR2gb7Kd4VkZJaSy3NnC5f4RfFVeFKAI9JOoJxwFSn0eAWD7Ww+jyT2W1r5QkX8RwAQy1sTHdugvbjPrWNd9Hpg7ksWZJ5V4eFYGQAmp5lh8bIecZuiceEV/cRtLK3HejUj4qrwYqhrRMxgwlXTCCW6NbdhixFS9n9Hknm1MCan7Vv3OU/V+EsEOPtT2mQpK1Yu06nfSPljFpQssrcRNBQ04IZ1lViWcBawgUvUi/oVK83/Xk/s2S6XqRXKaITGBqVy6aL1eQ89ggO1gjKikCYITyE0JZ1gP9C9UpsxbwQ3lnHWdoYRUtoOx1J5ygighlZmuoZQCSeZJTFwh2TDPTIN9XtuNcLf/BbAP7NO9tvrpLLU+uGCoVN5Ra5uwgkzLQ9SIdcjhoC3nZZWg7UbIyypxvRAGoFU5N0sNQWz2XQufdS3eFe9GDgfTztWIda77jAd4E1swAYaFcdtlsDqzHYzZoc7UFeKr8vK68amt8LQ8xMebQdeDX24E0HYjB4JllZWYfWW9NM7L4vFk/+mpqKQJRaArAI3YDqkR62jaeHSgRQcBOcMKlNMMEvtgHk82kZElTjnfsN74FtPyUEpBbTfi+jvMOmczG5b5FypJTMDjH/dMIIAMZ6F16I7mnuZ8RgKA2JpKYb4XORw8djb2Z5WVmN/QzfiWmUXRx/ufY6iqxmo4xo0HV/m6nkh9o+eKHv1caS4FYiGr4RgFYiEPq33H/gy93dxKbWL1u63uajiWdu8vc933B8LGNXUAAAAASUVORK5CYII=
diseno/bosses/sapo/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAACUAAAATCAYAAAAXvcSzAAAC8ElEQVR42q2WP0gbURzHvycOBW0bJINoMOHQIraGlyESrrGETlUsrUuHkKF0KAUXKSrFQmmFgonFoZOjQwixFGJEinRpqBpCDmpIEQLC8ZQ0ZDhsLdh2EK+D3ONecndJSn/L7+X9+f0+7/fnXQQ0ELfk1GrnDrOq0Oqe/yZuyakl1UUtqS5qQ/OEaSOEcc9E6j7TZqDNSrsdUHRjBvHtHBSZYn8ujOuxBES/BwoAN6ABQHRjBgvLSQDA/lwYdz9locgUw7NBYGnnnyIoNIJaWE5ify7M5p+XKRt7u/s4IF3Wzs5RrB7B293H2Yxv5/B1aachoC1UR8gF+qZUtzb95REbFw8qUGTK9lXe/Uasf4pb9w70cBepBayFE+yiVKwesbnXLg/Wzs4vHFWPUDyocGcUmSI7soer94CTNBDrn2LAot9zATTQwyCLBxVERgNYWE7iNFPmwAS7WjJKZDRQN2d0yFIkpLAVjLJazI7sIaJN2taQIlMOTGgGyMqQmUM9ClaRawasrRkgRaZ1WncYF1KsZhSZcimLaJM4SQNbwSgHpNsxiuj3oCPkgltyam3NAJhpKe/DSfpCryeylvti/VPcRfULWfll6XNLTm14Nmh6AwD4/GKlpcdvM7eC999/cPZEv6dhSvUIC8b03Sx0Wjp6e5zEZs4cbiLwpCGgXTPowABwminzUB0hF0S/B6tjz+oMfxzP2AKrf0qW67lCBpduDLI01jaD3ix6sbcbX1c3oCkAMAbOSYCEMHFsHY1GQLVS253xdApS3geH4wqqv874b99hVhXGr3VqrTq2kwAJmYKJfg+kvA9Z7EHK+0CIiN31AgbDXrRZAeiGzAw2I2bnFZmadrEOBAClRLEe6sMqFZ5OvzQ1bAXaaJ+xnoxAhIggRASlKnqJy/rb10Uc2p352+z37noBrx7faik1Ooj+D8IohIhsTKmKb4UyeomL06ZQl4e66owZD5YSRQSIAw8ehth7pLc11970Z53DZuQvnQsY9rZwRlkAAAAASUVORK5CYII=
diseno/bosses/sapo/cuerpo_lengua.png iVBORw0KGgoAAAANSUhEUgAAACUAAAATCAYAAAAXvcSzAAADBUlEQVR42q2V30tTYRjHP0cjREk3kTjo0MNAkLBxbpQxHIyu+nGhQoSsXXjVHxAVUSC2Owl20VV01cWQBYJLuqibOmCNgReNhWAJchxrjFo5s1mEuS7kPZ2zs61j+sDh5bzv87zv5zzf93mORBMbCPRU55ZuEI0l8I4obKzoeEcU3t1/bfGbW7pBfDltrG+s6FS0vG2/zVRJwoFJToBWb4WN+bt5HZ/cb/Gt9Xmyt0+2mLP4RWMJC2gzwBNOyDtOzwBQ+RTFJ/eTLeaMtex6weZjrJn8JsIBCINP7icaSzAA1UZwLY2yhEPbWNEt79vaTQtMcj5lWc8Wc0yEA1x9dIWzN8cYCPRUa8+TGskGEF9O4xvsBTCkyBZzZNcL+AZ7Sc6nmAgHSM6n8I4oxKVFusZh+yk8H5sjGktYMiXizGMk6DekFVmT6gHFl9OHypC5COLSogUoNfqWSHXS0X4CrPUoQKnRt7zqfQGAu88FQHtw0wLUNQ6X3k/RHtwkm8sb8cJfmLvPReXkPu2/92ZbGh34r1EcGJcWiQT9xrxoHwCR6qQhpfjY2n3qZV4yZ6oj5HF6vw2pItVJ2wFmSWeuT9mAGkkqJDSgwu1K04p78DXhCPZZ+iELW+W6d86cYXMxiMwKsGOHagTYrBjM4BUt76x5Civ9XDsUlF8NQUZjwQQE1K3OpnfKO6Lw+MLtIwOZLZ3RWNgq163eWikrWv5vR99MlSSlUOay20Xp55rtOYr51RCX3S4iQb8hVW11RmMJXK5Odnb37B394rRSvTIdOkj9MVk6o9E2PGTrgWbJVNXLm2SGPtVDa+0G65nyvV+UZ7tk8MgK6YyGR1b+C0TEm4FE4xRAqupFlt28SWYAKLzU7VAAX2B2u1ikSz54zxd1C6CTUcS1DQ8RjSUsIFuFsgGj6yXK5V065U52it/49fmHXb5u1VU9f+ecZU7XS1wb9TrOUm2fMkskTEj1MZO3jXWhTp3ptm1oDlybz+JXrf+u1Q/f6Qh5qGh5dnb3GAr76h7oxP4AdNf43vcpRm0AAAAASUVORK5CYII=
diseno/bosses/sapo/cuerpo_salto.png iVBORw0KGgoAAAANSUhEUgAAACUAAAATCAYAAAAXvcSzAAADK0lEQVR42rWWQUgbQRSG/7VSRGuzhlAWkyYhIIRiw1JQQmog9NRaqXoRSXPI0VNPWkoLYnOTQg49iaceQkhBMBUP7amLtmFpDi5bLLZCiGGV0IYYsREpqdtD2XEn2aSrbR+EJTNv5n37vzdvh0ELcwVs6vzKNGLxFDwDbuSyeXgG3Pj47B3lN78yjcS6SOZz2TyqgtKw306mxMCEMWaANh+GyfgTJQ8f56R8631e1k4gFwuUXyyeokBbAbabIe+6MgsAqH6Nwcc5IRcLZE7e3mvwIXM6v7FwAAgDPs6JWDwFF6A2g2trphJMWi6bp/4fCDMUTDqZoeblYgFj4QDuL07g+swQXAGbWh+PaZY2AEisi/D19QIASYVcLEDe3oOvrxfpZAZj4QDSyQw8A24kmGVYRoGDV8DroXnE4ilKKW2d/hkJ+klqNdUYI6DEungmhfSHIMEsU0CZwQ1E1HFT+2lgF/4GKDO4gbe9bwAAPXYWANAZ3KGALKPA3c+T6AzuQC4oZL3mr1mPnUX14gk6f9bm2s5aO3ogyyiQYJYRCfrJuNY+ACCijpNUai9bv4+R8m1mAIw20gJG1HGijN5PS6kRUGZwg4DrS4AqdFfApnaFHC2VWptdMKXoqriApf2KYc3pFdYfBj1QLps/LXRXwKbelC41Dfa8nMKqaAw24p/6I2Crw6AHrwoK3TzvFaZIK3hx5xEZLx1v4YF1sinwSHkKpeOthnE/HwIkAUs6IACGp1OvLKWUlsK12YWGILYOb1MoIyC9iZKApf2K4emtT2VVUOg+NRx1qxPR0O83/McmSgI6+r1U0denUutTDR39f4DVAxm1gaqg4PCohrJUOW2emm1Llac/UJmzcICDc0OUBDg497lAtPX1CvXYWQLE8x5wXA+cfhfar3aj+u2gsXlaeVZlh29g8UMOoiSQAOd9dvR7DfsYy14Gz3uQz5fIb1dS4A37Gj/IVp5Vbz++hfdpCXbega2kDD/PYiJqPp31bUCfIs0Oj2rwhn3YlRTYeQf1NITqvmY9XfypjLJUYYaj7pbXmc0v39EVchjeOJtd7Kw8qwKAPh4A/AJoKwaCC/Nq8wAAAABJRU5ErkJggg==
diseno/bosses/sapo/cuerpo_sentado.png iVBORw0KGgoAAAANSUhEUgAAACUAAAATCAYAAAAXvcSzAAADI0lEQVR42rWVT0jbUBzHv9ExRDfbShnBFlsKQhmu5GIpnYWy0/7I1ItI14On4WknHWMDcb3JoIedZKcdSulAsBMP22ULOkugB0OG0E0osWQlbJ3WbXUizuwgyfKStIv787s88t7v/d7nfX+/9wuFFuaLupX55Wmk0jkEBv0oF0UEBv14++gN4Te/PI3MGqetl4siGqxkirddqFGwYZQdoM27CW3+gSQiRPcRvkafZ0fHEOQK4ZdK5wjQVoBn7JB3XZgFADQ+phCi+yDIFW1N2KqafLQ1nd9oIgokgBDdh1Q6Bx+gNINra6YSbFq5KBLfe+wMAZPPFoh1Qa5gNBHFrSfjuDQzBF/UrRjPo5qlDQAyaxxC/b0AoKVCkCsQtqoI9fciny1gNBFFPltAYNCPDLUExwiw9xx4MTSPVDpHKKXu04/JWERLraoaZQWUWeNOpZD+EWSoJQKoEN5AUhmzFU8Fa/8boEJ4A697XwIAXB4nAKAztk0AOUaAG+8m0BnbhlCRtP2qv2oujxONs8fo/HE013ba2tEDOUaADLWEZCyizavtAwCSypiWSvWyxjhWyrfZAbAKpB6YVMY0ZfR+akqtgArhDQ1cXwJEofuibqUr7m2p1Orsgi1FV7gFLO7WLWtOr7D+MeiBykXxV6H7om7lMn+u6WGPd3JY4azBhiNTvwVs9Rj04A1WIpvnzcqU1gqeXrunzdcOSrjTM9EUeHhnCrWDkmk+wsQBnsWiDgiA5evUK0sopaZwdXbBdIi7I9gUygpIbxzPYnG3bvl6jalssBLZp65P+pXxyfjJDf+xcTyLjoEgUfTGVDqd3ShlBXNH/x9gRiCrNsAwAazneXgYL9qNAbb4+sND1OccNOCl/eB4Fl7a/0cg6n6jQi6PUwNimABo2oX1PA8AqL4SzVAA8BmY25NlOOiTb0kWCUA7o7qvYyCIVDpHgOxW6xqMKNZQr++jm+7GV/kLDj99N6evh3EqV+9fIeZEsYbb4YBtlYx9Sp8i1dRUfeAl02gJdf5ijymgfmMpKyDCkP+uzfff0BX3osFK+Lp/hGAiZHmgHfsJ9GL+tkOptxUAAAAASUVORK5CYII=
diseno/bosses/sapo/lengua_punta.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAW0lEQVR42k3IIRJAQBiG4RdtZ9xAcARZ0fcoTiE7grTZAeTdKv1Z0wzjDJ/EeOKDd7UUohSiYtvLu1qZQhTrxiuZkfOTzADI0zR/0TUNAMV5X0NFCcB+HIy28AAcwSMD2wMDkAAAAABJRU5ErkJggg==
diseno/bosses/sapo/lengua_segmento.png iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAI0lEQVR42mP8v+DAfwYGBgaGU7cYmGCMgxcuMDDBGAwMDAwAEf0NEhgWoYkAAAAASUVORK5CYII=
diseno/bosses/kraken/barredor.png iVBORw0KGgoAAAANSUhEUgAAAB4AAAAJCAYAAAAl45yBAAAAqElEQVR42mNkoCHQ4rL6D2PPq1sHF2/qqGBgpJVF6JbdOHGDgYGBgWHVgQUMDAwM5FuMbgm6RQwMDAybFq3AqvfCswv4LcZmOC5L8FmEbikDAwMDI6mGk2IJsmUGUgYoNOOJjhf/aWU4jMYGGE90vPjf1FGBUxOxND7w4NctTIu9BBL+UyNFYzMcBq59O8aINQHB8IMF//+Ty2dgYGB4sOA/iifQ+cgAALOZibZvPcpbAAAAAElFTkSuQmCC
diseno/bosses/kraken/cabeza_enfadado.png iVBORw0KGgoAAAANSUhEUgAAADAAAAAhCAYAAACfiCi5AAAEBUlEQVR42tVYQWgTQRR9m6oHa+heWkJRWBBD6KHMqRYL4qmUCq14WHKyLUIOHgI9BEIORXuQQrDHHnKojSCUgKUK9uDJS4v2NKcQFoSV0lqr1Q1CDvUQD+mMs7sz2WySFh0Iszsz/897///58zcautSGLt+qs+etlW3ffKlQhJmacb2v0YJrTbm2o4XdVzsL0PT9x79A360DAMz9RWCu7JInd27y51xuHtTZDU1G6xboUqGIeDzhtroAfhpRvMYvkGKUE2TzAGCOJzmpMGS0sOBllrasCqhNQQwiJWGOJ4HnQ1LwMs+IHmJkVCS0MFbfWtl2hYcIvhkQBkYGXuYZmX7mES+RSKtWZ+Atq8IVi+CnEQWeD7k2FvtSocjfWbhgrszBi/Niz8LrqbmMWZJyhXAgAQa+VChy8PF4gvcAQAwCa2yDA2Gbi+tkvTmehGVVOPig9QBAbeojobUCvpUmbnSWjZ21NVpAubajad0Af95NJBFpR/i8wfoSgkH4eCSM9ZmQV6lqvFMjNNNLDAKij7TuAabE3F90WaBd8EFy3v1U85Gw4KcRRXz7vmvcqTkwdANOzXHVOzI9bJ2hG4EeFffz6mWkerzhQ/QRHH/66loc02M4dA5xceMnvj+8DmtsA5WDChL9Cdg/bLy1h7D6bA+jN0bx8lURMT0mJRDTYxgeJohGrqByWIGhG7B/2Ej0JzA8THB8/F26n3hPeElqsjPw1FxWpkQzNYNcbh7EIMhsHTUG+zJANQ8AyE8OBHryZXnQN6eSM1MzymxIbSoPIbFK9LZcbh4AGuD7Mo3Bar7x3JdBZutIGkYu8EyOkW8i1wy88gwwkFJy4oGq5tE7sIDegQXugW7LBenzESjXdjTq7Pqqyk7vgW7fH6zAU2YhVqipmEtjtprH582M1O3tygUZo0e24NvvvSf7x0ePJxJ3QW3qyyrs/WrvI/R/uYa3dASfNzOoVsaagmhXTnqPnH4jaEHV6CxJ8dqj24VcWDkv+MCLrFzb0dZowXXzym5R9oGiumVVfatyKvAAcCGIdYMEGvW37c4mjNhZ9LIDK/siC/1NTPQRJYFOm0pfOp0FALx5sY5Nu+QiEaqcZik2nc76ahlmNVXvzUayXtRHnV3+Y+Dpgd9Ikbbz8EGjMOMbtRDHQfGeTmfh1Bwe56KlZeBbOgNKdw8SrvR0ozoA3DNMTD1IcnezNktSuD01AQBYXMrCPrFc+u4ZJhaXsi3t1xUC9IDCPrF4PHJr2ahPIeklhzWK+u2pCQ7e9z+PjfrqwoaShHe/jkPoX2ltEXjzYh3/g1zTdPph6bA+qc/Wxf9oVONnJddRCDU7cOcpp3XiBeNSHGSQ8GxjXIo3zqPskHZZjq37A9kHbmKU/F5aAAAAAElFTkSuQmCC
diseno/bosses/kraken/cabeza_herido.png iVBORw0KGgoAAAANSUhEUgAAADAAAAAhCAYAAACfiCi5AAADj0lEQVR42tVYPWjbQBT+5JQMKSaegvGkSQRPN6WQQugUQganZBCGQu0sHg0ZDMZDBg8hEMiYwUNjBwLBQ0gzZOjUxab1dJMImpQhJmRyKTUlizo4d9XPnX78R/vAPFmn9973vXv37iQFU5Ls0rrNrm9PO77xdqMFvVRw/W/ShusZY9hV4sZVZgGafv3+F+iXSwCA/lAH9gyXPXn3hl/Xavugg15sMsq0QLcbLWjaqjvrDvA7SOIzfoK0kpwgGwcAfTPPScUho8QFL8q0ad6BWhREJUIS+mYeOMsKwYtmxjlDjIyMhBIn67enHVd5OMEHAWFgROBFMyPyz2bESyQRNesMvGneccdO8DtIAmdZV2Cnbjda/D8rF+wZHLxz3KlZeR3qJyiSkquEQwkw8O1Gi4PXtFWuAYCoBObbKw6EBXc+J9L6Zh6mecfBhz0PANSiPhJKFPBRxBlolsLWWpM2YAy7ijIN8PMWJ4nEOMbzButrCCrh9xfiZJ8ZPQ4ekU6l5wZeFC+dSgO/F6LPAHOmP9RBVDI38LJ4bDwR19kOktA6u9BLBX7fq6P6k9nJ4nnLyNeFskvrNkmtSRkTlUDr7IK0kqjV9vnYhZHBh2zf5zyspoPsvPG8Jc38KKI1cKifSFuiXipw8BdGZnRzuQL8OAYAHG+vhIKPY6eXCtJuSC0qJhDUQn0gBHJ/XZFmLK5dWDJeiQZrtX1pGThb2OuVA9/4r6f6VO2kZ6sXfz4CL4clW9fywjJy1nCcoOPaBfmjg568C7GDmoi5r2aXK6FlMK5dWDICz0JFUuLdIGiBVW6fcH9dcZ06g2RcO1frfXlHUMJOo2EkJjnIxbXzgg/dyIxhV2nShmsBijYg9oIi26BkOqqdDLy0C/lJYHT+ttybDSM2Cy1asKI3stjvxCS1JiUwqcj8lctVAMDN+SWurbaLRKzjtDHsKnTQQ7lchZpSXVPNsibT3m4k0k5/dNDjPwae9v1JSozdh/t0RIIFilDHYfVeLlcxGA54nTszLQIfaQ1IpztDuFO2+QHAe1VH7mOeTzeTIilhI7cFAKgfVWE9my5/71Ud9aNqpHhTIUD7FNazyeuRZ8uCnUPeSw5NCnsjt8XB+77zWLA/HVxJSXjjTVxC/4qMReDm/BL/g11gO/129Ghvp4q28xuN7P6s7CYqoaAFN087ZZJZUBc1kAzh3UZd1EbrUbRIp2zHnvsDC9xHt8/lfZIAAAAASUVORK5CYII=
diseno/bosses/kraken/cabeza_reposo.png iVBORw0KGgoAAAANSUhEUgAAADAAAAAhCAYAAACfiCi5AAADpUlEQVR42tVYP0hbQRj/vVgcKqFZKiG08KYgmW6yoCCdRCxEcXgECk1cMnQIOARCBmkziCA4OmSoRhAkg1ihDp26JLRON4XwpifFVCyFSCEUO6RDvOv7c5f3XvIS2oNwybv7vu/3+/7dvSgIaCQeznXZ9/O9mmO9Wq5Ay6Ytvw9o2bKn0akrfu0qowBNP335C/TjMQBAuyoB6w2LPHn+jH8vFjdA2xe+yShBga6WK4jHZ6xeN4FfQRjv8ROkEuYE2ToAaIspTsoPGcUveJGndb0JalAQlQhJaIspYD8hBC+KjDlCjIyMhOLH6+d7NUt6mMH3A8LAiMCLIiPSzyJiJxLy6nUGXtebXLEZ/ArCwH7CYtg8V8sV/pulC9YbHLx53Tyz9NrSdpEhWUsKuxJg4KvlCgcfj8/wGQCISqDPn3AgzLh5n2jWFlPQ9SYH77YfAKhBHSQUL+C9DLOhUQ5Wawe0jEanrihBgB/3MJMIDSI8brCOhqAS/nzCj/eZ0HX7GtFIdGzgRfaikSjwa8J7BJgy7aoEopKxgZfZY+shv8pWEEa8tgYtm+bP7bNXfTI5mT17Gjm6UOLhXJdEZqWMiUoQr62BVMIoFjf42lEjhpeJlkO5W073k7Pbs6c006OIamBL25W2RC2b5uCPGjHH+s7ytCt4P3JaNi3thtSg4hQy3xLtww5+anoTU9ObvcVHeeTPbxzhFoH3KtcPvLQGzOkhamGDjKALn+lzEGh06gptXzhulcOeA0GfH+yCJ+1C7KImYy7M2dsdXJ7mhWEfVM7NGROiDd9/f3179ePmzdLMC1CDig8RAE+mXuPxt6f4QGdxeZrHbXO+L4hB5YQt+P4dQXG7jWZIlre0oC9yfuXs4F0PskanrhzQsuXuITqA2AuK7ICSzV7lZOAB4IEb6x4J9O7fhrWbMGKjmEUFK3oj8/1OTCKzUgJBtEaRvlyuAAA4OzzGqVG1kPB1nWYtNpcrQI2ollAzr8lmezcSzWZ9tH3BPww8bTmdFBq4D7dojwQz5CGP3fI9lyug3WnzPDd7WgTeUw1Iwx0jXOm9oS4ArKoakq9SPNxsZEgWC8klAEBpuwDjTrfoW1U1lLYLnuwFQoC2KIw7necj95aBbhIpOzkcUHQXkkscvON/HgPdd5snUhJ2e0On0L8yBiJwdniM/0Gubzv9vH3dXY5kuub/aGTPRyU3VAr1K7hxyinDREGdjIPECO826mS8V4+iIg1Yju37A9dTNWWD9/DRAAAAAElFTkSuQmCC
diseno/bosses/kraken/punta_apoyada.png iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAjUlEQVR42mNkIBFocVn9Z2BgYAhQCGNgJFXTvLp1DAwMDAxNHRX4NcM0IGvatGgFw4VnFxgYGBgwNWPTANOEDC48u8DAiKwYXUNTRwWDgZQBigYDKQOEzSc6XvxHNh1dAQMDA04+E8yGpo4KhrSyfBSF0ybMx8tn9BJI+P/g1y0GBgYGhmvfjqF4gxAfAKmSUyB42AhcAAAAAElFTkSuQmCC
diseno/bosses/kraken/punta_cortada.png iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAaElEQVR42mNgIANocVn9Z2BgYGAhR2OAQhgDwwOG/4ykao66kvX/g803BgMpAwZGUjXC2B9svjEwMZAJDKQMyNd84dkF0jQv05nGyMDAwJC3pY6BgYGBgZlUG/8uYG1gfPif4cTbQwwAA18b/hbJKzEAAAAASUVORK5CYII=
diseno/bosses/kraken/punta_golpe.png iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAqUlEQVR42pWQIQ7CQBBF3xJUFboKXbW6R0AQFEERjlGFqKpEISFBoRAcgiBXIapWNZwAUbMImM3upgi+mfz35yeTUfypIisdwGK6RKUQ4PG6qaECwGF7AaBuKsYSCLyezmBxYVkyyU1nAFD35ul86av5ehWdGmYi05lPuW4qdK6jQOfazyEOoGaTjT8xDEKlXPzI9i22b6MF8fvdMeKp//ntIiudzJSLfwNNYmEPc6EL8AAAAABJRU5ErkJggg==
diseno/bosses/kraken/punta_reposo.png iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAlUlEQVR42mNkIBFocVn9Z2BgYAhQCGNgJEUDAwMDw7y6dQwMDAwMTR0VDIzIErgATAMDAwPDpkUrGC48u8DAwMDAwHii4wVBzZsWrcAQu/DsAgMLzAkGUgYMF55dwEoja4CJMzAwMDB6CSQQtBlZAzKf6cGvWwwwPG3CfDjbQMqAYdqE+Sga0fmM+EL42rdjKAGKzgcAmxpRYAm4zi0AAAAASUVORK5CYII=
diseno/bosses/kraken/segmento_g.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAAfUlEQVR42n2OIQ6EMBREX5vNCo6AQq1AVXM4NBKFXBIUWUE2HIIgvyKkqqrhBCtqimsQZJ8ZMW+SUQBlVkWA4vnCBQvA9lvUo8yq+K4nAPZ1B8BaAUdUa3PEeRi5Il4wuUFzg8kN4gU9DyPiJS2uqb/uk8yu7VPhgkX9e3sC3Wc5GkMdbO4AAAAASUVORK5CYII=
diseno/bosses/kraken/segmento_m.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAkUlEQVR42jXNoQrCQBjA8f+cGg4E47hkMixdvkfwKXwSWVw0GRWWhkFkj2CQBcNhMGvw+IKmwRAMn8nfC/wAyI3XthRdTJeaG68Aw9x43a4ONFWNsw4iAJq0pWhT1QCEGHDWEWIgjZdXkU0yAKQTpBMA0tHAFJ/+i3TCZr3jeX3Qvk8k/3w2nuOs43jfc+vPyQ+evzcUPFOCBgAAAABJRU5ErkJggg==
diseno/bosses/kraken/segmento_p.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAZElEQVR42mPU4rL6z8DAwBCgEMaw4cEqBgYGBgaGEx0v/p/oePHfSyABTjOe6Hjxv6mjggEZMD8786aBgYGBYdqE+QxPLz1kePH5BQMzKxNXw4e/bxm+Xv3CsOHBKoYPf98yAAAzRCvBOxT26QAAAABJRU5ErkJggg==
diseno/bosses/kraken/tinta.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAICAYAAADA+m62AAAAPElEQVR42mNgIBIwInNEBLT+I/PffLjGCBNjxKYAG2Ai1momYkxjYGBgYHrz4RojIUVvPlxjZKKar2FsANgiEVm4W2fOAAAAAElFTkSuQmCC
diseno/bosses/huesos/bracito.png iVBORw0KGgoAAAANSUhEUgAAAAYAAAAFCAYAAABmWJ3mAAAAM0lEQVR42mNgQANaKhL/V8yq+s+gpSLxX0tF4j+yoJaKxH+GF3cOwDlwQZgqZEkMc9EFARevJAXSSGVGAAAAAElFTkSuQmCC
diseno/bosses/huesos/craneo_apoyado.png iVBORw0KGgoAAAANSUhEUgAAABsAAAALCAYAAACOAvbOAAABfUlEQVR42q2TP0gCYRjGf9efQTCtSZFIQyeJhhpqCBIHcWtvEHE0aJKGhAoHCQNbo+AIacg2h5YbjnNsdMgCFUzCvMHBydGGuPPUO+nfAx/v+x3P9z7f83wc/BDBgHugLSvcXx8PjDztrGAc8h2x59qH3quNMoos6ftQOILL4xuSbV6KN2kyOZFqvSPMakLiVZYlxzyHBwnLmr28g/4baquC3SbwWHoAIJnKc3F+iiJLrK1vorab2BcWUVsVfKt+vB4H1ZfamRAMuAfG206D2ijrvSJLJFN5AMSeQsIZAqDbeUVtNyfOKrLEnNWgUDhiKWqMTuwp7LE1FLR5gaYpf8ZsUDKVH81+DMaLJJwhSjzpzqbx9RiNzlwen2kU49B4wY0o3V5/IiFLZ9oHRZZQ282RvVXVeN1en+JN2lRowtnJUYL/wPg7a2+vyBKZnPjlbHsnTOu9/efq8u+aJqD9Z0Iw4B7E96PEYnEKhdtfV4CVZY/uKpMT9b5a7wgAn7xrB+aXgHZ3AAAAAElFTkSuQmCC
diseno/bosses/huesos/craneo_herido.png iVBORw0KGgoAAAANSUhEUgAAABsAAAALCAYAAACOAvbOAAABUklEQVR42q1TPUvDQBh+Il06dUwJYgN2yujkIBg6lP4DQaSUDA6ZQwcLDhkz5AdYCNLJ/gPJEC5/wK1BaANRJE2GDJkyxkHuTPOhVn3geN/37rn34zkO2BNSv5vT1YSHu5u8yKN3uX0LrdZbFse+C+LYLJYHQ/CC+Hmh3cNyPoNuWPA2EdeiSX5SbLXeAtkL4jAAL4iskKqZ8J4eQRwbF1fX7Dz2XciDIQBAN6ycK3f7FWLfZT5xbKiaWeEk0TPiMKjsE8dGqykR7agORemslDBf6chAuwcgqOUf1CVSNXNX+xKKjSgdma3v+EzG4mS8INZKUQblSScjJGlWUahxMrpBHBtxGOzETZbykjTDcj6rLVSZ7Haq4D9Qfmf69sSxoRvWx2SnZwO8voV/tvzxea0C9J9xUr+bTy5HGI8nWCzuf20B4OhQYFPphsV8bxNxAPAOs4n8fYoZeBcAAAAASUVORK5CYII=
diseno/bosses/huesos/craneo_mordisco.png iVBORw0KGgoAAAANSUhEUgAAABsAAAALCAYAAACOAvbOAAABXElEQVR42q2Tv0sCYRzGPxcuTo4nEink5NhSQ9DhIG6NQYSIQ4OzNCQ03HiDf0DCEU45tsUNx+vY0qYEKljE6Q0OTo7XEO/rrzvJ6oHj+37vnu+P53k52BG5bDKQTxQe72+DZZ6s1XYd1O2PVe4POwjXUbmRL6CnMouCeJp2s45p2fQGEy0mm/xkWLc/hvk7vjdCT2XUoGqtQe/1GeE6XFxdq+/+sIORLwBgWnagrW+7Df6wo87CdajWGgDYM0ElYQAwnbzhe6ONWuE6xKIayY3CsGydPROcc7wYGE8Do1D+Xlijaq2x6v0alhepJAyeeFHKtvGVjcvK9FQm1Ip1SF7uqMh0Nt9wKFKZfCFcB98breRRUfKmszntZj100Iayu5sK/4H1e5Z3L1wH07K/lZ2c5vn49P4c9cOzUAfkf6blssmgfFmkVCrTaj38OgIc7KeUKtOy1bk3mGgAX4ODAypZlNfJAAAAAElFTkSuQmCC
diseno/bosses/huesos/craneo_reposo.png iVBORw0KGgoAAAANSUhEUgAAABsAAAALCAYAAACOAvbOAAABXElEQVR42q2Tv0sCYRzGPxcuTo4nEink5NhSQ9DhIG6NQYSIQ4OzNCQ03HiDf0DCEU45tsUNx+vY0qYEKljE6Q0OTo7XEO/rrzvJ6oHj+37vnu+P53k52BG5bDKQTxQe72+DZZ6s1XYd1O2PVe4POwjXUbmRL6CnMouCeJp2s45p2fQGEy0mm/xkWLc/hvk7vjdCT2XUoGqtQe/1GeE6XFxdq+/+sIORLwBgWnagrW+7Df6wo87CdajWGgDYM0ElYQAwnbzhe6ONWuE6xKIayY3CsGydPROcc7wYGE8Do1D+Xlijaq2x6v0alhepJAyeeFHKtvGVjcvK9FQm1Ip1SF7uqMh0Nt9wKFKZfCFcB98breRRUfKmszntZj100Iayu5sK/4H1e5Z3L1wH07K/lZ2c5vn49P4c9cOzUAfkf6blssmgfFmkVCrTaj38OgIc7KeUKtOy1bk3mGgAX4ODAypZlNfJAAAAAElFTkSuQmCC
diseno/bosses/huesos/cuerpo_herido.png iVBORw0KGgoAAAANSUhEUgAAACgAAAAYCAYAAACIhL/AAAAClUlEQVR42s1Wz2sTQRT+0kaIUBZdKQ1BGoWcchM8CMpWKoj/gCKiGHPQ4FFEYcUYc8hhKR5LiLDkEMKaY8UQJJQ0h1IPQkHcHLKVECRuEQSx9/HSGWY32eysuwcfDMv33vz49s2b9x7wn0vMrchmkiSqzU3LjkVKMJtJkvZWwzHBnoyRTK0GxvZkjHxBDU08zpPTqxW0DCfB1bMpAEC/3w+M9WoFo28WLl1ZZ/u1jAbqzQ4RJT3lQb1aYX/+dfgD796+QFnTQ+Hx98nUwYqiMM8fk55JOO5W5gsqMS07FmUsug+nOr1aYZ7P3bmBW7fvsjChPDw3zWaSxKiphBKVpYQDu+1+2OsMfmjFHBt7XX3uWmQzSWJbPcckWUoQL7sfFhE3YQBYmLegt/3RsXhz44mDJG8XwSJpiR9TMeiWq+vXAQBlTScUb24Aj5++IV52LxxFTvS9Zh7LUoLwmI6w1+yWxXnGZXmplE5JePXyOdrtTgkA0ikJa5cv4PP+ADw+n17B/heLYXMwdMw3B8PSz19Hr0OXulleLD7Lo6zpcFeZeRWHFz7PBb3qRb8Jy/JS6f69mzgtncAZ+RTaH97P/ALA0Z/fM+2KouDRwwe4tnYRu7ufAnkyJhqLNJl6iaIoLOnOs9ebnX+rxSJdCa2h7pI2r2JQoVUiqMSDLqDkZpH38gz/io9rvXDaWQiScnhyZU13XJXfgS2j4RsGoQjy4iYnEiL1ZsfzlYcmSFPN4cFOJAVAr1aEO/cFUQ+UNR0rqXOREMwXVEQag+xvT6YBANsdA3zHIdKhtLcasCfjKX0k9ZiKUVOJbfWIUVMZ9uv3RmaXjMwu2evqrM+jOq2Y8yUplGYOD3ZY60S/fKrxe728BH3FfwF2MQkd6MYWcgAAAABJRU5ErkJggg==
diseno/bosses/huesos/cuerpo_reposo.png iVBORw0KGgoAAAANSUhEUgAAACgAAAAYCAYAAACIhL/AAAACZUlEQVR42s1Wz4vTQBT+ulsPwlK0smwIslXoqTfBg6BkZQXZf0ARUaw9aP8ChYi19tBD/oLQhaGHUmKPuxiClKXbw7LeBDF7aFZKkZpFEMS9j5edIUnzc5ODHwzhzSQzX968974H/OfIeScqZYFmtblp2blMCVbKAtV3eq4X7PkMgrie2LbnM9TqcmrieSc5orYx0NwE16+KAIDxeJzYJmob0+8Wbt3Z5PsNtB66fYPGJb3gQaK2+Z9/m/zEh+03aCkklT37MV84WJIk7vkz0r6E897JWl2mpmXnsoxF7+Fsjqht7vnq4y08fPSEhwnjEbhppSxQrSNTRjStHXSGcyiNKh+HQxL6LSplgdrWyHVgGjsOvIQXrtiL0d6nTO3zlKVQgnc37wMAWgqhae0samKqa2Yj7TV7sRy2uFpcaZbEAt69fQ1dN5oAUBIL2Lh9A+bRxGVfL63hy1crcN08mjR//T59n1rq/LzYeFVDSyHwqkyY4jjhrHNJr3o56oXV4krz2dMHuFy4gCvFS9A/7vo+AeD07x/fdUmS8PLFc9zbuImDg8+JPJmLG4usmAZBkiRedMPWu33jfFocJ/2ZhnolLUwxGJhKJEU+6QeMnB/5IM84s/hM62OXnaUkJcdJrqUQ11VFHTjQepFhkIqgE15ycUKk2zcCszw1QVZqTo73MxEAorZjd+5LcT3QUgjWxGuZEKzVZWQag/xvL5YAAHuGBmfHEadD0Xd6sOezhflM9JhB68jUtkZU68jcjur3puaQTs0hPRwS3uexOaVRjSQZq8ycHO/z1ok9naUmKnudSJrF/wDqfgNT+7G6GwAAAABJRU5ErkJggg==
diseno/bosses/huesos/escudo_cargas_1.png iVBORw0KGgoAAAANSUhEUgAAAD0AAAAtCAYAAAAdtGNyAAABHklEQVR42u1awQ3DIAwElJ3aLdpR6RZ0KveFZCECKAViDvuVEBR83AEGbM1k8xQoLXvbpzVI5ilQBOopUM7491yn9LZjJJORQc7kx3zNyzwMf+f1eQeIVkLKUI2tWL+l3lkbIoC2gO2hnpwSpk9Gsxuf3nY6Kd2ttKGylwJ0mn9SgQ7zVzrDQ/xdjeW//BaxJg5YUmEk3QXH6mBb8DhkwOi4Jgx8FGzoEuD49h3Tuwz0iNPtKG9lWplWppVpLOAakWlEprss3WlBYNrh5OQoVVz53vjyieiWkxfqubdDAq93Wb1+tM2t5dmaB38/XZIQfCZCTVLQOSe1UK+XQ+Kyi2odUFNC7bk17eqKdU+ey4WungLFcv5cAg+XOnm3/QASRxZQkZcyhgAAAABJRU5ErkJggg==
diseno/bosses/huesos/escudo_cargas_2.png iVBORw0KGgoAAAANSUhEUgAAAD0AAAAtCAYAAAAdtGNyAAABOElEQVR42u1a2w3DIAyEqjs1WzSj0i3oVO6XJYvSmKbgGmN/5YGEjzuIo3MMwpEgQ/lsj1sMliJBBgSaIEMt6PvaovSO60gmkUHK5CM8wz3cAr2n4+kCqFZCyRDHFo5vGfdpDhVAW8D2UE9NCeKHkfTk4nOXh9K/lTZU9lqAiuWnFeiwfLUzPCTf2Vj+KW8V38QBn1Qzku6CY3awLXgulgFbxyWw8a1gsy4Bim/dPb3KRkeclxXl7Uw70860M20LuFdkXpH5X9b0EWsrYsVFbPbDLEgBD67SFa3uaUsnOXVGy3gDvcctmjPJOdAU/Mxso+9N/e+vDoJZHY7TeS/nZc3C+ND8lvKnjyRkvhOBk5TpnhOumOmVkLruIm4BOCVw161tV2eie/NcrZpLkAGf0+sj8NarQvF4AY+ZI+shLU9hAAAAAElFTkSuQmCC
diseno/bosses/huesos/escudo_cargas_3.png iVBORw0KGgoAAAANSUhEUgAAAD0AAAAtCAYAAAAdtGNyAAABPUlEQVR42u2aQRLCIAxFoeOd9BZ6VLwFniquMpOhULACTUKyqrUOefxPS028mxwBIqTnXv7hnaYIEAFBA0TIBf0+Nym94zZSSVSQKvl2H/d0d0c/0+vpBLB2QqpQTS28vuW60hgsQFtge7gn54TpN6PZg08fO70pXe20obbnAjotP66gw/LlrvCQfKWp/FfeLJ6JAx6paizdhUM6bAvPphlYO9eEha+FTbsFKN+6a3qVhY6c24r2NqVNaVPalNYFbjsy25HZW5b48KUZ0VBJLPHsCnhYXMMfSITH3JGFFgl3azoHLzWO8t9WXNM7aLRCaglp8TNH+vep1ArH6byXq2WVZpC7wsP2sOrr00cWUt+JULOU6p6T2qtbr4TYdRfVJqDmhNpxa9vVmejePJfbqweIgOfp8RG8utbJq+MLBGMTCx7c2cYAAAAASUVORK5CYII=
diseno/bosses/huesos/escudo_roto.png iVBORw0KGgoAAAANSUhEUgAAAD0AAAAtCAYAAAAdtGNyAAAAiUlEQVR42u3asQ3AIAxEUcT+w2QMtnIGiJI0VoLhXYko/O3zFYjWKF9HjHg6P2LE3Z1yoBkgyzQk2zElp6nrRevgOFYG/K+6YQk4ewyYTBnftNCdx+3zutrS3p2jN4GW3hJckIHmZDLlYsBbvyYCVzdowEt2UcCp41vQaT7e2Hv5cQV5+0lIyToB2XC3feQpdbcAAAAASUVORK5CYII=
diseno/bosses/huesos/mandibula_abierta.png iVBORw0KGgoAAAANSUhEUgAAABcAAAAECAYAAABlaKSVAAAAR0lEQVR42mPUUpH4z0AjwPjg2p7/J47sY7CwcWKgFs3AwMCwasUSiOEMDAwML549YpCQkqMKfejQIQYGBgYGllUrltAqVBgAKIdKMRqPOkYAAAAASUVORK5CYII=
diseno/bosses/huesos/mandibula_cerrada.png iVBORw0KGgoAAAANSUhEUgAAABcAAAAECAYAAABlaKSVAAAAUUlEQVR42mN8cG3P/xNH9jFY2DgxUItmYGBgePHsEQPjg2t7/sM4ElJyVKEZGBgYDh06xMDEwMDAsGrFEgZq0ocOHWJgYGBgYOyqS/jPQCMAALZ/X9c1vYBOAAAAAElFTkSuQmCC
diseno/bosses/huesos/vertebra_g.png iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAATklEQVR42mPQUpH4r6Ui8f/FnQP/YWyG/1CwYlYVnGZiYGBgWDm7mkFBSYWB4ftDBgYGBgZmTenfDQwMDAzu3iEMK5fMYmBgYGBgwGYmACPZLCcqBK8IAAAAAElFTkSuQmCC
diseno/bosses/huesos/vertebra_m.png iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAS0lEQVR42gXBsQ2AMAxFwZ8tXCLkKlMgCoZiFCZghhSR2cMgyjDF407VDYCRQXWjAHz3pehNy7qpjAyiN02z631Sqm6MDM5jp7rxA0PpJZIR9fLVAAAAAElFTkSuQmCC
diseno/bosses/huesos/vertebra_p.png iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAJklEQVR42mPQUpH4v2JW1X8tFYn/jCtmVf1XUFJheHDvDgMDsgwAQxgQx4vRXMgAAAAASUVORK5CYII=
diseno/bosses/nave/canon_disparo.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAAECAYAAACzzX7wAAAAXElEQVR42mNkYGBg+H/h1X8GBgYG9ZgwBhePEAYY2LNjDQPj/wuv/jPoi0JELr5myF6yiuHJk0cMN66cYmBgYGBgYsACblw5xaChY8bAwMDAwIhshX9HD1wnDAAAtwIeuYufxBwAAAAASUVORK5CYII=
diseno/bosses/nave/canon_reposo.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAAECAYAAACzzX7wAAAAVklEQVR42m3NIRJFUACF4c8bQZJkWTCiIAsWYJkWIFiBfINsREnSSPfNC++r/5w5CXTd8MB53fphFC3zJI0RijwDx7Hbwgo+/tjCqqpbkPxeFGXzXUYvddEWMNPUcjsAAAAASUVORK5CYII=
diseno/bosses/nave/cupula_agrietada.png iVBORw0KGgoAAAANSUhEUgAAABQAAAAJCAYAAAAywQxIAAABEElEQVR42o1SPWvDMBQ8gwmlU2eVQmdPmbVEWZWldPSSgCE/IZu7dOuU+QVB/SPc1fJQ06l4yNS9mbu6FF4X2/WHTPpAHE86TveO52GqpOZuG2cpHperPqd48fCvkpqHJciO+uGnAOC7XPFriofvv2uT5FCScH0AovUCJsmB5yeIzQ4ngN1upea4YhYNkm2RmDiggMNjyIIsC6lZ1FO8/TDHFTvc1oShaHgM+XJ20UPR4Ta8RtBvxeoxTZIjylKY5QpRluJm9gFVKewPe9y938Nuv0aRR+sFDIATwL7zsSOq6AplUWIu5yiLEsAtPh0Zj0btZtZDqTmgoD1tLBN8D1Kz2OwmN6hxrCTBFtuzG/cLKxH8reZDM5AAAAAASUVORK5CYII=
diseno/bosses/nave/cupula_brillante.png iVBORw0KGgoAAAANSUhEUgAAABQAAAAJCAYAAAAywQxIAAABBklEQVR42q2PvUrDUBiGnzSC9xDvoC7FRThLMjild9AlQsBRnNzqNRw6dDghQ29AuqRTwXRo0C2D1+DsJEQsn0M4TZM24OALh+/nvLznOQ59UqEcjrK+w7kxbU+xcviTVChdeSY/mruPApydopJtxtuuXmU7SBcbAmW4SCCOfMZuXVPgA+Q07QHVtGqOZ3IxYmRohjJ5n4hn8tb9609dLcygi/z03fSW7OH8npEasbx6JlCGsdt47A+sBnu6bXYUBhBcBuhqBoCuZpRFybXbhogjH+/2EVQoLUIbki42xJFfhyQaneh93+e3clChTF+y1rKrQBnKogTgk3mvL458HAD5Wgr/pF/P+qs9cAxwcwAAAABJRU5ErkJggg==
diseno/bosses/nave/cupula_normal.png iVBORw0KGgoAAAANSUhEUgAAABQAAAAJCAYAAAAywQxIAAABC0lEQVR42o2SMU7DQBBFnx0k7uDcIDQRDdI2Nq1zgzSOZEGJqNIlDRdYpaBYy0UugGhMi11gUbogV6CmdQQaCuM4dhyFL61mZ+dL83Z3LI5J+bKfLl4THq4nbU/+YvEvKV+6ckx6kHebApz1UclbwnLbHMfrDE8ZhhGEgQtUMQY+Qfpp96gWZbMck4oRIyMzkunHVByTturv31WsYewuch/Z/fkdYzXm+fIJTxkmg8aT/FS+WvaOrueaAN6Fhy5XAOhyRZEXXA3aEGHg4szmoHyxj/1L/VY60uhI7/Z9ahP+0Q2jrFWM1xlh4PLFIwBFXgCwudmw3B766tGyUL44s/nJSfKUIc1vT/p+ATuJsiPl9S36AAAAAElFTkSuQmCC
diseno/bosses/nave/emisor_rayo.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAADCAYAAACuyE5IAAAALUlEQVR42mPMKpnynwEH2LNjDQOjmo4DTgUMDAwMjNy8Ev+PfjqBVdKaz4IBAEhWClUvBlQcAAAAAElFTkSuQmCC
diseno/bosses/nave/luz_alerta.png iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAIElEQVR42k3JMQEAIAAEIQarWurLnqusgLbgtOVekX8e9ogMY8m84noAAAAASUVORK5CYII=
diseno/bosses/nave/luz_off.png iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAG0lEQVR42mNgYGBgsLLy+M/AwMDACGPAAUwAAGjdBTOEESoIAAAAAElFTkSuQmCC
diseno/bosses/nave/luz_on.png iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAHklEQVR42mNgYGBg+P9tw38GGOP/////UQQYGBgYAGpsEo3h3N4ZAAAAAElFTkSuQmCC
diseno/bosses/nave/patas_aterrizada.png iVBORw0KGgoAAAANSUhEUgAAACkAAAAICAYAAABkkNZlAAAA7UlEQVR42mNkIBJw80r8j0+vYWBgYGDYs2MNw9OHNxi+fn7BSIp+aXkNBhePEJL1szCQCMhxIAMDA8PXzy8Ynz5k+L9nxxoGmgBuXon/WSVT/qvpOPzn5pX4Tw2z/CLKiDaLidhopmYIPHnyiOHGlVMMzt5xDMQ4lIkUw8mJZmzRvnfrIgYNHTOGG1dOEaUHq4VSCgb/GRgYGD6+fcEgLa8BdyC/sATDswcXGCkNSSkFg/8f375gcPaOY7hx5RTcbAYGBqzms2Az4MrF41gNT0ivZzjDwPCfEoeSYz7W3D1z4RaG48dOM9AKkGo+AIXMfEhFYlVZAAAAAElFTkSuQmCC
diseno/bosses/nave/platillo_fase1.png iVBORw0KGgoAAAANSUhEUgAAACkAAAAJCAYAAACvzAXAAAABFUlEQVR42mNkwAGkFAz+o4tduXicgRogIb2e4cyJXRjizx5cYMSmnhGXw7A56NjpawzUBFamWjgdjuxgRmTHITts5sItDPQGulpKDFamWigOfvbgAiOjlILBf5jjqOGw48dOM1hamVLFwZev3WOY3NfKwJRbVM2QkF6P14HHj52mKY0NXL52j+H4sdMMuUXVDIxSCgb/c4uq4SGAHhL4DMIGblw5xaChY0aSHnT7YO5gYGBgOHNiF2qaNLFwQ9EIUygjI0e0hU+ePCJa/Z4da+AeQrYP5jhYmmRBzklnGBj+YwsZ5BAihiZVvYaOGcPxY6fx525c5eTHty8YGBgYGKTlNWiWo58+vMHAwMDAwC8sgbOcBADr1r1SzTdK4AAAAABJRU5ErkJggg==
diseno/bosses/nave/platillo_fase2.png iVBORw0KGgoAAAANSUhEUgAAACkAAAAJCAYAAACvzAXAAAABjklEQVR42rWUv0sCYRzGn5faG1ri9EyaRAwcNPL+gCBbBCEca2pyaayhMFpbLogkkIbAoKGhIaS1O+luMDzESey8jjIqFNrEa4g7XvVeO7Ce5cu99/B+P+/z/iBgiAtGreEx7VHGX2hjaw9quTQybjYrxM1PWGBuQJJSmxgwf3aJhBDHYngBQjzMBKeBCQ1Hg52e3wAAZEkBACSE+MSAsqRA1TVkM5uu/21wGthsVgjhglHLhrPBaDh7UllSPIF68YnFAhOUBq7WGhCPDjG1kxP3j08u8PrxNWDieR+Mlon06hrEYgFmp41+twee90GWFGYFAKNljvX1uz1c35ec+dzUfvuELClIr2dAuGDUym7vOgkMJ0EnCgCxQGRsAnXtAaHIkqftV3UN+dwBqrXGyE44fculwTMZW15xzLTR7w/8JGToUHUNKSHJbGwYuuP/TXe3V86C6H42nH0mp+mbpAKWWzJ0QikhCcPQnW+3Svu9VllSxt9u1jvZeX8BAPjmQ/gvPT/VAQAzs3PMd/IbBY30O4alA68AAAAASUVORK5CYII=
diseno/bosses/nave/platillo_fase3.png iVBORw0KGgoAAAANSUhEUgAAACkAAAAJCAYAAACvzAXAAAABuklEQVR42rWUsUsbURzHP0fdFCq4SOJpkA4iChmMNLd0kaJ2EeyQUSenLI46VOyfkIJUBFEoKATsoBKCHb0LuRtaPEIm0fMMsRAhlmzqOZR7PPUuBtTf8uPefX/v97nvu99TCIlILO49XLP/GLxEzMx9wSrkH61XTn4rQXolDCwISDdLzwZcXdsmqSUYHuxHSwyGgsvAbTKcDPZ9YxcAQzcBSGqJZwMauonl2CS1BEelY45Kx/d6dHR0MjA0CoAFXr1WpfGvqiiRWNzz4XwwudBybNKpWQzdbAm0FV1ma510avZRHUDZLjI2/hkA13X4tbfJm4XlzNK3lR9cXDbuFalqFPeswvTEJzJb61Tqf7m9ukZVoxi6GZoB3LNKU93t1TU/D/NiP7nfYeoD+7UbDnJZdnfWaO96hxKJxb30/KJw4KETsqMAI71DTV0q20VxZE+F5disLn8Vxy73E5pC/v/g+P/kyPuP4qUPDNDT0yvstxybKW0ytLHrOkL/VBzksuKD5H4+nD9AbfIkWeAFOSM7NKVN4rqOeA7Ksr7VbOhm6HQrze7Jeq0KQLRvgNeK89MyAG+7ukPvyTsqngQUiQv/jQAAAABJRU5ErkJggg==
diseno/bosses/nave/platillo_herido.png iVBORw0KGgoAAAANSUhEUgAAACkAAAAJCAYAAACvzAXAAAABnklEQVR42rWUP0gCURzHv0ftDS3hvyQaRAwcVPLGhqBaAiEcc6lBXBprKIzWlgsiCaQhKGgoaAhp7U68GwwPkQax8zrKqFBoCdGGesfT+4NgfZcf/N733vvwvd97DCzk8Aa7/T35XsBfaHV9G1I+Z+hrtSJj5meswMyAeLE8NGDm+BxRNowZ/xTYsN8SnAZmaDga7OjkGgAg8CIAIMqGhwYUeBGSIiMVT5iuE3AaWKsVGcbhDXYJHAGj4cimAi8OBDqIjzvLWoLSwKVyFdz+HkY209zOweEpXt4/e0xutxNqXUNsYQncWRZas4FOqw232wmBFy0rAKh1zdbXabVxeZfT9zNT4/UDAi8ithIH4/AGu6mNLT2B/iToRAEg5AnYJlCRC0isJfXv7CQpMjLpXZTKVcOf0M/N53pnMjQ7r5tpo8vl+UlIVSApMpbZRaiqgqu56YHnMfnwZejd3lzAF4gYziNwZCZH6ZskAV2zZEj1BSI6YEUuIPkLP4gIENmnvwq8aH+7rd7J5tszAMA56cN/6emxAgAYG5+wfCe/AYXP64p8B7tdAAAAAElFTkSuQmCC
diseno/bosses/comun/aviso_diana.png iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAAAnElEQVR42p1SQQ7EIAgEsg/ws3Kg53rAR88eKgZteymJCcjMwESZHgLuiJxVee//HsG1EvVOVCuBCG9kgjsAAO6AO6yUmcf9K8FKuZ2dKJPZOx2tzfI0m/nR2rXuCIE7qNZlchAyMbzCHbJPmcAhFHWeJgFYmkMo16fZFBJW5bxvBmaPIcSqLHnfm/nscfP97Z0WYiYnkYzjL3/vD6DxrYTRglvVAAAAAElFTkSuQmCC
diseno/bosses/comun/aviso_flecha.png iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAAUUlEQVR42pWPSQ7AMAgDh4ovh0eQR9NDKxQ1a+eEhI0xDAj3YML1RwygnbiUZ4bOKGaSwnCPJW+ytldPUDGTjG+Nte7d+daiuH5LjcoeJc12N9wxSz+CqkGDAAAAAElFTkSuQmCC
diseno/bosses/comun/aviso_linea.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAACCAYAAABllJ3tAAAAGUlEQVR42mP839X1nwEJMJaVMSLzmRgIAADv5gQEb6xrLwAAAABJRU5ErkJggg==
diseno/bosses/comun/aviso_sombra.png iVBORw0KGgoAAAANSUhEUgAAABQAAAAICAYAAAD5nd/tAAAAWElEQVR42q2RQQrAMAgEV+kD8t7e43fdHySXFEIxxNLMzUUHUSBBG2R6ryi8S2nZ3EgJhSvJjnnOSNE/skiup2QPcnJDANDosG+qO6r7VmakyJcvryRz3QHKrCczHB7iUQAAAABJRU5ErkJggg==
diseno/bosses/comun/burbuja.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAALklEQVR42oWOMQoAQAjDEv//59504CCarYWUQiNJenYqAVSLBSfrU6qjdc2yvX2RnBAFThYfDAAAAABJRU5ErkJggg==
diseno/bosses/comun/fragmento_hielo.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAHCAYAAAAxrNxjAAAAlUlEQVR42mNggAI5r4r/cl4V/198//8/a8WN/zA+AzKAKXjx/f///S/+o7BhihnlvCr+n1rbznD9IwMGWH3gJkOogzpDfFIlA5NPXAJORQwMDAzxSZUMj7Z1MDK//MbT8IdflkFbQYRh9YGbcJqBgYFhy6IFDI+2dTAyMDAwMMLc6BOXgGIisiK4QphiZIXIihgYGBgAZfxTB/ltx3IAAAAASUVORK5CYII=
diseno/bosses/comun/fuego_fantasma.png iVBORw0KGgoAAAANSUhEUgAAAAcAAAAJCAYAAAD+WDajAAAAN0lEQVR42mNgIAZs+H/i/4b/J/4jizERpQsGkE3A0OnPYI5dFzKA24+uAMPYjQwnUWisDkPmAwBWu0312r44ZwAAAABJRU5ErkJggg==
diseno/bosses/comun/hueso.png iVBORw0KGgoAAAANSUhEUgAAAAsAAAAFCAYAAACTphZWAAAAXklEQVR42mPQUpH4v2JW1X8tFYn/DFgAsjzLvh0r4BJNXfMwNFy9/Zzh5d2DCJ3/vz34/+LOgf8rZlXhpLVUJP4zrphV9d/ByY3hwL5dDE1d8zCcUVeWxACTZyDFzQDsGktQRCrnmQAAAABJRU5ErkJggg==
diseno/bosses/comun/laser_tramo.png iVBORw0KGgoAAAANSUhEUgAAAAgAAAADCAYAAACuyE5IAAAAHklEQVR42mP8f+HVfwY8gPH///94FbAwXHyNT54BAJpUCXerlLxnAAAAAElFTkSuQmCC
diseno/bosses/comun/mininave.png iVBORw0KGgoAAAANSUhEUgAAAA0AAAAGCAYAAAAYLBS/AAAAsUlEQVR42mNgQAdWXv8ZrLz+1/78/x/GZsALrLz+w4DUrANwGl0jIwMDA4OUgsH/Z1JSDFIJZXCJ3B+vGSZziML5zxZ0MUg9e8bw7MEFRgYpBYP/7z5+/98+afX/dx+/wzE63y+i7H/7pNX/pRQM/jO2T1r9//ix0wwbnVQYtioZM1y+do/h+LHTDJZWpij0xnlWDFuPyTJcvnaPgVFKweB/blE1w/FjpxmIAWdO7GIAALklcZkqrTJUAAAAAElFTkSuQmCC
diseno/bosses/comun/pincho.png iVBORw0KGgoAAAANSUhEUgAAAAkAAAAFCAYAAACXU8ZrAAAALklEQVR42mNgwAE+7Pj//8OO//8ZGBgYWJAFkRXxuzMwfNwJYTMxUAKQrSMKAACpNhRFomX2kwAAAABJRU5ErkJggg==
diseno/bosses/comun/pluma.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAWElEQVR42mNgIBIw4pJ4ceD/fwyF6IIwYBbgyCAjpMZw4dE6BkZ0RTDJJ+9uMbz5coWBgYGB4dufN4yMDAwMDFwsIv8N5IJQJGEKMKzhYhH5z8Ui8h+XmwFehyQOWGscMgAAAABJRU5ErkJggg==
diseno/bosses/comun/rayo_tramo.png iVBORw0KGgoAAAANSUhEUgAAABgAAAAECAYAAACUY/8YAAAAOUlEQVR42mNkgIIL/x/8Z6AiMGBUYGRgYGBgQpfQZ5CnCo0BLvx/8P//////YTQMkMNHDg1GWgcRAMC4WFF96nQ+AAAAAElFTkSuQmCC
diseno/bosses/comun/roca_lava.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAA10lEQVR42o2QsYrCQBRFz2QVLGRBhCCpJEWKhYWYysLC0jKVX7BdGqvU1vb+x3xCCoVUIXWKkMYBs7BIsEgXm51ZZS281Xtw3jtwBb9x3gcdT6KaVgAIDW3Wq39QpWrkIUM1rehpSCYpAOFybuZjbAMB8pB1YvcVdjJJOcY2kRySFyW+5wIwdWxkkuJ7LpbWRHLIPrziey55URq13i3ALPewjj6yKlUb3T08dWz0E4C30/l7u5x9PMA//U9kkjIZj8iLkqq+/NUTLgKjeaiovqCaVohXC78BI3toGyFDPcQAAAAASUVORK5CYII=
diseno/bosses/comun/tinta.png iVBORw0KGgoAAAANSUhEUgAAAAoAAAAICAYAAADA+m62AAAAPElEQVR42mNgIBIwInNEBLT+I/PffLjGCBNjxKYAG2Ai1momYkxjYGBgYHrz4RojIUVvPlxjZKKar2FsANgiEVm4W2fOAAAAAElFTkSuQmCC
diseno/bosses/comun/veneno.png iVBORw0KGgoAAAANSUhEUgAAAAkAAAAGCAYAAAARx7TFAAAAN0lEQVR42mNgIAIwwhh3/s/6D2OrMKYxYqi883/Wf2QA0wCjWbAZr8yQynDnP8N/GE2USUS5CQCk0ztrlLpG/QAAAABJRU5ErkJggg==
```
<!-- PNG-END -->
