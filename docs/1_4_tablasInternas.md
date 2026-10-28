# 1.4. Tablas internas

Casi todo lo que calcula un sistema de gestión es una **suma sobre una lista**. En el taller, el neto del presupuesto es la suma de sus partidas; el importe de la orden, la suma de sus presupuestos aceptados; la mano de obra, la suma de los tramos de sus jornadas. En ABAP, las listas en memoria son **tablas internas**. En esta unidad aprendemos a trabajar con ellas, y tú añadirás a `ZCL_GOR_REGLAS` todas las reglas de §11.2 que trabajan con listas y la búsqueda por palabras de §11.5 (punto 10).

## Qué es una tabla interna

Una tabla interna es una colección en memoria de filas del mismo tipo: el equivalente de una lista de diccionarios en Python, o de un *recordset* de Odoo ya leído. Hay tres clases:

| Clase | Acceso | Cuándo |
|---|---|---|
| `STANDARD TABLE` | Por posición; búsquedas recorriendo la tabla | La habitual, para listas pequeñas o que se recorren enteras |
| `SORTED TABLE` | Siempre ordenada por su clave | Cuando se busca mucho por un campo y se necesita el orden |
| `HASHED TABLE` | Por clave única, muy rápido | Cuando se busca por una clave única (un código) en tablas grandes |

```abap
    TYPES tt_partidas TYPE STANDARD TABLE OF zif_tl_tipos=>ty_partida WITH EMPTY KEY.
```

`WITH EMPTY KEY` indica que la tabla no tiene clave: se accede por posición o buscando por los campos que interesen. Para listas como estas es lo más sencillo.

## Rellenar una tabla

```abap
    " VALUE con varias filas: cada ( ... ) interior es una fila
    DATA(lt_partidas) = VALUE tt_partidas(
      ( concepto = 'Horas de diagnosis' cantidad = 4 precio_unitario = '45' )
      ( concepto = 'Kit de embrague'    cantidad = 1 precio_unitario = '320' ) ).

    " APPEND anade una fila al final; # toma el tipo de la fila de lt_partidas
    APPEND VALUE #( concepto = 'Liquido de frenos' cantidad = 2 precio_unitario = '12.50' ) TO lt_partidas.

    out->write( lines( lt_partidas ) ).    " 3
    out->write( lt_partidas ).             " la tabla entera, en columnas
```

Cada par de paréntesis interiores es una fila. `lines( )` devuelve el número de filas.

## Recorrer una tabla

```abap
    DATA lv_neto TYPE zif_tl_tipos=>ty_euros.          " empieza en 0

    " Recorrer todas las filas: en cada vuelta, ls_partida es una COPIA de la fila
    LOOP AT lt_partidas INTO DATA(ls_partida).
      lv_neto = lv_neto + zcl_tl_calculos=>importe_partida( iv_cantidad        = ls_partida-cantidad
                                                            iv_precio_unitario = ls_partida-precio_unitario ).
    ENDLOOP.

    " Solo las filas que cumplen la condicion
    LOOP AT lt_partidas INTO ls_partida WHERE cantidad > 1.
      out->write( |{ ls_partida-concepto }: { ls_partida-cantidad }| ).
    ENDLOOP.
```

`LOOP AT ... INTO` copia cada fila en una estructura. Con `WHERE` solo se recorren las filas que cumplen la condición.

## Leer una fila

```abap
    " Por posicion (la primera fila es la 1, no la 0)
    DATA(ls_primera) = lt_partidas[ 1 ].

    " Por contenido: primero se pregunta si existe, para no provocar una excepcion
    IF line_exists( lt_partidas[ concepto = 'Kit de embrague' ] ).
      DATA(ls_embrague) = lt_partidas[ concepto = 'Kit de embrague' ].
    ENDIF.
```

Si la fila no existe, `lt_partidas[ ... ]` lanza una **excepción** (en 1.7 veremos cómo tratarla). Por eso, antes de leer, se pregunta con `line_exists( )`. Otra opción es `VALUE #( lt_partidas[ ... ] OPTIONAL )`, que devuelve una fila vacía si no la encuentra.

## Modificar filas: *field symbols*

`LOOP AT ... INTO` trabaja con una **copia**: cambiarla no cambia la tabla. Para modificar la fila de verdad se usa un *field symbol*, que es un **alias** de la fila (un puntero, si vienes de C):

```abap
    LOOP AT lt_partidas ASSIGNING FIELD-SYMBOL(<ls_partida>).
      <ls_partida>-precio_unitario = <ls_partida>-precio_unitario * '1.03'.   " sube un 3 % en la tabla
    ENDLOOP.
```

Con `ASSIGN` se apunta a una fila concreta. Si no existe, no hay excepción: `sy-subrc` vale distinto de 0. Este patrón sirve para **acumular por clave**. Así hace el taller su ranking de mecánicos por **euros** facturados:

