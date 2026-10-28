@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Presupuestos (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlPresupuesto
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlPresupuesto
{
  key PresupuestoUUID,
      @Search.defaultSearchElement: true
      PresupuestoRef,
      Fecha,
      @ObjectModel.text.element: [ 'TitularNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlTitular', element: 'TitularUUID' } } ]
      TitularUUID,
      @ObjectModel.text.element: [ 'OrdenRef' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlOrden', element: 'OrdenUUID' } } ]
      OrdenUUID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      TitularNombre,
      TitularDocumento,
      Impuesto,
      Situacion,
      Neto,
      Cuota,
      Importe,
      Moneda,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Orden.OrdenRef as OrdenRef,

      /* Associations */
      _Partidas : redirected to composition child ZC_TlPartida,
      _Previstos : redirected to composition child ZC_TlPresuDis,
      _Notas : redirected to composition child ZC_TlPresuNota,
      _Avisos : redirected to composition child ZC_TlPresuAviso,
      _Fotos : redirected to composition child ZC_TlPresuFoto,
      _Titular : redirected to ZC_TlTitular,
      _Orden : redirected to ZC_TlOrden
}
