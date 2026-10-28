@EndUserText.label : 'Borrador: Tramos de jornada'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_jor_tra_d {
  key mandt             : abap.clnt not null;
  key tramouuid         : sysuuid_x16 not null;
  jornadauuid           : sysuuid_x16;
  mecanicouuid          : sysuuid_x16;
  tiempo                : abap.dec(9,2);
  tarifaaplicada        : abap.dec(15,2);
  costetramo            : abap.dec(15,2);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
