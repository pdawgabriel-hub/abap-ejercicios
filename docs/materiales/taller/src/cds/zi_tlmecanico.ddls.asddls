@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlMecanico
  as select from ztl_mec
  // Las ausencias son hijas del mecanico
  composition [0..*] of ZI_TlAusencia as _Ausencias
{
  key mecanico_uuid            as MecanicoUUID,
      mecanico_ref             as MecanicoRef,
      nombre                   as Nombre,
      apellidos                as Apellidos,
      categoria                as Categoria,
      tarifa_base              as TarifaBase,
      // 2.4: nombre y apellidos juntos, para buscar y mostrar
      concat_with_space( nombre, apellidos, 1 ) as NombreCompleto,
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
      _Ausencias
}
