" Compara la hoja de costes que calcula ZI_TlOrdenResumen con la esperada (2.5).
" Antes, ejecuta ZCL_TL_DATOS_DEMO.
CLASS zcl_tl_comprobar_cds DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    " Lo que debe salir para cada orden (la tabla del caso de 0.5)
    TYPES: BEGIN OF ty_esperado,
             orden       TYPE c LENGTH 8,
             importe     TYPE decfloat34,
             costes      TYPE decfloat34,
             abonado     TYPE decfloat34,
             rendimiento TYPE decfloat34,
             saldo       TYPE decfloat34,
             porcentaje  TYPE decfloat34,
             situacion   TYPE string,
             semaforo    TYPE string,
             estado_hoja TYPE string,
           END OF ty_esperado.
    TYPES tt_esperado TYPE STANDARD TABLE OF ty_esperado WITH EMPTY KEY.

    DATA mo_out    TYPE REF TO if_oo_adt_classrun_out.
    DATA mv_errores TYPE i.

    METHODS comparar
      IMPORTING iv_orden TYPE csequence
                iv_campo TYPE string
                iv_real  TYPE any
                iv_esperado TYPE any.
ENDCLASS.

CLASS zcl_tl_comprobar_cds IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    mo_out = out.
    DATA(lt_esperado) = VALUE tt_esperado(
      ( orden = 'ORD0001' importe = 605 costes = 400 abonado = 605 rendimiento = 205 saldo = 0
        porcentaje = 100 situacion = `liquidado` semaforo = `verde` estado_hoja = `cerrada` )
      ( orden = 'ORD0002' importe = 0 costes = 0 abonado = 0 rendimiento = 0 saldo = 0
        porcentaje = 0 situacion = `sin_abonar` semaforo = `ambar` estado_hoja = `abierta` )
      ( orden = 'ORD0003' importe = 0 costes = 0 abonado = 0 rendimiento = 0 saldo = 0
        porcentaje = 0 situacion = `sin_abonar` semaforo = `ambar` estado_hoja = `abierta` ) ).

    LOOP AT lt_esperado INTO DATA(ls_esperado).
      " La ruta \_Resumen lleva de la orden a su hoja calculada (2.3)
      SELECT SINGLE FROM zi_tlorden
        FIELDS OrdenRef,
               \_Resumen-Importe             AS Importe,
               \_Resumen-Costes              AS Costes,
               \_Resumen-Abonado             AS Abonado,
               \_Resumen-Rendimiento         AS Rendimiento,
               \_Resumen-SaldoPendiente      AS SaldoPendiente,
               \_Resumen-PorcentajeLiquidado AS PorcentajeLiquidado,
               \_Resumen-SituacionCobro      AS SituacionCobro,
               \_Resumen-Semaforo            AS Semaforo,
               \_Resumen-EstadoHoja          AS EstadoHoja
        WHERE OrdenRef = @ls_esperado-orden
        INTO @DATA(ls_real).
      IF sy-subrc <> 0.
        mo_out->write( |{ ls_esperado-orden }: no existe. Ejecuta antes ZCL_TL_DATOS_DEMO| ).
        mv_errores += 1.
        CONTINUE.
      ENDIF.
      comparar( iv_orden = ls_esperado-orden iv_campo = `Importe`     iv_real = ls_real-importe     iv_esperado = ls_esperado-importe ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Costes`      iv_real = ls_real-costes      iv_esperado = ls_esperado-costes ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Abonado`     iv_real = ls_real-abonado     iv_esperado = ls_esperado-abonado ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Rendimiento` iv_real = ls_real-rendimiento iv_esperado = ls_esperado-rendimiento ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Saldo`       iv_real = ls_real-saldopendiente iv_esperado = ls_esperado-saldo ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Porcentaje`  iv_real = ls_real-porcentajeliquidado iv_esperado = ls_esperado-porcentaje ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Situacion`   iv_real = ls_real-situacioncobro iv_esperado = ls_esperado-situacion ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `Semaforo`    iv_real = ls_real-semaforo    iv_esperado = ls_esperado-semaforo ).
      comparar( iv_orden = ls_esperado-orden iv_campo = `EstadoHoja`  iv_real = ls_real-estadohoja  iv_esperado = ls_esperado-estado_hoja ).
    ENDLOOP.
    mo_out->write( |{ mv_errores } errores| ).
  ENDMETHOD.

  METHOD comparar.
    " Se comparan como texto sin espacios: 605.00 (dec) y 605 (decfloat34) deben ser iguales
    DATA(lv_real)     = condense( |{ iv_real }| ).
    DATA(lv_esperado) = condense( |{ iv_esperado }| ).
    IF lv_real CO '0123456789.-' AND lv_esperado CO '0123456789.-'.
      IF CONV decfloat34( lv_real ) = CONV decfloat34( lv_esperado ).
        RETURN.
      ENDIF.
    ELSEIF lv_real = lv_esperado.
      RETURN.
    ENDIF.
    mv_errores += 1.
    mo_out->write( |{ iv_orden } { iv_campo }: sale { lv_real }, se esperaba { lv_esperado }| ).
  ENDMETHOD.
ENDCLASS.
