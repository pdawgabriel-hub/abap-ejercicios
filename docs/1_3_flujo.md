---
title: "1.3. Control de flujo y funciones de cadena"
parent: "1. Fundamentos del lenguaje"
nav_order: 3
---

# 1.3. Control de flujo y funciones de cadena

{% raw %}
En 1.2 las fórmulas eran cuentas directas. Ahora hay que **decidir**: en el taller, una orden está sin abonar, abonada en parte o liquidada según lo que ha pagado el titular, y su semáforo es verde, ámbar o rojo según el rendimiento ([0.5](0_5_taller.html)). En esta unidad programamos esas decisiones y las funciones de texto que dan nombre a las cosas (los códigos `ORD0001`, los rótulos de los desplegables). Tú harás las de tu ERP: el estado de pago, la salud de la obra y el estado de la ficha de gastos (§11.2), los códigos (§10) y la etiqueta del cliente (§3.1).

## Comparaciones y condiciones

| Operador | Significado | Operador | Significado |
|---|---|---|---|
| `=` | igual | `<>` | distinto |
| `<`, `>` | menor, mayor | `<=`, `>=` | menor o igual, mayor o igual |
| `AND`, `OR`, `NOT` | y, o, no | `IS INITIAL` | vacío (0, texto vacío, fecha `00000000`) |

`IS INITIAL` es la forma de preguntar «¿tiene valor?» en ABAP. Cada tipo tiene su valor inicial: `0` para los números, el texto vacío para `string` y `c`, y `00000000` para las fechas.

## `IF`, `ELSEIF` y `ELSE`

Las condiciones se comprueban en orden y se ejecuta solo la primera rama que se cumple:

```abap
    DATA(lv_importe) = CONV decfloat34( '605' ).
    DATA(lv_abonado) = CONV decfloat34( '300' ).

    IF lv_abonado <= 0.
      out->write( 'sin_abonar' ).
    ELSEIF lv_abonado < lv_importe.
      out->write( 'abonado_parcial' ).
    ELSE.
      out->write( 'liquidado' ).
    ENDIF.
```

El orden importa. Si una orden tiene importe 0 y el titular ya ha pagado algo, no está `sin_abonar` (abonado > 0) ni `abonado_parcial` (abonado no es menor que 0): está `liquidado`, sin escribir ningún caso especial.

## `CASE`

`CASE` compara una variable con varios valores, como el `match` de Python:

```abap
    DATA(lv_semaforo) = CONV zif_tl_tipos=>ty_situacion( 'ambar' ).

    CASE lv_semaforo.
      WHEN 'verde'.
        out->write( 'Orden liquidada' ).
      WHEN 'ambar'.
        out->write( 'En curso, sin perdidas' ).
      WHEN OTHERS.
        out->write( 'Con perdidas' ).
    ENDCASE.
```

## Expresiones condicionales: `COND` y `SWITCH`

Cuando lo que se decide es **un valor** (no qué sentencias ejecutar), es más corto usar una expresión. `COND` es un `IF` que devuelve un valor; `SWITCH`, un `CASE`:

```abap
    DATA(lv_situacion) = COND zif_tl_tipos=>ty_situacion(
                           WHEN lv_abonado <= 0         THEN 'sin_abonar'
                           WHEN lv_abonado < lv_importe THEN 'abonado_parcial'
                           ELSE                              'liquidado' ).

    DATA(lv_texto) = SWITCH string( lv_situacion
                       WHEN 'sin_abonar' THEN 'Pendiente de pago'
                       WHEN 'liquidado'  THEN 'Pagada'
                       ELSE                   'Pagada en parte' ).
```

El tipo entre el nombre de la expresión y el paréntesis es el tipo del resultado. Con `#` lo deduce del destino: `rv_situacion = COND #( ... )`.

## El semáforo del taller

Así quedan en `ZCL_TL_CALCULOS` las decisiones del resumen de la orden. Las constantes están en `ZIF_TL_TIPOS`, con el mismo patrón que `situacion_presupuesto` (1.2):

