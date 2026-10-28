@EndUserText.label : 'Taller - Presupuestos'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs {
  key client            : abap.clnt not null;
  key presupuesto_uuid  : sysuuid_x16 not null;
  presupuesto_ref       : abap.char(8);   // PRS0001
  fecha                 : abap.dats;
  titular_uuid          : sysuuid_x16;   // de quien es
  orden_uuid            : sysuuid_x16;   // opcional: puede no tener orden aun
  titular_nombre        : abap.char(100);   // copia congelada del titular
  titular_documento     : abap.char(12);   // copia congelada del titular
  impuesto              : abap.dec(5,2);
  situacion             : abap.char(15);   // borrador / aceptado
  neto                  : abap.dec(15,2);   // calculado y guardado
  cuota                 : abap.dec(15,2);   // calculado y guardado
  importe               : abap.dec(15,2);   // calculado y guardado
  moneda                : abap.cuky;   // EUR (6.2)
  // Campos de administracion: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
