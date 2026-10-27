CLASS ltcl_lineas DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mt_lineas TYPE zcl_ej_lineas=>tt_lineas.
    METHODS setup.
    METHODS total_correcto FOR TESTING.
    METHODS total_tabla_vacia FOR TESTING.
    METHODS orden_descendente FOR TESTING.
ENDCLASS.

CLASS ltcl_lineas IMPLEMENTATION.
  METHOD setup.
    mt_lineas = VALUE #(
      ( concepto = 'Aceite'  cantidad = 1 precio = '5.50' )
      ( concepto = 'Filtros' cantidad = 2 precio = '10.00' )
      ( concepto = 'Bujias'  cantidad = 4 precio = '3.00' ) ).
  ENDMETHOD.

  METHOD total_correcto.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_lineas=>total( mt_lineas )
      exp = CONV decfloat34( '37.5' ) ).
  ENDMETHOD.

  METHOD total_tabla_vacia.
    DATA lt_vacia TYPE zcl_ej_lineas=>tt_lineas.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_lineas=>total( lt_vacia )
      exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.

  METHOD orden_descendente.
    DATA(lt_orden) = zcl_ej_lineas=>ordenar_por_importe( mt_lineas ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_orden ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_orden[ 1 ]-concepto exp = `Filtros` ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_orden[ 3 ]-concepto exp = `Aceite` ).
  ENDMETHOD.
ENDCLASS.
