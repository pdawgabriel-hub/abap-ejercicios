# 1.8. Pruebas con ABAP Unit

Desde 1.2 has pegado tests sin escribirlos. En esta unidad aprendemos a **escribirlos**. El ejemplo es el test del caso de la `ORD0001` del taller ([0.5](./0_5_taller.md)); tú escribirás la prueba más importante de tu proyecto: el **escenario de §12.7** del informe técnico, la tabla de pasos que cualquier reimplementación del ERP debe superar. En el Odoo original, `tests/test_financiero.py` protege la lógica financiera (§7); en tu ERP lo hará la clase `ltcl_escenario`. Antes, en el taller y en el ERP, hace falta un último método de cálculo que reúna en una sola llamada todos los indicadores.

## Una clase de test

Los tests de ABAP Unit son **clases locales** de la clase que prueban: se escriben en su pestaña **Test Classes** y no existen fuera de ella.

```abap
CLASS ltcl_presupuesto DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS neto_de_dos_partidas FOR TESTING.
ENDCLASS.

CLASS ltcl_presupuesto IMPLEMENTATION.
  METHOD setup.
    " Se ejecuta antes de CADA test
  ENDMETHOD.

  METHOD neto_de_dos_partidas.
    " Preparar: paso 1 del caso ORD0001
    DATA(lt_partidas) = VALUE zif_tl_tipos=>tt_partidas(
      ( concepto = `Diagnosis` cantidad = 4 precio_unitario = 45 )
      ( concepto = `Embrague`  cantidad = 1 precio_unitario = 320 ) ).
    " Ejecutar
    DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( lt_partidas ).
    " Comprobar
    cl_abap_unit_assert=>assert_equals( act = lv_neto exp = CONV decfloat34( '500' ) ).
  ENDMETHOD.
ENDCLASS.
```

- **`FOR TESTING`** en la clase y en cada método de test. Los métodos sin `FOR TESTING` (como `setup`) son auxiliares.
- **`DURATION SHORT`**: el test debe tardar menos de un minuto. **`RISK LEVEL HARMLESS`**: no cambia nada persistente. Son los valores de todos nuestros tests (también en el Bloque 3, aunque usen tablas, gracias a los *dobles de prueba*).
- **Preparar, ejecutar, comprobar** (*given, when, then*): cada test sigue esas tres fases. El nombre del método dice **qué comportamiento** comprueba, no qué método llama: `tarifa_congelada` es mejor nombre que `test_add_tramo`.

## Métodos especiales

| Método | Cuándo se ejecuta | Para qué |
|---|---|---|
| `setup` | Antes de cada test | Crear los datos comunes (como el `setUp()` de los tests de Odoo) |
| `teardown` | Después de cada test | Limpiar |
| `class_setup` / `class_teardown` (estáticos) | Una vez, antes y después de todos los tests de la clase | Preparación costosa, como los dobles de base de datos del Bloque 3 |

Cada test debe poder ejecutarse **solo y en cualquier orden**: no dependas de lo que dejó otro test. Para eso está `setup`.

## Comprobaciones

| Método de `cl_abap_unit_assert` | Comprueba |
|---|---|
| `assert_equals( act = exp = )` | Que el valor obtenido (`act`) es el esperado (`exp`) |
| `assert_differs( act = exp = )` | Que son distintos |
| `assert_true( act = )`, `assert_false( act = )` | Un `abap_bool` |
| `assert_initial( act = )`, `assert_not_initial( act = )` | Que está vacío, o que no lo está |
| `assert_bound( act = )` | Que una referencia apunta a un objeto |
| `fail( msg = )` | Falla siempre. Se usa tras una llamada que **debía** lanzar una excepción (lo viste en 1.7) |

Todas aceptan `msg = '...'`, el texto que se muestra si fallan. Úsalo cuando el error no se entienda solo con los valores.

