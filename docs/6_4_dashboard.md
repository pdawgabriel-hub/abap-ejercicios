# 6.4. Dashboard y calendario

> **Zona menos verificada.** Las vistas CDS de esta unidad son estables. Lo que cambia según el sistema es **cómo mostrarlas**: los tipos de app con gráficos (*Analytical List Page*, *Overview Page*) se generan con *Business Application Studio*, que puede no estar disponible en el trial. Con la vista previa del *binding* siempre tendrás listas ordenadas y con colores.

En Odoo, el «Análisis Financiero» es un componente OWL que llama a un método Python, `get_dashboard_data`, que lee movimientos y agrega en memoria (§3.14 del informe). En SAP se hace al revés: los agregados son **vistas CDS**, como las de 2.4, y la interfaz solo las muestra. El calendario unificado (§3.13) es otra vista que une varias tablas.

## Indicadores: vistas de agregados

El taller cuenta sus órdenes por color del semáforo y suma lo pendiente de cobro:

```cds
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes por semaforo'
@Metadata.allowExtensions: true
// Sobre el resumen de 2.4: una fila por color
define view entity ZI_TlKpiSemaforo
  as select from ZI_TlOrdenResumen
{
  key Semaforo,
      SemaforoCriticality,                     // para pintar el color en la app
      count( * )                                                                     as Ordenes,
      cast( sum( SaldoPendiente ) as abap.dec(15,2) ) as Pendiente
}
group by Semaforo, SemaforoCriticality      // todo lo que no es agregado
```

Y el ranking de mecánicos por euros facturados. El periodo («este mes», «este año»…) se filtra desde la app, con la fecha como filtro (`@UI.selectionField`), así que la vista agrupa por mecánico **y día**:

```cds
// Una fila por mecanico y dia: la app filtra el periodo por fecha
define view entity ZI_TlKpiMecanicos
  as select from ztl_jor_tra as Tramo
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
{
  key Tramo.mecanico_uuid                                as MecanicoUUID,
  key Jornada.dia                                        as Dia,
      cast( sum( Tramo.tiempo ) as abap.dec(9,2) )       as Tiempo,
      cast( sum( Tramo.coste_tramo ) as abap.dec(15,2) ) as Euros
}
group by Tramo.mecanico_uuid, Jornada.dia
```

`group by` solo admite columnas, no expresiones. Para agrupar **por mes** hacen falta dos vistas: una que calcule el mes (`substring( cast( dia as abap.char(8) ), 1, 6 ) as Mes`) y otra encima que agrupe por él, como apilaste `ZI_TlOrdenSumas` y `ZI_TlOrdenResumen` en 2.4.

En la metadata extension, `@UI.presentationVariant` con `sortOrder` en `Euros` descendente y `maxItems` hace el «top N» (4.3).

## El calendario: `union all`

Una vista puede unir los resultados de varios `select`, siempre que todos devuelvan las mismas columnas con los mismos tipos:

```cds
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Calendario de movimientos'
define view entity ZI_TlCalendario
  // Rama 1: los presupuestos
  as select from ztl_prs
{
  // Tipo + UUID: clave unica aunque se junten tablas distintas
  key cast( 'presupuesto' as abap.char(12) ) as Tipo,
  key presupuesto_uuid                       as RegistroUUID,
      fecha                                  as Fecha,
      cast( presupuesto_ref as abap.char(60) ) as Titulo   // mismo tipo en todas las ramas
}
// Rama 2: las jornadas (mismas columnas, mismos tipos)
union all select from ztl_jor
{
  key cast( 'jornada' as abap.char(12) )     as Tipo,
  key jornada_uuid                           as RegistroUUID,
      dia                                    as Fecha,
      cast( trabajo as abap.char(60) )       as Titulo
}
// Rama 3: los abonos
union all select from ztl_abo
{
  key cast( 'abono' as abap.char(12) )       as Tipo,
  key abono_uuid                             as RegistroUUID,
      fecha                                  as Fecha,
      cast( abono_ref as abap.char(60) )     as Titulo
}
```

La clave es **el tipo más el UUID**. Compáralo con la solución de Odoo (§3.13: sumar 100000, 200000… al id de cada origen para que no se repitan): con UUID, la colisión no puede ocurrir.

## Mostrarlo

Expón las vistas de indicadores y el calendario en el servicio financiero (4.2), con sus metadata extensions: listas con `criticality` para los colores, ordenadas, y filtros por fecha. Si tienes *Business Application Studio*, puedes generar una *Overview Page* con tarjetas sobre esas mismas vistas.

## Ejercicios

Los bloques del dashboard de Odoo (§3.14) son la especificación. Todas las vistas van en `ZGOR_CDS`, se crean como en 2.4 (*New → Data Definition*, plantilla *Define View Entity*) y se comprueban leyéndolas desde `ZCL_GOR_SQL_DEMO`, en un bloque `" 6.4 Dashboard`, con los datos de demo de 2.5:

1. **Bloque 1: salud global.** `ZI_GorKpiSalud`, sobre `ZI_GorObraFinanzas`, agrupada por `Salud`: el número de obras (`count( * )`) y la suma de `Debe`. **Comprueba:** `verde` 1 obra, `rojo` 1, `ambar` 2 con 852 € pendientes.
2. **Bloque 2: rentabilidad.** `ZI_GorKpiBeneficio` (código, descripción, beneficio real, total y salud de cada obra; el «top 10» lo hará la app ordenando y limitando) y `ZI_GorKpiManoObra` (coste de mano de obra por obra). **Comprueba:** leyendo con `ORDER BY BeneficioReal DESCENDING UP TO 10 ROWS`, el orden es `OBR0001` (540), `OBR0003` (240), `OBR0004` (0) y `OBR0002` (−380).
3. **Bloque 3 y cobros.** `ZI_GorKpiCostes` (una sola fila con el total de proveedores, de especialistas y de mano de obra) y `ZI_GorCobrosPendientes` (obras con `Debe > 0`). **Comprueba:** proveedores 1700, especialistas 150 y mano de obra 1760; un solo cobro pendiente, `OBR0003` con 852.
4. **Top 5 trabajadores.** `ZI_GorKpiTrabajadores`, con las horas y el coste por trabajador y día (con dos vistas apiladas, como `ZI_TlKpiMecanicos`), para filtrar por periodo desde la app (Odoo: «Este Mes», «3 Meses», «Este Año», «Todo»).
5. **Evolución mensual.** `ZI_GorKpiIngresosMes`: ingresos por mes (año y mes de la fecha del ingreso), con dos vistas apiladas. Fíjate en que en Odoo esta parte **ignora** el filtro de periodo (§3.14): en tu app, no le pongas filtro de fecha por defecto.
6. **El calendario.** `ZI_GorCalendario`, con las cinco ramas de §3.13 unidas con `union all`: presupuestos, ingresos, partes de trabajo, partes de proveedor y partes de especialista. La clave, tipo + UUID. **Comprueba:** `SELECT COUNT( * )` agrupado por tipo da tantas filas de cada uno como registros hay en su tabla.
7. **El servicio.** Expón todo en `ZUI_GOR_FINANCIERO`, con metadata extensions para que cada vista se lea bien en la vista previa. Comprueba los números con los datos de demo de 2.5.
8. **Investiga.** ¿Qué es una vista CDS con `@Analytics.dataCategory: #CUBE` y para qué serviría aquí? Anota la diferencia con las vistas de esta unidad.

---

**Siguiente:** [6.5. Consumir APIs externas](./6_5_apiExterna.md)
