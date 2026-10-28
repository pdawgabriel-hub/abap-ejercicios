@EndUserText.label : 'Borrador: Presupuestos'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_d {
  key mandt             : abap.clnt not null;
  key presupuestouuid   : sysuuid_x16 not null;
  presupuestoref        : abap.char(8);
  fecha                 : abap.dats;
  titularuuid           : sysuuid_x16;
  ordenuuid             : sysuuid_x16;
  titularnombre         : abap.char(100);
  titulardocumento      : abap.char(12);
  impuesto              : abap.dec(5,2);
  situacion             : abap.char(15);
  neto                  : abap.dec(15,2);
  cuota                 : abap.dec(15,2);
  importe               : abap.dec(15,2);
  moneda                : abap.cuky;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
