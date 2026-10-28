" Unidad 3.3 - Pegar en la pestana Test Classes de ZBP_I_GORPRESUPUESTO.
" Las tablas se sustituyen por dobles (cl_osql_test_environment): los tests
" no leen ni escriben tus datos reales. Ver la explicacion en la unidad 3.8.
CLASS ltcl_determinations DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_entorno TYPE REF TO if_osql_test_environment.
    DATA mv_cliente TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS valores_por_defecto      FOR TESTING.
    METHODS copia_datos_del_cliente  FOR TESTING.
    METHODS totales_desde_las_lineas FOR TESTING.

    METHODS crear_presupuesto
      IMPORTING iv_uds         TYPE i DEFAULT 10
                iv_precio      TYPE zgor_presu_lin-precio DEFAULT 100
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_determinations IMPLEMENTATION.
  METHOD class_setup.
    go_entorno = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZGOR_PRESU' )    ( 'ZGOR_PRESU_D' )
      ( 'ZGOR_PRESU_LIN' ) ( 'ZGOR_PRESU_LIN_D' )
      ( 'ZGOR_PRESU_PV' ) ( 'ZGOR_PRESU_PV_D' )
      ( 'ZGOR_PRESU_ES' ) ( 'ZGOR_PRESU_ES_D' )
      ( 'ZGOR_CLI' )      ( 'ZGOR_CLI_D' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_entorno->destroy( ).
  ENDMETHOD.

  METHOD setup.
    " Un cliente en la tabla doble
    TRY.
        mv_cliente = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( msg = 'No se pudo generar el UUID' ).
    ENDTRY.
    DATA lt_clientes TYPE STANDARD TABLE OF zgor_cli WITH EMPTY KEY.
    lt_clientes = VALUE #( ( cliente_uuid = mv_cliente cliente_id = 'CLI0001'
                             nombre = 'Juan' apellidos = 'Pérez López' nif = '12345678Z'
                             direccion = 'C/ Mayor 1, Madrid' telf = '600111222' ) ).
    go_entorno->insert_test_data( lt_clientes ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_entorno->clear_doubles( ).
  ENDMETHOD.

  METHOD crear_presupuesto.
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( ClienteUUID ) WITH VALUE #( ( %cid = 'P' ClienteUUID = mv_cliente ) )
        CREATE BY \_Lineas FIELDS ( Descripcion Uds Precio )
          WITH VALUE #( ( %cid_ref = 'P'
                          %target  = VALUE #( ( %cid = 'L' Descripcion = 'Reforma'
                                                Uds = iv_uds Precio = iv_precio ) ) ) )
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed msg = 'La creacion ha fallado' ).
    rv_uuid = ls_mapped-presupuesto[ 1 ]-PresupuestoUUID.
  ENDMETHOD.

  METHOD valores_por_defecto.
    DATA(lv_uuid) = crear_presupuesto( ).
    READ ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto FIELDS ( Iva Estado Fecha ) WITH VALUE #( ( PresupuestoUUID = lv_uuid ) )
      RESULT DATA(lt_presu).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Iva exp = CONV zgor_presu-iva( 21 ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Estado
                                        exp = CONV zgor_presu-estado( zif_gor_tipos=>estado_presu-no_aprobado ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Fecha exp = cl_abap_context_info=>get_system_date( ) ).
  ENDMETHOD.

  METHOD copia_datos_del_cliente.
    DATA(lv_uuid) = crear_presupuesto( ).
    READ ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto FIELDS ( NombreCliente Nif Telf ) WITH VALUE #( ( PresupuestoUUID = lv_uuid ) )
      RESULT DATA(lt_presu).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-NombreCliente
                                        exp = CONV zgor_presu-nombre_cliente( 'Juan Pérez López' ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Nif exp = CONV zgor_presu-nif( '12345678Z' ) ).
  ENDMETHOD.

  METHOD totales_desde_las_lineas.
    " Paso 2 de la seccion 12.7
    DATA(lv_uuid) = crear_presupuesto( ).
    READ ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto FIELDS ( BaseImponible CuotaIva Total ) WITH VALUE #( ( PresupuestoUUID = lv_uuid ) )
      RESULT DATA(lt_presu).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-BaseImponible exp = CONV zgor_presu-total( 1000 ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-CuotaIva      exp = CONV zgor_presu-total( 210 ) ).
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Total         exp = CONV zgor_presu-total( 1210 ) ).

    " Cambiar el IVA recalcula
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto UPDATE FIELDS ( Iva ) WITH VALUE #( ( PresupuestoUUID = lv_uuid Iva = 10 ) ).
    READ ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto FIELDS ( Total ) WITH VALUE #( ( PresupuestoUUID = lv_uuid ) )
      RESULT lt_presu.
    cl_abap_unit_assert=>assert_equals( act = lt_presu[ 1 ]-Total exp = CONV zgor_presu-total( 1100 ) ).
  ENDMETHOD.
ENDCLASS.
