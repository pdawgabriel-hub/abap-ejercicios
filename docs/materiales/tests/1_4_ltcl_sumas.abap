" Unidad 1.4 - Pegar en la pestana Test Classes de ZCL_GOR_REGLAS,
" debajo de las clases de test de 1.2 y 1.3
CLASS ltcl_sumas DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mt_lineas_parte TYPE zif_gor_tipos=>tt_parte_lineas.
    METHODS setup.
    METHODS base_suma_lineas_redondeadas FOR TESTING.
    METHODS total_solo_aprobados         FOR TESTING.
    METHODS total_sin_aprobados_es_cero  FOR TESTING.
    METHODS horas_y_coste_del_parte      FOR TESTING.
    METHODS participantes_distintos      FOR TESTING.
    METHODS horas_por_trabajador_orden   FOR TESTING.
    METHODS busqueda_palabra_a_palabra   FOR TESTING.
    METHODS busqueda_vacia_coincide      FOR TESTING.
ENDCLASS.

CLASS ltcl_sumas IMPLEMENTATION.
  METHOD setup.
    " Paso 4 de la seccion 12.7 (dos trabajadores, 8 h a 20) y una linea mas
    mt_lineas_parte = VALUE #(
      ( trabajador = 'TRB0002' horas = 8 coste_hora = 20 )
      ( trabajador = 'TRB0001' horas = 8 coste_hora = 20 )
      ( trabajador = 'TRB0002' horas = '4.5' coste_hora = 20 ) ).
  ENDMETHOD.

  METHOD base_suma_lineas_redondeadas.
    DATA(lt_lineas) = VALUE zif_gor_tipos=>tt_presu_lineas(
      ( descripcion = `Alicatado` uds = 10 precio = 100 )
      ( descripcion = `Remate`    uds = 3  precio = '10.555' ) ).
    " 1000 + 31.67
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>base_imponible( lt_lineas )
      exp = CONV decfloat34( '1031.67' ) ).
  ENDMETHOD.

  METHOD total_solo_aprobados.
    DATA(lt_presupuestos) = VALUE zif_gor_tipos=>tt_presupuestos(
      ( codigo = 'PREP0001' estado = zif_gor_tipos=>estado_presu-aprobado    total = 1210 )
      ( codigo = 'PREP0002' estado = zif_gor_tipos=>estado_presu-no_aprobado total = 500 )
      ( codigo = 'PREP0003' estado = zif_gor_tipos=>estado_presu-aprobado    total = 363 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_obra( lt_presupuestos )
      exp = CONV decfloat34( '1573' ) ).
  ENDMETHOD.

  METHOD total_sin_aprobados_es_cero.
    DATA(lt_presupuestos) = VALUE zif_gor_tipos=>tt_presupuestos(
      ( codigo = 'PREP0002' estado = zif_gor_tipos=>estado_presu-no_aprobado total = 500 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>total_obra( lt_presupuestos )
      exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.

  METHOD horas_y_coste_del_parte.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>horas_parte( mt_lineas_parte )
      exp = CONV decfloat34( '20.5' ) ).
    " 160 + 160 + 90
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>coste_parte( mt_lineas_parte )
      exp = CONV decfloat34( '410' ) ).
  ENDMETHOD.

  METHOD participantes_distintos.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>participantes( mt_lineas_parte )
      exp = VALUE zif_gor_tipos=>tt_codigos( ( 'TRB0001' ) ( 'TRB0002' ) ) ).
  ENDMETHOD.

  METHOD horas_por_trabajador_orden.
    DATA(lt_horas) = zcl_gor_reglas=>horas_por_trabajador( mt_lineas_parte ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_horas ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_horas[ 1 ]-trabajador exp = 'TRB0002' ).
    cl_abap_unit_assert=>assert_equals( act = lt_horas[ 1 ]-horas exp = CONV decfloat34( '12.5' ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_horas[ 1 ]-coste exp = CONV decfloat34( '250' ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_horas[ 2 ]-trabajador exp = 'TRB0001' ).
  ENDMETHOD.

  METHOD busqueda_palabra_a_palabra.
    DATA(lt_campos) = VALUE zif_gor_tipos=>tt_textos(
      ( `Juan` ) ( `Pérez López` ) ( `12345678Z` ) ( `600111222` ) ).
    cl_abap_unit_assert=>assert_true(
      act = zcl_gor_reglas=>coincide_busqueda( iv_busqueda = `Juan Pérez` it_campos = lt_campos ) ).
    cl_abap_unit_assert=>assert_true(
      act = zcl_gor_reglas=>coincide_busqueda( iv_busqueda = `pérez  JUAN` it_campos = lt_campos ) ).
    cl_abap_unit_assert=>assert_true(
      act = zcl_gor_reglas=>coincide_busqueda( iv_busqueda = `5678` it_campos = lt_campos ) ).
    cl_abap_unit_assert=>assert_false(
      act = zcl_gor_reglas=>coincide_busqueda( iv_busqueda = `Juan García` it_campos = lt_campos ) ).
  ENDMETHOD.

  METHOD busqueda_vacia_coincide.
    cl_abap_unit_assert=>assert_true(
      act = zcl_gor_reglas=>coincide_busqueda( iv_busqueda = `` it_campos = VALUE #( ( `Juan` ) ) ) ).
  ENDMETHOD.
ENDCLASS.
