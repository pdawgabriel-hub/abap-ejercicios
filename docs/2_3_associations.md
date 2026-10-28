# 2.3. Associations y composiciones

Las vistas de 2.2 están sueltas: en el taller, `ZI_TlOrden` tiene un `TitularUUID`, pero no sabe que ese UUID es un titular. En esta unidad vemos cómo se declaran las relaciones (los `Many2one`, `One2many` y `Many2many` de Odoo) y tú declararás **todas las del ERP**. Al terminar, tu modelo CDS tendrá la forma definitiva de los objetos de negocio del Bloque 3: diez **raíces**, cada una con sus **hijos**.

## Association: una relación navegable

Una *association* declara una relación entre dos vistas. No trae los datos hasta que alguien la usa, como la carga perezosa de un *recordset* de Odoo.

```cds
define view entity ZI_TlOrden
  as select from ztl_orden
  // Relacion con el titular: como mucho uno [0..1].
  // $projection.X es el campo X de ESTA vista; _Titular.X, el de la otra
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
      _Titular        // exponerla: asi otras vistas y el Data Preview pueden navegar
}
```

- **`[0..1]`** es la cardinalidad: una orden tiene como mucho un titular. `[1]` sería «exactamente uno» y `[0..*]`, «muchos».
- **`$projection.TitularUUID`** se refiere al campo `TitularUUID` **de esta vista** (por su alias); `_Titular.TitularUUID`, al de la vista destino.
- Las associations empiezan por guion bajo y se **exponen** al final de la lista de campos. Si no se exponen, solo sirven dentro de la vista.

Con la association expuesta, el Data Preview permite navegar: en una fila de `ZI_TlOrden`, clic derecho → *Follow Association* → `_Titular`. Y una vista puede leer a través de ella con una **expresión de ruta**: `_Titular.RazonSocial as TitularNombre`.

Desde ABAP SQL se recorre igual, pero la ruta empieza por una barra invertida y el campo se separa con un guion, como en una estructura:

```abap
" Cada orden con la razon social de su titular, sin escribir ningun join
SELECT FROM zi_tlorden
  FIELDS OrdenRef,
         \_Titular-RazonSocial AS Titular   " ruta: orden -> titular -> campo
  INTO TABLE @DATA(lt_ordenes).
```

La ruta se convierte en un *left outer join*: una orden sin titular sale igualmente, con `Titular` vacío. Solo funciona con associations **expuestas**.

## Composition: hijos que pertenecen al padre

Las partidas de un presupuesto no existen sin él: si se borra el presupuesto, se borran sus partidas. Es el `ondelete='cascade'` de Odoo. En CDS se declara con una **composición**, y tiene dos lados:

```cds
// root: es la raiz de un objeto de negocio (el presupuesto con sus partidas)
define root view entity ZI_TlPresupuesto
  as select from ztl_prs
  // Composicion: las partidas son hijas; no hace falta "on", lo dice el hijo
  composition [0..*] of ZI_TlPartida as _Partidas
  // Associations normales a otras raices: se relacionan, pero no le pertenecen
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

```cds
// Sin root: es hija, solo existe dentro del presupuesto
define view entity ZI_TlPartida
  as select from ztl_prs_par
  // El otro lado de la composicion: el hijo apunta a su padre
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

```cds
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mecanicos de cada orden'
define view entity ZI_TlOrdenMecanico
  // distinct: cada pareja orden-mecanico una sola vez, aunque haya muchos tramos
  as select distinct from ztl_jor_tra as Tramo
    // el tramo no sabe su orden: se une con su jornada, que si la sabe
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
  association [1] to ZI_TlMecanico as _Mecanico
    on $projection.MecanicoUUID = _Mecanico.MecanicoUUID
{
  // La clave son las dos columnas juntas
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

```cds
define view entity ZI_TlTitular
  as select from ztl_tit
  // Vista liberada de SAP: se usa igual que una propia
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

```cds
      // Ruta: del titular a su pais y de ahi a su texto, filtrado por el idioma de la sesion
      _Pais._Text[1: Language = $session.system_language].CountryName as PaisNombre
```

El filtro entre corchetes elige la fila del idioma de la sesión; `1:` le dice a CDS que, con ese filtro, sale una sola fila. Pon este campo en la **proyección** (Bloque 4), no en la vista interface, por el mismo motivo que el nombre del titular en la orden: es un dato de otro objeto.

> Comprueba con **F2** sobre `I_Country` el nombre exacto de su association de textos y de sus campos en tu sistema. Si no tiene `_Text`, busca la vista `I_CountryText` y relaciónala tú.

## Preparación del entorno de trabajo

Se modifican tus vistas de 2.2 y se crean tres nuevas en `ZGOR_CDS`. Al terminar, tu modelo tiene esta forma:

