@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Avisos de la orden (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlOrdenAviso
  as projection on ZI_TlOrdenAviso
{
  key AvisoUUID,
      OrdenUUID,
      Comentario,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Orden : redirected to parent ZC_TlOrden
}
