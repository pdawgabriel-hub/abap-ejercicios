---
title: "3.6. Cabecera y líneas en el comportamiento"
parent: "3. Comportamiento con RAP"
nav_order: 6
---

# 3.6. Cabecera y líneas en el comportamiento

{% raw %}
Cuando una entidad tiene líneas (Presupuesto → líneas), la BDEF de la **hija** hereda el bloqueo y la autorización de la cabecera y declara la association hacia ella:

```sql
define behavior for ZI_TlLinea alias Linea
persistent table ztl_linea
lock dependent by _Orden
authorization dependent by _Orden
{
  update;
  delete;
  field ( numbering : managed, readonly ) LineaUuid;
  field ( readonly ) OrdenUuid;
  association _Orden;
}
```

Y la BDEF de la **cabecera** permite crear líneas con `association _Lineas { create; }`.

> **Una sola clase de implementación.** En el ejemplo, la BDEF de la línea no declara clase propia: sus métodos están en la misma clase `zbp_i_tlorden`, en una clase local `lhc_Linea` aparte.

## Ejercicios

1. **Presupuesto con líneas.** Escribe las BDEF de `ZI_GorPresupuesto` y `ZI_GorPresuLin` (composición) usando el ejemplo.
2. **Total.** Escribe la determination que recalcula el total del presupuesto cuando cambian las líneas.
3. **Dos hijas.** ¿Qué tendrías que cambiar si el presupuesto tuviera también «observaciones» como entidad hija?


---

**Siguiente:** [3.7. Numeración](3_7_numeracion.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_6_composiciones.md){: .fs-2 }
{% endraw %}
