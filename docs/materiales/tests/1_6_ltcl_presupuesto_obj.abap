" Unidad 1.6 - Pegar en la pestana Test Classes de ZCL_GOR_PRESUPUESTO
CLASS ltcl_presupuesto_obj DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_gor_presupuesto.  " cut = clase bajo prueba
    METHODS setup.
    METHODS totales_del_escenario FOR TESTING.
    METHODS otro_iva              FOR TESTING.
    METHODS aprobar_y_desaprobar  FOR TESTING.
ENDCLASS.

CLASS ltcl_presupuesto_obj IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
    mo_cut->add_linea( iv_descripcion = `Reforma` iv_uds = 10 iv_precio = CONV #( '100' ) ).
  ENDMETHOD.

  METHOD totales_del_escenario.
    " Paso 2 de la seccion 12.7
    cl_abap_unit_assert=>assert_equals( act = mo_cut->base( )  exp = CONV decfloat34( '1000' ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->cuota( ) exp = CONV decfloat34( '210' ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = CONV decfloat34( '1210' ) ).
    cl_abap_unit_assert=>assert_equals( act = lines( mo_cut->get_lineas( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD otro_iva.
    DATA(lo_reducido) = NEW zcl_gor_presupuesto( iv_iva = CONV #( '10' ) ).
    lo_reducido->add_linea( iv_descripcion = `Reforma` iv_uds = 10 iv_precio = CONV #( '100' ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_reducido->total( ) exp = CONV decfloat34( '1100' ) ).
  ENDMETHOD.

  METHOD aprobar_y_desaprobar.
    cl_abap_unit_assert=>assert_false( act = mo_cut->esta_aprobado( ) ).
    mo_cut->aprobar( ).
    cl_abap_unit_assert=>assert_true( act = mo_cut->esta_aprobado( ) ).
    mo_cut->desaprobar( ).
    cl_abap_unit_assert=>assert_false( act = mo_cut->esta_aprobado( ) ).
  ENDMETHOD.
ENDCLASS.
