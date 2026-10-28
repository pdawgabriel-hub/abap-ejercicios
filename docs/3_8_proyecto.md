# 3.8. Proyecto: el escenario completo como test

Cerramos el Bloque 3 con la prueba que da sentido a todo el proyecto: el **escenario de §12.7** del informe técnico, ejecutado como test automático contra **tus objetos de negocio reales**. En 1.8 lo probaste en memoria, con la clase de reglas. Ahora cada paso pasa por RAP: se crea con EML, se disparan tus *determinations* y *validations*, se guarda y se lee de las vistas CDS. Si el test pasa, tu ERP se comporta como el `gestion_bd` de Odoo en todo lo que el informe considera crítico.

| Apartado | Qué aporta al proyecto |
|---|---|
| 3.1 y 3.2 BDEF y clases | Los diez BO sobre los que corre el escenario |
| 3.3 Determinations | Pasos 1 (ficha de gastos), 2 (totales y valores por defecto) y 5 (tarifa congelada) |
| 3.4 Validations | Pasos 9 y 13 |
| 3.5 Actions | Paso 3 (aprobar), pasos 11 y 11b (borrar) |
| 3.6 Composiciones | Las líneas y fichas que se crean y se borran con su padre |
| 3.7 Numeración | Los códigos que identifican cada registro en el test |
| 2.4 Vistas de cálculo | Pasos 6, 7 y 8: la ficha financiera |

## Dobles de prueba

Un test no debe depender de los datos que haya en el sistema ni dejar basura. En 3.3 a 3.5 ya has usado **dobles**: tablas falsas que sustituyen a las reales durante el test. Hay dos herramientas, y el escenario necesita las dos:

| Herramienta | Qué sustituye | Para qué |
|---|---|---|
| `cl_osql_test_environment` | **Tablas**: las sentencias ABAP SQL del código probado (incluidas las del framework RAP al guardar) leen y escriben en copias vacías | Probar comportamiento: crear, validar, borrar |
| `cl_cds_test_environment` | **Vistas CDS**: la vista probada lee de copias de sus tablas de debajo | Probar cálculos de las vistas, como los de 2.4 |

Así se monta en el taller el test del resumen de la orden `ORD0001` ([0.5](./0_5_taller.md)):

```abap
CLASS ltcl_resumen DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_cds TYPE REF TO if_cds_test_environment.
    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS paso_5_primer_abono FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_resumen IMPLEMENTATION.
  METHOD class_setup.
    " Dobla la vista y todo lo que hay debajo (vistas y tablas)
    go_cds = cl_cds_test_environment=>create( i_for_entity               = 'ZI_TLORDENRESUMEN'
                                              i_select_base_dependencies = abap_true ).
  ENDMETHOD.

  METHOD class_teardown.
    go_cds->destroy( ).
  ENDMETHOD.

  METHOD setup.
    go_cds->clear_doubles( ).
  ENDMETHOD.

  METHOD paso_5_primer_abono.
    DATA(lv_orden) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_ordenes TYPE STANDARD TABLE OF ztl_orden WITH EMPTY KEY.
    lt_ordenes = VALUE #( ( orden_uuid = lv_orden orden_ref = 'ORD0001' ) ).
    go_cds->insert_test_data( i_data = lt_ordenes ).
    DATA lt_prs TYPE STANDARD TABLE OF ztl_prs WITH EMPTY KEY.
    lt_prs = VALUE #( ( presupuesto_uuid = cl_system_uuid=>create_uuid_x16_static( )
                        orden_uuid = lv_orden situacion = 'aceptado' importe = 605 ) ).
    go_cds->insert_test_data( i_data = lt_prs ).
    " ... tramos (160), albaran (180), factura (60) y abono (300)

    SELECT SINGLE FROM zi_tlordenresumen FIELDS Rendimiento, SaldoPendiente, Semaforo
      WHERE OrdenUUID = @lv_orden INTO @DATA(ls_resumen).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Rendimiento    exp = CONV ztl_prs-importe( -100 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-SaldoPendiente exp = CONV ztl_prs-importe( 305 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_resumen-Semaforo       exp = CONV zi_tlordenresumen-Semaforo( 'rojo' ) ).
  ENDMETHOD.
ENDCLASS.
```

- `i_select_base_dependencies = abap_true` dobla también las vistas y tablas que hay **debajo** (`ZI_TlOrdenSumas`, `ztl_prs`…), y `insert_test_data` rellena sus copias. El código probado ni se entera.
- `clear_doubles( )` en `setup` deja las copias vacías antes de cada test.
- `cl_system_uuid=>create_uuid_x16_static( )` puede lanzar `cx_uuid_error`. En los tests se declara `RAISING cx_static_check` en el método o se captura, como en 3.3.

> **Poco verificado.** La forma exacta de doblar vistas apiladas y de insertar datos en sus tablas de debajo (`i_select_base_dependencies`, `insert_test_data` con o sin `i_named_dependency`) puede variar según la versión. Si tu sistema da un error al crear el entorno, mira la documentación de `CL_CDS_TEST_ENVIRONMENT` con **F2**. Si los tests de comportamiento de 3.3 a 3.5 no ven los datos de los dobles al leer otro BO, puede que tu versión lea a través de las vistas CDS: en ese caso, añade también un entorno CDS para esas vistas.

