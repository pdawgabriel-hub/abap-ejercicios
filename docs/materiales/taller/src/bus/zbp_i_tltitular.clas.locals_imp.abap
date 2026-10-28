" Local Types de zbp_i_tltitular

CLASS lhc_titular DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Titular RESULT result.
    " 3.4 Obligatorios y documento sin repetir
    METHODS validarTitular FOR VALIDATE ON SAVE
      IMPORTING keys FOR Titular~validarTitular.
    " 3.7 TIT0001, TIT0002...
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Titular~numerar.
ENDCLASS.


CLASS lhc_titular IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD validarTitular.
    READ ENTITIES OF zi_tltitular IN LOCAL MODE
      ENTITY Titular FIELDS ( RazonSocial Contacto DocumentoId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_filas).

    LOOP AT lt_filas INTO DATA(ls_fila).
      " Limpiar el mensaje anterior de esta validation
      APPEND VALUE #( %tky = ls_fila-%tky %state_area = 'TITULAR' ) TO reported-titular.
      TRY.
          zcl_tl_calculos=>comprobar_relleno( iv_valor = ls_fila-RazonSocial iv_elemento = `RazonSocial` ).
          zcl_tl_calculos=>comprobar_relleno( iv_valor = ls_fila-Contacto    iv_elemento = `Contacto` ).
          " Unicidad: no hay otro titular con el mismo documento (un SELECT, no otra regla)
          IF ls_fila-DocumentoId IS NOT INITIAL.
            SELECT SINGLE FROM ztl_tit FIELDS titular_ref
              WHERE documento_id = @ls_fila-DocumentoId AND titular_uuid <> @ls_fila-TitularUUID
              INTO @DATA(lv_otro).
            IF sy-subrc = 0.
              RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |El documento { ls_fila-DocumentoId } ya es de { lv_otro }|
                                                iv_elemento = `DocumentoId` ).
            ENDIF.
          ENDIF.
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_fila-%tky ) TO failed-titular.
          " Una fila del mismo tipo que las de reported-titular
          DATA ls_mensaje LIKE LINE OF reported-titular.
          ls_mensaje = VALUE #( %tky        = ls_fila-%tky
                                %state_area = 'TITULAR'
                                %msg        = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) ) ).
          " Marcar el campo cuyo nombre trae la excepcion
          ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
          IF sy-subrc = 0.
            <lv_marca> = if_abap_behv=>mk-on.
          ENDIF.
          APPEND ls_mensaje TO reported-titular.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD numerar.
    " Los registros que se estan guardando...
    READ ENTITIES OF zi_tltitular IN LOCAL MODE
      ENTITY Titular FIELDS ( TitularRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevos).
    " ...que todavia no tienen codigo
    DELETE lt_nuevos WHERE TitularRef IS NOT INITIAL.
    CHECK lt_nuevos IS NOT INITIAL.

    " El codigo mas alto guardado: TIT0041 -> 41 (si no hay ninguno, 0)
    SELECT SINGLE FROM ztl_tit FIELDS MAX( titular_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada registro nuevo, el siguiente (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tltitular IN LOCAL MODE
      ENTITY Titular
        UPDATE FIELDS ( TitularRef )
        WITH VALUE #( FOR ls IN lt_nuevos INDEX INTO i
                      ( %tky = ls-%tky
                        TitularRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `TIT`
                                                                   iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.
