CLASS ltcl_obras DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mt_obras TYPE zcl_ej_obras=>tt_obras.
    METHODS setup.
    METHODS encuentra_obra FOR TESTING.
    METHODS obra_inexistente_vacia FOR TESTING.
    METHODS existe_true_y_false FOR TESTING.
ENDCLASS.

CLASS ltcl_obras IMPLEMENTATION.
  METHOD setup.
    mt_obras = VALUE #(
      ( codigo = 'OB-001' direccion = 'Calle Mayor 1' )
      ( codigo = 'OB-002' direccion = 'Plaza Nueva 5' ) ).
  ENDMETHOD.

  METHOD encuentra_obra.
    DATA(ls_obra) = zcl_ej_obras=>buscar( it_obras = mt_obras iv_codigo = 'OB-002' ).
    cl_abap_unit_assert=>assert_equals( act = ls_obra-direccion exp = `Plaza Nueva 5` ).
  ENDMETHOD.

  METHOD obra_inexistente_vacia.
    DATA(ls_obra) = zcl_ej_obras=>buscar( it_obras = mt_obras iv_codigo = 'OB-999' ).
    cl_abap_unit_assert=>assert_initial( ls_obra ).
  ENDMETHOD.

  METHOD existe_true_y_false.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_obras=>existe( it_obras = mt_obras iv_codigo = 'OB-001' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_obras=>existe( it_obras = mt_obras iv_codigo = 'OB-999' )
      exp = abap_false ).
  ENDMETHOD.
ENDCLASS.
