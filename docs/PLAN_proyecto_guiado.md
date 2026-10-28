---
title: "Plan: proyecto guiado ZGOR"
nav_exclude: true
---

{% raw %}
# Plan de reorganización: los apuntes como proyecto guiado (ZGOR) · v2

> **Cambios en la v2 (28/10/2026), ya aplicados en los apuntes.** (1) La teoría vuelve a explicarse con un **proyecto de ejemplo**, el taller RuedaLibre ([0.5](0_5_taller.html)), con **otros nombres** a propósito; los ejercicios especifican el objeto del ERP (campos, datos y resultado esperado) pero **sin código**, y los tests lo comprueban. Sustituye al patrón «guiado + réplica» de la v1. (2) Se resuelven las dudas de diseño del apartado 6. (3) Los derivados que cambian al editar un registro se **guardan** con *determinations*; solo los que dependen de otros BO se calculan en CDS (apartado 3.3).

**Objetivo:** que los ejercicios de los apuntes construyan, unidad a unidad, el **ERP de Obras y Reformas**: el port del módulo `gestion_bd` (Odoo 18) a RAP / ABAP Cloud, en el paquete `ZGOR`. Así, al terminar el Bloque 5 la aplicación funciona y al terminar el Bloque 7 el repositorio `erp-obras-reformas-sap` está listo como portfolio. El modelo es el REA del profesor (`marcapersonalFP_REA`, 0613 Servidor): cada unidad explica con código completo de un proyecto de ejemplo, los ejercicios son pasos concretos y acumulativos sobre el ERP, y cada bloque se cierra con una unidad de **Proyecto** que integra lo visto.

**Referencia funcional:** el *Informe Técnico — Módulo `gestion_bd`* (septiembre de 2026). En este plan, «§11.2» significa la sección 11.2 de ese informe. Las secciones que se usan son la 11 (reglas de negocio), la 12.2 (modelo relacional), la 12.6 (orden de implementación) y la 12.7 (casos de prueba).

## Decisiones tomadas

| Decisión | Valor |
|---|---|
| Dónde se construye el proyecto guiado | **Directamente en `ZGOR`** (repo `erp-obras-reformas-sap`). `ZEJ` queda como caja de arena para probar ejemplos sueltos |
| Alcance | **Todas las entidades desde el principio**: cada unidad trata las 10 raíces del informe, no solo un núcleo |
| Método | Primero este plan; después se reescribe unidad a unidad, revisando cada una antes de pasar a la siguiente |
| Nombre | **ERP de Obras y Reformas**. Repo `erp-obras-reformas-sap`; el paquete sigue siendo `ZGOR`. El módulo de Odoo conserva su nombre, `gestion_bd` |
| IDE | **Eclipse con ADT** en los apuntes, en Linux; anexo F con las equivalencias en VS Code, que se escribe después de probarlo en el trial |
| Ejemplos de la teoría | **Taller RuedaLibre** (prefijo `ZTL`, paquete `ZEJ`), con todas las funcionalidades de `gestion_bd` y nombres distintos (titular, mecánico, orden de reparación, hoja de costes, abono…). Los ejercicios no traen código; los tests de `docs/materiales/tests/` los comprueban |
| Draft | En **todas** las BO |
| Commits | Los hace Gabriel |

## 1. Qué cambia respecto a la versión actual

| Hoy | Después |
|---|---|
| La teoría usa un taller de coches sencillo, los ejercicios usan clases `ZCL_EJ_*` sueltas y los proyectos usan `ZGOR` | Dos proyectos con la misma estructura: el **taller** (ejemplo, con código) y el **ERP** (ejercicios, sin código). Las clases `ZCL_EJ_*` desaparecen |
| Ejercicios abiertos («escribe una validation para…») | Pasos concretos: «crea `X` con estos campos», «añade el método `Y` con esta firma y esta regla del informe», «comprueba que sale `Z`» |
| Algunos ejercicios no siguen el informe (por ejemplo, `cerrarObra` con estado `'C'`, o la validación de fechas en Obra) | Cada regla cita su sección del informe; ver la tabla de correcciones en el apartado 7 |
| El test se pega dentro del `.md` **y** está repetido en `ejercicios/` | Una sola copia en `docs/materiales/tests/`, enlazada desde la unidad, como el `materiales/` del profesor |
| Bloque 7 «Proyecto gestion_bd» con mapa, fases y lógica al final | El mapa y la lógica pasan a ser material de 1.9 y de los anexos; el Bloque 7 queda como **cierre** (README, comprobación final, explicación en 5 minutos) |

