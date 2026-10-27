---
title: "1.2. Variables, tipos de datos y plantillas de texto"
parent: "1. Fundamentos del lenguaje"
nav_order: 2
---

# 1.2. Variables, tipos de datos y plantillas de texto

{% raw %}
> **Cómo ejecutar los ejemplos.** Los ejemplos muestran solo el **contenido del método `main`** de una clase ejecutable. Pégalos dentro de la plantilla de [1.1](1_1_classrun.html) (cambiando el nombre de la clase), activa con **Ctrl+F3** y ejecuta con **F9**.

## Tipos básicos

| Tipo ABAP | Para qué sirve | Ejemplo |
|---|---|---|
| `i` | Entero | `DATA lv_cant TYPE i VALUE 3.` |
| `string` | Texto de longitud variable | `DATA lv_txt TYPE string VALUE 'hola'.` |
| `c LENGTH n` | Texto de longitud fija (típico en tablas) | `DATA lv_mat TYPE c LENGTH 10.` |
| `decfloat34` | Número decimal (importes, porcentajes) | `DATA lv_p TYPE decfloat34 VALUE '12.50'.` |
| `d` | Fecha (AAAAMMDD) | `DATA lv_fecha TYPE d.` |
| `abap_bool` | Verdadero/falso | `DATA lv_ok TYPE abap_bool VALUE abap_true.` |

**Declaraciones inline**: `DATA(lv_x) = expresion.` declara la variable y le da el tipo de la expresión. Es la forma habitual en código moderno. Una **estructura** agrupa varios campos y se construye con `VALUE #( ... )`.

```abap
    CONSTANTS c_iva TYPE decfloat34 VALUE '0.21'.

    DATA(lv_cantidad) = 3.
    DATA(lv_precio)   = CONV decfloat34( '12.50' ).
    DATA(lv_base)     = lv_cantidad * lv_precio.

    out->write( |Base: { lv_base DECIMALS = 2 }| ).
    out->write( |Total con IVA: { lv_base * ( 1 + c_iva ) DECIMALS = 2 }| ).

    TYPES: BEGIN OF ty_vehiculo,
             matricula TYPE c LENGTH 10,
             marca     TYPE string,
             anio      TYPE i,
           END OF ty_vehiculo.

    DATA ls_vehiculo TYPE ty_vehiculo.
    ls_vehiculo = VALUE #( matricula = '1234ABC' marca = 'Seat' anio = 2015 ).

    out->write( ls_vehiculo ).
    out->write( |Matricula: { ls_vehiculo-matricula }, marca: { ls_vehiculo-marca }| ).
```

> **Puente a Odoo.** Una estructura es como un diccionario Python con campos tipados. Las plantillas `|...{ var }...|` son los f-strings de Python.

## Ejercicios

1. **Estructura de una obra.** Define una estructura con 4 campos de una entidad de tu proyecto (código, dirección, presupuesto, fecha de inicio), asígnale valores y escríbela en la consola.
2. **IVA.** Calcula el IVA de un importe y muestra el resultado con 2 decimales. ¿Por qué se usa `decfloat34` y no `i` para importes?
3. **Total con IVA.** Crea la clase `ZCL_EJ_PRECIOS` con el esqueleto de abajo e implementa `total_con_iva`.

```abap
CLASS zcl_ej_precios DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Devuelve cantidad * precio * ( 1 + iva ). El iva va como 0.21 para el 21%
    CLASS-METHODS total_con_iva
      IMPORTING iv_cantidad TYPE i
                iv_precio   TYPE decfloat34
                iv_iva      TYPE decfloat34
      RETURNING VALUE(rv_total) TYPE decfloat34.
ENDCLASS.

CLASS zcl_ej_precios IMPLEMENTATION.
  METHOD total_con_iva.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
```

## Comprueba tu solución automáticamente (opcional)

Abre tu clase y, en la pestaña inferior **Test Classes**, pega este test. Ejecútalo con **Ctrl+Shift+F10** (*Run As → ABAP Unit Test*). Al terminar deben salir en verde los dos tests. Más detalles en [1.8](1_8_abapUnit.html).

```abap
CLASS ltcl_precios DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS tres_unidades_con_iva FOR TESTING.
    METHODS sin_iva FOR TESTING.
ENDCLASS.

CLASS ltcl_precios IMPLEMENTATION.
  METHOD tres_unidades_con_iva.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_precios=>total_con_iva( iv_cantidad = 3
                                           iv_precio   = CONV #( '12.50' )
                                           iv_iva      = CONV #( '0.21' ) )
      exp = CONV decfloat34( '45.375' ) ).
  ENDMETHOD.

  METHOD sin_iva.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_precios=>total_con_iva( iv_cantidad = 2
                                           iv_precio   = CONV #( '10' )
                                           iv_iva      = CONV #( '0' ) )
      exp = CONV decfloat34( '20' ) ).
  ENDMETHOD.
ENDCLASS.
```


---

**Siguiente:** [1.3. Control de flujo y funciones de cadena](1_3_flujo.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_2_tipos.md){: .fs-2 }
{% endraw %}
