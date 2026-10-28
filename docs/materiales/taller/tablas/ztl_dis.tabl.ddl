@EndUserText.label : 'Taller - Distribuidores de recambios'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_dis {
  key client            : abap.clnt not null;
  key distribuidor_uuid : sysuuid_x16 not null;
  distribuidor_ref      : abap.char(8);   // DIS0001
  nombre                : abap.char(100);
  neto                  : abap.dec(15,2);   // neto de referencia
  impuesto              : abap.dec(5,2);
  bruto                 : abap.dec(15,2);   // calculado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
