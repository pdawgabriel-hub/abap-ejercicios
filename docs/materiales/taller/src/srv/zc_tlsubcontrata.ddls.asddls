@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Subcontratas (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlSubcontrata
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlSubcontrata
{
  key SubcontrataUUID,
      @Search.defaultSearchElement: true
      SubcontrataRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Nombre,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Oficio,
      TarifaReferencia,
      LocalLastChangedAt                   // el etag: lo necesita RAP
}
