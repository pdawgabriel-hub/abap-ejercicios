@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes de reparacion (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlOrden
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlOrden
{
  key OrdenUUID,
      @Search.defaultSearchElement: true
      OrdenRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Matricula,
      Averia,
      @ObjectModel.text.element: [ 'TitularNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlTitular', element: 'TitularUUID' } } ]
      TitularUUID,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Titular.RazonSocial as TitularNombre,

      /* Associations */
      _HojaCostes : redirected to composition child ZC_TlHojaCostes,
      _Notas : redirected to composition child ZC_TlOrdenNota,
      _Avisos : redirected to composition child ZC_TlOrdenAviso,
      _Fotos : redirected to composition child ZC_TlOrdenFoto,
      _Titular : redirected to ZC_TlTitular,
      _Resumen,
      _Mecanicos
}
