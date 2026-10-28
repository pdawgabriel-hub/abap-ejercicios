@EndUserText.label : 'Borrador: Fotos y adjuntos del presupuesto'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_fot_d {
  key mandt             : abap.clnt not null;
  key fotouuid          : sysuuid_x16 not null;
  presupuestouuid       : sysuuid_x16;
  imagen                : abap.rawstring(0);
  tipomime              : abap.char(128);
  nombrefichero         : abap.char(128);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
