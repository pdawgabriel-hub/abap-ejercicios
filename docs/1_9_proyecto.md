# 1.9. Proyecto: simulación de una obra

Cerramos el Bloque 1 con dos entregas. La primera es una **simulación**: una clase que recorre en memoria la vida completa de una obra (presupuesto, aprobación, partes, costes externos, cobros) e imprime su ficha financiera después de cada paso. El modelo es la simulación del taller, que verás a continuación. La segunda es el **diseño de las tablas** de todo el ERP, que construiremos en el Bloque 2.

Es un proyecto de integración: no aparece ningún concepto nuevo de importancia, sino que se combina lo de todo el bloque.

| Apartado | Qué aporta al proyecto |
|---|---|
| 1.1 Clases ejecutables | `ZCL_GOR_SIMULACION` es una clase de consola |
| 1.2 Tipos | `ZIF_GOR_TIPOS`; importes en `decfloat34`; plantillas para la ficha |
| 1.3 Flujo y cadenas | Estados de pago, salud, códigos y etiquetas |
| 1.4 Tablas internas | Presupuestos de la obra, líneas de parte, ingresos, quién participa |
| 1.5 ABAP SQL | Las dos primeras tablas, que sirven de modelo para el diseño |
| 1.6 Objetos | `ZCL_GOR_PRESUPUESTO`, `ZCL_GOR_TRABAJADOR`, `ZCL_GOR_PARTE_TRABAJO` |
| 1.7 Excepciones | Una línea de 25 h se rechaza y la simulación sigue |
| 1.8 ABAP Unit | La simulación debe imprimir exactamente lo que dice `ltcl_escenario` |

## El diseño de la simulación

La simulación no guarda nada en la base de datos: usa objetos y los métodos de la clase de reglas. La parte nueva es su **estructura**. En vez de escribir todo en `main`, se reparte en métodos privados, uno por paso del negocio. Así es la del taller, que recorre el caso `ORD0001` ([0.5](./0_5_taller.md)):

```abap
CLASS zcl_tl_simulacion DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    " Lista de importes (los abonos)
    TYPES tt_euros TYPE STANDARD TABLE OF zif_tl_tipos=>ty_euros WITH EMPTY KEY.

    " La salida de la consola, guardada para usarla desde cualquier metodo
    DATA mo_out          TYPE REF TO if_oo_adt_classrun_out.
    " El estado de la orden durante la simulacion
    DATA mt_presupuestos TYPE zif_tl_tipos=>tt_presupuestos.
    DATA mt_tramos       TYPE zif_tl_tipos=>tt_tramos.
    DATA mt_abonos       TYPE tt_euros.
    DATA mv_recambios    TYPE zif_tl_tipos=>ty_euros.
    DATA mv_subcontratas TYPE zif_tl_tipos=>ty_euros.

    " Un metodo por paso del negocio
    METHODS presupuestar.
    METHODS reparar.
    METHODS abonar
      IMPORTING iv_cantidad TYPE zif_tl_tipos=>ty_euros.
    METHODS mostrar_hoja
      IMPORTING iv_titulo TYPE string.
ENDCLASS.
```

- `mo_out` guarda la salida de la consola para que cualquier método pueda escribir, no solo `main`.
- Los atributos `mt_*` y `mv_*` son el **estado de la orden** durante la simulación. Hacen el papel de las tablas que llegan en el Bloque 2.
- `main` solo encadena los pasos, así que se lee como la tabla del caso:

```abap
  METHOD if_oo_adt_classrun~main.
    mo_out = out.                                   " guardar la consola en el atributo
    " main solo encadena los pasos, como la tabla del caso
    presupuestar( ).
    mostrar_hoja( `Paso 2: presupuesto aceptado` ).
    reparar( ).
    mostrar_hoja( `Paso 4: jornada, recambios y subcontrata` ).
    abonar( 300 ).
    mostrar_hoja( `Paso 5: primer abono` ).
    abonar( 305 ).
    mostrar_hoja( `Paso 6: orden liquidada` ).
  ENDMETHOD.
```

La hoja se calcula siempre a partir del estado actual, con `resumen_orden` (1.8):

