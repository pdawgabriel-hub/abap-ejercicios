@EndUserText.label : 'Taller - Subcontratas'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_sub {
  key client            : abap.clnt not null;
  key subcontrata_uuid  : sysuuid_x16 not null;
  subcontrata_ref       : abap.char(8);   // SUB0001
  nombre                : abap.char(100);
  oficio                : abap.char(40);
  tarifa_referencia     : abap.dec(15,2);
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
