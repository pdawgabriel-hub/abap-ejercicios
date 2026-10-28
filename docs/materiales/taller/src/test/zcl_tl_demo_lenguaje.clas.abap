" Los ejemplos de 1.2 a 1.4 y 1.7, juntos en una clase ejecutable (F9).
" Cada metodo es una unidad; main los llama en orden.
CLASS zcl_tl_demo_lenguaje DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    DATA mo_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS tipos.               " 1.2
    METHODS flujo.               " 1.3
    METHODS tablas.              " 1.4
    METHODS objetos.             " 1.6
    METHODS excepciones.         " 1.7
ENDCLASS.

CLASS zcl_tl_demo_lenguaje IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    mo_out = out.
    tipos( ).
    flujo( ).
    tablas( ).
    objetos( ).
    excepciones( ).
  ENDMETHOD.

  METHOD tipos.
    mo_out->write( `--- 1.2 Tipos ---` ).
    DATA lv_cantidad TYPE i VALUE 4.                 " variable entera con valor inicial 4
    CONSTANTS lc_impuesto TYPE decfloat34 VALUE 21.  " constante: no se puede cambiar

    " Declaracion inline: el tipo sale de la expresion de la derecha
    DATA(lv_precio) = CONV decfloat34( '45' ).       " CONV convierte el texto '45' a decimal
    DATA(lv_neto)   = lv_cantidad * lv_precio.       " i * decfloat34 da decfloat34: 180
    mo_out->write( |Neto { lv_neto }, impuesto { lc_impuesto } %| ).

    " Una estructura con el tipo de la interfaz
    DATA(ls_partida) = VALUE zif_tl_tipos=>ty_partida( concepto        = 'Horas de diagnosis'
                                                       cantidad        = 4
                                                       precio_unitario = '45' ).
    mo_out->write( ls_partida ).                                    " la estructura entera, en columnas
    mo_out->write( |{ ls_partida-cantidad } x { ls_partida-precio_unitario }| ).

    " Plantillas de texto con formato
    DATA(lv_importe) = CONV decfloat34( '605' ).
    DATA(lv_entrada) = CONV d( '20261102' ).
    mo_out->write( |Importe: { lv_importe DECIMALS = 2 } €| ).                 " Importe: 605.00 €
    mo_out->write( |Entrada: { lv_entrada DATE = ISO }| ).                     " Entrada: 2026-11-02
    mo_out->write( |Orden: { 'ORD' }{ 7 WIDTH = 4 ALIGN = RIGHT PAD = '0' }| ).  " ORD0007

    " Fechas: restar da dias; sumar da otra fecha
    DATA(lv_desde) = CONV d( '20261228' ).
    DATA(lv_hasta) = CONV d( '20270103' ).
    mo_out->write( lv_hasta - lv_desde ).            " 6
    mo_out->write( lv_desde + 7 ).                   " 20270104
  ENDMETHOD.

  METHOD flujo.
    mo_out->write( `--- 1.3 Flujo ---` ).
    DATA(lv_importe) = CONV decfloat34( '605' ).
    DATA(lv_abonado) = CONV decfloat34( '300' ).

    IF lv_abonado <= 0.                       " primera condicion que se comprueba
      mo_out->write( 'sin_abonar' ).
    ELSEIF lv_abonado < lv_importe.           " solo se mira si la anterior no se cumplio
      mo_out->write( 'abonado_parcial' ).
    ELSE.
      mo_out->write( 'liquidado' ).
    ENDIF.

    DATA(lv_semaforo) = CONV zif_tl_tipos=>ty_situacion( 'ambar' ).
    CASE lv_semaforo.
      WHEN 'verde'.
        mo_out->write( 'Orden liquidada' ).
      WHEN 'ambar'.
        mo_out->write( 'En curso, sin perdidas' ).
      WHEN OTHERS.
        mo_out->write( 'Con perdidas' ).
    ENDCASE.

    " COND devuelve el valor de la primera rama que se cumple
    DATA(lv_situacion) = COND zif_tl_tipos=>ty_situacion(
                           WHEN lv_abonado <= 0         THEN 'sin_abonar'
                           WHEN lv_abonado < lv_importe THEN 'abonado_parcial'
                           ELSE                              'liquidado' ).
    " SWITCH compara un valor con varios posibles, como CASE
    DATA(lv_texto) = SWITCH string( lv_situacion
                       WHEN 'sin_abonar' THEN 'Pendiente de pago'
                       WHEN 'liquidado'  THEN 'Pagada'
                       ELSE                   'Pagada en parte' ).
    mo_out->write( lv_texto ).

    DO 3 TIMES.
      mo_out->write( |Orden ORD{ sy-index WIDTH = 4 ALIGN = RIGHT PAD = '0' }| ).
    ENDDO.

    mo_out->write( zcl_tl_calculos=>rotulo_titular( iv_codigo       = 'TIT0001'
                                                    iv_razon_social = `Talleres Ebro SL`
                                                    iv_documento_id = `B50123456` ) ).
  ENDMETHOD.

  METHOD tablas.
    mo_out->write( `--- 1.4 Tablas internas ---` ).
    " VALUE con varias filas: cada ( ... ) interior es una fila
    DATA(lt_partidas) = VALUE zif_tl_tipos=>tt_partidas(
      ( concepto = 'Horas de diagnosis' cantidad = 4 precio_unitario = '45' )
      ( concepto = 'Kit de embrague'    cantidad = 1 precio_unitario = '320' ) ).
    " APPEND anade una fila al final; # toma el tipo de la fila de lt_partidas
    APPEND VALUE #( concepto = 'Liquido de frenos' cantidad = 2 precio_unitario = '12.50' ) TO lt_partidas.
    mo_out->write( lines( lt_partidas ) ).           " 3

    " Recorrer todas las filas: en cada vuelta, ls_partida es una COPIA de la fila
    DATA lv_neto TYPE zif_tl_tipos=>ty_euros.
    LOOP AT lt_partidas INTO DATA(ls_partida).
      lv_neto = lv_neto + zcl_tl_calculos=>importe_partida( iv_cantidad        = ls_partida-cantidad
                                                            iv_precio_unitario = ls_partida-precio_unitario ).
    ENDLOOP.
    mo_out->write( |Neto: { lv_neto }| ).

    " Por posicion y por contenido
    DATA(ls_primera) = lt_partidas[ 1 ].
    mo_out->write( ls_primera-concepto ).
    IF line_exists( lt_partidas[ concepto = 'Kit de embrague' ] ).
      mo_out->write( 'Hay embrague' ).
    ENDIF.

    " Field symbol: se cambia la fila de la tabla, no una copia
    LOOP AT lt_partidas ASSIGNING FIELD-SYMBOL(<ls_partida>).
      <ls_partida>-precio_unitario = <ls_partida>-precio_unitario * '1.03'.
    ENDLOOP.

    " VALUE ... FOR y REDUCE
    DATA(lt_conceptos) = VALUE zif_tl_tipos=>tt_textos( FOR ls IN lt_partidas ( ls-concepto ) ).
    mo_out->write( lt_conceptos ).
    mo_out->write( zcl_tl_calculos=>neto_presupuesto( lt_partidas ) ).

    " Ranking de los tramos de ORD0001
    DATA(lt_tramos) = VALUE zif_tl_tipos=>tt_tramos(
      ( mecanico = 'MEC0001' tiempo = 3 tarifa_aplicada = 30 )
      ( mecanico = 'MEC0002' tiempo = 2 tarifa_aplicada = 35 ) ).
    mo_out->write( zcl_tl_calculos=>ranking_mecanicos( lt_tramos ) ).

    " Filtro por palabras
    mo_out->write( zcl_tl_calculos=>encaja_filtro( iv_texto  = `tal ebro`
                                                   it_campos = VALUE #( ( `Talleres Ebro SL` ) ( `B50123456` ) ) ) ).
  ENDMETHOD.

  METHOD objetos.
    mo_out->write( `--- 1.6 Objetos ---` ).
    " NEW crea el objeto (llama al constructor) y devuelve una referencia a el
    DATA(lo_rosa)  = NEW zcl_tl_mecanico( iv_ref = 'MEC0001' ).                  " tarifa por defecto
    DATA(lo_diego) = NEW zcl_tl_mecanico( iv_ref = 'MEC0002' iv_tarifa = 35 ).
    mo_out->write( lo_rosa->tarifa( ) ).     " 30
    lo_rosa->revisar_tarifa( 32 ).
    mo_out->write( lo_rosa->tarifa( ) ).     " 32
    mo_out->write( lo_diego->tarifa( ) ).    " 35

    DATA(lo_misma) = lo_rosa.               " se copia la REFERENCIA, no el objeto
    lo_misma->revisar_tarifa( 40 ).
    mo_out->write( lo_rosa->tarifa( ) ).     " 40: es el mismo objeto
  ENDMETHOD.

  METHOD excepciones.
    mo_out->write( `--- 1.7 Excepciones ---` ).
    DATA(lt_refs) = VALUE zif_tl_tipos=>tt_refs( ( 'ORD0001' ) ( 'ORD0002' ) ).
    TRY.                                       " codigo que puede fallar
        DATA(lv_ref) = lt_refs[ 5 ].           " solo hay 2 filas: lanza una excepcion
        mo_out->write( lv_ref ).               " esta linea ya no se ejecuta
      CATCH cx_sy_itab_line_not_found.         " aqui se trata ESA excepcion
        mo_out->write( 'No hay quinta orden' ).
    ENDTRY.

    TRY.
        zcl_tl_calculos=>comprobar_tiempo( 12 ).
      CATCH zcx_tl_aviso INTO DATA(lx_aviso).
        mo_out->write( |{ lx_aviso->mv_elemento }: { lx_aviso->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
