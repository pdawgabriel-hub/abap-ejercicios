# 3.6. Composiciones: hijos y tablas satélite

Casi todos los modelos de `gestion_bd` tienen, además de sus campos, tres listas que se repiten (§2 del informe): **observaciones** (notas de seguimiento), **incidencias** (problemas) y **archivos adjuntos**. Las tres guardan automáticamente quién y cuándo, y se muestran de la más nueva a la más antigua. El taller tiene lo mismo con otros nombres: **notas**, **avisos** y **fotos**. En esta unidad vemos el patrón con las del presupuesto del taller, y tú las añadirás a todos los objetos de negocio de tu ERP. Son 21 tablas, pero todas siguen el mismo patrón, así que lo importante es hacer bien la primera.

## Una estructura común

Las notas de todas las entidades del taller tienen los mismos campos propios. En lugar de repetirlos en cada tabla, se declara una **estructura** y cada tabla la **incluye**:

```cds
@EndUserText.label : 'Taller - Campos de una nota o un aviso'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
// Una estructura no es una tabla: solo agrupa campos para incluirlos en otras
define structure ztl_s_comentario {
  comentario : abap.string(0);      // texto sin limite de longitud
}
```

```cds
@EndUserText.label : 'Taller - Campos de una foto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
define structure ztl_s_foto {
  imagen         : abap.rawstring(0);   // el fichero, en binario
  tipo_mime      : abap.char(128);      // image/png, application/pdf...
  nombre_fichero : abap.char(128);      // como se llamaba al subirlo
}
```

Las notas del presupuesto del taller quedan así:

```cds
@EndUserText.label : 'Taller - Notas del presupuesto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_not {
  key client            : abap.clnt not null;
  key nota_uuid         : sysuuid_x16 not null;
  presupuesto_uuid      : sysuuid_x16 not null;   // el padre
  include ztl_s_comentario;                        // los campos de la estructura, aqui
  // Autor y fecha de la nota: los rellena RAP
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
```

**El autor y la fecha no son campos nuevos**: son `created_by` y `created_at`, que RAP ya rellena solo (2.2). En Odoo, la fecha y el usuario de una bitácora llevan un `default` cada uno; aquí no hace falta nada.

## Fotos y adjuntos: objetos grandes

Una foto (o cualquier fichero) se guarda en la propia tabla, en un campo `rawstring` (en Odoo iría al *filestore*, fuera de la base de datos). Para que Fiori ofrezca **subir y descargar** el fichero, la vista CDS anota qué campo es el contenido, cuál el tipo MIME y cuál el nombre:

```cds
define view entity ZI_TlPresuFoto
  as select from ztl_prs_fot
  association to parent ZI_TlPresupuesto as _Presupuesto
    on $projection.PresupuestoUUID = _Presupuesto.PresupuestoUUID
{
  key foto_uuid        as FotoUUID,
      presupuesto_uuid as PresupuestoUUID,
      // Este campo es el fichero: su tipo y su nombre estan en estos otros dos campos
      @Semantics.largeObject: { mimeType: 'TipoMime',
                                fileName: 'NombreFichero',
                                contentDispositionPreference: #INLINE }
      imagen           as Imagen,
      @Semantics.mimeType: true             // este campo es un tipo MIME
      tipo_mime        as TipoMime,
      nombre_fichero   as NombreFichero,
      ...
      _Presupuesto
}
```

Una ventaja frente a Odoo: el fichero y su fila son **lo mismo**. Al borrar la fila desaparece el fichero. Busca en §11.5 (punto 14) del informe qué código necesitaba Odoo para conseguirlo. `#INLINE` hace que el navegador muestre la foto; `#ATTACHMENT`, que la descargue.

> **En el trial, ficheros pequeños.** El espacio es limitado y compartido. Para probar, usa PDF e imágenes de pocos cientos de KB.

## El comportamiento de los hijos

En la BDEF del presupuesto del taller, las tres listas son tres composiciones más, con el mismo patrón que las partidas (3.1):

```bdef
  // En la raiz: una composicion mas por cada lista
  association _Partidas { create; with draft; }
  association _Notas    { create; with draft; }
  association _Avisos   { create; with draft; }
  association _Fotos    { create; with draft; }
...
// Cada lista es una entidad hija, igual que las partidas
define behavior for ZI_TlPresuNota alias Nota
persistent table ztl_prs_not
draft table ztl_prs_not_d
lock dependent by _Presupuesto
authorization dependent by _Presupuesto
etag master LocalLastChangedAt
{
  update;
  delete;
  field ( numbering : managed, readonly ) NotaUUID;
  field ( readonly ) PresupuestoUUID, CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;
  field ( mandatory ) Comentario;
  association _Presupuesto { with draft; }
  // Varias parejas por linea: el orden da igual
  mapping for ztl_prs_not corresponding
  {
    NotaUUID = nota_uuid;  PresupuestoUUID = presupuesto_uuid;  Comentario = comentario;
    CreatedBy = created_by;  CreatedAt = created_at;  LastChangedBy = last_changed_by;
    LastChangedAt = last_changed_at;  LocalLastChangedAt = local_last_changed_at;
  }
}
```

