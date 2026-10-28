# 1.1. Tu primer programa: clases ejecutables

> **Bloque 1 · Fundamentos del lenguaje: las reglas de negocio en ABAP.** Empezamos el **ERP de Obras y Reformas**, el port a SAP de `gestion_bd`. Antes de crear tablas o apps, en este bloque escribiremos en ABAP puro **las reglas de negocio** del informe técnico: cómo se calcula un presupuesto, cuándo está pagada una obra o qué validaciones hay que pasar. Todo irá a una clase, `ZCL_GOR_REGLAS`, con tests automáticos que comprueban cada fórmula. Terminaremos con una simulación que calcula en memoria los indicadores de una obra completa. En el Bloque 3, el comportamiento RAP **reutilizará esa misma clase**.

En esta primera unidad preparamos el terreno: los paquetes del proyecto y una clase que se ejecuta desde Eclipse y escribe en la consola.

> **Dos proyectos.** La teoría usa como ejemplo el **taller RuedaLibre** ([0.5](./0_5_taller.md)); los ejercicios construyen **tu ERP**. Puedes probar los ejemplos en tu paquete `ZEJ`, pero lo que entregas es lo de `ZGOR`.

## Clases ejecutables

En ABAP Cloud no hay `REPORT` ni `WRITE`. Para ejecutar código creamos una **clase** que implementa la interfaz **`IF_OO_ADT_CLASSRUN`**. Esa interfaz obliga a escribir un método, `main`, que recibe un parámetro `out`: lo que pasemos a `out->write( )` aparece en la pestaña **Console** de Eclipse al ejecutar la clase con **F9**.

Una clase tiene dos partes:

- La **definición** (`DEFINITION`), que declara qué tiene la clase: aquí, solo que implementa la interfaz.
- La **implementación** (`IMPLEMENTATION`), que contiene el código de cada método.

```abap
CLASS zcl_tl_bienvenida DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_tl_bienvenida IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Cabecera del taller
    out->write( 'Taller RuedaLibre' ).
    out->write( 'Reparacion y mantenimiento de vehiculos' ).
    out->write( ' ' ).
    out->write( 'Series de codigos:' ).
    out->write( 'Titulares      TIT0001' ).
    out->write( 'Ordenes        ORD0001' ).
  ENDMETHOD.
ENDCLASS.
```

Es la clase de bienvenida del taller: escribe su nombre y dos de sus series de códigos. El nombre del método, `if_oo_adt_classrun~main`, se lee «el método `main` de la interfaz `if_oo_adt_classrun`». La tilde `~` separa la interfaz del método.

## Cómo se escribe ABAP

- **Cada sentencia termina en punto.** Olvidar un punto es el error más común al empezar.
- **Los comentarios** empiezan por una comilla doble `"` (desde ahí hasta el final de la línea) o por un asterisco `*` en la primera columna (toda la línea).
- **Las palabras clave no distinguen mayúsculas.** `CLASS` y `class` son lo mismo. Eclipse las formatea según tus preferencias con **Shift+F1** (*Format*).
- **Los textos entre comillas simples** (`'Taller RuedaLibre'`) son literales de texto. En 1.2 veremos las *plantillas de texto*, que permiten mezclar texto y variables.

En los comentarios evitamos las tildes y la eñe. No dan error, pero algunas herramientas de comparación las muestran mal. En los textos que se ven por pantalla sí las usamos.

## Los paquetes del proyecto

En ABAP todo objeto (clase, tabla, vista…) pertenece a un **paquete**. El proyecto se organiza en un paquete principal, `ZGOR`, con un subpaquete por capa:

| Paquete | Contiene | Se usa desde |
|---|---|---|
| `ZGOR` | Solo los subpaquetes | 1.1 |
| `ZGOR_DDIC` | Tablas y estructuras del diccionario | 1.5 |
| `ZGOR_CDS` | Vistas CDS | Bloque 2 |
| `ZGOR_BUS` | La clase de reglas y, después, el comportamiento RAP | 1.2 |
| `ZGOR_SRV` | Proyecciones, servicios y anotaciones de la interfaz | Bloque 4 |
| `ZGOR_TEST` | Clases de consola, datos de demo y el escenario de pruebas | 1.1 |

Cuando enlacemos `ZGOR` con GitHub ([5.2](./5_2_abapgit.md)), abapGit guardará cada subpaquete en su propia carpeta de `src/` del repositorio `erp-obras-reformas-sap`.

> **El trial es un sistema compartido.** Todos los usuarios del trial crean sus objetos en el mismo sistema, bajo el paquete `ZLOCAL`, y **dos objetos no pueden llamarse igual**. Si otra persona ya creó un paquete `ZGOR`, el tuyo no se podrá crear con ese nombre. Por eso, el primer ejercicio es comprobarlo.

## Las entidades del ERP

