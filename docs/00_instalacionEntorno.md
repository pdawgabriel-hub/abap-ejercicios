# 0.1. Preparación del entorno

Esta página explica lo que hay que configurar para trabajar con estos apuntes: la cuenta de pruebas de SAP, **VS Code** con la extensión oficial de SAP para ABAP, la conexión al trial, el paquete de pruebas y, con **Eclipse**, el enlace con GitHub. Se basa en los tutoriales oficiales de SAP, pero **los nombres exactos de los menús pueden variar** según la versión de la extensión o de BTP. Si algo no coincide con lo que ves en pantalla, copia el texto exacto del error y consúltalo.

> **Antes de empezar.** La cuenta de pruebas de SAP BTP dura **90 días desde el registro** y debes entrar al menos una vez cada 30 días. Lee primero [5.3. El ciclo de 90 días](./5_3_ciclo90dias.md): esta página asume que ya sabes que vas a trabajar con el repositorio como copia de seguridad.

## Qué vas a tener al terminar

1. Una cuenta de pruebas de SAP BTP con una instancia del entorno ABAP.
2. VS Code con *ABAP Development Tools for VS Code* conectado a esa instancia, con tu área de trabajo guardada.
3. Un paquete de pruebas y una clase «Hola mundo» ejecutada.
4. Eclipse con ADT conectado a la misma instancia, para abapGit, y el paquete enlazado con un repositorio de GitHub.

## Crear la instancia ABAP (booster)

1. Abre el cockpit de BTP trial y pulsa **Go To Your Trial Account**.
2. La primera vez, elige región y espera a que se creen la cuenta global, la subaccount, la organización y el espacio. Pulsa **Continue**.
3. En la página de la cuenta global, entra en **Boosters** (menú de la izquierda).
4. Busca el tile **Prepare an Account for ABAP Trial** y pulsa **Start**. Espera a que termine con éxito.
5. Pulsa **Go to instance**, haz clic derecho sobre el nombre de la instancia y elige **Copy link**.
6. Guarda ese enlace en un fichero de texto: es la URL que usarás en VS Code y en Eclipse.

Solo puede haber **una instancia a la vez**. Por eso trabajamos con **paquetes**: uno para las pruebas del taller y otro para el proyecto.

> **Apunta las fechas ahora.** Fecha de registro, fecha de caducidad (registro + 90 días) y fecha del último acceso. Genera los recordatorios con `herramientas/generar_recordatorios.py` (ver [5.3](./5_3_ciclo90dias.md)).

## Instalar la extensión de VS Code

SAP publica **ABAP Development Tools for VS Code**, la versión para VS Code de las herramientas con las que se escribe ABAP Cloud. Con un VS Code reciente:

1. Abre las extensiones (**Ctrl+Shift+X**), busca *ABAP Development Tools* e instala la que publica **SAP**.
2. Comprueba que está: **Ctrl+Shift+P** y escribe `ABAP`. Deben salir comandos como `ABAP: New Destination...`.

Mantenla al día: las versiones nuevas añaden funciones de Eclipse que aún faltan.

## Conectar con el trial

1. **Ctrl+Shift+P** → `ABAP: New Destination...` → **HTTP**, y pega la URL guardada.
2. Te pide un **ID** para el destino: es un nombre que eliges tú, no hay que buscarlo. Pon `TRIAL`.
3. **Ctrl+Shift+P** → `ABAP: Log On to Destination` → `TRIAL`. Se abre el navegador para que inicies sesión con tu cuenta de SAP; cuando diga que ya puedes cerrarlo, vuelve a VS Code.
4. Tus paquetes se añaden al área de trabajo con **Ctrl+Shift+P** → `ABAP: Add Package as Folder to Workspace...`: `ZEJ` en cuanto lo crees (abajo) y `ZGOR` en [1.1](./1_1_classrun.md). Es lo que en Eclipse eran los favoritos. **No añadas `ZLOCAL`**: contiene los objetos de todos los usuarios del trial y es muy lento.
5. **Archivo → Guardar área de trabajo como…**, por ejemplo `~/Documentos/erp-gor.code-workspace`. La próxima vez lo abres desde **Archivo → Abrir reciente** y solo tienes que volver a iniciar sesión.

Si un paquete del área de trabajo sale con un triángulo y el aviso «*Disconnected to TRIAL*», es que no hay sesión: clic derecho sobre él → **Logon to Destination**.

## Atajos que se usan en todos los apuntes

| Atajo | Qué hace |
|---|---|
| **Ctrl+S** / **Ctrl+F3** | Guardar / activar |
| **Ctrl+Shift+F3** | Activar todo lo pendiente (varios objetos a la vez) |
| **F5** | Ejecutar una clase de consola |
| **Ctrl+Shift+F10** | Ejecutar los tests de la clase |
| **Ctrl+Shift+A** | Abrir cualquier objeto por su nombre |
| **Ctrl+Shift+Alt+N** | Crear un objeto (clase, tabla, vista…) |
| Pasar el ratón | Firma, tipo o documentación del elemento |
| **F12** | Ir a la definición |
| **Ctrl+.** | Corrección rápida (crear un método que falta, una tabla de borradores…) |

La lista completa, con lo que todavía no está probado y su equivalente en Eclipse, está en la chuleta **[F. VS Code](./F_vscode.md)**. Tenla a mano: las unidades no repiten cómo se crea, activa o ejecuta un objeto.

## Primer objeto: paquete y «Hola mundo»

