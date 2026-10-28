# 1.7. Excepciones

Las fórmulas ya están; faltan las **validaciones**: lo que el sistema no debe aceptar nunca. En el taller, un tramo de 12 horas o un albarán de 0 € ([0.5](./0_5_taller.md)). En Odoo, cada `@api.constrains` lanza un `ValidationError`; en ABAP se hace igual: se **lanza una excepción**. En esta unidad vemos cómo, con la excepción del taller, y tú crearás la de tu ERP y los métodos que comprueban las reglas de §11.4. En el Bloque 3, las *validations* de RAP llamarán a esos mismos métodos y convertirán la excepción en el mensaje que ve el usuario.

## Capturar una excepción: `TRY ... CATCH`

Algunas operaciones fallan con una excepción: leer de una tabla una fila que no existe, dividir entre cero o convertir un texto que no es un número. Si nadie la captura, el programa se detiene con un error en tiempo de ejecución (un *dump*).

```abap
    DATA(lt_refs) = VALUE zif_tl_tipos=>tt_refs( ( 'ORD0001' ) ( 'ORD0002' ) ).

    TRY.
        DATA(lv_ref) = lt_refs[ 5 ].
        out->write( lv_ref ).
      CATCH cx_sy_itab_line_not_found.
        out->write( 'No hay quinta orden' ).
    ENDTRY.

    TRY.
        DATA(lv_media) = 100 / 0.
      CATCH cx_sy_zerodivide INTO DATA(lx_cero).
        out->write( lx_cero->get_text( ) ).     " el texto de la excepcion
    ENDTRY.
```

- Entre `TRY` y `CATCH` va el código que puede fallar. Si falla, salta al `CATCH` de esa excepción; el resto del bloque `TRY` no se ejecuta.
- `INTO DATA(lx_...)` guarda el **objeto** de la excepción: una excepción es un objeto de una clase, y `get_text( )` devuelve su mensaje.
- Puede haber varios `CATCH`. El primero que encaja es el que se ejecuta.

## Tres clases de excepciones

Todas las excepciones heredan de `CX_ROOT`, a través de una de estas tres:

| Superclase | Qué exige el compilador | Para qué |
|---|---|---|
| `CX_STATIC_CHECK` | Que quien llama la capture o la declare con `RAISING`; si no, avisa al activar | Errores **previstos** que quien llama debe tratar: las reglas de negocio |
| `CX_DYNAMIC_CHECK` | Nada al compilar; si no se captura, *dump* | Errores que se pueden evitar comprobando antes (`cx_sy_zerodivide`) |
| `CX_NO_CHECK` | Nada | Errores graves del sistema |

Una regla de negocio incumplida es un error previsto: las excepciones de reglas heredan de `CX_STATIC_CHECK`.

## La excepción del taller

Una clase de excepción es una clase normal que hereda de una de las tres anteriores. La del taller guarda el **mensaje** y el **elemento** (el campo) al que se refiere. En el Bloque 3, el elemento servirá para que Fiori marque en rojo la casilla concreta.

```abap
CLASS zcx_tl_aviso DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_mensaje  TYPE string READ-ONLY.
    DATA mv_elemento TYPE string READ-ONLY.
    METHODS constructor
      IMPORTING iv_mensaje  TYPE string OPTIONAL
                iv_elemento TYPE string OPTIONAL
                previous    LIKE previous OPTIONAL.
    METHODS if_message~get_text REDEFINITION.
ENDCLASS.

CLASS zcx_tl_aviso IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    mv_mensaje  = iv_mensaje.
    mv_elemento = iv_elemento.
  ENDMETHOD.

  METHOD if_message~get_text.
    result = mv_mensaje.
  ENDMETHOD.
ENDCLASS.
```

- `INHERITING FROM` indica la superclase; `super->constructor( )` llama a su constructor, que en las excepciones es obligatorio.
- `READ-ONLY` permite leer el atributo desde fuera (`lx_aviso->mv_elemento`) pero no cambiarlo.
- `REDEFINITION` sustituye el método `get_text` heredado: así, `get_text( )` devuelve nuestro mensaje.
- `##ADT_SUPPRESS_GENERATION` es un *pragma*: le dice a Eclipse que no regenere el constructor por su cuenta.
- `previous` permite **encadenar** una excepción con la que la causó.

Al crear la clase, Eclipse ofrece la plantilla de *Exception Class*; se sustituye entera.

En proyectos grandes, los textos se guardan en una **clase de mensajes** y la excepción implementa `IF_T100_MESSAGE`, para poder traducirlos. Para un portfolio basta con el texto directo.

## Lanzar una excepción

Un método declara con `RAISING` las excepciones que puede lanzar, y las lanza con `RAISE EXCEPTION NEW`:

```abap
    " Un tramo no puede pasar de 10 horas
    CLASS-METHODS comprobar_tiempo
      IMPORTING iv_tiempo TYPE zif_tl_tipos=>ty_tiempo
      RAISING   zcx_tl_aviso.
```

```abap
  METHOD comprobar_tiempo.
    IF iv_tiempo < 0 OR iv_tiempo > 10.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje  = |Un tramo debe durar entre 0 y 10 horas (dura { iv_tiempo })|
                                        iv_elemento = `Tiempo` ).
    ENDIF.
  ENDMETHOD.
```

