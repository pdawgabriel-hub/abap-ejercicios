# 4.3. Metadata Extensions y la interfaz

Fiori Elements no se programa: se **anota**. Qué columnas tiene la lista, qué filtros, qué secciones la página de detalle, qué botones… todo se declara con anotaciones `@UI` sobre la proyección. Para no mezclarlas con el modelo, van en un fichero aparte: la **metadata extension**. En esta unidad vemos las de la orden del taller, y tú harás las de tu ERP, reproduciendo las vistas de Odoo de §4 del informe: listas con sus columnas, formularios con pestañas, la franja de KPI de la obra y el semáforo de salud.

## Qué controla cada anotación

| Anotación | Efecto | En Odoo |
|---|---|---|
| `@UI.headerInfo` | Título de la página de detalle y nombre de la entidad | `display_name` y título del formulario |
| `@UI.lineItem` | Columnas de la lista | Vista `list` |
| `@UI.selectionField` | Filtros de la barra superior | Vista `search` |
| `@UI.facet` | Secciones (pestañas) de la página de detalle | `<notebook>` y `<page>` |
| `@UI.fieldGroup` | Campos de una sección | `<group>` |
| `@UI.identification` | Campos y botones de la sección principal | Cabecera del formulario |
| `@UI.dataPoint` | Un valor destacado, con su color | Tarjetas KPI |
| `@UI.presentationVariant` | Orden por defecto de una lista | `_order` / `default_order` |
| `@UI.hidden` | Oculta un campo | `invisible="1"` |

## La metadata extension de la orden

```cds
@Metadata.layer: #CORE                   // capa de las anotaciones (la nuestra, la base)
// Como se llama un registro y que sale de titulo en su pagina
@UI.headerInfo: { typeName: 'Orden de reparacion', typeNamePlural: 'Ordenes de reparacion',
                  title: { value: 'OrdenRef' }, description: { value: 'Matricula' } }
annotate entity ZC_TlOrden with
{
  // Las secciones de la pagina de detalle: cabecera y pestanas
  @UI.facet: [
    // En la cabecera, el semaforo del resumen
    { id: 'Semaforo', purpose: #HEADER, type: #DATAPOINT_REFERENCE,
      targetElement: '_Resumen', targetQualifier: 'Semaforo', position: 10 },
    // Pestana con los campos marcados con @UI.identification
    { id: 'Datos', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE,
      label: 'Datos de la orden', position: 10 },
    // Pestana con el grupo de campos 'Importes' del resumen
    { id: 'Resumen', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE,
      targetElement: '_Resumen', targetQualifier: 'Importes', label: 'Hoja de costes', position: 20 },
    // Pestana con la lista de fotos
    { id: 'Fotos', purpose: #STANDARD, type: #LINEITEM_REFERENCE,
      targetElement: '_Fotos', label: 'Fotos', position: 30 }
  ]

  @UI.hidden: true                        // el UUID no se ensena nunca
  OrdenUUID;

  @UI.lineItem: [ { position: 10, label: 'Orden' } ]        // columna 1 de la lista
  @UI.identification: [ { position: 10, label: 'Orden' } ]  // campo 1 de la pestana Datos
  @UI.selectionField: [ { position: 10 } ]                  // filtro 1 sobre la lista
  OrdenRef;

  @UI.lineItem: [ { position: 20 } ]
  @UI.identification: [ { position: 20 } ]
  @UI.selectionField: [ { position: 20 } ]
  Matricula;

  @UI.lineItem: [ { position: 30, label: 'Titular' } ]
  @UI.identification: [ { position: 30, label: 'Titular' } ]
  @UI.selectionField: [ { position: 30 } ]
  @UI.textArrangement: #TEXT_ONLY         // solo la razon social, sin el UUID
  TitularUUID;

  @UI.identification: [ { position: 40 } ]
  @UI.multiLineText: true                 // caja de texto de varias lineas
  Averia;
}
```

Y la del resumen, que es otra entidad (las anotaciones de una entidad van en **su** metadata extension, aunque se muestren en la página de otra):

