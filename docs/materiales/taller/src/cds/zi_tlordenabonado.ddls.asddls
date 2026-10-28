@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Abonado de la orden'
define view entity ZI_TlOrdenAbonado
  as select from ztl_abo
{
  // Suma de lo que ha pagado el titular por cada orden
  key orden_uuid                                        as OrdenUUID,
      cast( sum( cantidad_abonada ) as abap.dec(15,2) ) as Cantidad
}
group by orden_uuid
