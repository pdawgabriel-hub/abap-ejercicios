# 3.1. Behavior Definition managed

> **Bloque 3 · Comportamiento con RAP.** Las vistas del Bloque 2 **leen** datos. Ahora les damos **comportamiento**: crear, modificar y borrar, con los valores por defecto, los cálculos, las validaciones y las acciones de Odoo. Es lo que en `gestion_bd` hacen los `create()`, `@api.onchange`, `@api.constrains` y los botones. Al final del bloque, el escenario de §12.7 completo se ejecutará como test automático contra los objetos de negocio reales, y en el Bloque 4 solo quedará ponerles una interfaz.

En esta unidad vemos cómo se declara qué se puede hacer con cada objeto de negocio, su **Behavior Definition** (BDEF), con el titular y el presupuesto del taller. Tú escribirás las diez del ERP.

## Qué es una Behavior Definition

RAP (*ABAP RESTful Application Programming Model*) organiza la aplicación en **objetos de negocio** (BO): una raíz con sus hijos, como los diez árboles que montaste en [2.3](./2_3_associations.md). La BDEF de cada BO es un fichero declarativo que dice:

- qué **operaciones** admite cada entidad (crear, modificar, borrar, acciones propias);
- qué **campos** son de solo lectura u obligatorios;
- qué **lógica** se ejecuta y cuándo (*determinations*, *validations*), que se programa en una clase ABAP (3.2);
- cómo se guardan los datos (**tablas** y correspondencia de campos).

Hay dos modos. En **managed**, RAP hace él mismo las lecturas y escrituras en las tablas y nosotros solo añadimos la lógica de negocio. En **unmanaged**, todo lo escribe el programador (se usa para envolver código antiguo). Usamos siempre *managed*. Es lo más parecido al ORM de Odoo: declaras el modelo y escribes solo lo particular.

## Borradores (*draft*)

En un formulario de Odoo, los cambios no se guardan hasta pulsar **Guardar**, y **Descartar** los anula. En Fiori eso se consigue con **draft**: mientras se edita, los cambios van a una **tabla de borradores**, gemela de la de datos. Al pulsar *Guardar*, RAP valida el borrador y, si todo está bien, lo pasa a la tabla real. Ventajas:

- Las validaciones se ejecutan **al guardar**, como en Odoo, y no a cada tecla.
- Si se cierra el navegador, el borrador sigue ahí (*Resume*).
- Dos usuarios no pueden editar a la vez el mismo registro: el primero que lo abre lo bloquea.

Todos los BO, del taller y del ERP, serán *draft*. Cada tabla tendrá su gemela con `_d` al final. No hay que escribirlas: las genera Eclipse.

## La BDEF del titular

```bdef
// Cabecera: RAP hace el CRUD (managed); nuestra logica, en esta clase
managed implementation in class zbp_i_tltitular unique;
strict ( 2 );                        // comprobaciones estrictas
with draft;                          // el BO trabaja con borradores

// La entidad: la vista raiz y su nombre corto (alias) para EML
define behavior for ZI_TlTitular alias Titular
persistent table ztl_tit             // donde se guarda
draft table ztl_tit_d                // donde se guardan los borradores
lock master                          // se bloquea a partir de la raiz
total etag LastChangedAt             // detectar cambios de otros usuarios
authorization master ( global )      // permisos por tipo de operacion (6.1)
etag master LocalLastChangedAt
{
  // Operaciones permitidas
  create;
  update;
  delete;

  // RAP genera el UUID al crear; nadie lo puede cambiar
  field ( numbering : managed, readonly ) TitularUUID;
  // Solo los escribe la logica del BO: codigo (3.7) y administracion
  field ( readonly ) TitularRef,
                     CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;
  // Fiori los marca con asterisco (la validation de verdad, en 3.4)
  field ( mandatory ) RazonSocial, Contacto;

  // Las acciones del borrador: editar, guardar, descartar, retomar, preparar
  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  // Campo de la vista (izquierda) = columna de la tabla (derecha)
  mapping for ztl_tit corresponding
  {
    TitularUUID        = titular_uuid;
    TitularRef         = titular_ref;
    RazonSocial        = razon_social;
    DocumentoId        = documento_id;
    Contacto           = contacto;
    Poblacion          = poblacion;
    Cp                 = cp;
    CreatedBy          = created_by;
    CreatedAt          = created_at;
    LastChangedBy      = last_changed_by;
    LastChangedAt      = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }
}
```

