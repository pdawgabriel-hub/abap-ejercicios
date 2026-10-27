---
title: "3.4. Validations"
parent: "3. Comportamiento con RAP"
nav_order: 4
---

# 3.4. Validations

{% raw %}
Una **validation** comprueba los datos **antes de guardar** y puede bloquear el guardado. Equivale a un `@api.constrains` de Odoo. Para bloquear, rellenas dos tablas de salida:

- `failed-<alias>`: qué instancias han fallado.
- `reported-<alias>`: el mensaje que verá el usuario (y, si quieres, el campo que se marca en rojo con `%element-<Campo> = if_abap_behv=>mk-on`).

## Ejemplo: matrícula obligatoria

Está en la pestaña **Local Types** ([3.2](3_2_implementacion.html)). El patrón es siempre el mismo:

1. `READ ENTITIES ... IN LOCAL MODE` para leer los campos que quieres validar.
2. `LOOP` sobre el resultado.
3. Si no se cumple, `APPEND VALUE #( ... )` a `failed` y a `reported`.

Los mensajes se crean con `new_message_with_text( severity = if_abap_behv_message=>severity-error text = '...' )`.

> **Puente a Odoo.** Es el `raise ValidationError(...)` de un `@api.constrains`: el registro no se guarda y el usuario ve el mensaje.

## Ejercicios

1. **Nombre obligatorio.** Escribe una validation para `ZI_GorCliente` que bloquee el guardado si el nombre está vacío, con mensaje en el campo.
2. **IVA válido.** Escribe una validation para Presupuesto que obligue a que el IVA esté entre 0 y 100.
3. **Fechas.** Escribe una validation para Obra que compruebe que la fecha de fin no es anterior a la de inicio.


---

**Siguiente:** [3.5. Actions](3_5_actions.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_4_validations.md){: .fs-2 }
{% endraw %}
