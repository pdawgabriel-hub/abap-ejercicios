" Unidad 3.7 - Pegar en la pestana Test Classes de ZCL_GOR_REGLAS, debajo de las demas
CLASS ltcl_codigos DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS numero_tras_el_prefijo FOR TESTING.
    METHODS sin_codigo_es_cero     FOR TESTING.
ENDCLASS.

CLASS ltcl_codigos IMPLEMENTATION.
  METHOD numero_tras_el_prefijo.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>numero_de_codigo( iv_codigo = `CLI0007` iv_prefijo = `CLI` )
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>numero_de_codigo( iv_codigo = `PROV0123` iv_prefijo = `PROV` )
      exp = 123 ).
    " Ida y vuelta con formatear_codigo
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>formatear_codigo(
              iv_prefijo = `OBR`
              iv_numero  = zcl_gor_reglas=>numero_de_codigo( iv_codigo = `OBR0041` iv_prefijo = `OBR` ) + 1 )
      exp = 'OBR0042' ).
  ENDMETHOD.

  METHOD sin_codigo_es_cero.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_gor_reglas=>numero_de_codigo( iv_codigo = `` iv_prefijo = `CLI` )
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
