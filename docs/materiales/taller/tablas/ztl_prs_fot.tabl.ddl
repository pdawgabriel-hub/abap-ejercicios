@EndUserText.label : 'Taller - Fotos y adjuntos del presupuesto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_fot {
  key client            : abap.clnt not null;
  key foto_uuid         : sysuuid_x16 not null;
  presupuesto_uuid      : sysuuid_x16 not null;   // el padre
  include ztl_s_foto;
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
