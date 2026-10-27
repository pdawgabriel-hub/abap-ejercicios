---
title: "1.1. Tu primer programa: clases ejecutables"
parent: "1. Fundamentos del lenguaje"
nav_order: 1
---

# 1.1. Tu primer programa: clases ejecutables

{% raw %}
En ABAP Cloud no hay `REPORT` ni `WRITE`. Para ejecutar código de prueba creas una **clase** que implementa la interfaz `IF_OO_ADT_CLASSRUN`. Al pulsar **F9**, lo que escribas con `out->write( )` aparece en la pestaña **Console** de Eclipse.

## Una clase ABAP

Una clase se compone de una **definición** (qué tiene) y una **implementación** (qué hace). La interfaz `IF_OO_ADT_CLASSRUN` obliga a implementar el método `main`, con un parámetro `out` para escribir en la consola. `out->write( )` acepta texto, números, estructuras y tablas internas completas.

## La plantilla de todos los ejercicios

1. Clic derecho en tu paquete `ZEJ` → **New → ABAP Class**. Un nombre por ejercicio, por ejemplo `ZCL_EJ_01`.
2. Pega la plantilla y cambia el nombre de la clase en las dos líneas donde aparece.
3. Escribe tu código dentro de `main`. Guarda (**Ctrl+S**), activa (**Ctrl+F3**) y ejecuta (**F9**).

```abap
CLASS zcl_tl_ej02 DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_tl_ej02 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Aqui va tu codigo de prueba
    out->write( 'Hola desde ABAP Cloud' ).
  ENDMETHOD.
ENDCLASS.
```

Todas las sentencias terminan en punto. Los comentarios empiezan por una comilla doble `"`.

## Salidas de distintos tipos

```abap
    DATA lv_texto  TYPE string VALUE 'Taller RuedaLibre'.
    DATA lv_numero TYPE i VALUE 42.

    out->write( lv_texto ).
    out->write( lv_numero ).
    out->write( |El taller { lv_texto } tiene { lv_numero } coches| ).
```

## Ejercicios

1. **Primera salida.** Crea tu clase de prueba y haz que escriba tu nombre y el nombre de tu proyecto.
2. **Convención de nombres.** Si tu proyecto de obras se llamara `ZGOR`, ¿qué nombre le pondrías a la tabla de clientes siguiendo la [convención del Anexo B](B_nombres.html)?


---

**Siguiente:** [1.2. Variables, tipos de datos y plantillas de texto](1_2_tipos.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_1_classrun.md){: .fs-2 }
{% endraw %}
