@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Abonos (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlAbono
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlAbono
{
  key AbonoUUID,
      @Search.defaultSearchElement: true
      AbonoRef,
      @ObjectModel.text.element: [ 'OrdenRef' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlOrden', element: 'OrdenUUID' } } ]
      OrdenUUID,
      @ObjectModel.text.element: [ 'TitularNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlTitular', element: 'TitularUUID' } } ]
      TitularUUID,
      Fecha,
      CantidadAbonada,
      MedioPago,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Orden.OrdenRef as OrdenRef,
      _Titular.RazonSocial as TitularNombre,

      /* Associations */
      _Orden : redirected to ZC_TlOrden,
      _Titular : redirected to ZC_TlTitular
}
