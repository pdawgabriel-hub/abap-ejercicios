@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Fotos del presupuesto (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlPresuFoto
  as projection on ZI_TlPresuFoto
{
  key FotoUUID,
      PresupuestoUUID,
      Imagen,
      TipoMime,
      NombreFichero,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Presupuesto : redirected to parent ZC_TlPresupuesto
}
