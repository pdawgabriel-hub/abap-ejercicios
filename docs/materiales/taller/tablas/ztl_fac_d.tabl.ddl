@EndUserText.label : 'Borrador: Facturas de subcontrata'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_fac_d {
  key mandt             : abap.clnt not null;
  key facturauuid       : sysuuid_x16 not null;
  ordenuuid             : sysuuid_x16;
  subcontratauuid       : sysuuid_x16;
  fecha                 : abap.dats;
  importeneto           : abap.dec(15,2);
  liquidado             : abap_boolean;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
