@EndUserText.label : 'Borrador: Mecanicos'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_mec_d {
  key mandt             : abap.clnt not null;
  key mecanicouuid      : sysuuid_x16 not null;
  mecanicoref           : abap.char(8);
  nombre                : abap.char(60);
  apellidos             : abap.char(80);
  categoria             : abap.char(20);
  tarifabase            : abap.dec(15,2);
  nombrecompleto        : abap.char(141);   // campo calculado de la vista
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
