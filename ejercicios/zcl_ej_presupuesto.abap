CLASS zcl_ej_presupuesto DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " iv_iva va como 0.21 para el 21%
    METHODS constructor
      IMPORTING iv_iva TYPE decfloat34.
    METHODS add_linea
      IMPORTING iv_concepto TYPE string
                iv_importe  TYPE decfloat34.
    METHODS subtotal
      RETURNING VALUE(rv_subtotal) TYPE decfloat34.
    METHODS total
      RETURNING VALUE(rv_total) TYPE decfloat34.
  PRIVATE SECTION.
    DATA mv_iva TYPE decfloat34.
    " TODO: anade aqui los atributos que necesites
ENDCLASS.

CLASS zcl_ej_presupuesto IMPLEMENTATION.
  METHOD constructor.
    " TODO
  ENDMETHOD.

  METHOD add_linea.
    " TODO
  ENDMETHOD.

  METHOD subtotal.
    " TODO
  ENDMETHOD.

  METHOD total.
    " TODO
  ENDMETHOD.
ENDCLASS.
