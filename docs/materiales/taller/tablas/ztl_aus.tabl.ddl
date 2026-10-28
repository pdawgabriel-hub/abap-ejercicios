@EndUserText.label : 'Taller - Ausencias de mecanico'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_aus {
  key client            : abap.clnt not null;
  key ausencia_uuid     : sysuuid_x16 not null;
  mecanico_uuid         : sysuuid_x16 not null;   // el padre
  desde                 : abap.dats;
  hasta                 : abap.dats;
  motivo                : abap.char(255);
  jornadas              : abap.int4;   // calculado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
