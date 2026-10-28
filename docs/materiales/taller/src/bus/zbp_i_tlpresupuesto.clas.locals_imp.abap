" Local Types de zbp_i_tlpresupuesto: una clase manejadora (lhc) por entidad

CLASS lhc_presupuesto DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " 3.2 Permisos (de momento, todo permitido; 6.1 los afina en la orden)
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Presupuesto RESULT result.

    " 3.5 Feature control: que botones estan activos en cada presupuesto
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Presupuesto RESULT result.

    " 3.3 Determinations
    METHODS valoresIniciales FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Presupuesto~valoresIniciales.
    METHODS copiarTitular FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Presupuesto~copiarTitular.
    METHODS recalcularPorTipo FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Presupuesto~recalcularPorTipo.
    METHODS importesAlGuardar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Presupuesto~importesAlGuardar.
    METHODS recalcularImportes FOR MODIFY
      IMPORTING keys FOR ACTION Presupuesto~recalcularImportes.

    " 3.4 Validations
    METHODS validarImpuesto FOR VALIDATE ON SAVE
      IMPORTING keys FOR Presupuesto~validarImpuesto.
    METHODS validarTitularDeOrden FOR VALIDATE ON SAVE
      IMPORTING keys FOR Presupuesto~validarTitularDeOrden.

    " 3.5 Acciones
    METHODS aceptar FOR MODIFY
      IMPORTING keys FOR ACTION Presupuesto~aceptar RESULT result.
    METHODS volverABorrador FOR MODIFY
      IMPORTING keys FOR ACTION Presupuesto~volverABorrador RESULT result.
    METHODS vincularAOrden FOR MODIFY
      IMPORTING keys FOR ACTION Presupuesto~vincularAOrden RESULT result.

    " 6.3 Exportar como hoja de calculo
    METHODS exportarPresupuesto FOR MODIFY
      IMPORTING keys FOR ACTION Presupuesto~exportarPresupuesto RESULT result.

    " 3.7 Numeracion
    METHODS numerar FOR DETERMINE ON SAVE
      IMPORTING keys FOR Presupuesto~numerar.
ENDCLASS.


