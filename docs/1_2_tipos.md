# 1.2. Variables, tipos de datos y plantillas de texto

Empezamos a escribir reglas de negocio. En el taller, las primeras son las del presupuesto ([0.5](./0_5_taller.md)): el importe de cada partida, la cuota del impuesto y el importe final. En esta unidad las programamos con los tipos de ABAP, y tú harás lo mismo con las fórmulas del presupuesto de tu ERP (§11.2 del informe técnico).

## Tipos básicos

| Tipo | Para qué | Ejemplo |
|---|---|---|
| `i` | Entero | `DATA lv_cantidad TYPE i VALUE 4.` |
| `decfloat34` | Decimal exacto: importes, porcentajes, horas | `DATA lv_precio TYPE decfloat34 VALUE '45.50'.` |
| `string` | Texto de longitud variable | `DATA lv_concepto TYPE string VALUE 'Embrague'.` |
| `c LENGTH n` | Texto de longitud fija (códigos, situaciones) | `DATA lv_ref TYPE c LENGTH 8 VALUE 'ORD0001'.` |
| `d` | Fecha, en formato `AAAAMMDD` | `DATA lv_entrada TYPE d VALUE '20261102'.` |
| `abap_bool` | Verdadero o falso (`abap_true` / `abap_false`) | `DATA lv_garantia TYPE abap_bool.` |

**¿Por qué `decfloat34` y no `f`?** El tipo `f` es coma flotante binaria, como el `float` de Python: `0.1 + 0.2` no da exactamente `0.3`. Con dinero eso es inaceptable. `decfloat34` guarda los números en base 10 y opera sin esos errores. Lo usaremos en todos los cálculos; en las tablas (Bloque 2), decimales de 2 cifras.

Los literales decimales van **entre comillas**: `'45.50'`. Sin comillas, ABAP no admite decimales en un literal.

## Variables, constantes y declaraciones inline

```abap
    DATA lv_cantidad TYPE i VALUE 4.                 " variable entera con valor inicial 4
    CONSTANTS lc_impuesto TYPE decfloat34 VALUE 21.  " constante: no se puede cambiar

    " Declaracion inline: el tipo sale de la expresion de la derecha
    DATA(lv_precio) = CONV decfloat34( '45' ).       " CONV convierte el texto '45' a decimal
    DATA(lv_neto)   = lv_cantidad * lv_precio.       " i * decfloat34 da decfloat34: 180
```

- `DATA` declara una variable; `CONSTANTS`, un valor que no cambia.
- `DATA(x) = ...` es una **declaración inline**: declara la variable donde se usa por primera vez, con el tipo del resultado. Es la forma habitual en ABAP moderno.
- `CONV tipo( valor )` convierte un valor a un tipo. `CONV #( valor )` deja que ABAP deduzca el tipo del destino (lo verás en los tests).

## Estructuras y tipos propios

`TYPES` define un tipo nuevo. Una **estructura** agrupa varios campos, como un diccionario de Python con los campos fijados de antemano. Se rellena con `VALUE #( campo = valor ... )` y cada campo se lee con un guion: `ls_partida-precio_unitario`.

```abap
    " Un tipo nuevo: una estructura con tres campos
    TYPES: BEGIN OF ty_partida,
             concepto        TYPE string,
             cantidad        TYPE i,
             precio_unitario TYPE decfloat34,
           END OF ty_partida.

    " VALUE construye la estructura dando valor a cada campo
    DATA(ls_partida) = VALUE ty_partida( concepto        = 'Horas de diagnosis'
                                         cantidad        = 4
                                         precio_unitario = '45' ).
    out->write( ls_partida ).                                     " la estructura entera, en columnas
    out->write( |{ ls_partida-cantidad } x { ls_partida-precio_unitario }| ).   " campo a campo, con el guion
```

Los tipos que se usan en varias clases no se repiten en cada una: se declaran una vez en una **interfaz de tipos** y se usan con su nombre completo. La del taller es así:

