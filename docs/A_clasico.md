---
title: "A. ABAP clásico: lo mínimo"
parent: "Anexos"
nav_order: 1
---

# A. ABAP clásico: lo mínimo

{% raw %}
En ABAP Cloud no se usa, pero al ver código antiguo en un sistema real conviene reconocerlo.

| Clásico | En ABAP Cloud |
|---|---|
| SE11 (diccionario) | Database Table y CDS en ADT |
| SE38 / reports | Clases con `IF_OO_ADT_CLASSRUN` |
| `WRITE` | `out->write( )` |
| Dynpros | Fiori Elements |
| ALV | Apps Fiori |
| SE80 | Eclipse con ADT |
| Funciones (`CALL FUNCTION`) | Clases y APIs liberadas |
| `SELECT ... INTO TABLE @DATA(...)` | Igual, es ABAP SQL |

## Ejercicio

1. Lee un report clásico y traduce mentalmente cada sentencia a su equivalente de la tabla.


---

**Siguiente:** [B. Convenciones de nombres](B_nombres.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/A_clasico.md){: .fs-2 }
{% endraw %}
