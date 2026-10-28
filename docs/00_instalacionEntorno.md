# 0.1. Preparación del entorno

Esta página parte de un Eclipse ya instalado y explica lo que hay que configurar para trabajar con estos apuntes: la cuenta de pruebas de SAP, la conexión desde Eclipse, unas cuantas preferencias que ahorran tiempo y el paquete de pruebas enlazado con GitHub. Se basa en los tutoriales oficiales de SAP, pero **los nombres exactos de los menús pueden variar** según la versión de Eclipse o de BTP. Si algo no coincide con lo que ves en pantalla, copia el texto exacto del error y consúltalo.

> **Antes de empezar.** La cuenta de pruebas de SAP BTP dura **90 días desde el registro** y debes entrar al menos una vez cada 30 días. Lee primero [5.3. El ciclo de 90 días](./5_3_ciclo90dias.md): esta página asume que ya sabes que vas a trabajar con el repositorio como copia de seguridad.

## Qué vas a tener al terminar

1. Una cuenta de pruebas de SAP BTP con una instancia del entorno ABAP.
2. Eclipse con ABAP Development Tools (ADT) conectado a esa instancia y configurado.
3. Un paquete de pruebas y una clase «Hola mundo» ejecutada.
4. El paquete enlazado con un repositorio de GitHub mediante abapGit.

## Crear la instancia ABAP (booster)

1. Abre el cockpit de BTP trial y pulsa **Go To Your Trial Account**.
2. La primera vez, elige región y espera a que se creen la cuenta global, la subaccount, la organización y el espacio. Pulsa **Continue**.
3. En la página de la cuenta global, entra en **Boosters** (menú de la izquierda).
4. Busca el tile **Prepare an Account for ABAP Trial** y pulsa **Start**. Espera a que termine con éxito.
5. Pulsa **Go to instance**, haz clic derecho sobre el nombre de la instancia y elige **Copy link**.
6. Guarda ese enlace en un fichero de texto: es la URL que usarás en Eclipse.

Solo puede haber **una instancia a la vez**. Por eso trabajamos con **paquetes**: uno para las pruebas del taller y otro para el proyecto.

> **Apunta las fechas ahora.** Fecha de registro, fecha de caducidad (registro + 90 días) y fecha del último acceso. Genera los recordatorios con `herramientas/generar_recordatorios.py` (ver [5.3](./5_3_ciclo90dias.md)).

## Comprobar ADT

ABAP Development Tools es el plugin de Eclipse para ABAP. Comprueba que lo tienes:

- **Help → About Eclipse IDE → Installation Details → Installed Software**: debe aparecer *ABAP Development Tools*.
- **Window → Perspective → Open Perspective → Other → ABAP**: la perspectiva ABAP debe abrirse.

Si no está, se añade desde **Help → Install New Software** con el sitio `https://tools.hana.ondemand.com/latest`. Mantenlo al día con **Help → Check for Updates**: las versiones nuevas de ADT traen correcciones para los entornos cloud.

## Configurar Eclipse

Nada de esto es obligatorio, pero evita sorpresas y ahorra tiempo en todas las unidades.

**Vistas que conviene tener abiertas** (*Window → Show View → Other…*):

| Vista | Para qué | Unidad |
|---|---|---|
| *Project Explorer* | Navegar por los paquetes y objetos | Todas |
| *Problems* | Errores y avisos al activar | Todas |
| *Console* | Lo que escriben las clases ejecutables | 1.1 |
| *Outline* | Métodos de la clase abierta | 1.6 |
| *ABAP Unit* | Resultado de los tests | 1.8 |
| *ATC Problems* | Hallazgos del control de calidad | 5.1 |
| *abapGit Repositories* | Enlazar paquetes con GitHub | 5.2 |
| *Feed Reader* | Errores en tiempo de ejecución (*dumps*) | 4.4 |

Colócalas una vez y guarda la disposición con **Window → Perspective → Save Perspective As…**.

**Preferencias** (*Window → Preferences*):

- **Formato del código** (*ABAP Development → Editors → Source Code Editors → Formatter*): elige las palabras clave en mayúsculas y la sangría automática, como en los ejemplos de los apuntes. Después, **Shift+F1** formatea el fichero abierto. En algunas versiones el formato se ajusta por proyecto: clic derecho en el proyecto → *Properties → ABAP Formatter*.
- **Números de línea** (*General → Editors → Text Editors → Show line numbers*): los mensajes de error citan líneas.
- **Activación al guardar**: no la actives. En RAP muchos objetos se activan juntos, y conviene decidir cuándo.

**Atajos que se usan en todos los apuntes:**

