---
title: "2.3. Associations y composiciones"
parent: "2. Modelo de datos con CDS"
nav_order: 3
---

# 2.3. Associations y composiciones

{% raw %}
> **El ejemplo de referencia.** Todo el bloque 2 a 4 usa un único ejemplo, el taller de reparación de vehículos «RuedaLibre» (`ZTL_*`). Tus ejercicios usan tu proyecto de obras (`ZGOR_*`). Pega el ejemplo para ver cómo funciona y después **haz tu versión**.

Una **association** es una relación declarada entre dos CDS que no trae los datos hasta que alguien la usa (como la carga perezosa de un recordset). Una **composition** es una relación de **propiedad**: si borro la cabecera, se borran las líneas.

## Cuándo usar cada una

| Relación | Se modela con | Ejemplo |
|---|---|---|
| Many2one entre entidades independientes | `association` | Obra → Cliente |
| Cabecera con líneas que no existen sin ella | `composition` | Presupuesto → Línea |
| Many2many | tabla de asociación como entidad hija en composición de uno de los lados | Obra ↔ Trabajador |

## Qué se escribe y dónde

| Dónde | Qué se escribe | Para qué sirve |
|---|---|---|
| CDS interface raíz | `composition [0..*] of ZI_TlLinea as _Lineas` | Declara que las líneas pertenecen a la orden |
| CDS interface hija | `association to parent ZI_TlOrden as _Orden on ...` | La línea sabe de qué orden es |
| BDEF (raíz) | `association _Lineas { create; }` | Permite crear líneas dentro de una orden |
| BDEF (hija) | `lock dependent by _Orden; authorization dependent by _Orden` | La línea hereda bloqueo y autorización |
| CDS proyección raíz | `_Lineas : redirected to composition child ZC_TlLinea` | Apunta a la proyección hija |
| CDS proyección hija | `_Orden : redirected to parent ZC_TlOrden` | Apunta a la proyección padre |
| BDEF proyección | `use association _Lineas { create; }` | Hereda la creación de líneas |

> **Puente a Odoo.** La composition es el `ondelete='cascade'` de tus modelos hijos: `ClientesObservaciones`, `PresupuestoLinea`… Sin su padre no tienen sentido.

## Ejercicios

1. **Presupuesto con líneas.** Dibuja (en texto, como las tablas de arriba) cómo sería la composition entre `ZI_GorPresupuesto` y `ZI_GorPresuLin`, con tus nombres.
2. **¿Por qué dos conceptos?** ¿Por qué crees que RAP distingue entre association y composition en vez de tratarlas igual, como hace un Many2one/One2many genérico?
3. **Many2many.** Elige un Many2many de tu proyecto y explica cómo lo modelarías con la tabla de asociación como hija de uno de los lados.


---

**Siguiente:** [2.4. Campos calculados y Data Preview](2_4_calculados.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/2_3_associations.md){: .fs-2 }
{% endraw %}