```abap
  METHOD ranking_mecanicos.
    LOOP AT it_tramos INTO DATA(ls_tramo).
      ASSIGN rt_ranking[ mecanico = ls_tramo-mecanico ] TO FIELD-SYMBOL(<ls_puesto>).
      IF sy-subrc <> 0.
        APPEND VALUE #( mecanico = ls_tramo-mecanico ) TO rt_ranking ASSIGNING <ls_puesto>.
      ENDIF.
      <ls_puesto>-euros  += coste_tramo( iv_tiempo = ls_tramo-tiempo iv_tarifa = ls_tramo-tarifa_aplicada ).
      <ls_puesto>-tiempo += ls_tramo-tiempo.
    ENDLOOP.
    SORT rt_ranking BY euros DESCENDING mecanico ASCENDING.
  ENDMETHOD.
```

`+=` suma sobre el propio campo: `a += b` es `a = a + b`.

## Ordenar, quitar duplicados y borrar

```abap
    SORT lt_refs BY table_line.                                      " ordenar por la fila entera
    DELETE ADJACENT DUPLICATES FROM lt_refs COMPARING table_line.    " quitar repetidos seguidos

    DELETE lt_partidas WHERE cantidad = 0.                           " borrar las filas que cumplen la condicion
```

`table_line` significa «la fila entera», para tablas cuyas filas no son estructuras (una tabla de códigos). `DELETE ADJACENT DUPLICATES` solo quita duplicados **seguidos**: por eso se ordena antes. Con eso se sacan, por ejemplo, los mecánicos distintos que han trabajado en una orden.

## Expresiones de tabla: `VALUE ... FOR` y `REDUCE`

Las dos formas modernas de construir una tabla o un valor a partir de otra tabla, sin escribir el `LOOP`:

```abap
    " Una tabla nueva con una columna de otra (como una list comprehension)
    DATA(lt_conceptos) = VALUE zif_tl_tipos=>tt_textos( FOR ls IN lt_partidas ( ls-concepto ) ).

    " Un valor acumulado (como sum() con un generador)
    DATA(lv_neto_total) = REDUCE zif_tl_tipos=>ty_euros(
                            INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                            FOR ls IN lt_partidas
                            NEXT lv_suma = lv_suma + zcl_tl_calculos=>importe_partida(
                                                       iv_cantidad        = ls-cantidad
                                                       iv_precio_unitario = ls-precio_unitario ) ).

    " Con condicion: solo los presupuestos aceptados
    DATA(lv_importe_orden) = REDUCE zif_tl_tipos=>ty_euros(
                               INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                               FOR ls IN lt_presupuestos
                               WHERE ( situacion = zif_tl_tipos=>situacion_presupuesto-aceptado )
                               NEXT lv_suma = lv_suma + ls-importe ).
```

## Partir un texto en palabras

`SPLIT ... AT ... INTO TABLE` convierte un texto en una tabla de palabras. El filtro de mecánicos del taller lo usa para que «García Ruiz» encuentre al mecánico aunque «García» esté en el nombre y «Ruiz» en los apellidos. En el taller, cada palabra tiene que ser el **principio** de algún campo (`garc` encuentra a García, `arcía` no):

```abap
  METHOD encaja_filtro.
    rv_encaja = abap_true.
    SPLIT condense( to_lower( iv_texto ) ) AT space INTO TABLE DATA(lt_palabras).
    LOOP AT lt_palabras INTO DATA(lv_palabra) WHERE table_line IS NOT INITIAL.
      DATA(lv_encontrada) = abap_false.
      LOOP AT it_campos INTO DATA(lv_campo).
        IF to_lower( lv_campo ) CP |{ lv_palabra }*|.
          lv_encontrada = abap_true.
          EXIT.                         " sale del LOOP interior
        ENDIF.
      ENDLOOP.
      IF lv_encontrada = abap_false.
        rv_encaja = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
```

`CP` (*covers pattern*) compara con un patrón en el que `*` es «cualquier cosa». `EXIT` sale del bucle en el que está.

## Preparación del entorno de trabajo

Seguimos con `ZIF_GOR_TIPOS`, `ZCL_GOR_REGLAS` y `ZCL_GOR_TIPOS_DEMO` de [1.2](./1_2_tipos.md) y [1.3](./1_3_flujo.md).

## Ejercicios

1. **Los tipos de tabla.**
    - **Dónde:** `ZIF_GOR_TIPOS`, debajo de `ty_presu_linea`, con un comentario por tipo.
    - **Qué contiene:**

    | Tipo | Definición |
    |---|---|
    | `tt_presu_lineas` | Tabla estándar sin clave de `ty_presu_linea` |
    | `ty_presupuesto` | Estructura con `codigo` (`ty_codigo`), `estado` (`ty_estado`) y `total` (`ty_importe`): un presupuesto visto desde su obra (§3.5) |
    | `tt_presupuestos` | Tabla estándar sin clave de `ty_presupuesto` |
    | `ty_parte_linea` | Estructura con `trabajador` (`ty_codigo`), `horas` (`ty_horas`) y `coste_hora` (`ty_importe`): una línea de parte de trabajo (§3.9) |
    | `tt_parte_lineas` | Tabla estándar sin clave de `ty_parte_linea` |
    | `ty_horas_trabajador` | Estructura con `trabajador` (`ty_codigo`), `horas` (`ty_horas`) y `coste` (`ty_importe`) |
    | `tt_horas_trabajador` | Tabla estándar sin clave de `ty_horas_trabajador` |
    | `tt_codigos` | Tabla estándar sin clave de `ty_codigo` |
    | `tt_textos` | Tabla estándar sin clave de `string` |

