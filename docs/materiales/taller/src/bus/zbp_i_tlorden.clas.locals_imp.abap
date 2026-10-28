" Local Types de zbp_i_tlorden

CLASS lhc_orden DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " 6.1 Permisos: borrar solo el jefe de taller (global) y hojas cerradas solo el jefe (instancia)
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Orden RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Orden RESULT result.

    " 3.5 Boton Eliminar desactivado si la orden tiene abonos
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Orden RESULT result.
    " 3.5 Comprobacion antes de borrar (tambien cuando se borra con EML)
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE Orden.

    " 3.3 Crear la hoja de costes con la orden
    METHODS crearHojaCostes FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Orden~crearHojaCostes.
    " 3.4 Formato de la matricula
    METHODS validarMatricula FOR VALIDATE ON SAVE
      IMPORTING keys FOR Orden~validarMatricula.
    " 3.7 ORD0001...
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Orden~numerar.

    " Una lista de UUID
    TYPES tt_uuids TYPE STANDARD TABLE OF sysuuid_x16 WITH EMPTY KEY.
    " Las ordenes (de las pedidas) que tienen algun abono
    METHODS ordenes_con_abonos
      IMPORTING it_ordenes       TYPE tt_uuids
      RETURNING VALUE(rt_abonos) TYPE tt_uuids.
ENDCLASS.


