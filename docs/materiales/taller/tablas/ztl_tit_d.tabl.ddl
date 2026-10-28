@EndUserText.label : 'Borrador: Titulares'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_tit_d {
  key mandt             : abap.clnt not null;
  key titularuuid       : sysuuid_x16 not null;
  titularref            : abap.char(8);
  razonsocial           : abap.char(100);
  documentoid           : abap.char(12);
  contacto              : abap.char(20);
  poblacion             : abap.char(60);
  cp                    : abap.char(5);
  pais                  : land1;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
