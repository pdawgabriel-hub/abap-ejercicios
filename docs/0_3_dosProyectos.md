---
title: "0.3. Los dos proyectos"
parent: "0. Introducción y entorno"
nav_order: 3
---

# 0.3. Los dos proyectos

{% raw %}
Estos apuntes trabajan con **dos proyectos a la vez**, con papeles distintos:

| | Taller RuedaLibre | ERP de Obras y Reformas |
|---|---|---|
| Papel | **Ejemplo**: con él se explica la teoría | **Tu proyecto**: lo construyes en los ejercicios |
| Código en los apuntes | Completo | Ninguno: solo la especificación y el resultado esperado |
| Cómo se comprueba | Probándolo, si quieres | Con los tests de cada unidad y bloque |
| Paquete | `ZEJ` (pruebas) | `ZGOR` |
| Prefijo | `ZTL`, `ztl_`, `ZI_Tl` | `ZGOR`, `zgor_`, `ZI_Gor` |
| Repositorio | `abap-ejercicios` | `erp-obras-reformas-sap` |
| Guía técnica | [0.5](0_5_taller.html) | [0.4](0_4_erp.html) |

## Por qué dos

Si la teoría se explicara con tu propio ERP, los ejercicios se reducirían a copiar el código del apunte. Con el taller pasa lo contrario: tiene las mismas clases de problemas que tu ERP, pero con **otros nombres** y algunas reglas **distintas en los detalles**. Para resolver un ejercicio tienes que entender qué hace cada pieza del ejemplo y traducirla, que es exactamente lo que harás en las prácticas con el código de otros.

## Cómo se parecen

Las dos aplicaciones tienen la misma forma: un cliente, una oferta con líneas e impuesto, un trabajo que se ejecuta con mano de obra propia y costes externos, cobros, y una ficha que resume el dinero.

| Funcionalidad | Taller | ERP |
|---|---|---|
| Quién encarga el trabajo | Titular | Cliente |
| La oferta | Presupuesto con partidas, que se **acepta** | Presupuesto con líneas, que se **aprueba** |
| El trabajo | Orden de reparación | Obra |
| La ficha 1:1 que resume el dinero | Hoja de costes | Ficha de gastos |
| Mano de obra propia | Registros de jornada con tramos por mecánico | Partes de trabajo con líneas por trabajador |
| Costes externos | Albaranes de recambios y facturas de subcontrata | Partes de proveedor y de especialista |
| Cobros | Abonos | Ingresos |
| Ausencias del personal | Ausencias | Faltas |
| Bitácoras | Notas, avisos y fotos | Observaciones, incidencias y archivos |
| El semáforo | Rendimiento y situación de cobro | Beneficio real y estado de pago |

## En qué se diferencian

Lo bastante para que no baste con cambiar los nombres:

| Detalle | Taller | ERP |
|---|---|---|
| Máximo de horas por línea | 10 | 24 |
| Porcentaje cobrado | Desde lo **abonado** | Desde lo **pendiente** |
| Búsqueda por palabras | Cada palabra, al **principio** de un campo | Cada palabra, en **cualquier** posición |
| Ranking de personal | Por **euros** | Por **horas** |
| Tarifa por defecto | 30 €/h | 20 €/h |
| Nombre del titular / cliente | Un campo (razón social) | Nombre y apellidos |
| Toda orden / obra tiene cliente | Sí | No: una obra puede no tenerlo |
| Satélites | Presupuesto y orden | Casi todas las entidades (21 tablas) |
| Servicios | Uno | Tres (comercial, financiero, recursos) |

## Los modelos de datos

Los dos diagramas, uno junto a otro. En cada guía técnica están a tamaño completo, con la explicación de cada tabla.

| Taller RuedaLibre | ERP de Obras y Reformas |
|---|---|
| [![Modelo del taller](materiales/diagramas/taller_modelo.svg)](materiales/diagramas/taller_modelo.svg) | [![Modelo del ERP](materiales/diagramas/erp_modelo.svg)](materiales/diagramas/erp_modelo.svg) |

Los diagramas se generan con `herramientas/generar_diagramas.py`. Si cambias el modelo, cambia el script y vuelve a ejecutarlo.

## Cómo usar los dos en cada unidad

1. Lee la teoría: el código del taller, con la explicación de cada pieza.
2. Si quieres, pruébalo en tu paquete `ZEJ`.
3. Haz los ejercicios: construye la pieza equivalente de tu ERP en `ZGOR`, con la especificación del ejercicio y la guía técnica [0.4](0_4_erp.html).
4. Ejecuta el test de la unidad. Si falla, el mensaje te dice qué valor esperaba.

---

**Siguiente:** [0.4. Guía técnica del ERP de Obras y Reformas](0_4_erp.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/0_3_dosProyectos.md){: .fs-2 }
{% endraw %}
