" DEFINICION: que tiene la clase.
" PUBLIC: se puede usar desde otros objetos; FINAL: no se puede heredar de ella;
" CREATE PUBLIC: cualquiera puede crear objetos de esta clase.
CLASS zcl_tl_bienvenida DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Implementar esta interfaz convierte la clase en ejecutable con F9
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

" IMPLEMENTACION: el codigo de cada metodo.
CLASS zcl_tl_bienvenida IMPLEMENTATION.
  " El metodo main de la interfaz: es lo que se ejecuta al pulsar F9.
  " out es el objeto que escribe en la pestana Console.
  METHOD if_oo_adt_classrun~main.
    " Cabecera del taller
    out->write( 'Taller RuedaLibre' ).
    out->write( 'Reparacion y mantenimiento de vehiculos' ).
    out->write( ' ' ).                      " una linea en blanco
    out->write( 'Series de codigos:' ).
    out->write( 'Titulares      TIT0001' ).
    out->write( 'Ordenes        ORD0001' ).
  ENDMETHOD.
ENDCLASS.