1. **El paquete.** Comprueba antes con **Ctrl+Shift+A** que nadie ha usado ya el nombre `ZEJ`: el trial es un sistema compartido (lo verás en [1.1](./1_1_classrun.md)). Después, **Ctrl+Shift+Alt+N** → *Package*: nombre `ZEJ`, descripción «Pruebas y ejemplos del taller», *Superpackage* `ZLOCAL` y *Software Component* `ZLOCAL`. Si pregunta por una orden de transporte, continúa sin ninguna. Este paquete es tu caja de arena: aquí puedes probar los ejemplos del taller; tu ERP irá en `ZGOR`.
2. **Añádelo al área de trabajo** (`ABAP: Add Package as Folder to Workspace...` → `ZEJ`) y guarda el área.
3. **La clase.** **Ctrl+Shift+Alt+N** → *Class*, paquete `ZEJ`, nombre `ZCL_EJ_HOLA`.
4. Sustituye el contenido por el código de abajo, guarda (**Ctrl+S**) y activa (**Ctrl+F3**).
5. Ejecuta con **F5** (o clic derecho → *Run ABAP Application (Console)*). El texto sale en el panel inferior.

```abap
CLASS zcl_ej_hola DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ej_hola IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( 'Hola desde ABAP Cloud' ).
  ENDMETHOD.
ENDCLASS.
```

Si esto funciona, la conexión de lectura y escritura está bien.

## Eclipse, para abapGit

La extensión de VS Code todavía no incluye **abapGit**, el enlace entre un paquete y un repositorio de GitHub que es tu copia de seguridad ([5.2](./5_2_abapgit.md)). Para eso se usa **Eclipse con ABAP Development Tools (ADT)**, conectado al mismo trial. Los dos editores trabajan sobre los mismos objetos del sistema: lo que creas en uno aparece en el otro.

1. Comprueba que tienes ADT: **Help → About Eclipse IDE → Installation Details → Installed Software** debe mostrar *ABAP Development Tools*. Si no está, se añade desde **Help → Install New Software** con el sitio `https://tools.hana.ondemand.com/latest`.
2. **File → New → Other → ABAP → ABAP Cloud Project**, elige la conexión a SAP BTP (ABAP Environment) y pega la misma URL. Se abre el navegador para iniciar sesión.
3. En el *Project Explorer*, clic derecho en *Favorite Packages* → *Add Package…* → `ZEJ` (y `ZGOR` en 1.1).

Eclipse también sirve de respaldo para lo que tu versión de VS Code aún no haga (la chuleta lo indica).

## Enlazar con GitHub (abapGit)

Enlaza el paquete `ZEJ` con el repositorio `abap-ejercicios` usando la vista **abapGit Repositories** de Eclipse (*Window → Show View → Other… → abapGit Repositories*). Los pasos detallados están en [5.2](./5_2_abapgit.md); de momento basta con comprobar que:

- puedes hacer **pull** (traer del repositorio al sistema) y **push** (enviar del sistema al repositorio);
- los ficheros que genera abapGit se guardan en la carpeta `src/` del repositorio.

> abapGit crea el fichero `.abapgit.xml` y la carpeta `src/`. **No los escribas a mano**: deja que los genere el primer push.

## Problemas frecuentes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| No encuentra la instancia o da *timeout* | Instancia parada o arrancando | Mira su estado en el cockpit y arráncala |
| Error de autenticación al iniciar sesión | Cuenta equivocada | Inicia sesión con la cuenta con la que creaste el trial |
| El paquete sale con un triángulo y «*Disconnected to TRIAL*» | No has iniciado sesión en esta sesión de VS Code | Clic derecho sobre el paquete → *Logon to Destination* |
| Sigue el aviso después de iniciar sesión | La carpeta se añadió sin conexión | Botón de refrescar del explorador o `Developer: Reload Window` |
| No salen los comandos `ABAP:` o la extensión no hace nada | Extensión sin instalar o VS Code en modo restringido | Revisa la extensión; si arriba pone *Restricted Mode*, pulsa y elige confiar en el área de trabajo |
| En Eclipse, la ventana de inicio de sesión sale en blanco | El navegador integrado no funciona en tu equipo | *Window → Preferences → General → Web Browser*: elige un navegador externo |
| Error de autorización al crear un objeto | Tu usuario no tiene el rol de desarrollo | Revisa los roles de tu usuario en el cockpit |

## Ejercicios

1. **Entorno completo.** Deja funcionando el «Hola mundo» y haz que escriba también la fecha del sistema con `cl_abap_context_info=>get_system_date( )`.
2. **Tu área de trabajo.** Cierra VS Code, vuelve a abrirlo desde **Archivo → Abrir reciente**, inicia sesión y ejecuta otra vez `ZCL_EJ_HOLA` sin buscarla: debe estar en `ZEJ`, en el explorador.
3. **Formato.** Escribe la clase del «Hola mundo» todo en minúsculas y desordenado, y formatéala (clic derecho → *Format Document*). Anota en la chuleta ([F](./F_vscode.md)) el atajo que tiene en tu versión.
4. **Primer push.** Enlaza `ZEJ` con `abap-ejercicios`, haz el primer push y comprueba en GitHub que aparece la clase en `src/`.
5. **Fechas.** Anota la fecha de registro de la cuenta y la de caducidad, y genera el calendario de recordatorios.

---

**Siguiente:** [0.2. Introducción: ABAP Cloud y SAP BTP](./01_introduccion.md)
