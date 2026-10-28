" Local Types de zbp_i_tldistribuidor

CLASS lhc_distribuidor DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Distribuidor RESULT result.
    METHODS calcularBruto FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Distribuidor~calcularBruto.
    METHODS validarImpuesto FOR VALIDATE ON SAVE
      IMPORTING keys FOR Distribuidor~validarImpuesto.
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Distribuidor~numerar.
ENDCLASS.


CLASS lhc_distribuidor IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD calcularBruto.
    READ ENTITIES OF zi_tldistribuidor IN LOCAL MODE
      ENTITY Distribuidor FIELDS ( Neto Impuesto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_distribuidores).
    " bruto = neto + cuota: la misma formula que el importe de un presupuesto
    MODIFY ENTITIES OF zi_tldistribuidor IN LOCAL MODE
      ENTITY Distribuidor UPDATE FIELDS ( Bruto )
      WITH VALUE #( FOR ls IN lt_distribuidores
                    ( %tky  = ls-%tky
                      Bruto = zcl_tl_calculos=>importe_presupuesto( iv_neto     = CONV #( ls-Neto )
                                                                    iv_impuesto = CONV #( ls-Impuesto ) ) ) ).
  ENDMETHOD.

  METHOD validarImpuesto.
    READ ENTITIES OF zi_tldistribuidor IN LOCAL MODE
      ENTITY Distribuidor FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_filas).

    LOOP AT lt_filas INTO DATA(ls_fila).
      " Limpiar el mensaje anterior de esta validation
      APPEND VALUE #( %tky = ls_fila-%tky %state_area = 'IMPUESTO' ) TO reported-distribuidor.
      TRY.
          zcl_tl_calculos=>comprobar_impuesto( CONV #( ls_fila-Impuesto ) ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_fila-%tky ) TO failed-distribuidor.
          " Una fila del mismo tipo que las de reported-distribuidor
          DATA ls_mensaje LIKE LINE OF reported-distribuidor.
          ls_mensaje = VALUE #( %tky        = ls_fila-%tky
                                %state_area = 'IMPUESTO'
                                %msg        = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) ) ).
          " Marcar el campo cuyo nombre trae la excepcion
          ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
          IF sy-subrc = 0.
            <lv_marca> = if_abap_behv=>mk-on.
          ENDIF.
          APPEND ls_mensaje TO reported-distribuidor.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD numerar.
    " Los registros que se estan guardando...
    READ ENTITIES OF zi_tldistribuidor IN LOCAL MODE
      ENTITY Distribuidor FIELDS ( DistribuidorRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevos).
    " ...que todavia no tienen codigo
    DELETE lt_nuevos WHERE DistribuidorRef IS NOT INITIAL.
    CHECK lt_nuevos IS NOT INITIAL.

    " El codigo mas alto guardado: DIS0041 -> 41 (si no hay ninguno, 0)
    SELECT SINGLE FROM ztl_dis FIELDS MAX( distribuidor_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada registro nuevo, el siguiente (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tldistribuidor IN LOCAL MODE
      ENTITY Distribuidor
        UPDATE FIELDS ( DistribuidorRef )
        WITH VALUE #( FOR ls IN lt_nuevos INDEX INTO i
                      ( %tky = ls-%tky
                        DistribuidorRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `DIS`
                                                                   iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.
