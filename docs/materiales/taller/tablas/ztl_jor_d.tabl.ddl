@EndUserText.label : 'Borrador: Registros de jornada'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_jor_d {
  key mandt             : abap.clnt not null;
  key jornadauuid       : sysuuid_x16 not null;
  ordenuuid             : sysuuid_x16;
  dia                   : abap.dats;
  trabajo               : abap.char(120);
  tiempototal           : abap.dec(9,2);
  costetotal            : abap.dec(15,2);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
