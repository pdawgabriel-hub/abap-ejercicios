---
title: "2.2. CDS View Entities"
parent: "2. Modelo de datos con CDS"
nav_order: 2
---

# 2.2. CDS View Entities

{% raw %}
> **El ejemplo de referencia.** Todo el bloque 2 a 4 usa un único ejemplo, el taller de reparación de vehículos «RuedaLibre» (`ZTL_*`). Tus ejercicios usan tu proyecto de obras (`ZGOR_*`). Pega el ejemplo para ver cómo funciona y después **haz tu versión**.

Encima de cada tabla se construye una **CDS View Entity**: una definición declarativa de lo que expones. Es el punto de partida de todo en RAP. Hay dos capas típicas:

- La **interface view** (prefijo `ZI_`): el modelo de negocio.
- La **projection view** (prefijo `ZC_`): adapta el modelo a un consumo concreto, como una app Fiori ([4.1](4_1_proyecciones.html)).

## Crear una CDS

1. Clic derecho en el paquete → **New → Other ABAP Repository Object → Data Definition**.
2. Nombre `ZI_GorCliente`. Plantilla: **Define View Entity** (o **Define Root View Entity** para las raíces).
3. Completa la CDS, guarda y activa. Con la CDS abierta, **F8** abre el Data Preview.

## La CDS de las líneas

Pega primero la de las líneas, porque la de la orden la referencia. Si la orden da error por la línea, activa antes la línea.

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Linea de coste'
define view entity ZI_TlLinea
  as select from ztl_linea
  association to parent ZI_TlOrden as _Orden
    on $projection.OrdenUuid = _Orden.OrdenUuid
{
  key linea_uuid as LineaUuid,
      orden_uuid as OrdenUuid,
      concepto   as Concepto,
      @Semantics.amount.currencyCode: 'Moneda'
      importe    as Importe,
      moneda     as Moneda,
      _Orden
}
```

## La CDS de la orden

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Orden de reparacion'
define root view entity ZI_TlOrden
  as select from ztl_orden
  composition [0..*] of ZI_TlLinea as _Lineas
{
  key orden_uuid    as OrdenUuid,
      orden_id      as OrdenId,
      matricula     as Matricula,
      descripcion   as Descripcion,
      estado        as Estado,
      case estado
        when 'P' then 'Pendiente'
        when 'C' then 'En curso'
        when 'F' then 'Finalizada'
        else 'Desconocido'
      end           as EstadoTexto,
      fecha_entrada as FechaEntrada,
      @Semantics.amount.currencyCode: 'Moneda'
      coste_total   as CosteTotal,
      moneda        as Moneda,
      _Lineas
}
```

Cuando estén activas, pulsa **F8** con la CDS abierta para abrir el **Data Preview**. La tabla estará vacía, pero la vista debe abrirse sin errores.

> **Puente a Odoo.** Un campo calculado en la CDS (como `EstadoTexto`) equivale a un `compute` sin `store` de Odoo, pero se resuelve en SQL, no en el servidor de aplicación.

## Ejercicios

1. **CDS de Clientes.** Crea `ZI_GorCliente` con al menos un campo calculado con `case`.
2. **Interface frente a projection.** Explica con tus palabras la diferencia práctica entre una interface view y una projection view.
3. **CDS de Obras.** Crea `ZI_GorObra` con un campo calculado de estado en texto.


---

**Siguiente:** [2.3. Associations y composiciones](2_3_associations.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/2_2_cds.md){: .fs-2 }
{% endraw %}
