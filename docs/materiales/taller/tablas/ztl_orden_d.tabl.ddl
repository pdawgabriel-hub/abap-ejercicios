@EndUserText.label : 'Borrador: Ordenes de reparacion'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_orden_d {
  key mandt             : abap.clnt not null;
  key ordenuuid         : sysuuid_x16 not null;
  ordenref              : abap.char(8);
  matricula             : abap.char(10);
  averia                : abap.char(255);
  titularuuid           : sysuuid_x16;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
