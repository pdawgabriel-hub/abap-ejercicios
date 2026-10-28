" Tests del escenario ORD0001 con dobles: no tocan los datos reales (3.8)

" ---------------------------------------------------------------------
" 1. La hoja de costes, leyendo la vista ZI_TlOrdenResumen con dobles de sus tablas
" ---------------------------------------------------------------------
CLASS ltcl_resumen DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    " El entorno de dobles: uno para toda la clase (CLASS-DATA)
    CLASS-DATA go_cds TYPE REF TO if_cds_test_environment.
    CLASS-METHODS class_setup.                       " una vez, al empezar
    CLASS-METHODS class_teardown.                    " una vez, al terminar
    METHODS setup.                                   " antes de cada test
    METHODS paso_5_primer_abono FOR TESTING RAISING cx_static_check.
    METHODS paso_6_liquidada FOR TESTING RAISING cx_static_check.
    METHODS orden_sin_nada FOR TESTING RAISING cx_static_check.
    " Una lista de importes (los abonos)
    TYPES tt_importes TYPE STANDARD TABLE OF zif_tl_tipos=>ty_euros WITH EMPTY KEY.
    " Ayuda: los datos de los pasos 1 a 4 y los abonos que se pidan
    METHODS preparar_orden
      IMPORTING it_abonos       TYPE tt_importes OPTIONAL
      RETURNING VALUE(rv_orden) TYPE sysuuid_x16
      RAISING   cx_static_check.
ENDCLASS.