Los **alias** de los hijos deben ser únicos **dentro de cada BDEF**: en el presupuesto del taller, `Partida`, `Nota`, `Aviso` y `Foto`. En otra BDEF se pueden repetir.

> **Código completo del taller:** [ztl_s_comentario](./materiales/taller/tablas/ztl_s_comentario.tabl.ddl), [ztl_prs_not](./materiales/taller/tablas/ztl_prs_not.tabl.ddl), [ZI_TlPresuFoto](./materiales/taller/src/cds/zi_tlpresufoto.ddls.asddls) y la [BDEF del presupuesto](./materiales/taller/src/bus/zi_tlpresupuesto.bdef.asbdef). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Tus estructuras y tablas van en `ZGOR_DDIC`, las vistas en `ZGOR_CDS`, y el comportamiento se añade a tus BDEF. Para cada tabla satélite hacen falta cuatro piezas: tabla, vista hija, composición en la vista raíz y entidad en la BDEF (con su tabla de borradores).

## Ejercicios

1. **Las estructuras.**
    - **Dónde:** clic derecho en `ZGOR_DDIC` → **New → Other ABAP Repository Object** → *Dictionary* → **Structure**. Dos estructuras: `zgor_s_bitacora` (descripción `Campos de una observacion o incidencia`) y `zgor_s_archivo` (`Campos de un archivo adjunto`).
    - **Qué contienen** (§2 del informe), como `ztl_s_comentario` del taller:

        | Estructura | Campos |
        |---|---|
        | `zgor_s_bitacora` | `texto : abap.string(0);` |
        | `zgor_s_archivo` | `archivo : abap.rawstring(0);`, `mimetype : abap.char(128);`, `nombre_archivo : abap.char(128);`, `tipo : abap.char(15);` |

    - **Comprueba:** activa las dos sin errores.

2. **Las tres del presupuesto.** Este ejercicio crea, para cada satélite, una tabla, una vista y su entidad en la BDEF, en este orden:
    - **Las tablas** (`ZGOR_DDIC`, *New → Database Table*): `zgor_presu_obs` (clave `obs_uuid`) y `zgor_presu_inc` (clave `inc_uuid`), con `include zgor_s_bitacora;`, y `zgor_presu_arc` (clave `archivo_uuid`), con `include zgor_s_archivo;`. Las tres con `presupuesto_uuid : sysuuid_x16 not null;` y los cinco campos de administración, como `ztl_prs_not`.
    - **Las vistas** (`ZGOR_CDS`): `ZI_GorPresuObs`, `ZI_GorPresuInc` y `ZI_GorPresuArc`, cada una con su `association to parent ZI_GorPresupuesto as _Presupuesto`. En la de archivos, las anotaciones `@Semantics.largeObject` (con `contentDispositionPreference: #ATTACHMENT`) y `@Semantics.mimeType`, como en el taller.
    - **En la raíz** `ZI_GorPresupuesto`: las composiciones `_Observaciones`, `_Incidencias` y `_Archivos`, expuestas.
    - **En la BDEF:** tres `define behavior for` nuevos (alias `Observacion`, `Incidencia`, `Archivo`) con `lock dependent by _Presupuesto`, `authorization dependent by _Presupuesto`, `update; delete;`, `Texto` obligatorio y su `mapping`; en la raíz, `association _Observaciones { create; with draft; }` y las otras dos. Sus tablas de borradores, con **Ctrl+1**.
    - **Comprueba:** activa todo junto (clic derecho en `ZGOR` → **Activate** con los objetos nuevos seleccionados) sin errores.

