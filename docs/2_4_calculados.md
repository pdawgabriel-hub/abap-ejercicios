---
title: "2.4. Campos calculados y Data Preview"
parent: "2. Modelo de datos con CDS"
nav_order: 4
---

# 2.4. Campos calculados y Data Preview

{% raw %}
> **El ejemplo de referencia.** Todo el bloque 2 a 4 usa un único ejemplo, el taller de reparación de vehículos «RuedaLibre» (`ZTL_*`). Tus ejercicios usan tu proyecto de obras (`ZGOR_*`). Pega el ejemplo para ver cómo funciona y después **haz tu versión**.

## Dos sitios donde calcular

En RAP puedes calcular un valor en dos sitios, y elegir bien es una decisión de diseño:

| | Campo calculado en la CDS | Determination en el comportamiento |
|---|---|---|
| Dónde se calcula | En la base de datos, al consultar | En ABAP, al crear/modificar |
| ¿Se guarda en la tabla? | No | Sí |
| Flexibilidad | Limitada a lo que permite SQL | Total |
| Rendimiento | Muy bueno | Depende del código |
| Equivalente en Odoo | `compute` sin `store` | `compute` con `store=True` |

**Criterio.** Si el valor se puede recalcular al vuelo a partir de otros campos y no necesitas filtrarlo ni ordenarlo con volúmenes grandes, déjalo en la CDS. Si necesita vivir en la tabla (por ejemplo, para un histórico o porque depende de varias entidades), usa una determination ([3.3](3_3_determinations.html)).

## Data Preview

Con una CDS activa abierta, pulsa **F8** (o clic derecho → *Open With → Data Preview*). Se abre una tabla con los datos reales, con los campos calculados ya resueltos y las associations navegables. Úsalo después de activar cada CDS y **antes** de construir la Behavior Definition encima.

## Ejercicios

1. **Estado de pago.** Tu modelo Obras tiene `_compute_estado_pago`. ¿Lo implementarías como determination o como campo calculado? Justifícalo según si el valor necesita vivir en la tabla.
2. **Más campos.** Añade a `ZI_GorObra` otro campo calculado y compruébalo con el Data Preview.
3. **Criterio.** Haz una tabla con los campos calculados de tu Odoo (`horas_totales_obra`, `coste_moo_obra`…) indicando dónde irían y por qué.


---

**Siguiente:** [2.5. Proyecto: CDS de Clientes y Obras](2_5_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/2_4_calculados.md){: .fs-2 }
{% endraw %}
