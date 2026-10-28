" Festivos de Espania desde la API publica date.nager.at (6.5)
CLASS zcl_tl_festivos DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Un festivo tal como viene en el JSON (solo los campos que interesan)
    TYPES tt_textos TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES: BEGIN OF ty_festivo,
             date       TYPE string,
             local_name TYPE string,
             global     TYPE abap_bool,
             counties   TYPE tt_textos,           " lista de comunidades: tabla de textos
           END OF ty_festivo.
    TYPES tt_festivos TYPE STANDARD TABLE OF ty_festivo WITH EMPTY KEY.

    " Festivos de un anio en Espania, de la API publica date.nager.at
    CLASS-METHODS del_anio
      IMPORTING iv_anio            TYPE i
      RETURNING VALUE(rt_festivos) TYPE tt_festivos
      RAISING   cx_static_check.

    " Solo los nacionales y los de una comunidad (ES-AR es Aragon)
    CLASS-METHODS de_comunidad
      IMPORTING it_festivos        TYPE tt_festivos
                iv_comunidad       TYPE string
      RETURNING VALUE(rt_festivos) TYPE tt_festivos.
ENDCLASS.

CLASS zcl_tl_festivos IMPLEMENTATION.
  METHOD del_anio.
    " 1. A donde se llama: un destino creado a partir de la URL
    DATA(lo_destino) = cl_http_destination_provider=>create_by_url(
                         |https://date.nager.at/api/v3/PublicHolidays/{ iv_anio }/ES| ).
    DATA(lo_cliente) = cl_web_http_client_manager=>create_by_http_destination( lo_destino ).

    " 2. La peticion GET y lo que devuelve: codigo de estado y cuerpo (el JSON)
    DATA(lo_respuesta) = lo_cliente->execute( if_web_http_client=>get ).
    DATA(lv_estado) = lo_respuesta->get_status( )-code.
    DATA(lv_json) = lo_respuesta->get_text( ).
    lo_cliente->close( ).                            " cerrar siempre la conexion

    " 3. Si no es 200 (OK), algo ha ido mal: avisar a quien llama
    IF lv_estado <> 200.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje = |La API de festivos ha respondido { lv_estado }| ).
    ENDIF.

    " 4. Del texto JSON a la tabla interna de festivos
    /ui2/cl_json=>deserialize( EXPORTING json        = lv_json
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data        = rt_festivos ).
  ENDMETHOD.

  METHOD de_comunidad.
    LOOP AT it_festivos INTO DATA(ls_festivo).
      " Nacional (global = X) o con la comunidad en su lista
      IF ls_festivo-global = abap_true OR line_exists( ls_festivo-counties[ table_line = iv_comunidad ] ).
        APPEND ls_festivo TO rt_festivos.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
