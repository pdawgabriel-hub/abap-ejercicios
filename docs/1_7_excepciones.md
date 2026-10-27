---
title: "1.7. Excepciones"
parent: "1. Fundamentos del lenguaje"
nav_order: 7
---

# 1.7. Excepciones

{% raw %}
> **Cómo ejecutar los ejemplos.** Los ejemplos muestran solo el **contenido del método `main`** de una clase ejecutable. Pégalos dentro de la plantilla de [1.1](1_1_classrun.html) (cambiando el nombre de la clase), activa con **Ctrl+F3** y ejecuta con **F9**.

Los errores en ABAP moderno se tratan con **excepciones**: clases que heredan de `CX_...`, capturadas con `TRY ... CATCH ... ENDTRY`. Las excepciones del sistema ya existen (división por cero, fila no encontrada…). Cada excepción tiene un texto accesible con `get_text( )`.

```abap
    DATA lv_cero TYPE i VALUE 0.
    DATA lv_n    TYPE i VALUE 10.

    TRY.
        DATA(lv_res) = lv_n / lv_cero.
        out->write( lv_res ).
      CATCH cx_sy_zerodivide INTO DATA(lx_div).
        out->write( lx_div->get_text( ) ).
    ENDTRY.

    TYPES tt_nombres TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA(lt_nombres) = VALUE tt_nombres( ( `Ana` ) ( `Luis` ) ).

    TRY.
        DATA(lv_tercero) = lt_nombres[ 3 ].
        out->write( lv_tercero ).
      CATCH cx_sy_itab_line_not_found INTO DATA(lx_fila).
        out->write( 'No hay tercera fila' ).
    ENDTRY.
```

> **En RAP, los errores de negocio no se lanzan como excepciones.** Se devuelven en `failed` y `reported` ([3.4](3_4_validations.html)). Las excepciones son para errores técnicos.

Puedes declarar tus propias excepciones creando una clase que herede de `CX_STATIC_CHECK` o `CX_DYNAMIC_CHECK` y lanzarlas con `RAISE EXCEPTION NEW ...`.

## Ejercicios

1. **Obra inexistente.** Implementa en `ZCL_EJ_OBRAS` el método `buscar`, que devuelve la obra con un código dado o una estructura vacía si no existe (captura la excepción de fila no encontrada), y `existe`.
2. **Teoría.** Investiga la diferencia entre `CX_STATIC_CHECK` y `CX_DYNAMIC_CHECK`.

```abap
CLASS zcl_ej_obras DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_obra,
             codigo    TYPE string,
             direccion TYPE string,
           END OF ty_obra.
    TYPES tt_obras TYPE STANDARD TABLE OF ty_obra WITH EMPTY KEY.

    " Devuelve la obra con ese codigo. Si no existe, devuelve la estructura vacia
    " (usa TRY ... CATCH cx_sy_itab_line_not_found)
    CLASS-METHODS buscar
      IMPORTING it_obras TYPE tt_obras
                iv_codigo TYPE string
      RETURNING VALUE(rs_obra) TYPE ty_obra.

    " abap_true si existe una obra con ese codigo
    CLASS-METHODS existe
      IMPORTING it_obras TYPE tt_obras
                iv_codigo TYPE string
      RETURNING VALUE(rv_existe) TYPE abap_boolean.
ENDCLASS.

CLASS zcl_ej_obras IMPLEMENTATION.
  METHOD buscar.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.

  METHOD existe.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
```

## Comprueba tu solución automáticamente (opcional)

```abap
CLASS ltcl_obras DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mt_obras TYPE zcl_ej_obras=>tt_obras.
    METHODS setup.
    METHODS encuentra_obra FOR TESTING.
    METHODS obra_inexistente_vacia FOR TESTING.
    METHODS existe_true_y_false FOR TESTING.
ENDCLASS.

CLASS ltcl_obras IMPLEMENTATION.
  METHOD setup.
    mt_obras = VALUE #(
      ( codigo = 'OB-001' direccion = 'Calle Mayor 1' )
      ( codigo = 'OB-002' direccion = 'Plaza Nueva 5' ) ).
  ENDMETHOD.

  METHOD encuentra_obra.
    DATA(ls_obra) = zcl_ej_obras=>buscar( it_obras = mt_obras iv_codigo = 'OB-002' ).
    cl_abap_unit_assert=>assert_equals( act = ls_obra-direccion exp = `Plaza Nueva 5` ).
  ENDMETHOD.

  METHOD obra_inexistente_vacia.
    DATA(ls_obra) = zcl_ej_obras=>buscar( it_obras = mt_obras iv_codigo = 'OB-999' ).
    cl_abap_unit_assert=>assert_initial( ls_obra ).
  ENDMETHOD.

  METHOD existe_true_y_false.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_obras=>existe( it_obras = mt_obras iv_codigo = 'OB-001' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_obras=>existe( it_obras = mt_obras iv_codigo = 'OB-999' )
      exp = abap_false ).
  ENDMETHOD.
ENDCLASS.
```


---

**Siguiente:** [1.8. Pruebas con ABAP Unit](1_8_abapUnit.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_7_excepciones.md){: .fs-2 }
{% endraw %}