`RAISE EXCEPTION` termina el método en ese punto, como un `raise` de Python. Quien llama decide qué hacer: capturarla (`TRY ... CATCH zcx_tl_aviso`) o dejarla pasar declarando `RAISING zcx_tl_aviso` en su propio método. Así, `add_tramo` del registro de jornada (1.6) comprueba el tiempo **antes** de añadir el tramo:

```abap
  METHOD add_tramo.
    zcl_tl_calculos=>comprobar_tiempo( iv_tiempo ).    " si falla, no se anade nada
    APPEND VALUE #( ... ) TO mt_tramos.
  ENDMETHOD.
```

## Preparación del entorno de trabajo

La excepción del ERP va en `ZGOR_BUS`. Al terminar:

```
ZGOR_BUS
├── ZIF_GOR_TIPOS, ZCL_GOR_REGLAS          (ampliada en esta unidad)
├── ZCX_GOR_REGLA                          ← nueva
└── ZCL_GOR_TRABAJADOR, ZCL_GOR_PRESUPUESTO, ZCL_GOR_PARTE_TRABAJO   (1.6; se amplía el parte)
```

## Ejercicios

1. **La excepción del ERP.** Crea `ZCX_GOR_REGLA` (descripción `Regla de negocio incumplida`, superclase `CX_STATIC_CHECK`):

    | Elemento | Definición |
    |---|---|
    | `mv_texto` | Atributo `string` de solo lectura: el mensaje para el usuario |
    | `mv_campo` | Atributo `string` de solo lectura: el campo afectado, con su nombre en *CamelCase* (`Iva`, `Horas`, `FechaFin`…), como se llamará en las vistas del Bloque 2 |
    | `constructor` | Recibe `iv_texto`, `iv_campo` y `previous`, los tres opcionales |
    | `get_text` | Devuelve `mv_texto` |

2. **Las validaciones.** Añade a `ZCL_GOR_REGLAS` estos métodos estáticos, todos con `RAISING zcx_gor_regla`. Son las filas de §11.4 que no dependen de otra entidad:

    | Método | Parámetros | Falla si… | Campo (`mv_campo`) |
    |---|---|---|---|
    | `validar_iva` | `iv_iva` (`ty_porcentaje`) | `iva < 0` o `iva > 100` | `Iva` |
    | `validar_horas` | `iv_horas` (`ty_horas`) | `horas < 0` o `horas > 24` | `Horas` |
    | `validar_importe_positivo` | `iv_importe` (`ty_importe`), `iv_campo` (`string`) | `importe <= 0` | El que se recibe |
    | `validar_no_negativo` | `iv_valor` (`ty_importe`), `iv_campo` (`string`) | `valor < 0` | El que se recibe |
    | `validar_fechas` | `iv_inicio`, `iv_fin` (`d`), `iv_campo` (`string`) | Las dos fechas tienen valor **y** `fin < inicio` | El que se recibe |
    | `validar_obligatorio` | `iv_valor` (`string`), `iv_campo` (`string`) | El valor, sin espacios, está vacío | El que se recibe |

    Los textos deben servir tal cual al usuario: «El IVA debe estar entre 0 y 100 (es 150)», «Las horas de una línea deben estar entre 0 y 24», «El importe debe ser mayor que 0», «La fecha de fin no puede ser anterior a la de inicio», «El campo Nombre es obligatorio»…

3. **Las horas en el parte.** Cambia `add_linea` de `ZCL_GOR_PARTE_TRABAJO` para que declare `RAISING zcx_gor_regla` y no añada la línea si las horas no son válidas.
4. **El escenario, paso 9.** Crea la clase ejecutable `ZCL_GOR_EXC_DEMO`. Cada caso del paso 9 de §12.7 en su propio `TRY`, escribiendo en el `CATCH` el texto y el campo de la excepción: una línea de parte con 25 h, otra con −1 h, un parte externo de 0 €, un IVA de 150 y una falta que termina antes de empezar. Antes de los casos que fallan, comprueba uno que no falla (IVA 21) y escribe «IVA correcto».
5. **Excepciones del sistema.** En la misma clase, lee la quinta fila de una tabla con dos códigos **sin** `TRY` y ejecuta. Mira el *dump*: Eclipse muestra la excepción, el programa y la línea. Después rodea la lectura con el `TRY ... CATCH` adecuado.
6. **Investiga.** ¿Qué pasa si llamas a `validar_iva( 150 )` desde `main` sin `TRY` ni `RAISING`? Activa y mira la pestaña *Problems*: ¿es un error o un aviso? Ejecuta: ¿qué ocurre? Anota la diferencia con una excepción de `CX_DYNAMIC_CHECK` como `cx_sy_zerodivide`.

## Comprueba tu solución automáticamente (opcional)

- Pega [1_7_ltcl_validaciones.abap](materiales/tests/1_7_ltcl_validaciones.abap) en la pestaña **Test Classes** de `ZCL_GOR_REGLAS`, debajo de las anteriores: **31 tests en verde** (24 + 7).
- Pega [1_7_ltcl_parte_horas.abap](materiales/tests/1_7_ltcl_parte_horas.abap) en la de `ZCL_GOR_PARTE_TRABAJO`, debajo de la de 1.6: **3 tests en verde** (2 + 1).

---

**Siguiente:** [1.8. Pruebas con ABAP Unit](./1_8_abapUnit.md)
