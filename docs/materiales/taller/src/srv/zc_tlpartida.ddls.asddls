@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Partidas de presupuesto (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlPartida
  as projection on ZI_TlPartida
{
  key PartidaUUID,
      PresupuestoUUID,
      Concepto,
      Cantidad,
      PrecioUnitario,
      ImportePartida,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Presupuesto : redirected to parent ZC_TlPresupuesto
}
