---
title: "7.3. Explicarlo en 5 minutos"
parent: "7. Cierre del proyecto"
nav_order: 3
---

# 7.3. Explicarlo en 5 minutos

{% raw %}
En las prácticas te preguntarán qué has hecho. Tener preparada una explicación de cinco minutos, con una pequeña demo, marca la diferencia. Esta unidad es un guion para prepararla.

## El guion

| Minuto | Qué cuentas | Qué enseñas |
|---|---|---|
| 0:00 - 0:30 | **El problema.** Una empresa de reformas real que necesitaba controlar presupuestos, obras, mano de obra y cobros. Lo resolviste en Odoo y está en producción | — |
| 0:30 - 1:30 | **El modelo.** Diez objetos de negocio; el ciclo cliente → presupuesto → obra → partes → cobros; la ficha financiera de la obra | El diagrama del README |
| 1:30 - 3:30 | **La demo.** El escenario de §12.7 resumido: aprobar un presupuesto y ver cambiar el total de la obra; registrar un cobro y ver el semáforo pasar de rojo a verde; intentar borrar una obra con cobros | La app de obras |
| 3:30 - 4:30 | **Una decisión de diseño.** Elige **una** y explícala bien: por ejemplo, calcular al leer en lugar de guardar los totales, y qué errores del Odoo original evita | El código de `ZI_GorObraFinanzas` o un test |
| 4:30 - 5:00 | **Qué harías después.** Lo que no está hecho y cómo lo harías en un S/4HANA de empresa | — |

## Preguntas que te pueden hacer

Prepara una respuesta corta para cada una:

- ¿Por qué RAP y no ABAP clásico? ¿Qué sabes del clásico? (Anexo [A](A_clasico.html))
- ¿Qué es un *draft* y para qué sirve?
- ¿Qué diferencia hay entre una *determination* y una *validation*?
- ¿Cómo pruebas que esto funciona?
- ¿Qué pasa si dos personas editan la misma obra?
- ¿Cómo lo llevarías a un sistema de verdad? (Transportes, roles, Launchpad)

## Ejercicios

1. **Escribe el guion** con tus palabras, en una página, con lo que vas a decir en cada tramo.
2. **Ensaya con reloj.** Grábate en vídeo o hazlo delante de alguien. Si te pasas de cinco minutos, recorta la demo, no la decisión de diseño.
3. **Las preguntas.** Escribe tus respuestas a las seis preguntas. Si alguna no la sabes contestar, vuelve a la unidad que la explica.

---

**Siguiente:** [Anexos](bloque_A.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/7_3_explicacion.md){: .fs-2 }
{% endraw %}
