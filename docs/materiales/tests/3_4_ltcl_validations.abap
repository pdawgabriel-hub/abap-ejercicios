" Unidad 3.4 - Pegar en la pestana Test Classes de ZBP_I_GORPRESUPUESTO,
" debajo de la clase de test de 3.3. Usa dobles de las tablas.
CLASS ltcl_validations DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_entorno TYPE REF TO if_osql_test_environment.
    DATA mv_juan TYPE sysuuid_x16.
    DATA mv_ana  TYPE sysuuid_x16.
    DATA mv_obra TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS iva_150_no_se_guarda      FOR TESTING.
    METHODS iva_21_se_guarda          FOR TESTING.
    METHODS cliente_distinto_de_obra  FOR TESTING.

    METHODS guardar
      IMPORTING iv_cliente       TYPE sysuuid_x16
                iv_obra          TYPE sysuuid_x16 OPTIONAL
                iv_iva           TYPE zgor_presu-iva DEFAULT 21
      RETURNING VALUE(rs_failed) TYPE RESPONSE FOR FAILED LATE zi_gorpresupuesto.
    METHODS nuevo_uuid
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_validations IMPLEMENTATION.
  METHOD class_setup.
    go_entorno = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZGOR_PRESU' )     ( 'ZGOR_PRESU_D' )
      ( 'ZGOR_PRESU_LIN' ) ( 'ZGOR_PRESU_LIN_D' )
      ( 'ZGOR_PRESU_PV' )  ( 'ZGOR_PRESU_PV_D' )
      ( 'ZGOR_PRESU_ES' )  ( 'ZGOR_PRESU_ES_D' )
      ( 'ZGOR_CLI' )       ( 'ZGOR_CLI_D' )
      ( 'ZGOR_OBRA' )      ( 'ZGOR_OBRA_D' )
      ( 'ZGOR_GASTO' )     ( 'ZGOR_GASTO_D' ) ) ).
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
    mv_juan = nuevo_uuid( ).
    mv_ana  = nuevo_uuid( ).
    mv_obra = nuevo_uuid( ).
    DATA lt_clientes TYPE STANDARD TABLE OF zgor_cli WITH EMPTY KEY.
    lt_clientes = VALUE #( ( cliente_uuid = mv_juan cliente_id = 'CLI0001' nombre = 'Juan'
                             direccion = 'C/ Mayor 1' telf = '600111222' )
                           ( cliente_uuid = mv_ana  cliente_id = 'CLI0002' nombre = 'Ana'
                             direccion = 'C/ Sol 2'   telf = '600333444' ) ).
    go_entorno->insert_test_data( lt_clientes ).
    DATA lt_obras TYPE STANDARD TABLE OF zgor_obra WITH EMPTY KEY.
    lt_obras = VALUE #( ( obra_uuid = mv_obra obra_id = 'OBR0001' cliente_uuid = mv_juan ) ).
    go_entorno->insert_test_data( lt_obras ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_entorno->clear_doubles( ).
  ENDMETHOD.

  METHOD guardar.
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( ClienteUUID ObraUUID Iva )
        WITH VALUE #( ( %cid = 'P' ClienteUUID = iv_cliente ObraUUID = iv_obra Iva = iv_iva ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED rs_failed.
  ENDMETHOD.

  METHOD iva_150_no_se_guarda.
    DATA(ls_failed) = guardar( iv_cliente = mv_juan iv_iva = 150 ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-presupuesto msg = 'IVA 150 no deberia guardarse' ).
    SELECT COUNT( * ) FROM zgor_presu INTO @DATA(lv_guardados).
    cl_abap_unit_assert=>assert_equals( act = lv_guardados exp = 0 ).
  ENDMETHOD.

  METHOD iva_21_se_guarda.
    DATA(ls_failed) = guardar( iv_cliente = mv_juan ).
    cl_abap_unit_assert=>assert_initial( act = ls_failed-presupuesto ).
    SELECT COUNT( * ) FROM zgor_presu INTO @DATA(lv_guardados).
    cl_abap_unit_assert=>assert_equals( act = lv_guardados exp = 1 ).
  ENDMETHOD.

  METHOD cliente_distinto_de_obra.
    " Seccion 12.7, paso 13: un presupuesto de Ana en una obra de Juan
    DATA(ls_failed) = guardar( iv_cliente = mv_ana iv_obra = mv_obra ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-presupuesto ).
  ENDMETHOD.
ENDCLASS.
