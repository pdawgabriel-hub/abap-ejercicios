# 2.4. Campos calculados y Data Preview

En Odoo, la obra tiene once campos `compute`: total, horas, coste de mano de obra, gastos, beneficio, pendiente de cobro, margen, porcentaje cobrado, estado de pago, salud… Y para que estuvieran siempre al día hacía falta una cadena de `@api.depends` (§11.3) que, cuando fallaba, dejaba números atrasados (dos de los tests de §7 son regresiones de eso). En esta unidad vemos cómo calcular indicadores **al leer**, con vistas CDS de agregados, usando el resumen de la orden del taller. Tú harás lo mismo con la ficha financiera de la obra. No hay nada que recalcular, porque no hay nada guardado.

## Expresiones en una vista

Una vista CDS puede devolver, además de columnas, **expresiones**:

```sql
      concat_with_space( nombre, apellidos, 1 )               as NombreCompleto,
      substring( cast( fecha as abap.char(8) ), 1, 4 )        as Ejercicio,
      cast( neto * ( 1 + impuesto / 100 ) as abap.dec(15,2) ) as BrutoCalculado,
      case situacion
        when 'aceptado' then 'Aceptado'
        else 'Pendiente de aceptar'
      end                                                     as SituacionTexto
```

| Expresión | Para qué |
|---|---|
| `cast( x as tipo )` | Fija el tipo del resultado. En las cuentas con decimales, ponlo siempre |
| `case ... when ... then ... else ... end` | Elegir un valor (el `COND` de 1.3) |
| `coalesce( x, valor )` | `x`, o `valor` si `x` es nulo. Imprescindible tras un `left outer join` |
| `division( a, b, decimales )` | División con redondeo a los decimales indicados |
| `round( x, decimales )` | Redondeo |
| `concat( a, b )`, `concat_with_space( a, b, n )`, `substring( x, pos, len )` | Textos |
| `sum( )`, `count( * )`, `max( )`, `min( )`, `avg( )` con `group by` | Agregados |

Un campo como `NombreCompleto` no hace falta guardarlo para poder buscar por él: la vista lo calcula, y se puede buscar igual.

## Agregados: una vista por suma

Para calcular el importe de una orden hay que sumar sus presupuestos aceptados. En CDS, una suma es una vista con `group by`:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Importe de la orden'
define view entity ZI_TlOrdenImporte
  as select from ztl_prs
{
  key orden_uuid                               as OrdenUUID,
      cast( sum( importe ) as abap.dec(15,2) ) as Importe
}
where situacion = 'aceptado'
group by orden_uuid
```

Aceptar un presupuesto cambia el resultado de esta vista en la siguiente lectura, sin que nadie tenga que actualizar nada.

La mano de obra une los tramos con su jornada, para saber de qué orden es cada tramo:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Mano de obra de la orden'
define view entity ZI_TlOrdenManoObra
  as select from ztl_jor_tra as Tramo
    inner join ztl_jor as Jornada on Jornada.jornada_uuid = Tramo.jornada_uuid
{
  key Jornada.orden_uuid                                  as OrdenUUID,
      cast( sum( Tramo.tiempo ) as abap.dec(9,2) )        as Tiempo,
      cast( sum( Tramo.coste_tramo ) as abap.dec(15,2) )  as ManoObra
}
group by Jornada.orden_uuid
```

## Juntar las sumas: `left outer join` y `coalesce`

