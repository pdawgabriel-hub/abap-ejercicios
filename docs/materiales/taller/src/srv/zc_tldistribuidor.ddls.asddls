@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Distribuidores (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlDistribuidor
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlDistribuidor
{
  key DistribuidorUUID,
      @Search.defaultSearchElement: true
      DistribuidorRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Nombre,
      Neto,
      Impuesto,
      Bruto,
      LocalLastChangedAt                   // el etag: lo necesita RAP
}
