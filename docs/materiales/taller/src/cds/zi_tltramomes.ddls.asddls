@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Tramos con su mes'
// Paso 1 para agrupar por mes: calcular el mes (group by no admite expresiones)
define view entity ZI_TlTramoMes
  as select from ztl_jor_tra as Tramo
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
{
  key Tramo.tramo_uuid                                      as TramoUUID,
      Tramo.mecanico_uuid                                   as MecanicoUUID,
      // AAAAMMDD -> AAAAMM
      substring( cast( Jornada.dia as abap.char(8) ), 1, 6 ) as Mes,
      Tramo.coste_tramo                                     as CosteTramo
}
