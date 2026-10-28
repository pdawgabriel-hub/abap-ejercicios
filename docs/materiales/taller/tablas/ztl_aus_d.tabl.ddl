@EndUserText.label : 'Borrador: Ausencias de mecanico'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_aus_d {
  key mandt             : abap.clnt not null;
  key ausenciauuid      : sysuuid_x16 not null;
  mecanicouuid          : sysuuid_x16;
  desde                 : abap.dats;
  hasta                 : abap.dats;
  motivo                : abap.char(255);
  jornadas              : abap.int4;
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  lastchangedby         : abp_locinst_lastchange_user;
  lastchangedat         : abp_lastchange_tstmpl;
  locallastchangedat    : abp_locinst_lastchange_tstmpl;
  "%admin"              : include sych_bdl_draft_admin_inc;
}
