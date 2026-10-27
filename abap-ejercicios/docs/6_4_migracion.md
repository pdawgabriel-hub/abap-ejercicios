---
title: "6.4. Migración de datos desde Odoo"
parent: "6. Ampliaciones del proyecto"
nav_order: 4
---

# 6.4. Migración de datos desde Odoo

{% raw %}
En ABAP Environment no existe LSMW. Hay dos caminos:

| Camino | Cómo | Ventaja |
|---|---|---|
| **Cargador de clase** (`generar_carga.py`) | Convierte un CSV de Odoo en una clase ejecutable con `INSERT` | Sencillo, sin autenticación |
| **POST OData** | Un script lee de Odoo y hace un `POST` al servicio | Pasa por tus validations y determinations |

## El cargador

El script `herramientas/generar_carga.py` del repositorio lee un CSV y genera la clase. Uso típico:

```bash
python3 herramientas/generar_carga.py datos/clientes.csv zgor_cli zcl_gor_carga_cli \
    --uuid cliente_uuid --dates fecha_alta --clear > zcl_gor_carga_cli.abap
```

Pega la clase generada en Eclipse, actívala y ejecútala con **F9**. Orden de carga: Clientes, Obras, Presupuestos, líneas, Ingresos, Gastos.

Consulta `python3 herramientas/generar_carga.py --help` para ver todas las opciones (fechas, UUID, borrado previo).

> Con el cargador de clase **no se ejecutan** las validations ni las determinations: los datos entran tal cual. Para el portfolio es suficiente si lo anotas en el README.

## Ejercicios

1. **Exporta 5 clientes** de Odoo a CSV (sin datos personales reales; usa datos de prueba).
2. **Cárgalos** con el script y comprueba el Data Preview.
3. **POST.** Escribe en pseudocódigo el flujo de migración por OData y compáralo con el cargador.


---

**Siguiente:** [6.5. Dashboard y calendario](6_5_dashboard.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_4_migracion.md){: .fs-2 }
{% endraw %}