**La cabecera:**

- `managed implementation in class zbp_i_tltitular unique`: modo *managed*, y la lógica irá en esa clase.
- `strict ( 2 )`: comprobaciones estrictas del framework. Siempre en desarrollo nuevo.
- `with draft`: el BO usa borradores.

**La entidad:**

- `persistent table` y `draft table`: dónde se guardan los datos y los borradores.
- `lock master`: el bloqueo se hace sobre la raíz (con sus hijos).
- `total etag LastChangedAt` y `etag master LocalLastChangedAt`: los campos con los que RAP detecta si otro usuario ha cambiado el registro desde que lo leíste. Son los campos de administración de 2.2.
- `authorization master ( global )`: los permisos se comprueban por tipo de operación («¿puede este usuario crear titulares?»), como los grupos y el `ir.model.access.csv` de Odoo (§5). De momento lo permitiremos todo; en [6.1](./6_1_seguridad.md), los roles.

**Dentro de las llaves:**

- `create; update; delete;`: las operaciones permitidas.
- `field ( numbering : managed, readonly )`: RAP genera el UUID al crear, y nadie lo puede cambiar.
- `field ( readonly )`: el código visible (lo pondrá una *determination* en 3.7), los campos calculados de la vista, si los hay, y los de administración. La lógica de negocio sí puede escribirlos, porque trabaja en *local mode* (3.2).
- `field ( mandatory )`: Fiori marca el campo como obligatorio. **No basta para impedir** que se guarde vacío. Eso lo hace una *validation* (3.4).
- Las acciones `draft`: editar, activar (guardar), descartar, retomar y preparar (ejecutar las validaciones antes de guardar).
- `mapping for ztl_tit corresponding`: qué campo de la vista corresponde a cada columna. `corresponding` empareja solos los que se llamen igual; aquí, como los alias son *CamelCase*, se escriben todos.

## Los hijos

Así es la BDEF del presupuesto del taller con sus partidas. Las dos entidades van en **el mismo fichero**, porque forman un solo BO:

```bdef
// Un solo BO con dos entidades: el presupuesto (raiz) y sus partidas (hijas)
managed implementation in class zbp_i_tlpresupuesto unique;
strict ( 2 );
with draft;

define behavior for ZI_TlPresupuesto alias Presupuesto
persistent table ztl_prs
draft table ztl_prs_d
lock master
total etag LastChangedAt
authorization master ( global )
etag master LocalLastChangedAt
{
  create;
  update;
  delete;

  field ( numbering : managed, readonly ) PresupuestoUUID;
  field ( readonly ) PresupuestoRef, Neto, Cuota, Importe,
                     CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;
  field ( mandatory ) TitularUUID, Impuesto;

  // Las partidas se crean A TRAVES del presupuesto, tambien en borrador
  association _Partidas { create; with draft; }

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  mapping for ztl_prs corresponding
  {
    PresupuestoUUID = presupuesto_uuid;
    ...
  }
}

// La hija: bloqueo y permisos los decide su presupuesto
define behavior for ZI_TlPartida alias Partida
persistent table ztl_prs_par
draft table ztl_prs_par_d
lock dependent by _Presupuesto
authorization dependent by _Presupuesto
etag master LocalLastChangedAt
{
  // Sin create: una partida solo nace dentro de un presupuesto
  update;
  delete;

  field ( numbering : managed, readonly ) PartidaUUID;
  field ( readonly ) PresupuestoUUID, ImportePartida,
                     CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;

  association _Presupuesto { with draft; }   // camino de vuelta al padre

  mapping for ztl_prs_par corresponding
  {
    PartidaUUID     = partida_uuid;
    ...
  }
}
```

