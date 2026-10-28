" Excepcion del taller: un aviso de negocio con su texto y el campo al que se refiere (1.7)
CLASS zcx_tl_aviso DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    " READ-ONLY: se puede leer desde fuera, pero no cambiar
    DATA mv_mensaje  TYPE string READ-ONLY.    " texto para el usuario
    DATA mv_elemento TYPE string READ-ONLY.    " campo al que se refiere

    " Todos los parametros opcionales; previous es la excepcion que la causo (si la hay)
    METHODS constructor
      IMPORTING iv_mensaje  TYPE string OPTIONAL
                iv_elemento TYPE string OPTIONAL
                !previous   LIKE previous OPTIONAL.

    " Sustituir el get_text heredado para que devuelva nuestro mensaje
    METHODS if_message~get_text REDEFINITION.
ENDCLASS.

CLASS zcx_tl_aviso IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).       " obligatorio: el constructor de la superclase
    mv_mensaje  = iv_mensaje.
    mv_elemento = iv_elemento.
  ENDMETHOD.

  METHOD if_message~get_text.
    result = mv_mensaje.
  ENDMETHOD.
ENDCLASS.
