@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Hojas de costes (proyeccion)'
@Metadata.allowExtensions: true          // las anotaciones de UI, en su metadata extension (4.3)
define view entity ZC_TlHojaCostes
  as projection on ZI_TlHojaCostes
{
  key HojaUUID,
      OrdenUUID,
      HojaRef,
      FechaEntrada,
      FechaEntrega,
      Garantia,
      LocalLastChangedAt,                  // el etag: lo necesita RAP

      /* Associations */
      _Orden : redirected to parent ZC_TlOrden
}
