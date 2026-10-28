# 2.3. Associations y composiciones

Las vistas de 2.2 están sueltas: en el taller, `ZI_TlOrden` tiene un `TitularUUID`, pero no sabe que ese UUID es un titular. En esta unidad vemos cómo se declaran las relaciones (los `Many2one`, `One2many` y `Many2many` de Odoo) y tú declararás **todas las del ERP**. Al terminar, tu modelo CDS tendrá la forma definitiva de los objetos de negocio del Bloque 3: diez **raíces**, cada una con sus **hijos**.

## Association: una relación navegable

Una *association* declara una relación entre dos vistas. No trae los datos hasta que alguien la usa, como la carga perezosa de un *recordset* de Odoo.

```sql
define view entity ZI_TlOrden
  as select from ztl_orden
  association [0..1] to ZI_TlTitular as _Titular
    on $projection.TitularUUID = _Titular.TitularUUID
{
  key orden_uuid   as OrdenUUID,
      orden_ref    as OrdenRef,
      matricula    as Matricula,
      averia       as Averia,
      titular_uuid as TitularUUID,
      ...
      /* Associations */
      _Titular
}
```

- **`[0..1]`** es la cardinalidad: una orden tiene como mucho un titular. `[1]` sería «exactamente uno» y `[0..*]`, «muchos».
- **`$projection.TitularUUID`** se refiere al campo `TitularUUID` **de esta vista** (por su alias); `_Titular.TitularUUID`, al de la vista destino.
- Las associations empiezan por guion bajo y se **exponen** al final de la lista de campos. Si no se exponen, solo sirven dentro de la vista.

Con la association expuesta, el Data Preview permite navegar: en una fila de `ZI_TlOrden`, clic derecho → *Follow Association* → `_Titular`. Y una vista puede leer a través de ella con una **expresión de ruta**: `_Titular.RazonSocial as TitularNombre`.

## Composition: hijos que pertenecen al padre

Las partidas de un presupuesto no existen sin él: si se borra el presupuesto, se borran sus partidas. Es el `ondelete='cascade'` de Odoo. En CDS se declara con una **composición**, y tiene dos lados:

```sql
define root view entity ZI_TlPresupuesto
  as select from ztl_prs
  composition [0..*] of ZI_TlPartida as _Partidas
  association [0..1] to ZI_TlTitular as _Titular on $projection.TitularUUID = _Titular.TitularUUID
  association [0..1] to ZI_TlOrden   as _Orden   on $projection.OrdenUUID   = _Orden.OrdenUUID
{
  key presupuesto_uuid as PresupuestoUUID,
      ...
      _Partidas,
      _Titular,
      _Orden
}
```

```sql
define view entity ZI_TlPartida
  as select from ztl_prs_par
  association to parent ZI_TlPresupuesto as _Presupuesto
    on $projection.PresupuestoUUID = _Presupuesto.PresupuestoUUID
{
  key partida_uuid     as PartidaUUID,
      presupuesto_uuid as PresupuestoUUID,
      ...
      _Presupuesto
}
```

- La raíz se declara con **`define root view entity`**: es el punto de entrada del objeto de negocio. En RAP, todo lo que se crea, bloquea o borra se hace a través de la raíz.
- El padre dice `composition [0..*] of` el hijo; el hijo dice `association to parent` el padre. Las dos partes son obligatorias.
- **Activa las dos vistas juntas.** Cada una menciona a la otra, así que por separado ninguna activa. Selecciona las dos en el *Project Explorer* y pulsa **Ctrl+Shift+F3** (*Activate All*), o abre ambas y actívalas desde la ventana de activación.

## El mapa de relaciones

| En Odoo | En CDS | Ejemplo |
|---|---|---|
| `Many2one` entre entidades independientes | `association [0..1] to` | Orden → Titular, Abono → Orden |
| `One2many` con `ondelete='cascade'` (el hijo no tiene sentido solo) | `composition [0..*] of` + `association to parent` | Presupuesto → Partidas, Jornada → Tramos, Mecánico → Ausencias |
| Relación 1:1 que nace y muere con el padre | `composition [0..1] of` | Orden → Hoja de costes |
| `One2many` entre entidades independientes | `association [0..*] to`, solo de lectura | Orden → sus Presupuestos, sus Abonos, sus Jornadas |
| `Many2many` informativo | Hijo de composición con los dos UUID | Presupuesto → Distribuidores previstos |
| `Many2many` calculado | Vista con `select distinct` | Orden → Mecánicos que han trabajado en ella |

La **hoja de costes como hija `[0..1]` de la orden** es una decisión de diseño importante: con una composición `[0..1]`, que la hoja se borre con su orden y que nunca haya dos los garantiza el propio modelo. Solo su creación necesitará una *determination* (3.3). Busca en §3.7 del informe cuánto código necesitaba Odoo para conseguir lo mismo con la ficha de gastos.