- La raíz permite **crear partidas** a través de la composición: `association _Partidas { create; with draft; }`. Las partidas no tienen `create` propio: solo se crean dentro de un presupuesto, como en la lista editable de un formulario de Odoo.
- El hijo hereda el bloqueo y los permisos de su raíz: `lock dependent by` y `authorization dependent by`.
- `with draft` en las associations: también los hijos tienen borrador mientras se edita la raíz.

## Crear una BDEF

1. Clic derecho en la vista raíz → **New Behavior Definition**. En tu ERP, paquete `ZGOR_BUS`; tipo **Managed**. Eclipse genera un esqueleto con las entidades del BO.
2. Sustituye el contenido por el tuyo y guarda (todavía no actives).
3. Pon el cursor sobre el nombre de la tabla de borradores (`ztl_tit_d` en el taller) y pulsa **Ctrl+1** → *Create draft table*. Eclipse la crea con todos los campos de la vista más un bloque de administración del borrador (`"%admin"`). Activa la tabla.
4. La BDEF seguirá marcando un error: falta su clase de implementación. Se crea en [3.2](./3_2_implementacion.md).

## Preparación del entorno de trabajo

Las BDEF van en `ZGOR_BUS`; las tablas de borradores, en `ZGOR_DDIC`. Al terminar habrá diez BDEF, una por BO, y una tabla `_d` por cada tabla con comportamiento.

## Ejercicios

1. **El cliente.**
    - **Dónde:** en `ZGOR_CDS`, clic derecho en `ZI_GorCliente` → **New Behavior Definition**. Deja el nombre que propone (`ZI_GORCLIENTE`), elige *Implementation Type* **Managed** y el paquete `ZGOR_BUS`.
    - **Qué contiene:** el mismo patrón que la del titular: `managed implementation in class zbp_i_gorcliente unique;`, `strict ( 2 );`, `with draft;` y `define behavior for ZI_GorCliente alias Cliente`, con `persistent table zgor_cli`, `draft table zgor_cli_d`, `lock master`, `total etag LastChangedAt`, `authorization master ( global )` y `etag master LocalLastChangedAt`. Dentro de las llaves:
        - `create; update; delete;`;
        - `field ( numbering : managed, readonly ) ClienteUUID;`;
        - `field ( readonly )` para `ClienteId`, `NombreCompleto` y los cinco de administración;
        - `field ( mandatory )` para `Nombre`, `Direccion` y `Telf` (§11.4);
        - las cinco `draft action` del titular;
        - el `mapping for zgor_cli corresponding` con cada campo de la vista frente a su columna.

        Comenta cada bloque con `//`, como en el taller.
    - **La tabla de borradores:** pon el cursor sobre `zgor_cli_d` y pulsa **Ctrl+1** → *Create draft table*. ADT la genera con todas las columnas de la vista más las de control del borrador. Muévela a `ZGOR_DDIC` si te la propone en otro paquete y actívala.
    - **Comprueba:** guarda (**Ctrl+S**) **sin activar**. En *Problems* solo debe quedar un error: que la clase `zbp_i_gorcliente` no existe. La crearás en 3.2.

