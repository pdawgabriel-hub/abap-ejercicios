" Unidad 3.5 - Pegar en la pestana Test Classes de ZBP_I_GOROBRA. Usa dobles de las tablas.
CLASS ltcl_borrar_obra DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_entorno TYPE REF TO if_osql_test_environment.
    DATA mv_obra  TYPE sysuuid_x16.
    DATA mv_parte TYPE sysuuid_x16.
    DATA mv_presu TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS con_cobros_no_se_borra     FOR TESTING.
    METHODS sin_cobros_se_lleva_partes FOR TESTING.

    METHODS nuevo_uuid
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_borrar_obra IMPLEMENTATION.
  METHOD class_setup.
    go_entorno = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZGOR_OBRA' )  ( 'ZGOR_OBRA_D' )
      ( 'ZGOR_GASTO' ) ( 'ZGOR_GASTO_D' )
      ( 'ZGOR_ING' )
      ( 'ZGOR_PRESU' )
      ( 'ZGOR_PT' ) ( 'ZGOR_PT_LIN' ) ( 'ZGOR_PE' ) ( 'ZGOR_PP' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_entorno->destroy( ).
  ENDMETHOD.

  METHOD nuevo_uuid.
    TRY.
        rv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( msg = 'No se pudo generar el UUID' ).
    ENDTRY.
  ENDMETHOD.

  METHOD setup.
    mv_obra  = nuevo_uuid( ).
    mv_parte = nuevo_uuid( ).
    mv_presu = nuevo_uuid( ).
    DATA lt_obras TYPE STANDARD TABLE OF zgor_obra WITH EMPTY KEY.
    lt_obras = VALUE #( ( obra_uuid = mv_obra obra_id = 'OBR0009' ) ).
    go_entorno->insert_test_data( lt_obras ).
    DATA lt_gastos TYPE STANDARD TABLE OF zgor_gasto WITH EMPTY KEY.
    lt_gastos = VALUE #( ( gasto_uuid = nuevo_uuid( ) obra_uuid = mv_obra gasto_id = 'GAS0009' ) ).
    go_entorno->insert_test_data( lt_gastos ).
    DATA lt_partes TYPE STANDARD TABLE OF zgor_pt WITH EMPTY KEY.
    lt_partes = VALUE #( ( parte_uuid = mv_parte obra_uuid = mv_obra descripcion = 'Demolicion' ) ).
    go_entorno->insert_test_data( lt_partes ).
    DATA lt_lineas TYPE STANDARD TABLE OF zgor_pt_lin WITH EMPTY KEY.
    lt_lineas = VALUE #( ( linea_uuid = nuevo_uuid( ) parte_uuid = mv_parte horas = 8
                           coste_hora = 20 coste_subtotal = 160 ) ).
    go_entorno->insert_test_data( lt_lineas ).
    DATA lt_presu TYPE STANDARD TABLE OF zgor_presu WITH EMPTY KEY.
    lt_presu = VALUE #( ( presupuesto_uuid = mv_presu presupuesto_id = 'PREP0009' obra_uuid = mv_obra ) ).
    go_entorno->insert_test_data( lt_presu ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_entorno->clear_doubles( ).
  ENDMETHOD.

  METHOD con_cobros_no_se_borra.
    " Paso 11 de la seccion 12.7
    DATA lt_ingresos TYPE STANDARD TABLE OF zgor_ing WITH EMPTY KEY.
    lt_ingresos = VALUE #( ( ingreso_uuid = nuevo_uuid( ) obra_uuid = mv_obra importe = 500 ) ).
    go_entorno->insert_test_data( lt_ingresos ).

    MODIFY ENTITIES OF zi_gorobra
      ENTITY Obra DELETE FROM VALUE #( ( ObraUUID = mv_obra ) )
      FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-obra ).
  ENDMETHOD.

  METHOD sin_cobros_se_lleva_partes.
    " Paso 11b de la seccion 12.7
    MODIFY ENTITIES OF zi_gorobra
      ENTITY Obra DELETE FROM VALUE #( ( ObraUUID = mv_obra ) )
      FAILED DATA(ls_failed).
    COMMIT ENTITIES RESPONSE OF zi_gorobra FAILED DATA(ls_commit_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed ).
    cl_abap_unit_assert=>assert_initial( act = ls_commit_failed ).

    SELECT COUNT( * ) FROM zgor_gasto WHERE obra_uuid = @mv_obra INTO @DATA(lv_gastos).
    SELECT COUNT( * ) FROM zgor_pt    WHERE obra_uuid = @mv_obra INTO @DATA(lv_partes).
    SELECT COUNT( * ) FROM zgor_pt_lin WHERE parte_uuid = @mv_parte INTO @DATA(lv_lineas).
    SELECT SINGLE obra_uuid FROM zgor_presu WHERE presupuesto_uuid = @mv_presu INTO @DATA(lv_obra_presu).
    cl_abap_unit_assert=>assert_equals( act = lv_gastos exp = 0 msg = 'La ficha de gastos sigue' ).
    cl_abap_unit_assert=>assert_equals( act = lv_partes exp = 0 msg = 'El parte sigue' ).
    cl_abap_unit_assert=>assert_equals( act = lv_lineas exp = 0 msg = 'La linea del parte sigue' ).
    cl_abap_unit_assert=>assert_initial( act = lv_obra_presu msg = 'El presupuesto sigue vinculado' ).
  ENDMETHOD.
ENDCLASS.