## 2. Plantilla de una unidad

Igual que en el REA del profesor:

1. `# n.m. Título`
2. Cita de contexto: «**Bloque n · Título.** Qué llevamos construido y qué añade esta unidad». Solo en la primera unidad del bloque; en las demás, una frase.
3. Teoría con **ejemplos del taller**, con el código completo, por secciones `##`.
4. `## Preparación del entorno de trabajo`: en qué paquete se trabaja y qué objetos deben existir ya, con enlace a la unidad donde se crearon.
5. `## Ejercicios`: lista numerada de pasos acumulativos. Cada paso indica el objeto que se crea o modifica y cómo se comprueba (Data Preview, consola, app o test).
6. `## Comprueba tu solución automáticamente (opcional)`: enlace al test en `materiales/tests/`, cómo se pega (pestaña *Test Classes*), cómo se ejecuta (Ctrl+Shift+F10) y el resultado esperado («N tests en verde»).
7. `**Siguiente:** [n.m+1. …]`

Las unidades de **Proyecto** (n.último) llevan además: una tabla «Apartado → Qué aporta al proyecto», un apartado `## El diseño` y el **árbol de objetos del paquete** al terminar, como en 3.8 del profesor.

**Ejemplo y ejercicio no coinciden nunca.** La teoría muestra la pieza en el taller; el ejercicio pide la pieza equivalente del ERP con su especificación (objeto, campos y tipos, firma de los métodos, regla del informe, datos y resultado esperado). Como los nombres y algunos detalles de las reglas son distintos (tramos de 10 h frente a líneas de 24 h, porcentaje desde lo abonado frente a desde lo pendiente…), no basta con renombrar: hay que entender la pieza. Con todas las entidades, los ejercicios usan tablas de especificación para no repetir diez veces el mismo enunciado. La columna «Guiada» del apartado 4 queda como referencia de la v1.

## 3. Modelo RAP de ZGOR

### 3.1. Paquetes

`ZGOR` con `ZGOR_DDIC` (tablas y estructuras), `ZGOR_CDS` (vistas interface, de consulta y de agregados), `ZGOR_BUS` (BDEF, clases de comportamiento y la clase de reglas), `ZGOR_SRV` (proyecciones, metadata extensions y servicios) y `ZGOR_TEST` (escenario de pruebas y datos de demo).

### 3.2. Objetos de negocio (raíces y composiciones)

| BO raíz | Tabla | Hijos (composición) | Equivale en Odoo a |
|---|---|---|---|
| `ZI_GorCliente` | `zgor_cli` | Observación | `gestion.clientes` (§3.1) |
| `ZI_GorTrabajador` | `zgor_trab` | Falta (`zgor_trab_falta`), Observación, Archivo | `gestion.trabajadores` + `gestion.trabajadores.falta` (§3.2, §3.12) |
| `ZI_GorProveedor` | `zgor_prov` | Observación, Archivo | §3.3 |
| `ZI_GorEspecialista` | `zgor_esp` | Observación, Archivo | §3.4 |
| `ZI_GorPresupuesto` | `zgor_presu` | Línea (`zgor_presu_lin`), Proveedor (`zgor_presu_prov`), Especialista (`zgor_presu_esp`), Observación, Incidencia, Archivo | §3.6 |
| `ZI_GorObra` | `zgor_obra` | **Gasto** (`zgor_gasto`, `[0..1]`) → Archivo; Observación, Incidencia, Archivo | §3.5 + §3.7 |
| `ZI_GorIngreso` | `zgor_ing` | Observación, Archivo | §3.8 |
| `ZI_GorParteTrabajo` | `zgor_pt` | Línea (`zgor_pt_lin`), Incidencia | §3.9 |
| `ZI_GorParteEsp` | `zgor_pe` | Incidencia, Archivo | §3.10 |
| `ZI_GorParteProv` | `zgor_pp` | Incidencia, Archivo | §3.11 |

