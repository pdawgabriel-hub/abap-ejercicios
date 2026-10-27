---
title: "3.7. Numeración"
parent: "3. Comportamiento con RAP"
nav_order: 7
---

# 3.7. Numeración

{% raw %}
En Odoo, tu `create()` asigna el código al crear el registro. En RAP tienes que decidir **cuándo** y **cómo**.

| Opción | Cómo funciona | Cuándo usarla |
|---|---|---|
| **UUID como clave + número visible calculado al guardar** (lo que hace el ejemplo) | La clave técnica es el UUID; un campo aparte (`OrdenId`) se rellena en una determination *on save* | El caso más simple y robusto. **Recomendado** para tu proyecto |
| Early numbering | La clave se asigna nada más crear (con un manejador propio) | Cuando el usuario debe ver su número desde el primer momento |
| Late numbering | La clave se asigna al guardar (con un método `adjust_numbers`) | Cuando no puede haber huecos y el número es la clave técnica |

## Rango de números

Para el número visible, lo correcto en producción es un **rango de números**: se crea un *Number Range Object* en ADT (*New → Other ABAP Repository Object → Number Range Object*) y se consume con la API liberada `CL_NUMBERRANGE_RUNTIME`. Las funciones clásicas (`NUMBER_GET_NEXT`) no están liberadas para Cloud.

Este bloque sustituye el método `asignarNumero` del ejemplo:

```abap
  METHOD asignarNumero.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden FIELDS ( OrdenId ) WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).
    DELETE ordenes WHERE OrdenId IS NOT INITIAL.
    CHECK ordenes IS NOT INITIAL.

    LOOP AT ordenes INTO DATA(orden).
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZTL_ORDEN'
            IMPORTING
              number      = DATA(lv_numero) ).
        CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_nr).
          APPEND VALUE #( %tky = orden-%tky ) TO failed-orden.
          APPEND VALUE #( %tky = orden-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'No hay rango de numeros configurado' ) )
                 TO reported-orden.
          CONTINUE.
      ENDTRY.

      MODIFY ENTITIES OF ZI_TlOrden IN LOCAL MODE
        ENTITY Orden
          UPDATE FIELDS ( OrdenId )
          WITH VALUE #( ( %tky = orden-%tky OrdenId = lv_numero ) ).
    ENDLOOP.
  ENDMETHOD.
```

> **Variante delicada.** El nombre exacto de los parámetros y de las excepciones de la API, y los pasos para crear el objeto de rango, dependen de tu versión. Antes de usarla, comprueba la documentación de `CL_NUMBERRANGE_RUNTIME` con **F2** en Eclipse. Para el portfolio, el máximo + 1 del ejemplo es suficiente si lo explicas en el README.

## Ejercicios

1. **Estrategia por entidad.** Para Cliente, Obra y Presupuesto decide qué estrategia usarías y justifícalo.
2. **Determination de Obra.** Diseña la determination *on save* equivalente a `asignarNumero` para tu entidad de Obra, con un nombre de rango propio.
3. **Ventaja y límite.** Explica por qué el máximo + 1 no es seguro con varios usuarios.


---

**Siguiente:** [3.8. Proyecto: comportamiento de Clientes y Obras](3_8_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_7_numeracion.md){: .fs-2 }
{% endraw %}
