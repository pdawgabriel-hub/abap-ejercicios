CLASS zcl_ej_estados DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " 'P' -> Pendiente, 'C' -> En curso, 'F' -> Finalizada, otro -> Desconocido
    CLASS-METHODS texto_estado
      IMPORTING iv_estado TYPE string
      RETURNING VALUE(rv_texto) TYPE string.
    " Quita espacios sobrantes (inicio, fin y repetidos) y pasa a mayusculas
    CLASS-METHODS limpiar_nombre
      IMPORTING iv_nombre TYPE string
      RETURNING VALUE(rv_nombre) TYPE string.
ENDCLASS.

CLASS zcl_ej_estados IMPLEMENTATION.
  METHOD texto_estado.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.

  METHOD limpiar_nombre.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
