# 4.4. Comprobar y depurar

Con las apps funcionando aparecen errores nuevos: un botón que no hace nada, un total que no se actualiza, una columna que no sale. En una app RAP hay cinco capas (tabla, vista, comportamiento, proyección y anotaciones) y el primer paso para arreglar algo es saber **en cuál** está el problema. En esta unidad vemos cómo localizarlo y cómo usar el **depurador** de VS Code.

## ¿En qué capa está el error?

| Síntoma | Capa probable | Qué mirar |
|---|---|---|
| No activa una vista | CDS | La pestaña **Problemas** y el orden de activación |
| El Data Preview (SQL Notebook) sale vacío o con valores raros | Datos o vista | La tabla tiene filas; los `join` y los `coalesce` |
| Un valor sale bien en el Data Preview y mal en la app | Proyección o anotaciones | El campo está en la proyección; el `@UI` apunta al nombre correcto |
| Un campo calculado no se actualiza al editar | Comportamiento | El disparador de la determination |
| Se guarda algo que no debería | Comportamiento | La validation está en la BDEF **y** en `Prepare` |
| Un botón no aparece | Anotaciones o proyección | `@UI` con `#FOR_ACTION`; `use action` en la BDEF de proyección |
| Un botón aparece, pero gris | Comportamiento | El *feature control* |
| La app no muestra un error que el test sí ve | Comportamiento | `reported` con `%element` y `%state_area` |

Una regla útil: **primero el Data Preview, después EML, después la app**. Si la vista calcula bien y el test de EML pasa, el error está en la proyección o en las anotaciones.

## El depurador

1. Abre la clase de comportamiento y haz **clic en el margen izquierdo** de una línea dentro del método que quieres ver (por ejemplo, `recalcularImportes` en el taller), o pon el cursor en la línea y pulsa **F9**. Aparece un punto rojo: un *breakpoint*.
2. En la app, haz lo que dispara ese método (cambiar la cantidad de una partida).
3. VS Code se detiene en el *breakpoint* y abre la vista **Ejecución y depuración** (*Run and Debug*).
4. Avanza con **F10** (línea a línea), **F11** (entra en el método que se llama) y **Shift+F11** (sale del método actual). **F5** continúa hasta el siguiente *breakpoint*. Los mismos botones están en la barra flotante de arriba.
5. En la sección **Variables** ves el contenido de `keys`, de `lt_partidas`… Despliega una tabla para verla entera.

> Un *breakpoint* solo se detiene si la app se ejecuta con **el mismo usuario** con el que has iniciado sesión en VS Code. Si no salta, mira en la sección *Breakpoints* que está activo y que no hay otro que lo tape.

Con un clic derecho en el margen también se puede poner un *breakpoint* condicional (por ejemplo, que solo pare si `lv_neto > 1000`) o, mientras está detenido, cambiar el valor de una variable para probar otro camino sin tocar el código. Los atajos, con su equivalente en Eclipse, están en la [chuleta](./F_vscode.md#depurar).

## Tests como red de seguridad

Antes de cambiar algo para corregir un error de la app, **escribe un test que lo reproduzca**. Si el test falla, has encontrado el error; cuando lo arregles, el test pasará y te protegerá de que vuelva. Es lo que hicieron en el Odoo original con los tests de regresión de §7.

## Ejercicios

1. **Depura una determination.**
    - **Dónde:** el método `recalcularTotales` de `lhc_presupuesto` (3.3).
    - **Qué haces:** pon un *breakpoint* en la primera línea del método (clic en el margen o **F9**). En la vista previa de `Presupuesto`, abre `PREP0001`, pulsa *Editar* y cambia las unidades de la línea a 12. VS Code se detiene: avanza línea a línea con **F10**.
    - **Comprueba:** en *Variables*, `lt_lineas` tiene la línea con 12 uds y, al pasar por el cálculo, la base sale **1200**. Pulsa **F5** para continuar: la app muestra el total nuevo, 1452. Descarta el borrador.

2. **Depura una validation.**
    - **Dónde:** la validation de las horas de la línea de parte (3.4).
    - **Qué haces:** *breakpoint* en su primera línea; en la vista previa de `ParteTrabajo`, escribe 25 h en una línea y guarda. Sigue con **F10** hasta el `CATCH`.
    - **Comprueba:** en *Variables*, `reported-linea` recibe una fila con tu mensaje, y la app lo muestra junto al campo de las horas.

3. **Cambia un valor.** Repite el ejercicio 1 y, antes de que se escriba el resultado, haz doble clic en el valor de `lv_base` en *Variables* (o clic derecho → *Set Value*) y cámbialo a 2000. Continúa con **F5**. ¿Qué total muestra la app? Descarta el borrador.

4. **El escenario otra vez.** Ejecuta los tests de todo `ZGOR` ([F](./F_vscode.md#tests)). Todos deben seguir en verde; si alguno falla tras el Bloque 4, usa la tabla de arriba para localizar en qué capa está el problema.

5. **Investiga.** Abre la pestaña **ABAP Feeds** del panel inferior, donde salen los errores en tiempo de ejecución (*dumps*). Provoca uno (por ejemplo, con la lectura de la quinta fila de 1.7) y comprueba dónde aparece y qué línea señala.

---

**Siguiente:** [4.5. El servicio como API](./4_5_api.md)
