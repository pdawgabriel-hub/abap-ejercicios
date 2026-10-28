@EndUserText.label : 'Taller - Titulares'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_tit {
  key client            : abap.clnt not null;
  key titular_uuid      : sysuuid_x16 not null;
  titular_ref           : abap.char(8);   // TIT0001
  razon_social          : abap.char(100);
  documento_id          : abap.char(12);   // NIF o CIF
  contacto              : abap.char(20);   // telefono
  poblacion             : abap.char(60);
  cp                    : abap.char(5);
  pais                  : land1;   // ES, PT... (I_Country)
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
