@EndUserText.label : 'Borrador: Abonos del titular'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_abo_d {
  key mandt             : abap.clnt not null;
  key abonouuid         : sysuuid_x16 not null;
  abonoref              : abap.char(8);
  ordenuuid             : sysuuid_x16;
  titularuuid           : sysuuid_x16;
  fecha                 : abap.dats;
  cantidadabonada       : abap.dec(15,2);
  mediopago             : abap.char(15);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
