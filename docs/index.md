---
title: Inicio
nav_order: 0
---

# Apuntes de SAP ABAP Cloud y RAP

{% raw %}
**Apuntes de SAP ABAP Cloud y RAP** para aprender el lenguaje construyendo el **ERP de Obras y Reformas**: el port a SAP de `gestion_bd`, un módulo de Odoo para gestionar obras y reformas.

> **Dos proyectos.** La teoría se explica con un proyecto de ejemplo, el **taller RuedaLibre**, con el código completo. Los ejercicios te piden construir **tu ERP** tomando el taller como modelo: te dicen qué crear, con qué campos y datos y qué resultado debe salir, pero no te dan el código. Los tests de cada bloque comprueban tu solución. Los dos proyectos, con sus modelos de datos, se presentan en [0.3](0_3_dosProyectos.html), [0.4](0_4_erp.html) y [0.5](0_5_taller.html).

> **Aviso.** El código de estos apuntes se ha escrito siguiendo la documentación de SAP, pero **no se ha podido compilar contra un sistema real**. Si algo da error al activar, copia el mensaje exacto: es parte del aprendizaje. Las partes menos verificadas lo indican al principio.

## Los bloques

| Bloque | Qué aprendes | Qué tiene tu ERP al terminar |
|---|---|---|
| [0. Introducción y entorno](bloque_B0.html) | Eclipse, el trial, qué es ABAP Cloud y los dos proyectos | El entorno listo y la guía de lo que vas a construir |
| [1. Fundamentos del lenguaje](bloque_B1.html) | Tipos, flujo, tablas internas, SQL, objetos, excepciones y ABAP Unit | Las reglas de negocio en `ZCL_GOR_REGLAS`, con 34 tests, y una simulación en memoria |
| [2. Modelo de datos con CDS](bloque_B2.html) | Tablas, vistas CDS, relaciones y cálculos | Las tablas, el modelo CDS y la ficha financiera de cada obra calculada al leer |
| [3. Comportamiento con RAP](bloque_B3.html) | BDEF, EML, *determinations*, *validations*, *actions*, numeración y tests con dobles | Diez objetos de negocio que calculan, validan y guardan; el escenario de §12.7 como test |
| [4. Servicios y app Fiori](bloque_B4.html) | Proyecciones, servicios OData y anotaciones de Fiori | Tres apps con las que repetir el escenario a mano |
| [5. Calidad, Git y ciclo de 90 días](bloque_B5.html) | ATC, abapGit y la vida del trial | El código en GitHub y una restauración ensayada |
| [6. Ampliaciones del proyecto](bloque_B6.html) | Autorizaciones, Launchpad, documentos, migración y analítica | Lo que el trial permita de roles, documentos, dashboard y calendario |
| [7. Cierre del proyecto](bloque_B7.html) | Presentar un proyecto técnico | El portfolio: README, capturas y guion de 5 minutos |
| [Anexos](bloque_A.html) | Consulta | — |

Cada unidad sigue el mismo orden: teoría con el taller, **Preparación del entorno de trabajo**, **Ejercicios** sobre tu ERP y, cuando se puede, **Comprueba tu solución automáticamente** con un test de los [materiales](https://github.com/pdawgabriel-hub/abap-ejercicios/tree/main/docs/materiales/tests). Cada bloque termina con una unidad de **Proyecto** que integra lo visto.

## Dos repositorios

| Repositorio | Contiene | Paquete |
|---|---|---|
| `abap-ejercicios` | Estos apuntes (`docs/`), los tests de los ejercicios y las herramientas | `ZEJ` (tus pruebas del taller) |
| `erp-obras-reformas-sap` | Tu ERP: código, diseño y README | `ZGOR` |

## La regla de los 90 días

La cuenta de pruebas de SAP BTP dura **90 días** desde el registro y exige entrar al menos una vez cada 30. Cuando caduca se borra todo, y se abre un trial nuevo. Por eso el **repositorio es tu copia de seguridad**: haz *push* al terminar cada sesión y consulta [5.3. El ciclo de 90 días](5_3_ciclo90dias.html).
{% endraw %}