```abap
" Interfaz que solo contiene tipos y constantes: no tiene metodos
INTERFACE zif_tl_tipos PUBLIC.
  " Tipos basicos con nombre propio: si un dia cambia el tipo, se cambia aqui
  TYPES ty_euros    TYPE decfloat34.
  TYPES ty_tanto    TYPE decfloat34.          " porcentajes
  TYPES ty_tiempo   TYPE decfloat34.          " horas
  TYPES ty_ref      TYPE c LENGTH 8.          " codigos TIT0001, ORD0001...
  TYPES ty_situacion TYPE c LENGTH 15.

  " Una partida de presupuesto
  TYPES: BEGIN OF ty_partida,
           concepto        TYPE string,
           cantidad        TYPE i,
           precio_unitario TYPE ty_euros,
         END OF ty_partida.

  " Grupo de constantes: se usan como zif_tl_tipos=>situacion_presupuesto-aceptado
  CONSTANTS: BEGIN OF situacion_presupuesto,
               borrador TYPE ty_situacion VALUE 'borrador',
               aceptado TYPE ty_situacion VALUE 'aceptado',
             END OF situacion_presupuesto.
ENDINTERFACE.
```

Las constantes se usan así: `zif_tl_tipos=>situacion_presupuesto-aceptado`. Así no se escribe `'aceptado'` a mano en veinte sitios (y no hay errores de tecleo en ninguno).

## Plantillas de texto

Una plantilla va entre barras verticales y mezcla texto con expresiones entre llaves. Es el equivalente de los *f-strings* de Python:

```abap
    DATA(lv_importe) = CONV decfloat34( '605' ).
    DATA(lv_entrada) = CONV d( '20261102' ).

    out->write( |Importe: { lv_importe DECIMALS = 2 } €| ).           " Importe: 605.00 €
    out->write( |Entrada: { lv_entrada DATE = ISO }| ).               " Entrada: 2026-11-02
    out->write( |Orden: { 'ORD' }{ 7 WIDTH = 4 ALIGN = RIGHT PAD = '0' }| ).  " ORD0007
```

Las opciones de formato van dentro de las llaves: `DECIMALS`, `DATE`, `WIDTH`, `ALIGN`, `PAD`…

Hay dos clases de literales de texto: `'...'` (comillas simples) es de tipo `c` y pierde los espacios del final; `` `...` `` (acentos graves) es de tipo `string` y los conserva.

## Fechas

Una fecha (`d`) es un texto de 8 cifras, pero ABAP sabe operar con ella: **restar dos fechas da los días** entre ellas, y sumar un número a una fecha avanza ese número de días.

```abap
    DATA(lv_desde) = CONV d( '20261228' ).   " fechas: siempre AAAAMMDD
    DATA(lv_hasta) = CONV d( '20270103' ).
    out->write( lv_hasta - lv_desde ).       " fecha - fecha = dias entre ellas: 6
    out->write( lv_desde + 7 ).              " fecha + numero = otra fecha: 20270104
```

Fíjate en que la resta cruza el cambio de año sin que tengamos que hacer nada: del 28 de diciembre al 3 de enero hay 6 días, y ABAP lo sabe porque conoce el calendario. Lo usaremos en el ERP para los días de una falta (§11.2), que se cuentan **incluyendo** los dos extremos: por eso allí sumaremos 1 al resultado de la resta.

## Redondeo

`round( val = x dec = 2 )` redondea a 2 decimales, **hacia arriba en el empate** (`31.665` → `31.67`).

## Métodos estáticos: la clase de cálculos

Las fórmulas van como **métodos estáticos** (`CLASS-METHODS`): se llaman con el nombre de la clase, sin crear ningún objeto. En 1.6 veremos las clases con objetos; por ahora, así es la clase de cálculos del taller con sus primeras fórmulas:

```abap
CLASS zcl_tl_calculos DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Redondeo a centimos (empate hacia arriba)
    CLASS-METHODS ajustar_centimos
      IMPORTING iv_valor        TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_valor) TYPE zif_tl_tipos=>ty_euros.

    " importe_partida = ajustar_centimos( cantidad * precio_unitario )
    CLASS-METHODS importe_partida
      IMPORTING iv_cantidad        TYPE i
                iv_precio_unitario TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_importe)  TYPE zif_tl_tipos=>ty_euros.

    " cuota = ajustar_centimos( neto * impuesto / 100 )
    CLASS-METHODS cuota_impuesto
      IMPORTING iv_neto         TYPE zif_tl_tipos=>ty_euros
                iv_impuesto     TYPE zif_tl_tipos=>ty_tanto
      RETURNING VALUE(rv_cuota) TYPE zif_tl_tipos=>ty_euros.

    " jornadas de una ausencia, contando los dos extremos
    CLASS-METHODS jornadas_ausencia
      IMPORTING iv_desde           TYPE d
                iv_hasta           TYPE d
      RETURNING VALUE(rv_jornadas) TYPE i.
ENDCLASS.

CLASS zcl_tl_calculos IMPLEMENTATION.
  METHOD ajustar_centimos.
    rv_valor = round( val = iv_valor dec = 2 ).
  ENDMETHOD.

  METHOD importe_partida.
    rv_importe = ajustar_centimos( iv_cantidad * iv_precio_unitario ).
  ENDMETHOD.

  METHOD cuota_impuesto.
    rv_cuota = ajustar_centimos( iv_neto * iv_impuesto / 100 ).
  ENDMETHOD.

  METHOD jornadas_ausencia.
    IF iv_desde IS INITIAL OR iv_hasta IS INITIAL.
      RETURN.                 " rv_jornadas queda en 0
    ENDIF.
    rv_jornadas = iv_hasta - iv_desde + 1.
  ENDMETHOD.
ENDCLASS.
```

