---
title: "6.2. Moneda y Fiori Launchpad"
parent: "6. Ampliaciones del proyecto"
nav_order: 2
---

# 6.2. Moneda y Fiori Launchpad

{% raw %}
> **Zona menos verificada.** Los pasos de esta unidad dependen de apps de administración del entorno que cambian con las versiones. Úsala como guía de qué buscar y contrasta con la documentación oficial antes de dar nada por cierto.

## Moneda

Fija `EUR` por defecto en los campos con importe. El ejemplo lo hace en una determination ([3.3](3_3_determinations.html)). La gestión multiempresa queda fuera del alcance de un portfolio.

## Launchpad

Cada binding OData V4 - UI genera una app. Para verla como icono en el Launchpad:

1. En la app de administración del Launchpad, crea un tile que apunte a tu binding.
2. Asígnalo a un grupo («Gestión de Obras»).
3. Asocia el grupo al Business Catalog de [6.1](6_1_seguridad.html).

Es el equivalente al menú de aplicación del Odoo (`menuitem`).

## Ejercicios

1. **Un tile.** Da de alta la app de Clientes en el Launchpad.
2. **Moneda.** Comprueba que los importes se muestran con el símbolo de euro.


---

**Siguiente:** [6.3. Documentos PDF (Adobe Forms)](6_3_documentosPdf.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_2_monedaLaunchpad.md){: .fs-2 }
{% endraw %}
