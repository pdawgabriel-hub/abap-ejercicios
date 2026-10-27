---
title: "6.1. Seguridad: catálogos y roles"
parent: "6. Ampliaciones del proyecto"
nav_order: 1
---

# 6.1. Seguridad: catálogos y roles

{% raw %}
> **Zona menos verificada.** Los pasos de esta unidad dependen de apps de administración del entorno que cambian con las versiones. Úsala como guía de qué buscar y contrasta con la documentación oficial antes de dar nada por cierto.

Agrupa tus servicios en tres áreas y dale a cada una un **Business Catalog** y un **Business Role**:

| Business Catalog | Contiene las apps de | Rol |
|---|---|---|
| `ZGOR_BC_COMERCIAL` | `ZUI_GOR_COMERCIAL` | `Z_GOR_COMERCIAL` |
| `ZGOR_BC_FINANCIERO` | `ZUI_GOR_FINANCIERO` | `Z_GOR_FINANCIERO` |
| `ZGOR_BC_RECURSOS` | `ZUI_GOR_RECURSOS` | `Z_GOR_RECURSOS` |

Los roles se gestionan en las apps de administración del entorno: asignas el catálogo al rol y el rol al usuario.

## Ejercicios

1. **Un catálogo.** Crea un Business Catalog y su rol y comprueba con un usuario de prueba que solo ve esa app.
2. **Mapa de permisos.** Haz una tabla con quién debería ver qué en tu proyecto.


---

**Siguiente:** [6.2. Moneda y Fiori Launchpad](6_2_monedaLaunchpad.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_1_seguridad.md){: .fs-2 }
{% endraw %}
