@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Distribuidores previstos'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlPresuDis
  as select from ztl_prs_dis
  association to parent ZI_TlPresupuesto as _Presupuesto on $projection.PresupuestoUUID = _Presupuesto.PresupuestoUUID
  association [1] to ZI_TlDistribuidor as _Distribuidor on $projection.DistribuidorUUID = _Distribuidor.DistribuidorUUID
{
  key previsto_uuid            as PrevistoUUID,
      presupuesto_uuid         as PresupuestoUUID,
      distribuidor_uuid        as DistribuidorUUID,
      observacion              as Observacion,
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
      _Presupuesto,
      _Distribuidor
}
