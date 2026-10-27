---
title: "7.3. Lógica de negocio por entidad"
parent: "7. Proyecto ERP de Obras y Reformas"
nav_order: 3
---

# 7.3. Lógica de negocio por entidad

{% raw %}
Traduce los `compute`, `constrains` y botones de cada modelo de Odoo.

| Odoo | En SAP | Dónde |
|---|---|---|
| `_compute_...` con `store=True` | Determination | BDEF + clase local |
| `_compute_...` sin `store` | Campo calculado | CDS |
| `@api.constrains` | Validation | BDEF + clase local |
| Botón (método público) | Action | BDEF + clase local |
| `create()` con secuencia | Determination *on save* | [3.7](3_7_numeracion.html) |
| `ondelete='cascade'` | Composition | CDS + BDEF |

## Ejercicios

1. **Tabla de traducción** de todos los métodos de tu módulo Odoo a este formato.
2. **Prioriza** los 5 más importantes y haz esos primero.


---

**Siguiente:** [7.4. README y explicación en 5 minutos](7_4_readme.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/7_3_logica.md){: .fs-2 }
{% endraw %}