Fuera de las BO quedan solo vistas de lectura: `ZI_GorCalendario` (§3.13, `UNION ALL`), las vistas de KPI del dashboard (§3.14) y las de participantes de cada obra (`ZI_GorObraTrabajador`, `ZI_GorObraProveedor` y `ZI_GorObraEspecialista`, con `DISTINCT` sobre los partes, §12.2).

**Tablas satélite** (§2 del informe): una por entidad (`zgor_<ent>_obs`, `_inc`, `_arc`). Todas incluyen una estructura común (`zgor_s_bitacora` o `zgor_s_archivo`) para no repetir campos. El autor y la fecha se rellenan solos con `@Semantics.user.createdBy` y `@Semantics.systemDateTime.createdAt`. En total salen unas **37 tablas**, más las de *draft* si se usa (ver el apartado 6).

### 3.3. Dónde se calcula cada cosa

El informe recomienda **calcular al leer** (§12.3), y en RAP eso es lo natural: el cálculo se hace en la CDS y no hay cadena de recálculo que mantener (§11.3).

| Tipo de dato | Dónde | Ejemplos |
|---|---|---|
| Derivado que cambia mientras se edita el registro | **Se guarda**: *determination on modify* que llama a `ZCL_GOR_REGLAS` (con *draft*, un campo calculado en CDS no se refresca durante la edición) | `total_linea`, base, cuota y total del presupuesto, `coste_subtotal` y totales del parte, `falta.dias`, `proveedor.total` |
| Derivado que depende de **otros** BO | **CDS**: vistas de agregados (`ZI_GorObraTotal`, `ZI_GorObraImportes`, `ZI_GorObraFinanzas`, `ZI_GorTrabAcum`) | `obra.total`, horas y coste MOO, gastos, ingresos, `beneficio_real`, `debe`, `margen_proyectado`, `porcentaje_cobrado`, `estado_pago`, `salud_obra`, acumulados del trabajador, participantes |
| Congelado (se copia una vez, §11.5 puntos 3 y 4) | **Determination *on modify*** | Datos del cliente en el presupuesto; `coste_hora` en la línea del parte |
| Código visible (§10) | **Determination *on save*** (ver 3.7) | `CLI0001`, `TRB0001`, `PROV0001`, `ESP0001`, `PREP0001`, `OBR0001`, `GAS0001`, `ING0001` |
| Validaciones (§11.4) | **Validations**, que llaman a `ZCL_GOR_REGLAS` (creada en el Bloque 1) | IVA 0..100, horas 0..24, importe > 0, fechas, mismo cliente |
| Ciclo de vida (§11.5 puntos 5 y 12) | Determination y composición | La ficha de Gasto se crea al crear la obra y se borra con ella por la composición |

Ventaja para el portfolio: los errores de recálculo que el informe documenta (el trabajador que seguía sumando horas de partes borrados, §7) **no pueden existir** si el dato se calcula al leer. Merece un párrafo en el README.

## 4. Qué construye cada unidad

La columna «Guiada» indica la entidad con código completo; el resto se hace como réplica. «Test» indica el fichero de `materiales/tests/`.

### Bloque 0. Entorno y fundamentos

| Unidad | Se construye | Test |
|---|---|---|
| 0.1 Instalación | Eclipse con ADT, trial y booster; paquete `ZEJ` de pruebas | — |
| 0.2 Introducción | Se presenta el proyecto: el ciclo de negocio (§1 del informe) y qué tendremos al final de cada bloque | — |

### Bloque 1. Fundamentos del lenguaje: las reglas de negocio en ABAP

Todo el bloque construye **`ZCL_GOR_REGLAS`**: las fórmulas de §11.2 y las validaciones de §11.4 como métodos estáticos sin base de datos. En el Bloque 3 las validations la reutilizan, así que no es trabajo perdido. Cada unidad añade métodos y una clase de test local.

