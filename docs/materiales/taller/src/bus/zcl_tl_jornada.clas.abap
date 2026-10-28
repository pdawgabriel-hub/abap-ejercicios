" Un registro de jornada: sus tramos de trabajo (1.6; la comprobacion del tiempo, 1.7)
CLASS zcl_tl_jornada DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Anota un tramo copiando la tarifa que tiene el mecanico AHORA
    METHODS add_tramo
      IMPORTING io_mecanico TYPE REF TO zcl_tl_mecanico
                iv_tiempo   TYPE zif_tl_tipos=>ty_tiempo
      RAISING   zcx_tl_aviso.
    METHODS coste
      RETURNING VALUE(rv_coste) TYPE zif_tl_tipos=>ty_euros.
    METHODS tramos
      RETURNING VALUE(rt_tramos) TYPE zif_tl_tipos=>tt_tramos.
  PRIVATE SECTION.
    DATA mt_tramos TYPE zif_tl_tipos=>tt_tramos.
ENDCLASS.

CLASS zcl_tl_jornada IMPLEMENTATION.
  METHOD add_tramo.
    zcl_tl_calculos=>comprobar_tiempo( iv_tiempo ).    " si falla, no se anade nada
    APPEND VALUE #( mecanico        = io_mecanico->ref( )
                    tiempo          = iv_tiempo
                    tarifa_aplicada = io_mecanico->tarifa( ) ) TO mt_tramos.
  ENDMETHOD.

  METHOD coste.
    " No repite la formula: la de la clase de reglas
    rv_coste = zcl_tl_calculos=>coste_jornada( mt_tramos ).
  ENDMETHOD.

  METHOD tramos.
    rt_tramos = mt_tramos.
  ENDMETHOD.
ENDCLASS.
