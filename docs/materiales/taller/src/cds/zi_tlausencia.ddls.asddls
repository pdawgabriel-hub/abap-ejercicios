@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ausencias de mecanico'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlAusencia
  as select from ztl_aus
  association to parent ZI_TlMecanico as _Mecanico on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  key ausencia_uuid            as AusenciaUUID,
      mecanico_uuid            as MecanicoUUID,
      desde                    as Desde,
      hasta                    as Hasta,
      motivo                   as Motivo,
      jornadas                 as Jornadas,
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
      _Mecanico
}