**Cuidado con los tipos en `assert_equals`.** `act` y `exp` deben ser del mismo tipo, o comparables. Por eso escribimos `exp = CONV decfloat34( '500' )` y no `exp = 500`: el entero se compararía con un `decfloat34` y, aunque aquí funcionaría, en otros casos el test falla con un mensaje de tipos difícil de entender.

## Ejecutar y leer los resultados

- **Ctrl+Shift+F10**: ejecuta los tests de la clase abierta.
- Clic derecho en un paquete → **Run As → ABAP Unit Test**: los de todo el paquete. Hazlo sobre `ZGOR` antes de cada commit.
- Clic derecho → **Run As → ABAP Unit Test With… → Coverage**: además, marca en verde las líneas del código que los tests han recorrido y en rojo las que no. Sirve para ver qué ramas de un `COND` no tienen test.

En la vista **ABAP Unit** salen los tests en verde o en rojo. Al pulsar un test en rojo, abajo se ven el valor esperado y el obtenido, y la línea del `assert` que falló.

## Escribir el test antes que el código

Para el método de indicadores lo haremos al revés de lo habitual: **primero el test, después el código**. Es lo que se llama *desarrollo guiado por pruebas* (TDD):

1. Escribe un test con lo que esperas; falla, porque el método aún no hace nada.
2. Escribe el código mínimo para que pase.
3. Mejora el código sin miedo, porque el test avisa si rompes algo.

Con una tabla de pasos, el test casi se escribe solo: cada fila es un método y cada columna, un `assert_equals`. Así queda el paso 5 del caso `ORD0001` del taller, escrito **antes** que `resumen_orden`:

```abap
  METHOD paso_5_primer_abono.
    DATA(ls_resumen) = zcl_tl_calculos=>resumen_orden( iv_importe      = 605
                                                       iv_mano_obra    = 160
                                                       iv_recambios    = 180
                                                       iv_subcontratas = 60
                                                       iv_abonado      = 300 ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-costes      exp = CONV decfloat34( '400' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-rendimiento exp = CONV decfloat34( '-100' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-saldo       exp = CONV decfloat34( '305' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-porcentaje  exp = CONV decfloat34( '49.6' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-situacion
                                        exp = zif_tl_tipos=>situacion_cobro-abonado_parcial ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-semaforo exp = zif_tl_tipos=>semaforo-rojo ).
  ENDMETHOD.
```

Y después, el método que lo hace pasar, que solo **combina** los que ya existen:

```abap
  METHOD resumen_orden.
    rs_resumen-importe     = iv_importe.
    rs_resumen-costes      = ajustar_centimos( iv_mano_obra + iv_recambios + iv_subcontratas ).
    rs_resumen-abonado     = ajustar_centimos( iv_abonado ).
    rs_resumen-rendimiento = ajustar_centimos( rs_resumen-abonado - rs_resumen-costes ).
    rs_resumen-saldo       = ajustar_centimos( iv_importe - rs_resumen-abonado ).
    rs_resumen-previsto    = ajustar_centimos( iv_importe - rs_resumen-costes ).
    rs_resumen-porcentaje  = porcentaje_liquidado( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
    rs_resumen-situacion   = situacion_cobro( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
    rs_resumen-semaforo    = semaforo( iv_rendimiento = rs_resumen-rendimiento iv_situacion = rs_resumen-situacion ).
    rs_resumen-estado_hoja = estado_hoja( iv_importe = iv_importe iv_abonado = rs_resumen-abonado ).
  ENDMETHOD.
```

`rs_` es el prefijo de una estructura devuelta (*returning structure*).

## Preparación del entorno de trabajo

Todo en esta unidad amplía objetos que ya existen: `ZIF_GOR_TIPOS`, `ZCL_GOR_REGLAS` y su pestaña de tests.

## Ejercicios