| Unidad | Se construye | Guiada | Test |
|---|---|---|---|
| 1.1 Clases ejecutables | Paquetes `ZGOR` y `ZGOR_*`; `ZCL_GOR_INICIO` (`if_oo_adt_classrun`) que lista las 10 entidades y sus prefijos de código | — | — |
| 1.2 Tipos | `ZIF_GOR_TIPOS`: tipos de importe, código, estado y una estructura por entidad. En `ZCL_GOR_REGLAS`: `total_linea`, `cuota_iva` y `total_presupuesto` con redondeo (§11.2 *Presupuesto*) | Presupuesto | `1_2_ltcl_presupuesto.abap` |
| 1.3 Flujo y cadenas | `estado_pago`, `salud_obra`, `estado_gasto` y `porcentaje_cobrado` acotado (§11.2 *Obra*); `formatear_codigo( 'CLI', 7 )` → `CLI0007`; `coincide_busqueda( )`, la búsqueda por palabras de §11.5.10 | Obra | `1_3_ltcl_estados.abap` |
| 1.4 Tablas internas | Sumas sobre tablas: base del presupuesto, `obra.total` solo con presupuestos aprobados, coste MOO a partir de líneas de parte, participantes distintos y top de trabajadores por horas | Obra | `1_4_ltcl_sumas.abap` |
| 1.5 ABAP SQL | Primeras tablas: `zgor_cli` y `zgor_obra` (para poder unir). `ZCL_GOR_SQL_DEMO`: insertar, leer, agrupar, unir, actualizar y borrar | Cliente | — |
| 1.6 ABAP OO | `ZCL_GOR_PRESUPUESTO` (objeto con líneas: `add_linea`, `base`, `cuota`, `total`) y `ZCL_GOR_PARTE_TRABAJO` (líneas con tarifa congelada, §11.5.3) | Presupuesto | `1_6_ltcl_objetos.abap` |
| 1.7 Excepciones | `ZCX_GOR_REGLA` y `ZCL_GOR_REGLAS=>validar_*` para cada fila de §11.4 que no depende de otra entidad | Línea de parte (0..24 h) | `1_7_ltcl_validaciones.abap` |
| 1.8 ABAP Unit | Qué es un test; se repasan los anteriores y se escribe el **escenario de §12.7, pasos 2 a 8**, sobre `ZCL_GOR_REGLAS` en memoria | — | `1_8_ltcl_escenario.abap` |
| **1.9 Proyecto** | `ZCL_GOR_SIMULACION`: ejecuta en memoria una obra completa (presupuesto, aprobación, partes, ingresos) e imprime sus KPI. Además, el **diseño de tablas** de las 10 raíces en `docs/diseno.md` de `erp-obras-reformas-sap`, usando el mapa de tipos Odoo→ABAP (hoy en 1.9 y 7.1) | Todas | — |

### Bloque 2. Modelo de datos con CDS

| Unidad | Se construye | Guiada | Test |
|---|---|---|---|
| 2.1 Tablas | Las tablas restantes de §3.2, sin satélites: raíces, líneas, faltas y relaciones N:M informativas. Clave UUID, código visible y campos de administración (`created_by`, `last_changed_at`…). Moneda: `abap.curr` con `abap.cuky` | Presupuesto + Línea | — |
| 2.2 CDS View Entities | Una `ZI_Gor*` por tabla, con alias CamelCase | Cliente | — |
| 2.3 Associations y composiciones | Many2one como association (Obra→Cliente, Ingreso→Obra…), composiciones (Presupuesto→Línea, Parte→Línea, Trabajador→Falta, Obra→Gasto) y vistas de participantes | Presupuesto→Línea | — |
| 2.4 Campos calculados | Toda la columna «Derivado» de 3.3: `ZI_GorPresuTotales`, `ZI_GorObraFinanzas` y `ZI_GorTrabAcum`; `estado_pago` y `salud_obra` con `case`; `dias` de la falta | Obra (finanzas) | — |
| **2.5 Proyecto** | `ZCL_GOR_DATOS_DEMO`: port de `hooks.py` (§6) más la obra `OBR0001` con los datos exactos de §12.7. Comprobación: el Data Preview de `ZI_GorObraFinanzas` da los valores del paso 8 (1210 / 540 / 0 / 100 % / verde) | Todas | `2_5_comprobar_cds.abap` (classrun que compara la CDS con lo esperado) |

