@EndUserText.label : 'Taller - Tramos de jornada'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_jor_tra {
  key client            : abap.clnt not null;
  key tramo_uuid        : sysuuid_x16 not null;
  jornada_uuid          : sysuuid_x16 not null;   // el padre
  mecanico_uuid         : sysuuid_x16;
  tiempo                : abap.dec(9,2);   // horas
  tarifa_aplicada       : abap.dec(15,2);   // copia de la tarifa del mecanico
  coste_tramo           : abap.dec(15,2);   // calculado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
