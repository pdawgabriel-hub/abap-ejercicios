" Unidad 1.3 - Pegar en la pestana Test Classes de ZCL_GOR_REGLAS,
" debajo de la clase de test de 1.2
CLASS ltcl_estados DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS pago_pendiente_parcial_pagado FOR TESTING.
    METHODS pago_total_cero_con_cobro     FOR TESTING.
    METHODS salud_por_orden_de_reglas     FOR TESTING.
    METHODS gasto_finaliza_con_cobros     FOR TESTING.
    METHODS porcentaje_un_decimal         FOR TESTING.
    METHODS porcentaje_acotado            FOR TESTING.
    METHODS codigo_con_cuatro_cifras      FOR TESTING.
    METHODS nombre_sin_espacios_sobrantes FOR TESTING.
    METHODS etiqueta_segun_datos          FOR TESTING.
ENDCLASS.

CLASS ltcl_estados IMPLEMENTATION.
  METHOD pago_pendiente_parcial_pagado.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_pago( iv_total = CONV #( '1210' ) iv_cobrado = CONV #( '0' ) )
      exp = zif_gor_tipos=>estado_pago-pendiente ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_pago( iv_total = CONV #( '1210' ) iv_cobrado = CONV #( '500' ) )
      exp = zif_gor_tipos=>estado_pago-parcial ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_pago( iv_total = CONV #( '1210' ) iv_cobrado = CONV #( '1210' ) )
      exp = zif_gor_tipos=>estado_pago-pagado ).
  ENDMETHOD.

  METHOD pago_total_cero_con_cobro.
    " Seccion 11.6: total 0 y algun ingreso -> pagado
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_pago( iv_total = CONV #( '0' ) iv_cobrado = CONV #( '50' ) )
      exp = zif_gor_tipos=>estado_pago-pagado ).
  ENDMETHOD.

  METHOD salud_por_orden_de_reglas.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>salud_obra( iv_beneficio    = CONV #( '-170' )
                                        iv_estado_pago  = zif_gor_tipos=>estado_pago-parcial )
      exp = zif_gor_tipos=>salud-rojo ).
    " Pagada pero con perdidas: sigue siendo roja
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>salud_obra( iv_beneficio    = CONV #( '-1' )
                                        iv_estado_pago  = zif_gor_tipos=>estado_pago-pagado )
      exp = zif_gor_tipos=>salud-rojo ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>salud_obra( iv_beneficio    = CONV #( '540' )
                                        iv_estado_pago  = zif_gor_tipos=>estado_pago-pagado )
      exp = zif_gor_tipos=>salud-verde ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>salud_obra( iv_beneficio    = CONV #( '0' )
                                        iv_estado_pago  = zif_gor_tipos=>estado_pago-pendiente )
      exp = zif_gor_tipos=>salud-ambar ).
  ENDMETHOD.

  METHOD gasto_finaliza_con_cobros.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_gasto( iv_total_obra = CONV #( '1210' ) iv_ingresos = CONV #( '1210' ) )
      exp = zif_gor_tipos=>estado_gasto-finalizado ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_gasto( iv_total_obra = CONV #( '1210' ) iv_ingresos = CONV #( '500' ) )
      exp = zif_gor_tipos=>estado_gasto-proceso ).
    " Obra sin empezar a cobrar: no se marca como finalizada
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>estado_gasto( iv_total_obra = CONV #( '0' ) iv_ingresos = CONV #( '0' ) )
      exp = zif_gor_tipos=>estado_gasto-proceso ).
  ENDMETHOD.

  METHOD porcentaje_un_decimal.
    " Paso 7 de la seccion 12.7: 500 de 1210 -> 41.3
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>porcentaje_cobrado( iv_total = CONV #( '1210' ) iv_pendiente = CONV #( '710' ) )
      exp = CONV decfloat34( '41.3' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>porcentaje_cobrado( iv_total = CONV #( '0' ) iv_pendiente = CONV #( '0' ) )
      exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.

  METHOD porcentaje_acotado.
    " Cobrado de mas (pendiente negativo): 150 % -> 100
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>porcentaje_cobrado( iv_total = CONV #( '100' ) iv_pendiente = CONV #( '-50' ) )
      exp = CONV decfloat34( '100' ) ).
  ENDMETHOD.

  METHOD codigo_con_cuatro_cifras.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>formatear_codigo( iv_prefijo = `OBR` iv_numero = 7 )
      exp = 'OBR0007' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>formatear_codigo( iv_prefijo = `PROV` iv_numero = 123 )
      exp = 'PROV0123' ).
  ENDMETHOD.

  METHOD nombre_sin_espacios_sobrantes.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>nombre_completo( iv_nombre = `Juan` iv_apellidos = `Pérez López` )
      exp = `Juan Pérez López` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>nombre_completo( iv_nombre = `Juan` iv_apellidos = `` )
      exp = `Juan` ).
  ENDMETHOD.

  METHOD etiqueta_segun_datos.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>etiqueta_cliente( iv_codigo = `CLI0001` iv_nombre = `Juan`
                                              iv_apellidos = `Pérez` iv_nif = `12345678Z` )
      exp = `CLI0001 - Juan Pérez (12345678Z)` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>etiqueta_cliente( iv_codigo = `CLI0002` iv_nombre = `Ana`
                                              iv_apellidos = `Ruiz` iv_nif = `` )
      exp = `CLI0002 - Ana Ruiz` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>etiqueta_cliente( iv_codigo = `CLI0003` iv_nombre = ``
                                              iv_apellidos = `` iv_nif = `12345678Z` )
      exp = `CLI0003` ).
  ENDMETHOD.
ENDCLASS.
