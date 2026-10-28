@EndUserText.label : 'Borrador: Partidas de presupuesto'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_par_d {
  key mandt             : abap.clnt not null;
  key partidauuid       : sysuuid_x16 not null;
  presupuestouuid       : sysuuid_x16;
  concepto              : abap.char(120);
  cantidad              : abap.int4;
  preciounitario        : abap.dec(15,2);
  importepartida        : abap.dec(15,2);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
