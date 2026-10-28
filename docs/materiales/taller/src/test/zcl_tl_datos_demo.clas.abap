" Datos de demo del taller (2.5): el caso ORD0001 completo y otras dos ordenes.
" Cada ejecucion vacia las tablas y las vuelve a llenar: solo en tu sistema de pruebas.
CLASS zcl_tl_datos_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    " Una pareja codigo -> UUID: 'TIT0001' -> el UUID que se le genero
    TYPES: BEGIN OF ty_uuid,
             ref  TYPE string,
             uuid TYPE sysuuid_x16,
           END OF ty_uuid.
    " Hashed: se busca siempre por el codigo completo, y rapido
    DATA mt_uuids TYPE HASHED TABLE OF ty_uuid WITH UNIQUE KEY ref.

    " nuevo: crea un UUID para un codigo; de: devuelve el que ya se creo
    METHODS nuevo
      IMPORTING iv_ref         TYPE string
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    METHODS de
      IMPORTING iv_ref         TYPE string
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.

    " Un metodo por grupo de datos, en el orden en que se llaman
    METHODS vaciar.
    METHODS crear_fichas.
    METHODS crear_caso_ord0001.
    METHODS crear_otras_ordenes.
    METHODS sellar.

    " Ayuda: crea un presupuesto con sus partidas, con los importes calculados
    METHODS crear_presupuesto
      IMPORTING iv_ref       TYPE string
                iv_fecha     TYPE d
                iv_titular   TYPE string
                iv_orden     TYPE string OPTIONAL
                iv_situacion TYPE zif_tl_tipos=>ty_situacion
                it_partidas  TYPE zif_tl_tipos=>tt_partidas.
ENDCLASS.


