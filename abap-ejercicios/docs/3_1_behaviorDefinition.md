---
title: "3.1. Behavior Definition managed"
parent: "3. Comportamiento con RAP"
nav_order: 1
---

# 3.1. Behavior Definition managed

{% raw %}
Una CDS por sí sola es de solo lectura. Para crear, modificar y borrar necesitas una **Behavior Definition** (BDEF): un artefacto que declara qué operaciones están permitidas y qué lógica se ejecuta. En modo **managed**, el framework hace el guardado por ti; en **unmanaged** lo programas tú (más control, mucho más trabajo).

## Crearla

1. Clic derecho sobre la CDS activa → **New Behavior Definition**. Elige **Managed**.
2. Completa el cuerpo con el código de abajo.
3. Con el cursor sobre el nombre de la clase de implementación, **Ctrl+1** → «Create behavior implementation class» ([3.2](3_2_implementacion.html)).

## La BDEF de la orden (con composición de las líneas)

```sql
managed implementation in class zbp_i_tlorden unique;
strict ( 2 );

define behavior for ZI_TlOrden alias Orden
persistent table ztl_orden
lock master
authorization master ( instance )
{
  create;
  update;
  delete;

  field ( numbering : managed, readonly ) OrdenUuid;
  field ( readonly ) OrdenId, Estado, CosteTotal;
  field ( mandatory ) Matricula;

  determination iniciarOrden on modify { create; }
  determination asignarNumero on save { create; }
  validation validarMatricula on save { create; field Matricula; }

  action cerrarOrden result [1] $self;

  association _Lineas { create; }

  mapping for ztl_orden
  {
    OrdenUuid   = orden_uuid;
    OrdenId     = orden_id;
    Matricula   = matricula;
    Descripcion = descripcion;
    Estado      = estado;
    FechaEntrada = fecha_entrada;
    CosteTotal  = coste_total;
    Moneda      = moneda;
  }
}

define behavior for ZI_TlLinea alias Linea
persistent table ztl_linea
lock dependent by _Orden
authorization dependent by _Orden
{
  update;
  delete;

  field ( numbering : managed, readonly ) LineaUuid;
  field ( readonly ) OrdenUuid;

  determination recalcularCoste on modify { create; field Importe; }

  association _Orden;

  mapping for ztl_linea
  {
    LineaUuid = linea_uuid;
    OrdenUuid = orden_uuid;
    Concepto  = concepto;
    Importe   = importe;
    Moneda    = moneda;
  }
}
```

## Qué significa cada pieza

- `strict ( 2 )` activa comprobaciones más estrictas del framework. Úsalo siempre en desarrollo nuevo.
- `field ( numbering : managed, readonly )`: el framework genera el UUID al crear y el usuario no lo puede editar.
- `field ( readonly )` sobre `OrdenId`, `Estado` y `CosteTotal`: los rellena la lógica, no el usuario. La lógica sí puede escribirlos porque lo hace en *local mode*.
- `mapping`: une cada campo de la CDS (CamelCase) con su columna de la tabla (snake_case). Si los nombres no coinciden es obligatorio.
- `lock dependent by` y `authorization dependent by`: la línea hereda el bloqueo y la autorización de su orden.

> **Al guardar la BDEF** el editor marcará errores hasta que exista la clase de implementación y los métodos. Es normal: continúa en [3.2](3_2_implementacion.html).

## Ejercicios

1. **Managed y unmanaged.** Explica la diferencia. ¿En qué parte de tu proyecto (los cálculos de Gastos, por ejemplo) podrías necesitar unmanaged?
2. **Número no editable.** En el ejemplo, `OrdenId` es `readonly`. ¿Por qué tiene sentido? Relaciónalo con cómo generas tus códigos secuenciales en Odoo.
3. **BDEF de Cliente.** Escribe la BDEF de `ZI_GorCliente` con `create`, `update`, `delete`, clave UUID con numbering managed y el `mapping` completo.


---

**Siguiente:** [3.2. La clase de implementación](3_2_implementacion.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_1_behaviorDefinition.md){: .fs-2 }
{% endraw %}
