---
title: "1.4. Tablas internas"
parent: "1. Fundamentos del lenguaje"
nav_order: 4
---

# 1.4. Tablas internas

{% raw %}
> **Cómo ejecutar los ejemplos.** Los ejemplos muestran solo el **contenido del método `main`** de una clase ejecutable. Pégalos dentro de la plantilla de [1.1](1_1_classrun.html) (cambiando el nombre de la clase), activa con **Ctrl+F3** y ejecuta con **F9**.

Una **tabla interna** es una colección en memoria de filas del mismo tipo: el equivalente de una lista de diccionarios en Python o de un recordset de Odoo en memoria. Es la estructura de datos más usada en ABAP. Hay tres tipos:

- **STANDARD**: acceso por posición, la más común.
- **SORTED**: ordenada por clave.
- **HASHED**: acceso rápido por clave única.

```abap
    TYPES: BEGIN OF ty_linea,
             concepto TYPE string,
             importe  TYPE decfloat34,
           END OF ty_linea.
    TYPES tt_lineas TYPE STANDARD TABLE OF ty_linea WITH EMPTY KEY.

    DATA(lt_lineas) = VALUE tt_lineas(
      ( concepto = 'Aceite'  importe = '25.50' )
      ( concepto = 'Filtro'  importe = '12.00' )
      ( concepto = 'Pastillas' importe = '48.90' ) ).

    APPEND VALUE #( concepto = 'Mano de obra' importe = '60.00' ) TO lt_lineas.

    LOOP AT lt_lineas INTO DATA(ls_linea).
      out->write( |{ ls_linea-concepto }: { ls_linea-importe }| ).
    ENDLOOP.

    " Buscar una fila (si no existe, el resultado queda vacio)
    DATA(ls_filtro) = VALUE #( lt_lineas[ concepto = 'Filtro' ] OPTIONAL ).
    out->write( ls_filtro ).

    SORT lt_lineas BY importe DESCENDING.
    DELETE lt_lineas WHERE importe < 20.

    DATA(lv_suma) = REDUCE decfloat34( INIT s = CONV decfloat34( 0 )
                                       FOR l IN lt_lineas
                                       NEXT s = s + l-importe ).
    out->write( |Filas: { lines( lt_lineas ) }, suma: { lv_suma }| ).

    DATA(lt_caras) = VALUE tt_lineas( FOR l IN lt_lineas
                                      WHERE ( importe > 50 ) ( l ) ).
    out->write( lt_caras ).
```

> **Puente a Odoo.** `LOOP AT ... WHERE` es un `filtered()`; `REDUCE` es un `sum()` o `mapped()` con acumulador; `VALUE #( FOR ... )` es una *list comprehension*.

## Ejercicios

1. **Presupuesto en memoria.** Crea una tabla interna con las líneas de un presupuesto de tu proyecto (concepto, cantidad, precio unitario), calcula el subtotal de cada línea y el total.
2. **IVA y orden.** Añade el IVA al total y ordena las líneas de más a menos caras.
3. **HASHED frente a STANDARD.** ¿Cuándo usarías una tabla HASHED? Investiga la diferencia y explícala.
4. **Clase de líneas.** Crea `ZCL_EJ_LINEAS` con este esqueleto e implementa `total` y `ordenar_por_importe`.

```abap
CLASS zcl_ej_lineas DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_linea,
             concepto TYPE string,
             cantidad TYPE i,
             precio   TYPE decfloat34,
           END OF ty_linea.
    TYPES tt_lineas TYPE STANDARD TABLE OF ty_linea WITH EMPTY KEY.

    " Suma de cantidad * precio de todas las lineas
    CLASS-METHODS total
      IMPORTING it_lineas TYPE tt_lineas
      RETURNING VALUE(rv_total) TYPE decfloat34.

    " Devuelve las lineas ordenadas de mayor a menor importe (cantidad * precio)
    CLASS-METHODS ordenar_por_importe
      IMPORTING it_lineas TYPE tt_lineas
      RETURNING VALUE(rt_lineas) TYPE tt_lineas.
ENDCLASS.

CLASS zcl_ej_lineas IMPLEMENTATION.
  METHOD total.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.

  METHOD ordenar_por_importe.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
```

## Comprueba tu solución automáticamente (opcional)

```abap
CLASS ltcl_lineas DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mt_lineas TYPE zcl_ej_lineas=>tt_lineas.
    METHODS setup.
    METHODS total_correcto FOR TESTING.
    METHODS total_tabla_vacia FOR TESTING.
    METHODS orden_descendente FOR TESTING.
ENDCLASS.

CLASS ltcl_lineas IMPLEMENTATION.
  METHOD setup.
    mt_lineas = VALUE #(
      ( concepto = 'Aceite'  cantidad = 1 precio = '5.50' )
      ( concepto = 'Filtros' cantidad = 2 precio = '10.00' )
      ( concepto = 'Bujias'  cantidad = 4 precio = '3.00' ) ).
  ENDMETHOD.

  METHOD total_correcto.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_lineas=>total( mt_lineas )
      exp = CONV decfloat34( '37.5' ) ).
  ENDMETHOD.

  METHOD total_tabla_vacia.
    DATA lt_vacia TYPE zcl_ej_lineas=>tt_lineas.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_lineas=>total( lt_vacia )
      exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.

  METHOD orden_descendente.
    DATA(lt_orden) = zcl_ej_lineas=>ordenar_por_importe( mt_lineas ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_orden ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_orden[ 1 ]-concepto exp = `Filtros` ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_orden[ 3 ]-concepto exp = `Aceite` ).
  ENDMETHOD.
ENDCLASS.
```


---

**Siguiente:** [1.5. Tablas de base de datos y ABAP SQL](1_5_abapSql.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_4_tablasInternas.md){: .fs-2 }
{% endraw %}
