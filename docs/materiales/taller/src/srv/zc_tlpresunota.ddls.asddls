@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Notas del presupuesto (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlPresuNota
  as projection on ZI_TlPresuNota
{
  key NotaUUID,
      PresupuestoUUID,
      Comentario,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Presupuesto : redirected to parent ZC_TlPresupuesto
}