## Quién ha trabajado en cada orden

Quién ha trabajado en una orden no se guarda en ningún sitio: se saca de los tramos de sus jornadas con una vista.

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos de cada orden'
define view entity ZI_TlOrdenMecanico
  as select distinct from ztl_jor_tra as Tramo
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
  association [1] to ZI_TlMecanico as _Mecanico
    on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  key Jornada.orden_uuid  as OrdenUUID,
  key Tramo.mecanico_uuid as MecanicoUUID,
      _Mecanico
}
```

`select distinct` quita las filas repetidas: un mecánico con diez jornadas en la misma orden sale una vez. Las dos columnas son la clave de la vista. No puede quedarse desactualizada porque no hay nada que actualizar.

## Relaciones con lo estándar: vistas liberadas de SAP

Tus vistas no solo se relacionan entre sí: también pueden apuntar a las **vistas liberadas** de SAP. En ABAP Cloud no se pueden leer las tablas de SAP, pero sí las vistas CDS que SAP ha marcado como liberadas para usarlas (*released*, contrato C1). Son las mismas en cualquier sistema SAP moderno, y es lo primero que harás en un proyecto de empresa: apoyarte en ellas en vez de crear tus propias tablas de países, monedas o unidades.

En el trial hay pocas, porque es un sistema vacío, pero las básicas sí están: `I_Country` (países), `I_Currency` (monedas), `I_UnitOfMeasure` (unidades), `I_Language` (idiomas)… Para buscarlas: **Ctrl+Shift+A**, escribe `I_Country` y, con la vista abierta, mira la pestaña *Properties → API State*: debe decir *Released*.

En el taller, el titular guarda su país como el código de dos letras de SAP (`ES`, `FR`…) en una columna `pais` de tipo `abap.char(3)`, y su vista se relaciona con `I_Country`:

```sql
define view entity ZI_TlTitular
  as select from ztl_tit
  association [0..1] to I_Country as _Pais
    on $projection.Pais = _Pais.Country
{
  key titular_uuid as TitularUUID,
      ...
      pais         as Pais,
      ...
      _Pais
}
```

Y el nombre del país, en el idioma del usuario, se lee a través de la association de textos que trae la propia vista de SAP:

```sql
      _Pais._Text[1: Language = $session.system_language].CountryName as PaisNombre
```

El filtro entre corchetes elige la fila del idioma de la sesión; `1:` le dice a CDS que, con ese filtro, sale una sola fila. Pon este campo en la **proyección** (Bloque 4), no en la vista interface, por el mismo motivo que el nombre del titular en la orden: es un dato de otro objeto.

> Comprueba con **F2** sobre `I_Country` el nombre exacto de su association de textos y de sus campos en tu sistema. Si no tiene `_Text`, busca la vista `I_CountryText` y relaciónala tú.

## Preparación del entorno de trabajo

Se modifican tus vistas de 2.2 y se crean tres nuevas en `ZGOR_CDS`. Al terminar, tu modelo tiene esta forma:

```
ZI_GorCliente (raíz)
ZI_GorTrabajador (raíz) ──composición── ZI_GorFalta
ZI_GorProveedor (raíz)
ZI_GorEspecialista (raíz)
ZI_GorPresupuesto (raíz) ──composición── ZI_GorPresuLin, ZI_GorPresuProv, ZI_GorPresuEsp
ZI_GorObra (raíz) ──composición [0..1]── ZI_GorGasto
ZI_GorIngreso (raíz)
ZI_GorParteTrabajo (raíz) ──composición── ZI_GorParteTrabLin
ZI_GorParteEsp (raíz)
ZI_GorParteProv (raíz)

