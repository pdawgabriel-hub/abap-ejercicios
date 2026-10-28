" Tipos y constantes del taller RuedaLibre (1.2, ampliada en 1.3, 1.4 y 1.8)
INTERFACE zif_tl_tipos PUBLIC.

  " Tipos basicos con nombre propio: si un dia cambia el tipo, se cambia aqui
  TYPES ty_euros     TYPE decfloat34.
  TYPES ty_tanto     TYPE decfloat34.          " porcentajes
  TYPES ty_tiempo    TYPE decfloat34.          " horas
  TYPES ty_ref       TYPE c LENGTH 8.          " codigos TIT0001, ORD0001...
  TYPES ty_situacion TYPE c LENGTH 15.

  " Listas sencillas (1.4)
  TYPES tt_textos TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  TYPES tt_refs   TYPE STANDARD TABLE OF ty_ref WITH EMPTY KEY.

  " Una partida de presupuesto (1.2)
  TYPES: BEGIN OF ty_partida,
           concepto        TYPE string,
           cantidad        TYPE i,
           precio_unitario TYPE ty_euros,
         END OF ty_partida.
  TYPES tt_partidas TYPE STANDARD TABLE OF ty_partida WITH EMPTY KEY.

  " Un presupuesto visto desde su orden (1.4)
  TYPES: BEGIN OF ty_presupuesto,
           ref       TYPE ty_ref,
           situacion TYPE ty_situacion,
           importe   TYPE ty_euros,
         END OF ty_presupuesto.
  TYPES tt_presupuestos TYPE STANDARD TABLE OF ty_presupuesto WITH EMPTY KEY.

  " Un tramo de una jornada: quien, cuanto tiempo y a que tarifa (1.4)
  TYPES: BEGIN OF ty_tramo,
           mecanico        TYPE ty_ref,
           tiempo          TYPE ty_tiempo,
           tarifa_aplicada TYPE ty_euros,
         END OF ty_tramo.
  TYPES tt_tramos TYPE STANDARD TABLE OF ty_tramo WITH EMPTY KEY.

  " Un puesto del ranking de mecanicos (1.4)
  TYPES: BEGIN OF ty_puesto,
           mecanico TYPE ty_ref,
           tiempo   TYPE ty_tiempo,
           euros    TYPE ty_euros,
         END OF ty_puesto.
  TYPES tt_ranking TYPE STANDARD TABLE OF ty_puesto WITH EMPTY KEY.

  " La hoja de costes de una orden, ya calculada (1.8)
  TYPES: BEGIN OF ty_resumen,
           importe     TYPE ty_euros,
           costes      TYPE ty_euros,
           abonado     TYPE ty_euros,
           rendimiento TYPE ty_euros,
           saldo       TYPE ty_euros,
           previsto    TYPE ty_euros,
           porcentaje  TYPE ty_tanto,
           situacion   TYPE ty_situacion,
           semaforo    TYPE ty_situacion,
           estado_hoja TYPE ty_situacion,
         END OF ty_resumen.

  " Grupos de constantes: se usan como zif_tl_tipos=>situacion_presupuesto-aceptado
  CONSTANTS: BEGIN OF situacion_presupuesto,
               borrador TYPE ty_situacion VALUE 'borrador',
               aceptado TYPE ty_situacion VALUE 'aceptado',
             END OF situacion_presupuesto.

  CONSTANTS: BEGIN OF situacion_cobro,
               sin_abonar      TYPE ty_situacion VALUE 'sin_abonar',
               abonado_parcial TYPE ty_situacion VALUE 'abonado_parcial',
               liquidado       TYPE ty_situacion VALUE 'liquidado',
             END OF situacion_cobro.

  CONSTANTS: BEGIN OF semaforo,
               verde TYPE ty_situacion VALUE 'verde',
               ambar TYPE ty_situacion VALUE 'ambar',
               rojo  TYPE ty_situacion VALUE 'rojo',
             END OF semaforo.

  CONSTANTS: BEGIN OF estado_hoja,
               abierta TYPE ty_situacion VALUE 'abierta',
               cerrada TYPE ty_situacion VALUE 'cerrada',
             END OF estado_hoja.

ENDINTERFACE.
