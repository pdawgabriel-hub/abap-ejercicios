# 3.7. Numeración

En Odoo, cada `create()` toma el siguiente número de su secuencia `ir.sequence` y forma el código: `CLI0001`, `OBR0001`… (§10 del informe). La empresa se refiere a todo por esos códigos (§11.5, punto 8). En esta unidad vemos cómo lo hace el taller con sus titulares (`TIT0001`), y tú harás que los ocho objetos con código de tu ERP lo reciban **al guardar**.

## Estrategias de numeración en RAP

| Estrategia | Cómo funciona | Cuándo |
|---|---|---|
| **UUID como clave + código visible al guardar** | La clave es el UUID que genera RAP (`numbering : managed`); el código es un campo normal que rellena una determination *on save* | El caso más sencillo y robusto. **El nuestro** |
| *Early numbering* | La clave se asigna nada más crear, con un método propio | Cuando el código **es** la clave y el usuario debe verlo desde el principio |
| *Late numbering* | La clave se asigna justo antes de escribir en la base de datos (`adjust_numbers`) | Cuando la clave no puede tener huecos |

Con nuestra estrategia, el usuario ve el código en cuanto guarda. Mientras edita el borrador, el campo está vacío. Es lo mismo que en Odoo, donde el código vale «Nuevo» hasta guardar.

## Máximo + 1

La versión sencilla busca el código más alto que existe y suma 1:

```bdef
  // on save: el codigo se pone al guardar, no mientras se edita el borrador
  determination numerar on save { create; }
```

```abap
  METHOD numerar.
    " Los titulares que se estan guardando...
    READ ENTITIES OF zi_tltitular IN LOCAL MODE
      ENTITY Titular FIELDS ( TitularRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_titulares).
    " ...que todavia no tienen codigo
    DELETE lt_titulares WHERE TitularRef IS NOT INITIAL.
    CHECK lt_titulares IS NOT INITIAL.

    " El codigo mas alto guardado: TIT0041
    SELECT SINGLE FROM ztl_tit FIELDS MAX( titular_ref ) INTO @DATA(lv_maxima).
    " TIT0041 -> 41 (si no hay ninguno, 0)
    DATA(lv_ultimo) = COND i( WHEN lv_maxima IS INITIAL THEN 0
                              ELSE CONV i( substring( val = lv_maxima off = 3 ) ) ).

    " Cada titular nuevo, el siguiente: 42, 43... (i vale 1, 2, 3...)
    MODIFY ENTITIES OF zi_tltitular IN LOCAL MODE
      ENTITY Titular
        UPDATE FIELDS ( TitularRef )
        WITH VALUE #( FOR ls IN lt_titulares INDEX INTO i
                      ( %tky       = ls-%tky
                        TitularRef = zcl_tl_calculos=>componer_codigo( iv_serie  = `TIT`
                                                                       iv_numero = lv_ultimo + i ) ) ).
  ENDMETHOD.
```

- `DELETE ... WHERE TitularRef IS NOT INITIAL`: no se renumera nada que ya tenga código.
- `MAX( titular_ref )` funciona sobre un texto porque todos los códigos tienen el mismo prefijo y 4 cifras con ceros: `TIT0010` va detrás de `TIT0009`.
- `substring( ... off = 3 )` se salta las tres letras de la serie. En el taller todas las series tienen tres letras; en tu ERP no (`PROV`, `PREP`).
- `INDEX INTO i`: si se guardan varios titulares a la vez, cada uno recibe el siguiente número.

**Su límite.** Si dos usuarios guardan un titular **a la vez**, los dos pueden leer el mismo máximo y obtener el mismo código. En una empresa pequeña es poco probable, pero posible. En Odoo no pasa porque `ir.sequence` reserva el número en la base de datos. El equivalente en ABAP Cloud son los **rangos de números**.

## Rangos de números

Un *Number Range Object* es un contador que el sistema reserva de forma segura aunque haya muchos usuarios a la vez. Se crea en ADT (*New → Other ABAP Repository Object → Number Range Object*) y se consume con la clase liberada `CL_NUMBERRANGE_RUNTIME`:

```abap
    TRY.
        " Pedir al sistema el siguiente numero del contador, de forma segura
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'                  " el intervalo del rango
            object      = 'ZTL_TIT'             " el Number Range Object
          IMPORTING
            number      = DATA(lv_numero) ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_rango).
        " sin rango configurado: marcar la instancia como fallida y avisar
    ENDTRY.
```

Después, `componer_codigo( iv_serie = `TIT` iv_numero = CONV #( lv_numero ) )` como antes.

