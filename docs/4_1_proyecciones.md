# 4.1. Proyecciones

> **Bloque 4 · Servicios y apps Fiori.** Tu ERP ya funciona por dentro: crea, calcula, valida y guarda, y el escenario de §12.7 pasa como test. Pero de momento solo se usa desde EML. En este bloque le pones **interfaz**: proyecciones, servicios OData y anotaciones para que Fiori Elements genere las pantallas solo. Al final tendrás tres apps con las que repetir a mano el escenario, como lo haría la administrativa de la empresa.

La capa *interface* (`ZI_`) es el modelo completo. Una app no necesita todo: quiere ciertos campos, ciertas búsquedas y ciertos textos. Para eso está la capa de **proyección** (`ZC_`): una vista y una BDEF por encima de cada BO, que eligen qué se expone y cómo. Es lo que en Odoo serían las vistas XML sobre el modelo.

## Dos piezas por objeto de negocio

1. Una **vista de proyección** por entidad: `define root view entity ... as projection on ...` para la raíz, `define view entity ... as projection on ...` para los hijos.
2. Una **BDEF de proyección** por BO: dice qué operaciones del BO de debajo se usan (`use create`, `use action ...`).

## La proyección de la orden

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes de reparacion'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_TlOrden
  provider contract transactional_query
  as projection on ZI_TlOrden
{
  key OrdenUUID,
      @Search.defaultSearchElement: true
      OrdenRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Matricula,
      Averia,
      @ObjectModel.text.element: [ 'TitularNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlTitular', element: 'TitularUUID' } } ]
      TitularUUID,
      _Titular.RazonSocial as TitularNombre,
      LocalLastChangedAt,

      /* Associations */
      _HojaCostes : redirected to composition child ZC_TlHojaCostes,
      _Fotos      : redirected to composition child ZC_TlOrdenFoto,
      _Resumen,
      _Titular
}
```

- **`provider contract transactional_query`**: la proyección es para una app transaccional (con su BDEF de proyección).
- **`@Metadata.allowExtensions: true`**: las anotaciones de interfaz irán en un fichero aparte, la *metadata extension* (4.3).
- **Búsqueda**: `@Search.searchable` en la vista y `@Search.defaultSearchElement` en los campos donde busca la caja de búsqueda de Fiori. `@Search.fuzzinessThreshold` admite pequeñas erratas (0.8 es bastante tolerante; 1 es exacto).
- **Textos en lugar de UUID**: nadie quiere ver un UUID. `@ObjectModel.text.element` dice qué campo es el texto del UUID, y `_Titular.RazonSocial as TitularNombre` lo trae a través de la association. Ese campo es de **solo lectura**: pertenece al titular, no a la orden.
- **Ayuda de búsqueda**: `@Consumption.valueHelpDefinition` hace que, al elegir el titular, Fiori abra una lista de `ZC_TlTitular` con buscador.
- **Las composiciones se redirigen** a la proyección del hijo (`redirected to composition child`), y en el hijo, a la del padre (`redirected to parent`).
- **`_Resumen`** es la association de la orden a `ZI_TlOrdenResumen` (2.4). No es una composición: se expone tal cual, y el servicio (4.2) publicará el resumen como entidad de solo lectura.

Los campos de administración no hace falta exponerlos todos, pero sí el *etag* (`LocalLastChangedAt`), que RAP necesita para el control de cambios.

## La BDEF de proyección

```sql
projection;
strict ( 2 );
use draft;

define behavior for ZC_TlOrden alias Orden
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

  use association _HojaCostes { with draft; }
  use association _Fotos { create; with draft; }
}

define behavior for ZC_TlHojaCostes alias HojaCostes
{
  use update;
  use association _Orden { with draft; }
}

define behavior for ZC_TlOrdenFoto alias Foto
{
  use update;
  use delete;
  use association _Orden { with draft; }
}
```

- `use draft` y las acciones de borrador: la app usa los borradores del BO.
- **Solo se usa lo que la app necesita.** La hoja de costes no tiene `use create` (la crea la determination de 3.3) ni `use delete`. Las acciones de negocio también se eligen una a una: en la proyección del presupuesto irían `use action aceptar;`, `use action vincularAOrden;`…
- Lo que la proyección no usa, desde la app no existe, aunque el BO lo permita.

## Orden de activación

Una proyección depende de las de sus hijos y viceversa: actívalas **juntas** (selecciónalas en el *Project Explorer* y **Ctrl+Shift+F3**). Después, la BDEF de proyección. Si activas en otro orden verás errores de objeto inexistente que desaparecen al activar el resto.

## Preparación del entorno de trabajo

Las proyecciones de tu ERP van en `ZGOR_SRV`. Necesitas también la proyección de cada vista que vayas a usar como ayuda de búsqueda (clientes, trabajadores, proveedores, especialistas, obras).

## Ejercicios

1. **La obra.** Crea `ZC_GorObra` (raíz) y `ZC_GorGasto` (hija), con búsqueda por `ObraId` y `Descripcion` y, en la obra, el nombre del cliente como texto de `ClienteUUID` (con su ayuda de búsqueda a `ZC_GorCliente`). Expón las associations de la obra a `ZI_GorObraFinanzas` y a los participantes. Crea su BDEF de proyección: la ficha de gastos se modifica pero no se crea ni se borra (§3.7).
2. **El presupuesto.** Crea `ZC_GorPresupuesto` y las proyecciones de sus hijos (líneas, proveedores, especialistas, observaciones, incidencias y archivos), con el nombre del cliente como texto. En la BDEF de proyección usa `aprobar`, `desaprobar` y `vincularAObra` (la de 3.5).
3. **El resto.** Crea las proyecciones de las otras ocho raíces con sus hijos, con este criterio:

    | BO | Buscar por (§4 del informe: *Search*) | Textos de UUID | Acciones |
    |---|---|---|---|
    | Cliente | código, nombre completo, NIF, teléfono | — | — |
    | Trabajador | código, nombre completo, tipo | — | — |
    | Proveedor | código, nombre | — | — |
    | Especialista | código, nombre, tipo | — | — |
    | Ingreso | código, nombre de la obra | obra, cliente | — |
    | Parte de trabajo | descripción | obra; en la línea, trabajador | — |
    | Partes de especialista y de proveedor | descripción, documento | obra, especialista o proveedor | `marcarPagado` |

4. **Una de solo lectura.** Crea `ZC_GorObraFinanzas` como proyección de `ZI_GorObraFinanzas` (sin `provider contract` ni BDEF: es solo para leer). La usará el servicio financiero.
5. **Investiga.** Quita `use delete;` de tu proyección de la obra y activa. ¿Se puede seguir borrando una obra con EML sobre `ZI_GorObra`? ¿Y sobre `ZC_GorObra`? Vuelve a ponerlo y anota la diferencia.

---

**Siguiente:** [4.2. Service Definition y Service Binding](./4_2_servicio.md)
