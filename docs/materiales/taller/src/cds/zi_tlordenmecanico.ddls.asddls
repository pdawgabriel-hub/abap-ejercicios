@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos de cada orden'
define view entity ZI_TlOrdenMecanico
  // distinct: cada pareja orden-mecanico una sola vez, aunque haya muchos tramos
  as select distinct from ztl_jor_tra as Tramo
    // el tramo no sabe su orden: se une con su jornada, que si la sabe
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
  association [1] to ZI_TlMecanico as _Mecanico on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  // La clave son las dos columnas juntas
  key Jornada.orden_uuid  as OrdenUUID,
  key Tramo.mecanico_uuid as MecanicoUUID,
      _Mecanico
}
