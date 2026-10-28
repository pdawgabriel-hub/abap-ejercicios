" Local Types de zbp_i_tlabono

CLASS lhc_abono DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Abono RESULT result.
    " El titular del abono es el de su orden
    METHODS titularDeOrden FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Abono~titularDeOrden.
    " 3.7 ABO0001...
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Abono~numerar.
ENDCLASS.


CLASS lhc_abono IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD titularDeOrden.
    READ ENTITIES OF zi_tlabono IN LOCAL MODE
      ENTITY Abono FIELDS ( OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_abonos).
    DELETE lt_abonos WHERE OrdenUUID IS INITIAL.
    CHECK lt_abonos IS NOT INITIAL.

    " La orden es otro objeto de negocio
    READ ENTITIES OF zi_tlorden
      ENTITY Orden FIELDS ( TitularUUID )
      WITH VALUE #( FOR a IN lt_abonos ( OrdenUUID = a-OrdenUUID ) )
      RESULT DATA(lt_ordenes).

    MODIFY ENTITIES OF zi_tlabono IN LOCAL MODE
      ENTITY Abono UPDATE FIELDS ( TitularUUID )
      WITH VALUE #( FOR a IN lt_abonos
                    LET o = VALUE #( lt_ordenes[ OrdenUUID = a-OrdenUUID ] OPTIONAL ) IN
                    ( %tky = a-%tky TitularUUID = o-TitularUUID ) ).
  ENDMETHOD.

  METHOD numerar.
    READ ENTITIES OF zi_tlabono IN LOCAL MODE
      ENTITY Abono FIELDS ( AbonoRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevos).
    DELETE lt_nuevos WHERE AbonoRef IS NOT INITIAL.
    CHECK lt_nuevos IS NOT INITIAL.

    SELECT SINGLE FROM ztl_abo FIELDS MAX( abono_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    MODIFY ENTITIES OF zi_tlabono IN LOCAL MODE
      ENTITY Abono UPDATE FIELDS ( AbonoRef )
      WITH VALUE #( FOR ls IN lt_nuevos INDEX INTO i
                    ( %tky     = ls-%tky
                      AbonoRef = zcl_tl_calculos=>componer_codigo( iv_serie = `ABO` iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.


" 6.7 Al guardar, el abono anuncia que se ha registrado
CLASS lsc_zi_tlabono DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.


CLASS lsc_zi_tlabono IMPLEMENTATION.

  METHOD save_modified.
    CHECK create-abono IS NOT INITIAL.               " solo si se crean abonos
    " Un evento por abono creado, con sus datos en %param
    RAISE ENTITY EVENT zi_tlabono~AbonoRegistrado
      FROM VALUE #( FOR ls IN create-abono
                    ( %key   = ls-%key
                      %param = VALUE #( OrdenUUID       = ls-OrdenUUID
                                        CantidadAbonada = ls-CantidadAbonada ) ) ).
  ENDMETHOD.

ENDCLASS.
