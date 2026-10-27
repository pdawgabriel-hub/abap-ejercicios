---
title: "6.3. Documentos PDF (Adobe Forms)"
parent: "6. Ampliaciones del proyecto"
nav_order: 3
---

# 6.3. Documentos PDF (Adobe Forms)

{% raw %}
> **Zona menos verificada.** Los pasos de esta unidad dependen de apps de administración del entorno que cambian con las versiones. Úsala como guía de qué buscar y contrasta con la documentación oficial antes de dar nada por cierto.

Tus tres informes de Odoo se convierten en plantillas de formulario disparadas desde una action:

| Documento | Plantilla | Se dispara desde |
|---|---|---|
| Presupuesto | `ZGOR_FT_PRESUPUESTO` | Action `imprimirPresupuesto` |
| Parte de trabajo | `ZGOR_FT_PARTE` | Action `imprimirParte` |
| Seguimiento de gastos | `ZGOR_FT_SEGUIMIENTO` | Action `imprimirSeguimiento` |

Regla de oro: **no recalcules en la plantilla**. Pásale los números que ya ve el usuario en pantalla.

> Esta parte necesita el servicio de documentos del entorno, que puede no estar disponible en el trial. Comprueba antes de planificarla; es opcional para el portfolio.

## Ejercicios

1. **Disponibilidad.** Averigua si tu entorno trial permite Adobe Forms.
2. **Alternativa.** Si no, describe cómo mostrarías el presupuesto como una vista de impresión.


---

**Siguiente:** [6.4. Migración de datos desde Odoo](6_4_migracion.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_3_documentosPdf.md){: .fs-2 }
{% endraw %}