Una orden sin jornadas no tiene fila en `ZI_TlOrdenManoObra`. Si se une con `inner join`, esa orden **desaparece**; con `left outer join` aparece, pero con la mano de obra a **nulo**. `coalesce( ..., 0 )` lo convierte en 0:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Sumas de la orden'
define view entity ZI_TlOrdenSumas
  as select from ztl_orden as Orden
    left outer join ZI_TlOrdenImporte   as Imp on Imp.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenManoObra  as Mo  on Mo.OrdenUUID  = Orden.orden_uuid
    left outer join ZI_TlOrdenRecambios as Rec on Rec.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenSubcontr  as Sub on Sub.OrdenUUID = Orden.orden_uuid
    left outer join ZI_TlOrdenAbonado   as Abo on Abo.OrdenUUID = Orden.orden_uuid
{
  key Orden.orden_uuid                                        as OrdenUUID,
      cast( coalesce( Imp.Importe, 0 ) as abap.dec(15,2) )    as Importe,
      cast( coalesce( Mo.ManoObra, 0 ) + coalesce( Rec.Neto, 0 )
            + coalesce( Sub.Neto, 0 ) as abap.dec(15,2) )     as Costes,
      cast( coalesce( Abo.Cantidad, 0 ) as abap.dec(15,2) )   as Abonado
}
```

Todos los importes de las tablas tienen 2 decimales, así que sus sumas también: el `ajustar_centimos` de 1.2 no hace falta aquí.

## El resumen: decisiones con `case`

La última vista toma las sumas y calcula los indicadores. Como una vista no puede usar en un campo el alias de otro campo de **la misma** vista, se apila sobre la anterior:

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Taller - Resumen de la orden'
define view entity ZI_TlOrdenResumen
  as select from ZI_TlOrdenSumas
{
  key OrdenUUID,
      Importe,
      Costes,
      Abonado,
      cast( Abonado - Costes as abap.dec(15,2) ) as Rendimiento,
      cast( Importe - Abonado as abap.dec(15,2) ) as SaldoPendiente,

      case
        when Importe = 0         then cast( 0 as abap.dec(4,1) )
        when Abonado >= Importe  then cast( 100 as abap.dec(4,1) )
        else cast( division( Abonado * 100, Importe, 1 ) as abap.dec(4,1) )
      end                                         as PorcentajeLiquidado,

      case
        when Abonado <= 0        then cast( 'sin_abonar'      as abap.char(15) )
        when Abonado < Importe   then cast( 'abonado_parcial' as abap.char(15) )
        else                          cast( 'liquidado'       as abap.char(15) )
      end                                         as SituacionCobro,

      case
        when Abonado - Costes < 0                 then cast( 'rojo'  as abap.char(15) )
        when Abonado > 0 and Abonado >= Importe   then cast( 'verde' as abap.char(15) )
        else                                           cast( 'ambar' as abap.char(15) )
      end                                         as Semaforo,

      case
        when Abonado - Costes < 0                 then 1
        when Abonado > 0 and Abonado >= Importe   then 3
        else                                           2
      end                                         as SemaforoCriticality
}
```

Compara cada `case` con su método de `ZCL_TL_CALCULOS` (1.3):

- **`SituacionCobro`** es `situacion_cobro`, con las condiciones en el mismo orden.
- **`Semaforo`** escribe «liquidada» como «abonado > 0 y abonado ≥ importe», que es exactamente cuando `SituacionCobro` vale `liquidado`. No puede usar `SituacionCobro` directamente, porque está en la misma vista.
- **`PorcentajeLiquidado`** queda acotado a 100 si se ha cobrado de más.
- **`SemaforoCriticality`** (1 rojo, 2 ámbar, 3 verde) es el código que usa Fiori para pintar el semáforo (4.3).
- **Los literales llevan `cast`**: si no, el tipo del resultado lo fija el primero, y uno más largo que viniera después se cortaría.

## Dos sitios donde calcular

| | Vista CDS (esta unidad) | Determination (Bloque 3) |
|---|---|---|
| Se calcula | En la base de datos, al leer | En ABAP, al crear o modificar |
| Se guarda | No | Sí |
| Puede quedar atrasado | Nunca | Si falta un disparador |
| Se usa para | Lo que depende de **otros** registros | Lo que cambia mientras se edita el propio registro |
| En Odoo | `compute` sin `store` | `compute` con `store=True` |

## Preparación del entorno de trabajo

Las vistas nuevas van en `ZGOR_CDS`. Para comprobarlas necesitas datos: los de 1.5 sirven para clientes y obras; el resto se comprueba con los datos completos de [2.5](./2_5_proyecto.md). Al terminar:

```
ZGOR_CDS
├── (las vistas de 2.2 y 2.3)
├── ZI_GorObraTotal, ZI_GorObraMoo, ZI_GorObraCosteProv,
│   ZI_GorObraCosteEsp, ZI_GorObraCobros                  ← sumas (nuevas)
├── ZI_GorObraImportes                                    ← nueva
├── ZI_GorObraFinanzas                                    ← la ficha (nueva)
└── ZI_GorTrabAcum                                        ← nueva
```

## Ejercicios

