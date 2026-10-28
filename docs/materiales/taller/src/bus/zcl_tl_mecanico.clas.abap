" Un mecanico como objeto: su referencia y su tarifa (1.6)
CLASS zcl_tl_mecanico DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Se ejecuta al hacer NEW: recibe la referencia y, si no se indica, tarifa 30
    METHODS constructor
      IMPORTING iv_ref    TYPE zif_tl_tipos=>ty_ref
                iv_tarifa TYPE zif_tl_tipos=>ty_euros DEFAULT 30.
    " Metodos de lectura (getters): devuelven el valor de un atributo
    METHODS ref
      RETURNING VALUE(rv_ref) TYPE zif_tl_tipos=>ty_ref.
    METHODS tarifa
      RETURNING VALUE(rv_tarifa) TYPE zif_tl_tipos=>ty_euros.
    " Metodo de escritura (setter): cambia la tarifa
    METHODS revisar_tarifa
      IMPORTING iv_nueva TYPE zif_tl_tipos=>ty_euros.
  PRIVATE SECTION.
    " Atributos: cada objeto tiene los suyos. Privados: solo los toca la clase
    DATA mv_ref    TYPE zif_tl_tipos=>ty_ref.
    DATA mv_tarifa TYPE zif_tl_tipos=>ty_euros.
ENDCLASS.

CLASS zcl_tl_mecanico IMPLEMENTATION.
  METHOD constructor.
    " Guardar en los atributos lo que llega por parametro
    mv_ref    = iv_ref.
    mv_tarifa = iv_tarifa.
  ENDMETHOD.

  METHOD ref.
    rv_ref = mv_ref.
  ENDMETHOD.

  METHOD tarifa.
    rv_tarifa = mv_tarifa.
  ENDMETHOD.

  METHOD revisar_tarifa.
    mv_tarifa = iv_nueva.
  ENDMETHOD.
ENDCLASS.
