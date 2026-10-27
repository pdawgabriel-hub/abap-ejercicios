---
title: "3.3. Determinations"
parent: "3. Comportamiento con RAP"
nav_order: 3
---

# 3.3. Determinations

{% raw %}
Una **determination** es lógica que se ejecuta **automáticamente** cuando se crea o modifica una instancia. Equivale a un `@api.depends` con `store=True` o a rellenar campos en un `create()` de Odoo.

| Momento | Cuándo se ejecuta | Uso típico |
|---|---|---|
| `on modify` | Al crear o cambiar un campo, durante la edición | Valores por defecto, cálculos que el usuario ve al instante |
| `on save` | Al guardar | Asignar el número visible, cálculos finales |

## Las tres determinations del ejemplo

- `iniciarOrden` (*on modify, create*): fija el estado inicial en 'P', la fecha de entrada con la del sistema y la moneda en EUR.
- `asignarNumero` (*on save, create*): calcula el número visible máximo + 1.
- `recalcularCoste` (*on modify, en la línea*): suma los importes de las líneas y actualiza el coste de la orden.

Están en la pestaña **Local Types** de la clase ([3.2](3_2_implementacion.html)).

## Limitaciones conscientes del ejemplo

- `asignarNumero` usa máximo + 1, que sirve para aprender pero **no es seguro** con muchos usuarios a la vez. La variante con rango de números está en [3.7](3_7_numeracion.html).
- `recalcularCoste` se dispara al crear o cambiar el importe de una línea, pero **no al borrarla**. Tratarlo es el ejercicio 3.

## Ejercicios

1. **Fecha de alta.** En `ZI_GorCliente`, añade una determination *on modify* que rellene la fecha de alta con la del sistema.
2. **Número visible.** Añade una determination *on save* que asigne `ClienteId` (máximo + 1, como en el ejemplo).
3. **Borrar una línea.** Investiga en la documentación oficial qué trigger necesitas para que `recalcularCoste` también se ejecute al borrar una línea y explica tu solución (no hace falta código).


---

**Siguiente:** [3.4. Validations](3_4_validations.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_3_determinations.md){: .fs-2 }
{% endraw %}
