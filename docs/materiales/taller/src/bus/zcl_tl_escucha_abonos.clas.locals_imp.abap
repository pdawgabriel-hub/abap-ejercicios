" lhe = local handler of events (pestana Local Types)
CLASS lhe_abono DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    " Se ejecuta con cada AbonoRegistrado; it_abonos trae los eventos recibidos
    METHODS al_registrar FOR ENTITY EVENT it_abonos FOR Abono~AbonoRegistrado.
ENDCLASS.

CLASS lhe_abono IMPLEMENTATION.
  METHOD al_registrar.
    " Si con este abono la orden queda liquidada, se apunta en el registro de cobros
    LOOP AT it_abonos INTO DATA(ls_abono).
      " La situacion de la orden ya incluye este abono (ya esta guardado)
      SELECT SINGLE FROM zi_tlordenresumen FIELDS SituacionCobro
        WHERE OrdenUUID = @ls_abono-%param-OrdenUUID INTO @DATA(lv_situacion).
      IF lv_situacion = 'liquidado'.
        DATA lv_ahora TYPE timestampl.
        GET TIME STAMP FIELD lv_ahora.
        TRY.
            DATA(ls_log) = VALUE ztl_cobro_log( log_uuid   = cl_system_uuid=>create_uuid_x16_static( )
                                                orden_uuid = ls_abono-%param-OrdenUUID
                                                momento    = lv_ahora
                                                mensaje    = 'Orden liquidada' ).
            INSERT ztl_cobro_log FROM @ls_log.
          CATCH cx_uuid_error.
            " Sin UUID no se apunta; el abono ya esta guardado de todos modos
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
