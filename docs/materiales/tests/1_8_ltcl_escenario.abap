" Unidad 1.8 - Escenario de la seccion 12.7 del informe tecnico, en memoria.
" Pegar en la pestana Test Classes de ZCL_GOR_REGLAS, debajo de las demas.
CLASS ltcl_escenario DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS pasos_2_a_6_hasta_los_gastos FOR TESTING.
    METHODS paso_7_primer_ingreso        FOR TESTING.
    METHODS paso_8_obra_cobrada          FOR TESTING.
ENDCLASS.

CLASS ltcl_escenario IMPLEMENTATION.
  METHOD pasos_2_a_6_hasta_los_gastos.
    " Paso 2: presupuesto de 10 uds x 100, IVA 21, no aprobado
    DATA(lv_base) = zcl_gor_reglas=>base_imponible(
      VALUE #( ( descripcion = `Reforma` uds = 10 precio = 100 ) ) ).
    DATA(lv_total_presu) = zcl_gor_reglas=>total_presupuesto( iv_base = lv_base iv_iva = 21 ).
    cl_abap_unit_assert=>assert_equals( act = lv_base       exp = CONV decfloat34( '1000' ) ).
    cl_abap_unit_assert=>assert_equals( act = lv_total_presu exp = CONV decfloat34( '1210' ) ).

    DATA(lt_presupuestos) = VALUE zif_gor_tipos=>tt_presupuestos(
      ( codigo = 'PREP0001' estado = zif_gor_tipos=>estado_presu-no_aprobado total = lv_total_presu ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_gor_reglas=>total_obra( lt_presupuestos )
                                        exp = CONV decfloat34( '0' ) ).

    " Paso 3: se aprueba
    lt_presupuestos[ 1 ]-estado = zif_gor_tipos=>estado_presu-aprobado.
    DATA(lv_total_obra) = zcl_gor_reglas=>total_obra( lt_presupuestos ).
    cl_abap_unit_assert=>assert_equals( act = lv_total_obra exp = CONV decfloat34( '1210' ) ).

    " Paso 4: dos trabajadores, 8 h a 20 EUR/h
    DATA(lt_lineas) = VALUE zif_gor_tipos=>tt_parte_lineas(
      ( trabajador = 'TRB0001' horas = 8 coste_hora = 20 )
      ( trabajador = 'TRB0002' horas = 8 coste_hora = 20 ) ).
    DATA(lv_moo) = zcl_gor_reglas=>coste_parte( lt_lineas ).
    cl_abap_unit_assert=>assert_equals( act = lv_moo exp = CONV decfloat34( '320' ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_gor_reglas=>horas_parte( lt_lineas )
                                        exp = CONV decfloat34( '16' ) ).

    " Paso 6: proveedor 200 y especialista 150, sin ingresos
    DATA(ls_kpi) = zcl_gor_reglas=>kpi_obra( iv_total      = lv_total_obra
                                             iv_coste_moo  = lv_moo
                                             iv_coste_prov = 200
                                             iv_coste_esp  = 150
                                             iv_ingresos   = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-gastos exp = CONV decfloat34( '670' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-estado_pago exp = zif_gor_tipos=>estado_pago-pendiente ).
  ENDMETHOD.

  METHOD paso_7_primer_ingreso.
    DATA(ls_kpi) = zcl_gor_reglas=>kpi_obra( iv_total      = 1210
                                             iv_coste_moo  = 320
                                             iv_coste_prov = 200
                                             iv_coste_esp  = 150
                                             iv_ingresos   = 500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-gastos      exp = CONV decfloat34( '670' ) ).
    " Seccion 11.5 (2): beneficio = caja (ingresos - gastos), no presupuesto - gastos
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-beneficio   exp = CONV decfloat34( '-170' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-debe        exp = CONV decfloat34( '710' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-margen      exp = CONV decfloat34( '540' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-porcentaje  exp = CONV decfloat34( '41.3' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-estado_pago exp = zif_gor_tipos=>estado_pago-parcial ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-salud       exp = zif_gor_tipos=>salud-rojo ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-estado_gasto exp = zif_gor_tipos=>estado_gasto-proceso ).
  ENDMETHOD.

  METHOD paso_8_obra_cobrada.
    DATA(ls_kpi) = zcl_gor_reglas=>kpi_obra( iv_total      = 1210
                                             iv_coste_moo  = 320
                                             iv_coste_prov = 200
                                             iv_coste_esp  = 150
                                             iv_ingresos   = 1210 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-ingresos    exp = CONV decfloat34( '1210' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-beneficio   exp = CONV decfloat34( '540' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-debe        exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-porcentaje  exp = CONV decfloat34( '100' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-estado_pago exp = zif_gor_tipos=>estado_pago-pagado ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-salud       exp = zif_gor_tipos=>salud-verde ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-estado_gasto exp = zif_gor_tipos=>estado_gasto-finalizado ).
  ENDMETHOD.
ENDCLASS.
