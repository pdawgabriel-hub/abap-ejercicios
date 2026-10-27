---
title: "2.5. Proyecto: CDS de Clientes y Obras"
parent: "2. Modelo de datos con CDS"
nav_order: 5
---

# 2.5. Proyecto: CDS de Clientes y Obras

{% raw %}
Pon en práctica el bloque 2 con las dos primeras entidades del ERP de Obras y Reformas.

## Qué cambiar al clonar el ejemplo RuedaLibre

| Ejemplo | Para Clientes |
|---|---|
| `ztl_orden` | `zgor_cli` |
| `orden_uuid` | `cliente_uuid` |
| `orden_id` (numc 8) | `cliente_id` (numc 8) |
| Campos de la orden | Los de tu diseño (nombre, NIF, teléfono, email…) |
| `ZI_TlOrden` | `ZI_GorCliente` |
| Alias en CamelCase | `ClienteUuid`, `ClienteId`, `Nombre`… |

## Criterio de «listo»

- [ ] Las tablas `zgor_cli` y `zgor_obra` están activas.
- [ ] `ZI_GorCliente` y `ZI_GorObra` están activas y el Data Preview se abre.
- [ ] `ZI_GorObra` tiene la association hacia `ZI_GorCliente`.
- [ ] Hay 3 clientes y 3 obras de prueba y se ven en el Data Preview.
- [ ] Has hecho push con abapGit (mensaje: «Fase 1: tablas y CDS de Cliente y Obra»).

## Ejercicios

1. **Fase 1.** Crea la tabla y la CDS de Clientes, con al menos un campo calculado con `case`. Comprueba con Data Preview.
2. **Obras.** Repite con Obras, añadiendo una association hacia Clientes.
3. **Datos.** Inserta 3 clientes con una clase ejecutable ([1.5](1_5_abapSql.html)) y vuelve a mirar el Preview.


---

**Siguiente:** [3.1. Behavior Definition managed](3_1_behaviorDefinition.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/2_5_proyecto.md){: .fs-2 }
{% endraw %}
