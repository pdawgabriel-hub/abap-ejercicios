# 5.2. abapGit: tu código en GitHub

El código ABAP vive **en el sistema**, no en ficheros de tu disco. **abapGit** lo convierte en ficheros (lo *serializa*) y lo sincroniza con un repositorio Git. Es la forma de tener tu proyecto en GitHub como portfolio y, sobre todo, de **restaurarlo** cuando caduque el trial ([5.3](./5_3_ciclo90dias.md)).

## Dos repositorios, dos paquetes

| Repositorio | Paquete | Contiene |
|---|---|---|
| `abap-ejercicios` | `ZEJ` | Estos apuntes (`docs/`) y tus pruebas del taller |
| `erp-obras-reformas-sap` | `ZGOR` | Tu ERP: el código en `src/`, el diseño en `docs/`, el README |

Un paquete se enlaza con **un** repositorio. Los subpaquetes (`ZGOR_DDIC`, `ZGOR_CDS`…) van con su paquete padre, cada uno en su carpeta de `src/`.

## Preparación

1. El repositorio en GitHub ya existe desde 1.9 (con `docs/diseno.md`). Si no, créalo vacío y **público** (para enlazarlo en el CV).
2. Crea un **Personal Access Token** con permiso de escritura sobre ese repositorio (*Settings → Developer settings → Personal access tokens*; los *fine-grained* permiten limitarlo a un solo repositorio). Guárdalo en un gestor de contraseñas. **Nunca lo subas a ningún repositorio.**

## Enlazar y subir

1. En Eclipse, abre la vista **abapGit Repositories** (*Window → Show View → Other… → abapGit Repositories*).
2. Pulsa **+** (*Link New abapGit Repository*), pega la URL del repositorio y elige el paquete (`ZGOR`). Si te pregunta por la *folder logic*, elige **Prefix** (las carpetas siguen los nombres de los subpaquetes).
3. Clic derecho en el repositorio enlazado → **Stage and Push**. Introduce tu usuario de GitHub y el token como contraseña.
4. En la ventana de *staging*, pasa los objetos a *Staged*, escribe el mensaje del commit y pulsa **Commit and Push**.

abapGit genera él mismo `src/` y `.abapgit.xml`. **No los escribas ni los edites a mano.** Tu `docs/diseno.md` y el README conviven con ellos sin problema: abapGit solo toca lo que hay bajo `src/` y su fichero de configuración.

> Si el repositorio ya tiene ficheros (como tu `docs/diseno.md`), el primer *push* los respeta. Si abapGit dice que el repositorio «no está vacío» y no deja enlazar, mira en su documentación la opción para repositorios con contenido previo.

## La rutina de commit

1. Activa todos los objetos (clic derecho en `ZGOR` → *Activate*, o **Ctrl+Shift+F3**).
2. Ejecuta los tests de `ZGOR`: todos en verde.
3. Pasa el ATC ([5.1](./5_1_atc.md)).
4. *Stage and Push*, con un mensaje que diga **qué** has hecho: «Validations de los partes externos», no «cambios».
5. Comprueba en GitHub que el commit está.

Hazlo al terminar **cada sesión de trabajo**, aunque no hayas acabado la unidad. Si el trial se pierde a mitad de semana, solo perderás lo que no hayas subido.

## Del sistema a GitHub y al revés

- **Push**: del sistema al repositorio.
- **Pull**: del repositorio al sistema. Crea o sobrescribe los objetos del paquete con lo que hay en GitHub. Es lo que harás al restaurar.

Si cambias un objeto en el sistema **y** su fichero en GitHub, abapGit mostrará el conflicto al hacer *pull*. En ABAP Cloud lo normal es no editar nunca el código en GitHub: el sistema es la única fuente de los cambios, y GitHub, la copia.

## Ejercicios

1. **Primer push del ERP.** Enlaza `ZGOR` con `erp-obras-reformas-sap` y sube todo. En GitHub, comprueba que en `src/` hay una carpeta por subpaquete y que tus tablas, vistas, BDEF y clases están.
2. **Los ejercicios del taller.** Enlaza `ZEJ` con `abap-ejercicios` y sube lo que hayas probado del taller.
3. **Lee lo que se ha subido.** Abre en GitHub el fichero de una BDEF y el de una tabla. ¿En qué formato están? ¿Qué fichero acompaña a cada clase?
4. **Un pull de prueba.** Cambia en el sistema el texto de un mensaje de una validation **sin** hacer *push*. Haz *Pull*: ¿qué te propone abapGit? Cancela, deshaz el cambio y haz *push* de lo que tengas.
5. **Investiga.** ¿Qué es el fichero `.abapgit.xml`? Ábrelo en GitHub y anota qué guarda.

---

**Siguiente:** [5.3. El ciclo de 90 días](./5_3_ciclo90dias.md)
