@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Albaranes de recambios'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlAlbaran
  as select from ztl_alb
  association [0..1] to ZI_TlOrden        as _Orden        on $projection.OrdenUUID = _Orden.OrdenUUID
  association [0..1] to ZI_TlDistribuidor as _Distribuidor on $projection.DistribuidorUUID = _Distribuidor.DistribuidorUUID
{
  key albaran_uuid             as AlbaranUUID,
      orden_uuid               as OrdenUUID,
      distribuidor_uuid        as DistribuidorUUID,
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
      _Distribuidor
}
