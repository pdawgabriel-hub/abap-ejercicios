" Unidad 3.5 - Pegar en la pestana Test Classes de ZBP_I_GORPRESUPUESTO,
" debajo de las clases de test de 3.3 y 3.4. Usa dobles de las tablas.
CLASS ltcl_actions DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_entorno TYPE REF TO if_osql_test_environment.
    DATA mv_juan TYPE sysuuid_x16.
    DATA mv_ana  TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS aprobar_cambia_el_estado     FOR TESTING.
    METHODS no_se_aprueba_dos_veces      FOR TESTING.
    METHODS no_vincula_obra_ajena        FOR TESTING.

    METHODS crear_presupuesto
      IMPORTING iv_cliente     TYPE sysuuid_x16
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    METHODS nuevo_uuid
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_actions IMPLEMENTATION.
  METHOD class_setup.
    go_entorno = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZGOR_PRESU' )     ( 'ZGOR_PRESU_D' )
      ( 'ZGOR_PRESU_LIN' ) ( 'ZGOR_PRESU_LIN_D' )
      ( 'ZGOR_PRESU_PV' )  ( 'ZGOR_PRESU_PV_D' )
      ( 'ZGOR_PRESU_ES' )  ( 'ZGOR_PRESU_ES_D' )
      ( 'ZGOR_CLI' )       ( 'ZGOR_CLI_D' )
      ( 'ZGOR_OBRA' )      ( 'ZGOR_OBRA_D' ) ) ).
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
    DATA lt_clientes TYPE STANDARD TABLE OF zgor_cli WITH EMPTY KEY.
    lt_clientes = VALUE #( ( cliente_uuid = mv_juan cliente_id = 'CLI0001' nombre = 'Juan'
                             direccion = 'C/ Mayor 1' telf = '600111222' )
                           ( cliente_uuid = mv_ana  cliente_id = 'CLI0002' nombre = 'Ana'
                             direccion = 'C/ Sol 2'   telf = '600333444' ) ).
    go_entorno->insert_test_data( lt_clientes ).
    DATA lt_obras TYPE STANDARD TABLE OF zgor_obra WITH EMPTY KEY.
    lt_obras = VALUE #( ( obra_uuid = nuevo_uuid( ) obra_id = 'OBR0001' cliente_uuid = mv_juan ) ).
    go_entorno->insert_test_data( lt_obras ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_entorno->clear_doubles( ).
  ENDMETHOD.

  METHOD crear_presupuesto.
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( ClienteUUID ) WITH VALUE #( ( %cid = 'P' ClienteUUID = iv_cliente ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed msg = 'No se pudo crear el presupuesto' ).
    rv_uuid = ls_mapped-presupuesto[ 1 ]-PresupuestoUUID.
  ENDMETHOD.

  METHOD aprobar_cambia_el_estado.
    " Paso 3 de la seccion 12.7
    DATA(lv_uuid) = crear_presupuesto( mv_juan ).
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto EXECUTE aprobar FROM VALUE #( ( PresupuestoUUID = lv_uuid ) )
      FAILED DATA(ls_failed).
    COMMIT ENTITIES.
    cl_abap_unit_assert=>assert_initial( act = ls_failed ).

    SELECT SINGLE estado FROM zgor_presu WHERE presupuesto_uuid = @lv_uuid INTO @DATA(lv_estado).
    cl_abap_unit_assert=>assert_equals( act = lv_estado
                                        exp = CONV zgor_presu-estado( zif_gor_tipos=>estado_presu-aprobado ) ).
  ENDMETHOD.

  METHOD no_se_aprueba_dos_veces.
    DATA(lv_uuid) = crear_presupuesto( mv_juan ).
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto EXECUTE aprobar FROM VALUE #( ( PresupuestoUUID = lv_uuid ) ).
    COMMIT ENTITIES.
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto EXECUTE aprobar FROM VALUE #( ( PresupuestoUUID = lv_uuid ) )
      FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-presupuesto
                                             msg = 'El feature control deberia rechazarlo' ).
  ENDMETHOD.

  METHOD no_vincula_obra_ajena.
    " Seccion 3.15: solo presupuestos del cliente de la obra
    DATA(lv_uuid) = crear_presupuesto( mv_ana ).
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto EXECUTE vincularAObra
        FROM VALUE #( ( PresupuestoUUID = lv_uuid %param-ObraId = 'OBR0001' ) )
      FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-presupuesto ).
  ENDMETHOD.
ENDCLASS.