La consola de esta unidad presenta las entidades que vamos a construir. Son las mismas que las del módulo de Odoo (informe técnico, §3), y ocho tienen un **código visible** con prefijo y 4 cifras (§10):

| Entidad | Código | Entidad | Código |
|---|---|---|---|
| Cliente | `CLI0001` | Obra | `OBR0001` |
| Trabajador | `TRB0001` | Gasto (ficha de la obra) | `GAS0001` |
| Proveedor | `PROV0001` | Ingreso | `ING0001` |
| Especialista | `ESP0001` | Parte de Trabajo | sin código (fecha) |
| Presupuesto | `PREP0001` | Partes de Especialista y de Proveedor | sin código |

## Preparación del entorno de trabajo

Necesitas Eclipse con ADT conectado a tu trial, como se explica en [0.1. Preparación del entorno](./00_instalacionEntorno.md). En esta unidad creas los paquetes de `ZGOR`; a partir de aquí, todo el proyecto vive en ellos.

Al terminar, el proyecto tendrá esta forma:

```
ZLOCAL
└── ZGOR
    ├── ZGOR_DDIC
    ├── ZGOR_CDS
    ├── ZGOR_BUS
    ├── ZGOR_SRV
    └── ZGOR_TEST
        └── ZCL_GOR_INICIO   ← la clase de esta unidad (nueva)
```

## Ejercicios

1. **Comprueba que los nombres están libres.** En Eclipse, pulsa **Ctrl+Shift+A** (*Open ABAP Development Object*) y escribe `ZGOR`. Si la lista sale vacía, el nombre está libre. Repite con `ZCL_GOR`, `ZI_GOR` y, para los ejemplos, `ZTL`. Si aparece algún objeto que **no es tuyo**, para aquí: hay que elegir otro prefijo para todo el proyecto antes de seguir (ver la nota de abajo).
2. **El paquete principal.** Clic derecho en `ZLOCAL` → **New → ABAP Package**:
    - *Name*: `ZGOR`.
    - *Description*: `ERP de Obras y Reformas`.
    - *Superpackage*: `ZLOCAL`. *Software Component*: `ZLOCAL`.

    En `ZLOCAL` no hace falta orden de transporte. Si el asistente te pide una, créala con *Create New Request*.
3. **Los subpaquetes.** Clic derecho en `ZGOR` → **New → ABAP Package**, cinco veces: `ZGOR_DDIC`, `ZGOR_CDS`, `ZGOR_BUS`, `ZGOR_SRV` y `ZGOR_TEST`, con *Superpackage* `ZGOR` y la descripción de la tabla de [Los paquetes del proyecto](#los-paquetes-del-proyecto). Comprueba en el *Project Explorer* que cuelgan de `ZGOR`.
4. **La clase de inicio.** Clic derecho en `ZGOR_TEST` → **New → ABAP Class**, con nombre `ZCL_GOR_INICIO` y descripción `Presentacion del proyecto`. Es una clase ejecutable, como la del taller. Al ejecutarla (**F9**) debe escribir estas dos líneas:

    ```
    ERP de Obras y Reformas
    Port a SAP del modulo gestion_bd de Odoo
    ```

5. **Las entidades.** Amplía `main` para que, después de las dos líneas, escriba: una línea en blanco; el título `Entidades con codigo propio:`; una línea por cada una de las ocho entidades con código de la tabla de [Las entidades del ERP](#las-entidades-del-erp), con su nombre y su primer código (`Cliente        CLI0001`); el título `Entidades sin codigo:`, y los tres tipos de parte, uno por línea. Activa y ejecuta: la consola debe mostrar 2 + 1 + 1 + 8 + 1 + 3 = **16 líneas**.
6. **Lee los errores.** Quita el punto final de una de las líneas de `out->write` y activa. Fíjate en el mensaje de la pestaña *Problems* y en la línea que señala: a veces no es la línea del error, sino la siguiente. Vuelve a poner el punto. Haz lo mismo cambiando `out->write` por `out->writ`. Escribe en un comentario, encima de `main`, cómo es cada uno de los dos mensajes.
7. **Investiga.** Con el cursor sobre `write`, pulsa **F2**. ¿Qué parámetros acepta el método? ¿Hay alguno opcional? Anótalo en un comentario: en 1.2 escribiremos con él estructuras completas, no solo textos.

> **Si el ejercicio 1 encuentra objetos de otra persona**, no crees nada todavía. Elige un prefijo de 4 letras que no exista (compruébalo igual que en el ejercicio 1) y avisa antes de seguir: los apuntes se adaptarán a ese prefijo. Lo mismo vale para `ZEJ`, el paquete de pruebas de [0.1](./00_instalacionEntorno.md).

En esta unidad no hay comprobación automática: el resultado se ve en la consola. A partir de 1.2, cada unidad trae su test.

---

**Siguiente:** [1.2. Variables, tipos de datos y plantillas de texto](./1_2_tipos.md)