### Bloque 3. Comportamiento con RAP

| Unidad | Se construye | Guiada | Test |
|---|---|---|---|
| 3.1 Behavior Definition | BDEF *managed* para las 10 raíces y sus hijos de 2.3: `create`, `update`, `delete` y campos de solo lectura (todos los derivados) | Cliente | — |
| 3.2 Clase de implementación | `zbp_i_gor*` vacías que activan; EML básico (`READ` y `MODIFY ENTITIES`) desde un classrun | Cliente | — |
| 3.3 Determinations | Copia de los datos del cliente en el presupuesto (§11.5.4); `coste_hora` congelado en la línea (§11.5.3); **creación del Gasto al crear la Obra** (§11.5.5); fechas por defecto | Presupuesto | `3_3_ltcl_determinations.abap` (EML) |
| 3.4 Validations | Todas las de §11.4, llamando a `ZCL_GOR_REGLAS`: IVA, horas, importes, fechas de **Gasto** y de **Falta**, obligatorios y mismo cliente en presupuesto, ingreso y obra | Línea de parte | `3_4_ltcl_validations.abap` |
| 3.5 Actions | `aprobar` y `desaprobar` en Presupuesto (cambia `obra.total`, §11.5.1); `vincularAObra` en Presupuesto (sustituye al asistente de §3.15, ver el apartado 6); bloqueo del borrado de una obra con ingresos (§11.5.12) | Presupuesto | `3_5_ltcl_actions.abap` |
| 3.6 Composiciones | Comportamiento de los hijos: líneas, faltas, N:M informativas y **satélites** (observaciones, incidencias y archivos con autor y fecha automáticos, §11.5.9) | Presupuesto (líneas + satélites) | — |
| 3.7 Numeración | Los 8 códigos de §10 con determination *on save*: rango de números o máximo + 1 (ver 3.7 actual) | Obra | `3_7_ltcl_codigos.abap` |
| **3.8 Proyecto** | `ZCL_GOR_TEST_ESCENARIO` en `ZGOR_TEST`: **toda la tabla de §12.7** (pasos 1 a 13) con EML contra las BO reales | Todas | `3_8_escenario_12_7.abap` |

### Bloque 4. Servicios y apps Fiori

| Unidad | Se construye | Guiada | Test |
|---|---|---|---|
| 4.1 Proyecciones | `ZC_Gor*` y BDEF de proyección para todas las raíces | Obra | — |
| 4.2 Servicios | `ZUI_GOR_COMERCIAL` (Cliente, Presupuesto, Obra), `ZUI_GOR_FINANCIERO` (Ingreso; Gasto a través de Obra) y `ZUI_GOR_RECURSOS` (Trabajador con Faltas, Proveedor, Especialista y los tres Partes), cada uno con su binding `_O4` | Comercial | — |
| 4.3 Metadata Extensions | Equivalencia con las vistas de §4 del informe: columnas de lista, *facets* como las pestañas de Odoo, cabecera KPI de Obra (*DataPoints*), `criticality` para la salud verde/ámbar/rojo, ayudas de búsqueda y búsqueda por varias palabras (ver el apartado 6) | Obra | — |
| 4.4 Comprobar y depurar | Depurar una validation y una determination desde la app; volver a pasar el test de 3.8 | — | `3_8_escenario_12_7.abap` |
| **4.5 Proyecto** | Las tres apps funcionando. Se repite **a mano**, en la app, el escenario de §12.7, con capturas para el README | Todas | — |

### Bloque 5. Calidad, Git y ciclo de 90 días

