@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Albaranes de recambios (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define root view entity ZC_TlAlbaran
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlAlbaran
{
  key AlbaranUUID,
      @ObjectModel.text.element: [ 'OrdenRef' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlOrden', element: 'OrdenUUID' } } ]
      OrdenUUID,
      @ObjectModel.text.element: [ 'DistribuidorNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlDistribuidor', element: 'DistribuidorUUID' } } ]
      DistribuidorUUID,
      Fecha,
      ImporteNeto,
      Liquidado,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Orden.OrdenRef as OrdenRef,
      _Distribuidor.Nombre as DistribuidorNombre,

      /* Associations */
      _Orden : redirected to ZC_TlOrden,
      _Distribuidor : redirected to ZC_TlDistribuidor
}
