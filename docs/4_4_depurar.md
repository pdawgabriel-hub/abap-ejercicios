# 4.4. Comprobar y depurar

Con las apps funcionando aparecen errores nuevos: un botón que no hace nada, un total que no se actualiza, una columna que no sale. En una app RAP hay cinco capas (tabla, vista, comportamiento, proyección y anotaciones) y el primer paso para arreglar algo es saber **en cuál** está el problema. En esta unidad vemos cómo localizarlo y cómo usar el **depurador** de Eclipse.

## ¿En qué capa está el error?

| Síntoma | Capa probable | Qué mirar |
|---|---|---|
| No activa una vista | CDS | La pestaña *Problems* y el orden de activación |
| El Data Preview sale vacío o con valores raros | Datos o vista | La tabla tiene filas; los `join` y los `coalesce` |
| Un valor sale bien en el Data Preview y mal en la app | Proyección o anotaciones | El campo está en la proyección; el `@UI` apunta al nombre correcto |
| Un campo calculado no se actualiza al editar | Comportamiento | El disparador de la determination |
| Se guarda algo que no debería | Comportamiento | La validation está en la BDEF **y** en `Prepare` |
| Un botón no aparece | Anotaciones o proyección | `@UI` con `#FOR_ACTION`; `use action` en la BDEF de proyección |
| Un botón aparece, pero gris | Comportamiento | El *feature control* |
| La app no muestra un error que el test sí ve | Comportamiento | `reported` con `%element` y `%state_area` |

Una regla útil: **primero el Data Preview, después EML, después la app**. Si la vista calcula bien y el test de EML pasa, el error está en la proyección o en las anotaciones.

## El depurador

1. Abre la clase de comportamiento y haz **doble clic en el margen izquierdo** de una línea dentro del método que quieres ver (por ejemplo, `recalcularImportes` en el taller). Aparece un punto azul: un *breakpoint*.
2. En la app, haz lo que dispara ese método (cambiar la cantidad de una partida).
3. Eclipse se detiene en el *breakpoint* y te propone cambiar a la perspectiva **Debug**. Acepta.
4. Avanza con **F6** (línea a línea), **F5** (entra en el método que se llama) y **F7** (sale del método actual). **F8** continúa hasta el siguiente *breakpoint*.
5. En la vista **Variables** ves el contenido de `keys`, de `lt_partidas`… Doble clic en una tabla para verla entera.

> Un *breakpoint* solo se detiene si la app se ejecuta con **el mismo usuario** con el que estás conectado en Eclipse. Si no salta, mira en la vista *Breakpoints* que está activo y que no hay otro que lo tape.

Con un clic derecho en el margen también se puede poner un *breakpoint* condicional (por ejemplo, que solo pare si `lv_neto > 1000`) o, en la perspectiva Debug, cambiar el valor de una variable para probar otro camino sin tocar el código.

## Tests como red de seguridad

Antes de cambiar algo para corregir un error de la app, **escribe un test que lo reproduzca**. Si el test falla, has encontrado el error; cuando lo arregles, el test pasará y te protegerá de que vuelva. Es lo que hicieron en el Odoo original con los tests de regresión de §7.

## Ejercicios

1. **Depura una determination.**
    - **Dónde:** el método `recalcularTotales` de `lhc_presupuesto` (3.3).
    - **Qué haces:** doble clic en el margen izquierdo de la primera línea del método para poner un *breakpoint*. En la vista previa de `Presupuesto`, abre `PREP0001`, pulsa *Editar* y cambia las unidades de la línea a 12. Eclipse pasa a la perspectiva *Debug*: avanza línea a línea con **F6**.
    - **Comprueba:** en la vista *Variables*, `lt_lineas` tiene la línea con 12 uds y, al pasar por el cálculo, la base sale **1200**. Pulsa **F8** para continuar: la app muestra el total nuevo, 1452. Descarta el borrador.

2. **Depura una validation.**
    - **Dónde:** la validation de las horas de la línea de parte (3.4).
    - **Qué haces:** *breakpoint* en su primera línea; en la vista previa de `ParteTrabajo`, escribe 25 h en una línea y guarda. Sigue con **F6** hasta el `CATCH`.
    - **Comprueba:** en *Variables*, `reported-linea` recibe una fila con tu mensaje, y la app lo muestra junto al campo de las horas.

3. **Cambia un valor.** Repite el ejercicio 1 y, antes de que se escriba el resultado, haz doble clic en el valor de `lv_base` en *Variables* y cámbialo a 2000. Continúa con **F8**. ¿Qué total muestra la app? Descarta el borrador.

4. **El escenario otra vez.** Clic derecho en `ZGOR` → **Run As → ABAP Unit Test**. Todos deben seguir en verde; si alguno falla tras el Bloque 4, usa la tabla de arriba para localizar en qué capa está el problema.

5. **Investiga.** En *Window → Show View → Other…*, busca **ABAP Runtime Errors** (los *dumps*). Provoca uno (por ejemplo, con la lectura de la quinta fila de 1.7) y comprueba dónde aparece y qué línea señala.

---

**Siguiente:** [4.5. El servicio como API](./4_5_api.md)
