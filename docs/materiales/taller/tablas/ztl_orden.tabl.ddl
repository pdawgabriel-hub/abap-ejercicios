@EndUserText.label : 'Taller - Ordenes de reparacion'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_orden {
  key client            : abap.clnt not null;
  key orden_uuid        : sysuuid_x16 not null;
  orden_ref             : abap.char(8);   // ORD0001
  matricula             : abap.char(10);
  averia                : abap.char(255);
  titular_uuid          : sysuuid_x16;   // de quien es el vehiculo
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
