---
title: "4.1. Proyecciones"
parent: "4. Servicios y app Fiori"
nav_order: 1
---

# 4.1. Proyecciones

{% raw %}
Las CDS `ZI_` son el modelo de negocio; para exponerlas se crea una capa de **proyección** (`ZC_`) que decide qué campos y qué operaciones se ven. Así puedes tener varias apps con vistas distintas sobre el mismo modelo.

Hacen falta dos cosas por entidad:

1. Una **CDS de proyección** (`define root view entity ... as projection on ...`).
2. Una **BDEF de proyección** (`projection; ... use create; use update; use delete;`).

## Proyección de la orden

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Orden de reparacion (proyeccion)'
@Metadata.allowExtensions: true
define root view entity ZC_TlOrden
  provider contract transactional_query
  as projection on ZI_TlOrden
{
  key OrdenUuid,
      OrdenId,
      Matricula,
      Descripcion,
      Estado,
      EstadoTexto,
      FechaEntrada,
      @Semantics.amount.currencyCode: 'Moneda'
      CosteTotal,
      Moneda,
      _Lineas : redirected to composition child ZC_TlLinea
}
```

```sql
projection;
strict ( 2 );

define behavior for ZC_TlOrden alias Orden
{
  use create;
  use update;
  use delete;

  use action cerrarOrden;

  use association _Lineas { create; }
}

define behavior for ZC_TlLinea alias Linea
{
  use update;
  use delete;

  use association _Orden;
}
```

## Proyección de la línea

```sql
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Linea de coste (proyeccion)'
@Metadata.allowExtensions: true
define view entity ZC_TlLinea
  as projection on ZI_TlLinea
{
  key LineaUuid,
      OrdenUuid,
      Concepto,
      @Semantics.amount.currencyCode: 'Moneda'
      Importe,
      Moneda,
      _Orden : redirected to parent ZC_TlOrden
}
```

> Activa primero la proyección hija (`ZC_TlLinea`), después la raíz y por último la BDEF de proyección. Si activas en otro orden verás errores de objeto inexistente.

## Ejercicios

1. **Proyección de Cliente.** Crea `ZC_GorCliente` y su BDEF de proyección con `use create; use update; use delete;`.
2. **Ocultar un campo.** Deja fuera de la proyección un campo interno y compruébalo en el servicio ([4.2](4_2_servicio.html)).
3. **Dos proyecciones.** Explica un caso real de tu proyecto en el que querrías dos proyecciones distintas de la misma entidad.


---

**Siguiente:** [4.2. Service Definition y Service Binding](4_2_servicio.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/4_1_proyecciones.md){: .fs-2 }
{% endraw %}
