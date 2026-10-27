---
title: "3.5. Actions"
parent: "3. Comportamiento con RAP"
nav_order: 5
---

# 3.5. Actions

{% raw %}
Una **action** es lógica que el usuario dispara de forma explícita, normalmente con un botón. Equivale a un método público de Odoo llamado desde un botón de una vista XML.

```sql
action cerrarOrden result [1] $self;
```

Se declara en la BDEF, se implementa con `METHODS cerrarOrden FOR MODIFY IMPORTING keys FOR ACTION Orden~cerrarOrden RESULT result` y devuelve la instancia ya modificada (`result`).

## El ejemplo: cerrar una orden

`cerrarOrden` ([3.2](3_2_implementacion.html)) solo cierra órdenes en estado 'C' (en curso) y las pasa a 'F'. Si la orden no está en curso, devuelve un mensaje de error en `reported`. Fíjate en la estructura:

1. Lee el estado actual de las instancias.
2. Separa las que se pueden cerrar de las que no.
3. Modifica solo las válidas y devuelve el resultado.

## Ejercicios

1. **Cerrar obra.** Implementa `cerrarObra` en `ZI_GorObra`: solo debe poder ejecutarse con estado 'C' y pasa el estado a 'F'.
2. **Reabrir.** Escribe la firma (sin implementar) de una action `reabrirObra` que solo tenga sentido con estado 'F'.
3. **Iniciar trabajo.** Escribe la action `iniciarTrabajo` (de 'P' a 'C') en la BDEF de interface y en la de proyección, y explica qué método nuevo hace falta en la clase local.


---

**Siguiente:** [3.6. Cabecera y líneas en el comportamiento](3_6_composiciones.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_5_actions.md){: .fs-2 }
{% endraw %}
