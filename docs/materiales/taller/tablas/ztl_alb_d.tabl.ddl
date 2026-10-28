@EndUserText.label : 'Borrador: Albaranes de recambios'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_alb_d {
  key mandt             : abap.clnt not null;
  key albaranuuid       : sysuuid_x16 not null;
  ordenuuid             : sysuuid_x16;
  distribuidoruuid      : sysuuid_x16;
  fecha                 : abap.dats;
  importeneto           : abap.dec(15,2);
  liquidado             : abap_boolean;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
