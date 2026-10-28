@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlMecanico
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlMecanico
{
  key MecanicoUUID,
      @Search.defaultSearchElement: true
      MecanicoRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Nombre,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Apellidos,
      Categoria,
      TarifaBase,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      NombreCompleto,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Ausencias : redirected to composition child ZC_TlAusencia
}
