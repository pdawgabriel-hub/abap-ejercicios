---
title: "6.4. Migración de datos desde Odoo"
parent: "6. Ampliaciones del proyecto"
nav_order: 4
---

# 6.4. Migración de datos desde Odoo

{% raw %}
Una reimplementación no está terminada hasta que los datos del sistema antiguo están en el nuevo. En ABAP Environment no hay herramientas clásicas de carga (LSMW); hay dos caminos:

| Camino | Cómo | Ventaja | Inconveniente |
|---|---|---|---|
| **Clase de carga generada** | `herramientas/generar_carga.py` convierte un CSV en una clase que hace `INSERT` | Sencillo, sin autenticación | No pasa por las *determinations* ni las *validations* |
| **EML** | Una clase lee los datos y los crea con `MODIFY ENTITIES` | Pasa por toda la lógica: códigos, cálculos, validaciones | Hay que escribirla |

> **Datos personales.** Nunca cargues datos reales de clientes en un trial compartido ni los subas a GitHub. Para practicar, exporta de una base de datos de **demo** de Odoo (§6 del informe: los datos se generan solos al instalar en una BD de demo) o inventa los CSV.

## El generador de clases de carga

El CSV debe tener en la cabecera los **nombres de columna** de la tabla ABAP. Las relaciones vienen como **códigos** (`TIT0001`), porque los UUID de SAP no existen en Odoo; la opción `--ref` hace que la clase busque el UUID por el código en una tabla ya cargada. En el taller:

```bash
python3 herramientas/generar_carga.py datos/titulares.csv ztl_tit zcl_tl_carga_tit \
    --uuid titular_uuid --clear > zcl_tl_carga_tit.abap

python3 herramientas/generar_carga.py datos/ordenes.csv ztl_orden zcl_tl_carga_orden \
    --uuid orden_uuid --ref titular_uuid=ztl_tit.titular_ref:titular > zcl_tl_carga_orden.abap
```

`--ref titular_uuid=ztl_tit.titular_ref:titular` se lee: «la columna `titular` del CSV trae el código; búscalo en `ztl_tit.titular_ref` y pon su UUID en `titular_uuid`». Las fechas en formato `AAAA-MM-DD` se convierten con `--dates`. Todas las opciones: `python3 herramientas/generar_carga.py --help`.

Pega cada clase generada en Eclipse, actívala y ejecútala con **F9**, **en orden**: primero lo que no depende de nada, después lo que apunta a ello.

## Por EML, para que se ejecute la lógica

Con la clase generada, los datos entran tal cual: sin códigos nuevos, sin totales calculados, sin validar. Para el portfolio es más convincente cargar **por EML**, porque demuestra que la lógica del BO acepta los datos reales. El patrón es el de `ZCL_GOR_EML_DEMO` (3.2): leer el CSV (o pegarlo en una tabla interna), y un `MODIFY ENTITIES ... CREATE` por cada BO, en orden, con `COMMIT ENTITIES` y escribiendo los `FAILED` y `REPORTED` de lo que no entre. Lo que rechace una validation es justo lo que hay que revisar en los datos de Odoo.

## Ejercicios

1. **Exporta de Odoo.** En una base de datos de demo de tu Odoo, exporta a CSV (*Acción → Exportar*) 5 clientes, 5 trabajadores, 3 obras con su cliente y los presupuestos de esas obras. Renombra las columnas de la cabecera a los nombres de tus tablas y deja las relaciones como códigos (`CLI0001`, `OBR0001`).
2. **Carga con el generador.** Genera y ejecuta las clases de carga en este orden: clientes, trabajadores, obras (`--ref cliente_uuid=zgor_cli.cliente_id:cliente`), presupuestos (con `--ref` de cliente y de obra). Comprueba en el Data Preview que las relaciones han entrado bien.
3. **Lo que falta.** Las obras cargadas no tienen ficha de gastos y los presupuestos tienen los totales a 0. ¿Por qué? Explícalo en `diseno.md`.
4. **Por EML.** Escribe `ZCL_GOR_MIGRACION`, que cargue los mismos datos con EML. Comprueba que ahora las obras tienen su ficha y los presupuestos sus totales, y que lo que no pasa una validation sale en la consola.
5. **Investiga.** ¿Qué pasaría con el código `OBR0001` de Odoo al cargar por EML, si tu determination de 3.7 asigna los códigos al guardar? Decide si quieres conservar los códigos de Odoo y cómo lo harías.

---

**Siguiente:** [6.5. Dashboard y calendario](6_5_dashboard.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_4_migracion.md){: .fs-2 }
{% endraw %}
