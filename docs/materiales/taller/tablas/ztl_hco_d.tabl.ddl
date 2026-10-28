@EndUserText.label : 'Borrador: Hojas de costes'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_hco_d {
  key mandt             : abap.clnt not null;
  key hojauuid          : sysuuid_x16 not null;
  ordenuuid             : sysuuid_x16;
  hojaref               : abap.char(8);
  fechaentrada          : abap.dats;
  fechaentrega          : abap.dats;
  garantia              : abap_boolean;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
