---
title: "1.9. Proyecto: del modelo de Odoo a tablas ABAP"
parent: "1. Fundamentos del lenguaje"
nav_order: 9
---

# 1.9. Proyecto: del modelo de Odoo a tablas ABAP

{% raw %}
Este es el primer paso de tu proyecto: **traducir tu modelo de Odoo a tablas de base de datos ABAP**, sin escribir todavía código en el sistema. El resultado será el germen de `docs/diseno.md` en el repositorio `gestion-bd-sap`.

## Qué tienes que entregar

Para las **4 entidades del núcleo** (Clientes, Obras, Presupuestos con líneas e Ingresos):

1. La tabla con prefijo `ZGOR_`: campos, tipos ABAP y clave.
2. Las relaciones: Many2one → campo con el UUID del padre; One2many con borrado en cascada → tabla hija; Many2many → tabla de asociación.
3. Qué campos `compute` con `store=True` se guardan y cuáles se recalcularán al vuelo.

El resto de modelos (Gastos, Trabajadores, Especialistas, Proveedores, Partes de trabajo) puedes dejarlos para más tarde.

## Tabla de equivalencias de tipos

| Odoo | ABAP Cloud (tabla) |
|---|---|
| Char | `abap.char(n)` o `string` |
| Text | `abap.string` o `abap.char(255)` |
| Integer | `abap.int4` |
| Float / Monetary | `abap.curr(15,2)` con campo de moneda `abap.cuky` |
| Date | `abap.dats` |
| Datetime | `abap.utclong` o timestamp |
| Selection | `abap.char(1)` con la lista de valores en el código |
| Boolean | `abap.char(1)` o `abap_boolean` |
| Many2one | campo con el UUID del registro padre |
| Binary (archivo) | `abap.rawstring` (con precauciones, ver [7.1](7_1_mapaEntidades.html)) |

> **Patrón recomendado.** Cada entidad lleva una **clave UUID** (la genera el framework) y, aparte, un **número visible** (el código del negocio, por ejemplo `cliente_id`). Lo verás en [3.7](3_7_numeracion.html).

Respeta la [convención de nombres](B_nombres.html): tablas de 16 caracteres como máximo y sin tildes.

## Ejercicios

1. **Diseño del núcleo.** Entrega el diseño de las 4 entidades: campos, tipos, claves y relaciones.
2. **DDL de Clientes.** Escribe el DDL de la tabla de Clientes con la sintaxis de [2.1](2_1_tablas.html) (aunque aún no la actives).
3. **Subida al repo.** Guarda el diseño en `docs/diseno.md` del repositorio `gestion-bd-sap` y pásaselo a Claude para revisarlo antes de tocar el sistema.


---

**Siguiente:** [2.1. Tablas persistentes en ADT](2_1_tablas.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_9_proyecto.md){: .fs-2 }
{% endraw %}
