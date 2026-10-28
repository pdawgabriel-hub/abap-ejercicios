" Reglas de negocio del taller en ABAP puro: todas estaticas y sin acceso a la base de datos.
" Cada metodo indica la unidad en la que aparece.
CLASS zcl_tl_calculos DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    " ---- 1.2 Formulas sencillas ----

    " Redondeo a centimos (empate hacia arriba)
    CLASS-METHODS ajustar_centimos
      IMPORTING iv_valor        TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_valor) TYPE zif_tl_tipos=>ty_euros.

    " importe_partida = ajustar_centimos( cantidad * precio_unitario )
    CLASS-METHODS importe_partida
      IMPORTING iv_cantidad        TYPE i
                iv_precio_unitario TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_importe)  TYPE zif_tl_tipos=>ty_euros.

    " cuota = ajustar_centimos( neto * impuesto / 100 )
    CLASS-METHODS cuota_impuesto
      IMPORTING iv_neto         TYPE zif_tl_tipos=>ty_euros
                iv_impuesto     TYPE zif_tl_tipos=>ty_tanto
      RETURNING VALUE(rv_cuota) TYPE zif_tl_tipos=>ty_euros.

    " importe = neto + cuota
    CLASS-METHODS importe_presupuesto
      IMPORTING iv_neto           TYPE zif_tl_tipos=>ty_euros
                iv_impuesto       TYPE zif_tl_tipos=>ty_tanto
      RETURNING VALUE(rv_importe) TYPE zif_tl_tipos=>ty_euros.

    " coste_tramo = ajustar_centimos( tiempo * tarifa )
    CLASS-METHODS coste_tramo
      IMPORTING iv_tiempo       TYPE zif_tl_tipos=>ty_tiempo
                iv_tarifa       TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_coste) TYPE zif_tl_tipos=>ty_euros.

    " Jornadas de una ausencia, contando los dos extremos; 0 si falta una fecha
    CLASS-METHODS jornadas_ausencia
      IMPORTING iv_desde           TYPE d
                iv_hasta           TYPE d
      RETURNING VALUE(rv_jornadas) TYPE i.

    " ---- 1.3 Decisiones y textos ----

    " sin_abonar, abonado_parcial o liquidado
    CLASS-METHODS situacion_cobro
      IMPORTING iv_importe          TYPE zif_tl_tipos=>ty_euros
                iv_abonado          TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_situacion) TYPE zif_tl_tipos=>ty_situacion.

    " rojo si pierde dinero; verde si esta liquidada; ambar en otro caso
    CLASS-METHODS semaforo
      IMPORTING iv_rendimiento  TYPE zif_tl_tipos=>ty_euros
                iv_situacion    TYPE zif_tl_tipos=>ty_situacion
      RETURNING VALUE(rv_color) TYPE zif_tl_tipos=>ty_situacion.

    " cerrada si no queda saldo y se ha abonado algo; si no, abierta
    CLASS-METHODS estado_hoja
      IMPORTING iv_importe       TYPE zif_tl_tipos=>ty_euros
                iv_abonado       TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_estado) TYPE zif_tl_tipos=>ty_situacion.

    " abonado * 100 / importe, a 1 decimal, entre 0 y 100; 0 si no hay importe
    CLASS-METHODS porcentaje_liquidado
      IMPORTING iv_importe      TYPE zif_tl_tipos=>ty_euros
                iv_abonado      TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rv_tanto) TYPE zif_tl_tipos=>ty_tanto.

    " TIT + 7 -> TIT0007
    CLASS-METHODS componer_codigo
      IMPORTING iv_serie         TYPE string
                iv_numero        TYPE i
      RETURNING VALUE(rv_codigo) TYPE zif_tl_tipos=>ty_ref.

    " TIT0001 · Talleres Ebro SL [B50123456]
    CLASS-METHODS rotulo_titular
      IMPORTING iv_codigo        TYPE zif_tl_tipos=>ty_ref
                iv_razon_social  TYPE string
                iv_documento_id  TYPE string OPTIONAL
      RETURNING VALUE(rv_rotulo) TYPE string.

    " ---- 1.4 Tablas internas ----

    " Suma de los importes de las partidas
    CLASS-METHODS neto_presupuesto
      IMPORTING it_partidas    TYPE zif_tl_tipos=>tt_partidas
      RETURNING VALUE(rv_neto) TYPE zif_tl_tipos=>ty_euros.

    " Suma de los importes de los presupuestos ACEPTADOS
    CLASS-METHODS importe_orden
      IMPORTING it_presupuestos   TYPE zif_tl_tipos=>tt_presupuestos
      RETURNING VALUE(rv_importe) TYPE zif_tl_tipos=>ty_euros.

    " Suma del coste de los tramos
    CLASS-METHODS coste_jornada
      IMPORTING it_tramos       TYPE zif_tl_tipos=>tt_tramos
      RETURNING VALUE(rv_coste) TYPE zif_tl_tipos=>ty_euros.

    " Mecanicos ordenados de mas a menos euros
    CLASS-METHODS ranking_mecanicos
      IMPORTING it_tramos         TYPE zif_tl_tipos=>tt_tramos
      RETURNING VALUE(rt_ranking) TYPE zif_tl_tipos=>tt_ranking.

    " Cada palabra del texto es el principio de alguno de los campos
    CLASS-METHODS encaja_filtro
      IMPORTING iv_texto         TYPE string
                it_campos        TYPE zif_tl_tipos=>tt_textos
      RETURNING VALUE(rv_encaja) TYPE abap_bool.

    " ---- 1.7 Validaciones ----

    " Un tramo dura entre 0 y 10 horas
    CLASS-METHODS comprobar_tiempo
      IMPORTING iv_tiempo TYPE zif_tl_tipos=>ty_tiempo
      RAISING   zcx_tl_aviso.

    " El impuesto esta entre 0 y 100
    CLASS-METHODS comprobar_impuesto
      IMPORTING iv_impuesto TYPE zif_tl_tipos=>ty_tanto
      RAISING   zcx_tl_aviso.

    " Un importe de albaran o factura es mayor que 0
    CLASS-METHODS comprobar_importe_positivo
      IMPORTING iv_importe TYPE zif_tl_tipos=>ty_euros
      RAISING   zcx_tl_aviso.

    " La fecha final no es anterior a la inicial
    CLASS-METHODS comprobar_periodo
      IMPORTING iv_desde TYPE d
                iv_hasta TYPE d
      RAISING   zcx_tl_aviso.

    " Un texto obligatorio no esta vacio (iv_elemento: el campo de la vista)
    CLASS-METHODS comprobar_relleno
      IMPORTING iv_valor    TYPE csequence
                iv_elemento TYPE string
      RAISING   zcx_tl_aviso.

    " Una tarifa o un precio no es negativo
    CLASS-METHODS comprobar_no_negativo
      IMPORTING iv_valor    TYPE zif_tl_tipos=>ty_euros
                iv_elemento TYPE string
      RAISING   zcx_tl_aviso.

    " La cantidad de una partida es al menos 1
    CLASS-METHODS comprobar_cantidad
      IMPORTING iv_cantidad TYPE i
      RAISING   zcx_tl_aviso.

    " Matricula espanola actual: 4 cifras y 3 letras (1234ABC)
    CLASS-METHODS comprobar_matricula
      IMPORTING iv_matricula TYPE csequence
      RAISING   zcx_tl_aviso.

    " ---- 1.8 La hoja de costes completa ----

    CLASS-METHODS resumen_orden
      IMPORTING iv_importe        TYPE zif_tl_tipos=>ty_euros
                iv_mano_obra      TYPE zif_tl_tipos=>ty_euros
                iv_recambios      TYPE zif_tl_tipos=>ty_euros
                iv_subcontratas   TYPE zif_tl_tipos=>ty_euros
                iv_abonado        TYPE zif_tl_tipos=>ty_euros
      RETURNING VALUE(rs_resumen) TYPE zif_tl_tipos=>ty_resumen.
