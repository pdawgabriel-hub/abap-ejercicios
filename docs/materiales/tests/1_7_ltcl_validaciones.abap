" Unidad 1.7 - Pegar en la pestana Test Classes de ZCL_GOR_REGLAS,
" debajo de las clases de test de 1.2 a 1.4
CLASS ltcl_validaciones DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS iva_fuera_de_rango      FOR TESTING.
    METHODS iva_en_los_limites      FOR TESTING RAISING cx_static_check.
    METHODS horas_entre_0_y_24      FOR TESTING RAISING cx_static_check.
    METHODS importe_positivo        FOR TESTING RAISING cx_static_check.
    METHODS no_negativo             FOR TESTING RAISING cx_static_check.
    METHODS fechas_en_orden         FOR TESTING RAISING cx_static_check.
    METHODS obligatorio_sin_blancos FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_validaciones IMPLEMENTATION.
  METHOD iva_fuera_de_rango.
    TRY.
        zcl_gor_reglas=>validar_iva( CONV #( '150' ) ).
        cl_abap_unit_assert=>fail( msg = 'IVA 150 deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `Iva` ).
        cl_abap_unit_assert=>assert_not_initial( act = lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD iva_en_los_limites.
    " Si alguna lanza la excepcion, el test falla solo (RAISING en el metodo)
    zcl_gor_reglas=>validar_iva( CONV #( '0' ) ).
    zcl_gor_reglas=>validar_iva( CONV #( '100' ) ).
    TRY.
        zcl_gor_reglas=>validar_iva( CONV #( '-1' ) ).
        cl_abap_unit_assert=>fail( msg = 'IVA -1 deberia fallar' ).
      CATCH zcx_gor_regla.
    ENDTRY.
  ENDMETHOD.

  METHOD horas_entre_0_y_24.
    zcl_gor_reglas=>validar_horas( CONV #( '0' ) ).
    zcl_gor_reglas=>validar_horas( CONV #( '24' ) ).
    TRY.
        zcl_gor_reglas=>validar_horas( CONV #( '25' ) ).
        cl_abap_unit_assert=>fail( msg = '25 h deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `Horas` ).
    ENDTRY.
    TRY.
        zcl_gor_reglas=>validar_horas( CONV #( '-1' ) ).
        cl_abap_unit_assert=>fail( msg = '-1 h deberia fallar' ).
      CATCH zcx_gor_regla.
    ENDTRY.
  ENDMETHOD.

  METHOD importe_positivo.
    zcl_gor_reglas=>validar_importe_positivo( iv_importe = CONV #( '0.01' ) iv_campo = `Importe` ).
    TRY.
        zcl_gor_reglas=>validar_importe_positivo( iv_importe = CONV #( '0' ) iv_campo = `Importe` ).
        cl_abap_unit_assert=>fail( msg = 'Importe 0 deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `Importe` ).
    ENDTRY.
  ENDMETHOD.

  METHOD no_negativo.
    zcl_gor_reglas=>validar_no_negativo( iv_valor = CONV #( '0' ) iv_campo = `CosteHoraEstandar` ).
    TRY.
        zcl_gor_reglas=>validar_no_negativo( iv_valor = CONV #( '-5' ) iv_campo = `CosteHoraEstandar` ).
        cl_abap_unit_assert=>fail( msg = 'Valor negativo deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `CosteHoraEstandar` ).
    ENDTRY.
  ENDMETHOD.

  METHOD fechas_en_orden.
    zcl_gor_reglas=>validar_fechas( iv_inicio = '20261101' iv_fin = '20261101' iv_campo = `FechaFin` ).
    " Sin fecha de fin todavia: no se valida
    zcl_gor_reglas=>validar_fechas( iv_inicio = '20261101' iv_fin = '00000000' iv_campo = `FechaFin` ).
    TRY.
        zcl_gor_reglas=>validar_fechas( iv_inicio = '20261101' iv_fin = '20261031' iv_campo = `FechaFin` ).
        cl_abap_unit_assert=>fail( msg = 'Fin anterior a inicio deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `FechaFin` ).
    ENDTRY.
  ENDMETHOD.

  METHOD obligatorio_sin_blancos.
    zcl_gor_reglas=>validar_obligatorio( iv_valor = `Juan` iv_campo = `Nombre` ).
    TRY.
        zcl_gor_reglas=>validar_obligatorio( iv_valor = `   ` iv_campo = `Nombre` ).
        cl_abap_unit_assert=>fail( msg = 'Un texto en blanco deberia fallar' ).
      CATCH zcx_gor_regla INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals( act = lx_error->mv_campo exp = `Nombre` ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
