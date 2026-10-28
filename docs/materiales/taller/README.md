# Taller RuedaLibre: el proyecto de ejemplo completo

Aquí está **completo** el código del proyecto que usa la teoría: cada tabla, vista, comportamiento, proyección, servicio y clase, entero y comentado. En las unidades solo se muestra la parte que se explica; aquí puedes consultar cada objeto mientras haces los ejercicios del ERP.

No hace falta crearlo en tu sistema para seguir el curso. Si quieres verlo funcionar, al final se explica cómo importarlo con abapGit.

## Estructura

El taller está organizado como un proyecto real de ABAP Cloud: un paquete principal, `ZTL`, con un subpaquete por capa, y los fuentes en el formato de **abapGit** (el mismo que tendrá tu repositorio `erp-obras-reformas-sap` en 5.2).

```text
taller/
├── README.md            esta guia
├── abaplint.json        configuracion de la comprobacion automatica
├── tablas/              las tablas en DDL, tal como se escriben en Eclipse
└── src/                 los objetos en formato abapGit (paquete ZTL)
    ├── ddic/            ZTL_DDIC: tablas, estructuras y tablas de borradores (.tabl.xml)
    ├── cds/             ZTL_CDS:  vistas interface, vistas de calculo y control de acceso
    ├── bus/             ZTL_BUS:  reglas, BDEF y clases de comportamiento
    ├── srv/             ZTL_SRV:  proyecciones, metadata extensions y servicios
    └── test/            ZTL_TEST: clases de consola, datos de demo y tests del escenario
```

En `src/`, cada objeto es un fichero de código y un `.xml` con su nombre y su descripción:

| Fichero | Objeto | En Eclipse |
|---|---|---|
| `.clas.abap` | Clase | La pestaña principal |
| `.clas.locals_imp.abap` | Clase | La pestaña **Local Types** (clases de comportamiento) |
| `.clas.testclasses.abap` | Clase | La pestaña **Test Classes** |
| `.intf.abap` | Interfaz | |
| `.ddls.asddls` | Vista CDS (*Data Definition*) | |
| `.bdef.asbdef` | *Behavior Definition* | |
| `.ddlx.asddlxs` | *Metadata Extension* | |
| `.srvd.srvdsrv` | *Service Definition* | |
| `.dcls.asdcls` | *Access Control* | |
| `.tabl.xml` | Tabla | Generado desde `tablas/*.tabl.ddl` |

Cada objeto está en su **estado final**. Por ejemplo, la BDEF del presupuesto ya tiene las validations de 3.4 y las acciones de 3.5, aunque en 3.1 se explique sin ellas. Los comentarios indican en qué unidad aparece cada parte.

## Qué hay, por unidad

