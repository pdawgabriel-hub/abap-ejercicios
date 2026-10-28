@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Recambios de la orden'
define view entity ZI_TlOrdenRecambios
  as select from ztl_alb
{
  // Suma de los albaranes de cada orden
  key orden_uuid                                    as OrdenUUID,
      cast( sum( importe_neto ) as abap.dec(15,2) ) as Neto
}
group by orden_uuid
