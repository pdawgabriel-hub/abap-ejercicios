" Local Types de zbp_i_tlalbaran

CLASS lhc_albaran DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Albaran RESULT result.
    METHODS validarImporte FOR VALIDATE ON SAVE
      IMPORTING keys FOR Albaran~validarImporte.
ENDCLASS.


CLASS lhc_albaran IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD validarImporte.
    READ ENTITIES OF zi_tlalbaran IN LOCAL MODE
      ENTITY Albaran FIELDS ( ImporteNeto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_filas).

    LOOP AT lt_filas INTO DATA(ls_fila).
      " Limpiar el mensaje anterior de esta validation
      APPEND VALUE #( %tky = ls_fila-%tky %state_area = 'IMPORTE' ) TO reported-albaran.
      TRY.
          zcl_tl_calculos=>comprobar_importe_positivo( CONV #( ls_fila-ImporteNeto ) ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_fila-%tky ) TO failed-albaran.
          " Una fila del mismo tipo que las de reported-albaran
          DATA ls_mensaje LIKE LINE OF reported-albaran.
          ls_mensaje = VALUE #( %tky        = ls_fila-%tky
                                %state_area = 'IMPORTE'
                                %msg        = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) ) ).
          " Marcar el campo cuyo nombre trae la excepcion
          ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
          IF sy-subrc = 0.
            <lv_marca> = if_abap_behv=>mk-on.
          ENDIF.
          APPEND ls_mensaje TO reported-albaran.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