| Unidad | Objetos |
|---|---|
| 1.1 | [zcl_tl_bienvenida](./src/test/zcl_tl_bienvenida.clas.abap) |
| 1.2 a 1.4 | [zif_tl_tipos](./src/bus/zif_tl_tipos.intf.abap), [zcl_tl_calculos](./src/bus/zcl_tl_calculos.clas.abap); los ejemplos, ejecutables, en [zcl_tl_demo_lenguaje](./src/test/zcl_tl_demo_lenguaje.clas.abap) |
| 1.5 | Tablas [ztl_tit](./tablas/ztl_tit.tabl.ddl) y [ztl_orden](./tablas/ztl_orden.tabl.ddl); [zcl_tl_sql_demo](./src/test/zcl_tl_sql_demo.clas.abap) |
| 1.6 | [zcl_tl_mecanico](./src/bus/zcl_tl_mecanico.clas.abap), [zcl_tl_jornada](./src/bus/zcl_tl_jornada.clas.abap), [zcl_tl_presupuesto](./src/bus/zcl_tl_presupuesto.clas.abap) |
| 1.7 | [zcx_tl_aviso](./src/bus/zcx_tl_aviso.clas.abap) y los métodos `comprobar_*` de `zcl_tl_calculos` |
| 1.8 | Tests de [zcl_tl_calculos](./src/bus/zcl_tl_calculos.clas.testclasses.abap) y de [zcl_tl_jornada](./src/bus/zcl_tl_jornada.clas.testclasses.abap) |
| 1.9 | [zcl_tl_simulacion](./src/test/zcl_tl_simulacion.clas.abap) |
| 2.1 | Las 21 tablas, 2 estructuras y 2 tablas de 6.x en [tablas/](./tablas/) (las `_d` son las de borradores de 3.1) |
| 2.2 y 2.3 | Las 21 interface views `zi_tl*` de [src/cds/](./src/cds/), con sus relaciones; [zi_tlordenmecanico](./src/cds/zi_tlordenmecanico.ddls.asddls) |
| 2.4 | [zi_tlordenimporte](./src/cds/zi_tlordenimporte.ddls.asddls), [zi_tlordenmanoobra](./src/cds/zi_tlordenmanoobra.ddls.asddls), [zi_tlordenrecambios](./src/cds/zi_tlordenrecambios.ddls.asddls), [zi_tlordensubcontr](./src/cds/zi_tlordensubcontr.ddls.asddls), [zi_tlordenabonado](./src/cds/zi_tlordenabonado.ddls.asddls), [zi_tlordensumas](./src/cds/zi_tlordensumas.ddls.asddls), [zi_tlordenresumen](./src/cds/zi_tlordenresumen.ddls.asddls) |
| 2.5 | [zcl_tl_datos_demo](./src/test/zcl_tl_datos_demo.clas.abap), [zcl_tl_comprobar_cds](./src/test/zcl_tl_comprobar_cds.clas.abap) |
| 3.1 | Las 10 BDEF `zi_tl*.bdef.asbdef` de [src/bus/](./src/bus/); por ejemplo, [la del presupuesto](./src/bus/zi_tlpresupuesto.bdef.asbdef) y [la de la orden](./src/bus/zi_tlorden.bdef.asbdef) |
| 3.2 a 3.7 | Las clases de comportamiento `zbp_i_tl*` (el código, en los `.locals_imp.abap`): [presupuesto](./src/bus/zbp_i_tlpresupuesto.clas.locals_imp.abap), [orden](./src/bus/zbp_i_tlorden.clas.locals_imp.abap), [jornada](./src/bus/zbp_i_tljornada.clas.locals_imp.abap), [titular](./src/bus/zbp_i_tltitular.clas.locals_imp.abap), [mecánico](./src/bus/zbp_i_tlmecanico.clas.locals_imp.abap)…; los ejemplos de EML en [zcl_tl_eml_demo](./src/test/zcl_tl_eml_demo.clas.abap) |
| 3.8 | [zcl_tl_escenario](./src/test/zcl_tl_escenario.clas.testclasses.abap): el caso `ORD0001` como tests, con dobles |
| 4.1 | Las proyecciones `zc_tl*.ddls.asddls` y sus BDEF de proyección `zc_tl*.bdef.asbdef` de [src/srv/](./src/srv/) |
| 4.2 y 4.5 | [ZUI_TL_TALLER](./src/srv/zui_tl_taller.srvd.srvdsrv) y [ZAPI_TL_TALLER](./src/srv/zapi_tl_taller.srvd.srvdsrv) |
| 4.3 | Las metadata extensions `.ddlx.asddlxs`; por ejemplo, [la de la orden](./src/srv/zc_tlorden.ddlx.asddlxs) y [la del resumen](./src/srv/zi_tlordenresumen.ddlx.asddlxs) |
| 6.1 | Permisos en [la orden](./src/bus/zbp_i_tlorden.clas.locals_imp.abap) (`get_global_authorizations` y `get_instance_authorizations`) y el control de acceso [zi_tljornada](./src/cds/zi_tljornada.dcls.asdcls) |
| 6.2 | La moneda del [presupuesto](./src/srv/zc_tlpresupuesto.ddls.asddls) |
| 6.3 | La acción `exportarPresupuesto` del [presupuesto](./src/bus/zbp_i_tlpresupuesto.clas.locals_imp.abap) |
| 6.4 | [zi_tlkpisemaforo](./src/cds/zi_tlkpisemaforo.ddls.asddls), [zi_tlkpimecanicos](./src/cds/zi_tlkpimecanicos.ddls.asddls), [zi_tltramomes](./src/cds/zi_tltramomes.ddls.asddls) y [zi_tlkpimecanicosmes](./src/cds/zi_tlkpimecanicosmes.ddls.asddls), [zi_tlcalendario](./src/cds/zi_tlcalendario.ddls.asddls) |
| 6.5 | [zcl_tl_festivos](./src/bus/zcl_tl_festivos.clas.abap), [zcl_tl_cargar_festivos](./src/test/zcl_tl_cargar_festivos.clas.abap), la validation `avisarFestivo` de la [jornada](./src/bus/zbp_i_tljornada.clas.locals_imp.abap) |
| 6.6 | [zcl_tl_consultar_bp](./src/test/zcl_tl_consultar_bp.clas.abap) |
| 6.7 | El evento en [la BDEF del abono](./src/bus/zi_tlabono.bdef.asbdef) y [su clase](./src/bus/zbp_i_tlabono.clas.locals_imp.abap); el manejador [zcl_tl_escucha_abonos](./src/bus/zcl_tl_escucha_abonos.clas.locals_imp.abap) |

