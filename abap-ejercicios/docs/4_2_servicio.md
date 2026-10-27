---
title: "4.2. Service Definition y Service Binding"
parent: "4. Servicios y app Fiori"
nav_order: 2
---

# 4.2. Service Definition y Service Binding

{% raw %}
Para que otros (una app Fiori, Postman) consuman el modelo hay que **publicarlo como servicio**. Son dos objetos:

- **Service Definition**: qué entidades se exponen.
- **Service Binding**: con qué protocolo (aquí **OData V4 - UI**).

## Pasos

1. Clic derecho en el paquete → **New → Other ABAP Repository Object → Service Definition**. Nombre `ZUI_TL_TALLER`.
2. Pega el contenido y activa.
3. Clic derecho sobre la Service Definition → **New Service Binding**. Nombre `ZUI_TL_TALLER_O4`, tipo **OData V4 - UI**.
4. Activa el binding y pulsa **Publish** (botón de la parte superior).

```sql
@EndUserText.label: 'Servicio de gestion del taller'
define service ZUI_TL_TALLER {
  expose ZC_TlOrden  as Orden;
  expose ZC_TlLinea  as Linea;
}
```

## Comprobar que funciona

Con el binding publicado, selecciona la entidad raíz y pulsa **Preview**: se abre la app Fiori Elements en el navegador. Para ver el servicio en bruto, abre la URL del servicio y añade `/$metadata`.

## Ejercicios

1. **Servicio de Clientes.** Crea la Service Definition `ZUI_GOR_COMERCIAL` exponiendo Cliente, Obra y Presupuesto cuando los tengas, y su binding.
2. **$metadata.** Abre `$metadata` y localiza una entidad y una navegación.
3. **Tres servicios.** En [7.1](7_1_mapaEntidades.html) se propone un servicio por área. Explica ventajas de separar en tres frente a uno solo.


---

**Siguiente:** [4.3. Metadata Extensions y la interfaz](4_3_metadataExtensions.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/4_2_servicio.md){: .fs-2 }
{% endraw %}
