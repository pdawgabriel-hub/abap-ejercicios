@EndUserText.label : 'Taller - Abonos del titular'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_abo {
  key client            : abap.clnt not null;
  key abono_uuid        : sysuuid_x16 not null;
  abono_ref             : abap.char(8);   // ABO0001
  orden_uuid            : sysuuid_x16;
  titular_uuid          : sysuuid_x16;
  fecha                 : abap.dats;
  cantidad_abonada      : abap.dec(15,2);
  medio_pago            : abap.char(15);   // efectivo, tarjeta...
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
