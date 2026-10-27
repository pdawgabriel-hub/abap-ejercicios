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
