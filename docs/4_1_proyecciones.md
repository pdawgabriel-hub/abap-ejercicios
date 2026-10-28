# 4.1. Proyecciones

> **Bloque 4 · Servicios y apps Fiori.** Tu ERP ya funciona por dentro: crea, calcula, valida y guarda, y el escenario de §12.7 pasa como test. Pero de momento solo se usa desde EML. En este bloque le pones **interfaz**: proyecciones, servicios OData y anotaciones para que Fiori Elements genere las pantallas solo. Al final tendrás tres apps con las que repetir a mano el escenario, como lo haría la administrativa de la empresa.

La capa *interface* (`ZI_`) es el modelo completo. Una app no necesita todo: quiere ciertos campos, ciertas búsquedas y ciertos textos. Para eso está la capa de **proyección** (`ZC_`): una vista y una BDEF por encima de cada BO, que eligen qué se expone y cómo. Es lo que en Odoo serían las vistas XML sobre el modelo.

## Dos piezas por objeto de negocio

1. Una **vista de proyección** por entidad: `define root view entity ... as projection on ...` para la raíz, `define view entity ... as projection on ...` para los hijos.
2. Una **BDEF de proyección** por BO: dice qué operaciones del BO de debajo se usan (`use create`, `use action ...`).

## La proyección de la orden

```cds
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes de reparacion'
@Metadata.allowExtensions: true          // las anotaciones de UI, en otro fichero (4.3)
@Search.searchable: true                 // la app tendra caja de busqueda
define root view entity ZC_TlOrden
  provider contract transactional_query  // para una app transaccional
  as projection on ZI_TlOrden            // se apoya en la vista interface
{
  key OrdenUUID,
      @Search.defaultSearchElement: true   // la caja de busqueda mira aqui...
      OrdenRef,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8      // ...y aqui, admitiendo erratas
      Matricula,
      Averia,
      // Mostrar el nombre en lugar del UUID, y una lista para elegirlo
      @ObjectModel.text.element: [ 'TitularNombre' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_TlTitular', element: 'TitularUUID' } } ]
      TitularUUID,
      _Titular.RazonSocial as TitularNombre,   // dato del titular, solo lectura
      LocalLastChangedAt,                      // el etag: obligatorio para RAP

      /* Associations */
      // Los hijos, hacia SUS proyecciones
      _HojaCostes : redirected to composition child ZC_TlHojaCostes,
      _Fotos      : redirected to composition child ZC_TlOrdenFoto,
      _Resumen,                               // solo lectura (2.4)
      _Titular : redirected to ZC_TlTitular   // a la proyeccion, que es la que expone el servicio
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

```bdef
// Proyeccion: elige que partes del comportamiento de debajo usa la app
projection;
strict ( 2 );
use draft;                       // la app trabaja con borradores
use side effects;                // y publica los side effects de 3.3

define behavior for ZC_TlOrden alias Orden
{
  use create;
  use update;
  use delete;

  // Las acciones del borrador, una a una
  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

  use association _HojaCostes { with draft; }      // sin create: la crea la orden
  use association _Fotos { create; with draft; }
}

define behavior for ZC_TlHojaCostes alias HojaCostes
{
  use update;                    // se modifica, pero no se crea ni se borra
  use association _Orden { with draft; }
}

