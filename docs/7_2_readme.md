---
title: "7.2. El README del portfolio"
parent: "7. Cierre del proyecto"
nav_order: 2
---

# 7.2. El README del portfolio

{% raw %}
Quien mire tu repositorio dedicará al README menos de un minuto. Tiene que entender en ese minuto **qué es**, **qué demuestra** y **que funciona**. Todo lo demás (el diseño, las decisiones, el detalle) va enlazado.

## Qué debe contar, en este orden

1. **Qué es, en dos frases.** El ERP de Obras y Reformas: una reimplementación en SAP (ABAP Cloud y RAP) del módulo `gestion_bd` de Odoo para empresas de reformas.
2. **Una captura.** La ficha de una obra, con sus tarjetas KPI y el semáforo de salud.
3. **Qué hace.** Las entidades y el ciclo de negocio (cliente → presupuesto → obra → partes → cobros), en una lista corta o un diagrama.
4. **Odoo → SAP.** Una tabla breve con la traducción de conceptos: modelo → tabla + vista CDS + BDEF; `compute` → vista CDS o *determination*; `@api.constrains` → *validation*; botón → *action*; vistas XML → anotaciones de Fiori.
5. **Las decisiones de diseño**, cada una en una o dos frases y con el motivo:
    - Los derivados entre objetos se **calculan al leer** (vistas CDS) y los de dentro de un objeto se guardan con *determinations*: así no puede haber números atrasados, el problema que el Odoo original tenía que proteger con tests de regresión.
    - Las reglas de negocio en **una clase sin dependencias** (`ZCL_GOR_REGLAS`), probada con ABAP Unit y reutilizada por el comportamiento RAP.
    - La ficha de gastos como **hija `[0..1]`** de la obra: unicidad y borrado garantizados por el modelo.
    - El borrado de una obra con **guardado adicional**, y por qué es aceptable aquí.
    - Los códigos con **máximo + 1** y su límite con varios usuarios.
6. **Cómo se prueba.** Los tests (cuántos y qué cubren, con el escenario de §12.7 como prueba de aceptación) y el ATC.
7. **Cómo se restaura.** Enlace al documento de restauración.
8. **Lo que no está hecho**, con honestidad: lo que el trial no permite (formularios PDF, Launchpad) y lo que mejorarías.
9. **Tecnologías**: ABAP Cloud, RAP (*managed*, *draft*), CDS View Entities, OData V4, Fiori Elements, ABAP Unit, ATC, abapGit, SAP BTP ABAP Environment.

## Lo que no va en el README

- El detalle campo a campo: va en `docs/diseno.md`.
- El informe de Odoo entero: se enlaza (`docs/odoo/informe-tecnico.md`), y solo en su versión sin datos de la empresa (1.9).
- Datos personales de la empresa o de sus clientes: **nunca**. Ni en el README ni en las capturas (usa los datos de demo de 2.5).

## Ejercicios

1. **Escríbelo.** Redacta el README de `erp-obras-reformas-sap` siguiendo los nueve puntos. Usa tus notas de `diseno.md` para las decisiones y las cifras de 7.1.
2. **Las capturas.** Elige tres de las de 4.5: la lista de obras, la ficha de una obra y un error de validación. Comprueba que no se ve ningún dato real.
3. **La prueba del minuto.** Pide a alguien que lea el README durante un minuto y te diga qué es el proyecto. Si no lo sabe decir, reescribe el principio.
4. **Revisa los enlaces.** Que el enlace a la restauración, al diseño y al informe funcionen en GitHub.

---

**Siguiente:** [7.3. Explicarlo en 5 minutos](7_3_explicacion.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/7_2_readme.md){: .fs-2 }
{% endraw %}
