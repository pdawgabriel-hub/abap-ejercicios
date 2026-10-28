@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes por semaforo'
@Metadata.allowExtensions: true
// Sobre el resumen de 2.4: una fila por color
define view entity ZI_TlKpiSemaforo
  as select from ZI_TlOrdenResumen
{
  key Semaforo,
      SemaforoCriticality,                     // para pintar el color en la app
      count( * )                                      as Ordenes,
      cast( sum( SaldoPendiente ) as abap.dec(15,2) ) as Pendiente
}
group by Semaforo, SemaforoCriticality      // todo lo que no es agregado