```text
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

1. **Presupuesto con líneas.**
    - **Dónde:** `ZI_GorPresupuesto` y `ZI_GorPresuLin`, en `ZGOR_CDS` (las dos de 2.2).
    - **Qué cambia:** `ZI_GorPresupuesto` pasa a `define root view entity`, con la composición `_Lineas` (`[0..*] of ZI_GorPresuLin`) y las associations `_Cliente` (`[0..1]` a `ZI_GorCliente`) y `_Obra` (`[0..1]` a `ZI_GorObra`). `ZI_GorPresuLin` recibe `association to parent ZI_GorPresupuesto as _Presupuesto`. Expón las associations al final de cada lista de campos y comenta cada una, como en el taller.
    - **Comprueba:** abre las dos y actívalas juntas (**Ctrl+Shift+F3**): por separado, cada una se queja de que la otra no la reconoce. Deben quedar sin errores en *Problems*.

2. **Proveedores y especialistas del presupuesto.**
    - **Dónde:** `ZI_GorPresupuesto`, `ZI_GorPresuProv` y `ZI_GorPresuEsp`.
    - **Qué cambia:** la raíz recibe las composiciones `_Proveedores` (a `ZI_GorPresuProv`) y `_Especialistas` (a `ZI_GorPresuEsp`). Cada hijo, su `association to parent ZI_GorPresupuesto as _Presupuesto` y una association `[1]` a su recurso: `_Proveedor` a `ZI_GorProveedor` o `_Especialista` a `ZI_GorEspecialista`.
    - **Comprueba:** activa las tres juntas sin errores.

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

4. **Participantes.** Las tres vistas de quién participa en cada obra (§11.2 *Otros*).
    - **Dónde:** tres *Data Definitions* nuevas en `ZGOR_CDS`, con la plantilla *Define View Entity*.
    - **Qué contienen:** cada una, con `select distinct`, dos claves (`ObraUUID` y el UUID del recurso) y una association `[1]` a la vista del recurso, como `ZI_TlOrdenMecanico`:

        | Vista | Descripción | Sale de | Claves | Association |
        |---|---|---|---|---|
        | `ZI_GorObraTrab` | `Trabajadores de cada obra` | Las líneas de los partes de trabajo, con `inner join` a su parte (que es quien sabe la obra) | `ObraUUID`, `TrabajadorUUID` | `_Trabajador` a `ZI_GorTrabajador` |
        | `ZI_GorObraProv` | `Proveedores de cada obra` | `zgor_pp` | `ObraUUID`, `ProveedorUUID` | `_Proveedor` a `ZI_GorProveedor` |
        | `ZI_GorObraEsp` | `Especialistas de cada obra` | `zgor_pe` | `ObraUUID`, `EspecialistaUUID` | `_Especialista` a `ZI_GorEspecialista` |

    - **Comprueba:** activa sin errores. Todavía no hay partes, así que estarán vacías: las rellenarás en 2.5.

5. **Navega desde código.** Una association expuesta también se recorre desde ABAP SQL, con una **expresión de ruta** escrita con `\`.
    - **Dónde:** `ZCL_GOR_SQL_DEMO`, un bloque nuevo al final de `main` con el comentario `" 2.3 Navegar por associations`.
    - **Qué hace:** dos lecturas:
        - `SELECT FROM zi_gorobra FIELDS ObraId, \_Cliente-Nombre AS Cliente WHERE ObraId = 'OBR0001' INTO TABLE @DATA(obra).`
        - El número de obras de cada cliente, leyendo desde el cliente: `SELECT FROM zi_gorcliente FIELDS Nombre, COUNT( \_Obras-ObraUUID ) AS Obras GROUP BY Nombre INTO TABLE @DATA(obras_cliente).`

        Escribe las dos con `out->write( )`, y comenta encima de cada `SELECT` qué association recorre y en qué dirección.
    - **Comprueba:** la primera escribe `OBR0001` con `Juan`; la segunda, Juan con 2, Ana con 1 y Luis con 0 (los datos de 1.5): la ruta se une como *left outer join*, así que un cliente sin obras también sale. Si sale un error de sintaxis en la ruta, comprueba que la association está **expuesta** en la vista.

6. **Una ruta dentro de la vista.**
    - **Dónde:** `ZI_GorObra`.
    - **Qué cambia:** añade, antes de las associations, el campo `_Cliente.Nombre as ClienteNombre` con un comentario que diga que es temporal.
    - **Comprueba:** en `ZCL_GOR_SQL_DEMO`, lee `ObraId, ClienteNombre` de `zi_gorobra`: sale el nombre sin escribir la ruta en el `SELECT`. Después **quita el campo** y la lectura: los datos de otra raíz se mostrarán en la proyección (Bloque 4), no en la interface, para que el objeto de negocio solo contenga sus propios campos.

7. **El país del cliente.** No está en el informe: es una ampliación, como lo sería en un proyecto real que usa datos estándar de SAP.
    - **Dónde:** la tabla `zgor_cli` y la vista `ZI_GorCliente`.
    - **Qué cambia:** en `zgor_cli`, la columna `pais : land1;` (antes de los campos de administración). En `ZI_GorCliente`, el campo `pais as Pais` y la association `_Pais` (`[0..1]` a `I_Country`, `on $projection.Pais = _Pais.Country`), expuesta.
    - **Comprueba:** en `ZCL_GOR_SQL_DEMO`, pon `ES` a Juan con un `UPDATE zgor_cli SET pais = 'ES' WHERE cliente_id = 'CLI0001'.` y lee `Nombre, Pais, \_Pais\_Text[ Language = @sy-langu ]-CountryName` de `zi_gorcliente`. Juan debe salir con `España` (o `Spain`, según el idioma de tu sesión); los demás, sin país. Si el editor avisa de que `_Text` puede devolver varias filas, es un aviso, no un error: el filtro por idioma deja una.

8. **Investiga.** Cambia temporalmente la cardinalidad de `_Gasto` a `[0..*]` y activa. ¿Da error? ¿Qué diferencia habría para el usuario? Vuelve a `[0..1]` y anota en `diseno.md` qué regla de §11.4 garantiza esa cardinalidad.

---

**Siguiente:** [2.4. Campos calculados y Data Preview](./2_4_calculados.md)