1. **Campos de texto.** Añade `NombreCompleto` a `ZI_GorCliente` (nombre y apellidos) y a `ZI_GorTrabajador` (nombre y apellido), y `Anio` (los 4 primeros caracteres de la fecha) a `ZI_GorPresupuesto` y a `ZI_GorIngreso`. Comprueba `NombreCompleto` en el Data Preview de clientes.
2. **Las sumas.** Crea estas cinco vistas, todas con clave `ObraUUID`. Los importes, en `abap.dec(15,2)`; las horas, en `abap.dec(9,2)`:

    | Vista | Sale de | Devuelve (§11.2) |
    |---|---|---|
    | `ZI_GorObraTotal` | `zgor_presu` | `Total`: suma de `total` de los presupuestos **aprobados** |
    | `ZI_GorObraMoo` | `zgor_pt_lin` unida con `zgor_pt` | `Horas` y `CosteMoo`: sumas de `horas` y `coste_subtotal` |
    | `ZI_GorObraCosteProv` | `zgor_pp` | `Coste`: suma de `importe` |
    | `ZI_GorObraCosteEsp` | `zgor_pe` | `Coste`: suma de `importe` |
    | `ZI_GorObraCobros` | `zgor_ing` | `Importe`: suma de `importe` |

3. **Importes de la obra.** Crea `ZI_GorObraImportes`: una fila por cada obra de `zgor_obra` (también las que no tienen presupuestos, partes ni cobros), con `ObraUUID`, `Total`, `Horas`, `CosteMoo`, `CosteProveedores`, `CosteEspecialistas`, `Gastos` (la suma de los tres costes) e `Ingresos`. Ningún valor puede salir nulo.
4. **La ficha financiera.** Crea `ZI_GorObraFinanzas` encima de la anterior. Además de sus campos, debe devolver (§11.2, *Gastos* y *Obra: indicadores de cabecera*):

    | Campo | Regla |
    |---|---|
    | `BeneficioReal` | `ingresos − gastos` |
    | `Debe` | `total − ingresos` |
    | `MargenProyectado` | `total − gastos` |
    | `PorcentajeCobrado` | `abap.dec(4,1)`: 0 si total = 0; si no, `(total − debe) × 100 / total` a 1 decimal, acotado entre 0 y 100 |
    | `EstadoPago` | `pendiente`, `parcial` o `pagado`, con la regla de 1.3 |
    | `Salud` | `rojo`, `verde` o `ambar`, con la regla de 1.3 |
    | `SaludCriticality` | 1 si rojo, 3 si verde, 2 si ámbar |
    | `EstadoGasto` | `finalizado` o `proceso`, con la regla de 1.3 |

    Con los datos de 1.5 (obras sin presupuestos ni partes), el Data Preview debe mostrar una fila por obra, todo a 0, `pendiente`, `ambar` y `proceso`. ¿Por qué `ambar` y no `verde`?
5. **Enlázala.** Añade a `ZI_GorObra` y a `ZI_GorGasto` una association `[1]` a `ZI_GorObraFinanzas` llamada `_Finanzas` (por `ObraUUID`), y a `ZI_GorIngreso` otra llamada `_FinanzasObra`. El ingreso de Odoo muestra el total cobrado de su obra y lo que falta (§3.8): son `_FinanzasObra.Ingresos` y `_FinanzasObra.Debe`.
6. **Acumulados del trabajador.** Crea `ZI_GorTrabAcum`, con clave `TrabajadorUUID`: la suma de `horas` (`HorasTotales`) y de `coste_subtotal` (`TotalEuros`) de sus líneas de parte (§11.2 *Obra*). Añade a `ZI_GorTrabajador` una association llamada `_Acumulado`. ¿Por qué `[0..1]` y no `[1]`?
7. **Prueba a mano un caso.** Con un `INSERT` desde `ZCL_GOR_SQL_DEMO` (1.5), añade a `OBR0001` un presupuesto `aprobado` de total 1210, otro `no_aprobado` de 500 y un ingreso de 500. El Data Preview de `ZI_GorObraFinanzas` debe dar para `OBR0001`: total 1210, ingresos 500, debe 710, porcentaje 41.3, `parcial`. Cambia el estado del segundo a `aprobado` con un `UPDATE` y vuelve a abrir la vista: total 1710.
8. **Investiga.** Cambia en tu `ZI_GorObraImportes` un `left outer join` por `inner join` y abre el Data Preview: ¿cuántas obras salen? Deshaz el cambio y anota en `diseno.md` por qué **ninguna** de las dos regresiones del trabajador de §7 (horas que no se sumaban y horas de partes borrados que se seguían sumando) puede ocurrir con esta forma de calcular.

## Comprueba tu solución

Tus vistas se comprueban con datos en [2.5](./2_5_proyecto.md), con la clase `ZCL_GOR_COMPROBAR_CDS`.

---

**Siguiente:** [2.5. Proyecto: el ERP con datos](./2_5_proyecto.md)
