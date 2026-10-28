@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Subcontratas'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlSubcontrata
  as select from ztl_sub
{
  key subcontrata_uuid         as SubcontrataUUID,
      subcontrata_ref          as SubcontrataRef,
      nombre                   as Nombre,
      oficio                   as Oficio,
      tarifa_referencia        as TarifaReferencia,
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
