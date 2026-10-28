" Carga en ztl_festivo los festivos del anio, nacionales y de Aragon (6.5). Una vez al anio.
CLASS zcl_tl_cargar_festivos DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_tl_cargar_festivos IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Los 4 primeros caracteres de la fecha AAAAMMDD
    DATA(lv_hoy) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_anio) = CONV i( lv_hoy(4) ).
    TRY.
        DATA(lt_festivos) = zcl_tl_festivos=>de_comunidad( it_festivos  = zcl_tl_festivos=>del_anio( lv_anio )
                                                           iv_comunidad = `ES-AR` ).
      CATCH cx_static_check INTO DATA(lx_error).
        out->write( |No se han podido leer los festivos: { lx_error->get_text( ) }| ).
        RETURN.
    ENDTRY.

    " La caché: se vacia el anio y se vuelve a llenar
    DATA(lv_desde) = CONV d( |{ lv_anio }0101| ).
    DATA(lv_hasta) = CONV d( |{ lv_anio }1231| ).
    DELETE FROM ztl_festivo WHERE fecha BETWEEN @lv_desde AND @lv_hasta.

    " "2026-01-01" -> 20260101: se quitan los guiones
    DATA lt_tabla TYPE STANDARD TABLE OF ztl_festivo WITH EMPTY KEY.
    lt_tabla = VALUE #( FOR ls IN lt_festivos
                        ( fecha  = CONV d( replace( val = ls-date sub = `-` with = `` occ = 0 ) )
                          nombre = ls-local_name ) ).
    SORT lt_tabla BY fecha.
    DELETE ADJACENT DUPLICATES FROM lt_tabla COMPARING fecha.   " dos festivos el mismo dia: uno
    INSERT ztl_festivo FROM TABLE @lt_tabla.
    out->write( |Festivos de { lv_anio } cargados: { sy-dbcnt }| ).
    out->write( lt_tabla ).
  ENDMETHOD.
ENDCLASS.