## El diseño

El escenario va en una clase global **vacía**, `ZCL_GOR_ESCENARIO`, que solo existe para alojar los tests en su pestaña *Test Classes*. Dentro hay dos clases de test, una por herramienta:

| Clase de test | Dobles | Pasos de §12.7 |
|---|---|---|
| `ltcl_comportamiento` | `cl_osql_test_environment` con las tablas (y las de borradores) de los BO que intervienen | 1, 2, 3, 4, 5, 9, 11, 13 |
| `ltcl_finanzas` | `cl_cds_test_environment` sobre `ZI_GorObraFinanzas` | 6, 7, 8 |

El paso 10 (buscar «Juan Pérez») se prueba en la app, en 4.3; el 11b ya lo prueba `3_5_ltcl_borrar_obra`; y el 12 (borrar la ficha de gastos suelta) no se puede ni escribir: tu BDEF no tiene `delete` para el gasto, y un `MODIFY ... DELETE` sobre él no compilaría. Esa es la mejor protección posible.

## Preparación del entorno de trabajo

La clase va en `ZGOR_TEST`. Al terminar, el Bloque 3 está completo:

```
ZGOR
├── ZGOR_DDIC   37 tablas + sus tablas de borradores
├── ZGOR_CDS    vistas interface, de cálculo y de participantes; ZA_GorVincularObra
├── ZGOR_BUS    10 BDEF + 10 clases de comportamiento; ZCL_GOR_REGLAS y compañía
└── ZGOR_TEST   clases de consola; ZCL_GOR_DATOS_DEMO; ZCL_GOR_ESCENARIO   ← nueva
```

## Ejercicios

1. **La clase.** Crea en `ZGOR_TEST` la clase `ZCL_GOR_ESCENARIO`, sin métodos (descripción `Escenario de pruebas del informe, seccion 12.7`).
2. **El comportamiento.** Escribe en su pestaña *Test Classes* la clase `ltcl_comportamiento`, con dobles de las tablas de clientes, trabajadores, proveedores, especialistas, presupuestos (con sus hijos), obras (con su gasto), ingresos y partes, y un método de test por grupo de pasos:

    | Método | Qué hace | Qué comprueba |
    |---|---|---|
    | `paso_01_obra_nueva` | Crea una obra con EML y guarda | Tiene exactamente una ficha de gastos, con código |
    | `paso_02_03_presupuesto` | Presupuesto de 10 × 100 € sin IVA ni estado; después lo aprueba | Base 1000, cuota 210, total 1210, `no_aprobado`; tras aprobar, `aprobado` |
    | `paso_04_05_parte` | Parte con 8 h de dos trabajadores a 20 €/h; sube la tarifa del primero a 25 | Subtotales de 160; tras subir la tarifa, siguen en 160 |
    | `paso_09_validaciones` | Intenta guardar: línea de 25 h, línea de −1 h, parte externo de 0 €, IVA 150, falta con fin anterior al inicio | Los cinco devuelven `FAILED` |
    | `paso_11_obra_con_cobros` | Obra con un ingreso; intenta borrarla | `FAILED`; la obra sigue |
    | `paso_13_otro_cliente` | Presupuesto e ingreso de otro cliente en la obra | Los dos devuelven `FAILED` |

    Los datos maestros (clientes y trabajadores) insértalos directamente en los dobles en `setup`, como en 3.4; lo que prueba cada paso, créalo con EML.
3. **Las finanzas.** Escribe `ltcl_finanzas`, con un entorno CDS sobre `ZI_GorObraFinanzas` como el del taller, y un método por paso: `paso_06_gastos` (gastos 670, sin ingresos, `pendiente`), `paso_07_primer_cobro` y `paso_08_obra_cobrada`, con todos los valores de las filas 7 y 8 de §12.7. Los datos (obra, presupuesto aprobado, líneas de parte, partes externos e ingresos) se insertan en las tablas dobladas.
4. **Que falle por el motivo correcto.** Cambia temporalmente en tu `ZI_GorObraFinanzas` el `BeneficioReal` a `total − gastos` (el error de Odoo que cuenta §11.5, punto 2). Ejecuta: debe fallar `paso_07_primer_cobro`, y el mensaje debe decir que el beneficio es 540 en vez de −170. Deshazlo.
5. **Todo el proyecto.** Clic derecho en `ZGOR` → **Run As → ABAP Unit Test**. Anota cuántos tests tienes en total y cuánto tardan.
6. **Investiga.** Ejecuta los tests con cobertura. ¿Qué métodos de tus clases de comportamiento no recorre ningún test? Elige uno y escribe el test que falta.

## Comprueba tu solución automáticamente

Cuando tus dos clases de test estén en verde, compáralas con [3_8_escenario_12_7.abap](materiales/tests/3_8_escenario_12_7.abap): comprueba los mismos pasos. Si al sustituir las tuyas por las del fichero algo falla, tu ERP tiene un error que tus tests no veían.

Con el Bloque 3 terminado, conviene guardar el trabajo en GitHub. Si no quieres esperar a [5.2](./5_2_abapgit.md), adelanta ahora el primer *push* con abapGit.

---

**Siguiente:** [4.1. Proyecciones](./4_1_proyecciones.md)