CLASS zcl_tl_datos_demo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Primero se borra todo: asi la clase se puede ejecutar las veces que haga falta
    vaciar( ).
    " Despues, de lo que no depende de nada a lo que depende de otros
    crear_fichas( ).
    crear_caso_ord0001( ).
    crear_otras_ordenes( ).
    sellar( ).
    out->write( |Datos del taller creados: { lines( mt_uuids ) } registros| ).
  ENDMETHOD.

  METHOD nuevo.
    " Genera un UUID y lo apunta con su referencia para usarlo despues
    TRY.
        rv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.
    INSERT VALUE #( ref = iv_ref uuid = rv_uuid ) INTO TABLE mt_uuids.
  ENDMETHOD.

  METHOD de.
    " Si el codigo no existe, lanza cx_sy_itab_line_not_found: un error en los datos se ve enseguida
    rv_uuid = mt_uuids[ ref = iv_ref ]-uuid.
  ENDMETHOD.

  METHOD vaciar.
    " Primero las hijas, despues las raices
    DELETE FROM ztl_jor_tra.
    DELETE FROM ztl_jor.
    DELETE FROM ztl_alb.
    DELETE FROM ztl_fac.
    DELETE FROM ztl_abo.
    DELETE FROM ztl_prs_par.
    DELETE FROM ztl_prs_dis.
    DELETE FROM ztl_prs_not.
    DELETE FROM ztl_prs_avi.
    DELETE FROM ztl_prs_fot.
    DELETE FROM ztl_prs.
    DELETE FROM ztl_hco.
    DELETE FROM ztl_ord_not.
    DELETE FROM ztl_ord_avi.
    DELETE FROM ztl_ord_fot.
    DELETE FROM ztl_orden.
    DELETE FROM ztl_aus.
    DELETE FROM ztl_mec.
    DELETE FROM ztl_dis.
    DELETE FROM ztl_sub.
    DELETE FROM ztl_tit.
  ENDMETHOD.

  METHOD crear_fichas.
    " Titulares
    DATA lt_titulares TYPE STANDARD TABLE OF ztl_tit WITH EMPTY KEY.
    lt_titulares = VALUE #(
      ( titular_uuid = nuevo( `TIT0001` ) titular_ref = 'TIT0001' razon_social = 'Transportes Moncayo SL'
        documento_id = 'B50111222' contacto = '976111222' poblacion = 'Zaragoza' cp = '50001' pais = 'ES' )
      ( titular_uuid = nuevo( `TIT0002` ) titular_ref = 'TIT0002' razon_social = 'Autoescuela Pilar'
        documento_id = 'B50999888' contacto = '976333444' poblacion = 'Zaragoza' cp = '50003' pais = 'ES' )
      ( titular_uuid = nuevo( `TIT0003` ) titular_ref = 'TIT0003' razon_social = 'Laura Gimeno Sanz'
        documento_id = '25123456K' contacto = '600123123' poblacion = 'Huesca' cp = '22001' pais = 'ES' ) ).
    INSERT ztl_tit FROM TABLE @lt_titulares.

    " Mecanicos y una ausencia
    DATA lt_mecanicos TYPE STANDARD TABLE OF ztl_mec WITH EMPTY KEY.
    lt_mecanicos = VALUE #(
      ( mecanico_uuid = nuevo( `MEC0001` ) mecanico_ref = 'MEC0001' nombre = 'Rosa' apellidos = 'Garcia Ruiz'
        categoria = 'Oficial' tarifa_base = 30 )
      ( mecanico_uuid = nuevo( `MEC0002` ) mecanico_ref = 'MEC0002' nombre = 'Diego' apellidos = 'Lopez Marin'
        categoria = 'Oficial' tarifa_base = 35 )
      ( mecanico_uuid = nuevo( `MEC0003` ) mecanico_ref = 'MEC0003' nombre = 'Ines' apellidos = 'Sanz Pardo'
        categoria = 'Ayudante' tarifa_base = 22 ) ).
    INSERT ztl_mec FROM TABLE @lt_mecanicos.

    DATA(ls_ausencia) = VALUE ztl_aus( ausencia_uuid = nuevo( `AUS-1` ) mecanico_uuid = de( `MEC0003` )
                                       desde = '20261102' hasta = '20261106' motivo = 'Vacaciones'
                                       jornadas = zcl_tl_calculos=>jornadas_ausencia(
                                                    iv_desde = '20261102' iv_hasta = '20261106' ) ).
    INSERT ztl_aus FROM @ls_ausencia.

    " Distribuidor y subcontrata: el bruto se calcula con la clase de reglas
    DATA(ls_distribuidor) = VALUE ztl_dis( distribuidor_uuid = nuevo( `DIS0001` ) distribuidor_ref = 'DIS0001'
                                           nombre = 'Recambios Ebro' neto = 100 impuesto = 21
                                           bruto = zcl_tl_calculos=>importe_presupuesto( iv_neto     = 100
                                                                                         iv_impuesto = 21 ) ).
    INSERT ztl_dis FROM @ls_distribuidor.
    DATA(ls_subcontrata) = VALUE ztl_sub( subcontrata_uuid = nuevo( `SUB0001` ) subcontrata_ref = 'SUB0001'
                                          nombre = 'Electricidad Rapida' oficio = 'Electricista'
                                          tarifa_referencia = 40 ).
    INSERT ztl_sub FROM @ls_subcontrata.
  ENDMETHOD.

  METHOD crear_caso_ord0001.
    " La orden y su hoja de costes
    DATA(ls_orden) = VALUE ztl_orden( orden_uuid = nuevo( `ORD0001` ) orden_ref = 'ORD0001'
                                      matricula = '1234ABC' averia = 'Patina el embrague'
                                      titular_uuid = de( `TIT0001` ) ).
    INSERT ztl_orden FROM @ls_orden.
    DATA(ls_hoja) = VALUE ztl_hco( hoja_uuid = nuevo( `HCO0001` ) orden_uuid = de( `ORD0001` )
                                   hoja_ref = 'HCO0001' fecha_entrada = '20261002' ).
    INSERT ztl_hco FROM @ls_hoja.

    " Pasos 1 y 2: el presupuesto aceptado (neto 500, cuota 105, importe 605)
    crear_presupuesto( iv_ref       = `PRS0001`
                       iv_fecha     = '20261002'
                       iv_titular   = `TIT0001`
                       iv_orden     = `ORD0001`
                       iv_situacion = zif_tl_tipos=>situacion_presupuesto-aceptado
                       it_partidas  = VALUE #( ( concepto = `Horas de diagnosis` cantidad = 4 precio_unitario = 45 )
                                               ( concepto = `Kit de embrague`    cantidad = 1 precio_unitario = 320 ) ) ).

    " Paso 3: la jornada, con la tarifa de cada mecanico COPIADA en el tramo
    DATA(lt_tramos) = VALUE zif_tl_tipos=>tt_tramos( ( mecanico = 'MEC0001' tiempo = 3 tarifa_aplicada = 30 )
                                                     ( mecanico = 'MEC0002' tiempo = 2 tarifa_aplicada = 35 ) ).
    DATA(ls_jornada) = VALUE ztl_jor( jornada_uuid = nuevo( `JOR-1` ) orden_uuid = de( `ORD0001` )
                                      dia = '20261003' trabajo = 'Diagnosis y cambio de embrague'
                                      tiempo_total = REDUCE #( INIT t = CONV zif_tl_tipos=>ty_tiempo( 0 )
                                                               FOR ls IN lt_tramos NEXT t = t + ls-tiempo )
                                      coste_total = zcl_tl_calculos=>coste_jornada( lt_tramos ) ).
    INSERT ztl_jor FROM @ls_jornada.
    DATA lt_tra TYPE STANDARD TABLE OF ztl_jor_tra WITH EMPTY KEY.
    lt_tra = VALUE #( FOR ls_tramo IN lt_tramos INDEX INTO lv_i
                      ( tramo_uuid      = nuevo( |JOR-1-{ lv_i }| )
                        jornada_uuid    = de( `JOR-1` )
                        mecanico_uuid   = de( CONV string( ls_tramo-mecanico ) )
                        tiempo          = ls_tramo-tiempo
                        tarifa_aplicada = ls_tramo-tarifa_aplicada
                        coste_tramo     = zcl_tl_calculos=>coste_tramo( iv_tiempo = ls_tramo-tiempo
                                                                        iv_tarifa = ls_tramo-tarifa_aplicada ) ) ).
    INSERT ztl_jor_tra FROM TABLE @lt_tra.

    " Paso 4: albaran de recambios y factura de subcontrata
    DATA(ls_albaran) = VALUE ztl_alb( albaran_uuid = nuevo( `ALB-1` ) orden_uuid = de( `ORD0001` )
                                      distribuidor_uuid = de( `DIS0001` ) fecha = '20261003' importe_neto = 180 ).
    INSERT ztl_alb FROM @ls_albaran.
    DATA(ls_factura) = VALUE ztl_fac( factura_uuid = nuevo( `FAC-1` ) orden_uuid = de( `ORD0001` )
                                      subcontrata_uuid = de( `SUB0001` ) fecha = '20261004' importe_neto = 60 ).
    INSERT ztl_fac FROM @ls_factura.

    " Pasos 5 y 6: los dos abonos
    DATA lt_abonos TYPE STANDARD TABLE OF ztl_abo WITH EMPTY KEY.
    lt_abonos = VALUE #(
      ( abono_uuid = nuevo( `ABO0001` ) abono_ref = 'ABO0001' orden_uuid = de( `ORD0001` )
        titular_uuid = de( `TIT0001` ) fecha = '20261005' cantidad_abonada = 300 medio_pago = 'tarjeta' )
      ( abono_uuid = nuevo( `ABO0002` ) abono_ref = 'ABO0002' orden_uuid = de( `ORD0001` )
        titular_uuid = de( `TIT0001` ) fecha = '20261010' cantidad_abonada = 305 medio_pago = 'transferencia' ) ).
    INSERT ztl_abo FROM TABLE @lt_abonos.
  ENDMETHOD.

  METHOD crear_otras_ordenes.
    " ORD0002: de la autoescuela, con el presupuesto aun en borrador (la orden vale 0)
    DATA lt_ordenes TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ordenes = VALUE #(
      ( orden_uuid = nuevo( `ORD0002` ) orden_ref = 'ORD0002' matricula = '5678DEF' averia = 'Revision de los 60000 km'
        titular_uuid = de( `TIT0002` ) )
      ( orden_uuid = nuevo( `ORD0003` ) orden_ref = 'ORD0003' matricula = '9012GHI' averia = 'Ruido al frenar'
        titular_uuid = de( `TIT0003` ) ) ).
    INSERT ztl_orden FROM TABLE @lt_ordenes.

    DATA lt_hojas TYPE STANDARD TABLE OF ztl_hco WITH EMPTY KEY.
    lt_hojas = VALUE #( ( hoja_uuid = nuevo( `HCO0002` ) orden_uuid = de( `ORD0002` ) hoja_ref = 'HCO0002'
                          fecha_entrada = '20261012' )
                        ( hoja_uuid = nuevo( `HCO0003` ) orden_uuid = de( `ORD0003` ) hoja_ref = 'HCO0003'
                          fecha_entrada = '20261015' garantia = abap_true ) ).
    INSERT ztl_hco FROM TABLE @lt_hojas.

    crear_presupuesto( iv_ref       = `PRS0002`
                       iv_fecha     = '20261012'
                       iv_titular   = `TIT0002`
                       iv_orden     = `ORD0002`
                       iv_situacion = zif_tl_tipos=>situacion_presupuesto-borrador
                       it_partidas  = VALUE #( ( concepto = `Revision completa` cantidad = 1 precio_unitario = 150 ) ) ).

    " PRS0003: de Laura, todavia sin orden (para probar la accion vincularAOrden de 3.5)
    crear_presupuesto( iv_ref       = `PRS0003`
                       iv_fecha     = '20261014'
                       iv_titular   = `TIT0003`
                       iv_situacion = zif_tl_tipos=>situacion_presupuesto-borrador
                       it_partidas  = VALUE #( ( concepto = `Pastillas de freno` cantidad = 2 precio_unitario = '35.50' )
                                               ( concepto = `Mano de obra`       cantidad = 1 precio_unitario = 60 ) ) ).
  ENDMETHOD.

  METHOD crear_presupuesto.
    " 1. Lo que se guarda calculado, con la clase de reglas (no a mano)
    DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( it_partidas ).

    " 2. La cabecera: nuevo( ) crea su UUID; de( ) busca los que ya existen
    SELECT SINGLE FROM ztl_tit FIELDS razon_social, documento_id
      WHERE titular_uuid = @( de( iv_titular ) )
      INTO @DATA(ls_titular).
    DATA(ls_presupuesto) = VALUE ztl_prs(
      presupuesto_uuid  = nuevo( iv_ref )
      presupuesto_ref   = iv_ref
      fecha             = iv_fecha
      titular_uuid      = de( iv_titular )
      orden_uuid        = COND #( WHEN iv_orden IS NOT INITIAL THEN de( iv_orden ) )
      " copia de los datos del titular, como en el presupuesto real
      titular_nombre    = ls_titular-razon_social
      titular_documento = ls_titular-documento_id
      impuesto          = 21
      situacion         = iv_situacion
      neto              = lv_neto
      cuota             = zcl_tl_calculos=>cuota_impuesto( iv_neto = lv_neto iv_impuesto = 21 )
      importe           = zcl_tl_calculos=>importe_presupuesto( iv_neto = lv_neto iv_impuesto = 21 ) ).
    INSERT ztl_prs FROM @ls_presupuesto.

    " 3. Las partidas: FOR recorre la tabla; INDEX INTO da 1, 2...
    "    para que cada partida tenga su propia referencia (PRS0001-1, PRS0001-2)
    DATA lt_par TYPE STANDARD TABLE OF ztl_prs_par WITH EMPTY KEY.
    lt_par = VALUE #( FOR ls_partida IN it_partidas INDEX INTO lv_i
                      ( partida_uuid     = nuevo( |{ iv_ref }-{ lv_i }| )
                        presupuesto_uuid = de( iv_ref )
                        concepto         = ls_partida-concepto
                        cantidad         = ls_partida-cantidad
                        precio_unitario  = ls_partida-precio_unitario
                        importe_partida  = zcl_tl_calculos=>importe_partida(
                                             iv_cantidad        = ls_partida-cantidad
                                             iv_precio_unitario = ls_partida-precio_unitario ) ) ).
    INSERT ztl_prs_par FROM TABLE @lt_par.
  ENDMETHOD.

  METHOD sellar.
    " Fecha y hora actuales, con fracciones de segundo
    DATA lv_ahora TYPE timestampl.
    GET TIME STAMP FIELD lv_ahora.
    " El usuario que ejecuta la clase
    DATA(lv_usuario) = cl_abap_context_info=>get_user_technical_name( ).

    " Sin WHERE: se actualizan todas las filas de cada tabla
    UPDATE ztl_tit     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_mec     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_aus     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_dis     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_sub     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_prs     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_prs_par SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_orden   SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_hco     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_jor     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_jor_tra SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_alb     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_fac     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
    UPDATE ztl_abo     SET created_by = @lv_usuario, created_at = @lv_ahora, last_changed_by = @lv_usuario,
                           last_changed_at = @lv_ahora, local_last_changed_at = @lv_ahora.
  ENDMETHOD.

ENDCLASS.
