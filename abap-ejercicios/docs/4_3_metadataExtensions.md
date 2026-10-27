---
title: "4.3. Metadata Extensions y la interfaz"
parent: "4. Servicios y app Fiori"
nav_order: 3
---

# 4.3. Metadata Extensions y la interfaz

{% raw %}
Una app Fiori Elements pinta lo que le dicen las **anotaciones** `@UI.*`. Para no ensuciar la CDS, se ponen en una **Metadata Extension**.

## Qué controlan las anotaciones principales

| Anotación | Efecto |
|---|---|
| `@UI.lineItem` | Columnas de la tabla (lista) |
| `@UI.selectionField` | Filtros de la cabecera |
| `@UI.facet` | Secciones de la página de detalle |
| `@UI.fieldGroup` | Campos de una sección |
| `@UI.identification` | Botones, como las actions |
| `@UI.hidden` | Oculta un campo |

## Ejemplo de la orden

Crea con **New → Metadata Extension** y pega:

```sql
@Metadata.layer: #CORE
annotate entity ZC_TlOrden with
{
  @UI.facet: [
    { id: 'Datos', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE,
      label: 'Datos generales', position: 10 },
    { id: 'Lineas', purpose: #STANDARD, type: #LINEITEM_REFERENCE,
      label: 'Lineas de coste', position: 20, targetElement: '_Lineas' }
  ]

  @UI.hidden: true
  OrdenUuid;

  @UI.lineItem: [ { position: 10, label: 'N. orden' },
                  { type: #FOR_ACTION, dataAction: 'cerrarOrden',
                    label: 'Cerrar orden' } ]
  @UI.identification: [ { position: 10 },
                        { type: #FOR_ACTION, dataAction: 'cerrarOrden',
                          label: 'Cerrar orden' } ]
  OrdenId;

  @UI.lineItem: [ { position: 20 } ]
  @UI.identification: [ { position: 20 } ]
  @UI.selectionField: [ { position: 10 } ]
  Matricula;

  @UI.lineItem: [ { position: 30 } ]
  @UI.identification: [ { position: 30 } ]
  Descripcion;

  @UI.lineItem: [ { position: 40, label: 'Estado' } ]
  @UI.identification: [ { position: 40, label: 'Estado' } ]
  @UI.selectionField: [ { position: 20 } ]
  EstadoTexto;

  @UI.lineItem: [ { position: 50 } ]
  @UI.identification: [ { position: 50 } ]
  FechaEntrada;

  @UI.lineItem: [ { position: 60 } ]
  @UI.identification: [ { position: 60 } ]
  CosteTotal;
}
```

Y la de las líneas:

```sql
@Metadata.layer: #CORE
annotate entity ZC_TlLinea with
{
  @UI.facet: [
    { id: 'Datos', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE,
      label: 'Linea', position: 10 }
  ]

  @UI.hidden: true
  LineaUuid;

  @UI.hidden: true
  OrdenUuid;

  @UI.lineItem: [ { position: 10 } ]
  @UI.identification: [ { position: 10 } ]
  Concepto;

  @UI.lineItem: [ { position: 20 } ]
  @UI.identification: [ { position: 20 } ]
  Importe;
}
```

Para ver el resultado, **recarga la vista previa** del binding.

## Ejercicios

1. **Lista de Clientes.** Crea la metadata extension de `ZC_GorCliente` con 4 columnas y 2 filtros.
2. **Detalle.** Añade una sección «Contacto» con teléfono y email.
3. **Botón.** Añade un botón para `cerrarObra` con `@UI.identification`.


---

**Siguiente:** [4.4. Comprobar y depurar](4_4_depurar.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/4_3_metadataExtensions.md){: .fs-2 }
{% endraw %}
