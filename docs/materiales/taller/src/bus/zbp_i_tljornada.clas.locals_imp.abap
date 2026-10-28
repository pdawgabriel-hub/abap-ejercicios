" Local Types de zbp_i_tljornada

CLASS lhc_jornada DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Jornada RESULT result.
    " 3.3 Tiempo y coste totales a partir de los tramos
    METHODS recalcularTotales FOR MODIFY
      IMPORTING keys FOR ACTION Jornada~recalcularTotales.
    METHODS totalesAlGuardar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Jornada~totalesAlGuardar.
    " 6.5 Aviso si el dia es festivo (no impide guardar)
    METHODS avisarFestivo FOR VALIDATE ON SAVE
      IMPORTING keys FOR Jornada~avisarFestivo.
ENDCLASS.


CLASS lhc_jornada IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD recalcularTotales.
    " Las jornadas y, por la composicion, sus tramos
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Jornada FIELDS ( JornadaUUID ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_jornadas)
      ENTITY Jornada BY \_Tramos FIELDS ( Tiempo TarifaAplicada ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_tramos).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tljornada\\Jornada.
    LOOP AT lt_jornadas INTO DATA(ls_jornada).
      " Los tramos de esta jornada, en el formato de la clase de reglas
      DATA(lt_calculo) = VALUE zif_tl_tipos=>tt_tramos(
        FOR t IN lt_tramos WHERE ( JornadaUUID = ls_jornada-JornadaUUID )
        ( tiempo = t-Tiempo tarifa_aplicada = t-TarifaAplicada ) ).
      APPEND VALUE #( %tky        = ls_jornada-%tky
                      TiempoTotal = REDUCE zif_tl_tipos=>ty_tiempo( INIT s = CONV zif_tl_tipos=>ty_tiempo( 0 )
                                                                    FOR c IN lt_calculo NEXT s = s + c-tiempo )
                      CosteTotal  = zcl_tl_calculos=>coste_jornada( lt_calculo ) ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Jornada UPDATE FIELDS ( TiempoTotal CosteTotal ) WITH lt_update.
  ENDMETHOD.

  METHOD totalesAlGuardar.
    MODIFY ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Jornada EXECUTE recalcularTotales FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD avisarFestivo.
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Jornada FIELDS ( Dia ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_jornadas).

    LOOP AT lt_jornadas INTO DATA(ls_jornada).
      APPEND VALUE #( %tky = ls_jornada-%tky %state_area = 'FESTIVO' ) TO reported-jornada.
      " Se consulta la copia local, no la API
      SELECT SINGLE nombre FROM ztl_festivo WHERE fecha = @ls_jornada-Dia INTO @DATA(lv_festivo).
      IF sy-subrc = 0.                                 " es festivo
        " Solo reported (no failed): severidad aviso, la jornada se guarda igual
        APPEND VALUE #( %tky         = ls_jornada-%tky
                        %state_area  = 'FESTIVO'
                        %msg         = new_message_with_text(
                                         severity = if_abap_behv_message=>severity-warning
                                         text     = |El { ls_jornada-Dia DATE = USER } es festivo ({ lv_festivo })| )
                        %element-Dia = if_abap_behv=>mk-on ) TO reported-jornada.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_tramo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " 3.3 La tarifa del mecanico se COPIA al elegirlo: si despues sube, el tramo no cambia
    METHODS copiarTarifa FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Tramo~copiarTarifa.
    " 3.3 Coste del tramo y totales de su jornada
    METHODS calcularTramo FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Tramo~calcularTramo.
    " 3.4 Entre 0 y 10 horas
    METHODS validarTiempo FOR VALIDATE ON SAVE
      IMPORTING keys FOR Tramo~validarTiempo.
ENDCLASS.


CLASS lhc_tramo IMPLEMENTATION.

  METHOD copiarTarifa.
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo FIELDS ( MecanicoUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tramos).
    DELETE lt_tramos WHERE MecanicoUUID IS INITIAL.
    CHECK lt_tramos IS NOT INITIAL.

    " El mecanico es OTRO objeto de negocio: se lee sin IN LOCAL MODE
    READ ENTITIES OF zi_tlmecanico
      ENTITY Mecanico FIELDS ( TarifaBase )
      WITH VALUE #( FOR t IN lt_tramos ( MecanicoUUID = t-MecanicoUUID ) )
      RESULT DATA(lt_mecanicos).

    MODIFY ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo UPDATE FIELDS ( TarifaAplicada )
      WITH VALUE #( FOR t IN lt_tramos
                    LET m = VALUE #( lt_mecanicos[ MecanicoUUID = t-MecanicoUUID ] OPTIONAL ) IN
                    ( %tky = t-%tky TarifaAplicada = m-TarifaBase ) ).
  ENDMETHOD.

  METHOD calcularTramo.
    " 1. El coste de cada tramo
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo FIELDS ( Tiempo TarifaAplicada ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tramos).

    MODIFY ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo UPDATE FIELDS ( CosteTramo )
      WITH VALUE #( FOR t IN lt_tramos
                    ( %tky       = t-%tky
                      CosteTramo = zcl_tl_calculos=>coste_tramo( iv_tiempo = CONV #( t-Tiempo )
                                                                 iv_tarifa = CONV #( t-TarifaAplicada ) ) ) ).

    " 2. Los totales de sus jornadas, cada una una sola vez
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo BY \_Jornada FIELDS ( JornadaUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_jornadas).
    SORT lt_jornadas BY JornadaUUID.
    DELETE ADJACENT DUPLICATES FROM lt_jornadas COMPARING JornadaUUID.

    MODIFY ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Jornada EXECUTE recalcularTotales FROM CORRESPONDING #( lt_jornadas ).
  ENDMETHOD.

  METHOD validarTiempo.
    READ ENTITIES OF zi_tljornada IN LOCAL MODE
      ENTITY Tramo FIELDS ( Tiempo JornadaUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tramos).

    LOOP AT lt_tramos INTO DATA(ls_tramo).
      APPEND VALUE #( %tky = ls_tramo-%tky %state_area = 'TIEMPO' ) TO reported-tramo.
      TRY.
          zcl_tl_calculos=>comprobar_tiempo( CONV #( ls_tramo-Tiempo ) ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_tramo-%tky ) TO failed-tramo.
          APPEND VALUE #( %tky            = ls_tramo-%tky
                          %state_area     = 'TIEMPO'
                          %msg            = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = lx_aviso->get_text( ) )
                          %element-Tiempo = if_abap_behv=>mk-on
                          " En un hijo, %path dice a que padre pertenece el mensaje
                          %path           = VALUE #( jornada-%is_draft   = ls_tramo-%is_draft
                                                     jornada-JornadaUUID = ls_tramo-JornadaUUID ) )
                 TO reported-tramo.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
