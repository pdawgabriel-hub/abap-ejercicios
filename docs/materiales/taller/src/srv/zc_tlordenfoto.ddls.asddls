@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Fotos de la orden (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlOrdenFoto
  as projection on ZI_TlOrdenFoto
{
  key FotoUUID,
      OrdenUUID,
      Imagen,
      TipoMime,
      NombreFichero,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Orden : redirected to parent ZC_TlOrden
}