CLASS ltcl_resumen IMPLEMENTATION.
  METHOD class_setup.
    " Dobla la vista y todo lo que hay debajo (vistas y tablas)
    go_cds = cl_cds_test_environment=>create( i_for_entity               = 'ZI_TLORDENRESUMEN'
                                              i_select_base_dependencies = abap_true ).
  ENDMETHOD.

  METHOD class_teardown.
    go_cds->destroy( ).                              " quitar los dobles
  ENDMETHOD.

  METHOD setup.
    go_cds->clear_doubles( ).
  ENDMETHOD.

  METHOD preparar_orden.
    " Pasos 1 a 4 del caso: presupuesto aceptado de 605, tramos de 160, albaran 180, factura 60
    rv_orden = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_ordenes TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ordenes = VALUE #( ( orden_uuid = rv_orden orden_ref = 'ORD0001' ) ).
    go_cds->insert_test_data( i_data = lt_ordenes ).

    DATA lt_prs TYPE STANDARD TABLE OF ztl_prs WITH EMPTY KEY.
    lt_prs = VALUE #( ( presupuesto_uuid = cl_system_uuid=>create_uuid_x16_static( )
                        orden_uuid = rv_orden situacion = 'aceptado' importe = 605 ) ).
    go_cds->insert_test_data( i_data = lt_prs ).

    DATA(lv_jornada) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_jor TYPE STANDARD TABLE OF ztl_jor WITH EMPTY KEY.
    lt_jor = VALUE #( ( jornada_uuid = lv_jornada orden_uuid = rv_orden ) ).
    go_cds->insert_test_data( i_data = lt_jor ).
    DATA lt_tra TYPE STANDARD TABLE OF ztl_jor_tra WITH EMPTY KEY.
    lt_tra = VALUE #( ( tramo_uuid = cl_system_uuid=>create_uuid_x16_static( ) jornada_uuid = lv_jornada
                        tiempo = 3 coste_tramo = 90 )
                      ( tramo_uuid = cl_system_uuid=>create_uuid_x16_static( ) jornada_uuid = lv_jornada
                        tiempo = 2 coste_tramo = 70 ) ).
    go_cds->insert_test_data( i_data = lt_tra ).

    DATA lt_alb TYPE STANDARD TABLE OF ztl_alb WITH EMPTY KEY.
    lt_alb = VALUE #( ( albaran_uuid = cl_system_uuid=>create_uuid_x16_static( ) orden_uuid = rv_orden
                        importe_neto = 180 ) ).
    go_cds->insert_test_data( i_data = lt_alb ).
    DATA lt_fac TYPE STANDARD TABLE OF ztl_fac WITH EMPTY KEY.
    lt_fac = VALUE #( ( factura_uuid = cl_system_uuid=>create_uuid_x16_static( ) orden_uuid = rv_orden
                        importe_neto = 60 ) ).
    go_cds->insert_test_data( i_data = lt_fac ).

    " Los abonos que pida el test
    DATA lt_abo TYPE STANDARD TABLE OF ztl_abo WITH EMPTY KEY.
    LOOP AT it_abonos INTO DATA(lv_abono).
      APPEND VALUE #( abono_uuid = cl_system_uuid=>create_uuid_x16_static( ) orden_uuid = rv_orden
                      cantidad_abonada = lv_abono ) TO lt_abo.
    ENDLOOP.
    IF lt_abo IS NOT INITIAL.
      go_cds->insert_test_data( i_data = lt_abo ).
    ENDIF.
  ENDMETHOD.

  METHOD paso_5_primer_abono.
    " Preparar: los datos minimos del caso, en las copias de las tablas
    DATA(lv_orden) = preparar_orden( VALUE #( ( 300 ) ) ).

    " Ejecutar: leer la vista como lo haria la app
    SELECT SINGLE FROM zi_tlordenresumen FIELDS Rendimiento, SaldoPendiente, Semaforo, EstadoHoja
      WHERE OrdenUUID = @lv_orden INTO @DATA(ls_resumen).

    " Comprobar: los valores esperados de ORD0001 tras el primer abono
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Rendimiento    exp = CONV ztl_prs-importe( -100 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-SaldoPendiente exp = CONV ztl_prs-importe( 305 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Semaforo       exp = CONV zi_tlordenresumen-Semaforo( 'rojo' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-EstadoHoja     exp = CONV zi_tlordenresumen-EstadoHoja( 'abierta' ) ).
  ENDMETHOD.

  METHOD paso_6_liquidada.
    DATA(lv_orden) = preparar_orden( VALUE #( ( 300 ) ( 305 ) ) ).
    SELECT SINGLE FROM zi_tlordenresumen FIELDS Rendimiento, SaldoPendiente, PorcentajeLiquidado, Semaforo, EstadoHoja
      WHERE OrdenUUID = @lv_orden INTO @DATA(ls_resumen).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Rendimiento    exp = CONV ztl_prs-importe( 205 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-SaldoPendiente exp = CONV ztl_prs-importe( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-PorcentajeLiquidado
                                        exp = CONV zi_tlordenresumen-PorcentajeLiquidado( 100 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Semaforo       exp = CONV zi_tlordenresumen-Semaforo( 'verde' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-EstadoHoja     exp = CONV zi_tlordenresumen-EstadoHoja( 'cerrada' ) ).
  ENDMETHOD.

  METHOD orden_sin_nada.
    " Una orden sin presupuestos ni costes no desaparece (left outer join) y vale 0
    DATA(lv_orden) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_ordenes TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ordenes = VALUE #( ( orden_uuid = lv_orden orden_ref = 'ORD0009' ) ).
    go_cds->insert_test_data( i_data = lt_ordenes ).
    SELECT SINGLE FROM zi_tlordenresumen FIELDS Importe, Semaforo WHERE OrdenUUID = @lv_orden INTO @DATA(ls_resumen).
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Importe  exp = CONV ztl_prs-importe( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Semaforo exp = CONV zi_tlordenresumen-Semaforo( 'ambar' ) ).
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------
" 2. El comportamiento: EML contra los objetos de negocio, con las tablas dobladas
" ---------------------------------------------------------------------
CLASS ltcl_comportamiento DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_sql TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS paso_1_presupuesto FOR TESTING.
    METHODS impuesto_150_rechazado FOR TESTING.
    METHODS tramo_de_11_horas FOR TESTING.
    DATA mv_titular TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_comportamiento IMPLEMENTATION.
  METHOD class_setup.
    " Las tablas (y las de borradores) de los BO que intervienen: todo lo que lean o escriban va a copias
    go_sql = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZTL_TIT' ) ( 'ZTL_TIT_D' ) ( 'ZTL_PRS' ) ( 'ZTL_PRS_D' ) ( 'ZTL_PRS_PAR' ) ( 'ZTL_PRS_PAR_D' )
      ( 'ZTL_PRS_DIS' ) ( 'ZTL_PRS_DIS_D' ) ( 'ZTL_PRS_NOT' ) ( 'ZTL_PRS_NOT_D' ) ( 'ZTL_PRS_AVI' )
      ( 'ZTL_PRS_AVI_D' ) ( 'ZTL_PRS_FOT' ) ( 'ZTL_PRS_FOT_D' ) ( 'ZTL_ORDEN' ) ( 'ZTL_ORDEN_D' )
      ( 'ZTL_HCO' ) ( 'ZTL_HCO_D' ) ( 'ZTL_JOR' ) ( 'ZTL_JOR_D' ) ( 'ZTL_JOR_TRA' ) ( 'ZTL_JOR_TRA_D' )
      ( 'ZTL_MEC' ) ( 'ZTL_MEC_D' ) ( 'ZTL_FESTIVO' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_sql->destroy( ).
  ENDMETHOD.

  METHOD setup.
    go_sql->clear_doubles( ).
    " Un titular de partida, insertado directamente en su doble
    TRY.
        mv_titular = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Sin UUID' ).
    ENDTRY.
    DATA lt_tit TYPE STANDARD TABLE OF ztl_tit WITH EMPTY KEY.
    lt_tit = VALUE #( ( titular_uuid = mv_titular titular_ref = 'TIT0001' razon_social = 'Transportes Moncayo SL'
                        documento_id = 'B50111222' contacto = '976111222' ) ).
    go_sql->insert_test_data( lt_tit ).
  ENDMETHOD.

  METHOD paso_1_presupuesto.
    " Crear el presupuesto con sus dos partidas, sin impuesto: lo pone valoresIniciales
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( TitularUUID ) WITH VALUE #( ( %cid = 'p1' TitularUUID = mv_titular ) )
        CREATE BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario )
          WITH VALUE #( ( %cid_ref = 'p1'
                          %target  = VALUE #( ( %cid = 'a' Concepto = 'Diagnosis' Cantidad = 4 PrecioUnitario = 45 )
                                              ( %cid = 'b' Concepto = 'Embrague'  Cantidad = 1 PrecioUnitario = 320 ) ) ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES RESPONSE OF zi_tlpresupuesto FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed msg = 'No se ha guardado' ).

    SELECT SINGLE FROM ztl_prs FIELDS impuesto, situacion, titular_nombre, neto, cuota, importe, presupuesto_ref
      WHERE presupuesto_uuid = @( ls_mapped-presupuesto[ 1 ]-PresupuestoUUID )
      INTO @DATA(ls_prs).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-impuesto       exp = CONV ztl_prs-impuesto( 21 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-situacion      exp = CONV ztl_prs-situacion( 'borrador' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-titular_nombre exp = CONV ztl_prs-titular_nombre( 'Transportes Moncayo SL' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-neto           exp = CONV ztl_prs-neto( 500 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-importe        exp = CONV ztl_prs-importe( 605 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_prs-presupuesto_ref exp = CONV ztl_prs-presupuesto_ref( 'PRS0001' ) ).
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD impuesto_150_rechazado.
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto CREATE FIELDS ( TitularUUID Impuesto )
        WITH VALUE #( ( %cid = 'p1' TitularUUID = mv_titular Impuesto = 150 ) ).
    COMMIT ENTITIES RESPONSE OF zi_tlpresupuesto FAILED DATA(ls_failed) REPORTED DATA(ls_reported).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-presupuesto ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_reported-presupuesto ).
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD tramo_de_11_horas.
    " Una orden y un mecanico de partida
    DATA(lv_orden) = VALUE sysuuid_x16( ).
    DATA(lv_mecanico) = VALUE sysuuid_x16( ).
    TRY.
        lv_orden = cl_system_uuid=>create_uuid_x16_static( ).
        lv_mecanico = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Sin UUID' ).
    ENDTRY.
    DATA lt_ord TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ord = VALUE #( ( orden_uuid = lv_orden orden_ref = 'ORD0001' matricula = '1234ABC' titular_uuid = mv_titular ) ).
    go_sql->insert_test_data( lt_ord ).
    DATA lt_mec TYPE STANDARD TABLE OF ztl_mec WITH EMPTY KEY.
    lt_mec = VALUE #( ( mecanico_uuid = lv_mecanico mecanico_ref = 'MEC0001' nombre = 'Rosa' tarifa_base = 30 ) ).
    go_sql->insert_test_data( lt_mec ).

    MODIFY ENTITIES OF zi_tljornada
      ENTITY Jornada
        CREATE FIELDS ( OrdenUUID Dia ) WITH VALUE #( ( %cid = 'j' OrdenUUID = lv_orden Dia = '20261003' ) )
        CREATE BY \_Tramos FIELDS ( MecanicoUUID Tiempo )
          WITH VALUE #( ( %cid_ref = 'j' %target = VALUE #( ( %cid = 't' MecanicoUUID = lv_mecanico Tiempo = 11 ) ) ) ).
    COMMIT ENTITIES RESPONSE OF zi_tljornada FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-tramo msg = 'Un tramo de 11 h no deberia guardarse' ).
    ROLLBACK ENTITIES.
  ENDMETHOD.
ENDCLASS.
