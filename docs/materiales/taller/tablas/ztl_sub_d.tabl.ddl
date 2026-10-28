@EndUserText.label : 'Borrador: Subcontratas'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_sub_d {
  key mandt             : abap.clnt not null;
  key subcontratauuid   : sysuuid_x16 not null;
  subcontrataref        : abap.char(8);
  nombre                : abap.char(100);
  oficio                : abap.char(40);
  tarifareferencia      : abap.dec(15,2);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
