---
title: Inicio
nav_order: 0
---

# Apuntes de SAP ABAP Cloud y RAP

{% raw %}
**Apuntes de SAP ABAP Cloud y RAP** para aprender el lenguaje construyendo el **ERP de Obras y Reformas**: el port a SAP del módulo `gestion_bd` de Odoo. Teoría breve, código que puedes ejecutar y ejercicios con comprobación automática cuando se puede.

> **Estructura por bloques.** Cada bloque agrupa unidades con teoría, ejemplos y ejercicios, y termina con una unidad de **Proyecto** donde aplicas lo aprendido al ERP de Obras y Reformas. Las unidades con `ABAP Unit` incluyen una comprobación automática opcional.

> **Aviso importante.** El código de estos apuntes se ha escrito siguiendo la documentación de SAP, pero **no se ha podido compilar contra un sistema real**. Si algo da error al activar, copia el mensaje exacto: es parte del aprendizaje.

## Dos repositorios, dos finalidades

| Repositorio | Contiene | Se sincroniza con |
|---|---|---|
| `abap-ejercicios` | Estos apuntes (`docs/`), los esqueletos y los tests de los ejercicios, tus soluciones | El paquete `ZEJ` (carpeta `src/`) |
| `erp-obras-reformas-sap` | El proyecto: diseño, README, código generado | El paquete `ZGOR` (carpeta `src/`) |

## La regla de los 90 días

La cuenta de pruebas de SAP BTP dura **90 días** desde el registro y exige entrar al menos una vez cada 30. Cuando caduca se borra todo, y se abre un trial nuevo. Por eso el **repositorio es tu copia de seguridad**: haz push al terminar cada sesión y consulta [5.3. El ciclo de 90 días](5_3_ciclo90dias.html).
{% endraw %}
