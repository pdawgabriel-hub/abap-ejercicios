" Unidad 1.2 - Pegar en la pestana Test Classes de ZCL_GOR_REGLAS
" Comprueba las formulas del presupuesto y las de 'Otros' (seccion 11.2)
CLASS ltcl_presupuesto DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS total_linea_redondea   FOR TESTING.
    METHODS cuota_iva_del_21       FOR TESTING.
    METHODS total_es_base_mas_iva  FOR TESTING.
    METHODS proveedor_sin_redondeo FOR TESTING.
    METHODS subtotal_horas         FOR TESTING.
    METHODS falta_un_dia_cuenta_1  FOR TESTING.
    METHODS falta_sin_fecha_es_0   FOR TESTING.
ENDCLASS.

CLASS ltcl_presupuesto IMPLEMENTATION.
  METHOD total_linea_redondea.
    " 3 x 10.555 = 31.665 -> 31.67 (empate hacia arriba)
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_linea( iv_uds = 3 iv_precio = CONV #( '10.555' ) )
      exp = CONV decfloat34( '31.67' ) ).
  ENDMETHOD.

  METHOD cuota_iva_del_21.
    " Paso 2 de la seccion 12.7: base 1000, IVA 21 -> cuota 210
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>cuota_iva( iv_base = CONV #( '1000' ) iv_iva = CONV #( '21' ) )
      exp = CONV decfloat34( '210' ) ).
  ENDMETHOD.

  METHOD total_es_base_mas_iva.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_presupuesto( iv_base = CONV #( '1000' ) iv_iva = CONV #( '21' ) )
      exp = CONV decfloat34( '1210' ) ).
    " Con decimales: 99.99 * 21 / 100 = 20.9979 -> 21.00; total 120.99
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_presupuesto( iv_base = CONV #( '99.99' ) iv_iva = CONV #( '21' ) )
      exp = CONV decfloat34( '120.99' ) ).
  ENDMETHOD.

  METHOD proveedor_sin_redondeo.
    " 10.01 * 1.21 = 12.1121 (no se redondea)
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_proveedor( iv_base = CONV #( '10.01' ) iv_iva = CONV #( '21' ) )
      exp = CONV decfloat34( '12.1121' ) ).
  ENDMETHOD.

  METHOD subtotal_horas.
    " Paso 4 de la seccion 12.7: 8 h a 20 EUR/h = 160
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>coste_subtotal( iv_horas = CONV #( '8' ) iv_coste_hora = CONV #( '20' ) )
      exp = CONV decfloat34( '160' ) ).
  ENDMETHOD.

  METHOD falta_un_dia_cuenta_1.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>dias_falta( iv_inicio = '20261105' iv_fin = '20261105' )
      exp = 1 ).
    " 2028 es bisiesto: 28/02, 29/02 y 01/03
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>dias_falta( iv_inicio = '20280228' iv_fin = '20280301' )
      exp = 3 ).
  ENDMETHOD.

  METHOD falta_sin_fecha_es_0.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>dias_falta( iv_inicio = '20261105' iv_fin = '00000000' )
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
