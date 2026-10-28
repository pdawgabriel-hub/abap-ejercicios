# A. ABAP clásico: lo mínimo

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

**Siguiente:** [B. Convenciones de nombres](./B_nombres.md)
