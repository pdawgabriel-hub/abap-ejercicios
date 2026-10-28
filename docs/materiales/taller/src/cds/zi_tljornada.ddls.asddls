@AccessControl.authorizationCheck: #CHECK           // 6.1: filtra con el rol ZI_TlJornada
@EndUserText.label: 'Taller - Registros de jornada'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlJornada
  as select from ztl_jor
  composition [0..*] of ZI_TlTramo as _Tramos
  association [0..1] to ZI_TlOrden as _Orden on $projection.OrdenUUID = _Orden.OrdenUUID
{
  key jornada_uuid             as JornadaUUID,
      orden_uuid               as OrdenUUID,
      dia                      as Dia,
      trabajo                  as Trabajo,
      tiempo_total             as TiempoTotal,
      coste_total              as CosteTotal,
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
      _Tramos,
      _Orden
}