1. **El tipo de los indicadores.** Añade a `ZIF_GOR_TIPOS` la estructura `ty_kpi_obra`, con estos campos en este orden: `total`, `gastos`, `ingresos`, `beneficio`, `debe` y `margen` (`ty_importe`); `porcentaje` (`ty_porcentaje`); y `estado_pago`, `salud` y `estado_gasto` (`ty_estado`).

2. **El método, vacío.** Añade a `ZCL_GOR_REGLAS` el método estático `kpi_obra`, todavía **sin código** dentro, con esta firma:

    | Parámetro | Tipo |
    |---|---|
    | `iv_total` (precio de la obra), `iv_coste_moo`, `iv_coste_prov`, `iv_coste_esp`, `iv_ingresos` | Entrada, `ty_importe` |
    | `rs_kpi` | Devuelto, `ty_kpi_obra` |

3. **El test del paso 7.** Escribe en la pestaña **Test Classes** de `ZCL_GOR_REGLAS`, debajo de las demás, la clase `ltcl_escenario` con un método `paso_7_primer_ingreso`. Datos del escenario hasta ese paso: total 1210, coste de mano de obra 320, proveedores 200, especialistas 150 e ingresos 500. Comprueba los ocho valores de la fila 7 de §12.7: gastos 670, beneficio −170, debe 710, margen 540, porcentaje 41.3, estado de pago `parcial`, salud `rojo` y estado de gasto `proceso`. Ejecútalo: **debe fallar**, porque `kpi_obra` está vacío.
4. **Hazlo pasar.** Implementa `kpi_obra` con las fórmulas de §11.2 (*Gastos* y *Obra: indicadores de cabecera*), **reutilizando** `redondear`, `porcentaje_cobrado`, `estado_pago`, `salud_obra` y `estado_gasto`. Fíjate en que `gastos` se redondea una vez, al final de la suma, y en que el porcentaje se calcula a partir del `debe`. Ejecuta: el test debe pasar.
5. **El paso 8.** Añade el método `paso_8_obra_cobrada` con un segundo ingreso de 710 (ingresos 1210): beneficio 540, debe 0, porcentaje 100, `pagado`, `verde` y `finalizado`. Si falla, el test te dirá qué valor no cuadra.
6. **Pasos 1 a 6 encadenados.** Añade `pasos_2_a_6_hasta_los_gastos`, que construye los datos **con los métodos de las unidades anteriores** en lugar de escribir los totales a mano: el total con `base_imponible` + `total_presupuesto` + `total_obra` (con el presupuesto primero no aprobado, total 0, y después aprobado, 1210); el coste de mano de obra con `coste_parte` sobre dos líneas de 8 h a 20 €/h; y los gastos con `kpi_obra` sin ingresos. Comprueba los valores de los pasos 2, 3, 4 y 6.
7. **La cobertura.** Ejecuta los tests de `ZCL_GOR_REGLAS` con cobertura (clic derecho → **Run As → ABAP Unit Test With… → Coverage**). ¿Queda alguna línea en rojo? Si queda, escribe el test que falta.
8. **Investiga.** Rompe a propósito una regla: cambia en `salud_obra` el orden de las dos primeras condiciones. ¿Qué tests fallan? Lee el mensaje de cada uno y deshaz el cambio. Anota en un comentario de `ltcl_escenario` qué error del informe (§11.5, punto 2) protege el test del paso 7.

## Comprueba tu solución automáticamente (opcional)

Cuando tu `ltcl_escenario` esté en verde, compáralo con [1_8_ltcl_escenario.abap](materiales/tests/1_8_ltcl_escenario.abap), que comprueba lo mismo. Si al sustituir el tuyo por el del fichero algo falla, tu `kpi_obra` tiene un error que tu test no veía. No pegues los dos a la vez: tendrías dos clases con el mismo nombre. Con todo el bloque hecho, `ZCL_GOR_REGLAS` debe tener **34 tests en verde** (31 + 3).

---

**Siguiente:** [1.9. Proyecto: simulación de una obra](./1_9_proyecto.md)
