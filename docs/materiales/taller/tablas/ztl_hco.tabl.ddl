@EndUserText.label : 'Taller - Hojas de costes'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_hco {
  key client            : abap.clnt not null;
  key hoja_uuid         : sysuuid_x16 not null;
  orden_uuid            : sysuuid_x16 not null;   // el padre (1:1)
  hoja_ref              : abap.char(8);   // HCO0001
  fecha_entrada         : abap.dats;
  fecha_entrega         : abap.dats;
  garantia              : abap_boolean;   // X si la reparacion va en garantia
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
