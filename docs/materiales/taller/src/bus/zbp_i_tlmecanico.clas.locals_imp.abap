" Local Types de zbp_i_tlmecanico

CLASS lhc_mecanico DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Mecanico RESULT result.
    METHODS valoresIniciales FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Mecanico~valoresIniciales.
    METHODS validarTarifa FOR VALIDATE ON SAVE
      IMPORTING keys FOR Mecanico~validarTarifa.
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Mecanico~numerar.
ENDCLASS.


CLASS lhc_mecanico IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD valoresIniciales.
    READ ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Mecanico FIELDS ( TarifaBase ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mecanicos).
    " Solo los que no traen tarifa: 30 euros/h
    DELETE lt_mecanicos WHERE TarifaBase IS NOT INITIAL.
    CHECK lt_mecanicos IS NOT INITIAL.
    MODIFY ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Mecanico UPDATE FIELDS ( TarifaBase )
      WITH VALUE #( FOR ls IN lt_mecanicos ( %tky = ls-%tky TarifaBase = 30 ) ).
  ENDMETHOD.

  METHOD validarTarifa.
    READ ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Mecanico FIELDS ( TarifaBase ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_filas).

    LOOP AT lt_filas INTO DATA(ls_fila).
      " Limpiar el mensaje anterior de esta validation
      APPEND VALUE #( %tky = ls_fila-%tky %state_area = 'TARIFA' ) TO reported-mecanico.
      TRY.
          zcl_tl_calculos=>comprobar_no_negativo( iv_valor = CONV #( ls_fila-TarifaBase ) iv_elemento = `TarifaBase` ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_fila-%tky ) TO failed-mecanico.
          " Una fila del mismo tipo que las de reported-mecanico
          DATA ls_mensaje LIKE LINE OF reported-mecanico.
          ls_mensaje = VALUE #( %tky        = ls_fila-%tky
                                %state_area = 'TARIFA'
                                %msg        = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) ) ).
          " Marcar el campo cuyo nombre trae la excepcion
          ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
          IF sy-subrc = 0.
            <lv_marca> = if_abap_behv=>mk-on.
          ENDIF.
          APPEND ls_mensaje TO reported-mecanico.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD numerar.
    " Los registros que se estan guardando...
    READ ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Mecanico FIELDS ( MecanicoRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevos).
    " ...que todavia no tienen codigo
    DELETE lt_nuevos WHERE MecanicoRef IS NOT INITIAL.
    CHECK lt_nuevos IS NOT INITIAL.

    " El codigo mas alto guardado: MEC0041 -> 41 (si no hay ninguno, 0)
    SELECT SINGLE FROM ztl_mec FIELDS MAX( mecanico_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada registro nuevo, el siguiente (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Mecanico
        UPDATE FIELDS ( MecanicoRef )
        WITH VALUE #( FOR ls IN lt_nuevos INDEX INTO i
                      ( %tky = ls-%tky
                        MecanicoRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `MEC`
                                                                   iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_ausencia DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calcularJornadas FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Ausencia~calcularJornadas.
    METHODS validarPeriodo FOR VALIDATE ON SAVE
      IMPORTING keys FOR Ausencia~validarPeriodo.
ENDCLASS.


CLASS lhc_ausencia IMPLEMENTATION.

  METHOD calcularJornadas.
    READ ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Ausencia FIELDS ( Desde Hasta ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ausencias).
    " jornadas = hasta - desde + 1 (0 si falta una fecha), con la clase de reglas
    MODIFY ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Ausencia UPDATE FIELDS ( Jornadas )
      WITH VALUE #( FOR ls IN lt_ausencias
                    ( %tky     = ls-%tky
                      Jornadas = zcl_tl_calculos=>jornadas_ausencia( iv_desde = ls-Desde iv_hasta = ls-Hasta ) ) ).
  ENDMETHOD.

  METHOD validarPeriodo.
    READ ENTITIES OF zi_tlmecanico IN LOCAL MODE
      ENTITY Ausencia FIELDS ( Desde Hasta MecanicoUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_filas).

    LOOP AT lt_filas INTO DATA(ls_fila).
      " Limpiar el mensaje anterior de esta validation
      APPEND VALUE #( %tky = ls_fila-%tky %state_area = 'PERIODO' ) TO reported-ausencia.
      TRY.
          zcl_tl_calculos=>comprobar_periodo( iv_desde = ls_fila-Desde iv_hasta = ls_fila-Hasta ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_fila-%tky ) TO failed-ausencia.
          " Una fila del mismo tipo que las de reported-ausencia
          DATA ls_mensaje LIKE LINE OF reported-ausencia.
          ls_mensaje = VALUE #( %tky        = ls_fila-%tky
                                %state_area = 'PERIODO'
                                %msg        = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) ) ).
          " En un hijo, %path dice a que padre pertenece el mensaje
          ls_mensaje-%path = VALUE #( mecanico-%is_draft = ls_fila-%is_draft
                                      mecanico-MecanicoUUID = ls_fila-MecanicoUUID ).
          " Marcar el campo cuyo nombre trae la excepcion
          ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
          IF sy-subrc = 0.
            <lv_marca> = if_abap_behv=>mk-on.
          ENDIF.
          APPEND ls_mensaje TO reported-ausencia.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
