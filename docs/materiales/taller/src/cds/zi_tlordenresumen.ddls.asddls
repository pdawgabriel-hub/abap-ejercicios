@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Resumen de la orden'
@Metadata.allowExtensions: true
define view entity ZI_TlOrdenResumen
  // Apilada sobre las sumas: aqui ya se pueden usar Importe, Costes y Abonado
  as select from ZI_TlOrdenSumas
{
  key OrdenUUID,
      Importe,
      ManoObra,
      Costes,
      Abonado,
      // Restas simples
      cast( Abonado - Costes as abap.dec(15,2) ) as Rendimiento,
      cast( Importe - Abonado as abap.dec(15,2) ) as SaldoPendiente,
      cast( Importe - Costes as abap.dec(15,2) )  as Previsto,

      // Porcentaje: sin division por cero y sin pasar de 100
      case
        when Importe = 0         then cast( 0 as abap.dec(4,1) )
        when Abonado >= Importe  then cast( 100 as abap.dec(4,1) )
        else cast( division( Abonado * 100, Importe, 1 ) as abap.dec(4,1) )
      end                                         as PorcentajeLiquidado,

      // Las condiciones se miran en orden: gana la primera que se cumple
      case
        when Abonado <= 0        then cast( 'sin_abonar'      as abap.char(15) )
        when Abonado < Importe   then cast( 'abonado_parcial' as abap.char(15) )
        else                          cast( 'liquidado'       as abap.char(15) )
      end                                         as SituacionCobro,

      // Pierde dinero -> rojo; liquidada -> verde; lo demas -> ambar
      case
        when Abonado - Costes < 0                 then cast( 'rojo'  as abap.char(15) )
        when Abonado > 0 and Abonado >= Importe   then cast( 'verde' as abap.char(15) )
        else                                           cast( 'ambar' as abap.char(15) )
      end                                         as Semaforo,

      // La misma regla en el codigo de colores de Fiori: 1 rojo, 2 ambar, 3 verde
      case
        when Abonado - Costes < 0                 then 1
        when Abonado > 0 and Abonado >= Importe   then 3
        else                                           2
      end                                         as SemaforoCriticality,

      // Cerrada si no queda nada por cobrar y se ha cobrado algo (la usa 6.1)
      case
        when Importe - Abonado <= 0 and Abonado > 0 then cast( 'cerrada' as abap.char(15) )
        else                                             cast( 'abierta' as abap.char(15) )
      end                                         as EstadoHoja
}