```abap
  METHOD mostrar_hoja.
    " Calcular la hoja con el estado ACTUAL: nada se guarda, todo se recalcula
    DATA(ls_resumen) = zcl_tl_calculos=>resumen_orden(
      iv_importe      = zcl_tl_calculos=>importe_orden( mt_presupuestos )
      iv_mano_obra    = zcl_tl_calculos=>coste_jornada( mt_tramos )
      iv_recambios    = mv_recambios
      iv_subcontratas = mv_subcontratas
      " Suma de los abonos con REDUCE (1.4)
      iv_abonado      = REDUCE #( INIT lv_suma = CONV zif_tl_tipos=>ty_euros( 0 )
                                  FOR lv_cantidad IN mt_abonos
                                  NEXT lv_suma = lv_suma + lv_cantidad ) ).

    mo_out->write( |--- { iv_titulo } ---| ).
    mo_out->write( |Importe:      { ls_resumen-importe DECIMALS = 2 }| ).
    mo_out->write( |Costes:       { ls_resumen-costes DECIMALS = 2 }| ).
    mo_out->write( |Rendimiento:  { ls_resumen-rendimiento DECIMALS = 2 }| ).
    mo_out->write( |Semaforo:     { ls_resumen-semaforo }| ).
  ENDMETHOD.
```

Y así el paso que añade la mano de obra, con el registro de jornada de 1.6 y el aviso de 1.7:

```abap
  METHOD reparar.
    DATA(lo_jornada) = NEW zcl_tl_jornada( ).
    TRY.                                            " add_tramo puede lanzar ZCX_TL_AVISO (1.7)
        lo_jornada->add_tramo( io_mecanico = NEW zcl_tl_mecanico( iv_ref = 'MEC0001' ) iv_tiempo = 3 ).
        lo_jornada->add_tramo( io_mecanico = NEW zcl_tl_mecanico( iv_ref = 'MEC0002' iv_tarifa = 35 )
                               iv_tiempo   = 2 ).
      CATCH zcx_tl_aviso INTO DATA(lx_aviso).
        mo_out->write( lx_aviso->get_text( ) ).
    ENDTRY.
    " Guardar en el estado de la orden lo que ha pasado en este paso
    mt_tramos       = lo_jornada->tramos( ).
    mv_recambios    = 180.
    mv_subcontratas = 60.
  ENDMETHOD.
```

Cada paso de la simulación trabaja igual: usa los objetos de 1.6, captura con `TRY` los avisos de 1.7 para escribirlos en la consola sin detener la simulación, y guarda el resultado en los atributos de la clase (`mt_tramos`, `mv_recambios`…) para que el paso siguiente lo encuentre. Al final, el método que calcula la ficha solo tiene que leer esos atributos y llamar a `zcl_tl_calculos`.

## El diseño de las tablas

La segunda entrega es un documento: el diseño de **todas** las tablas del ERP, a partir del modelo relacional del informe (§12.2). En 1.5 ya hiciste dos (`zgor_cli` y `zgor_obra`); ahora toca el resto, sobre el papel. En 2.1 las crearemos en el sistema y podrás comparar tu diseño con el definitivo.

**Tabla de tipos** (Odoo → tabla ABAP):

| Odoo | Tabla ABAP | Notas |
|---|---|---|
| `Char` | `abap.char(n)` | Elige `n` según el dato: códigos 8, NIF 12, teléfono 20, nombres 60–80, direcciones 120 |
| `Text` | `abap.char(255)` | Para descripciones; las bitácoras usan `abap.string(0)` |
| `Integer` | `abap.int4` | |
| `Float` / `Monetary` | `abap.dec(15,2)` | Horas `abap.dec(5,2)`, IVA `abap.dec(5,2)`. La moneda es siempre EUR (§12.1); se añade en 6.2 |
| `Date` | `abap.dats` | |
| `Datetime` automático | Los cinco campos `abp_*` de administración | Autor y fecha de las bitácoras salen de ahí |
| `Selection` | `abap.char(15)` | Con los valores en minúscula de Odoo: `aprobado`, `pendiente`… |
| `Boolean` / sí-no | `abap_boolean` | |
| `Many2one` | `<entidad>_uuid : sysuuid_x16` | El UUID del registro padre |
| `One2many` | Nada | Es la FK del hijo vista desde el padre |
| `Many2many` | Tabla puente con dos UUID | Solo las informativas; las calculadas se sacan de los partes (§12.2) |
| `Binary` (adjunto) | `abap.rawstring(0)` + `mimetype` + `nombre_archivo` | Con un tamaño razonable; lo veremos en 3.6 |