```abap
  METHOD situacion_cobro.
    rv_situacion = COND #( WHEN iv_abonado <= 0         THEN zif_tl_tipos=>situacion_cobro-sin_abonar
                           WHEN iv_abonado < iv_importe THEN zif_tl_tipos=>situacion_cobro-abonado_parcial
                           ELSE                              zif_tl_tipos=>situacion_cobro-liquidado ).
  ENDMETHOD.

  METHOD semaforo.
    " El orden importa: liquidada pero con perdidas es roja
    rv_color = COND #( WHEN iv_rendimiento < 0
                         THEN zif_tl_tipos=>semaforo-rojo
                       WHEN iv_situacion = zif_tl_tipos=>situacion_cobro-liquidado
                         THEN zif_tl_tipos=>semaforo-verde
                       ELSE zif_tl_tipos=>semaforo-ambar ).
  ENDMETHOD.

  METHOD porcentaje_liquidado.
    IF iv_importe = 0.
      RETURN.                                   " 0 %
    ENDIF.
    DATA(lv_tanto) = round( val = iv_abonado * 100 / iv_importe dec = 1 ).
    rv_tanto = COND #( WHEN lv_tanto > 100 THEN 100
                       WHEN lv_tanto < 0   THEN 0
                       ELSE lv_tanto ).
  ENDMETHOD.
```

`porcentaje_liquidado` **evita** dividir entre cero comprobando antes. Lo verás también en 1.7: es más claro evitar un error que capturarlo.

## Bucles sencillos

`DO n TIMES` repite un bloque `n` veces; `sy-index` dice en qué vuelta estamos. `WHILE` repite mientras se cumpla una condición. Los bucles sobre tablas (`LOOP AT`) llegan en 1.4.

```abap
    DO 3 TIMES.
      out->write( |Orden ORD{ sy-index WIDTH = 4 ALIGN = RIGHT PAD = '0' }| ).
    ENDDO.
```

## Funciones de cadena

Las funciones de texto **devuelven** un valor nuevo y no cambian la variable original:

| Función | Qué hace | Ejemplo → resultado |
|---|---|---|
| `condense( )` | Quita espacios al principio y al final y deja uno solo entre palabras | `` condense( `  Rosa   García ` ) `` → `Rosa García` |
| `to_upper( )`, `to_lower( )` | Mayúsculas, minúsculas | `to_lower( 'GARCÍA' )` → `garcía` |
| `strlen( )` | Longitud | `strlen( 'García' )` → `6` |
| `substring( val = off = len = )` | Trozo del texto (`off` empieza en 0) | `substring( val = 'ORD0007' off = 3 len = 4 )` → `0007` |
| `contains( val = sub = )` | ¿Contiene el texto? (verdadero o falso) | `contains( val = 'Rosa García' sub = 'Gar' )` |
| `replace( val = sub = with = )` | Sustituye | `replace( val = '1234-ABC' sub = '-' with = '' )` → `1234ABC` |

`strlen( 'García' )` vale 6: ABAP cuenta **caracteres**, no bytes. `contains( )` es una *función predicativa*: se usa directamente en un `IF`, como `IF contains( val = lv_nombre sub = 'Gar' ).`

Con ellas se construye el rótulo de un titular para los desplegables:

```abap
  METHOD rotulo_titular.
    " TIT0001 · Talleres Ebro SL [B50123456]; sin razon social, solo el codigo
    rv_rotulo = iv_codigo.
    IF condense( iv_razon_social ) IS INITIAL.
      RETURN.
    ENDIF.
    rv_rotulo = |{ rv_rotulo } · { condense( iv_razon_social ) }|.
    IF iv_documento_id IS NOT INITIAL.
      rv_rotulo = |{ rv_rotulo } [{ iv_documento_id }]|.
    ENDIF.
  ENDMETHOD.
```

## Preparación del entorno de trabajo

Seguimos con `ZIF_GOR_TIPOS`, `ZCL_GOR_REGLAS` y `ZCL_GOR_TIPOS_DEMO` de [1.2](1_2_tipos.html). En esta unidad no se crean objetos nuevos: se amplían los que ya hay.

## Ejercicios