| Unidad | Se construye | Test |
|---|---|---|
| 5.1 ATC | ATC sobre `ZGOR` sin errores ni avisos prioritarios | — |
| 5.2 abapGit | `ZGOR` enlazado a `erp-obras-reformas-sap`; primer push de `src/` | — |
| 5.3 Ciclo de 90 días | Recordatorios con `generar_recordatorios.py` | — |
| **5.4 Proyecto** | **Ensayo de restauración**: pull en una instancia limpia (o borrando y recuperando un subpaquete), activar y pasar los tests de 1.8 y 3.8 | Todos en verde |

### Bloque 6. Ampliaciones

| Unidad | Se construye |
|---|---|
| 6.1 Seguridad | Roles *Administrativa* y *Jefe* (§5); Gasto sin crear ni borrar sueltos, también para el administrador técnico |
| 6.2 Moneda y Launchpad | EUR en todos los importes; mosaicos por área en el Launchpad |
| 6.3 PDF | Presupuesto, Parte de Trabajo y Seguimiento de Gastos (§8). **Comprobar antes si el trial tiene el servicio de formularios** (apartado 6) |
| 6.4 Migración | Exportar los CSV de Odoo, prepararlos con `generar_carga.py` y cargarlos con una clase que reutiliza `ZCL_GOR_DATOS_DEMO` |
| 6.5 Dashboard y calendario | `ZI_GorCalendario` (`UNION ALL` de 5 orígenes, §3.13) y las vistas de KPI de `get_dashboard_data` (§3.14): bloques 1 a 3, cobros pendientes, top de trabajadores y evolución mensual |

### Bloque 7. Cierre del proyecto

| Unidad | Contenido |
|---|---|
| 7.1 Comprobación final | Checklist: tests en verde, ATC limpio, escenario de §12.7 en la app y restauración ensayada |
| 7.2 README | README de `erp-obras-reformas-sap`: mapa Odoo→SAP, decisiones (sobre todo «calcular al leer»), capturas y cómo restaurar |
| 7.3 Explicación en 5 minutos | Guion para presentar el proyecto en las prácticas |

El contenido actual de 7.1 (mapa de entidades) pasa a 1.9 y al apartado 3.2 de este plan. El de 7.3 (lógica por entidad) pasa a un anexo **E. Reglas de negocio** que resume §11 del informe con enlaces a la unidad que implementa cada regla. 7.2 (fases) desaparece: lo sustituye este plan.

## 5. Ficheros del repositorio que cambian

| Fichero | Cambio |
|---|---|
| `docs/index.md` | Tabla de bloques con lo que se tiene al final de cada uno (como la tabla RA/horas del profesor) y lista numerada de unidades |
| `docs/bloque_B*.md` | Cita de contexto del bloque y lista de unidades con el «Qué aporta» |
| `docs/1_*.md` a `docs/6_*.md` | Teoría con objetos `ZGOR` en lugar de `ZTL`; ejercicios según el apartado 4 |
| `docs/7_*.md` | Nuevo Bloque 7 de cierre (apartado 4) |
| `docs/E_reglas.md` | Nuevo anexo con las reglas de negocio |
| `docs/F_vscode.md` | Nuevo anexo: el mismo flujo en VS Code (instalación, conexión al trial, atajos equivalentes y qué falta respecto a Eclipse). Se escribe tras probarlo en el trial |
| `docs/B_nombres.md` | Se añaden las tablas satélite, las vistas de agregados, `ZCL_GOR_*`, `ZCX_GOR_*` y `ZIF_GOR_*`. Desaparece `ZCL_EJ_*` |
| `docs/materiales/tests/` | **Nuevo**: un fichero por test de la columna «Test», única copia del código |
| `ejercicios/` | Se elimina cuando sus tests se hayan migrado a `docs/materiales/tests/` |
| `README.md` | Se actualiza la tabla de carpetas |
| `docs/D_planificacion.md` | Semanas por bloque según este plan |

En `erp-obras-reformas-sap` conviene guardar el informe técnico en `docs/odoo/informe-tecnico.md`, porque las unidades citan sus secciones.

## 6. Puntos que hay que verificar en el sistema

