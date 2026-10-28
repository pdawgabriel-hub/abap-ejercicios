@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Distribuidores previstos (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlPresuDis
  as projection on ZI_TlPresuDis
{
  key PrevistoUUID,
      PresupuestoUUID,
      @ObjectModel.text.element: [ 'DistribuidorNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlDistribuidor', element: 'DistribuidorUUID' } } ]
      DistribuidorUUID,
      Observacion,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Distribuidor.Nombre as DistribuidorNombre,

      /* Associations */
      _Presupuesto : redirected to parent ZC_TlPresupuesto,
      _Distribuidor : redirected to ZC_TlDistribuidor
}
