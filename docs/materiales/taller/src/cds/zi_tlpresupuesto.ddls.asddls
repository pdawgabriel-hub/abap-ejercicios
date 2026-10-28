@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Presupuestos'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TlPresupuesto
  as select from ztl_prs
  // Hijos: solo existen dentro del presupuesto
  composition [0..*] of ZI_TlPartida    as _Partidas
  composition [0..*] of ZI_TlPresuDis   as _Previstos
  composition [0..*] of ZI_TlPresuNota  as _Notas
  composition [0..*] of ZI_TlPresuAviso as _Avisos
  composition [0..*] of ZI_TlPresuFoto  as _Fotos
  // Otras raices con las que se relaciona
  association [0..1] to ZI_TlTitular as _Titular on $projection.TitularUUID = _Titular.TitularUUID
  association [0..1] to ZI_TlOrden   as _Orden   on $projection.OrdenUUID   = _Orden.OrdenUUID
{
  key presupuesto_uuid         as PresupuestoUUID,
      presupuesto_ref          as PresupuestoRef,
      fecha                    as Fecha,
      titular_uuid             as TitularUUID,
      orden_uuid               as OrdenUUID,
      titular_nombre           as TitularNombre,
      titular_documento        as TitularDocumento,
      impuesto                 as Impuesto,
      situacion                as Situacion,
      neto                     as Neto,
      cuota                    as Cuota,
      importe                  as Importe,
      moneda                   as Moneda,
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
      _Partidas,
      _Previstos,
      _Notas,
      _Avisos,
      _Fotos,
      _Titular,
      _Orden
}
