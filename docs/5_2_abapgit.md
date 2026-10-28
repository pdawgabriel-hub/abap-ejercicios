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

## En una empresa: órdenes de transporte

En el trial, todo lo creas en `ZLOCAL`, un componente **local**: los objetos viven solo en ese sistema y abapGit es tu único medio de llevarlos a otro sitio. En una empresa no se trabaja así. Hay al menos **tres sistemas**:

| Sistema | Para qué |
|---|---|
| Desarrollo (DEV) | Donde se programa |
| Calidad o pruebas (QAS) | Donde los usuarios prueban con datos parecidos a los reales |
| Producción (PRD) | Donde trabaja la empresa. Nadie programa aquí |

Los cambios viajan de uno a otro en **órdenes de transporte**: al crear o modificar un objeto en desarrollo, Eclipse te pide una orden (o te propone la que tienes abierta), y el objeto queda **bloqueado** en ella hasta que se libera. Al **liberar** la orden, su contenido queda listo para importarse en calidad y, cuando se aprueba, en producción. En Eclipse las ves en la vista **Transport Organizer**.

En SAP BTP ABAP Environment y en S/4HANA Cloud, el código además se agrupa en **componentes de software** (*software components*), que se mueven entre sistemas con Git por debajo (gCTS) y se gestionan con la app *Manage Software Components*. Es la misma idea que tu `ZLOCAL`, pero con un componente propio del proyecto en lugar del local.

Lo que esto significa en el día a día:

- **No se toca producción.** Un error se corrige en desarrollo y se transporta.
- **Una orden por tarea**, con una descripción que diga qué cambia. Es el equivalente de un commit.
- **Antes de liberar**: activar todo, tests y ATC. Es la rutina de commit de esta unidad, con otro nombre.

En el trial no podrás practicarlo, pero si en la 0.1 Eclipse te pidió una orden al crear el paquete, ya has visto la primera.

## Ejercicios

1. **Primer push del ERP.**
    - **Dónde:** en GitHub, crea el repositorio público `erp-obras-reformas-sap` (vacío, con un README). En Eclipse, la vista **abapGit Repositories**.
    - **Qué haces:** los cuatro pasos de «Enlazar un paquete con un repositorio»: enlaza `ZGOR` (*folder logic* **Prefix**) y haz *Stage and Push* de todo con el mensaje «Bloques 1 a 4».
    - **Comprueba:** en GitHub, `src/` tiene una carpeta por subpaquete (`zgor_ddic`, `zgor_cds`…) y dentro están tus tablas, vistas, BDEF y clases.
2. **Los ejercicios del taller.** Enlaza `ZEJ` con `abap-ejercicios` y sube lo que hayas probado del taller.
3. **Lee lo que se ha subido.** Abre en GitHub el fichero de una BDEF y el de una tabla. ¿En qué formato están? ¿Qué fichero acompaña a cada clase?
4. **Un pull de prueba.** Cambia en el sistema el texto de un mensaje de una validation **sin** hacer *push*. Haz *Pull*: ¿qué te propone abapGit? Cancela, deshaz el cambio y haz *push* de lo que tengas.
5. **Investiga.** ¿Qué es el fichero `.abapgit.xml`? Ábrelo en GitHub y anota qué guarda.
6. **Investiga.** Abre la vista *Transport Organizer* en Eclipse. ¿Hay alguna orden a tu nombre? Si la hay, mira qué objetos contiene. Anota en `diseno.md` en qué se parecen y en qué se diferencian una orden de transporte y un commit de Git.

---

**Siguiente:** [5.3. El ciclo de 90 días](./5_3_ciclo90dias.md)
