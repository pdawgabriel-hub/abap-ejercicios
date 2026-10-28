@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Facturas de subcontrata'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlFactura
  as select from ztl_fac
  association [0..1] to ZI_TlOrden       as _Orden       on $projection.OrdenUUID = _Orden.OrdenUUID
  association [0..1] to ZI_TlSubcontrata as _Subcontrata on $projection.SubcontrataUUID = _Subcontrata.SubcontrataUUID
{
  key factura_uuid             as FacturaUUID,
      orden_uuid               as OrdenUUID,
      subcontrata_uuid         as SubcontrataUUID,
      fecha                    as Fecha,
      importe_neto             as ImporteNeto,
      liquidado                as Liquidado,
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
      _Orden,
      _Subcontrata
}
