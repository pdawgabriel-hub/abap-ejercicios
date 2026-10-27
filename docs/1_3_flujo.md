---
title: "1.3. Control de flujo y funciones de cadena"
parent: "1. Fundamentos del lenguaje"
nav_order: 3
---

# 1.3. Control de flujo y funciones de cadena

{% raw %}
> **Cómo ejecutar los ejemplos.** Los ejemplos muestran solo el **contenido del método `main`** de una clase ejecutable. Pégalos dentro de la plantilla de [1.1](1_1_classrun.html) (cambiando el nombre de la clase), activa con **Ctrl+F3** y ejecuta con **F9**.

Las estructuras de control son las habituales: `IF / ELSEIF / ELSE`, `CASE` (como un switch), `DO n TIMES` y `WHILE`. Para elegir un valor según una condición hay expresiones: `COND` (if) y `SWITCH` (case). Las funciones de cadena **devuelven** un valor, sin cambiar el original.

```abap
    DATA(lv_estado) = 'C'.
    DATA(lv_cantidad) = 7.

    IF lv_cantidad > 10.
      out->write( 'Mucho' ).
    ELSEIF lv_cantidad > 5.
      out->write( 'Normal' ).
    ELSE.
      out->write( 'Poco' ).
    ENDIF.

    CASE lv_estado.
      WHEN 'P'.
        out->write( 'Pendiente' ).
      WHEN 'C'.
        out->write( 'En curso' ).
      WHEN OTHERS.
        out->write( 'Otro' ).
    ENDCASE.

    DATA(lv_texto) = SWITCH string( lv_estado
                       WHEN 'P' THEN 'Pendiente'
                       WHEN 'C' THEN 'En curso'
                       ELSE 'Desconocido' ).
    out->write( lv_texto ).

    DO 3 TIMES.
      out->write( |Vuelta { sy-index }| ).
    ENDDO.

    DATA(lv_nombre) = `  Reformas Garcia  `.
    out->write( to_upper( condense( lv_nombre ) ) ).
    out->write( strlen( lv_nombre ) ).
    out->write( replace( val = lv_nombre sub = 'Garcia' with = 'Lopez' ) ).
    out->write( substring( val = 'ABCDEFGH' off = 2 len = 3 ) ).
```

## Ejercicios

1. **Estado de una obra.** Escribe un método que, dado un estado ('P', 'C', 'F'), devuelva el texto con `SWITCH`, y pruébalo con los tres valores y uno desconocido.
2. **Nombre limpio.** Dado un nombre con espacios sobrantes, devuelve el nombre en mayúsculas sin espacios sobrantes y su longitud.
3. **Clase de utilidades.** Crea `ZCL_EJ_ESTADOS` con este esqueleto e implementa los dos métodos.

```abap
CLASS zcl_ej_estados DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " 'P' -> Pendiente, 'C' -> En curso, 'F' -> Finalizada, otro -> Desconocido
    CLASS-METHODS texto_estado
      IMPORTING iv_estado TYPE string
      RETURNING VALUE(rv_texto) TYPE string.
    " Quita espacios sobrantes (inicio, fin y repetidos) y pasa a mayusculas
    CLASS-METHODS limpiar_nombre
      IMPORTING iv_nombre TYPE string
      RETURNING VALUE(rv_nombre) TYPE string.
ENDCLASS.

CLASS zcl_ej_estados IMPLEMENTATION.
  METHOD texto_estado.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.

  METHOD limpiar_nombre.
    " TODO: escribe tu solucion aqui
  ENDMETHOD.
ENDCLASS.
```

## Comprueba tu solución automáticamente (opcional)

Pega el test en la pestaña **Test Classes** de la clase y ejecútalo con **Ctrl+Shift+F10**.

```abap
CLASS ltcl_estados DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS estados_conocidos FOR TESTING.
    METHODS estado_desconocido FOR TESTING.
    METHODS nombre_limpio FOR TESTING.
ENDCLASS.

CLASS ltcl_estados IMPLEMENTATION.
  METHOD estados_conocidos.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'P' ) exp = `Pendiente` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'C' ) exp = `En curso` ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'F' ) exp = `Finalizada` ).
  ENDMETHOD.

  METHOD estado_desconocido.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>texto_estado( 'X' ) exp = `Desconocido` ).
  ENDMETHOD.

  METHOD nombre_limpio.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_ej_estados=>limpiar_nombre( `  reformas   garcia ` )
      exp = `REFORMAS GARCIA` ).
  ENDMETHOD.
ENDCLASS.
```


---

**Siguiente:** [1.4. Tablas internas](1_4_tablasInternas.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_3_flujo.md){: .fs-2 }
{% endraw %}
