---
title: "5.1. ATC y calidad de código"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 1
---

# 5.1. ATC y calidad de código

{% raw %}
> **Bloque 5 · Calidad, Git y ciclo de 90 días.** Tu ERP funciona y tiene apps. Este bloque es para que **dure**: que el código pase el control de calidad de SAP, que esté en GitHub y que puedas reconstruirlo entero en un trial nuevo cuando caduque el actual. Termina con un ensayo de restauración: si sale bien, el sistema SAP es desechable y tu repositorio es el proyecto.

**ATC** (*ABAP Test Cockpit*) es el analizador estático de SAP: revisa el código sin ejecutarlo y avisa de errores, malas prácticas y problemas de rendimiento. En ABAP Cloud, además, comprueba que solo usas **objetos liberados**. Es lo que en un proyecto de Python harían `pylint` o `ruff`. En una empresa, el ATC suele ser obligatorio antes de liberar una orden de transporte.

## Cómo lanzarlo

Clic derecho sobre un paquete (o una clase) → **Run As → ABAP Test Cockpit** (o *ABAP Test Cockpit With…* para elegir la variante de comprobaciones). Los resultados salen en la vista **ATC Problems**, agrupados por prioridad. Doble clic en un hallazgo lleva a la línea; con el cursor encima, **Ctrl+1** ofrece a veces la corrección automática.

## Qué mirar

| Prioridad | Qué es | Qué hacer |
|---|---|---|
| 1 | Error: código que fallará o que no se puede liberar (por ejemplo, una API no liberada) | Corregirlo siempre |
| 2 | Aviso serio: rendimiento, robustez | Corregirlo, salvo que haya un motivo y se documente |
| 3 | Sugerencia | Leerla; corregir si es fácil |

Un hallazgo típico es un **`SELECT` dentro de un bucle**: una consulta a la base de datos por cada vuelta. En el taller, así no:

```abap
    LOOP AT lt_ordenes INTO DATA(ls_orden).
      SELECT SINGLE razon_social FROM ztl_tit
        WHERE titular_uuid = @ls_orden-titular_uuid
        INTO @DATA(lv_razon).
      " ...
    ENDLOOP.
```

Sino con una sola consulta, uniendo las tablas:

```abap
    SELECT FROM ztl_orden AS o
      INNER JOIN ztl_tit AS t ON t~titular_uuid = o~titular_uuid
      FIELDS o~orden_ref, t~razon_social
      INTO TABLE @DATA(lt_ordenes_con_titular).
```

## Hallazgos que vas a ver en tu ERP

- **Escritura en tablas de otro BO** desde el guardado adicional de la obra (3.5). Es una decisión consciente: en lugar de esconder el aviso, documéntalo. Si tu sistema lo permite, márcalo como excepción justificada con un *pragma* o un comentario `"#EC` que indique el motivo (el ATC te propone cuál con **Ctrl+1**).
- **Variables sin usar**, **`CATCH` vacíos** y **textos sin traducir** (los literales de los mensajes). Los dos primeros se corrigen; el último es una sugerencia que, para el portfolio, puedes dejar explicada en el README.

## Ejercicios

1. **Primer ATC.** Pásalo por el paquete `ZGOR` entero. Apunta cuántos hallazgos hay de cada prioridad.
2. **Prioridad 1 y 2.** Corrige todos los de prioridad 1 y 2, excepto los que decidas justificar. Para cada uno que justifiques, escribe en `diseno.md` qué es y por qué se queda.
3. **Un `SELECT` en bucle.** Escribe a propósito, en `ZCL_GOR_SQL_DEMO`, un bucle sobre las obras que lea el nombre de su cliente con un `SELECT SINGLE` por vuelta. Pasa el ATC, mira el aviso y corrígelo con un `JOIN`.
4. **Los tests también cuentan.** Lanza el ATC sobre `ZCL_GOR_ESCENARIO`. ¿Comprueba también el código de los tests?
5. **Investiga.** Busca qué es la variante de comprobaciones `ABAP_CLOUD_DEVELOPMENT_DEFAULT` y anota qué grupos de comprobaciones incluye.

---

**Siguiente:** [5.2. abapGit: tu código en GitHub](5_2_abapgit.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_1_atc.md){: .fs-2 }
{% endraw %}
