CLASS ltcl_presupuesto DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_ej_presupuesto.
    METHODS setup.
    METHODS subtotal_suma_lineas FOR TESTING.
    METHODS total_incluye_iva FOR TESTING.
    METHODS sin_lineas_es_cero FOR TESTING.
ENDCLASS.

CLASS ltcl_presupuesto IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW zcl_ej_presupuesto( iv_iva = CONV #( '0.21' ) ).
  ENDMETHOD.

  METHOD subtotal_suma_lineas.
    mo_cut->add_linea( iv_concepto = 'Pintura' iv_importe = CONV #( '100' ) ).
    mo_cut->add_linea( iv_concepto = 'Mano de obra' iv_importe = CONV #( '50' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->subtotal( ) exp = CONV decfloat34( '150' ) ).
  ENDMETHOD.

  METHOD total_incluye_iva.
    mo_cut->add_linea( iv_concepto = 'Pintura' iv_importe = CONV #( '100' ) ).
    mo_cut->add_linea( iv_concepto = 'Mano de obra' iv_importe = CONV #( '50' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( ) exp = CONV decfloat34( '181.5' ) ).
  ENDMETHOD.

  METHOD sin_lineas_es_cero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( ) exp = CONV decfloat34( '0' ) ).
  ENDMETHOD.
ENDCLASS.
