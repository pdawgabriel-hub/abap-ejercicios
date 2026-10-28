" Tests de ZCL_TL_CALCULOS con el caso ORD0001 (0.5): pestana Test Classes (1.8)
CLASS ltcl_presupuesto DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS neto_de_dos_partidas FOR TESTING.
    METHODS importe_con_impuesto FOR TESTING.
    METHODS orden_solo_aceptados FOR TESTING.
ENDCLASS.

CLASS ltcl_presupuesto IMPLEMENTATION.
  METHOD neto_de_dos_partidas.
    " Preparar: paso 1 del caso ORD0001
    DATA(lt_partidas) = VALUE zif_tl_tipos=>tt_partidas(
      ( concepto = `Diagnosis` cantidad = 4 precio_unitario = 45 )
      ( concepto = `Embrague`  cantidad = 1 precio_unitario = 320 ) ).
    " Ejecutar
    DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( lt_partidas ).
    " Comprobar: act = lo obtenido, exp = lo esperado (del mismo tipo)
    cl_abap_unit_assert=>assert_equals( act = lv_neto exp = CONV decfloat34( '500' ) ).
  ENDMETHOD.

  METHOD importe_con_impuesto.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_tl_calculos=>importe_presupuesto( iv_neto = 500 iv_impuesto = 21 )
      exp = CONV decfloat34( '605' ) ).
  ENDMETHOD.

  METHOD orden_solo_aceptados.
    " El borrador no cuenta
    DATA(lt_presupuestos) = VALUE zif_tl_tipos=>tt_presupuestos(
      ( ref = 'PRS0001' situacion = zif_tl_tipos=>situacion_presupuesto-aceptado importe = 605 )
      ( ref = 'PRS0002' situacion = zif_tl_tipos=>situacion_presupuesto-borrador importe = 200 ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_tl_calculos=>importe_orden( lt_presupuestos )
                                        exp = CONV decfloat34( '605' ) ).
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_resumen DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS paso_5_primer_abono FOR TESTING.
    METHODS paso_6_liquidada FOR TESTING.
ENDCLASS.

CLASS ltcl_resumen IMPLEMENTATION.
  METHOD paso_5_primer_abono.
    " Ejecutar con los datos del paso 5 del caso ORD0001
    DATA(ls_resumen) = zcl_tl_calculos=>resumen_orden( iv_importe      = 605
                                                       iv_mano_obra    = 160
                                                       iv_recambios    = 180
                                                       iv_subcontratas = 60
                                                       iv_abonado      = 300 ).
    " Un assert por cada columna de la fila 5 de la tabla del caso
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-costes      exp = CONV decfloat34( '400' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-rendimiento exp = CONV decfloat34( '-100' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-saldo       exp = CONV decfloat34( '305' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-porcentaje  exp = CONV decfloat34( '49.6' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-situacion
                                        exp = zif_tl_tipos=>situacion_cobro-abonado_parcial ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-semaforo exp = zif_tl_tipos=>semaforo-rojo ).
  ENDMETHOD.

  METHOD paso_6_liquidada.
    DATA(ls_resumen) = zcl_tl_calculos=>resumen_orden( iv_importe      = 605
                                                       iv_mano_obra    = 160
                                                       iv_recambios    = 180
                                                       iv_subcontratas = 60
                                                       iv_abonado      = 605 ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-rendimiento exp = CONV decfloat34( '205' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-saldo       exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-porcentaje  exp = CONV decfloat34( '100' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-semaforo    exp = zif_tl_tipos=>semaforo-verde ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-estado_hoja exp = zif_tl_tipos=>estado_hoja-cerrada ).
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_validaciones DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS tramo_de_11_horas FOR TESTING.
    METHODS tramo_de_10_horas FOR TESTING RAISING zcx_tl_aviso.
    METHODS matricula_valida FOR TESTING RAISING zcx_tl_aviso.
    METHODS matricula_antigua FOR TESTING.
ENDCLASS.

CLASS ltcl_validaciones IMPLEMENTATION.
  METHOD tramo_de_11_horas.
    TRY.
        zcl_tl_calculos=>comprobar_tiempo( 11 ).
        cl_abap_unit_assert=>fail( 'Deberia haber lanzado ZCX_TL_AVISO' ).
      CATCH zcx_tl_aviso INTO DATA(lx_aviso).
        cl_abap_unit_assert=>assert_equals( act = lx_aviso->mv_elemento exp = `Tiempo` ).
    ENDTRY.
  ENDMETHOD.

  METHOD tramo_de_10_horas.
    " El limite esta permitido: si lanzara la excepcion, el test fallaria
    zcl_tl_calculos=>comprobar_tiempo( 10 ).
  ENDMETHOD.

  METHOD matricula_valida.
    zcl_tl_calculos=>comprobar_matricula( '1234ABC' ).
  ENDMETHOD.

  METHOD matricula_antigua.
    " Las matriculas provinciales (Z-1234-AB) no se aceptan
    TRY.
        zcl_tl_calculos=>comprobar_matricula( 'Z1234AB' ).
        cl_abap_unit_assert=>fail( 'Deberia haber lanzado ZCX_TL_AVISO' ).
      CATCH zcx_tl_aviso INTO DATA(lx_aviso).
        cl_abap_unit_assert=>assert_equals( act = lx_aviso->mv_elemento exp = `Matricula` ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
