# 2.1. Tablas persistentes en ADT

> **Bloque 2 · Modelo de datos con CDS.** En el Bloque 1 escribiste las reglas del ERP en memoria. Ahora les das un sitio donde vivir: **las tablas** de todas las entidades y, encima de ellas, **las vistas CDS**, que son el modelo de datos sobre el que se construye RAP. Al final del bloque tendrás la base de datos cargada con obras de prueba y una vista que calcula, al leer, la ficha financiera de cada obra. Debe dar los mismos números que tu simulación de 1.9.

En 1.5 creaste `zgor_cli` y `zgor_obra`. En esta unidad crearás **las demás tablas de negocio**, partiendo del diseño que hiciste en [1.9](./1_9_proyecto.md). Las tablas satélite (observaciones, incidencias y adjuntos) esperan a [3.6](./3_6_composiciones.md), cuando sepas cómo se comportan los hijos en RAP.

## El patrón de todas las tablas

Todas siguen las cuatro decisiones de 1.5: `client`, clave UUID, código visible aparte (si la entidad lo tiene) y los cinco campos de administración al final. Así es la del presupuesto del taller:

```sql
@EndUserText.label : 'Taller - Presupuestos'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs {
  key client            : abap.clnt not null;
  key presupuesto_uuid  : sysuuid_x16 not null;
  presupuesto_ref       : abap.char(8);
  fecha                 : abap.dats;
  titular_uuid          : sysuuid_x16;
  orden_uuid            : sysuuid_x16;
  titular_nombre        : abap.char(100);
  titular_documento     : abap.char(12);
  impuesto              : abap.dec(5,2);
  situacion             : abap.char(15);
  neto                  : abap.dec(15,2);
  cuota                 : abap.dec(15,2);
  importe               : abap.dec(15,2);
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
```

Fíjate en tres grupos de campos:

- `titular_nombre` y `titular_documento` son una **copia congelada** del titular. Que existan aunque ya esté `titular_uuid` no es una duplicación por descuido: un presupuesto entregado no debe cambiar si el titular cambia de razón social.
- `neto`, `cuota` e `importe` **se guardan**, porque cambian mientras se edita el presupuesto y solo dependen de sus partidas. Los recalculará una *determination* en el Bloque 3 (es el primer caso de la tabla «qué se guarda» de 1.9).
- `orden_uuid` es **opcional**: un presupuesto puede existir antes que su orden.

Y la tabla de sus partidas, que es **hija**: además de su propia clave, guarda el UUID del padre, y como no puede existir sin él, lo declara `not null`.

```sql
@EndUserText.label : 'Taller - Partidas de presupuesto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_prs_par {
  key client            : abap.clnt not null;
  key partida_uuid      : sysuuid_x16 not null;
  presupuesto_uuid      : sysuuid_x16 not null;
  concepto              : abap.char(120);
  cantidad              : abap.int4;
  precio_unitario       : abap.dec(15,2);
  importe_partida       : abap.dec(15,2);
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
```

## ¿Y los valores por defecto?

En el taller, el impuesto vale 21 si no se indica otro y un presupuesto empieza en `borrador`. Las tablas de ABAP no tienen valores por defecto: los pondrá RAP al crear el registro, con una *determination* ([3.3](./3_3_determinations.md)). En las tablas, solo el tipo.

## ¿Y las claves foráneas?

Las tablas no declaran claves foráneas: `titular_uuid` es una columna más. La relación se declara en las **vistas CDS**, con una *association* ([2.3](./2_3_associations.md)), y lo que en Odoo es `ondelete='restrict'` o `'cascade'` lo controlará el comportamiento RAP. Es la forma habitual en ABAP Cloud: el modelo vive en CDS, no en la base de datos.

## Preparación del entorno de trabajo

Todas las tablas del ERP van en `ZGOR_DDIC`. Para crear cada una: clic derecho en `ZGOR_DDIC` → **New → Other ABAP Repository Object** → *Database Table*, nombre en minúsculas y descripción. Si una tabla no activa, lee el error de la pestaña *Problems*: casi siempre es un punto y coma que falta o un tipo mal escrito.

Al terminar, `ZGOR_DDIC` tendrá 16 tablas:

```
ZGOR_DDIC
├── zgor_cli, zgor_obra                                        (1.5)
├── zgor_trab, zgor_falta                                      ← nuevas
├── zgor_prov, zgor_esp                                        ← nuevas
├── zgor_presu, zgor_presu_lin, zgor_presu_pv, zgor_presu_es   ← nuevas
├── zgor_gasto                                                 ← nueva
├── zgor_ing                                                   ← nueva
└── zgor_pt, zgor_pt_lin, zgor_pe, zgor_pp                     ← nuevas
```

## Ejercicios

Todas las tablas llevan las anotaciones del principio, `key client`, su clave UUID (primera columna de cada fila de las tablas de abajo) y los cinco campos de administración al final. En las tablas de los ejercicios, `char(8)` significa `abap.char(8)`, `dec(15,2)` es `abap.dec(15,2)`, `dats` es `abap.dats` e `int4` es `abap.int4`; `abap_boolean` y `sysuuid_x16` se escriben tal cual. Los UUID de los padres en las tablas hijas, **not null**.

