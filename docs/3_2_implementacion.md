---
title: "3.2. La clase de implementación"
parent: "3. Comportamiento con RAP"
nav_order: 2
---

# 3.2. La clase de implementación

{% raw %}
La lógica de negocio de una BDEF vive en una **clase de implementación**. La clase global (la que ves en el explorador) está casi vacía a propósito: en RAP la lógica va en **clases locales** (`lhc_...`), una por entidad.

## Crear la clase

1. Con la BDEF abierta, cursor sobre el nombre de la clase (`zbp_i_tlorden`) y **Ctrl+1** (*Quick Fix*).
2. Elige **Create behavior implementation class zbp_i_tlorden**, acepta el asistente y elige tu orden de transporte.
3. Se crea la clase global. La lógica va en la pestaña inferior **Local Types** del editor de la clase (abajo, junto a «Global Class»).
4. Sustituye el contenido de **Global Class** y el de **Local Types** por los bloques de abajo.

> Si tu ADT ya generó los métodos vacíos en Local Types, sustituye todo el contenido por el bloque de abajo. Si ves el nombre de la pestaña distinto, busca la que contenga las clases `lhc_...`.

## Pestaña Global Class

```abap
CLASS zbp_i_tlorden DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF ZI_TlOrden.
ENDCLASS.

CLASS zbp_i_tlorden IMPLEMENTATION.
ENDCLASS.
```

## Pestaña Local Types

La lógica completa del ejemplo está en esta pestaña. La tienes explicada por partes en las unidades siguientes ([3.3](3_3_determinations.html), [3.4](3_4_validations.html), [3.5](3_5_actions.html) y [3.6](3_6_composiciones.html)).

```abap
CLASS lhc_Orden DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS iniciarOrden FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Orden~iniciarOrden.
    METHODS asignarNumero FOR DETERMINE ON SAVE
      IMPORTING keys FOR Orden~asignarNumero.
    METHODS validarMatricula FOR VALIDATE ON SAVE
      IMPORTING keys FOR Orden~validarMatricula.
    METHODS cerrarOrden FOR MODIFY
      IMPORTING keys FOR ACTION Orden~cerrarOrden RESULT result.
ENDCLASS.

CLASS lhc_Orden IMPLEMENTATION.

  METHOD iniciarOrden.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden FIELDS ( Estado ) WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).
    DELETE ordenes WHERE Estado IS NOT INITIAL.
    CHECK ordenes IS NOT INITIAL.

    MODIFY ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden
        UPDATE FIELDS ( Estado FechaEntrada Moneda )
        WITH VALUE #( FOR orden IN ordenes
                      ( %tky         = orden-%tky
                        Estado       = 'P'
                        FechaEntrada = cl_abap_context_info=>get_system_date( )
                        Moneda       = 'EUR' ) ).
  ENDMETHOD.

  METHOD asignarNumero.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden FIELDS ( OrdenId ) WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).
    DELETE ordenes WHERE OrdenId IS NOT INITIAL.
    CHECK ordenes IS NOT INITIAL.

    SELECT SINGLE FROM ztl_orden FIELDS MAX( orden_id ) INTO @DATA(lv_max).

    MODIFY ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden
        UPDATE FIELDS ( OrdenId )
        WITH VALUE #( FOR orden IN ordenes INDEX INTO i
                      ( %tky    = orden-%tky
                        OrdenId = lv_max + i ) ).
  ENDMETHOD.

  METHOD validarMatricula.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden FIELDS ( Matricula ) WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).

    LOOP AT ordenes INTO DATA(orden).
      IF orden-Matricula IS INITIAL.
        APPEND VALUE #( %tky = orden-%tky ) TO failed-orden.
        APPEND VALUE #( %tky = orden-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'La matricula es obligatoria' )
                        %element-Matricula = if_abap_behv=>mk-on )
               TO reported-orden.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cerrarOrden.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden FIELDS ( Estado ) WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).

    DATA lt_cerrar LIKE ordenes.
    LOOP AT ordenes INTO DATA(orden).
      IF orden-Estado = 'C'.
        APPEND orden TO lt_cerrar.
      ELSE.
        APPEND VALUE #( %tky = orden-%tky ) TO failed-orden.
        APPEND VALUE #( %tky = orden-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Solo se puede cerrar una orden en curso' ) )
               TO reported-orden.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden
        UPDATE FIELDS ( Estado )
        WITH VALUE #( FOR o IN lt_cerrar ( %tky = o-%tky Estado = 'F' ) ).

    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes_nuevas).
    result = VALUE #( FOR o IN ordenes_nuevas ( %tky = o-%tky %param = o ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Linea DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS recalcularCoste FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Linea~recalcularCoste.
ENDCLASS.

CLASS lhc_Linea IMPLEMENTATION.

  METHOD recalcularCoste.
    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Linea BY \_Orden FIELDS ( OrdenUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(ordenes).
    SORT ordenes BY OrdenUuid.
    DELETE ADJACENT DUPLICATES FROM ordenes COMPARING OrdenUuid.

    READ ENTITIES OF ZI_TlOrden IN LOCAL MODE
      ENTITY Orden BY \_Lineas FIELDS ( OrdenUuid Importe )
      WITH CORRESPONDING #( ordenes )
      RESULT DATA(lineas).

    DATA lv_total TYPE ztl_orden-coste_total.
    LOOP AT ordenes INTO DATA(orden).
      lv_total = 0.
      LOOP AT lineas INTO DATA(linea) WHERE OrdenUuid = orden-OrdenUuid.
        lv_total = lv_total + linea-Importe.
      ENDLOOP.
      MODIFY ENTITIES OF ZI_TlOrden IN LOCAL MODE
        ENTITY Orden
          UPDATE FIELDS ( CosteTotal )
          WITH VALUE #( ( %tky = orden-%tky CosteTotal = lv_total ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
```

## Cosas que conviene entender

- `IN LOCAL MODE`: el código se salta las comprobaciones de autorización y los campos `readonly`. Es lo que se usa dentro de la lógica de negocio.
- `%tky`: identifica la instancia (en este ejemplo, el UUID). Siempre se propaga tal cual.
- `failed-orden` marca qué instancias han fallado; `reported-orden` lleva el mensaje que verá el usuario. Los nombres `orden` y `linea` son los alias de la BDEF en minúsculas.
- `BY \_Orden`: navegación por la association. La barra invertida es parte de la sintaxis.

## Ejercicios

1. **Clase de Cliente.** Crea la clase de implementación de `ZI_GorCliente` y actívala aunque no tenga lógica todavía.
2. **Lectura del ejemplo.** Lee la clase local del ejemplo y explica con tus palabras para qué sirve cada `READ ENTITIES` y cada `MODIFY ENTITIES`.


---

**Siguiente:** [3.3. Determinations](3_3_determinations.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_2_implementacion.md){: .fs-2 }
{% endraw %}
