# F. Chuleta de VS Code

Los apuntes se trabajan con **VS Code** y la extensión oficial de SAP **ABAP Development Tools for VS Code**. Esta página reúne todo lo que se hace con el editor: conectarse, abrir los paquetes, crear objetos, activarlos, ejecutarlos, probarlos y depurarlos. Las unidades no repiten estos pasos: cuando un ejercicio dice «crea una clase en `ZGOR_TEST`» o «ejecuta», es como se explica aquí.

> **Estado.** La conexión al trial, el área de trabajo y la ejecución de clases están probadas. Lo marcado como **(por comprobar)** sale de la documentación de SAP y no se ha probado todavía: si en tu versión se llama distinto, anótalo en la tabla del final. Lo que la extensión aún no hace se sigue haciendo en **Eclipse con ADT**, que conviene mantener instalado ([último apartado](#lo-que-sigue-en-eclipse)).

## Conectarse al trial

Se hace una vez (los detalles, en [0.1](./00_instalacionEntorno.md)):

1. **Ctrl+Shift+P** → `ABAP: New Destination...` → **HTTP** → pega la URL de la instancia (`https://<id>.abap.<region>.hana.ondemand.com`).
2. Como *ID* del destino, un nombre corto que eliges tú, por ejemplo `TRIAL`.
3. **Ctrl+Shift+P** → `ABAP: Add Package as Folder to Workspace...` → `ZGOR` (y `ZEJ` si lo usas). **No añadas `ZLOCAL`**: tiene los objetos de todos los usuarios del trial y es muy lento.
4. **Archivo → Guardar área de trabajo como…**, por ejemplo `~/Documentos/erp-gor.code-workspace`.

## Cada vez que abres VS Code

1. **Archivo → Abrir área de trabajo desde archivo…** → `erp-gor.code-workspace` (o **Archivo → Abrir reciente**).
2. Si el paquete sale con un triángulo y el aviso «**Disconnected to TRIAL**», no hay sesión: clic derecho en `ZGOR [TRIAL]` → **Logon to Destination**, o **Ctrl+Shift+P** → `ABAP: Log On to Destination`. Se abre el navegador; inicia sesión y vuelve.
3. Despliega `ZGOR`. Si el aviso sigue, pulsa refrescar en el explorador o **Ctrl+Shift+P** → `Developer: Reload Window`.

Tus objetos están **en el sistema SAP**, no en tu ordenador: cerrar VS Code, cambiar de editor o borrar el área de trabajo no borra nada.

## Abrir un objeto

| Para | Cómo |
|---|---|
| Abrir un objeto por su nombre | **Ctrl+Shift+A** y escribe el nombre (también sirve para comprobar si un nombre está libre en el trial) |
| Navegar por los paquetes | El **Explorador** (**Ctrl+Shift+E**): `ZGOR` y sus subpaquetes como carpetas |
| Ir a la definición de algo (una tabla, un método, una vista) | Cursor encima y **F12**, o **Ctrl+clic** |
| Ver dónde se usa | Clic derecho → *Find All References* (**Shift+Alt+F12**) |
| Ver los métodos de la clase abierta | La sección **Outline** (Esquema) del explorador |

## Crear un objeto

Todos los objetos (paquetes, clases, interfaces, tablas, vistas CDS, BDEF, *service definitions*…) se crean igual:

1. **Ctrl+Shift+Alt+N**, o **Ctrl+Shift+P** → `ABAP: Create ABAP Repository Object`. También con clic derecho sobre el paquete en el explorador.
2. Elige el **tipo**. Los nombres son los mismos que usan los apuntes: *Package*, *Class*, *Interface*, *Database Table*, *Structure*, *Data Definition*, *Behavior Definition*, *Metadata Extension*, *Service Definition*, *Service Binding*, *Authorization Object*…
3. Rellena el **paquete**, el **nombre** y la **descripción**. Según el tipo, pregunta algo más: en una clase, la superclase y las interfaces (`if_oo_adt_classrun` para las de consola); en una vista CDS, la plantilla y la tabla o vista de referencia; en una BDEF, la vista raíz y el tipo de implementación.
4. Si pregunta por una **orden de transporte**: en `ZLOCAL` no hay (*No change recording*), así que continúa sin elegir ninguna.

El objeto se abre en el editor. **No crees los ficheros a mano** en el explorador (por ejemplo, un `.clas.abap` nuevo): el explorador es una vista del sistema SAP, y un objeto solo existe si lo registra el asistente, con su tipo, paquete y descripción.

En los ejercicios:

- **Crea** significa un objeto nuevo con este asistente. La línea dice todo lo que pide: *tipo **Class** · paquete `ZGOR_TEST` · nombre `ZCL_GOR_X` · descripción `…` · interfaz `if_oo_adt_classrun`*. Cada objeto puede ser de un tipo distinto: fíjate en el tipo antes de elegirlo en la lista.
- **Dónde** significa un objeto que ya existe: ábrelo (**Ctrl+Shift+A**) y trabaja en él.

## Guardar, activar y ejecutar

| Para | Atajo |
|---|---|
| Guardar | **Ctrl+S** (guardar no activa: el sistema sigue usando la versión anterior) |
| Activar el objeto abierto | **Ctrl+F3** |
| Activar todo lo pendiente (varios objetos que dependen entre sí) | **Ctrl+Shift+F3**, o *Activate All* en la barra inferior |
| Ejecutar una clase de consola | **F5** con la clase abierta, o clic derecho → *Run ABAP Application (Console)* |
| Formatear el código | **Shift+Alt+F** (por comprobar) |
| Comentar o descomentar líneas | **Ctrl+/** (por comprobar) |
| Autocompletar | **Ctrl+Espacio** |

La salida de una clase de consola sale en el **panel inferior**. Se ejecuta siempre la **versión activa**: si cambias algo y solo guardas, verás la salida antigua.

> **Si no deja guardar.** Guardar envía el código al sistema SAP, y el sistema **rechaza el guardado si la estructura está rota**: sale un aviso *«No se pudo guardar… Save failed»* con el motivo al final (por ejemplo, *«The statement CLASS ... IMPLEMENTATION. is unexpected»*: falta el `ENDCLASS.` de la definición o un punto). Mientras tanto, el código **solo está en la pestaña**, marcada con un punto: si cierras VS Code, se pierde. Si el arreglo va para largo, copia el contenido (**Ctrl+A**, **Ctrl+C**) a un fichero de texto, corrige el error y guarda otra vez. En Eclipse esto no pasaba: guardaba con errores y fallaba al activar.

Muchos objetos de RAP se mencionan entre sí (dos vistas con associations en los dos sentidos, una BDEF y su clase) y por separado no activan. Abre o modifica los que vayan juntos y usa **Ctrl+Shift+F3**: los activa a la vez.

## Errores y ayuda

| Para | Cómo |
|---|---|
| Ver los errores al activar | La pestaña **Problemas** del panel inferior (**Ctrl+Shift+M**). Doble clic lleva a la línea |
| Ver la firma de un método, el tipo de un campo, la documentación de una clase | **Pasa el ratón por encima** (es lo que en Eclipse hacía **F2**) |
| Corrección rápida (crear un método que falta, una tabla de borradores…) | Cursor sobre el nombre y **Ctrl+.**, o clic en la bombilla (por comprobar; en Eclipse es **Ctrl+1**) |
| Documentación de una palabra clave (`LOOP AT GROUP`, `etag master`…) | Pasa el ratón por encima; si no sale, búscala en la [ayuda de ABAP de SAP](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm) |
| Ver un error en tiempo de ejecución (*dump*) | La pestaña **ABAP Feeds** del panel inferior |

## Tests

| Para | Cómo |
|---|---|
| Pegar los tests de una unidad | Abre la clase y su pestaña o sección **Test Classes** (`*.testclasses.abap`); pega debajo de lo que haya |
| Ejecutar los tests de la clase abierta | **Ctrl+Shift+F10** |
| Ejecutar los de todo un paquete | Clic derecho en el paquete (`ZGOR`) en el explorador → ejecutar los tests ABAP Unit (por comprobar), o la vista **Testing** de VS Code (el matraz de la barra izquierda) |
| Cobertura (qué líneas recorren los tests) | Por comprobar; si no está, en Eclipse: clic derecho → *Coverage As → ABAP Unit Test* |

## Ver datos (Data Preview)

El *Data Preview* de Eclipse se llama en VS Code **SQL Notebook**: una consulta sobre una tabla o vista cuyo resultado se ve como tabla. Ábrelo desde el clic derecho sobre la tabla o la vista (por comprobar) y escribe un `SELECT` como los de [1.5](./1_5_abapSql.md). Para comprobar los ejercicios, los apuntes usan además una clase de consola (`ZCL_GOR_SQL_DEMO`), que funciona en cualquier editor.

## Depurar

| Para | Atajo |
|---|---|
| Poner o quitar un *breakpoint* | Clic en el margen izquierdo de la línea, o **F9** |
| Siguiente línea (sin entrar en los métodos) | **F10** |
| Entrar en el método que se llama | **F11** |
| Salir del método actual | **Shift+F11** |
| Continuar hasta el siguiente *breakpoint* | **F5** |

Cuando el programa se detiene, VS Code abre la vista **Ejecución y depuración** (*Run and Debug*): variables, expresiones vigiladas, *breakpoints* y pila de llamadas. El *breakpoint* solo salta si la app se ejecuta con **el mismo usuario** con el que has iniciado sesión. Más en [4.4](./4_4_depurar.md).

## Calidad y transportes

- **ATC** (control de calidad, [5.1](./5_1_atc.md)): clic derecho en el paquete o la clase → ejecutar el *ABAP Test Cockpit* (por comprobar). Los hallazgos salen en **Problemas**.
- **Transportes:** la vista **ABAP Transport Organizer**. En el trial casi no se usa: `ZLOCAL` no graba cambios.

## Lo que sigue en Eclipse

La extensión de VS Code aún no hace todo lo que hace Eclipse. Mantenlo instalado y conectado al mismo trial: los dos editores ven los mismos objetos y puedes alternar sin perder nada.

| Qué | Dónde se usa | En Eclipse |
|---|---|---|
| **abapGit** (copia de seguridad en GitHub) | 0.1, 5.2 y [Restaurar](./RESTAURAR.md) | La vista *abapGit Repositories* |
| Lo que tu versión de VS Code no tenga (marcado arriba como «por comprobar») | Donde lo pida el ejercicio | Los atajos de la tabla siguiente |

## Equivalencias con Eclipse

Por si sigues un tutorial de SAP o trabajas en una empresa con Eclipse:

| Acción | Eclipse (ADT) | VS Code |
|---|---|---|
| Activar / activar todo | Ctrl+F3 / Ctrl+Shift+F3 | Igual |
| Ejecutar clase de consola | F9 | F5 |
| Tests de la clase | Ctrl+Shift+F10 | Igual |
| Abrir objeto | Ctrl+Shift+A | Igual |
| Crear objeto | Clic derecho → *New* | Ctrl+Shift+Alt+N |
| Corrección rápida | Ctrl+1 | Ctrl+. (por comprobar) |
| Información del elemento | F2 | Pasar el ratón |
| Ir a la definición | F3 | F12 |
| Ayuda de la palabra clave | F1 | Pasar el ratón / ayuda de SAP |
| Data Preview | F8 | SQL Notebook |
| Formatear | Shift+F1 | Shift+Alt+F (por comprobar) |
| Comentar líneas | Ctrl+< | Ctrl+/ (por comprobar) |
| Favoritos | *Favorite Packages* | Paquete añadido al área de trabajo |
| Consola | Pestaña *Console* | Panel inferior |
| Errores | Pestaña *Problems* | Pestaña *Problemas* |
| Depurar: paso / entrar / salir / continuar | F6 / F5 / F7 / F8 | F10 / F11 / Shift+F11 / F5 |

**Tus notas.** Si algo «por comprobar» funciona distinto en tu versión, apúntalo aquí:

| Qué | Cómo es en tu versión |
|---|---|
| | |

---

**Siguiente:** [Restaurar en un trial nuevo](./RESTAURAR.md)
