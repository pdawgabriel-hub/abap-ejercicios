@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Fotos del presupuesto'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TlPresuFoto
  as select from ztl_prs_fot
  association to parent ZI_TlPresupuesto as _Presupuesto on $projection.PresupuestoUUID = _Presupuesto.PresupuestoUUID
{
  key foto_uuid                as FotoUUID,
      presupuesto_uuid         as PresupuestoUUID,
      // Este campo es el fichero; su tipo y su nombre estan en los otros dos
      @Semantics.largeObject: { mimeType: 'TipoMime', fileName: 'NombreFichero',
                                contentDispositionPreference: #INLINE }
      imagen                   as Imagen,
      @Semantics.mimeType: true
      tipo_mime                as TipoMime,
      nombre_fichero           as NombreFichero,
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
      _Presupuesto
}
