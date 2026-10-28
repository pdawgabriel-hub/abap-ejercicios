" Unidad 2.5 - Clase de consola ZCL_GOR_COMPROBAR_CDS (paquete ZGOR_TEST).
" Compara lo que calculan las vistas CDS con los valores esperados de las
" cuatro obras de demo. Ejecutar despues de ZCL_GOR_DATOS_DEMO.
CLASS zcl_gor_comprobar_cds DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_ficha,
             obra_id      TYPE zgor_obra-obra_id,
             total        TYPE zif_gor_tipos=>ty_importe,
             gastos       TYPE zif_gor_tipos=>ty_importe,
             ingresos     TYPE zif_gor_tipos=>ty_importe,
             beneficio    TYPE zif_gor_tipos=>ty_importe,
             debe         TYPE zif_gor_tipos=>ty_importe,
             margen       TYPE zif_gor_tipos=>ty_importe,
             porcentaje   TYPE zif_gor_tipos=>ty_porcentaje,
             estado_pago  TYPE zif_gor_tipos=>ty_estado,
             salud        TYPE zif_gor_tipos=>ty_estado,
             estado_gasto TYPE zif_gor_tipos=>ty_estado,
           END OF ty_ficha.
    TYPES tt_fichas TYPE STANDARD TABLE OF ty_ficha WITH EMPTY KEY.

    DATA mo_out     TYPE REF TO if_oo_adt_classrun_out.
    DATA mv_errores TYPE i.

    METHODS comprobar
      IMPORTING iv_que TYPE string
                iv_act TYPE any
                iv_exp TYPE any.
    METHODS comprobar_fichas.
    METHODS comprobar_trabajadores.
ENDCLASS.

