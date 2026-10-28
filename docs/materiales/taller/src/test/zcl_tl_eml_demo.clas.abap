" Los ejemplos de EML de 3.2 a 3.5 sobre los objetos de negocio del taller (F9).
" Crea un titular de prueba, le hace un presupuesto, prueba una validation y las acciones.
CLASS zcl_tl_eml_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    DATA mo_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS crear_titular                       " 3.2 Crear
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    METHODS leer_cambiar_borrar.                " 3.2 Leer, modificar y borrar
    METHODS presupuesto_con_partidas            " 3.2 Hijos a traves de la raiz; 3.3 determinations
      IMPORTING iv_titular     TYPE sysuuid_x16
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    METHODS validation_impuesto                 " 3.4 Probar una validation con codigo
      IMPORTING iv_titular TYPE sysuuid_x16.
    METHODS acciones                            " 3.5 Aceptar y feature control
      IMPORTING iv_presupuesto TYPE sysuuid_x16.
    METHODS borrar_orden_con_abonos.            " 3.5 Precheck
ENDCLASS.


CLASS zcl_tl_eml_demo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    mo_out = out.
    DATA(lv_titular) = crear_titular( ).
    CHECK lv_titular IS NOT INITIAL.
    leer_cambiar_borrar( ).
    DATA(lv_presupuesto) = presupuesto_con_partidas( lv_titular ).
    validation_impuesto( lv_titular ).
    acciones( lv_presupuesto ).
    borrar_orden_con_abonos( ).
  ENDMETHOD.

  METHOD crear_titular.
    mo_out->write( `--- 3.2 Crear ---` ).
    " Crear un titular a traves de su comportamiento (se ejecuta su logica)
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular                                   " alias de la BDEF
        CREATE FIELDS ( RazonSocial DocumentoId Contacto )   " campos que se informan
        WITH VALUE #( ( %cid        = 'nuevo'           " id temporal: aun no hay UUID
                        RazonSocial = 'Autoescuela Pilar'
                        DocumentoId = |B{ cl_abap_context_info=>get_system_time( ) }|   " distinto en cada ejecucion
                        Contacto    = '976333444' ) )
      MAPPED   DATA(ls_mapped)                         " %cid -> UUID asignado
      FAILED   DATA(ls_failed)                         " que instancias fallaron
      REPORTED DATA(ls_reported).                      " con que mensajes

    " Guardar: aqui se ejecutan las validations; si una falla, no se guarda nada
    COMMIT ENTITIES RESPONSE OF zi_tltitular
      FAILED   DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_failed IS NOT INITIAL OR ls_commit_failed IS NOT INITIAL.
      mo_out->write( 'No se ha podido crear el titular' ).
      LOOP AT ls_commit_reported-titular INTO DATA(ls_mensaje) WHERE %msg IS BOUND.
        mo_out->write( ls_mensaje-%msg->if_message~get_text( ) ).
      ENDLOOP.
      RETURN.
    ENDIF.
    rv_uuid = ls_mapped-titular[ 1 ]-TitularUUID.
    mo_out->write( |Titular creado. Errores: { lines( ls_reported-titular ) }| ).

    " El codigo lo puso la determination numerar (3.7) al guardar
    SELECT SINGLE FROM zi_tltitular FIELDS TitularRef WHERE TitularUUID = @rv_uuid INTO @DATA(lv_ref).
    mo_out->write( |Codigo asignado: { lv_ref }| ).
  ENDMETHOD.

  METHOD leer_cambiar_borrar.
    mo_out->write( `--- 3.2 Leer, cambiar y borrar ---` ).
    " Un titular temporal para no tocar los de demo
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular CREATE FIELDS ( RazonSocial Contacto )
        WITH VALUE #( ( %cid = 'temporal' RazonSocial = 'Titular temporal' Contacto = '600000000' ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES.
    DATA(lv_uuid) = ls_mapped-titular[ 1 ]-TitularUUID.

    " Leer: las claves de las instancias van en la tabla de WITH
    READ ENTITIES OF zi_tltitular
      ENTITY Titular
        FIELDS ( TitularRef RazonSocial Contacto ) WITH VALUE #( ( TitularUUID = lv_uuid ) )
      RESULT DATA(lt_titulares).                       " una fila por instancia leida
    mo_out->write( lt_titulares[ 1 ]-Contacto ).

    " Varias operaciones en una sola sentencia: cambiar y despues borrar
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular
        UPDATE FIELDS ( Contacto )                     " solo se cambia Contacto
        WITH VALUE #( ( TitularUUID = lv_uuid Contacto = '976000111' ) )
      ENTITY Titular
        DELETE FROM VALUE #( ( TitularUUID = lv_uuid ) )
      FAILED DATA(ls_failed_mod).
    COMMIT ENTITIES.                                   " sin commit, no se guarda nada

    SELECT COUNT( * ) FROM ztl_tit WHERE titular_uuid = @lv_uuid INTO @DATA(lv_quedan).
    mo_out->write( |Fallos: { lines( ls_failed_mod-titular ) }. Quedan: { lv_quedan }| ).   " 0 y 0
  ENDMETHOD.

  METHOD presupuesto_con_partidas.
    mo_out->write( `--- 3.2 y 3.3 Presupuesto con partidas ---` ).
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        " 1. La cabecera, con el id temporal 'p1' (sin impuesto: lo pone valoresIniciales)
        CREATE FIELDS ( TitularUUID ) WITH VALUE #( ( %cid = 'p1' TitularUUID = iv_titular ) )
        " 2. Sus partidas, colgando de 'p1' (%cid_ref); %target son las filas hijas
        CREATE BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario )
          WITH VALUE #( ( %cid_ref = 'p1'
                          %target  = VALUE #( ( %cid = 'pa1' Concepto = 'Horas de diagnosis'
                                                Cantidad = 4 PrecioUnitario = 45 )
                                              ( %cid = 'pa2' Concepto = 'Kit de embrague'
                                                Cantidad = 1 PrecioUnitario = 320 ) ) ) )
      MAPPED DATA(ls_mapped).
    COMMIT ENTITIES RESPONSE OF zi_tlpresupuesto FAILED DATA(ls_failed).
    IF ls_failed IS NOT INITIAL.
      mo_out->write( 'No se ha podido crear el presupuesto' ).
      RETURN.
    ENDIF.
    rv_uuid = ls_mapped-presupuesto[ 1 ]-PresupuestoUUID.

    " Lo han calculado y copiado las determinations: 21 %, borrador, 500 / 105 / 605
    SELECT SINGLE FROM zi_tlpresupuesto
      FIELDS PresupuestoRef, Impuesto, Situacion, TitularNombre, Neto, Cuota, Importe
      WHERE PresupuestoUUID = @rv_uuid
      INTO @DATA(ls_presupuesto).
    mo_out->write( ls_presupuesto ).
  ENDMETHOD.

  METHOD validation_impuesto.
    mo_out->write( `--- 3.4 Una validation ---` ).
    SELECT COUNT( * ) FROM ztl_prs INTO @DATA(lv_antes).

    " Intentar crear un presupuesto con un impuesto imposible
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( TitularUUID Impuesto )
        WITH VALUE #( ( %cid = 'P1' TitularUUID = iv_titular Impuesto = 150 ) ).

    " Guardar y recoger lo que ha fallado (FAILED) y los mensajes (REPORTED)
    COMMIT ENTITIES RESPONSE OF zi_tlpresupuesto
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed-presupuesto IS INITIAL.
      mo_out->write( 'ERROR: se ha guardado y no deberia' ).
    ELSE.
      " Texto del mensaje: %msg es un objeto con el interfaz IF_MESSAGE
      LOOP AT ls_reported-presupuesto INTO DATA(ls_mensaje) WHERE %msg IS BOUND.
        mo_out->write( ls_mensaje-%msg->if_message~get_text( ) ).   " El impuesto debe estar entre 0 y 100 (es 150)
      ENDLOOP.
    ENDIF.

    SELECT COUNT( * ) FROM ztl_prs INTO @DATA(lv_despues).
    mo_out->write( |Presupuestos antes: { lv_antes }, despues: { lv_despues }| ).   " iguales
  ENDMETHOD.

  METHOD acciones.
    mo_out->write( `--- 3.5 Acciones ---` ).
    " Aceptar: la accion devuelve el presupuesto cambiado en RESULT
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto EXECUTE aceptar FROM VALUE #( ( PresupuestoUUID = iv_presupuesto ) )
      RESULT DATA(lt_resultado)
      FAILED DATA(ls_failed).
    COMMIT ENTITIES.
    IF ls_failed IS INITIAL AND lt_resultado IS NOT INITIAL.
      mo_out->write( |Situacion: { lt_resultado[ 1 ]-%param-Situacion }| ).   " aceptado
    ENDIF.

    " Aceptar otra vez: el feature control lo impide
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto EXECUTE aceptar FROM VALUE #( ( PresupuestoUUID = iv_presupuesto ) )
      FAILED DATA(ls_failed2).
    COMMIT ENTITIES.
    mo_out->write( |Segundo aceptar rechazado: { xsdbool( ls_failed2-presupuesto IS NOT INITIAL ) }| ).   " X
  ENDMETHOD.

  METHOD borrar_orden_con_abonos.
    mo_out->write( `--- 3.5 Precheck al borrar ---` ).
    " ORD0001 tiene abonos en los datos de demo (2.5)
    SELECT SINGLE FROM ztl_orden FIELDS orden_uuid WHERE orden_ref = 'ORD0001' INTO @DATA(lv_orden).
    IF sy-subrc <> 0.
      mo_out->write( 'Ejecuta antes ZCL_TL_DATOS_DEMO' ).
      RETURN.
    ENDIF.
    MODIFY ENTITIES OF zi_tlorden
      ENTITY Orden DELETE FROM VALUE #( ( OrdenUUID = lv_orden ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).
    COMMIT ENTITIES.
    LOOP AT ls_reported-orden INTO DATA(ls_mensaje) WHERE %msg IS BOUND.
      mo_out->write( ls_mensaje-%msg->if_message~get_text( ) ).   " No se puede borrar una orden con abonos
    ENDLOOP.
    mo_out->write( |Rechazado: { xsdbool( ls_failed-orden IS NOT INITIAL ) }| ).
  ENDMETHOD.

ENDCLASS.
