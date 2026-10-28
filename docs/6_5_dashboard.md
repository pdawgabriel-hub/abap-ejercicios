---
title: "6.5. Dashboard y calendario"
parent: "6. Ampliaciones del proyecto"
nav_order: 5
---

# 6.5. Dashboard y calendario

{% raw %}
> **Zona menos verificada.** Las vistas CDS de esta unidad son estables. Lo que cambia según el sistema es **cómo mostrarlas**: los tipos de app con gráficos (*Analytical List Page*, *Overview Page*) se generan con *Business Application Studio*, que puede no estar disponible en el trial. Con la vista previa del *binding* siempre tendrás listas ordenadas y con colores.

En Odoo, el «Análisis Financiero» es un componente OWL que llama a un método Python, `get_dashboard_data`, que lee movimientos y agrega en memoria (§3.14 del informe). En SAP se hace al revés: los agregados son **vistas CDS**, como las de 2.4, y la interfaz solo las muestra. El calendario unificado (§3.13) es otra vista que une varias tablas.

## Indicadores: vistas de agregados

El taller cuenta sus órdenes por color del semáforo y suma lo pendiente de cobro:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Ordenes por semaforo'
@Metadata.allowExtensions: true
define view entity ZI_TlKpiSemaforo
  as select from ZI_TlOrdenResumen
{
  key Semaforo,
      SemaforoCriticality,
      count( * )                                      as Ordenes,
      cast( sum( SaldoPendiente ) as abap.dec(15,2) ) as Pendiente
}
group by Semaforo, SemaforoCriticality
```

Y el ranking de mecánicos por euros facturados. El periodo («este mes», «este año»…) se filtra desde la app, con la fecha como filtro (`@UI.selectionField`), así que la vista agrupa por mecánico **y día**:

```sql
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

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Calendario de movimientos'
define view entity ZI_TlCalendario
  as select from ztl_prs
{
  key cast( 'presupuesto' as abap.char(12) ) as Tipo,
  key presupuesto_uuid                       as RegistroUUID,
      fecha                                  as Fecha,
      cast( presupuesto_ref as abap.char(60) ) as Titulo
}
union all select from ztl_jor
{
  key cast( 'jornada' as abap.char(12) )     as Tipo,
  key jornada_uuid                           as RegistroUUID,
      dia                                    as Fecha,
      cast( trabajo as abap.char(60) )       as Titulo
}
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

Los bloques del dashboard de Odoo (§3.14) son la especificación:

1. **Bloque 1: salud global.** Crea `ZI_GorKpiSalud` (obras por salud, con su número y lo pendiente de cobro) sobre tu `ZI_GorObraFinanzas`.
2. **Bloque 2: rentabilidad.** Crea la vista para el **top 10 de obras por beneficio** (beneficio real, total y salud de cada obra) y la de coste de mano de obra por obra.
3. **Bloque 3 y cobros.** Crea la vista de **distribución de costes** (proveedores, especialistas y mano de obra en total) y la **lista de cobros pendientes** (obras con debe > 0, ordenada de mayor a menor).
4. **Top 5 trabajadores.** Crea `ZI_GorKpiTrabajadores` con las horas y el coste por trabajador y día, para filtrar por periodo desde la app (Odoo: «Este Mes», «3 Meses», «Este Año», «Todo»).
5. **Evolución mensual.** Crea la vista de ingresos por mes (año y mes de la fecha del ingreso), con dos vistas apiladas. Fíjate en que en Odoo esta parte **ignora** el filtro de periodo (§3.14): en tu app, no le pongas filtro de fecha por defecto.
6. **El calendario.** Crea `ZI_GorCalendario` con las cinco ramas de §3.13: presupuestos, ingresos, partes de trabajo, partes de proveedor y partes de especialista. La clave, tipo + UUID.
7. **El servicio.** Expón todo en `ZUI_GOR_FINANCIERO`, con metadata extensions para que cada vista se lea bien en la vista previa. Comprueba los números con los datos de demo de 2.5.
8. **Investiga.** ¿Qué es una vista CDS con `@Analytics.dataCategory: #CUBE` y para qué serviría aquí? Anota la diferencia con las vistas de esta unidad.

---

**Siguiente:** [7. Cierre del proyecto](bloque_B7.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/6_5_dashboard.md){: .fs-2 }
{% endraw %}
