" Local Types de zbp_i_tlsubcontrata

CLASS lhc_subcontrata DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Subcontrata RESULT result.
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Subcontrata~numerar.
ENDCLASS.


CLASS lhc_subcontrata IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD numerar.
    " Los registros que se estan guardando...
    READ ENTITIES OF zi_tlsubcontrata IN LOCAL MODE
      ENTITY Subcontrata FIELDS ( SubcontrataRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_nuevos).
    " ...que todavia no tienen codigo
    DELETE lt_nuevos WHERE SubcontrataRef IS NOT INITIAL.
    CHECK lt_nuevos IS NOT INITIAL.

    " El codigo mas alto guardado: SUB0041 -> 41 (si no hay ninguno, 0)
    SELECT SINGLE FROM ztl_sub FIELDS MAX( subcontrata_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada registro nuevo, el siguiente (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tlsubcontrata IN LOCAL MODE
      ENTITY Subcontrata
        UPDATE FIELDS ( SubcontrataRef )
        WITH VALUE #( FOR ls IN lt_nuevos INDEX INTO i
                      ( %tky = ls-%tky
                        SubcontrataRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `SUB`
                                                                   iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.
