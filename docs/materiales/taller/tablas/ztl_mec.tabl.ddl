@EndUserText.label : 'Taller - Mecanicos'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_mec {
  key client            : abap.clnt not null;
  key mecanico_uuid     : sysuuid_x16 not null;
  mecanico_ref          : abap.char(8);   // MEC0001
  nombre                : abap.char(60);
  apellidos             : abap.char(80);
  categoria             : abap.char(20);   // oficial, ayudante...
  tarifa_base           : abap.dec(15,2);   // euros por hora (30 si no se indica)
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
