CLASS zcl_ej_obras DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_obra,
             codigo    TYPE string,
             direccion TYPE string,
           END OF ty_obra.
    TYPES tt_obras TYPE STANDARD TABLE OF ty_obra WITH EMPTY KEY.

    " Devuelve la obra con ese codigo. Si no existe, devuelve la estructura vacia
    " (usa TRY ... CATCH cx_sy_itab_line_not_found)
    CLASS-METHODS buscar
      IMPORTING it_obras TYPE tt_obras
                iv_codigo TYPE string
      RETURNING VALUE(rs_obra) TYPE ty_obra.

    " abap_true si existe una obra con ese codigo
    CLASS-METHODS existe
      IMPORTING it_obras TYPE tt_obras
                iv_codigo TYPE string
      RETURNING VALUE(rv_existe) TYPE abap_boolean.
ENDCLASS.

CLASS zcl_ej_obras IMPLEMENTATION.
  METHOD buscar.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.

  METHOD existe.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
