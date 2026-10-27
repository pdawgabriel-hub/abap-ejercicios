---
title: "7.1. Mapa de entidades Odoo a SAP"
parent: "7. Proyecto gestion_bd"
nav_order: 1
---

# 7.1. Mapa de entidades Odoo a SAP

{% raw %}
Plan de paquetes: `ZGOR` con subpaquetes `ZGOR_DDIC` (tablas), `ZGOR_CDS`, `ZGOR_BUS` (comportamiento), `ZGOR_SRV` (servicios) y `ZGOR_TEST`.

| Servicio | Entidades |
|---|---|
| `ZUI_GOR_COMERCIAL` | Cliente, Obra, Presupuesto (+ líneas y observaciones) |
| `ZUI_GOR_FINANCIERO` | Ingreso, Gasto (+ sublíneas) |
| `ZUI_GOR_RECURSOS` | Trabajador, Especialista, Proveedor, Parte de trabajo |

## Nombres de entidades

| Odoo | CDS interface | Tabla |
|---|---|---|
| Clientes | `ZI_GorCliente` | `zgor_cli` |
| Obras | `ZI_GorObra` | `zgor_obra` |
| Presupuestos | `ZI_GorPresupuesto` | `zgor_presu` |
| Líneas de presupuesto | `ZI_GorPresuLin` | (hija) |
| Ingresos | `ZI_GorIngreso` | `zgor_ing` |
| Gastos | `ZI_GorGasto` | `zgor_gasto` |
| Partes | `ZI_GorParte` | `zgor_parte` |
| Trabajadores / Especialistas / Proveedores | `ZI_GorTrabajador`, `ZI_GorEspecialista`, `ZI_GorProveedor` | por definir |

## Ejercicios

1. **Completa la tabla** con los nombres de las columnas de cada tabla desde tus modelos de Odoo.
2. **Many2many.** Define las tablas de asociación Obra-Trabajador, Obra-Especialista y Obra-Proveedor.


---

**Siguiente:** [7.2. Fases y checklist](7_2_fases.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/7_1_mapaEntidades.md){: .fs-2 }
{% endraw %}
