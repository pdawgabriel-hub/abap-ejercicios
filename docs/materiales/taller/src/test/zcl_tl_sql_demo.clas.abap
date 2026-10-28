" Los ejemplos de ABAP SQL de 1.5 sobre las tablas ztl_tit y ztl_orden (F9).
" Cada ejecucion vacia las dos tablas y las vuelve a llenar: solo en tu sistema de pruebas.
CLASS zcl_tl_sql_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_tl_sql_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Empezar de cero: primero las ordenes, que apuntan a los titulares
    DELETE FROM ztl_orden.
    DELETE FROM ztl_tit.

    " UUID nuevos para los dos titulares
    TRY.
        " Clase liberada de SAP que genera un UUID nuevo
        DATA(lv_moncayo) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_pilar)   = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_orden1)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_orden2)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_orden3)  = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.                     " por si falla: se trata en 1.7
        out->write( 'No se pudo generar el UUID' ).
        RETURN.
    ENDTRY.

    " Tabla interna con las mismas columnas que la tabla de base de datos
    DATA lt_titulares TYPE STANDARD TABLE OF ztl_tit WITH EMPTY KEY.
    lt_titulares = VALUE #(
      ( titular_uuid = lv_moncayo titular_ref = 'TIT0001' razon_social = 'Transportes Moncayo SL'
        documento_id = 'B50111222' contacto = '976111222' poblacion = 'Zaragoza' cp = '50001' )
      ( titular_uuid = lv_pilar   titular_ref = 'TIT0002' razon_social = 'Autoescuela Pilar'
        documento_id = 'B50999888' contacto = '976333444' poblacion = 'Zaragoza' cp = '50003' ) ).
    INSERT ztl_tit FROM TABLE @lt_titulares.        " varias filas (tabla interna)
    out->write( |Titulares creados: { sy-dbcnt }| ).

    " Una sola fila (estructura)
    DATA(ls_orden) = VALUE ztl_orden( orden_uuid = lv_orden1 orden_ref = 'ORD0001' matricula = '1234ABC'
                                      averia = 'Patina el embrague' titular_uuid = lv_moncayo ).
    INSERT ztl_orden FROM @ls_orden.
    DATA lt_ordenes TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ordenes = VALUE #(
      ( orden_uuid = lv_orden2 orden_ref = 'ORD0002' matricula = '5678DEF' averia = 'Revision' titular_uuid = lv_moncayo )
      ( orden_uuid = lv_orden3 orden_ref = 'ORD0003' matricula = '9012GHI' averia = 'Frenos'   titular_uuid = lv_pilar ) ).
    INSERT ztl_orden FROM TABLE @lt_ordenes.

    " Leer: tabla, columnas, condicion, orden y destino
    SELECT FROM ztl_tit
      FIELDS titular_ref, razon_social, contacto
      WHERE cp = '50001'
      ORDER BY razon_social
      INTO TABLE @DATA(lt_de_zaragoza).          " @: variable de ABAP; DATA(...) la declara
    out->write( lt_de_zaragoza ).

    " Una sola fila
    SELECT SINGLE FROM ztl_tit
      FIELDS *
      WHERE titular_ref = 'TIT0001'
      INTO @DATA(ls_titular).
    IF sy-subrc <> 0.
      out->write( 'No existe' ).
    ELSE.
      out->write( ls_titular-razon_social ).
    ENDIF.

    " Modificar y borrar
    UPDATE ztl_tit SET contacto = '976999888' WHERE titular_ref = 'TIT0001'.
    out->write( |Filas modificadas: { sy-dbcnt }| ).
    DELETE FROM ztl_orden WHERE orden_ref = 'ORD0003'.

    " Cuantas ordenes tiene cada titular: una fila por titular_uuid
    SELECT FROM ztl_orden
      FIELDS titular_uuid, COUNT( * ) AS ordenes          " AS da nombre a la columna calculada
      GROUP BY titular_uuid
      INTO TABLE @DATA(lt_por_titular).
    out->write( lt_por_titular ).

    " Ordenes con la razon social de su titular
    SELECT FROM ztl_orden AS o                             " o y t son alias de las tablas
      INNER JOIN ztl_tit AS t ON t~titular_uuid = o~titular_uuid   " solo ordenes con titular
      FIELDS o~orden_ref, o~matricula, t~razon_social
      ORDER BY o~orden_ref
      INTO TABLE @DATA(lt_con_titular).
    out->write( lt_con_titular ).
  ENDMETHOD.
ENDCLASS.