| Atajo | Qué hace |
|---|---|
| **Ctrl+S** / **Ctrl+F3** | Guardar / activar |
| **Ctrl+Shift+F3** | Activar varios objetos a la vez |
| **F9** | Ejecutar una clase de consola |
| **Ctrl+Shift+F10** | Ejecutar los tests de la clase |
| **Ctrl+Shift+A** | Abrir cualquier objeto por su nombre |
| **Ctrl+1** | Corrección rápida (crear un método que falta, una tabla de borradores…) |
| **F2** / **F3** | Información del elemento / ir a su definición |
| **F8** | *Data Preview* de una tabla o vista |
| **Shift+F1** | Formatear |

## Crear el proyecto ABAP Cloud

1. **File → New → Other → ABAP → ABAP Cloud Project**.
2. Elige la conexión a una instancia de SAP BTP (ABAP Environment) y pega la URL guardada.
3. Eclipse abre el navegador para que inicies sesión con tu cuenta de SAP. Vuelve a Eclipse y termina el asistente.
4. Comprueba que el proyecto aparece en el *Project Explorer*.

Para no tener que abrir el paquete cada vez, añádelo a **Favorite Packages**: clic derecho en *Favorite Packages* dentro del proyecto → *Add Package…*. Hazlo con `ZEJ` y, en 1.1, con `ZGOR`.

## Primer objeto: paquete y «Hola mundo»

1. Clic derecho en el paquete `ZLOCAL` del proyecto → **New → ABAP Package**. Nombre `ZEJ`, descripción «Pruebas y ejemplos del taller», *Superpackage* `ZLOCAL` y *Software Component* `ZLOCAL`. Antes, comprueba con **Ctrl+Shift+A** que nadie ha usado ya ese nombre: el trial es un sistema compartido (lo verás en [1.1](./1_1_classrun.md)). Este paquete es tu caja de arena: aquí puedes probar los ejemplos del taller; tu ERP irá en `ZGOR`.
2. Clic derecho en el paquete → **New → ABAP Class**. Nombre `ZCL_EJ_HOLA`.
3. Sustituye el contenido por el código de abajo, guarda (**Ctrl+S**) y activa (**Ctrl+F3**).
4. Ejecuta con **F9** (*Run As → ABAP Application (Console)*). Debe salir el texto en la pestaña **Console**.

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

## Enlazar con GitHub (abapGit)

Enlaza el paquete `ZEJ` con el repositorio `abap-ejercicios` usando la vista **abapGit Repositories** de Eclipse. Los pasos detallados están en [5.2](./5_2_abapgit.md); de momento basta con comprobar que:

- puedes hacer **pull** (traer del repositorio al sistema) y **push** (enviar del sistema al repositorio);
- los ficheros que genera abapGit se guardan en la carpeta `src/` del repositorio.

> abapGit crea el fichero `.abapgit.xml` y la carpeta `src/`. **No los escribas a mano**: deja que los genere el primer push.

## Problemas frecuentes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| No encuentra la instancia o da *timeout* | Instancia parada o arrancando | Mira su estado en el cockpit y arráncala |
| Error de autenticación al crear el proyecto | Credenciales equivocadas | Inicia sesión con la cuenta con la que creaste el trial |
| La ventana de inicio de sesión sale en blanco | El navegador integrado de Eclipse no funciona en tu equipo | En *Window → Preferences → General → Web Browser*, elige un navegador externo |
| No aparece la perspectiva ABAP o falta una opción del menú | ADT incompleto o antiguo | Revisa *Installed Software* y actualiza con *Check for Updates* |
| Error de autorización al crear un objeto | Tu usuario no tiene el rol de desarrollo | Revisa los roles de tu usuario en el cockpit |

## Ejercicios

1. **Entorno completo.** Deja funcionando el «Hola mundo» y haz que escriba también la fecha del sistema con `cl_abap_context_info=>get_system_date( )`.
2. **Tu disposición.** Abre las vistas de la tabla, colócalas a tu gusto y guarda la perspectiva.
3. **Formato.** Escribe la clase del «Hola mundo» todo en minúsculas y desordenado, y pulsa **Shift+F1**. Ajusta el formateador hasta que quede como los ejemplos.
4. **Primer push.** Enlaza `ZEJ` con `abap-ejercicios`, haz el primer push y comprueba en GitHub que aparece la clase en `src/`.
5. **Fechas.** Anota la fecha de registro de la cuenta y la de caducidad, y genera el calendario de recordatorios.

---

**Siguiente:** [0.2. Introducción: ABAP Cloud y SAP BTP](./01_introduccion.md)