**Estado en la v2:** las decisiones de diseño están tomadas y escritas en los apuntes (columna «Opción prevista»; el borrado de la obra, con **guardado adicional** y SQL en lugar de una acción; el *draft*, en **todas** las BO; el gasto, con `internal create`). Lo que sigue pendiente es **comprobarlo en el sistema**; si algo no funciona, se usa la alternativa.

| Antes de | Duda | Opción prevista | Alternativa |
|---|---|---|---|
| 3.1 | ¿*Draft* o no? | Con draft en **todas** las BO | Sin draft |
| 3.3 | Borrar una línea no dispara su determination | `Prepare` con `determination ( always )` | `delete` como disparador, si la versión lo admite |
| 3.8 | Dobles de prueba: ¿bastan los de tablas (`cl_osql_test_environment`) para los tests con EML? | Tablas dobladas; vistas con `cl_cds_test_environment` | Añadir dobles CDS también en los tests de comportamiento |
| 3.3 | Gasto como hijo `[0..1]` de Obra: ¿se puede crear el hijo en una determination *on save* de la raíz? | Sí, con `MODIFY ENTITIES … CREATE BY \_Gasto` | Determination *on modify* al crear la obra |
| 3.5 | Borrar una obra **sin** ingresos tiene que borrar sus partes, que son **otras BO** (§11.5.12) y desvincular los presupuestos | `managed with additional save`: el guardado de la obra borra con SQL sus partes y desvincula sus presupuestos; `delete ( features : instance, precheck )` impide borrar si hay ingresos | Partes como hijos de Obra |
| 3.5 | El asistente de §3.15 modifica el presupuesto desde la obra | Acción en **Presupuesto** (`vincularAObra`, con parámetro de obra y ayuda filtrada por cliente): solo modifica su propia BO | Acción en Obra con EML a otra BO |
| 3.7 | API de rangos de números (`CL_NUMBERRANGE_RUNTIME`) | Rango de números | Máximo + 1, explicado en el README |
| 4.3 | Búsqueda «Juan Pérez» con nombre y apellidos en columnas distintas (§11.5.10) | `@Search.defaultSearchElement` en nombre, apellidos, NIF y teléfono, y comprobar cómo combina las palabras | Campo calculado `NombreCompleto` buscable |
| 4.2 | ¿Se puede tener la lista de Gastos como entrada propia, aunque Gasto sea un hijo? | Vista de consulta de solo lectura con enlace a su obra | Solo dentro de la obra |
| 6.3 | Servicio de formularios PDF en el trial | Verificar en el cockpit | Generar el PDF fuera (fuera del alcance del portfolio) o documentarlo como mejora futura |

## 7. Correcciones de los ejercicios actuales

| Dónde | Hoy | Según el informe |
|---|---|---|
| 3.4, ej. 3 | Validación de fechas en **Obra** | Las fechas `inicio_obra` y `fin_obra` están en **Gastos** (§3.7); también en Faltas (§3.12) |
| 3.8, ej. 3 | Acción `cerrarObra` si el estado no es `'C'` | La obra **no tiene estado editable**: `estado_pago` y `salud_obra` se calculan (§3.5). La acción equivalente es `aprobar` en Presupuesto (§11.5.1) |
| 1.9 | Núcleo de 4 entidades | Pasa a ser el diseño de las 10 raíces |
| 7.2 | Fases 5 y 6 dejan Presupuesto, Ingresos y Partes para después | Con el alcance elegido, todo entra en los bloques 2 a 4 |

## 8. Orden de ejecución

Hecho en la v2 (28/10/2026): todas las unidades de los bloques 0 a 7, los anexos (B a F y Restaurar), `index.md`, las portadas de bloque y 13 ficheros de test en `materiales/tests/`. Se han eliminado `ejercicios/`, el `RESTAURAR.md` de la raíz y las antiguas unidades 7.1 a 7.4.

Pendiente: compilar todo contra un sistema real y corregir lo que falle (empezando por el Bloque 1 y los tests de RAP de 3.3 a 3.8, los menos verificados); probar VS Code para completar el anexo F.
{% endraw %}