1. **Presupuestos.** Crea las dos tablas del presupuesto (§3.6 del informe):

    | Tabla (descripción) | Columnas, en este orden |
    |---|---|
    | `zgor_presu` (Presupuestos) | `presupuesto_uuid`; `presupuesto_id` char(8); `fecha` dats; `cliente_uuid` y `obra_uuid` sysuuid_x16; `nombre_cliente` char(140), `nif` char(12), `direccion` char(120), `telf` char(20) (la copia del cliente); `iva` dec(5,2); `estado` char(15); `base_imponible`, `cuota_iva` y `total` dec(15,2) |
    | `zgor_presu_lin` (Lineas de presupuesto) | `linea_uuid`; `presupuesto_uuid` sysuuid_x16 **not null**; `descripcion` char(255); `uds` int4; `precio` dec(15,2); `total_linea` dec(15,2) |

    Compáralas con tu `diseno.md` de 1.9 y anota las diferencias.

2. **El resto de tablas.** Crea las doce restantes:

    | Tabla (descripción) | Columnas, en este orden |
    |---|---|
    | `zgor_trab` (Trabajadores, §3.2) | `trabajador_uuid`; `trabajador_id` char(8); `tipo` char(40); `nombre` char(60); `apellido` char(80); `telf` char(20); `coste_hora_estandar` dec(15,2) |
    | `zgor_falta` (Faltas de trabajador, §3.12) | `falta_uuid`; `trabajador_uuid` sysuuid_x16 **not null**; `fecha_inicio`, `fecha_fin` dats; `tipo` char(15); `motivo` char(255); `dias` int4 |
    | `zgor_prov` (Proveedores, §3.3) | `proveedor_uuid`; `proveedor_id` char(8); `nombre` char(80); `direccion` char(120); `telf` char(20); `correo` char(80); `tipo` char(40); `ref` char(30); `documento` char(20); `num_documento` char(30); `base` dec(15,2); `iva` dec(5,2); `total` dec(15,2) |
    | `zgor_esp` (Especialistas, §3.4) | `especialista_uuid`; `especialista_id` char(8); `tipo` char(40); `ref` char(30); `comunicacion_parte` char(255); `nombre` char(80); `observaciones` char(255); `telf` char(20); `correo` char(80); `importe` dec(15,2) |
    | `zgor_presu_pv` (Proveedores del presupuesto) | `presu_prov_uuid`; `presupuesto_uuid` **not null**; `proveedor_uuid` |
    | `zgor_presu_es` (Especialistas del presupuesto) | `presu_esp_uuid`; `presupuesto_uuid` **not null**; `especialista_uuid` |
    | `zgor_gasto` (Ficha de gastos de la obra, §3.7) | `gasto_uuid`; `obra_uuid` **not null**; `gasto_id` char(8); `presupuesto_uuid`; `direccion_obra` char(120); `inicio_obra`, `fin_obra`, `solicitud_obra` dats; `mandante`, `gestion_licencia`, `pago_icio` abap_boolean |
    | `zgor_ing` (Ingresos, §3.8) | `ingreso_uuid`; `ingreso_id` char(8); `obra_uuid`; `cliente_uuid`; `nombre_obra` char(255); `tipo` char(30); `fecha` dats; `documento` char(20); `num_documento` char(30); `importe` dec(15,2) |
    | `zgor_pt` (Partes de trabajo, §3.9) | `parte_uuid`; `fecha` dats; `descripcion` char(255); `obra_uuid`; `horas_totales` dec(7,2); `coste_total` dec(15,2) |
    | `zgor_pt_lin` (Lineas de parte de trabajo) | `linea_uuid`; `parte_uuid` **not null**; `trabajador_uuid`; `horas` dec(5,2); `coste_hora` dec(15,2); `coste_subtotal` dec(15,2) |
    | `zgor_pe` (Partes de especialista, §3.10) | `parte_uuid`; `obra_uuid`; `especialista_uuid`; `fecha` dats; `descripcion` char(255); `documento` char(30); `importe` dec(15,2); `estado_pago` char(15) |
    | `zgor_pp` (Partes de proveedor, §3.11) | Igual que `zgor_pe`, con `proveedor_uuid` en lugar de `especialista_uuid` |

    Los UUID sin tipo indicado son `sysuuid_x16`.

3. **Lo que no está.** Repasa la tabla de «qué se guarda» de 1.9 y explica en `diseno.md`, con una frase cada uno, por qué **no** hay columna para el total de la obra, el `debe` de un ingreso, las horas acumuladas de un trabajador ni la lista de trabajadores de una obra. Y por qué **sí** la hay para `dias` (falta), `total` (proveedor), `horas_totales` y `coste_total` (parte) y `coste_subtotal` (línea).
4. **Comprueba los nombres.** Pulsa **Ctrl+Shift+A** y escribe `zgor_`: deben salir las 16. En el Bloque 3, cada tabla tendrá una gemela para los borradores (*draft*) con `_d` al final, y el nombre completo sigue sin poder pasar de 16 caracteres. ¿Por qué crees que la tabla de faltas se llama `zgor_falta` y no `zgor_trab_falta`?
5. **Investiga.** En el Data Preview de `zgor_presu` (todavía vacía) pulsa **Add filter** y mira qué operadores ofrece para `fecha` y para `estado`. Anota cuál usarías para ver los presupuestos de 2026.

En esta unidad no hay test: el sistema comprueba la sintaxis al activar. Los datos llegan en [2.5](./2_5_proyecto.md).

---

**Siguiente:** [2.2. CDS View Entities](./2_2_cds.md)
