@EndUserText.label : 'Taller - Registros de jornada'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_jor {
  key client            : abap.clnt not null;
  key jornada_uuid      : sysuuid_x16 not null;
  orden_uuid            : sysuuid_x16;   // en que orden se ha trabajado
  dia                   : abap.dats;
  trabajo               : abap.char(120);   // que se ha hecho
  tiempo_total          : abap.dec(9,2);   // calculado
  coste_total           : abap.dec(15,2);   // calculado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
