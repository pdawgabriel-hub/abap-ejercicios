@EndUserText.label : 'Borrador: Distribuidores previstos'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_dis_d {
  key mandt             : abap.clnt not null;
  key previstouuid      : sysuuid_x16 not null;
  presupuestouuid       : sysuuid_x16;
  distribuidoruuid      : sysuuid_x16;
  observacion           : abap.char(120);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