Cómo se lee la firma de un método:

- `IMPORTING` son los parámetros de entrada; `RETURNING VALUE(...)`, el valor que devuelve. Se llama así: `zcl_tl_calculos=>importe_partida( iv_cantidad = 4 iv_precio_unitario = 45 )`.
- Dentro de la propia clase, un método estático se llama sin el nombre de la clase: `ajustar_centimos( ... )`.
- Los prefijos son una convención: `iv_` para los parámetros de entrada, `rv_` para el valor devuelto, `lv_` para las variables locales y `ls_` para las estructuras locales (ver el [Anexo B](./B_nombres.md)).
- `RETURN` sale del método. Como `rv_jornadas` empieza en 0, si falta una fecha se devuelve 0.

> **Código completo del taller:** [zif_tl_tipos](./materiales/taller/src/bus/zif_tl_tipos.intf.abap), [zcl_tl_calculos](./materiales/taller/src/bus/zcl_tl_calculos.clas.abap) y los ejemplos en [zcl_tl_demo_lenguaje](./materiales/taller/src/test/zcl_tl_demo_lenguaje.clas.abap). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Seguimos en los paquetes de [1.1](./1_1_classrun.md). Al terminar, tu proyecto tendrá esta forma:

```text
ZGOR
├── ZGOR_BUS
│   ├── ZIF_GOR_TIPOS        ← tipos comunes (nueva)
│   └── ZCL_GOR_REGLAS       ← reglas de negocio (nueva)
└── ZGOR_TEST
    ├── ZCL_GOR_INICIO       (1.1)
    └── ZCL_GOR_TIPOS_DEMO   ← pruebas de esta unidad (nueva)
```

## Ejercicios

1. **La interfaz de tipos.**
    - **Dónde:** clic derecho en `ZGOR_BUS` → **New → ABAP Interface**. Nombre `ZIF_GOR_TIPOS`, descripción `Tipos comunes del ERP`.
    - **Qué contiene** (con el mismo estilo que `ZIF_TL_TIPOS`, y un comentario por grupo):

    | Elemento | Definición |
    |---|---|
    | `ty_importe`, `ty_horas`, `ty_porcentaje` | `decfloat34` |
    | `ty_codigo` | Texto de 8 caracteres |
    | `ty_estado` | Texto de 15 caracteres |
    | `ty_presu_linea` | Estructura con `descripcion` (`string`), `uds` (`i`) y `precio` (`ty_importe`): la línea de un presupuesto (§3.6) |
    | `estado_presu` | Constantes `aprobado` y `no_aprobado`, de tipo `ty_estado`, con esos mismos valores |

    - **Comprueba:** la interfaz activa sin errores (**Ctrl+F3**).

2. **Las fórmulas del presupuesto.**
    - **Dónde:** clic derecho en `ZGOR_BUS` → **New → ABAP Class**. Nombre `ZCL_GOR_REGLAS`, descripción `Reglas de negocio del ERP`. Es una clase normal, **no** ejecutable.
    - **Qué contiene:** estos cuatro métodos estáticos (`CLASS-METHODS`), declarados en la `PUBLIC SECTION` con un comentario encima de cada uno que diga su regla, como en `ZCL_TL_CALCULOS`. El IVA llega como porcentaje: 21, no 0.21.

    | Método | Parámetros de entrada | Devuelve | Regla (§11.2) |
    |---|---|---|---|
    | `redondear` | `iv_valor` (`ty_importe`) | `rv_valor` (`ty_importe`) | 2 decimales, empate hacia arriba |
    | `total_linea` | `iv_uds` (`i`), `iv_precio` (`ty_importe`) | `rv_total` (`ty_importe`) | `redondear(uds × precio)` |
    | `cuota_iva` | `iv_base` (`ty_importe`), `iv_iva` (`ty_porcentaje`) | `rv_cuota` (`ty_importe`) | `redondear(base × iva / 100)` |
    | `total_presupuesto` | `iv_base`, `iv_iva` | `rv_total` (`ty_importe`) | `base + cuota_iva`. Reutiliza `cuota_iva` |

    - **Comprueba:** activa la clase. Lo comprobarás de verdad en el ejercicio 4 y con el test.

