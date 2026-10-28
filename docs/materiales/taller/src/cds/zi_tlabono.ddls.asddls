@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Abonos'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlAbono
  as select from ztl_abo
  association [0..1] to ZI_TlOrden   as _Orden   on $projection.OrdenUUID   = _Orden.OrdenUUID
  association [0..1] to ZI_TlTitular as _Titular on $projection.TitularUUID = _Titular.TitularUUID
{
  key abono_uuid               as AbonoUUID,
      abono_ref                as AbonoRef,
      orden_uuid               as OrdenUUID,
      titular_uuid             as TitularUUID,
      fecha                    as Fecha,
      cantidad_abonada         as CantidadAbonada,
      medio_pago               as MedioPago,
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
      _Titular
}