> **Variante poco verificada.** El nombre exacto de los parámetros y excepciones de la API, y cómo se mantienen los intervalos del rango, dependen de la versión del sistema. Antes de usarla, mira la documentación de `CL_NUMBERRANGE_RUNTIME` con **F2** en Eclipse. Para el portfolio, el máximo + 1 es suficiente si lo explicas en el README.

> **Código completo del taller:** el método `numerar` de cada clase de comportamiento, por ejemplo [zbp_i_tltitular](./materiales/taller/src/bus/zbp_i_tltitular.clas.locals_imp.abap). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Se amplían tu `ZCL_GOR_REGLAS` (y su pestaña de tests) y tus BDEF y clases de los ocho BO con código.

## Ejercicios

1. **Leer el número de un código.**
    - **Dónde:** `ZCL_GOR_REGLAS`, un método estático nuevo junto a `formatear_codigo`.
    - **Firma:** `CLASS-METHODS numero_de_codigo IMPORTING iv_codigo TYPE string iv_prefijo TYPE string RETURNING VALUE(rv_numero) TYPE i.`
    - **Qué hace:** devuelve 0 si el código está vacío y, si no, el número que sigue al prefijo, sea cual sea su longitud (`OBR0041` → 41, `PROV0123` → 123). Es el inverso de tu `formatear_codigo`. Pista: `substring( val = iv_codigo off = strlen( iv_prefijo ) )`.
    - **Comprueba:** con el test de abajo, o escribiendo en `ZCL_GOR_EML_DEMO` `zcl_gor_reglas=>numero_de_codigo( iv_codigo = 'PROV0123' iv_prefijo = 'PROV' )`: **123**.

2. **El código del cliente.**
    - **Dónde:** BDEF `ZI_GorCliente`, entidad `Cliente`; clase local `lhc_cliente`.
    - **En la BDEF:** `determination asignarCodigo on save { create; }`, como `numerar` del taller.
    - **Qué hace:** lee los clientes nuevos sin `ClienteId`, busca el mayor código con `SELECT MAX( cliente_id ) FROM zgor_cli`, y da a cada uno el siguiente con tus `numero_de_codigo` y `formatear_codigo`, sumando 1 en cada vuelta.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, crea dos clientes en el **mismo** `MODIFY` y guarda. Con los datos de demo de 2.5, `SELECT cliente_id FROM zgor_cli ORDER BY cliente_id DESCENDING UP TO 2 ROWS` debe devolver `CLI0007` y `CLI0006`.

3. **Los demás.** Haz lo mismo, con su determination `asignarCodigo` en la BDEF y la clase local de cada uno, en los otros siete:

    | BO / entidad | Campo | Tabla | Prefijo |
    |---|---|---|---|
    | Trabajador | `TrabajadorId` | `zgor_trab` | `TRB` |
    | Proveedor | `ProveedorId` | `zgor_prov` | `PROV` |
    | Especialista | `EspecialistaId` | `zgor_esp` | `ESP` |
    | Presupuesto | `PresupuestoId` | `zgor_presu` | `PREP` |
    | Obra | `ObraId` | `zgor_obra` | `OBR` |
    | Gasto (hijo de la obra) | `GastoId` | `zgor_gasto` | `GAS` |
    | Ingreso | `IngresoId` | `zgor_ing` | `ING` |

    Como el método es casi igual en los ocho, piensa si merece la pena sacar el `SELECT MAX` a un método de una clase auxiliar. Si lo haces, ten en cuenta que cada uno lee una tabla distinta.
4. **La obra y su ficha.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.7 Codigos`.
    - **Qué hace:** crea una obra con EML, guarda y lee `ObraId, \_Gasto-GastoId AS GastoId` de `zi_gorobra` para esa obra.
    - **Comprueba:** la obra tiene `OBR0005` **y** su ficha de gastos `GAS0005`: la ficha la creó una determination *on modify* de la obra (3.3), y su código, la determination *on save* del gasto.
5. **Investiga.** En tu ERP, ¿qué pasa con los códigos si borras el cliente `CLI0007` y creas otro? ¿Y si borras `CLI0005`? Compáralo con lo que hace `ir.sequence` en Odoo. Anota la diferencia en `diseno.md`, junto con el límite de varios usuarios, para el README.

## Comprueba tu solución automáticamente (opcional)

Pega [3_7_ltcl_codigos.abap](materiales/tests/3_7_ltcl_codigos.abap) en la pestaña **Test Classes** de `ZCL_GOR_REGLAS`, debajo de las de 1.8: **36 tests en verde** (34 + 2).

---

**Siguiente:** [3.8. Proyecto: el escenario completo como test](./3_8_proyecto.md)