CLASS lhc_orden IMPLEMENTATION.

  METHOD get_global_authorizations.
    " Por defecto, todo permitido; borrar, solo con la actividad 06
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).

    " Solo si en esta llamada se pregunta por borrar
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      " Tiene el usuario la actividad 06 (borrar) del objeto ZTL_TALLER?
      AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '06'.
      IF sy-subrc <> 0.                                " no la tiene
        result-%delete = if_abap_behv=>auth-unauthorized.
        " Mensaje general (%global), no de una orden concreta
        APPEND VALUE #( %msg    = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text     = 'Solo el jefe de taller puede borrar ordenes' )
                        %global = if_abap_behv=>mk-on ) TO reported-orden.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    " Hojas cerradas de las ordenes pedidas
    SELECT FROM zi_tlordenresumen FIELDS OrdenUUID
      FOR ALL ENTRIES IN @keys WHERE OrdenUUID = @keys-OrdenUUID AND EstadoHoja = 'cerrada'
      INTO TABLE @DATA(lt_cerradas).

    AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '70'.    " 70 = administrar
    DATA(lv_es_jefe) = xsdbool( sy-subrc = 0 ).     " abap_true si tiene la actividad

    " Para cada orden pedida: bloqueada si esta cerrada y el usuario no es jefe
    result = VALUE #( FOR k IN keys
      LET lv_bloqueada = xsdbool( line_exists( lt_cerradas[ OrdenUUID = k-OrdenUUID ] )
                                  AND lv_es_jefe = abap_false ) IN
      ( %tky         = k-%tky
        %update      = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed )
        %delete      = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed )
        %action-Edit = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed ) ) ).
  ENDMETHOD.

  METHOD ordenes_con_abonos.
    CHECK it_ordenes IS NOT INITIAL.
    SELECT DISTINCT orden_uuid FROM ztl_abo
      FOR ALL ENTRIES IN @it_ordenes WHERE orden_uuid = @it_ordenes-table_line
      INTO TABLE @rt_abonos.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA(lt_con_abonos) = ordenes_con_abonos( VALUE #( FOR k IN keys ( k-OrdenUUID ) ) ).
    " Una orden con abonos no se puede borrar: el boton sale desactivado
    result = VALUE #( FOR k IN keys
      ( %tky    = k-%tky
        %delete = COND #( WHEN line_exists( lt_con_abonos[ table_line = k-OrdenUUID ] )
                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    " Que ordenes de las que se quieren borrar tienen abonos (una sola consulta)
    DATA(lt_con_abonos) = ordenes_con_abonos( VALUE #( FOR k IN keys ( k-OrdenUUID ) ) ).

    LOOP AT keys INTO DATA(ls_key).
      " Sin abonos: se puede borrar, siguiente
      CHECK line_exists( lt_con_abonos[ table_line = ls_key-OrdenUUID ] ).
      APPEND VALUE #( %tky = ls_key-%tky ) TO failed-orden.
      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'No se puede borrar una orden con abonos' ) )
             TO reported-orden.
    ENDLOOP.
  ENDMETHOD.

  METHOD crearHojaCostes.
    " Las hojas que ya tengan estas ordenes (normalmente ninguna)
    READ ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden BY \_HojaCostes FIELDS ( HojaUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hojas).

    " Tipo de la tabla para crear hijos por la composicion _HojaCostes
    DATA lt_crear TYPE TABLE FOR CREATE zi_tlorden\\Orden\_HojaCostes.
    LOOP AT keys INTO DATA(ls_key).
      " Nunca dos hojas para la misma orden
      CHECK NOT line_exists( lt_hojas[ OrdenUUID = ls_key-OrdenUUID ] ).
      APPEND VALUE #( %tky    = ls_key-%tky
                      %target = VALUE #( ( %cid          = |HOJA{ sy-tabix }|
                                           %is_draft     = ls_key-%is_draft
                                           FechaEntrada  = cl_abap_context_info=>get_system_date( )
                                           Garantia      = abap_false ) ) ) TO lt_crear.
    ENDLOOP.
    CHECK lt_crear IS NOT INITIAL.                    " nada que crear

    MODIFY ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden CREATE BY \_HojaCostes FIELDS ( FechaEntrada Garantia ) WITH lt_crear.
  ENDMETHOD.

  METHOD validarMatricula.
    READ ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden FIELDS ( Matricula ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ordenes).

    LOOP AT lt_ordenes INTO DATA(ls_orden).
      APPEND VALUE #( %tky = ls_orden-%tky %state_area = 'MATRICULA' ) TO reported-orden.
      TRY.
          zcl_tl_calculos=>comprobar_matricula( ls_orden-Matricula ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_orden-%tky ) TO failed-orden.
          APPEND VALUE #( %tky               = ls_orden-%tky
                          %state_area        = 'MATRICULA'
                          %msg               = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = lx_aviso->get_text( ) )
                          %element-Matricula = if_abap_behv=>mk-on ) TO reported-orden.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD numerar.
    READ ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden FIELDS ( OrdenRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevas).
    DELETE lt_nuevas WHERE OrdenRef IS NOT INITIAL.
    CHECK lt_nuevas IS NOT INITIAL.

    SELECT SINGLE FROM ztl_orden FIELDS MAX( orden_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    MODIFY ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden UPDATE FIELDS ( OrdenRef )
      WITH VALUE #( FOR ls IN lt_nuevas INDEX INTO i
                    ( %tky     = ls-%tky
                      OrdenRef = zcl_tl_calculos=>componer_codigo( iv_serie = `ORD` iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_hojacostes DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " 3.7 HCO0001...: la hoja tiene su propio codigo
    METHODS numerarHoja FOR DETERMINE ON SAVE
      IMPORTING keys FOR HojaCostes~numerarHoja.
ENDCLASS.


CLASS lhc_hojacostes IMPLEMENTATION.

  METHOD numerarHoja.
    READ ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY HojaCostes FIELDS ( HojaRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevas).
    DELETE lt_nuevas WHERE HojaRef IS NOT INITIAL.
    CHECK lt_nuevas IS NOT INITIAL.

    SELECT SINGLE FROM ztl_hco FIELDS MAX( hoja_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    MODIFY ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY HojaCostes UPDATE FIELDS ( HojaRef )
      WITH VALUE #( FOR ls IN lt_nuevas INDEX INTO i
                    ( %tky    = ls-%tky
                      HojaRef = zcl_tl_calculos=>componer_codigo( iv_serie = `HCO` iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.


" lsc = local saver class: interviene en el momento de guardar (3.5)
CLASS lsc_zi_tlorden DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.


CLASS lsc_zi_tlorden IMPLEMENTATION.

  METHOD save_modified.
    DATA lv_sin_orden TYPE sysuuid_x16.               " UUID vacio

    " delete-orden: las ordenes que se acaban de borrar
    LOOP AT delete-orden INTO DATA(ls_orden).
      " Jornadas con sus tramos (primero los tramos)
      DELETE FROM ztl_jor_tra WHERE jornada_uuid IN ( SELECT jornada_uuid FROM ztl_jor
                                                      WHERE orden_uuid = @ls_orden-OrdenUUID ).
      DELETE FROM ztl_jor WHERE orden_uuid = @ls_orden-OrdenUUID.
      " Albaranes y facturas
      DELETE FROM ztl_alb WHERE orden_uuid = @ls_orden-OrdenUUID.
      DELETE FROM ztl_fac WHERE orden_uuid = @ls_orden-OrdenUUID.
      " Los presupuestos se conservan, sin orden
      UPDATE ztl_prs SET orden_uuid = @lv_sin_orden WHERE orden_uuid = @ls_orden-OrdenUUID.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