```cds
@Metadata.layer: #CORE
annotate entity ZI_TlOrdenResumen with
{
  // Grupo 'Importes': los campos que pinta la pestana Hoja de costes, en este orden
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 10 } ]
  Importe;
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 20 } ]
  Costes;
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 30 } ]
  Abonado;
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 40 } ]
  Rendimiento;
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 50 } ]
  SaldoPendiente;

  // Valor destacado para la cabecera, con su color
  @UI.dataPoint: { qualifier: 'Semaforo', title: 'Semaforo', criticality: 'SemaforoCriticality' }
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 60, criticality: 'SemaforoCriticality' } ]
  Semaforo;

  @UI.hidden: true                        // solo sirve para el color
  SemaforoCriticality;
}
```

Para que `ZI_TlOrdenResumen` admita una metadata extension, la vista necesita `@Metadata.allowExtensions: true` (añádelo en 2.4 si no lo tiene).

- **`purpose: #HEADER`** pone la sección en la cabecera de la página, sobre las pestañas. Ahí van los valores destacados (`#DATAPOINT_REFERENCE`).
- **`targetElement`** hace que una sección muestre datos de una association: `_Resumen` para un grupo de campos, `_Fotos` para una lista (`#LINEITEM_REFERENCE`), que usará los `@UI.lineItem` de la metadata extension de las fotos.
- **`criticality`** apunta al campo que dice el color: 1 rojo, 2 ámbar, 3 verde. Es el `SemaforoCriticality` de 2.4.
- **`@UI.textArrangement: #TEXT_ONLY`** muestra solo el texto del UUID (la razón social), no el UUID.

## Botones de acciones

Una acción aparece como botón si se anota en un `@UI.lineItem` (en la barra de la lista) o en un `@UI.identification` (en la página de detalle). Así se ponen en el presupuesto del taller:

```cds
  // En la lista: la columna y, ademas, un boton en la barra
  @UI.lineItem: [ { position: 10, label: 'Presupuesto' },
                  { type: #FOR_ACTION, dataAction: 'aceptar', label: 'Aceptar' } ]
  // En la pagina de detalle: los tres botones
  @UI.identification: [ { position: 10, label: 'Presupuesto' },
                        { type: #FOR_ACTION, dataAction: 'aceptar', label: 'Aceptar' },
                        { type: #FOR_ACTION, dataAction: 'volverABorrador', label: 'Volver a borrador' },
                        { type: #FOR_ACTION, dataAction: 'vincularAOrden', label: 'Vincular a orden' } ]
  PresupuestoRef;
```

El botón se activa o no según el *feature control* de 3.5. `vincularAOrden` tiene parámetro, así que Fiori abre un pequeño diálogo para pedir la orden.

## Listas ordenadas

Las notas, las más nuevas primero. Va en la metadata extension de la nota, **antes** de `annotate entity`:

```cds
@Metadata.layer: #CORE
// Orden de la lista al abrirla: la nota mas nueva primero
@UI.presentationVariant: [ { sortOrder: [ { by: 'CreatedAt', direction: #DESC } ] } ]
annotate entity ZC_TlPresuNota with
{
  @UI.lineItem: [ { position: 10 } ]
  Comentario;
  @UI.lineItem: [ { position: 20, label: 'Autor' } ]
  CreatedBy;
  @UI.lineItem: [ { position: 30, label: 'Fecha' } ]
  CreatedAt;
}
```

`@UI.presentationVariant` va **fuera** de las llaves porque se refiere a la entidad entera, no a un campo: dice cómo se ordena la lista cuando se abre. Dentro, cada campo lleva su `@UI.lineItem` con la posición de la columna y, si hace falta, una etiqueta distinta de la de la vista. El resultado es una tabla de notas con tres columnas (texto, autor y fecha), con la más reciente arriba.

## Crear y ver

Clic derecho en la proyección → **New Metadata Extension**, con el mismo nombre que la vista. Escribe las anotaciones, activa y **recarga la vista previa** del binding (a veces hace falta vaciar la caché del navegador con **Ctrl+F5**).

## Preparación del entorno de trabajo

