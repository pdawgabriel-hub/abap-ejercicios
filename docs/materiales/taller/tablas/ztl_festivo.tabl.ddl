@EndUserText.label : 'Taller - Festivos (copia de la API)'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_festivo {
  key client            : abap.clnt not null;
  key fecha             : abap.dats not null;
  nombre                : abap.char(80);
}
