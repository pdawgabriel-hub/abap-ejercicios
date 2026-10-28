@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Sumas de la orden'
define view entity ZI_TlOrdenSumas
  // Se parte de TODAS las ordenes...
  as select from ztl_orden as Orden
    // ...y se pega cada suma; left outer: si no hay fila, queda nulo, no se pierde la orden
    left outer join ZI_TlOrdenImporte   as Imp on Imp.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenManoObra  as Mo  on Mo.OrdenUUID  = Orden.orden_uuid
    left outer join ZI_TlOrdenRecambios as Rec on Rec.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenSubcontr  as Sub on Sub.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenAbonado   as Abo on Abo.OrdenUUID = Orden.orden_uuid
{
  key Orden.orden_uuid                                        as OrdenUUID,
      // coalesce: el nulo de una orden sin presupuestos se convierte en 0
      cast( coalesce( Imp.Importe, 0 ) as abap.dec(15,2) )    as Importe,
      cast( coalesce( Mo.ManoObra, 0 ) as abap.dec(15,2) )    as ManoObra,
      // Cada sumando con su coalesce: nulo + 100 da nulo, no 100
      cast( coalesce( Mo.ManoObra, 0 ) + coalesce( Rec.Neto, 0 )
            + coalesce( Sub.Neto, 0 ) as abap.dec(15,2) )     as Costes,
      cast( coalesce( Abo.Cantidad, 0 ) as abap.dec(15,2) )   as Abonado
}