2. **El presupuesto.**
    - **Dónde:** igual que el anterior, sobre `ZI_GorPresupuesto`. Al ser raíz con composiciones, ADT añade a la BDEF un `define behavior for` por cada hijo.
    - **Qué contiene:** como la del presupuesto del taller:
        - la raíz, alias `Presupuesto`, con `association _Lineas { create; with draft; }` y lo mismo para `_Proveedores` y `_Especialistas`;
        - tres hijos con `lock dependent by _Presupuesto` y `authorization dependent by _Presupuesto`: `ZI_GorPresuLin` (alias `Linea`), `ZI_GorPresuProv` (`PresuProv`) y `ZI_GorPresuEsp` (`PresuEsp`), cada uno con `update; delete;` y `association _Presupuesto { with draft; }`;
        - solo lectura en la raíz: `PresupuestoId`, `Anio`, `BaseImponible`, `CuotaIva` y `Total`; en la línea, `PresupuestoUUID` y `TotalLinea`;
        - obligatorios en la raíz: `ClienteUUID` e `Iva`.
    - **Las tablas de borradores:** cuatro, `zgor_presu_d`, `zgor_presu_lin_d`, `zgor_presu_pv_d` y `zgor_presu_es_d`, cada una con **Ctrl+1** y en `ZGOR_DDIC` (el nombre de una tabla no puede pasar de 16 caracteres: [B. Nombres](./B_nombres.md)).
    - **Comprueba:** guarda sin activar; la única queja debe ser la clase.

3. **Las demás.** Crea las otras ocho BDEF igual que las anteriores (clic derecho en la vista raíz → **New Behavior Definition**, tipo *Managed*), cada una con su tabla de borradores y su clase `zbp_i_<vista>`:

    | BO (alias de la raíz) | Hijos (alias) | Solo lectura, además de UUID y administración | Obligatorios (§11.4) |
    |---|---|---|---|
    | `ZI_GorTrabajador` (`Trabajador`) | `ZI_GorFalta` (`Falta`) | `TrabajadorId`, `NombreCompleto`; en la falta, `TrabajadorUUID`, `Dias` | Nombre, Apellido, CosteHoraEstandar; en la falta, FechaInicio, FechaFin, Tipo |
    | `ZI_GorProveedor` (`Proveedor`) | — | `ProveedorId`, `Total` | Base, Iva |
    | `ZI_GorEspecialista` (`Especialista`) | — | `EspecialistaId` | Nombre |
    | `ZI_GorObra` (`Obra`) | `ZI_GorGasto` (`Gasto`) | `ObraId`; en el gasto, `ObraUUID`, `GastoId` | — |
    | `ZI_GorIngreso` (`Ingreso`) | — | `IngresoId`, `Anio` | ObraUUID, Importe |
    | `ZI_GorParteTrabajo` (`ParteTrabajo`) | `ZI_GorParteTrabLin` (`Linea`) | `HorasTotales`, `CosteTotal`; en la línea, `ParteUUID`, `CosteSubtotal` | ObraUUID, Descripcion; en la línea, TrabajadorUUID |
    | `ZI_GorParteEsp` (`ParteEsp`) | — | — | ObraUUID, EspecialistaUUID, Importe, EstadoPago |
    | `ZI_GorParteProv` (`ParteProv`) | — | — | ObraUUID, ProveedorUUID, Importe, EstadoPago |

    Dos casos especiales en la obra:
    - El **gasto** nace con la obra y no se borra suelto (§3.7). La raíz no permite crearlo desde fuera: `association _Gasto { internal create; with draft; }` (`internal` significa «solo desde la lógica del propio BO»). La entidad `Gasto` tiene `update;` pero **no** `delete;`. Se borrará con su obra, por la composición.
    - La obra no tiene obligatorio el cliente (§3.5: puede no tenerlo).

4. **Revisa los errores.** Las BDEF no activarán hasta tener su clase (3.2). Abre la pestaña *Problems* y comprueba que la única queja de cada una es la clase que falta: cualquier otro error (un campo mal escrito en el `mapping`, un alias repetido, una tabla de borradores sin activar) corrígelo ahora.

    > Si te aparece el error «*Field X does not exist in draft table*», la tabla de borradores se creó antes de añadir ese campo a la vista. Bórrala y vuelve a crearla con **Ctrl+1**.
5. **Investiga.** En tu BDEF del cliente, quita la línea `field ( mandatory ) ...` y mira qué avisos aparecen. Vuelve a ponerla. Después busca con **F1** sobre `etag master` qué ocurre si dos usuarios editan el mismo cliente sin draft, y anota por qué el draft lo evita.

---

**Siguiente:** [3.2. La clase de implementación](./3_2_implementacion.md)
