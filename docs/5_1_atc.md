# 5.1. ATC y calidad de código

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
    " Una sola consulta: cada orden con la razon social de su titular
    SELECT FROM ztl_orden AS o
      INNER JOIN ztl_tit AS t ON t~titular_uuid = o~titular_uuid
      FIELDS o~orden_ref, t~razon_social
      INTO TABLE @DATA(lt_ordenes_con_titular).
```

Con el `INNER JOIN`, la base de datos hace todo el trabajo en **una sola** petición y devuelve cada orden ya con la razón social de su titular. Fíjate en la tilde `~`: en ABAP SQL separa el alias de la tabla de la columna (`o~orden_ref`), igual que el punto en el SQL de MySQL. Si leemos una vista CDS con la association `_Titular`, ni siquiera hace falta el join: basta la ruta `\_Titular-RazonSocial` de 2.3.

## Hallazgos que vas a ver en tu ERP

- **Escritura en tablas de otro BO** desde el guardado adicional de la obra (3.5). Es una decisión consciente: en lugar de esconder el aviso, documéntalo. Si tu sistema lo permite, márcalo como excepción justificada con un *pragma* o un comentario `"#EC` que indique el motivo (el ATC te propone cuál con **Ctrl+1**).
- **Variables sin usar**, **`CATCH` vacíos** y **textos sin traducir** (los literales de los mensajes). Los dos primeros se corrigen; el último es una sugerencia que, para el portfolio, puedes dejar explicada en el README.

## Ejercicios

1. **Primer ATC.**
    - **Dónde:** clic derecho en el paquete `ZGOR` → **Run As → ABAP Test Cockpit**.
    - **Qué haces:** espera a que termine y abre la vista **ATC Problems**.
    - **Comprueba:** apunta en `diseno.md` cuántos hallazgos hay de cada prioridad (1, 2 y 3). Es tu punto de partida.

2. **Prioridad 1 y 2.**
    - **Dónde:** cada hallazgo de **ATC Problems**: doble clic lleva a la línea, y **Ctrl+1** ofrece a veces la corrección.
    - **Qué haces:** corrige todos los de prioridad 1 y 2, excepto los que decidas justificar. Para cada uno que justifiques, escribe en `diseno.md` qué es y por qué se queda.
    - **Comprueba:** vuelve a pasar el ATC: 0 de prioridad 1, y los de prioridad 2 que queden, todos en tu lista.

3. **Un `SELECT` en bucle.**
    - **Dónde:** `ZCL_GOR_SQL_DEMO`, bloque `" 5.1 SELECT en bucle`.
    - **Qué haces:** escribe a propósito un `LOOP AT` sobre las obras que lea el nombre de su cliente con un `SELECT SINGLE` por vuelta. Pasa el ATC solo a esa clase (clic derecho en la clase → **Run As → ABAP Test Cockpit**).
    - **Comprueba:** aparece el aviso del `SELECT` en bucle. Corrígelo con un `INNER JOIN` (o con la ruta `\_Cliente-Nombre` de 2.3), vuelve a pasar el ATC y el aviso desaparece. La consola debe escribir lo mismo antes y después.

4. **Los tests también cuentan.** Lanza el ATC sobre `ZCL_GOR_ESCENARIO`. ¿Comprueba también el código de la pestaña *Test Classes*? Anótalo.

5. **Investiga.** Con **Run As → ABAP Test Cockpit With…** verás el nombre de la variante que se usa. Busca qué es la variante `ABAP_CLOUD_DEVELOPMENT_DEFAULT` y anota qué grupos de comprobaciones incluye.

---

**Siguiente:** [5.2. abapGit: tu código en GitHub](./5_2_abapgit.md)