3. **Pruébalo con EML.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.6 Observaciones`.
    - **Qué hace:** con `MODIFY ENTITIES OF zi_gorpresupuesto ENTITY Presupuesto CREATE BY \_Observaciones` y `CREATE BY \_Incidencias`, añade a `PREP0001` una observación («Cliente pide azulejo gris») y una incidencia («Retraso en la entrega»), y guarda.
    - **Comprueba:** `SELECT FROM zi_gorpresuobs FIELDS Texto, CreatedBy, CreatedAt` devuelve la observación con `CreatedBy` y `CreatedAt` **rellenos** sin haberlos escrito.

4. **El tipo de archivo.**
    - **Dónde:** BDEF del presupuesto, entidad `Archivo`; clase local `lhc_archivo`.
    - **En la BDEF:** `determination tipoDeArchivo on modify { create; field Mimetype; }`.
    - **Qué hace:** pone `Tipo` a `imagen` si el tipo MIME empieza por `image/`, `pdf` si es `application/pdf` y `otro` en los demás casos (§2). Pista: el operador `CP` de 1.4 (`IF ls_archivo-Mimetype CP 'image/*'`).
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, crea tres archivos en `PREP0001` con `Mimetype` `image/png`, `application/pdf` y `text/plain` (el contenido puede ser un `xstring` cualquiera) y lee su `Tipo`: `imagen`, `pdf` y `otro`.

5. **Todas las demás.** Crea las 18 restantes con los mismos pasos que el ejercicio 2 (estructura incluida, vista con `association to parent`, composición en la raíz y entidad en la BDEF). Tabla, vista y alias siguen siempre el patrón `zgor_<padre>_obs|inc|arc` → `ZI_Gor<Padre>Obs|Inc|Arc`:

    | BO | Observaciones | Incidencias | Archivos |
    |---|---|---|---|
    | Cliente | `zgor_cli_obs` | — | — |
    | Trabajador | `zgor_trab_obs` | — | `zgor_trab_arc` |
    | Proveedor | `zgor_prov_obs` | — | `zgor_prov_arc` |
    | Especialista | `zgor_esp_obs` | — | `zgor_esp_arc` |
    | Obra | `zgor_obra_obs` | `zgor_obra_inc` | `zgor_obra_arc` |
    | Gasto (hijo de Obra) | — | — | `zgor_gasto_arc` (nieto de la obra: ver la nota de abajo) |
    | Ingreso | `zgor_ing_obs` | — | `zgor_ing_arc` |
    | Parte de trabajo | — | `zgor_pt_inc` | — |
    | Parte de especialista | — | `zgor_pe_inc` | `zgor_pe_arc` |
    | Parte de proveedor | — | `zgor_pp_inc` | `zgor_pp_arc` |

    **Los adjuntos de la ficha de gastos son nietos** de la obra, y el bloqueo y los permisos de un nieto dependen de la **raíz**, no de su padre. Por eso `zgor_gasto_arc` guarda los dos UUID, `gasto_uuid` y `obra_uuid`. En su vista, el `association to parent ZI_GorGasto as _Gasto` une por los dos (`on $projection.GastoUUID = _Gasto.GastoUUID and $projection.ObraUUID = _Gasto.ObraUUID`), para que RAP rellene ambos al crear el adjunto, y una association `[1]` a `ZI_GorObra as _Obra` lleva a la raíz. En la BDEF: `lock dependent by _Obra` y `authorization dependent by _Obra`.

    Es exactamente la tabla de satélites de §2 del informe. Las vistas de los partes usan `ZI_GorParteTrabInc`, `ZI_GorParteEspInc`, `ZI_GorParteEspArc`, `ZI_GorParteProvInc` y `ZI_GorParteProvArc`. Repite la determination `tipoDeArchivo` en cada entidad de archivos (o, mejor, añade a `ZCL_GOR_REGLAS` un método `tipo_archivo( iv_mimetype )` con su test, y llámalo desde todas).
6. **Borrar sin restos.**
    - **Dónde:** el método `save_modified` de `lsc_zi_gorobra` (3.5).
    - **Qué hace:** antes de borrar los partes de la obra, borra las incidencias de sus partes de trabajo y las incidencias y adjuntos de sus partes externos (`DELETE FROM zgor_pt_inc WHERE parte_uuid IN ...`). Los satélites de la propia obra (y los adjuntos de su ficha de gastos) se borran solos: son hijos de su composición.
    - **Comprueba:** repite la prueba del ejercicio 4 de 3.5 añadiendo una incidencia al parte de trabajo antes de borrar la obra: `SELECT COUNT( * ) FROM zgor_pt_inc` vuelve al valor de antes.
7. **Investiga.** Abre tu tabla de borradores `zgor_presu_obs_d`, la que generó Eclipse. ¿Qué contiene el bloque `"%admin"`? Busca con **F2** sobre su tipo qué campos tiene y anota para qué crees que sirve cada uno.

---

**Siguiente:** [3.7. Numeración](./3_7_numeracion.md)
