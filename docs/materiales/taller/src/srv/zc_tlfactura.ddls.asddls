@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Facturas de subcontrata (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define root view entity ZC_TlFactura
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlFactura
{
  key FacturaUUID,
      @ObjectModel.text.element: [ 'OrdenRef' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlOrden', element: 'OrdenUUID' } } ]
      OrdenUUID,
      @ObjectModel.text.element: [ 'SubcontrataNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlSubcontrata', element: 'SubcontrataUUID' } } ]
      SubcontrataUUID,
      Fecha,
      ImporteNeto,
      Liquidado,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Orden.OrdenRef as OrdenRef,
      _Subcontrata.Nombre as SubcontrataNombre,

      /* Associations */
      _Orden : redirected to ZC_TlOrden,
      _Subcontrata : redirected to ZC_TlSubcontrata
}
