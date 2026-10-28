@EndUserText.label : 'Borrador: Distribuidores de recambios'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_dis_d {
  key mandt             : abap.clnt not null;
  key distribuidoruuid  : sysuuid_x16 not null;
  distribuidorref       : abap.char(8);
  nombre                : abap.char(100);
  neto                  : abap.dec(15,2);
  impuesto              : abap.dec(5,2);
  bruto                 : abap.dec(15,2);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
