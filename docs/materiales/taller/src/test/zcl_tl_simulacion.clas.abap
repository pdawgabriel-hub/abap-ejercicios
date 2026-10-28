" Simulacion en memoria del caso ORD0001 (1.9): un metodo por paso del negocio
CLASS zcl_tl_simulacion DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    " Lista de importes (los abonos)
    TYPES tt_euros TYPE STANDARD TABLE OF zif_tl_tipos=>ty_euros WITH EMPTY KEY.

    " La salida de la consola, guardada para usarla desde cualquier metodo
    DATA mo_out          TYPE REF TO if_oo_adt_classrun_out.
    " El estado de la orden durante la simulacion
    DATA mt_presupuestos TYPE zif_tl_tipos=>tt_presupuestos.
    DATA mt_tramos       TYPE zif_tl_tipos=>tt_tramos.
    DATA mt_abonos       TYPE tt_euros.
    DATA mv_recambios    TYPE zif_tl_tipos=>ty_euros.
    DATA mv_subcontratas TYPE zif_tl_tipos=>ty_euros.

    " Un metodo por paso del negocio
    METHODS presupuestar.
    METHODS reparar.
    METHODS abonar
      IMPORTING iv_cantidad TYPE zif_tl_tipos=>ty_euros.
    METHODS mostrar_hoja
      IMPORTING iv_titulo TYPE string.
ENDCLASS.

CLASS zcl_tl_simulacion IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    mo_out = out.                                   " guardar la consola en el atributo
    " main solo encadena los pasos, como la tabla del caso
    presupuestar( ).
    mostrar_hoja( `Paso 2: presupuesto aceptado` ).
    reparar( ).
    mostrar_hoja( `Paso 4: jornada, recambios y subcontrata` ).
    abonar( 300 ).
    mostrar_hoja( `Paso 5: primer abono` ).
    abonar( 305 ).
    mostrar_hoja( `Paso 6: orden liquidada` ).
  ENDMETHOD.

  METHOD presupuestar.
    " Pasos 1 y 2: el presupuesto con sus dos partidas, aceptado
    DATA(lo_presupuesto) = NEW zcl_tl_presupuesto( ).        " impuesto 21 por defecto
    lo_presupuesto->add_partida( VALUE #( concepto = `Horas de diagnosis` cantidad = 4 precio_unitario = 45 ) ).
    lo_presupuesto->add_partida( VALUE #( concepto = `Kit de embrague`    cantidad = 1 precio_unitario = 320 ) ).
    lo_presupuesto->aceptar( ).
    " La orden solo necesita saber su situacion y su importe
    APPEND VALUE #( ref       = 'PRS0001'
                    situacion = zif_tl_tipos=>situacion_presupuesto-aceptado
                    importe   = lo_presupuesto->importe( ) ) TO mt_presupuestos.
  ENDMETHOD.

  METHOD reparar.
    DATA(lo_jornada) = NEW zcl_tl_jornada( ).
    TRY.                                            " add_tramo puede lanzar ZCX_TL_AVISO (1.7)
        lo_jornada->add_tramo( io_mecanico = NEW zcl_tl_mecanico( iv_ref = 'MEC0001' ) iv_tiempo = 3 ).
        lo_jornada->add_tramo( io_mecanico = NEW zcl_tl_mecanico( iv_ref = 'MEC0002' iv_tarifa = 35 )
                               iv_tiempo   = 2 ).
      CATCH zcx_tl_aviso INTO DATA(lx_aviso).
        mo_out->write( lx_aviso->get_text( ) ).
    ENDTRY.
    " Guardar en el estado de la orden lo que ha pasado en este paso
    mt_tramos       = lo_jornada->tramos( ).
    mv_recambios    = 180.
    mv_subcontratas = 60.
  ENDMETHOD.

  METHOD abonar.
    APPEND iv_cantidad TO mt_abonos.
  ENDMETHOD.

  METHOD mostrar_hoja.
    " Calcular la hoja con el estado ACTUAL: nada se guarda, todo se recalcula
    DATA(ls_resumen) = zcl_tl_calculos=>resumen_orden(
      iv_importe      = zcl_tl_calculos=>importe_orden( mt_presupuestos )
      iv_mano_obra    = zcl_tl_calculos=>coste_jornada( mt_tramos )
      iv_recambios    = mv_recambios
      iv_subcontratas = mv_subcontratas
      " Suma de los abonos con REDUCE (1.4)
      iv_abonado      = REDUCE #( INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                                  FOR lv_cantidad IN mt_abonos
                                  NEXT lv_suma = lv_suma + lv_cantidad ) ).

    mo_out->write( |--- { iv_titulo } ---| ).
    mo_out->write( |Importe:      { ls_resumen-importe DECIMALS = 2 }| ).
    mo_out->write( |Costes:       { ls_resumen-costes DECIMALS = 2 }| ).
    mo_out->write( |Rendimiento:  { ls_resumen-rendimiento DECIMALS = 2 }| ).
    mo_out->write( |Semaforo:     { ls_resumen-semaforo }| ).
  ENDMETHOD.
ENDCLASS.