1. **Las constantes de estado.** Añade a `ZIF_GOR_TIPOS` tres grupos de constantes de tipo `ty_estado`, con el valor igual al nombre:

    | Grupo | Constantes |
    |---|---|
    | `estado_pago` | `pendiente`, `parcial`, `pagado` |
    | `salud` | `verde`, `ambar`, `rojo` |
    | `estado_gasto` | `proceso`, `finalizado` |

2. **Los estados de la obra.** Añade a `ZCL_GOR_REGLAS`:

    | Método | Parámetros de entrada | Devuelve | Regla (§11.2) |
    |---|---|---|---|
    | `estado_pago` | `iv_total`, `iv_cobrado` (`ty_importe`) | `rv_estado` (`ty_estado`) | `pendiente` si cobrado ≤ 0; `parcial` si cobrado < total; `pagado` en otro caso |
    | `salud_obra` | `iv_beneficio` (`ty_importe`), `iv_estado_pago` (`ty_estado`) | `rv_salud` (`ty_estado`) | `rojo` si beneficio < 0; `verde` si estado de pago = `pagado`; `ambar` en otro caso |
    | `estado_gasto` | `iv_total_obra`, `iv_ingresos` (`ty_importe`) | `rv_estado` (`ty_estado`) | `finalizado` si `total − ingresos ≤ 0` **y** `ingresos > 0`; si no, `proceso` |

    Usa las constantes del ejercicio 1, nunca los textos sueltos.

3. **El porcentaje cobrado.** Añade `porcentaje_cobrado`, con `iv_total` e `iv_pendiente` (`ty_importe`), que devuelve `rv_porcentaje` (`ty_porcentaje`). Regla (§11.2): 0 si el total es 0; si no, `(total − pendiente) × 100 / total`, redondeado a **1 decimal** y acotado entre 0 y 100. Fíjate en que no recibe lo cobrado, como el del taller, sino **lo pendiente**.
4. **Códigos.** Añade `formatear_codigo`, con `iv_prefijo` (`string`) e `iv_numero` (`i`), que devuelve `rv_codigo` (`ty_codigo`): el prefijo seguido del número con 4 cifras y ceros a la izquierda (`OBR0007`, `PROV0123`; §10). Hazlo con una sola plantilla. En `ZCL_GOR_TIPOS_DEMO`, escribe con un `DO 3 TIMES` los tres primeros códigos de cada uno de los 8 prefijos de [1.1](1_1_classrun.html).
5. **Nombres y etiquetas.** Añade dos métodos con parámetros y resultado de tipo `string`:

    | Método | Parámetros | Resultado (§3.1) |
    |---|---|---|
    | `nombre_completo` | `iv_nombre`, `iv_apellidos` | Los dos separados por un espacio, sin espacios sobrantes si falta alguno: `Juan Pérez López`, o `Juan` |
    | `etiqueta_cliente` | `iv_codigo`, `iv_nombre`, `iv_apellidos`, `iv_nif` | `CLI0001 - Juan Pérez (12345678Z)`. Sin nombre: **solo el código**. El NIF, solo si existe: `CLI0002 - Ana Ruiz` |

    Reutiliza `nombre_completo` en `etiqueta_cliente`. Escribe en la consola la etiqueta de un cliente con todos los datos, otra sin NIF y otra sin nombre.

6. **Investiga.** ¿Qué devuelve `formatear_codigo( iv_prefijo = 'PROV' iv_numero = 12345 )`? `ty_codigo` mide 8 caracteres: mira qué pasa con lo que sobra. Anota en un comentario qué habría que cambiar si la empresa llegara a 10000 proveedores, y en qué otros sitios del proyecto.

## Comprueba tu solución automáticamente (opcional)

Pega [1_3_ltcl_estados.abap](materiales/tests/1_3_ltcl_estados.abap) en la pestaña **Test Classes** de `ZCL_GOR_REGLAS`, **debajo** de la de 1.2, y ejecuta con **Ctrl+Shift+F10**. Deben salir **16 tests en verde**: los 7 de 1.2 y 9 nuevos.

---

**Siguiente:** [1.4. Tablas internas](1_4_tablasInternas.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_3_flujo.md){: .fs-2 }
{% endraw %}
