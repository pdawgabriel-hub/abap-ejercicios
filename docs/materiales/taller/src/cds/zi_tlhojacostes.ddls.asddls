@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Hojas de costes'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlHojaCostes
  as select from ztl_hco
  association to parent ZI_TlOrden as _Orden on $projection.OrdenUUID = _Orden.OrdenUUID
{
  key hoja_uuid                as HojaUUID,
      orden_uuid               as OrdenUUID,
      hoja_ref                 as HojaRef,
      fecha_entrada            as FechaEntrada,
      fecha_entrega            as FechaEntrega,
      garantia                 as Garantia,
      // Campos de administracion: @Semantics le dice a RAP que es cada uno
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      /* Associations */
      _Orden
}
