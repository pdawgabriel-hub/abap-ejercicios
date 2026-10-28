@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Partidas de presupuesto'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlPartida
  as select from ztl_prs_par
  association to parent ZI_TlPresupuesto as _Presupuesto on $projection.PresupuestoUUID = _Presupuesto.PresupuestoUUID
{
  key partida_uuid             as PartidaUUID,
      presupuesto_uuid         as PresupuestoUUID,
      concepto                 as Concepto,
      cantidad                 as Cantidad,
      precio_unitario          as PrecioUnitario,
      importe_partida          as ImportePartida,
      // Campos de administracion: @Semantics le dice a RAP que es cada uno
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      /* Associations */
      _Presupuesto
}
