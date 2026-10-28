@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Tramos de jornada (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlTramo
  as projection on ZI_TlTramo
{
  key TramoUUID,
      JornadaUUID,
      @ObjectModel.text.element: [ 'MecanicoNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlMecanico', element: 'MecanicoUUID' } } ]
      MecanicoUUID,
      Tiempo,
      TarifaAplicada,
      CosteTramo,
      LocalLastChangedAt,                  // el etag: lo necesita RAP
      _Mecanico.NombreCompleto as MecanicoNombre,

      /* Associations */
      _Jornada : redirected to parent ZC_TlJornada,
      _Mecanico : redirected to ZC_TlMecanico
}