define behavior for ZC_TlOrdenFoto alias Foto
{
  use update;
  use delete;
  use association _Orden { with draft; }
}
```

- `use draft` y las acciones de borrador: la app usa los borradores del BO. `use side effects` publica los *side effects* de la BDEF (3.3) para que Fiori refresque lo que cambian las *determinations*.
- **Solo se usa lo que la app necesita.** La hoja de costes no tiene `use create` (la crea la determination de 3.3) ni `use delete`. Las acciones de negocio también se eligen una a una: en la proyección del presupuesto irían `use action aceptar;`, `use action vincularAOrden;`…
- Lo que la proyección no usa, desde la app no existe, aunque el BO lo permita.

## Orden de activación

Una proyección depende de las de sus hijos y viceversa: actívalas **juntas** (selecciónalas en el *Project Explorer* y **Ctrl+Shift+F3**). Después, la BDEF de proyección. Si activas en otro orden verás errores de objeto inexistente que desaparecen al activar el resto.

> **Código completo del taller:** [ZC_TlOrden](./materiales/taller/src/srv/zc_tlorden.ddls.asddls), [su BDEF de proyección](./materiales/taller/src/srv/zc_tlorden.bdef.asbdef) y las demás en [src/srv/](./materiales/taller/src/srv/). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Las proyecciones de tu ERP van en `ZGOR_SRV`. Necesitas también la proyección de cada vista que vayas a usar como ayuda de búsqueda (clientes, trabajadores, proveedores, especialistas, obras).

## Ejercicios

1. **La obra.**
    - **Dónde:** en `ZGOR_SRV`, clic derecho → **New → Other ABAP Repository Object** → *Data Definition*. Dos vistas: `ZC_GorObra` (descripción `Obra - proyeccion`, plantilla *Define Projection View*, sobre `ZI_GorObra`) y `ZC_GorGasto` (`Ficha de gastos - proyeccion`, sobre `ZI_GorGasto`).
    - **Qué contienen:** como `ZC_TlOrden`:
        - en la obra, `define root view entity ZC_GorObra provider contract transactional_query as projection on ZI_GorObra`, con `@Search.searchable: true`;
        - `@Search.defaultSearchElement: true` en `ObraId` y `Descripcion`;
        - el campo `_Cliente.NombreCompleto as ClienteNombre`, y en `ClienteUUID` las anotaciones `@ObjectModel.text.element: [ 'ClienteNombre' ]` y `@Consumption.valueHelpDefinition` a `ZC_GorCliente`;
        - las associations a `_Finanzas` y `_Trabajadores` expuestas, y `_Gasto : redirected to composition child ZC_GorGasto`;
        - en el gasto, `_Obra : redirected to parent ZC_GorObra`.
    - **La BDEF de proyección:** clic derecho en `ZC_GorObra` → **New Behavior Definition** (tipo *Projection*). Contiene `projection; strict ( 2 ); use draft;` y, en la obra, `use create; use update; use delete;`, las `use action` de borrador y `use association _Gasto { with draft; }`; en el gasto, solo `use update;` (la ficha se modifica pero no se crea ni se borra, §3.7).
    - **Comprueba:** activa todo. En `ZCL_GOR_SQL_DEMO`, `SELECT FROM zc_gorobra FIELDS ObraId, ClienteNombre` devuelve las cuatro obras de 2.5, cada una con el nombre completo de su cliente.

2. **El presupuesto.**
    - **Dónde:** `ZGOR_SRV`: `ZC_GorPresupuesto` y una proyección por hijo (`ZC_GorPresuLin`, `ZC_GorPresuProv`, `ZC_GorPresuEsp`, `ZC_GorPresuObs`, `ZC_GorPresuInc`, `ZC_GorPresuArc`), y su BDEF de proyección.
    - **Qué contienen:** la raíz, como la obra, con el nombre del cliente como texto de `ClienteUUID`; cada hijo con su `redirected to parent`. En la BDEF, además de las operaciones y las `use association`, `use action aprobar;`, `use action desaprobar;` y `use action vincularAObra;`.
    - **Comprueba:** activa todo. `SELECT FROM zc_gorpresupuesto FIELDS PresupuestoId, ClienteNombre, Total` devuelve los seis presupuestos de 2.5.

3. **El resto.** Crea las proyecciones de las otras ocho raíces con sus hijos, y sus BDEF de proyección, con los mismos pasos y este criterio:

    | BO | Buscar por (§4 del informe: *Search*) | Textos de UUID | Acciones |
    |---|---|---|---|
    | Cliente | código, nombre completo, NIF, teléfono | — | — |
    | Trabajador | código, nombre completo, tipo | — | — |
    | Proveedor | código, nombre | — | — |
    | Especialista | código, nombre, tipo | — | — |
    | Ingreso | código, nombre de la obra | obra, cliente | — |
    | Parte de trabajo | descripción | obra; en la línea, trabajador | — |
    | Partes de especialista y de proveedor | descripción, documento | obra, especialista o proveedor | `marcarPagado` |

    **Comprueba:** clic derecho en `ZGOR_SRV` → **Activate**, sin errores.

4. **Una de solo lectura.**
    - **Dónde:** `ZGOR_SRV`, `ZC_GorObraFinanzas` (descripción `Ficha financiera - proyeccion`).
    - **Qué contiene:** `define view entity ZC_GorObraFinanzas as projection on ZI_GorObraFinanzas` con todos sus campos, **sin** `provider contract` ni BDEF: es solo para leer. La usará el servicio financiero.
    - **Comprueba:** `SELECT FROM zc_gorobrafinanzas FIELDS COUNT( * )` da 4.

5. **Investiga.** Quita `use delete;` de tu proyección de la obra y activa. ¿Se puede seguir borrando una obra con EML sobre `ZI_GorObra`? ¿Y sobre `ZC_GorObra`? Vuelve a ponerlo y anota la diferencia en un comentario `//` de la BDEF de proyección.

---

**Siguiente:** [4.2. Service Definition y Service Binding](./4_2_servicio.md)