3. **Más fórmulas.**
    - **Dónde:** la misma clase `ZCL_GOR_REGLAS`.
    - **Qué contiene:** tres métodos estáticos más:

    | Método | Parámetros de entrada | Devuelve | Regla |
    |---|---|---|---|
    | `total_proveedor` | `iv_base`, `iv_iva` | `rv_total` (`ty_importe`) | `base × (1 + iva / 100)`, **sin redondear** (§11.2 *Otros*) |
    | `coste_subtotal` | `iv_horas` (`ty_horas`), `iv_coste_hora` (`ty_importe`) | `rv_coste` (`ty_importe`) | `horas × coste_hora` (§11.2 *Obra*), sin redondear |
    | `dias_falta` | `iv_inicio`, `iv_fin` (tipo `d`) | `rv_dias` (`i`) | `fin − inicio + 1`; **0** si falta alguna de las dos fechas (§3.12) |

    - **Comprueba:** con el test de esta unidad (abajo): 7 en verde.

4. **El presupuesto del escenario.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_TIPOS_DEMO`, descripción `Pruebas de tipos y formulas`. Es ejecutable, como `ZCL_GOR_INICIO`.
    - **Qué hace:** en `main`, declara una estructura `zif_gor_tipos=>ty_presu_linea` con 10 uds a 100 € y, con `ZCL_GOR_REGLAS`, calcula su total, la cuota con IVA 21 y el total del presupuesto. Escribe cada valor con una plantilla y `DECIMALS = 2`.
    - **Comprueba:** ejecuta con **F9**. Es el paso 2 de §12.7; deben salir estas tres líneas:

    ```text
    Base: 1000.00
    Cuota IVA: 210.00
    Total: 1210.00
    ```

5. **Una estructura por entidad.**
    - **Dónde:** el `main` de `ZCL_GOR_TIPOS_DEMO`, después del ejercicio 4.
    - **Qué hace:** declara con `TYPES` una estructura con los campos propios de cada entidad del ERP (sin relaciones ni campos calculados): `ty_cliente` (§3.1), `ty_trabajador` (§3.2), `ty_proveedor` (§3.3), `ty_especialista` (§3.4), `ty_obra` (§3.5), `ty_ingreso` (§3.8) y `ty_falta` (§3.12). Para elegir los tipos:

    | En Odoo | En ABAP |
    |---|---|
    | `Char` de código o de estado | `ty_codigo` o `ty_estado` |
    | `Char` de nombres, direcciones, teléfonos… y `Text` | `string` |
    | `Integer` | `i` |
    | `Float`, `Monetary` | `ty_importe` (las horas, `ty_horas`) |
    | `Date` | `d` |
    | `Boolean` o `Selection` de sí/no | `abap_bool` |

    - **Comprueba:** crea un cliente (Juan Pérez López, `CLI0001`) y un trabajador (`TRB0001`, 20 €/h) con `VALUE` y escríbelos con `out->write( )`: en la consola salen en columnas, con el nombre de cada campo.
6. **Investiga.** En Python, `round(31.665, 2)` no da `31.67`. Pruébalo y busca por qué (pista: cómo guarda `float` los decimales y qué regla de empate usa `round`). Calcula después `zcl_gor_reglas=>redondear( CONV #( '31.665' ) )`. Escribe en un comentario qué diferencia hay y por qué, al portar, conviene que el ERP en SAP use siempre `redondear`.

## Comprueba tu solución automáticamente (opcional)

Abre `ZCL_GOR_REGLAS`, ve a la pestaña inferior **Test Classes** y pega el contenido de [1_2_ltcl_presupuesto.abap](materiales/tests/1_2_ltcl_presupuesto.abap). Ejecútalo con **Ctrl+Shift+F10** (*Run As → ABAP Unit Test*). Si tu solución es correcta, salen **7 tests en verde**. Si alguno sale en rojo, el mensaje dice qué valor esperaba y cuál ha salido. En [1.8](./1_8_abapUnit.md) aprenderás a escribirlos tú.

Cada unidad del bloque añade otra clase de test **a continuación** de las anteriores, en la misma pestaña: no borres las de unidades previas.

---

**Siguiente:** [1.3. Control de flujo y funciones de cadena](./1_3_flujo.md)
