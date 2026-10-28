" Unidad 1.7 - Pegar en la pestana Test Classes de ZCL_GOR_PARTE_TRABAJO,
" debajo de la clase de test de 1.6
CLASS ltcl_parte_horas DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS linea_de_25_horas_no_entra FOR TESTING.
ENDCLASS.

CLASS ltcl_parte_horas IMPLEMENTATION.
  METHOD linea_de_25_horas_no_entra.
    " Paso 9 de la seccion 12.7
    DATA(lo_parte) = NEW zcl_gor_parte_trabajo( ).
    TRY.
        lo_parte->add_linea( io_trabajador = NEW zcl_gor_trabajador( iv_codigo = 'TRB0001' )
                             iv_horas      = 25 ).
        cl_abap_unit_assert=>fail( msg = '25 h deberia fallar' ).
      CATCH zcx_gor_regla.
        cl_abap_unit_assert=>assert_initial( act = lo_parte->get_lineas( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
