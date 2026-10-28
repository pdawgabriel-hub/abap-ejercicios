@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Tramos de jornada'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlTramo
  as select from ztl_jor_tra
  association to parent ZI_TlJornada as _Jornada on $projection.JornadaUUID = _Jornada.JornadaUUID
  association [0..1] to ZI_TlMecanico as _Mecanico on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  key tramo_uuid               as TramoUUID,
      jornada_uuid             as JornadaUUID,
      mecanico_uuid            as MecanicoUUID,
      tiempo                   as Tiempo,
      tarifa_aplicada          as TarifaAplicada,
      coste_tramo              as CosteTramo,
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
      _Jornada,
      _Mecanico
}
