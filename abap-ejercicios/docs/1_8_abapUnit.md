---
title: "1.8. Pruebas con ABAP Unit"
parent: "1. Fundamentos del lenguaje"
nav_order: 8
---

# 1.8. Pruebas con ABAP Unit

{% raw %}
**ABAP Unit** es el marco de pruebas unitarias de ABAP. Lo has usado ya en las secciones anteriores para comprobar tus ejercicios; aquí está explicado.

## Cómo funciona

1. Un test es una **clase local** de la clase que quieres probar, marcada `FOR TESTING`.
2. Cada método `FOR TESTING` es un caso. Dentro llamas al código y comparas con `cl_abap_unit_assert=>assert_equals( act = ... exp = ... )`.
3. El método `setup` (opcional) se ejecuta antes de cada caso.
4. Se escribe en la pestaña **Test Classes** del editor de la clase.
5. Se ejecuta con **Ctrl+Shift+F10** (*Run As → ABAP Unit Test*). Verde = todos pasan.

```abap
CLASS zcl_gor_calculo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS calcular_iva
      IMPORTING iv_base TYPE decfloat34
                iv_tipo TYPE decfloat34
      RETURNING VALUE(rv_iva) TYPE decfloat34.
ENDCLASS.

CLASS zcl_gor_calculo IMPLEMENTATION.
  METHOD calcular_iva.
    rv_iva = iv_base * iv_tipo / 100.
  ENDMETHOD.
ENDCLASS.
```

```abap
CLASS ltcl_calculo DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS iva_21 FOR TESTING.
    METHODS iva_cero FOR TESTING.
ENDCLASS.

CLASS ltcl_calculo IMPLEMENTATION.
  METHOD iva_21.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_calculo=>calcular_iva( iv_base = '100' iv_tipo = '21' )
      exp = CONV decfloat34( '21' ) ).
  ENDMETHOD.

  METHOD iva_cero.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_calculo=>calcular_iva( iv_base = '100' iv_tipo = '0' )
      exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.
ENDCLASS.
```

> **Un detalle.** Cuando pases un literal a un parámetro de tipo `decfloat34`, usa `CONV #( '21' )` para que el tipo se infiera del parámetro. Así evitas errores de tipo.

## Ejercicios

1. **Más casos.** Añade un caso para un tipo de IVA del 10 % y otro para una base con decimales.
2. **Un test que falla.** Cambia a propósito el valor esperado de uno de los tests y observa cómo lo muestra Eclipse.
3. **Antes del código.** Para tu proyecto, escribe primero el test de un cálculo (por ejemplo `HorasTotalesObra`) y luego impleméntalo.


---

**Siguiente:** [1.9. Proyecto: del modelo de Odoo a tablas ABAP](1_9_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_8_abapUnit.md){: .fs-2 }
{% endraw %}
