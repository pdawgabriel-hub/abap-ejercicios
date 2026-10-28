@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos por dia'
@Metadata.allowExtensions: true
// Una fila por mecanico y dia: la app filtra el periodo por fecha
define view entity ZI_TlKpiMecanicos
  as select from ztl_jor_tra as Tramo
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
  association [1] to ZI_TlMecanico as _Mecanico on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  key Tramo.mecanico_uuid                                as MecanicoUUID,
  key Jornada.dia                                        as Dia,
      cast( sum( Tramo.tiempo ) as abap.dec(9,2) )       as Tiempo,
      cast( sum( Tramo.coste_tramo ) as abap.dec(15,2) ) as Euros,
      _Mecanico
}
group by Tramo.mecanico_uuid, Jornada.dia
