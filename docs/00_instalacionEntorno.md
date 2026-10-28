# 0.1. Instalación y preparación del entorno

Esta página es la guía práctica para el día en que abras tu cuenta de pruebas. Se basa en los tutoriales oficiales de SAP, pero **los nombres exactos de los menús pueden variar** según la versión de Eclipse o de BTP. Si algo no coincide con lo que ves en pantalla, copia el texto exacto del error y consúltalo.

> **Antes de empezar.** La cuenta de pruebas de SAP BTP dura **90 días desde el registro** y debes entrar al menos una vez cada 30 días. Lee primero [5.3. El ciclo de 90 días](./5_3_ciclo90dias.md): esta página asume que ya sabes que vas a trabajar con el repositorio como copia de seguridad.

## Qué vas a tener al terminar

1. Una cuenta de pruebas de SAP BTP con una instancia del entorno ABAP.
2. Eclipse con ABAP Development Tools (ADT) conectado a esa instancia.
3. Un paquete de pruebas y una clase «Hola mundo» ejecutada.
4. El paquete enlazado con un repositorio de GitHub mediante abapGit.

## Crear la instancia ABAP (booster)

1. Abre el cockpit de BTP trial y pulsa **Go To Your Trial Account**.
2. La primera vez, elige región y espera a que se creen la cuenta global, la subaccount, la organización y el espacio. Pulsa **Continue**.
3. En la página de la cuenta global, entra en **Boosters** (menú de la izquierda).
4. Busca el tile **Prepare an Account for ABAP Trial** y pulsa **Start**. Espera a que termine con éxito.
5. Pulsa **Go to instance**, haz clic derecho sobre el nombre de la instancia y elige **Copy link**.
6. Guarda ese enlace en un fichero de texto: es la URL que usarás en Eclipse.

Solo puede haber **una instancia a la vez**. Por eso trabajamos con **paquetes**: uno para los ejercicios de clase y otro para el proyecto.

> **Apunta las fechas ahora.** Fecha de registro, fecha de caducidad (registro + 90 días) y fecha del último acceso. Genera los recordatorios con `herramientas/generar_recordatorios.py` (ver [5.3](./5_3_ciclo90dias.md)).

## Instalar Eclipse y ADT en Ubuntu

Eclipse no se instala con `apt`: se descomprime y se ejecuta. Descarga el paquete **Eclipse IDE for Java Developers** para Linux x86_64 (incluye su propio JRE).

```bash
cd ~/Descargas
mkdir -p ~/eclipse
tar -xzf eclipse-java-*-linux-gtk-x86_64.tar.gz -C ~/eclipse --strip-components=1
~/eclipse/eclipse
```

Después instala el plugin:

1. **Help → Install New Software**.
2. En «Work with» escribe `https://tools.hana.ondemand.com/latest` y pulsa Enter. Espera a que cargue la lista.
3. Marca **ABAP Development Tools**, pulsa Next, acepta la licencia y Finish.
4. Si aparece el aviso de confianza, **Select All** y **Trust Selected**. Reinicia Eclipse.
5. Abre la perspectiva ABAP: **Window → Perspective → Open Perspective → Other → ABAP**.
6. Para comprobar que está instalado: **Help → About Eclipse IDE → Installation Details → Installed Software**.

> **Linux.** El tutorial oficial de SAP lista Windows y macOS como sistemas soportados para ADT. En Linux funciona a muchos desarrolladores, pero no tiene soporte oficial. Si algo falla de forma rara, el plan B es instalar Eclipse + ADT en Windows.

## Crear el proyecto ABAP Cloud

1. **File → New → Other → ABAP → ABAP Cloud Project**.
2. Elige la conexión a una instancia de SAP BTP (ABAP Environment) y pega la URL guardada.
3. Eclipse abre el navegador para que inicies sesión con tu cuenta de SAP. Vuelve a Eclipse y termina el asistente.
4. Comprueba que el proyecto aparece en el explorador.

## Primer objeto: paquete y «Hola mundo»

1. Clic derecho en el paquete `ZLOCAL` del proyecto → **New → ABAP Package**. Nombre `ZEJ`, descripción «Pruebas y ejemplos del taller», *Superpackage* `ZLOCAL` y *Software Component* `ZLOCAL`. Antes, comprueba con **Ctrl+Shift+A** que nadie ha usado ya ese nombre: el trial es un sistema compartido (lo verás en [1.1](./1_1_classrun.md)). Este paquete es tu caja de arena: aquí puedes probar los ejemplos del taller; tu ERP irá en `ZGOR`.
2. Clic derecho en el paquete → **New → ABAP Class**. Nombre `ZCL_EJ_HOLA`.
3. Sustituye el contenido por el código de abajo, guarda (**Ctrl+S**) y activa (**Ctrl+F3**).
4. Ejecuta con **F9** (Run as ABAP Application - Console). Debe salir el texto en la pestaña **Console**.

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

Crea primero el repositorio vacío `abap-ejercicios` en GitHub. Después enlaza tu paquete `ZEJ` con él usando **abapGit**. En el entorno ABAP de BTP, la forma habitual es la app Fiori **abapGit Repositories** del propio sistema (y, según la versión de ADT, una vista equivalente dentro de Eclipse). La instalación y el nombre exacto de la app dependen de la versión, así que **consulta la documentación oficial de abapGit para ABAP Environment** y comprueba que:

- puedes hacer **pull** (traer del repositorio al sistema) y **push** (enviar del sistema al repositorio);
- los ficheros que genera abapGit se guardan en la carpeta `src/` del repositorio.

> abapGit crea el fichero `.abapgit.xml` y la carpeta `src/`. **No los escribas a mano**: deja que lo genere el primer push.

## Problemas frecuentes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| No encuentra la instancia o da timeout | Instancia parada o arrancando | Mira su estado en el cockpit y arráncala |
| Error de autenticación al crear el proyecto | Credenciales equivocadas | Inicia sesión con la cuenta con la que creaste el trial |
| «Install New Software» sale vacía | Fallo de red o URL mal copiada | Revisa la URL sin espacios y reintenta |
| No aparece la perspectiva ABAP | El plugin no se instaló del todo | Repite la instalación y revisa Installed Software |
| Error de autorización al crear un objeto | Tu usuario no tiene el rol de desarrollo | Revisa los roles de tu usuario en el cockpit |

## Ejercicios

1. **Entorno completo.** Deja funcionando el «Hola mundo» y haz que escriba tu nombre y la fecha del sistema con `cl_abap_context_info=>get_system_date( )`.
2. **Primer push.** Enlaza `ZEJ` con `abap-ejercicios`, haz el primer push y comprueba en GitHub que aparece la clase en `src/`.
3. **Fechas.** Anota en tu `README.md` la fecha de registro de la cuenta y la de caducidad, y genera el calendario de recordatorios.

---

**Siguiente:** [0.2. Introducción: ABAP Cloud y SAP BTP](./01_introduccion.md)
