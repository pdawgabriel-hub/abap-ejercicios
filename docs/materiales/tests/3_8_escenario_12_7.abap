" Unidad 3.8 - Escenario de la seccion 12.7 contra los objetos de negocio.
" Pegar en la pestana Test Classes de ZCL_GOR_ESCENARIO (clase global vacia, ZGOR_TEST).
" POCO VERIFICADO: el montaje de los dobles puede necesitar ajustes segun la version (ver 3.8).

"-----------------------------------------------------------------------
" Comportamiento: pasos 1, 2, 3, 4, 5, 9, 11 y 13
"-----------------------------------------------------------------------
CLASS ltcl_comportamiento DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_sql TYPE REF TO if_osql_test_environment.
    DATA mv_juan  TYPE sysuuid_x16.
    DATA mv_ana   TYPE sysuuid_x16.
    DATA mv_trab1 TYPE sysuuid_x16.
    DATA mv_trab2 TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS paso_01_obra_nueva      FOR TESTING RAISING cx_static_check.
    METHODS paso_02_03_presupuesto  FOR TESTING RAISING cx_static_check.
    METHODS paso_04_05_parte        FOR TESTING RAISING cx_static_check.
    METHODS paso_09_validaciones    FOR TESTING RAISING cx_static_check.
    METHODS paso_11_obra_con_cobros FOR TESTING RAISING cx_static_check.
    METHODS paso_13_otro_cliente    FOR TESTING RAISING cx_static_check.

    METHODS crear_obra
      IMPORTING iv_cliente     TYPE sysuuid_x16
      RETURNING VALUE(rv_obra) TYPE sysuuid_x16.
ENDCLASS.