## Cómo se comprueba

Este código no se ha activado en un sistema SAP. Se comprueba de forma automática en cada *push*, con dos herramientas ([.github/workflows/comprobar-taller.yml](https://github.com/pdawgabriel-hub/abap-ejercicios/blob/main/.github/workflows/comprobar-taller.yml)):

1. **abaplint**, el analizador de ABAP de código abierto que usan los proyectos de abapGit. Comprueba la sintaxis de ABAP Cloud y de CDS, los tipos, las llamadas entre clases y las sentencias SQL, contra las definiciones de las APIs liberadas de SAP ([abapedia](https://github.com/abapedia/steampunk-2305-api)).
2. **`herramientas/comprobar_rap.py`**, que comprueba lo que abaplint no ve de RAP: que cada campo de una BDEF, de un `mapping`, de un *side effect* o de una sentencia EML existe en su vista; que cada *determination*, *validation* y acción tiene su método; que las tablas de borradores tienen todos los campos; y que las proyecciones y las metadata extensions usan campos y acciones que existen.

Para repetirlo en tu equipo (necesitas Node.js y Python):

```bash
python3 herramientas/taller_abapgit.py        # regenera los .xml de abapGit
cd docs/materiales/taller
npx @abaplint/cli abaplint.json               # debe terminar con 0 issue(s)
cd ../../..
python3 herramientas/comprobar_rap.py         # debe terminar con 0 errores
```

Lo que **ninguna** de las dos puede asegurar, y hay que confirmar en el sistema:

- Las anotaciones de UI (abaplint comprueba que se pueden leer, no que Fiori las pinte como se espera).
- El comportamiento en ejecución: que las *determinations* se disparen en el orden previsto, los tests con dobles de 3.8 o la exportación con XCO (6.3).
- El manejador de eventos de 6.7: abaplint no conoce aún la sintaxis `FOR ENTITY EVENT`, y su comprobación de sintaxis está desactivada solo para ese fichero.
- La moneda de 6.2: algunas versiones exigen que un importe con moneda sea de tipo `abap.curr`.

Si al activarlo algo falla, es un error de estos apuntes: avisa con el mensaje exacto.

## Importarlo en tu sistema (opcional)

El repositorio `abap-ejercicios` tiene un `.abapgit.xml` que apunta a `docs/materiales/taller/src/`, así que abapGit puede crear el taller entero:

1. En Eclipse, crea el paquete **`ZTL`** en `ZLOCAL` (*New → ABAP Package*), sin subpaquetes: los crea abapGit.
2. Crea el objeto de autorización **`ZTL_TALLER`** con el campo `ACTVT` y las actividades 03, 06 y 70 (*New → Other ABAP Repository Object → Authorization Object*). Lo usan los permisos de 6.1. Si no lo creas, solo fallarán la clase de la orden y el control de acceso de las jornadas.
3. En la vista **abapGit Repositories**, *Link New abapGit Repository* con la URL de `abap-ejercicios`, paquete `ZTL`, y haz **Pull**.
4. Activa todo (clic derecho en `ZTL` → *Activate*). Crea a mano los *bindings* `ZUI_TL_TALLER_O4` (OData V4 - UI) y `ZAPI_TL_TALLER_O4` (OData V4 - Web API), que abapGit no incluye aquí.
5. Ejecuta `ZCL_TL_DATOS_DEMO` y después `ZCL_TL_COMPROBAR_CDS`: debe escribir «0 errores».

En el trial compartido, asegúrate antes de que nadie más usa el prefijo `ZTL` (ejercicio 1 de 1.1).
