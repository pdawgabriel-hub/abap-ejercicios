@EndUserText.label : 'Taller - Registro de ordenes cobradas'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_cobro_log {
  key client            : abap.clnt not null;
  key log_uuid          : sysuuid_x16 not null;
  orden_uuid            : sysuuid_x16;
  momento               : timestampl;   // cuando se apunto
  mensaje               : abap.char(120);
}
