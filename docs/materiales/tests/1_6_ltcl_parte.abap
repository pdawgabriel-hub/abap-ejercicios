" Unidad 1.6 - Pegar en la pestana Test Classes de ZCL_GOR_PARTE_TRABAJO
" RAISING cx_static_check: en 1.7, add_linea podra lanzar ZCX_GOR_REGLA
CLASS ltcl_parte DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS horas_y_coste_del_parte FOR TESTING RAISING cx_static_check.
    METHODS tarifa_congelada        FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_parte IMPLEMENTATION.
  METHOD horas_y_coste_del_parte.
    " Paso 4 de la seccion 12.7
    DATA(lo_parte) = NEW zcl_gor_parte_trabajo( ).
    lo_parte->add_linea( io_trabajador = NEW zcl_gor_trabajador( iv_codigo = 'TRB0001' )
                         iv_horas      = 8 ).
    lo_parte->add_linea( io_trabajador = NEW zcl_gor_trabajador( iv_codigo = 'TRB0002' )
                         iv_horas      = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lo_parte->horas_totales( ) exp = CONV decfloat34( '16' ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_parte->coste_total( ) exp = CONV decfloat34( '320' ) ).
  ENDMETHOD.

  METHOD tarifa_congelada.
    " Paso 5 de la seccion 12.7: subir la tarifa no cambia los partes ya registrados
    DATA(lo_trabajador) = NEW zcl_gor_trabajador( iv_codigo = 'TRB0001' ).
    DATA(lo_antiguo) = NEW zcl_gor_parte_trabajo( ).
    lo_antiguo->add_linea( io_trabajador = lo_trabajador iv_horas = 8 ).

    lo_trabajador->set_coste_hora( 25 ).

    cl_abap_unit_assert=>assert_equals( act = lo_antiguo->coste_total( ) exp = CONV decfloat34( '160' ) ).
    DATA(lo_nuevo) = NEW zcl_gor_parte_trabajo( ).
    lo_nuevo->add_linea( io_trabajador = lo_trabajador iv_horas = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lo_nuevo->coste_total( ) exp = CONV decfloat34( '200' ) ).
  ENDMETHOD.
ENDCLASS.
