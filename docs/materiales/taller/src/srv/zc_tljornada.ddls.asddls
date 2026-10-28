@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Registros de jornada (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlJornada
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlJornada
{
  key JornadaUUID,
      @ObjectModel.text.element: [ 'OrdenRef' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlOrden', element: 'OrdenUUID' } } ]
      OrdenUUID,
      Dia,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Trabajo,
      TiempoTotal,
      CosteTotal,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Orden.OrdenRef as OrdenRef,

      /* Associations */
      _Tramos : redirected to composition child ZC_TlTramo,
      _Orden : redirected to ZC_TlOrden
}
