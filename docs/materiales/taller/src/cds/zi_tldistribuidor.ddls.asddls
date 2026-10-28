@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Distribuidores'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlDistribuidor
  as select from ztl_dis
{
  key distribuidor_uuid        as DistribuidorUUID,
      distribuidor_ref         as DistribuidorRef,
      nombre                   as Nombre,
      neto                     as Neto,
      impuesto                 as Impuesto,
      bruto                    as Bruto,
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
      local_last_changed_at    as LocalLastChangedAt
}
