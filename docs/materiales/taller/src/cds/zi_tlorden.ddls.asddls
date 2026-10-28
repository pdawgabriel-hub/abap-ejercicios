@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes de reparacion'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlOrden
  as select from ztl_orden
  // La hoja de costes: una por orden, hija suya
  composition [0..1] of ZI_TlHojaCostes as _HojaCostes
  composition [0..*] of ZI_TlOrdenNota  as _Notas
  composition [0..*] of ZI_TlOrdenAviso as _Avisos
  composition [0..*] of ZI_TlOrdenFoto  as _Fotos
  association [0..1] to ZI_TlTitular       as _Titular   on $projection.TitularUUID = _Titular.TitularUUID
  // Los calculos de 2.4, que se leen pero no se guardan
  association [1]    to ZI_TlOrdenResumen  as _Resumen   on $projection.OrdenUUID = _Resumen.OrdenUUID
  association [0..*] to ZI_TlOrdenMecanico as _Mecanicos on $projection.OrdenUUID = _Mecanicos.OrdenUUID
{
  key orden_uuid               as OrdenUUID,
      orden_ref                as OrdenRef,
      matricula                as Matricula,
      averia                   as Averia,
      titular_uuid             as TitularUUID,
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
      _HojaCostes,
      _Notas,
      _Avisos,
      _Fotos,
      _Titular,
      _Resumen,
      _Mecanicos
}
