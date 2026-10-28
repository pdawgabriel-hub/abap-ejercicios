" Lee 5 Business Partner del sandbox de SAP y los compara con el titular (6.6). No guarda nada.
" La clave de API NO se sube a GitHub: escribela en lc_clave solo en tu sistema.
CLASS zcl_tl_consultar_bp DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    CONSTANTS lc_clave TYPE string VALUE ``.         " <- tu clave de api.sap.com, solo en local
ENDCLASS.

CLASS zcl_tl_consultar_bp IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    IF lc_clave IS INITIAL.
      out->write( 'Falta la clave de API (constante lc_clave)' ).
      RETURN.
    ENDIF.
    DATA(lv_clave) = lc_clave.

    TRY.
        " La URL: servicio de Business Partner, 5 registros, 2 campos, en JSON
        DATA(lo_destino) = cl_http_destination_provider=>create_by_url(
          |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner| &&
          |?$top=5&$select=BusinessPartner,BusinessPartnerFullName&$format=json| ).
        DATA(lo_cliente) = cl_web_http_client_manager=>create_by_http_destination( lo_destino ).
        " El sandbox pide la clave de API en una cabecera (lv_clave: nunca escrita en el codigo)
        lo_cliente->get_http_request( )->set_header_field( i_name = 'APIKey' i_value = lv_clave ).
        DATA(lo_respuesta) = lo_cliente->execute( if_web_http_client=>get ).

        " OData V2: { "d": { "results": [ ... ] } }
        TYPES: BEGIN OF ty_bp,
                 business_partner           TYPE string,
                 business_partner_full_name TYPE string,
               END OF ty_bp.
        TYPES: BEGIN OF ty_resultados,
                 results TYPE STANDARD TABLE OF ty_bp WITH EMPTY KEY,
               END OF ty_resultados.
        " La estructura imita el JSON por fuera: d -> results -> lista
        DATA: BEGIN OF ls_respuesta,
                d TYPE ty_resultados,
              END OF ls_respuesta.
        /ui2/cl_json=>deserialize( EXPORTING json        = lo_respuesta->get_text( )
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING  data        = ls_respuesta ).
        lo_cliente->close( ).
      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        out->write( lx_error->get_text( ) ).
        RETURN.
    ENDTRY.

    " Cada Business Partner junto al campo del titular donde encajaria
    LOOP AT ls_respuesta-d-results INTO DATA(ls_bp).
      out->write( |{ ls_bp-business_partner }: { ls_bp-business_partner_full_name } -> ztl_tit-razon_social| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