CLASS lhc_presupuesto IMPLEMENTATION.

  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD get_instance_features.
    " Leer lo que decide el estado de los botones
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Situacion OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " Una fila por presupuesto, con el estado (enabled/disabled) de cada accion
    result = VALUE #( FOR p IN lt_presupuestos
      LET lv_aceptado = xsdbool( p-Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) IN
      ( %tky                    = p-%tky
        %action-aceptar         = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %action-volverABorrador = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        " Vincular solo si todavia no tiene orden
        %action-vincularAOrden  = COND #( WHEN p-OrdenUUID IS INITIAL
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD valoresIniciales.
    " 1. Leer
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto Situacion Fecha Moneda ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " 2 y 3. Calcular y escribir (solo lo que esta vacio)
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Impuesto Situacion Fecha Moneda )
        WITH VALUE #( FOR ls IN lt_presupuestos
                      ( %tky      = ls-%tky
                        Impuesto  = COND #( WHEN ls-Impuesto IS INITIAL THEN 21 ELSE ls-Impuesto )
                        Situacion = COND #( WHEN ls-Situacion IS INITIAL
                                            THEN zif_tl_tipos=>situacion_presupuesto-borrador
                                            ELSE ls-Situacion )
                        Fecha     = COND #( WHEN ls-Fecha IS INITIAL
                                            THEN cl_abap_context_info=>get_system_date( )
                                            ELSE ls-Fecha )
                        Moneda    = 'EUR' ) ).                       " 6.2: el taller trabaja en euros
  ENDMETHOD.

  METHOD copiarTitular.
    " 1. Leer de NUESTRO BO (local mode) que titular tiene cada presupuesto
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    DELETE lt_presupuestos WHERE TitularUUID IS INITIAL.   " sin titular, nada que copiar
    CHECK lt_presupuestos IS NOT INITIAL.

    " 2. Leer del OTRO BO (sin local mode) los datos de esos titulares
    READ ENTITIES OF zi_tltitular
      ENTITY Titular FIELDS ( RazonSocial DocumentoId )
      WITH VALUE #( FOR ls IN lt_presupuestos ( TitularUUID = ls-TitularUUID ) )
      RESULT DATA(lt_titulares).

    " 3. Escribir la copia en cada presupuesto
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( TitularNombre TitularDocumento )
        WITH VALUE #( FOR ls IN lt_presupuestos
                      " t: el titular de este presupuesto (fila vacia si no se encuentra)
                      LET t = VALUE #( lt_titulares[ TitularUUID = ls-TitularUUID ] OPTIONAL ) IN
                      ( %tky             = ls-%tky
                        TitularNombre    = t-RazonSocial
                        TitularDocumento = t-DocumentoId ) ).
  ENDMETHOD.

  METHOD recalcularPorTipo.
    " Si cambia el impuesto, se recalcula con la accion interna
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto EXECUTE recalcularImportes FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD importesAlGuardar.
    " Al guardar, siempre (cubre el borrado de partidas, que no dispara calcularPartida)
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto EXECUTE recalcularImportes FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD recalcularImportes.
    " Una sola lectura para dos cosas: las cabeceras y, por la composicion, sus partidas
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_presupuestos)
      ENTITY Presupuesto BY \_Partidas FIELDS ( Cantidad PrecioUnitario ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_partidas).

    " Tabla con el tipo exacto que espera el UPDATE de la entidad Presupuesto
    DATA lt_update TYPE TABLE FOR UPDATE zi_tlpresupuesto\\Presupuesto.
    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      " Las partidas de este presupuesto, en el formato de la clase de reglas
      DATA(lt_calculo) = VALUE zif_tl_tipos=>tt_partidas(
        FOR p IN lt_partidas WHERE ( PresupuestoUUID = ls_presu-PresupuestoUUID )
        ( cantidad = p-Cantidad precio_unitario = p-PrecioUnitario ) ).
      " Las formulas son las del Bloque 1: no se repiten, se llaman
      DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( lt_calculo ).
      APPEND VALUE #( %tky    = ls_presu-%tky
                      Neto    = lv_neto
                      Cuota   = zcl_tl_calculos=>cuota_impuesto( iv_neto = lv_neto iv_impuesto = CONV #( ls_presu-Impuesto ) )
                      Importe = zcl_tl_calculos=>importe_presupuesto( iv_neto     = lv_neto
                                                                      iv_impuesto = CONV #( ls_presu-Impuesto ) ) )
        TO lt_update.
    ENDLOOP.

    " Escribir todas las cabeceras de una vez
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto UPDATE FIELDS ( Neto Cuota Importe ) WITH lt_update.
  ENDMETHOD.

  METHOD validarImpuesto.
    " 1. Leer el impuesto de los presupuestos que hay que comprobar.
    "    IN LOCAL MODE: lectura interna del propio BO, sin comprobar permisos.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      " 2. Borrar el mensaje que esta validation dejo la vez anterior (si lo hubo).
      "    Una entrada SIN %msg y con el mismo %state_area lo limpia.
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'IMPUESTO' ) TO reported-presupuesto.

      " 3. Comprobar con la clase de reglas: si el impuesto no vale, lanza ZCX_TL_AVISO
      TRY.
          zcl_tl_calculos=>comprobar_impuesto( CONV #( ls_presu-Impuesto ) ).   " CONV: de dec a decfloat34
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          " 4a. failed: esta instancia NO se guarda
          APPEND VALUE #( %tky = ls_presu-%tky ) TO failed-presupuesto.
          " 4b. reported: el mensaje que vera el usuario
          APPEND VALUE #( %tky              = ls_presu-%tky
                          %state_area       = 'IMPUESTO'                          " grupo de la validation
                          %msg              = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) )   " texto de la excepcion
                          %element-Impuesto = if_abap_behv=>mk-on )             " marca la casilla en Fiori
                 TO reported-presupuesto.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD validarTitularDeOrden.
    " 1. Titular y orden de los presupuestos que hay que comprobar
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " Los presupuestos sin orden no tienen nada que comprobar
    DELETE lt_presupuestos WHERE OrdenUUID IS INITIAL.
    CHECK lt_presupuestos IS NOT INITIAL.           " si no queda ninguno, salir

    " 2. Titular de cada orden. Es OTRO objeto de negocio: se lee sin IN LOCAL MODE
    READ ENTITIES OF zi_tlorden
      ENTITY Orden FIELDS ( TitularUUID )
      WITH VALUE #( FOR p IN lt_presupuestos ( OrdenUUID = p-OrdenUUID ) )
      RESULT DATA(lt_ordenes).

    " 3. Comparar uno a uno
    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'TITULAR_ORDEN' ) TO reported-presupuesto.

      " La orden de este presupuesto (fila vacia si no se encuentra)
      DATA(ls_orden) = VALUE #( lt_ordenes[ OrdenUUID = ls_presu-OrdenUUID ] OPTIONAL ).

      IF ls_orden-TitularUUID IS NOT INITIAL AND ls_orden-TitularUUID <> ls_presu-TitularUUID.
        APPEND VALUE #( %tky = ls_presu-%tky ) TO failed-presupuesto.
        APPEND VALUE #( %tky                 = ls_presu-%tky
                        %state_area          = 'TITULAR_ORDEN'
                        %msg                 = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = 'El presupuesto debe ser del titular de la orden' )
                        %element-TitularUUID = if_abap_behv=>mk-on ) TO reported-presupuesto.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD aceptar.
    " 1. Cambiar la situacion de cada presupuesto recibido
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Situacion )
        WITH VALUE #( FOR k IN keys ( %tky      = k-%tky
                                      Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) ).

    " 2. Devolver la instancia ya cambiada (result [1] $self): Fiori pinta el estado nuevo
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    result = VALUE #( FOR p IN lt_presupuestos ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.

  METHOD volverABorrador.
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Situacion )
        WITH VALUE #( FOR k IN keys ( %tky      = k-%tky
                                      Situacion = zif_tl_tipos=>situacion_presupuesto-borrador ) ).

    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    result = VALUE #( FOR p IN lt_presupuestos ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.

  METHOD vincularAOrden.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_presu) = VALUE #( lt_presupuestos[ %tky = ls_key-%tky ] OPTIONAL ).
      " Buscar la orden por el codigo que llega en el parametro
      SELECT SINGLE FROM ztl_orden
        FIELDS orden_uuid, titular_uuid
        WHERE orden_ref = @ls_key-%param-OrdenRef
        INTO @DATA(ls_orden).

      " No existe, o es de otro titular: marcar como fallida y explicar por que
      IF sy-subrc <> 0 OR ls_orden-titular_uuid <> ls_presu-TitularUUID.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-presupuesto.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |La orden { ls_key-%param-OrdenRef } no existe o es de otro titular| ) )
               TO reported-presupuesto.
        CONTINUE.                                     " siguiente presupuesto
      ENDIF.

      " Todo bien: enlazar el presupuesto con la orden
      MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
        ENTITY Presupuesto
          UPDATE FIELDS ( OrdenUUID ) WITH VALUE #( ( %tky = ls_key-%tky OrdenUUID = ls_orden-orden_uuid ) ).
    ENDLOOP.

    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_resultado).
    result = VALUE #( FOR p IN lt_resultado ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.

  METHOD exportarPresupuesto.
    " Las partidas de los presupuestos pedidos
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario ImportePartida )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    " Una fila de la hoja: todo texto, para poder poner los titulos en la primera
    TYPES: BEGIN OF ty_fila,
             concepto TYPE string,
             cantidad TYPE string,
             precio   TYPE string,
             importe  TYPE string,
           END OF ty_fila.
    DATA lt_filas TYPE STANDARD TABLE OF ty_fila WITH EMPTY KEY.

    LOOP AT keys INTO DATA(ls_key).
      " Primera fila: los titulos de las columnas
      lt_filas = VALUE #( ( concepto = `Concepto` cantidad = `Cantidad` precio = `Precio` importe = `Importe` ) ).
      LOOP AT lt_partidas INTO DATA(ls_partida) WHERE PresupuestoUUID = ls_key-PresupuestoUUID.
        APPEND VALUE #( concepto = ls_partida-Concepto
                        cantidad = |{ ls_partida-Cantidad }|
                        precio   = |{ ls_partida-PrecioUnitario DECIMALS = 2 }|
                        importe  = |{ ls_partida-ImportePartida DECIMALS = 2 }| ) TO lt_filas.
      ENDLOOP.

      " Hoja de calculo con una pestana y las filas desde A1
      DATA(lo_documento) = xco_cp_xlsx=>document->empty( )->write_access( ).
      DATA(lo_hoja) = lo_documento->get_workbook( )->worksheet->at_position( 1 ).
      DATA(lo_patron) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
      lo_hoja->select( lo_patron )->row_stream( )->operation->write_from( REF #( lt_filas ) )->execute( ).
      DATA(lv_fichero) = lo_documento->get_file_content( ).   " el .xlsx en binario

      " Guardarlo como adjunto del presupuesto (la lista de 3.6)
      MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
        ENTITY Presupuesto CREATE BY \_Fotos FIELDS ( Imagen TipoMime NombreFichero )
        WITH VALUE #( ( %tky    = ls_key-%tky
                        %target = VALUE #( ( %cid          = |XLSX{ sy-tabix }|
                                             %is_draft     = ls_key-%is_draft
                                             Imagen        = lv_fichero
                                             TipoMime      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                             NombreFichero = 'presupuesto.xlsx' ) ) ) ).
    ENDLOOP.

    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_resultado).
    result = VALUE #( FOR p IN lt_resultado ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.

  METHOD numerar.
    " Los presupuestos que se estan guardando...
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( PresupuestoRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    " ...que todavia no tienen codigo
    DELETE lt_presupuestos WHERE PresupuestoRef IS NOT INITIAL.
    CHECK lt_presupuestos IS NOT INITIAL.

    " El codigo mas alto guardado: PRS0041 -> 41 (si no hay ninguno, 0)
    SELECT SINGLE FROM ztl_prs FIELDS MAX( presupuesto_ref ) INTO @DATA(lv_maxima).
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada presupuesto nuevo, el siguiente (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( PresupuestoRef )
        WITH VALUE #( FOR ls IN lt_presupuestos INDEX INTO i
                      ( %tky           = ls-%tky
                        PresupuestoRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `PRS`
                                                                           iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_partida DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calcularPartida FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Partida~calcularPartida.
    METHODS validarCantidad FOR VALIDATE ON SAVE
      IMPORTING keys FOR Partida~validarCantidad.
ENDCLASS.


CLASS lhc_partida IMPLEMENTATION.

  METHOD calcularPartida.
    " 1. El importe de cada partida cambiada
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida FIELDS ( Cantidad PrecioUnitario ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida
        UPDATE FIELDS ( ImportePartida )
        WITH VALUE #( FOR p IN lt_partidas
                      ( %tky           = p-%tky
                        ImportePartida = zcl_tl_calculos=>importe_partida(
                                           iv_cantidad        = p-Cantidad
                                           iv_precio_unitario = CONV #( p-PrecioUnitario ) ) ) ).

    " 2. Sus presupuestos (navegando al padre), cada uno una sola vez
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida BY \_Presupuesto FIELDS ( PresupuestoUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cabeceras).
    SORT lt_cabeceras BY PresupuestoUUID.
    DELETE ADJACENT DUPLICATES FROM lt_cabeceras COMPARING PresupuestoUUID.

    " 3. Pedir a cada cabecera que se recalcule
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto EXECUTE recalcularImportes FROM CORRESPONDING #( lt_cabeceras ).
  ENDMETHOD.

  METHOD validarCantidad.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida FIELDS ( Cantidad PresupuestoUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    LOOP AT lt_partidas INTO DATA(ls_partida).
      APPEND VALUE #( %tky = ls_partida-%tky %state_area = 'CANTIDAD' ) TO reported-partida.
      TRY.
          zcl_tl_calculos=>comprobar_cantidad( ls_partida-Cantidad ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_partida-%tky ) TO failed-partida.
          APPEND VALUE #( %tky              = ls_partida-%tky
                          %state_area       = 'CANTIDAD'
                          %msg              = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) )
                          %element-Cantidad = if_abap_behv=>mk-on
                          " En un hijo, %path dice a que padre pertenece el mensaje
                          %path             = VALUE #( presupuesto-%is_draft        = ls_partida-%is_draft
                                                       presupuesto-PresupuestoUUID  = ls_partida-PresupuestoUUID ) )
                 TO reported-partida.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
