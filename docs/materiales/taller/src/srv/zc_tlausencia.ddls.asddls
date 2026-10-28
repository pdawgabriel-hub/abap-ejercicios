@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ausencias de mecanico (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlAusencia
  as projection on ZI_TlAusencia
{
  key AusenciaUUID,
      MecanicoUUID,
      Desde,
      Hasta,
      Motivo,
      Jornadas,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Mecanico : redirected to parent ZC_TlMecanico
}
