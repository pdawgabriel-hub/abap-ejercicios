@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Titulares'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlTitular
  as select from ztl_tit
  // Vista liberada de SAP con los paises: se usa igual que una propia
  association [0..1] to I_Country as _Pais on $projection.Pais = _Pais.Country
{
  key titular_uuid             as TitularUUID,
      titular_ref              as TitularRef,
      razon_social             as RazonSocial,
      documento_id             as DocumentoId,
      contacto                 as Contacto,
      poblacion                as Poblacion,
      cp                       as Cp,
      pais                     as Pais,
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
      _Pais
}
