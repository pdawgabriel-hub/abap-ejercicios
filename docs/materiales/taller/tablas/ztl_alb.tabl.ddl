@EndUserText.label : 'Taller - Albaranes de recambios'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_alb {
  key client            : abap.clnt not null;
  key albaran_uuid      : sysuuid_x16 not null;
  orden_uuid            : sysuuid_x16;
  distribuidor_uuid     : sysuuid_x16;
  fecha                 : abap.dats;
  importe_neto          : abap.dec(15,2);
  liquidado             : abap_boolean;   // X si ya se ha pagado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