**Qué se guarda y qué no.** Cada campo calculado de Odoo cae en uno de estos tres casos:

| Caso | Dónde se calcula | Ejemplos |
|---|---|---|
| Cambia mientras se edita el registro y depende **solo de él** (o de sus hijos) | Se **guarda**, y lo recalcula una *determination* de RAP llamando a `ZCL_GOR_REGLAS` (Bloque 3) | Total de línea, base, cuota y total del presupuesto; coste de línea y totales del parte; días de una falta; total del proveedor |
| Depende de **otros** registros | **No se guarda**: lo calcula una vista CDS al leer (Bloque 2) | Total de la obra, gastos, ingresos, beneficio, debe, estado de pago, salud; horas del trabajador; participantes |
| Se **copia** una vez y no cambia | Se guarda; lo copia una *determination* al elegir el dato de origen | Datos del cliente en el presupuesto; tarifa en la línea del parte |

## Preparación del entorno de trabajo

La clase de la simulación va en `ZGOR_TEST`. El diseño es un fichero Markdown en el repositorio del proyecto, `erp-obras-reformas-sap`: si aún no lo tienes clonado en tu equipo, créalo ahora en GitHub (vacío y público) y clónalo con `git clone`. Al terminar, el proyecto queda así:

```text
ZGOR
├── ZGOR_DDIC   zgor_cli, zgor_obra                                    (1.5)
├── ZGOR_BUS    ZIF_GOR_TIPOS, ZCL_GOR_REGLAS, ZCX_GOR_REGLA,
│               ZCL_GOR_PRESUPUESTO, ZCL_GOR_TRABAJADOR, ZCL_GOR_PARTE_TRABAJO
└── ZGOR_TEST   ZCL_GOR_INICIO, ZCL_GOR_TIPOS_DEMO, ZCL_GOR_SQL_DEMO,
                ZCL_GOR_OO_DEMO, ZCL_GOR_EXC_DEMO,
                ZCL_GOR_SIMULACION                                     ← nueva

erp-obras-reformas-sap/
└── docs/
    ├── diseno.md                                                      ← nuevo
    └── odoo/informe-tecnico.md                                        ← copia del informe
```

## Ejercicios

1. **El esqueleto.**
    - **Dónde:** `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_SIMULACION`, descripción `Simulacion de una obra en memoria`. Ejecutable.
    - **Qué contiene:** la misma estructura que la del taller, con comentarios: atributos para el estado de la obra (presupuestos `tt_presupuestos`, líneas de parte `tt_parte_lineas`, ingresos, coste de proveedores y de especialistas) y cuatro métodos privados: `presupuestar`, `trabajar`, `cobrar` (recibe `iv_importe`) e `imprimir_ficha` (recibe `iv_titulo`). Su `main` recorre los pasos 3, 6, 7 y 8 de §12.7, imprimiendo la ficha después de cada uno. Deja los métodos vacíos.
    - **Comprueba:** activa y ejecuta: salen los cuatro títulos, todavía sin datos.

2. **Presupuestar.**
    - **Dónde:** el método `presupuestar`.
    - **Qué hace:** con `ZCL_GOR_PRESUPUESTO`, una línea de 10 uds a 100 €, aprobada. Guarda el presupuesto en el estado de la obra con su código (`formatear_codigo`), su estado y su total, y escribe la etiqueta del cliente (Juan Pérez López, `CLI0001`, NIF 12345678Z) y el total del presupuesto.
    - **Comprueba:** salen `CLI0001 - Juan Pérez López (12345678Z)` y `1210.00`.

3. **La ficha.**
    - **Dónde:** el método `imprimir_ficha`.
    - **Qué hace:** calcula `kpi_obra` con el estado actual y escribe **todos** sus campos, uno por línea: total, gastos, ingresos, beneficio, debe, margen, porcentaje cobrado (con 1 decimal), estado de pago, salud y estado del gasto.
    - **Comprueba:** la ficha del paso 3 muestra total 1210.00, gastos 0.00 y estado `pendiente`.

