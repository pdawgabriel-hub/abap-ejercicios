" Un presupuesto como objeto: sus partidas y su situacion (1.6)
CLASS zcl_tl_presupuesto DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_impuesto TYPE zif_tl_tipos=>ty_tanto DEFAULT 21.
    METHODS add_partida
      IMPORTING is_partida TYPE zif_tl_tipos=>ty_partida.
    METHODS neto
      RETURNING VALUE(rv_neto) TYPE zif_tl_tipos=>ty_euros.
    METHODS cuota
      RETURNING VALUE(rv_cuota) TYPE zif_tl_tipos=>ty_euros.
    METHODS importe
      RETURNING VALUE(rv_importe) TYPE zif_tl_tipos=>ty_euros.
    METHODS aceptar.
    METHODS esta_aceptado
      RETURNING VALUE(rv_aceptado) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mt_partidas TYPE zif_tl_tipos=>tt_partidas.
    DATA mv_impuesto TYPE zif_tl_tipos=>ty_tanto.
    " Atributo con valor inicial: todo presupuesto nuevo empieza en borrador
    DATA mv_situacion TYPE zif_tl_tipos=>ty_situacion
                      VALUE zif_tl_tipos=>situacion_presupuesto-borrador.
ENDCLASS.

CLASS zcl_tl_presupuesto IMPLEMENTATION.
  METHOD constructor.
    mv_impuesto = iv_impuesto.
  ENDMETHOD.

  METHOD add_partida.
    APPEND is_partida TO mt_partidas.
  ENDMETHOD.

  " Las cuentas, con la clase de reglas: el objeto solo guarda los datos
  METHOD neto.
    rv_neto = zcl_tl_calculos=>neto_presupuesto( mt_partidas ).
  ENDMETHOD.

  METHOD cuota.
    rv_cuota = zcl_tl_calculos=>cuota_impuesto( iv_neto = neto( ) iv_impuesto = mv_impuesto ).
  ENDMETHOD.

  METHOD importe.
    rv_importe = zcl_tl_calculos=>importe_presupuesto( iv_neto = neto( ) iv_impuesto = mv_impuesto ).
  ENDMETHOD.

  METHOD aceptar.
    mv_situacion = zif_tl_tipos=>situacion_presupuesto-aceptado.
  ENDMETHOD.

  METHOD esta_aceptado.
    " xsdbool convierte la condicion en abap_true o abap_false
    rv_aceptado = xsdbool( mv_situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ).
  ENDMETHOD.
ENDCLASS.
