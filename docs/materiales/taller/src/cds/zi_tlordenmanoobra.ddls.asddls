@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mano de obra de la orden'
define view entity ZI_TlOrdenManoObra
  as select from ztl_jor_tra as Tramo
    // El tramo no sabe su orden: la saca de su jornada
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
{
  key Jornada.orden_uuid                                  as OrdenUUID,
      // Dos sumas en la misma vista: horas y euros
      cast( sum( Tramo.tiempo ) as abap.dec(9,2) )        as Tiempo,
      cast( sum( Tramo.coste_tramo ) as abap.dec(15,2) )  as ManoObra
}
group by Jornada.orden_uuid
