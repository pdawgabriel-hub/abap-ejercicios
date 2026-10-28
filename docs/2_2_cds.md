# 2.2. CDS View Entities

Las tablas guardan los datos, pero RAP no trabaja directamente con ellas: trabaja con **vistas CDS** (*Core Data Services*). Una vista CDS es una definición declarativa, parecida a un `CREATE VIEW` de SQL, que además lleva **anotaciones** (metadatos para el framework y para Fiori) y **associations** (relaciones navegables). En esta unidad creamos una vista por tabla: la capa *interface* del ERP, con prefijo `ZI_`.

## Las capas de vistas

Encima de cada tabla habrá dos vistas:

| Capa | Prefijo | Qué hace | Bloque |
|---|---|---|---|
| **Interface** | `ZI_` | El modelo de negocio: nombres claros, relaciones, cálculos. El comportamiento RAP se define sobre ella | 2 y 3 |
| **Proyección** | `ZC_` | Adapta el modelo a un uso concreto (una app Fiori): qué campos, qué búsquedas, qué textos | 4 |

Es la misma idea que separar el modelo (`models/`) de las vistas (`views/`) en Odoo.

## Una vista CDS

Así es la de los titulares del taller:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED      // sin control de acceso (hasta 6.1)
@EndUserText.label: 'Taller - Titulares'
@Metadata.ignorePropagatedAnnotations: true            // no heredar anotaciones de la tabla
define view entity ZI_TlTitular
  as select from ztl_tit                               // la tabla de debajo
{
  // columna de la tabla  as  nombre en la vista (CamelCase)
  key titular_uuid          as TitularUUID,
      titular_ref           as TitularRef,
      razon_social          as RazonSocial,
      documento_id          as DocumentoId,
      contacto              as Contacto,
      poblacion             as Poblacion,
      cp                    as Cp,
      // Campos de administracion: @Semantics le dice a RAP que es cada uno
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
```

- **`define view entity`** es el tipo moderno de vista CDS. Hay otro antiguo (`define view` con `@AbapCatalog.sqlViewName`) que verás en código viejo; en ABAP Cloud se usa siempre `view entity`.
- **Alias en *CamelCase***: la columna `razon_social` se expone como `RazonSocial`. Los nombres de la vista son los que verán el comportamiento RAP, el servicio OData y Fiori. En el taller, los UUID terminan en `UUID` y los códigos visibles, en `Ref`.
- **`@Semantics...`** en los campos de administración indica a RAP qué es cada uno, para que los rellene solo al crear y al modificar. Sin estas anotaciones, se quedarían vacíos.
- **`@AccessControl.authorizationCheck: #NOT_REQUIRED`**: de momento, sin control de acceso. En [6.1](./6_1_seguridad.md) lo cambiaremos.
- **`@Metadata.ignorePropagatedAnnotations: true`**: no hereda anotaciones de las tablas de debajo, para que la vista diga exactamente lo que declaramos.

## Crear una vista

1. Clic derecho en `ZGOR_CDS` → **New → Other ABAP Repository Object** → *Data Definition*.
2. Nombre de la vista, descripción y, en *Referenced Object*, la tabla de debajo.
3. El asistente ofrece plantillas: elige **Define View Entity**. Con la tabla de referencia, Eclipse ya rellena las columnas. Ponles los alias, guarda y activa.

## Data Preview

Con la vista abierta, **F8** abre el *Data Preview*: los datos de la vista tal como los vería RAP. Después de cada vista nueva, ábrelo. Debe mostrar las mismas filas que la tabla, con los nombres de columna nuevos.

El Data Preview permite también filtrar, ordenar y, cuando haya associations (2.3), **navegar** de un registro a sus relacionados.

## Preparación del entorno de trabajo

Todas las vistas van en `ZGOR_CDS`. Al terminar habrá una por tabla:

```
ZGOR_CDS
├── ZI_GorCliente, ZI_GorTrabajador, ZI_GorFalta
├── ZI_GorProveedor, ZI_GorEspecialista
├── ZI_GorPresupuesto, ZI_GorPresuLin, ZI_GorPresuProv, ZI_GorPresuEsp
├── ZI_GorObra, ZI_GorGasto
├── ZI_GorIngreso
└── ZI_GorParteTrabajo, ZI_GorParteTrabLin, ZI_GorParteEsp, ZI_GorParteProv
```

## Ejercicios

1. **Clientes.**
    - **Dónde:** clic derecho en `ZGOR_CDS` → **New → Other ABAP Repository Object** → *Data Definition*. Nombre `ZI_GorCliente`, descripción `Clientes`, plantilla *Define View Entity*.
    - **Qué contiene:** una vista sobre `zgor_cli` con estos alias: `ClienteUUID` (clave), `ClienteId`, `Nombre`, `Apellidos`, `Nif`, `Direccion`, `CodPostal`, `Telf` y los cinco campos de administración con sus `@Semantics`, igual que en el taller.
    - **Comprueba:** en `ZCL_GOR_SQL_DEMO`, lee de la **vista** (`SELECT FROM zi_gorcliente FIELDS ClienteId, Nombre ...`) y escribe el resultado: salen tus tres clientes de 1.5, con los nombres de la vista. ABAP SQL lee igual una tabla que una vista CDS.

2. **Líneas de presupuesto.**
    - **Dónde:** igual, en `ZGOR_CDS`. Nombre `ZI_GorPresuLin`, descripción `Lineas de presupuesto`.
    - **Qué contiene:** una vista sobre `zgor_presu_lin` con `LineaUUID`, `PresupuestoUUID`, `Descripcion`, `Uds`, `Precio`, `TotalLinea` y los cinco de administración. Fíjate en que `presupuesto_uuid` se llama `PresupuestoUUID`, igual que la clave de la cabecera: así, en 2.3, la relación se lee sola.
    - **Comprueba:** activa sin errores.

3. **Todas las demás.**
    - **Dónde:** igual, en `ZGOR_CDS`, una por fila, con la descripción de su tabla.
    - **Qué contienen:** una vista por tabla con este reparto de nombres:

    | Vista | Tabla | Alias que no son evidentes |
    |---|---|---|
    | `ZI_GorTrabajador` | `zgor_trab` | `TrabajadorUUID`, `TrabajadorId`, `CosteHoraEstandar` |
    | `ZI_GorFalta` | `zgor_falta` | `FaltaUUID`, `TrabajadorUUID`, `FechaInicio`, `FechaFin`, `Dias` |
    | `ZI_GorProveedor` | `zgor_prov` | `ProveedorUUID`, `ProveedorId`, `NumDocumento` |
    | `ZI_GorEspecialista` | `zgor_esp` | `EspecialistaUUID`, `EspecialistaId`, `ComunicacionParte` |
    | `ZI_GorPresupuesto` | `zgor_presu` | `PresupuestoUUID`, `PresupuestoId`, `ClienteUUID`, `ObraUUID`, `NombreCliente`, `BaseImponible`, `CuotaIva` |
    | `ZI_GorPresuProv` | `zgor_presu_pv` | `PresuProvUUID`, `PresupuestoUUID`, `ProveedorUUID` |
    | `ZI_GorPresuEsp` | `zgor_presu_es` | `PresuEspUUID`, `PresupuestoUUID`, `EspecialistaUUID` |
    | `ZI_GorObra` | `zgor_obra` | `ObraUUID`, `ObraId`, `ClienteUUID` |
    | `ZI_GorGasto` | `zgor_gasto` | `GastoUUID`, `ObraUUID`, `GastoId`, `PresupuestoUUID`, `DireccionObra`, `InicioObra`, `FinObra`, `SolicitudObra`, `GestionLicencia`, `PagoIcio` |
    | `ZI_GorIngreso` | `zgor_ing` | `IngresoUUID`, `IngresoId`, `ObraUUID`, `ClienteUUID`, `NombreObra`, `NumDocumento` |
    | `ZI_GorParteTrabajo` | `zgor_pt` | `ParteUUID`, `ObraUUID`, `HorasTotales`, `CosteTotal` |
    | `ZI_GorParteTrabLin` | `zgor_pt_lin` | `LineaUUID`, `ParteUUID`, `TrabajadorUUID`, `CosteHora`, `CosteSubtotal` |
    | `ZI_GorParteEsp` | `zgor_pe` | `ParteUUID`, `ObraUUID`, `EspecialistaUUID`, `EstadoPago` |
    | `ZI_GorParteProv` | `zgor_pp` | `ParteUUID`, `ObraUUID`, `ProveedorUUID`, `EstadoPago` |

    El resto de columnas se traduce sin sorpresas: `fecha` → `Fecha`, `descripcion` → `Descripcion`, `importe` → `Importe`… Todas llevan los cinco campos de administración con sus `@Semantics`.
    - **Comprueba:** activa todas a la vez (clic derecho en `ZGOR_CDS` → *Activate*) sin errores.

4. **Una vista con condición.** Crea una vista auxiliar de prueba, `ZI_GorClienteMadrid`, sobre `zgor_cli`, con `where cod_postal like '28%'` (se escribe después de la lista de campos, tras la llave de cierre). Léela desde `ZCL_GOR_SQL_DEMO`: deben salir los clientes de Madrid de 1.5. Después **bórrala** (clic derecho → *Delete*): era solo para practicar y no forma parte del ERP.
5. **Investiga.** Abre `ZI_GorCliente`, pon el cursor sobre `zgor_cli` y pulsa **F2**. Después pulsa **F3**. ¿Qué hace cada tecla? Anótalo: las usarás constantemente para navegar entre vistas, tablas y clases.

---

**Siguiente:** [2.3. Associations y composiciones](./2_3_associations.md)