CLASS ltcl_comportamiento IMPLEMENTATION.
  METHOD class_setup.
    go_sql = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
      ( 'ZGOR_CLI' )       ( 'ZGOR_CLI_D' )       ( 'ZGOR_CLI_OBS' )   ( 'ZGOR_CLI_OBS_D' )
      ( 'ZGOR_TRAB' )      ( 'ZGOR_TRAB_D' )      ( 'ZGOR_FALTA' )     ( 'ZGOR_FALTA_D' )
      ( 'ZGOR_PROV' )      ( 'ZGOR_ESP' )
      ( 'ZGOR_PRESU' )     ( 'ZGOR_PRESU_D' )     ( 'ZGOR_PRESU_LIN' ) ( 'ZGOR_PRESU_LIN_D' )
      ( 'ZGOR_PRESU_PV' )  ( 'ZGOR_PRESU_PV_D' )  ( 'ZGOR_PRESU_ES' )  ( 'ZGOR_PRESU_ES_D' )
      ( 'ZGOR_OBRA' )      ( 'ZGOR_OBRA_D' )      ( 'ZGOR_GASTO' )     ( 'ZGOR_GASTO_D' )
      ( 'ZGOR_ING' )       ( 'ZGOR_ING_D' )
      ( 'ZGOR_PT' )        ( 'ZGOR_PT_D' )        ( 'ZGOR_PT_LIN' )    ( 'ZGOR_PT_LIN_D' )
      ( 'ZGOR_PE' )        ( 'ZGOR_PE_D' )        ( 'ZGOR_PP' )        ( 'ZGOR_PP_D' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_sql->destroy( ).
  ENDMETHOD.

  METHOD setup.
    mv_juan  = cl_system_uuid=>create_uuid_x16_static( ).
    mv_ana   = cl_system_uuid=>create_uuid_x16_static( ).
    mv_trab1 = cl_system_uuid=>create_uuid_x16_static( ).
    mv_trab2 = cl_system_uuid=>create_uuid_x16_static( ).

    DATA lt_clientes TYPE STANDARD TABLE OF zgor_cli WITH EMPTY KEY.
    lt_clientes = VALUE #( ( cliente_uuid = mv_juan cliente_id = 'CLI0001' nombre = 'Juan'
                             apellidos = 'Pérez' direccion = 'C/ Mayor 1' telf = '600111222' )
                           ( cliente_uuid = mv_ana  cliente_id = 'CLI0002' nombre = 'Ana'
                             apellidos = 'Ruiz' direccion = 'C/ Sol 2' telf = '600333444' ) ).
    go_sql->insert_test_data( lt_clientes ).

    DATA lt_trabajadores TYPE STANDARD TABLE OF zgor_trab WITH EMPTY KEY.
    lt_trabajadores = VALUE #( ( trabajador_uuid = mv_trab1 trabajador_id = 'TRB0001' nombre = 'Pedro'
                                 apellido = 'Sánchez' coste_hora_estandar = 20 )
                               ( trabajador_uuid = mv_trab2 trabajador_id = 'TRB0002' nombre = 'Rosa'
                                 apellido = 'Martín' coste_hora_estandar = 20 ) ).
    go_sql->insert_test_data( lt_trabajadores ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_sql->clear_doubles( ).
  ENDMETHOD.

  METHOD crear_obra.
    MODIFY ENTITIES OF zi_gorobra
      ENTITY Obra CREATE FIELDS ( Descripcion ClienteUUID )
        WITH VALUE #( ( %cid = 'O' Descripcion = 'Reforma integral de bano' ClienteUUID = iv_cliente ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES RESPONSE OF zi_gorobra FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed msg = 'No se pudo crear la obra' ).
    rv_obra = ls_mapped-obra[ 1 ]-ObraUUID.
  ENDMETHOD.

  METHOD paso_01_obra_nueva.
    DATA(lv_obra) = crear_obra( mv_juan ).
    SELECT FROM zgor_gasto FIELDS gasto_id WHERE obra_uuid = @lv_obra INTO TABLE @DATA(lt_gastos).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_gastos ) exp = 1 msg = 'Una y solo una ficha' ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_gastos[ 1 ]-gasto_id msg = 'La ficha tiene codigo' ).
  ENDMETHOD.

  METHOD paso_02_03_presupuesto.
    DATA(lv_obra) = crear_obra( mv_juan ).
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( ClienteUUID ObraUUID ) WITH VALUE #( ( %cid = 'P' ClienteUUID = mv_juan ObraUUID = lv_obra ) )
        CREATE BY \_Lineas FIELDS ( Descripcion Uds Precio )
          WITH VALUE #( ( %cid_ref = 'P'
                          %target  = VALUE #( ( %cid = 'L' Descripcion = 'Reforma' Uds = 10 Precio = 100 ) ) ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed ).
    DATA(lv_presu) = ls_mapped-presupuesto[ 1 ]-PresupuestoUUID.

    SELECT SINGLE FROM zgor_presu FIELDS base_imponible, cuota_iva, total, estado
      WHERE presupuesto_uuid = @lv_presu INTO @DATA(ls_presu).
    cl_abap_unit_assert=>assert_equals( act = ls_presu-base_imponible exp = CONV zgor_presu-total( 1000 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_presu-cuota_iva      exp = CONV zgor_presu-total( 210 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_presu-total          exp = CONV zgor_presu-total( 1210 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_presu-estado         exp = CONV zgor_presu-estado( 'no_aprobado' ) ).

    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto EXECUTE aprobar FROM VALUE #( ( PresupuestoUUID = lv_presu ) ).
    COMMIT ENTITIES.
    SELECT SINGLE FROM zgor_presu FIELDS estado WHERE presupuesto_uuid = @lv_presu INTO @DATA(lv_estado).
    cl_abap_unit_assert=>assert_equals( act = lv_estado exp = CONV zgor_presu-estado( 'aprobado' ) ).
  ENDMETHOD.

  METHOD paso_04_05_parte.
    DATA(lv_obra) = crear_obra( mv_juan ).
    MODIFY ENTITIES OF zi_gorpartetrabajo
      ENTITY ParteTrabajo
        CREATE FIELDS ( ObraUUID Descripcion ) WITH VALUE #( ( %cid = 'PT' ObraUUID = lv_obra Descripcion = 'Demolicion' ) )
        CREATE BY \_Lineas FIELDS ( TrabajadorUUID Horas )
          WITH VALUE #( ( %cid_ref = 'PT'
                          %target  = VALUE #( ( %cid = 'L1' TrabajadorUUID = mv_trab1 Horas = 8 )
                                              ( %cid = 'L2' TrabajadorUUID = mv_trab2 Horas = 8 ) ) ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpartetrabajo FAILED DATA(ls_failed).
    cl_abap_unit_assert=>assert_initial( act = ls_failed ).

    " Paso 5: subir la tarifa no cambia las lineas ya registradas
    MODIFY ENTITIES OF zi_gortrabajador
      ENTITY Trabajador UPDATE FIELDS ( CosteHoraEstandar )
        WITH VALUE #( ( TrabajadorUUID = mv_trab1 CosteHoraEstandar = 25 ) ).
    COMMIT ENTITIES.

    SELECT FROM zgor_pt_lin FIELDS coste_hora, coste_subtotal INTO TABLE @DATA(lt_lineas).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_lineas ) exp = 2 ).
    LOOP AT lt_lineas INTO DATA(ls_linea).
      cl_abap_unit_assert=>assert_equals( act = ls_linea-coste_hora     exp = CONV zgor_pt_lin-coste_hora( 20 ) ).
      cl_abap_unit_assert=>assert_equals( act = ls_linea-coste_subtotal exp = CONV zgor_pt_lin-coste_subtotal( 160 ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD paso_09_validaciones.
    DATA(lv_obra) = crear_obra( mv_juan ).

    " Lineas de 25 h y de -1 h
    MODIFY ENTITIES OF zi_gorpartetrabajo
      ENTITY ParteTrabajo
        CREATE FIELDS ( ObraUUID Descripcion ) WITH VALUE #( ( %cid = 'PT' ObraUUID = lv_obra Descripcion = 'X' ) )
        CREATE BY \_Lineas FIELDS ( TrabajadorUUID Horas )
          WITH VALUE #( ( %cid_ref = 'PT'
                          %target  = VALUE #( ( %cid = 'L1' TrabajadorUUID = mv_trab1 Horas = 25 ) ) ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpartetrabajo FAILED DATA(ls_f1).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f1 msg = '25 h' ).
    ROLLBACK ENTITIES.

    MODIFY ENTITIES OF zi_gorpartetrabajo
      ENTITY ParteTrabajo
        CREATE FIELDS ( ObraUUID Descripcion ) WITH VALUE #( ( %cid = 'PT' ObraUUID = lv_obra Descripcion = 'X' ) )
        CREATE BY \_Lineas FIELDS ( TrabajadorUUID Horas )
          WITH VALUE #( ( %cid_ref = 'PT'
                          %target  = VALUE #( ( %cid = 'L1' TrabajadorUUID = mv_trab1 Horas = -1 ) ) ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpartetrabajo FAILED DATA(ls_f2).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f2 msg = '-1 h' ).
    ROLLBACK ENTITIES.

    " Parte de proveedor de 0 EUR
    MODIFY ENTITIES OF zi_gorparteprov
      ENTITY ParteProv CREATE FIELDS ( ObraUUID ProveedorUUID Importe )
        WITH VALUE #( ( %cid = 'PP' ObraUUID = lv_obra ProveedorUUID = cl_system_uuid=>create_uuid_x16_static( )
                        Importe = 0 ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorparteprov FAILED DATA(ls_f3).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f3 msg = 'Importe 0' ).
    ROLLBACK ENTITIES.

    " IVA 150
    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto CREATE FIELDS ( ClienteUUID Iva )
        WITH VALUE #( ( %cid = 'P' ClienteUUID = mv_juan Iva = 150 ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED DATA(ls_f4).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f4 msg = 'IVA 150' ).
    ROLLBACK ENTITIES.

    " Falta que termina antes de empezar
    MODIFY ENTITIES OF zi_gortrabajador
      ENTITY Trabajador CREATE BY \_Faltas FIELDS ( FechaInicio FechaFin Tipo )
        WITH VALUE #( ( TrabajadorUUID = mv_trab1
                        %target = VALUE #( ( %cid = 'F' FechaInicio = '20261110' FechaFin = '20261105'
                                             Tipo = 'vacaciones' ) ) ) ).
    COMMIT ENTITIES RESPONSE OF zi_gortrabajador FAILED DATA(ls_f5).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f5 msg = 'Falta al reves' ).
  ENDMETHOD.

  METHOD paso_11_obra_con_cobros.
    DATA(lv_obra) = crear_obra( mv_juan ).
    DATA lt_ingresos TYPE STANDARD TABLE OF zgor_ing WITH EMPTY KEY.
    lt_ingresos = VALUE #( ( ingreso_uuid = cl_system_uuid=>create_uuid_x16_static( )
                             obra_uuid = lv_obra importe = 500 ) ).
    go_sql->insert_test_data( lt_ingresos ).

    MODIFY ENTITIES OF zi_gorobra
      ENTITY Obra DELETE FROM VALUE #( ( ObraUUID = lv_obra ) )
      FAILED DATA(ls_failed).
    COMMIT ENTITIES.
    cl_abap_unit_assert=>assert_not_initial( act = ls_failed-obra ).
    SELECT COUNT( * ) FROM zgor_obra WHERE obra_uuid = @lv_obra INTO @DATA(lv_sigue).
    cl_abap_unit_assert=>assert_equals( act = lv_sigue exp = 1 ).
  ENDMETHOD.

  METHOD paso_13_otro_cliente.
    DATA(lv_obra) = crear_obra( mv_juan ).

    MODIFY ENTITIES OF zi_gorpresupuesto
      ENTITY Presupuesto CREATE FIELDS ( ClienteUUID ObraUUID )
        WITH VALUE #( ( %cid = 'P' ClienteUUID = mv_ana ObraUUID = lv_obra ) ).
    COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED DATA(ls_f1).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f1 msg = 'Presupuesto de otro cliente' ).
    ROLLBACK ENTITIES.

    MODIFY ENTITIES OF zi_goringreso
      ENTITY Ingreso CREATE FIELDS ( ObraUUID ClienteUUID Importe )
        WITH VALUE #( ( %cid = 'I' ObraUUID = lv_obra ClienteUUID = mv_ana Importe = 100 ) ).
    COMMIT ENTITIES RESPONSE OF zi_goringreso FAILED DATA(ls_f2).
    cl_abap_unit_assert=>assert_not_initial( act = ls_f2 msg = 'Ingreso de otro cliente' ).
  ENDMETHOD.