Solo lectura: ZI_GorObraTrab, ZI_GorObraProv, ZI_GorObraEsp   ← nuevas
```

## Ejercicios

1. **Presupuesto con líneas.** Convierte `ZI_GorPresupuesto` en raíz con la composición `_Lineas` (a `ZI_GorPresuLin`) y las associations `_Cliente` y `_Obra`, y añade a `ZI_GorPresuLin` su `association to parent` llamada `_Presupuesto`. Activa las dos juntas. En el Data Preview de `ZI_GorPresupuesto` comprueba que aparecen las associations (todavía sin datos).
2. **Proveedores y especialistas del presupuesto.** Añade a la raíz las composiciones `_Proveedores` (`ZI_GorPresuProv`) y `_Especialistas` (`ZI_GorPresuEsp`). En cada hijo, el `association to parent` y una association `[1]` a `ZI_GorProveedor` o `ZI_GorEspecialista`.
3. **El resto de relaciones.** Declara estas. Pon `root` en las diez raíces:

    | Vista | Composiciones | Associations |
    |---|---|---|
    | `ZI_GorCliente` | — (en 3.6, sus observaciones) | `_Obras` [0..*] a `ZI_GorObra`, `_Presupuestos` [0..*], `_Ingresos` [0..*] |
    | `ZI_GorTrabajador` | `_Faltas` [0..*] | `_Obras` [0..*] a `ZI_GorObraTrab` |
    | `ZI_GorFalta` | — | `association to parent ZI_GorTrabajador as _Trabajador` |
    | `ZI_GorProveedor` | — | `_Presupuestos` [0..*] a `ZI_GorPresuProv`, `_Obras` [0..*] a `ZI_GorObraProv` |
    | `ZI_GorEspecialista` | — | `_Presupuestos` [0..*] a `ZI_GorPresuEsp`, `_Obras` [0..*] a `ZI_GorObraEsp` |
    | `ZI_GorObra` | `_Gasto` **[0..1]** | `_Cliente` [0..1], `_Presupuestos`, `_Ingresos`, `_PartesTrabajo`, `_PartesEsp`, `_PartesProv` [0..*], `_Trabajadores` [0..*] a `ZI_GorObraTrab` |
    | `ZI_GorGasto` | — | `association to parent ZI_GorObra as _Obra`, `_Presupuesto` [0..1] |
    | `ZI_GorIngreso` | — | `_Obra` [0..1], `_Cliente` [0..1] |
    | `ZI_GorParteTrabajo` | `_Lineas` [0..*] a `ZI_GorParteTrabLin` | `_Obra` [0..1] |
    | `ZI_GorParteTrabLin` | — | `association to parent ZI_GorParteTrabajo as _Parte`, `_Trabajador` [0..1] |
    | `ZI_GorParteEsp` | — | `_Obra` [0..1], `_Especialista` [0..1] |
    | `ZI_GorParteProv` | — | `_Obra` [0..1], `_Proveedor` [0..1] |

    Las associations `[0..*]` hacia otra raíz usan su UUID: por ejemplo, `_Ingresos` de la obra es `on $projection.ObraUUID = _Ingresos.ObraUUID`.

    Muchas vistas se mencionan entre sí (la obra al cliente y el cliente a sus obras), así que actívalas todas a la vez: clic derecho en `ZGOR_CDS` → **Activate** (o **Ctrl+Shift+F3** con todas abiertas). Si queda alguna con error, corrígela y vuelve a activar el grupo.

4. **Participantes.** Crea las tres vistas de quién participa en cada obra (§11.2 *Otros*), con claves `ObraUUID` y el UUID del recurso, y una association `[1]` a su vista:

    | Vista | Sale de | Clave |
    |---|---|---|
    | `ZI_GorObraTrab` | Las líneas de los partes de trabajo, unidas con su parte | `ObraUUID`, `TrabajadorUUID` |
    | `ZI_GorObraProv` | `zgor_pp` | `ObraUUID`, `ProveedorUUID` |
    | `ZI_GorObraEsp` | `zgor_pe` | `ObraUUID`, `EspecialistaUUID` |
5. **Navega.** Con los datos de 1.5, abre el Data Preview de `ZI_GorObra`, elige `OBR0001` y sigue `_Cliente`: debe salir Juan. Desde `ZI_GorCliente`, sigue `_Obras` de Juan: deben salir dos.
6. **Una ruta.** En `ZI_GorObra`, añade un campo `ClienteNombre` que lea el nombre a través de `_Cliente` (antes de las associations) y actívala. Míralo en el Data Preview. Después **quítalo**: los datos de otra raíz se mostrarán en la proyección (Bloque 4), no en la interface, para que el objeto de negocio solo contenga sus propios campos.
7. **El país del cliente.** Añade a `zgor_cli` la columna `pais` (`abap.char(3)`), a `ZI_GorCliente` el campo `Pais` y una association `_Pais` a `I_Country`. En el Data Preview de `ZI_GorCliente`, pon `ES` a uno de tus clientes (con un `UPDATE` desde `ZCL_GOR_SQL_DEMO`) y sigue `_Pais`. No está en el informe: es una ampliación, como lo sería en un proyecto real que usa datos estándar.
8. **Investiga.** Cambia temporalmente la cardinalidad de `_Gasto` a `[0..*]` y activa. ¿Da error? ¿Qué diferencia habría para el usuario? Vuelve a `[0..1]` y anota en `diseno.md` qué regla de §11.4 garantiza esa cardinalidad.

---

**Siguiente:** [2.4. Campos calculados y Data Preview](./2_4_calculados.md)
