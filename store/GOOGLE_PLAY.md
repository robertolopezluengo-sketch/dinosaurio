# Dino Runner en Google Play

Todo lo necesario para publicar el juego en Google Play como app de Android (TWA: la web de GitHub Pages empaquetada como app).

- Juego: https://robertolopezluengo-sketch.github.io/dinosaurio/
- Política de privacidad: https://robertolopezluengo-sketch.github.io/dinosaurio/privacy.html

## Material de la ficha (carpeta `store/`)

| Elemento | Archivo | Requisito de Play |
|---|---|---|
| Icono | `icon-512.png` (raíz) | 512 × 512 PNG |
| Gráfico destacado | `store/feature-graphic.png` | 1024 × 500 |
| Capturas de teléfono | `store/screenshots/*.png` (8) | 2 a 8, 16:9 |

## Textos

**Nombre de la app** (máx. 30): `Dino Runner: Raptor Rush`

> Conviene un nombre que no sea solo "Dino Runner" (hay muchas apps parecidas y recuerda al dinosaurio de Chrome). Si cambias el nombre, dímelo y lo cambio también en el juego y en el manifiesto.

**Descripción breve** (máx. 80):

```
Corre, salta y ruge con tu raptor por 10 biomas llenos de jefes y secretos.
```

**Descripción completa** (máx. 4000):

```
¡Corre, salta y ruge! Guía a tu velociraptor por un mundo pixel art lleno de obstáculos, jefes enormes y secretos.

🦖 10 BIOMAS
Desierto, selva, volcán, glaciar, noche, playa, bosque de setas, océano, cementerio y luna, cada uno con sus obstáculos, su música y su paisaje.

👹 JEFES CON MECÁNICAS ÚNICAS
Escorpión gigante, mamut de hielo, golem de lava, sapo gigante… Cada jefe se vence de una forma distinta. ¿Encontrarás el portal dorado al nivel secreto?

📢 RUGIDO Y FURIA
Ruge para romper rocas y pájaros. Esquiva por los pelos para llenar la furia y lanza el súper rugido que lo arrasa todo.

🐢 MONTURAS
Tabla de arena, tronco por el río, trineo, delfín, cohete… Cada bioma tiene su montura con controles propios.

🃏 MEJORAS ROGUELIKE
Tras cada jefe eliges una mejora. Combínalas para activar sinergias o arriésgate con los pactos del altar de ámbar. Cada partida es diferente.

📅 CARRERA DIARIA
Un recorrido nuevo cada día, el mismo para todos. Mantén la racha para ganar más premios.

🎟️ PASE DE TEMPORADA GRATIS
30 niveles de recompensas y skins exclusivas, como la legendaria Prisma Celestial.

🛒 Y MUCHO MÁS
Decenas de skins, editor de raptores, huevos sorpresa, ruleta, logros, árbol de mejoras permanentes, estadísticas, modos Fácil, Difícil y Aleatorio, y multijugador local en el mismo dispositivo.

🌍 RANKING MUNDIAL
Compite en la carrera diaria y en cada modo con jugadores de todo el mundo, y pasa tu progreso a otro móvil con la nube.

✅ Sin anuncios. Sin compras. Funciona sin conexión.
Todo se consigue jugando.
```

**Categoría:** Juegos → Arcade · **Etiquetas:** correr, pixel art, dinosaurios, sin conexión

## Respuestas para Play Console

- **Anuncios:** No contiene anuncios.
- **Compras en la aplicación:** No.
- **Seguridad de los datos** (desde la v21, por el ranking y la nube, que son opcionales):
  - Se recogen: **Identificadores de dispositivo u otros** (identificador anónimo de Supabase), **Actividad en la app → Otro contenido generado por el usuario** (apodo) y **Actividad en la app → Otras acciones** (puntuaciones y copia del progreso).
  - Finalidad: **Funcionalidad de la app**. No se comparten con terceros, no se usan para publicidad, se cifran en tránsito (HTTPS) y la recogida es **opcional**.
  - Se puede pedir el borrado (ver la política de privacidad).
- **Clasificación de contenido (cuestionario IARC):** violencia de dibujos animados leve (el raptor ruge a obstáculos y jefes fantásticos; no hay sangre). Debería salir PEGI 3 / Para todos.
- **Público objetivo:** 13 años o más (evita las normas extra de la política de Familias). Marca que la app *no* está dirigida a niños, aunque es apta para todos.
- **Acceso a la app:** Todas las funciones están disponibles sin restricciones (no hay inicio de sesión).
- **Política de privacidad:** la URL de arriba.

## Pasos

1. **Cuenta de desarrollador:** https://play.google.com/console → crear cuenta personal (pago único de 25 $ y verificación de identidad).
2. **Generar el paquete Android:**
   1. Entra en https://www.pwabuilder.com y pega la URL del juego.
   2. Pulsa *Package for stores* → **Android** → *Generate Package*.
   3. Opciones recomendadas: Package ID `io.github.robertolopezluengo_sketch.dinorunner`, nombre de la app, versión `1.0.0` (código 1), *Display mode*: Fullscreen, *Orientation*: Landscape, *Signing key*: **New** (PWABuilder la crea).
   4. Descarga el ZIP. Dentro hay el `.aab` (lo que se sube a Play), el `.apk` (para probar en tu móvil) y la **clave de firma** (`signing.keystore` + `signing-key-info.txt`). **Guarda la clave en un sitio seguro**: sin ella no podrás publicar actualizaciones de la app.
3. **Verificar el dominio (quita la barra del navegador):** el ZIP trae `assetlinks.json`. Pásamelo (o copia aquí su contenido) y lo subo al repositorio en `.well-known/assetlinks.json`. Si Play Console activa la "firma de apps de Google Play", añade también la huella SHA-256 que aparece en *Configuración → Integridad de la app* (te lo preparo igual).
4. **Crear la app en Play Console:** *Crear aplicación* → nombre, idioma español, Juego, Gratis. Rellena la ficha con los textos e imágenes de arriba y completa las secciones de *Contenido de la aplicación*.
5. **Prueba cerrada (obligatoria en cuentas personales nuevas):** sube el `.aab` a *Pruebas → Prueba cerrada*, añade al menos 12 testers (correos de Gmail de amigos y familia) y que la tengan instalada durante 14 días seguidos.
6. **Producción:** pasados los 14 días, solicita el acceso a producción, sube el mismo `.aab` y envíalo a revisión (suele tardar de unas horas a unos días).

## Actualizaciones

El juego se carga desde GitHub Pages, así que **cada cambio que se sube a la rama llega solo a la app**, sin publicar una versión nueva en Play. Solo hay que subir un `.aab` nuevo (con el código de versión +1 y la misma clave) si cambian el nombre, el icono o la configuración de la app.
