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
