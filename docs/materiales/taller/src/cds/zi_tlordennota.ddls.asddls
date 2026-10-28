@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Notas de la orden'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlOrdenNota
  as select from ztl_ord_not
  association to parent ZI_TlOrden as _Orden on $projection.OrdenUUID = _Orden.OrdenUUID
{
  key nota_uuid                as NotaUUID,
      orden_uuid               as OrdenUUID,
      comentario               as Comentario,
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