2. **Las sumas de la obra.** Añade a `ZCL_GOR_REGLAS`:

    - **Dónde:** `ZCL_GOR_REGLAS`, como métodos estáticos.
    - **Qué contiene:**

    | Método | Recibe | Devuelve | Regla (§11.2) |
    |---|---|---|---|
    | `base_imponible` | `it_lineas` (`tt_presu_lineas`) | `rv_base` (`ty_importe`) | `redondear(Σ total_linea)`, reutilizando `total_linea` |
    | `total_obra` | `it_presupuestos` (`tt_presupuestos`) | `rv_total` (`ty_importe`) | `redondear(Σ total)` **solo** de los presupuestos con estado `aprobado`; 0 si no hay ninguno |
    | `horas_parte` | `it_lineas` (`tt_parte_lineas`) | `rv_horas` (`ty_horas`) | `Σ horas` |
    | `coste_parte` | `it_lineas` (`tt_parte_lineas`) | `rv_coste` (`ty_importe`) | `Σ coste_subtotal`, reutilizando `coste_subtotal` |

    - **Comprueba:** con el test de la unidad.

3. **Quién participa.**
    - **Dónde:** `ZCL_GOR_REGLAS`.
    - **Firma:** `participantes`, recibe `it_lineas` (`tt_parte_lineas`) y devuelve `rt_trabajadores` (`tt_codigos`).
    - **Qué hace** (§11.2 *Otros*): los trabajadores **distintos** de las líneas, ordenados. Patrón: `VALUE ... FOR`, `SORT` y `DELETE ADJACENT DUPLICATES`.
    - **Comprueba:** con tres líneas de `TRB0002`, `TRB0001` y `TRB0002`, devuelve dos filas: `TRB0001` y `TRB0002`.

4. **Horas por trabajador.**
    - **Dónde:** `ZCL_GOR_REGLAS`.
    - **Firma:** `horas_por_trabajador`, recibe `it_lineas` (`tt_parte_lineas`) y devuelve `rt_horas` (`tt_horas_trabajador`).
    - **Qué hace:** una fila por trabajador con la suma de sus horas y de su coste, ordenada de **más a menos horas** y, si empatan, por código. Es la base del «top 5 trabajadores por horas» del dashboard (§3.14). Ojo: el ranking del taller ordena por euros.
    - **Comprueba:** con las líneas del ejercicio 3 (8 h, 8 h y 4,5 h, todas a 20 €/h), la primera fila es `TRB0002` con 12,5 h y 250 €.

5. **La búsqueda por palabras.**
    - **Dónde:** `ZCL_GOR_REGLAS`.
    - **Firma:** `coincide_busqueda`, recibe `iv_busqueda` (`string`) e `it_campos` (`tt_textos`) y devuelve `rv_coincide` (`abap_bool`).
    - **Qué hace** (§11.5, punto 10): cada palabra de la búsqueda debe **aparecer** en alguno de los campos, en cualquier posición y sin distinguir mayúsculas. Una búsqueda vacía coincide siempre. Fíjate en la diferencia con el filtro del taller, que exige que la palabra sea el principio del campo.
    - **Comprueba:** en `ZCL_GOR_TIPOS_DEMO`, con los campos de un cliente (nombre `Juan`, apellidos `Pérez López`, NIF `12345678Z`, teléfono `600111222`): `Juan Pérez`, `pérez  JUAN` y `5678` deben dar `X` (verdadero); `Juan García`, vacío (falso).

6. **El precio de la obra.**
    - **Dónde:** el `main` de `ZCL_GOR_TIPOS_DEMO`.
    - **Qué hace:** monta una tabla `tt_presupuestos` con tres presupuestos de la misma obra: uno aprobado de 1210 €, otro no aprobado de 500 € y otro aprobado de 363 €. Escribe `total_obra`. Después, cambia el estado del segundo a aprobado con un *field symbol* y vuelve a escribirlo.
    - **Comprueba:** deben salir **1573.00** y después **2073.00**. Es la regla §11.5 (punto 1): aprobar un presupuesto cambia el precio de la obra.
7. **Investiga.** Reescribe `horas_por_trabajador` con `LOOP AT ... GROUP BY` y `LOOP AT GROUP` (búscalos con **F1**). ¿Qué versión te parece más clara? Deja la que prefieras y explica en un comentario por qué.

## Comprueba tu solución automáticamente (opcional)

Pega [1_4_ltcl_sumas.abap](materiales/tests/1_4_ltcl_sumas.abap) en la pestaña **Test Classes** de `ZCL_GOR_REGLAS`, debajo de las anteriores, y ejecuta con **Ctrl+Shift+F10**. Deben salir **24 tests en verde** (16 + 8).

---

**Siguiente:** [1.5. Tablas de base de datos y ABAP SQL](./1_5_abapSql.md)
