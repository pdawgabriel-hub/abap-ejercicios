@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Subcontratas de la orden'
define view entity ZI_TlOrdenSubcontr
  as select from ztl_fac
{
  // Suma de las facturas de subcontrata de cada orden
  key orden_uuid                                    as OrdenUUID,
      cast( sum( importe_neto ) as abap.dec(15,2) ) as Neto
}
group by orden_uuid
