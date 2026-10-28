---
title: "4.3. Metadata Extensions y la interfaz"
parent: "4. Servicios y app Fiori"
nav_order: 3
---

# 4.3. Metadata Extensions y la interfaz

{% raw %}
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

```sql
@Metadata.layer: #CORE
@UI.headerInfo: { typeName: 'Orden de reparacion', typeNamePlural: 'Ordenes de reparacion',
                  title: { value: 'OrdenRef' }, description: { value: 'Matricula' } }
annotate entity ZC_TlOrden with
{
  @UI.facet: [
    { id: 'Semaforo', purpose: #HEADER, type: #DATAPOINT_REFERENCE,
      targetElement: '_Resumen', targetQualifier: 'Semaforo', position: 10 },
    { id: 'Datos', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE,
      label: 'Datos de la orden', position: 10 },
    { id: 'Resumen', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE,
      targetElement: '_Resumen', targetQualifier: 'Importes', label: 'Hoja de costes', position: 20 },
    { id: 'Fotos', purpose: #STANDARD, type: #LINEITEM_REFERENCE,
      targetElement: '_Fotos', label: 'Fotos', position: 30 }
  ]

  @UI.hidden: true
  OrdenUUID;

  @UI.lineItem: [ { position: 10, label: 'Orden' } ]
  @UI.identification: [ { position: 10, label: 'Orden' } ]
  @UI.selectionField: [ { position: 10 } ]
  OrdenRef;

  @UI.lineItem: [ { position: 20 } ]
  @UI.identification: [ { position: 20 } ]
  @UI.selectionField: [ { position: 20 } ]
  Matricula;

  @UI.lineItem: [ { position: 30, label: 'Titular' } ]
  @UI.identification: [ { position: 30, label: 'Titular' } ]
  @UI.selectionField: [ { position: 30 } ]
  @UI.textArrangement: #TEXT_ONLY
  TitularUUID;

  @UI.identification: [ { position: 40 } ]
  @UI.multiLineText: true
  Averia;
}
```

Y la del resumen, que es otra entidad (las anotaciones de una entidad van en **su** metadata extension, aunque se muestren en la página de otra):

```sql
@Metadata.layer: #CORE
annotate entity ZI_TlOrdenResumen with
{
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

  @UI.dataPoint: { qualifier: 'Semaforo', title: 'Semaforo', criticality: 'SemaforoCriticality' }
  @UI.fieldGroup: [ { qualifier: 'Importes', position: 60, criticality: 'SemaforoCriticality' } ]
  Semaforo;

  @UI.hidden: true
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

```sql
  @UI.lineItem: [ { position: 10, label: 'Presupuesto' },
                  { type: #FOR_ACTION, dataAction: 'aceptar', label: 'Aceptar' } ]
  @UI.identification: [ { position: 10, label: 'Presupuesto' },
                        { type: #FOR_ACTION, dataAction: 'aceptar', label: 'Aceptar' },
                        { type: #FOR_ACTION, dataAction: 'volverABorrador', label: 'Volver a borrador' },
                        { type: #FOR_ACTION, dataAction: 'vincularAOrden', label: 'Vincular a orden' } ]
  PresupuestoRef;
```

El botón se activa o no según el *feature control* de 3.5. `vincularAOrden` tiene parámetro, así que Fiori abre un pequeño diálogo para pedir la orden.

## Listas ordenadas

Las notas, las más nuevas primero. Va en la metadata extension de la nota, **antes** de `annotate entity`:

```sql
@Metadata.layer: #CORE
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

## Crear y ver

Clic derecho en la proyección → **New Metadata Extension**, con el mismo nombre que la vista. Escribe las anotaciones, activa y **recarga la vista previa** del binding (a veces hace falta vaciar la caché del navegador con **Ctrl+F5**).

## Preparación del entorno de trabajo

Una metadata extension por proyección, en `ZGOR_SRV`, más las de las vistas de cálculo que se muestren en otra página (`ZI_GorObraFinanzas`, con `@Metadata.allowExtensions: true`).

## Ejercicios

1. **La obra (§4 del informe, `obras_views.xml`).** Escribe la metadata extension de `ZC_GorObra` y la de `ZI_GorObraFinanzas`:
    - Lista: código, descripción, cliente, total, pendiente de cobro y salud (con su color). Filtros: código, cliente y salud.
    - Cabecera de la página: las 5 tarjetas KPI de Odoo (total, gastos, beneficio de caja, pendiente de cobro y margen proyectado) y la salud con su color.
    - Pestañas: Datos (descripción y cliente), Presupuestos, Ingresos, Partes de trabajo, Partes de especialista, Partes de proveedor, Trabajadores (los participantes), Seguimiento de gastos (la ficha), Observaciones, Incidencias y Archivos.
2. **El presupuesto (`presupuestos_views.xml`).** Lista con código, cliente, fecha, total y estado; filtros por cliente, estado y año. Página con los datos del cliente copiados (solo lectura), las líneas como lista, y los botones Aprobar, Desaprobar y Vincular a obra. Pestañas de proveedores, especialistas, observaciones, incidencias y archivos.
3. **El resto.** Las demás, siguiendo §4 del informe. Lo mínimo en cada una: `@UI.headerInfo` con el código como título; lista con las columnas que muestra Odoo; filtros con sus agrupaciones más útiles (estado, obra, cliente, año); bitácoras ordenadas de la más nueva a la más antigua; y el botón *Marcar como pagado* en los partes externos.
4. **El paso 10 de §12.7.** En la lista de clientes, busca `Juan Pérez` con nombre `Juan` y apellidos `Pérez López` en columnas distintas: debe encontrarlo. Si tu sistema no combina así las palabras, añade a `ZC_GorCliente` la búsqueda sobre `NombreCompleto` (2.4) y vuelve a probar. Anota en `diseno.md` qué has tenido que hacer.
5. **Investiga.** Pon `@UI.hidden: true` en un campo obligatorio de la obra y crea una obra desde la app. ¿Qué pasa al guardar? Quítalo y anota por qué un campo obligatorio no se debe ocultar.

---

**Siguiente:** [4.4. Comprobar y depurar](4_4_depurar.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/4_3_metadataExtensions.md){: .fs-2 }
{% endraw %}
