@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Importe de la orden'
define view entity ZI_TlOrdenImporte
  as select from ztl_prs
{
  // Una fila por orden: la clave es el campo del group by
  key orden_uuid                               as OrdenUUID,
      // La suma de los importes de esa orden
      cast( sum( importe ) as abap.dec(15,2) ) as Importe
}
// Solo cuentan los aceptados (el where se aplica antes de agrupar)
where situacion = 'aceptado'
// Todo campo que no sea un agregado tiene que estar en el group by
group by orden_uuid
