@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos por mes'
// Paso 2: encima de la anterior, ya se puede agrupar por Mes
define view entity ZI_TlKpiMecanicosMes
  as select from ZI_TlTramoMes
{
  key MecanicoUUID,
  key Mes,
      cast( sum( CosteTramo ) as abap.dec(15,2) ) as Euros
}
group by MecanicoUUID, Mes
