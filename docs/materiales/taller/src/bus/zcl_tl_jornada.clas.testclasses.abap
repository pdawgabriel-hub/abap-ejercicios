" La tarifa queda congelada en el tramo (1.6)
CLASS ltcl_jornada DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS tarifa_congelada FOR TESTING RAISING zcx_tl_aviso.
ENDCLASS.

CLASS ltcl_jornada IMPLEMENTATION.
  METHOD tarifa_congelada.
    DATA(lo_rosa) = NEW zcl_tl_mecanico( iv_ref = 'MEC0001' ).   " 30 euros/h
    DATA(lo_jornada) = NEW zcl_tl_jornada( ).
    lo_jornada->add_tramo( io_mecanico = lo_rosa iv_tiempo = 3 ).
    " Subir la tarifa despues no cambia el tramo ya anotado
    lo_rosa->revisar_tarifa( 40 ).
    cl_abap_unit_assert=>assert_equals( act = lo_jornada->coste( ) exp = CONV decfloat34( '90' ) ).
  ENDMETHOD.
ENDCLASS.
