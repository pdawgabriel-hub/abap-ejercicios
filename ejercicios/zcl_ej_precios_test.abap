CLASS ltcl_precios DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS tres_unidades_con_iva FOR TESTING.
    METHODS sin_iva FOR TESTING.
ENDCLASS.

CLASS ltcl_precios IMPLEMENTATION.
  METHOD tres_unidades_con_iva.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_precios=>total_con_iva( iv_cantidad = 3
                                           iv_precio   = CONV #( '12.50' )
                                           iv_iva      = CONV #( '0.21' ) )
      exp = CONV decfloat34( '45.375' ) ).
  ENDMETHOD.

  METHOD sin_iva.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_precios=>total_con_iva( iv_cantidad = 2
                                           iv_precio   = CONV #( '10' )
                                           iv_iva      = CONV #( '0' ) )
      exp = CONV decfloat34( '20' ) ).
  ENDMETHOD.
ENDCLASS.
