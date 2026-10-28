@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Titulares (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlTitular
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlTitular
{
  key TitularUUID,
      @Search.defaultSearchElement: true
      TitularRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      RazonSocial,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      DocumentoId,
      Contacto,
      Poblacion,
      Cp,
      @ObjectModel.text.element: [ 'PaisNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Country', element: 'Country' } } ]
      Pais,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Pais._Text[1: Language = $session.system_language].CountryName as PaisNombre,

      /* Associations */
      _Pais
}