ENDCLASS.

"-----------------------------------------------------------------------
" Finanzas: pasos 6, 7 y 8 sobre ZI_GorObraFinanzas
"-----------------------------------------------------------------------
CLASS ltcl_finanzas DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_cds TYPE REF TO if_cds_test_environment.
    DATA mv_obra TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup RAISING cx_static_check.

    METHODS paso_06_gastos       FOR TESTING RAISING cx_static_check.
    METHODS paso_07_primer_cobro FOR TESTING RAISING cx_static_check.
    METHODS paso_08_obra_cobrada FOR TESTING RAISING cx_static_check.

    METHODS cobrar
      IMPORTING iv_importe TYPE zgor_ing-importe
      RAISING   cx_static_check.
    METHODS leer_ficha
      RETURNING VALUE(rs_ficha) TYPE zi_gorobrafinanzas.
ENDCLASS.

CLASS ltcl_finanzas IMPLEMENTATION.
  METHOD class_setup.
    go_cds = cl_cds_test_environment=>create( i_for_entity               = 'ZI_GOROBRAFINANZAS'
                                              i_select_base_dependencies = abap_true ).
  ENDMETHOD.

  METHOD class_teardown.
    go_cds->destroy( ).
  ENDMETHOD.

  METHOD setup.
    go_cds->clear_doubles( ).
    mv_obra = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_parte) = cl_system_uuid=>create_uuid_x16_static( ).

    DATA lt_obras TYPE STANDARD TABLE OF zgor_obra WITH EMPTY KEY.
    lt_obras = VALUE #( ( obra_uuid = mv_obra obra_id = 'OBR0001' ) ).
    go_cds->insert_test_data( i_data = lt_obras ).

    " Pasos 2 y 3: presupuesto aprobado de 1210 (y otro sin aprobar que no cuenta)
    DATA lt_presu TYPE STANDARD TABLE OF zgor_presu WITH EMPTY KEY.
    lt_presu = VALUE #( ( presupuesto_uuid = cl_system_uuid=>create_uuid_x16_static( )
                          obra_uuid = mv_obra estado = 'aprobado' total = 1210 )
                        ( presupuesto_uuid = cl_system_uuid=>create_uuid_x16_static( )
                          obra_uuid = mv_obra estado = 'no_aprobado' total = 500 ) ).
    go_cds->insert_test_data( i_data = lt_presu ).

    " Paso 4: dos lineas de 8 h a 20
    DATA lt_partes TYPE STANDARD TABLE OF zgor_pt WITH EMPTY KEY.
    lt_partes = VALUE #( ( parte_uuid = lv_parte obra_uuid = mv_obra ) ).
    go_cds->insert_test_data( i_data = lt_partes ).
    DATA lt_lineas TYPE STANDARD TABLE OF zgor_pt_lin WITH EMPTY KEY.
    lt_lineas = VALUE #( ( linea_uuid = cl_system_uuid=>create_uuid_x16_static( ) parte_uuid = lv_parte
                           horas = 8 coste_hora = 20 coste_subtotal = 160 )
                         ( linea_uuid = cl_system_uuid=>create_uuid_x16_static( ) parte_uuid = lv_parte
                           horas = 8 coste_hora = 20 coste_subtotal = 160 ) ).
    go_cds->insert_test_data( i_data = lt_lineas ).

    " Paso 6: proveedor 200 y especialista 150
    DATA lt_pp TYPE STANDARD TABLE OF zgor_pp WITH EMPTY KEY.
    lt_pp = VALUE #( ( parte_uuid = cl_system_uuid=>create_uuid_x16_static( ) obra_uuid = mv_obra importe = 200 ) ).
    go_cds->insert_test_data( i_data = lt_pp ).
    DATA lt_pe TYPE STANDARD TABLE OF zgor_pe WITH EMPTY KEY.
    lt_pe = VALUE #( ( parte_uuid = cl_system_uuid=>create_uuid_x16_static( ) obra_uuid = mv_obra importe = 150 ) ).
    go_cds->insert_test_data( i_data = lt_pe ).
  ENDMETHOD.

  METHOD cobrar.
    DATA lt_ingresos TYPE STANDARD TABLE OF zgor_ing WITH EMPTY KEY.
    lt_ingresos = VALUE #( ( ingreso_uuid = cl_system_uuid=>create_uuid_x16_static( )
                             obra_uuid = mv_obra importe = iv_importe ) ).
    go_cds->insert_test_data( i_data = lt_ingresos ).
  ENDMETHOD.

  METHOD leer_ficha.
    SELECT SINGLE FROM zi_gorobrafinanzas FIELDS *
      WHERE ObraUUID = @mv_obra INTO @rs_ficha.
    cl_abap_unit_assert=>assert_subrc( act = sy-subrc exp = 0 msg = 'La obra no esta en la vista' ).
  ENDMETHOD.

  METHOD paso_06_gastos.
    DATA(ls_ficha) = leer_ficha( ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Total      exp = CONV zgor_presu-total( 1210 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Gastos     exp = CONV zgor_presu-total( 670 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-EstadoPago exp = CONV zi_gorobrafinanzas-EstadoPago( 'pendiente' ) ).
  ENDMETHOD.

  METHOD paso_07_primer_cobro.
    cobrar( 500 ).
    DATA(ls_ficha) = leer_ficha( ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Ingresos          exp = CONV zgor_presu-total( 500 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-BeneficioReal     exp = CONV zgor_presu-total( -170 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Debe              exp = CONV zgor_presu-total( 710 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-MargenProyectado  exp = CONV zgor_presu-total( 540 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-PorcentajeCobrado exp = CONV zi_gorobrafinanzas-PorcentajeCobrado( '41.3' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-EstadoPago        exp = CONV zi_gorobrafinanzas-EstadoPago( 'parcial' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Salud             exp = CONV zi_gorobrafinanzas-Salud( 'rojo' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-EstadoGasto       exp = CONV zi_gorobrafinanzas-EstadoGasto( 'proceso' ) ).
  ENDMETHOD.

  METHOD paso_08_obra_cobrada.
    cobrar( 500 ).
    cobrar( 710 ).
    DATA(ls_ficha) = leer_ficha( ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Ingresos          exp = CONV zgor_presu-total( 1210 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-BeneficioReal     exp = CONV zgor_presu-total( 540 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Debe              exp = CONV zgor_presu-total( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-PorcentajeCobrado exp = CONV zi_gorobrafinanzas-PorcentajeCobrado( 100 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-EstadoPago        exp = CONV zi_gorobrafinanzas-EstadoPago( 'pagado' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-Salud             exp = CONV zi_gorobrafinanzas-Salud( 'verde' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_ficha-EstadoGasto       exp = CONV zi_gorobrafinanzas-EstadoGasto( 'finalizado' ) ).
  ENDMETHOD.
ENDCLASS.
