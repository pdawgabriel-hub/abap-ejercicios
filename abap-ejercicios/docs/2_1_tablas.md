---
title: "2.1. Tablas persistentes en ADT"
parent: "2. Modelo de datos con CDS"
nav_order: 1
---

# 2.1. Tablas persistentes en ADT

{% raw %}
> **El ejemplo de referencia.** Todo el bloque 2 a 4 usa un único ejemplo, el taller de reparación de vehículos «RuedaLibre» (`ZTL_*`). Tus ejercicios usan tu proyecto de obras (`ZGOR_*`). Pega el ejemplo para ver cómo funciona y después **haz tu versión**.

En ABAP Cloud **no hay SE11**. Las tablas se escriben como código en Eclipse con el objeto **Database Table**. Esa tabla es la base física debajo de tu modelo RAP.

## Pasos

1. Clic derecho en el paquete → **New → Other ABAP Repository Object** → busca «Database Table».
2. Nombre en minúsculas, por ejemplo `ztl_orden`, y descripción. Elige tu orden de transporte.
3. Se abre el editor con las anotaciones iniciales. Escribe tus campos, guarda (**Ctrl+S**) y activa (**Ctrl+F3**).

## Las tablas del ejemplo

Una orden de reparación con sus líneas de coste. Fíjate en tres detalles:

- La clave primaria es un **UUID** (`sysuuid_x16`): lo genera el framework.
- El campo `client` es obligatorio en las tablas dependientes de mandante.
- Los importes llevan un campo de moneda y la anotación `@Semantics.amount.currencyCode`.

```sql
@EndUserText.label : 'Taller - Ordenes de reparacion'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_orden {
  key client    : abap.clnt not null;
  key orden_uuid : sysuuid_x16 not null;
  orden_id      : abap.numc(8);
  matricula     : abap.char(10);
  descripcion   : abap.char(80);
  estado        : abap.char(1);
  fecha_entrada : abap.dats;
  @Semantics.amount.currencyCode : 'ztl_orden.moneda'
  coste_total   : abap.curr(15,2);
  moneda        : abap.cuky;
}
```

```sql
@EndUserText.label : 'Taller - Lineas de coste'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_linea {
  key client     : abap.clnt not null;
  key linea_uuid : sysuuid_x16 not null;
  orden_uuid     : sysuuid_x16 not null;
  concepto       : abap.char(60);
  @Semantics.amount.currencyCode : 'ztl_linea.moneda'
  importe        : abap.curr(15,2);
  moneda         : abap.cuky;
}
```

> Si el editor marca algún aviso en las anotaciones del principio, déjalas como están: son las que genera el asistente al crear una tabla nueva. Si prefieres, crea la tabla con el asistente (*New → Database Table*) y solo sustituye el bloque de campos.

## Ejercicios

1. **Tabla de Clientes.** Escribe y activa `zgor_cli` con clave UUID, un número visible `cliente_id`, y los campos de tu diseño de [1.9](1_9_proyecto.html).
2. **Tabla de Obras.** Lo mismo para `zgor_obra`, con una columna que guarde el UUID del cliente.
3. **Datos de prueba.** Carga 3 filas en cada una con una clase ejecutable. Recuerda que las claves UUID se generan con `cl_system_uuid=>create_uuid_x16_static( )`.


---

**Siguiente:** [2.2. CDS View Entities](2_2_cds.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/2_1_tablas.md){: .fs-2 }
{% endraw %}
