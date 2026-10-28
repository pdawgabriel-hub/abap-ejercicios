@EndUserText.label : 'Taller - Partidas de presupuesto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_par {
  key client            : abap.clnt not null;
  key partida_uuid      : sysuuid_x16 not null;
  presupuesto_uuid      : sysuuid_x16 not null;   // el padre
  concepto              : abap.char(120);
  cantidad              : abap.int4;
  precio_unitario       : abap.dec(15,2);
  importe_partida       : abap.dec(15,2);   // calculado
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