Una metadata extension por proyección, en `ZGOR_SRV`, más las de las vistas de cálculo que se muestren en otra página (`ZI_GorObraFinanzas`, con `@Metadata.allowExtensions: true`).

## Ejercicios

Todas las metadata extensions van en `ZGOR_SRV`: clic derecho en la proyección → **New Metadata Extension**, con el mismo nombre que la vista (`ZC_GorObra`). Para que la vista las use, la proyección necesita `@Metadata.allowExtensions: true`. Después de cada una, actívala y recarga la vista previa del binding (**F5** en el navegador).

1. **La obra** (§4 del informe, `obras_views.xml`).
    - **Dónde:** las metadata extensions de `ZC_GorObra` y de `ZI_GorObraFinanzas` (como la del resumen del taller; la vista necesita `@Metadata.allowExtensions: true`).
    - **Qué contienen:**
        - `@UI.headerInfo` con `typeName: 'Obra'`, `typeNamePlural: 'Obras'` y el código como título;
        - lista (`@UI.lineItem`): código, descripción, cliente, total, pendiente de cobro y salud (con `criticality: 'SaludCriticality'`);
        - filtros (`@UI.selectionField`): código, cliente y salud;
        - cabecera (`@UI.dataPoint` + `@UI.facet` de tipo `#DATAPOINT_REFERENCE`): las 5 tarjetas KPI de Odoo (total, gastos, beneficio de caja, pendiente de cobro y margen proyectado) y la salud con su color;
        - pestañas (`@UI.facet` de tipo `#LINEITEM_REFERENCE` o `#IDENTIFICATION_REFERENCE`): Datos (descripción y cliente), Presupuestos, Ingresos, Partes de trabajo, Partes de especialista, Partes de proveedor, Trabajadores (los participantes), Seguimiento de gastos (la ficha), Observaciones, Incidencias y Archivos.
    - **Comprueba:** en la vista previa de `Obra`, **Go** muestra las 4 obras con sus 6 columnas; `OBR0002` sale con la salud en rojo; al abrir `OBR0001` se ven las 5 tarjetas (1210, 670, 540, 0, 540) y las 11 pestañas.

2. **El presupuesto** (`presupuestos_views.xml`).
    - **Dónde:** las de `ZC_GorPresupuesto` y sus hijos.
    - **Qué contienen:** lista con código, cliente, fecha, total y estado; filtros por cliente, estado y año. Página con los datos del cliente copiados (solo lectura), las líneas como lista, y los botones *Aprobar*, *Desaprobar* y *Vincular a obra* (`@UI.lineItem` e `@UI.identification` con `type: #FOR_ACTION`). Pestañas de proveedores, especialistas, observaciones, incidencias y archivos.
    - **Comprueba:** en la vista previa de `Presupuesto`, abre `PREP0005`: el botón *Aprobar* está activo y *Desaprobar* no (el *feature control* de 3.5). Pulsa *Aprobar*: cambian los dos.

3. **El resto.** Las demás, siguiendo §4 del informe. Lo mínimo en cada una: `@UI.headerInfo` con el código como título; lista con las columnas que muestra Odoo; filtros con sus agrupaciones más útiles (estado, obra, cliente, año); bitácoras ordenadas de la más nueva a la más antigua (`@UI.presentationVariant`, como las notas del taller); y el botón *Marcar como pagado* en los partes externos.

4. **El paso 10 de §12.7.** En la vista previa de `Cliente`, escribe `Juan Pérez` en la caja de búsqueda: debe encontrar a Juan aunque nombre y apellidos estén en columnas distintas. Si tu sistema no combina así las palabras, añade `@Search.defaultSearchElement: true` a `NombreCompleto` (2.4) en `ZC_GorCliente` y vuelve a probar. Anota en `diseno.md` qué has tenido que hacer.

5. **Investiga.** Pon `@UI.hidden: true` en un campo obligatorio de la obra y crea una obra desde la app. ¿Qué pasa al guardar? Quítalo y anota por qué un campo obligatorio no se debe ocultar.

---

**Siguiente:** [4.4. Comprobar y depurar](./4_4_depurar.md)
