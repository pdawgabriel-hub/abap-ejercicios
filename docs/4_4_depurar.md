---
title: "4.4. Comprobar y depurar"
parent: "4. Servicios y app Fiori"
nav_order: 4
---

# 4.4. Comprobar y depurar

{% raw %}
Cuando algo no funciona, la clave es saber **en qué capa** falla.

| Síntoma | Capa probable | Qué hacer |
|---|---|---|
| La CDS no activa | CDS | Lee el mensaje de la pestaña *Problems* |
| El Data Preview está vacío | Datos | Comprueba que la tabla tiene filas |
| La BDEF marca errores | Comportamiento | Revisa nombres de alias y mapping |
| La app no muestra columnas | Anotaciones | Revisa la metadata extension |
| El botón no hace nada | Clase de implementación | Pon un breakpoint |

## Depurador

1. Doble clic en el margen izquierdo de una línea de la clase local para poner un **breakpoint**.
2. Abre la app Fiori (Preview) y ejecuta la acción.
3. Eclipse te pedirá cambiar a la perspectiva de depuración. Acepta.
4. **F6** avanza línea a línea, **F5** entra en un método, **F8** continúa.

> Un breakpoint solo se detiene si estás conectado con el mismo usuario que lanzó la acción. Si no salta, revisa que el breakpoint está activo en la vista *Breakpoints*.

## Ejercicios

1. **Provoca un fallo.** Quita un campo del `mapping` y observa el mensaje. Después corrígelo.
2. **Breakpoint.** Depura la determination de fecha de Cliente y mira el valor del sistema.
3. **Diario de errores.** Apunta en tu repositorio (`docs/errores.md`) tres errores con su causa y solución.


---

**Siguiente:** [4.5. Proyecto: tu primera app](4_5_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/4_4_depurar.md){: .fs-2 }
{% endraw %}