CLASS zcl_gor_comprobar_cds IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    mo_out = out.
    comprobar_fichas( ).
    comprobar_trabajadores( ).
    out->write( |{ mv_errores } errores| ).
  ENDMETHOD.

  METHOD comprobar.
    IF iv_act <> iv_exp.
      mv_errores += 1.
      mo_out->write( |ERROR { iv_que }: sale { iv_act }, se esperaba { iv_exp }| ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_fichas.
    DATA(lt_esperadas) = VALUE tt_fichas(
      ( obra_id = 'OBR0001' total = 1210 gastos = 670  ingresos = 1210 beneficio = 540
        debe = 0   margen = 540  porcentaje = 100 estado_pago = 'pagado'
        salud = 'verde' estado_gasto = 'finalizado' )
      ( obra_id = 'OBR0002' total = 2200 gastos = 2580 ingresos = 2200 beneficio = -380
        debe = 0   margen = -380 porcentaje = 100 estado_pago = 'pagado'
        salud = 'rojo'  estado_gasto = 'finalizado' )
      ( obra_id = 'OBR0003' total = 1452 gastos = 360  ingresos = 600  beneficio = 240
        debe = 852 margen = 1092 porcentaje = '41.3' estado_pago = 'parcial'
        salud = 'ambar' estado_gasto = 'proceso' )
      ( obra_id = 'OBR0004' total = 0    gastos = 0    ingresos = 0    beneficio = 0
        debe = 0   margen = 0    porcentaje = 0   estado_pago = 'pendiente'
        salud = 'ambar' estado_gasto = 'proceso' ) ).

    SELECT FROM ZI_GorObraFinanzas AS f
      INNER JOIN zgor_obra AS o ON o~obra_uuid = f~ObraUUID
      FIELDS o~obra_id, f~Total AS total, f~Gastos AS gastos, f~Ingresos AS ingresos,
             f~BeneficioReal AS beneficio, f~Debe AS debe, f~MargenProyectado AS margen,
             f~PorcentajeCobrado AS porcentaje, f~EstadoPago AS estado_pago,
             f~Salud AS salud, f~EstadoGasto AS estado_gasto
      ORDER BY o~obra_id
      INTO TABLE @DATA(lt_reales).

    LOOP AT lt_esperadas INTO DATA(ls_esp).
      IF NOT line_exists( lt_reales[ obra_id = ls_esp-obra_id ] ).
        comprobar( iv_que = |{ ls_esp-obra_id } existe| iv_act = 'no' iv_exp = 'si' ).
        CONTINUE.
      ENDIF.
      DATA(ls_real) = lt_reales[ obra_id = ls_esp-obra_id ].
      DATA(lv_obra) = CONV string( ls_esp-obra_id ).
      comprobar( iv_que = |{ lv_obra } total|        iv_act = ls_real-total        iv_exp = ls_esp-total ).
      comprobar( iv_que = |{ lv_obra } gastos|       iv_act = ls_real-gastos       iv_exp = ls_esp-gastos ).
      comprobar( iv_que = |{ lv_obra } ingresos|     iv_act = ls_real-ingresos     iv_exp = ls_esp-ingresos ).
      comprobar( iv_que = |{ lv_obra } beneficio|    iv_act = ls_real-beneficio    iv_exp = ls_esp-beneficio ).
      comprobar( iv_que = |{ lv_obra } debe|         iv_act = ls_real-debe         iv_exp = ls_esp-debe ).
      comprobar( iv_que = |{ lv_obra } margen|       iv_act = ls_real-margen       iv_exp = ls_esp-margen ).
      comprobar( iv_que = |{ lv_obra } porcentaje|   iv_act = ls_real-porcentaje   iv_exp = ls_esp-porcentaje ).
      comprobar( iv_que = |{ lv_obra } estado pago|  iv_act = ls_real-estado_pago  iv_exp = ls_esp-estado_pago ).
      comprobar( iv_que = |{ lv_obra } salud|        iv_act = ls_real-salud        iv_exp = ls_esp-salud ).
      comprobar( iv_que = |{ lv_obra } estado gasto| iv_act = ls_real-estado_gasto iv_exp = ls_esp-estado_gasto ).
      mo_out->write( |{ lv_obra }: comprobada| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD comprobar_trabajadores.
    TYPES: BEGIN OF ty_acum,
             trabajador_id TYPE zgor_trab-trabajador_id,
             horas         TYPE zif_gor_tipos=>ty_horas,
             euros         TYPE zif_gor_tipos=>ty_importe,
           END OF ty_acum.
    DATA lt_esperados TYPE STANDARD TABLE OF ty_acum WITH EMPTY KEY.
    lt_esperados = VALUE #( ( trabajador_id = 'TRB0001' horas = 16 euros = 320 )
                            ( trabajador_id = 'TRB0002' horas = 8  euros = 160 )
                            ( trabajador_id = 'TRB0003' horas = 60 euros = 1080 )
                            ( trabajador_id = 'TRB0004' horas = 8  euros = 200 ) ).

    SELECT FROM ZI_GorTrabAcum AS a
      INNER JOIN zgor_trab AS t ON t~trabajador_uuid = a~TrabajadorUUID
      FIELDS t~trabajador_id, a~HorasTotales AS horas, a~TotalEuros AS euros
      INTO TABLE @DATA(lt_reales).

    LOOP AT lt_esperados INTO DATA(ls_esp).
      DATA(ls_real) = VALUE #( lt_reales[ trabajador_id = ls_esp-trabajador_id ] OPTIONAL ).
      comprobar( iv_que = |{ ls_esp-trabajador_id } horas| iv_act = ls_real-horas iv_exp = ls_esp-horas ).
      comprobar( iv_que = |{ ls_esp-trabajador_id } euros| iv_act = ls_real-euros iv_exp = ls_esp-euros ).
    ENDLOOP.

    " Participantes de OBR0001: dos trabajadores distintos
    SELECT FROM ZI_GorObraTrab AS p
      INNER JOIN zgor_obra AS o ON o~obra_uuid = p~ObraUUID
      FIELDS COUNT( * )
      WHERE o~obra_id = 'OBR0001'
      INTO @DATA(lv_participantes).
    comprobar( iv_que = |OBR0001 participantes| iv_act = lv_participantes iv_exp = 2 ).
  ENDMETHOD.
ENDCLASS.