ENDCLASS.


CLASS zcl_tl_calculos IMPLEMENTATION.

  METHOD ajustar_centimos.
    rv_valor = round( val = iv_valor dec = 2 ).
  ENDMETHOD.

  METHOD importe_partida.
    rv_importe = ajustar_centimos( iv_cantidad * iv_precio_unitario ).
  ENDMETHOD.

  METHOD cuota_impuesto.
    rv_cuota = ajustar_centimos( iv_neto * iv_impuesto / 100 ).
  ENDMETHOD.

  METHOD importe_presupuesto.
    " Se reutiliza cuota_impuesto: la formula de la cuota esta escrita una sola vez
    rv_importe = iv_neto + cuota_impuesto( iv_neto = iv_neto iv_impuesto = iv_impuesto ).
  ENDMETHOD.

  METHOD coste_tramo.
    rv_coste = ajustar_centimos( iv_tiempo * iv_tarifa ).
  ENDMETHOD.

  METHOD jornadas_ausencia.
    IF iv_desde IS INITIAL OR iv_hasta IS INITIAL.
      RETURN.                 " rv_jornadas queda en 0
    ENDIF.
    rv_jornadas = iv_hasta - iv_desde + 1.
  ENDMETHOD.

  METHOD situacion_cobro.
    " El # toma el tipo del resultado (rv_situacion); se usan las constantes, no textos sueltos
    rv_situacion = COND #( WHEN iv_abonado <= 0         THEN zif_tl_tipos=>situacion_cobro-sin_abonar
                           WHEN iv_abonado < iv_importe THEN zif_tl_tipos=>situacion_cobro-abonado_parcial
                           ELSE                              zif_tl_tipos=>situacion_cobro-liquidado ).
  ENDMETHOD.

  METHOD semaforo.
    " El orden importa: liquidada pero con perdidas es roja
    rv_color = COND #( WHEN iv_rendimiento < 0
                         THEN zif_tl_tipos=>semaforo-rojo
                       WHEN iv_situacion = zif_tl_tipos=>situacion_cobro-liquidado
                         THEN zif_tl_tipos=>semaforo-verde
                       ELSE zif_tl_tipos=>semaforo-ambar ).
  ENDMETHOD.

  METHOD estado_hoja.
    rv_estado = COND #( WHEN iv_importe - iv_abonado <= 0 AND iv_abonado > 0
                          THEN zif_tl_tipos=>estado_hoja-cerrada
                        ELSE zif_tl_tipos=>estado_hoja-abierta ).
  ENDMETHOD.

  METHOD porcentaje_liquidado.
    " Sin importe no hay porcentaje: se sale antes de dividir entre cero
    IF iv_importe = 0.
      RETURN.                                   " rv_tanto se queda en 0
    ENDIF.
    " Porcentaje con 1 decimal
    DATA(lv_tanto) = round( val = iv_abonado * 100 / iv_importe dec = 1 ).
    " Acotarlo entre 0 y 100 (si se cobra de mas, 100)
    rv_tanto = COND #( WHEN lv_tanto > 100 THEN 100
                       WHEN lv_tanto < 0   THEN 0
                       ELSE lv_tanto ).
  ENDMETHOD.

  METHOD componer_codigo.
    " La serie y el numero con 4 cifras, rellenado con ceros por la izquierda
    rv_codigo = |{ iv_serie }{ iv_numero WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.
  ENDMETHOD.

  METHOD rotulo_titular.
    " TIT0001 · Talleres Ebro SL [B50123456]; sin razon social, solo el codigo
    rv_rotulo = iv_codigo.                              " como minimo, el codigo
    DATA(lv_razon) = condense( iv_razon_social ).       " condense quita espacios: '   ' queda vacio
    IF lv_razon IS INITIAL.                             " IS INITIAL necesita una variable, no una funcion
      RETURN.
    ENDIF.
    rv_rotulo = |{ rv_rotulo } · { lv_razon }|.         " plantilla: texto + valores
    IF iv_documento_id IS NOT INITIAL.                  " el documento, solo si existe
      rv_rotulo = |{ rv_rotulo } [{ iv_documento_id }]|.
    ENDIF.
  ENDMETHOD.

  METHOD neto_presupuesto.
    " REDUCE: empieza en 0 y suma el importe de cada partida
    rv_neto = ajustar_centimos( REDUCE zif_tl_tipos=>ty_euros(
                                  INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                                  FOR ls IN it_partidas
                                  NEXT lv_suma = lv_suma + importe_partida(
                                                             iv_cantidad        = ls-cantidad
                                                             iv_precio_unitario = ls-precio_unitario ) ) ).
  ENDMETHOD.

  METHOD importe_orden.
    " Solo cuentan los aceptados (WHERE dentro del FOR)
    rv_importe = ajustar_centimos( REDUCE zif_tl_tipos=>ty_euros(
                                     INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                                     FOR ls IN it_presupuestos
                                     WHERE ( situacion = zif_tl_tipos=>situacion_presupuesto-aceptado )
                                     NEXT lv_suma = lv_suma + ls-importe ) ).
  ENDMETHOD.

  METHOD coste_jornada.
    LOOP AT it_tramos INTO DATA(ls_tramo).
      rv_coste = rv_coste + coste_tramo( iv_tiempo = ls_tramo-tiempo iv_tarifa = ls_tramo-tarifa_aplicada ).
    ENDLOOP.
  ENDMETHOD.

  METHOD ranking_mecanicos.
    LOOP AT it_tramos INTO DATA(ls_tramo).
      " Buscar el puesto del mecanico; si aun no esta, crearlo
      ASSIGN rt_ranking[ mecanico = ls_tramo-mecanico ] TO FIELD-SYMBOL(<ls_puesto>).
      IF sy-subrc <> 0.
        APPEND VALUE #( mecanico = ls_tramo-mecanico ) TO rt_ranking ASSIGNING <ls_puesto>.
      ENDIF.
      " Acumular en la fila de la tabla (el field symbol apunta a ella)
      <ls_puesto>-euros  += coste_tramo( iv_tiempo = ls_tramo-tiempo iv_tarifa = ls_tramo-tarifa_aplicada ).
      <ls_puesto>-tiempo += ls_tramo-tiempo.
    ENDLOOP.
    SORT rt_ranking BY euros DESCENDING mecanico ASCENDING.
  ENDMETHOD.

  METHOD encaja_filtro.
    rv_encaja = abap_true.
    " Partir el texto en palabras, en minusculas
    SPLIT condense( to_lower( iv_texto ) ) AT space INTO TABLE DATA(lt_palabras).
    LOOP AT lt_palabras INTO DATA(lv_palabra) WHERE table_line IS NOT INITIAL.
      DATA(lv_encontrada) = abap_false.
      LOOP AT it_campos INTO DATA(lv_campo).
        IF to_lower( lv_campo ) CP |{ lv_palabra }*|.
          lv_encontrada = abap_true.
          EXIT.                         " sale del LOOP interior
        ENDIF.
      ENDLOOP.
      IF lv_encontrada = abap_false.    " una palabra que no encaja: no encaja el texto
        rv_encaja = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD comprobar_tiempo.
    IF iv_tiempo < 0 OR iv_tiempo > 10.
      " Crear la excepcion y lanzarla: el metodo termina aqui
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |Un tramo debe durar entre 0 y 10 horas (dura { iv_tiempo })|
                                        iv_elemento = `Tiempo` ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_impuesto.
    IF iv_impuesto < 0 OR iv_impuesto > 100.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |El impuesto debe estar entre 0 y 100 (es { iv_impuesto })|
                                        iv_elemento = `Impuesto` ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_importe_positivo.
    IF iv_importe <= 0.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |El importe neto debe ser mayor que 0 (es { iv_importe })|
                                        iv_elemento = `ImporteNeto` ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_periodo.
    IF iv_desde IS NOT INITIAL AND iv_hasta IS NOT INITIAL AND iv_hasta < iv_desde.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |La fecha final ({ iv_hasta DATE = ISO }) es anterior a la inicial|
                                        iv_elemento = `Hasta` ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_relleno.
    IF condense( CONV string( iv_valor ) ) = ``.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |El campo { iv_elemento } es obligatorio|
                                        iv_elemento = iv_elemento ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_no_negativo.
    IF iv_valor < 0.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |{ iv_elemento } no puede ser negativo (es { iv_valor })|
                                        iv_elemento = iv_elemento ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_cantidad.
    IF iv_cantidad < 1.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |La cantidad debe ser al menos 1 (es { iv_cantidad })|
                                        iv_elemento = `Cantidad` ).
    ENDIF.
  ENDMETHOD.

  METHOD comprobar_matricula.
    " matches compara con una expresion regular (PCRE): 4 digitos y 3 letras mayusculas
    IF NOT matches( val = iv_matricula pcre = `^\d{4}[A-Z]{3}$` ).
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |La matricula { iv_matricula } no tiene el formato 1234ABC|
                                        iv_elemento = `Matricula` ).
    ENDIF.
  ENDMETHOD.

  METHOD resumen_orden.
    " Solo combina metodos que ya existen y tienen sus propios tests
    rs_resumen-importe     = iv_importe.
    rs_resumen-costes      = ajustar_centimos( iv_mano_obra + iv_recambios + iv_subcontratas ).  " redondeo una vez, al final
    rs_resumen-abonado     = ajustar_centimos( iv_abonado ).
    rs_resumen-rendimiento = ajustar_centimos( rs_resumen-abonado - rs_resumen-costes ).
    rs_resumen-saldo       = ajustar_centimos( iv_importe - rs_resumen-abonado ).
    rs_resumen-previsto    = ajustar_centimos( iv_importe - rs_resumen-costes ).
    rs_resumen-porcentaje  = porcentaje_liquidado( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
    rs_resumen-situacion   = situacion_cobro( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
    rs_resumen-semaforo    = semaforo( iv_rendimiento = rs_resumen-rendimiento iv_situacion = rs_resumen-situacion ).
    rs_resumen-estado_hoja = estado_hoja( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
  ENDMETHOD.

ENDCLASS.
