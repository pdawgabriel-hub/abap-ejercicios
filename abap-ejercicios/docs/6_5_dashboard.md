---
title: "6.5. Dashboard y calendario"
parent: "6. Ampliaciones del proyecto"
nav_order: 5
---

# 6.5. Dashboard y calendario

{% raw %}
> **Zona menos verificada.** Los pasos de esta unidad dependen de apps de administración del entorno que cambian con las versiones. Úsala como guía de qué buscar y contrasta con la documentación oficial antes de dar nada por cierto.

## Dashboard

El dashboard de Odoo agrega datos. En SAP se hace con **CDS analíticas** (`@Analytics.query`, agregaciones con `sum`, `count`) en vez de un método que agrega en memoria. Ejemplo del repositorio:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'KPI de ordenes por estado'
define view entity ZI_TlKpiEstado
  as select from ztl_orden
{
  key estado               as Estado,
      count( * )           as NumOrdenes,
      @Semantics.amount.currencyCode: 'Moneda'
      sum( coste_total )   as CosteTotal,
      moneda               as Moneda
}
group by estado, moneda
```

## Calendario unificado

Se resuelve con una CDS que une varias fuentes con `union all` (obras, partes, ingresos...), cada rama con las mismas columnas (fecha, tipo, título).

## Ejercicios

1. **KPI.** Crea una CDS que cuente obras por estado.
2. **Calendario.** Une al menos tres ramas en `ZI_GorCalendario`.


---

**Siguiente:** [7.1. Mapa de entidades Odoo a SAP](7_1_mapaEntidades.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_5_dashboard.md){: .fs-2 }
{% endraw %}
