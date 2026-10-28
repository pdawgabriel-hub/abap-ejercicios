@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Calendario de movimientos'
@Metadata.allowExtensions: true
define view entity ZI_TlCalendario
  // Rama 1: los presupuestos
  as select from ztl_prs
{
  // Tipo + UUID: clave unica aunque se junten tablas distintas
  key cast( 'presupuesto' as abap.char(12) ) as Tipo,
  key presupuesto_uuid                       as RegistroUUID,
      fecha                                  as Fecha,
      cast( presupuesto_ref as abap.char(60) ) as Titulo   // mismo tipo en todas las ramas
}
// Rama 2: las jornadas (mismas columnas, mismos tipos)
union all select from ztl_jor
{
  key cast( 'jornada' as abap.char(12) )     as Tipo,
  key jornada_uuid                           as RegistroUUID,
      dia                                    as Fecha,
      cast( trabajo as abap.char(60) )       as Titulo
}
// Rama 3: los abonos
union all select from ztl_abo
{
  key cast( 'abono' as abap.char(12) )       as Tipo,
  key abono_uuid                             as RegistroUUID,
      fecha                                  as Fecha,
      cast( abono_ref as abap.char(60) )     as Titulo
}
