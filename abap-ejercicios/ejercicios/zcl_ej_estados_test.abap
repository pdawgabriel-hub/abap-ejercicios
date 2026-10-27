CLASS ltcl_estados DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS estados_conocidos FOR TESTING.
    METHODS estado_desconocido FOR TESTING.
    METHODS nombre_limpio FOR TESTING.
ENDCLASS.

CLASS ltcl_estados IMPLEMENTATION.
  METHOD estados_conocidos.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'P' ) exp = `Pendiente` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'C' ) exp = `En curso` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'F' ) exp = `Finalizada` ).
  ENDMETHOD.

  METHOD estado_desconocido.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'X' ) exp = `Desconocido` ).
  ENDMETHOD.

  METHOD nombre_limpio.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>limpiar_nombre( `  reformas   garcia ` )
      exp = `REFORMAS GARCIA` ).
  ENDMETHOD.
ENDCLASS.