4. **Trabajar.**
    - **Dónde:** el método `trabajar`.
    - **Qué hace:** con `ZCL_GOR_PARTE_TRABAJO`, dos trabajadores a 20 €/h con 8 h cada uno, guardando las líneas en el estado de la obra; más 200 € de proveedor y 150 € de especialista. Si se lanza `ZCX_GOR_REGLA`, escribe su texto.
    - **Comprueba:** la ficha del paso 6 muestra gastos 670.00.

5. **Cobrar.**
    - **Dónde:** el método `cobrar`.
    - **Qué hace:** añade el importe a los ingresos.
    - **Comprueba:** ejecuta la simulación completa. Las fichas de los pasos 7 y 8 deben coincidir **una a una** con los valores de tu `ltcl_escenario` (1.8).

6. **Una línea imposible.**
    - **Dónde:** el método `trabajar`, después de las dos líneas buenas.
    - **Qué hace:** intenta añadir una línea de 25 h.
    - **Comprueba:** la simulación escribe el mensaje del error y sigue; el coste del parte sigue siendo 320.

7. **Quién trabajó.** Añade al final de `main` un listado de los participantes de la obra (`participantes`) y de sus horas (`horas_por_trabajador`).
8. **Una obra con pérdidas.** Añade un segundo recorrido con otra obra: presupuesto de 1 línea de 2000 € con IVA 10, aprobado; 60 h de un trabajador a 20 €/h; un proveedor de 1500 €; un cobro de 2200 €. Antes de ejecutar, calcula a mano qué ficha esperas (estado de pago, salud y beneficio) y apúntalo en un comentario. Después comprueba. Para no mezclar estados, vacía los atributos con `CLEAR` antes de empezar la segunda obra.
9. **El diseño de tablas.** Crea `docs/diseno.md` en `erp-obras-reformas-sap` con una sección por tabla. Usa como modelo `zgor_cli` y `zgor_obra` de 1.5 y la tabla de tipos de la sección «El diseño de las tablas». Para cada una: nombre (como mucho 16 caracteres, sin tildes; ver el [Anexo B](./B_nombres.md)), columnas con tipo, clave y relaciones, y en qué caso de «qué se guarda» cae cada campo calculado de Odoo. Las entidades son las diez raíces del informe (Clientes, Trabajadores, Proveedores, Especialistas, Presupuestos, Obras, Ingresos y los tres tipos de parte) más sus tablas hijas: líneas de presupuesto y de parte, faltas, la ficha de gastos y las dos relaciones N:M informativas de los presupuestos. Las tablas satélite (observaciones, incidencias y adjuntos) basta con describirlas una vez, porque todas tienen la misma forma (§2 del informe).
10. **Copia del informe.** Guarda el informe técnico de Odoo en `docs/odoo/informe-tecnico.md` del mismo repositorio: los apuntes citan sus secciones. **El repositorio es público**: antes de subirlo, quita todo lo que identifique a la empresa o a sus clientes (nombre, dominio, base de datos, proveedores contratados, importes y fechas de facturación). En la práctica, la sección 13 (infraestructura y despliegue) entera y cualquier nombre propio del resto. Las secciones que citan los apuntes (3 a 12) no los necesitan. Haz commit y push de los dos ficheros.

## Comprueba tu solución

No hay test automático de la simulación, porque es una salida por consola. Para comprobarla:

- Las fichas de los pasos 7 y 8 deben coincidir con [1_8_ltcl_escenario.abap](materiales/tests/1_8_ltcl_escenario.abap).
- Clic derecho en `ZGOR` → **Run As → ABAP Unit Test**: todos los tests del bloque en verde. Son 34 en `ZCL_GOR_REGLAS`, 3 en `ZCL_GOR_PRESUPUESTO` y 3 en `ZCL_GOR_PARTE_TRABAJO`: **40 en total**.
- Del diseño, lo importante es que cada campo calculado tenga claro su caso. En [2.1](./2_1_tablas.md) verás la versión definitiva: anota las diferencias con la tuya y por qué.

---

**Siguiente:** [2.1. Tablas persistentes en ADT](./2_1_tablas.md)
