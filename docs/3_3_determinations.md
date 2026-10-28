# 3.3. Determinations

Una *determination* es lógica que **rellena o recalcula campos** cuando ocurre algo: al crear un registro, al cambiar un campo o al guardar. Cubre tres cosas de Odoo: los valores por defecto (`default=`), los `@api.onchange` y los `compute` con `store=True`. En esta unidad las vemos con el presupuesto y la orden del taller, y tú harás que tu ERP calcule solo todo lo que **guarda**: los totales del presupuesto y del parte, la tarifa congelada, los datos copiados del cliente… y que cada obra nazca con su ficha de gastos.

## Cuándo se ejecuta

| Momento | Cuándo | Para qué |
|---|---|---|
| `on modify` | Al crear o al cambiar los campos indicados, mientras se edita | Valores por defecto y cálculos que el usuario debe ver al momento: el equivalente de `@api.onchange` |
| `on save` | Al guardar, justo antes de escribir en la base de datos | Lo que solo tiene sentido al final, como el código visible (3.7) |

Los disparadores van entre llaves:

```bdef
  determination valoresIniciales  on modify { create; }
  determination copiarTitular     on modify { field TitularUUID; }
  determination recalcularPorTipo on modify { field Impuesto; }
```

`create` se dispara al crear el registro; `field X`, cuando cambia ese campo. Se pueden combinar: `{ create; field Cantidad, PrecioUnitario; }`.

## El patrón de toda determination

Todas siguen tres pasos: **leer** las instancias afectadas, **calcular** y **escribir** con `MODIFY ... IN LOCAL MODE`. Así pone el taller los valores iniciales de un presupuesto:

```abap
  METHOD valoresIniciales.
    " 1. Leer
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto Situacion Fecha ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " 2 y 3. Calcular y escribir (solo lo que esta vacio)
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Impuesto Situacion Fecha )
        WITH VALUE #( FOR ls IN lt_presupuestos
                      ( %tky      = ls-%tky
                        Impuesto  = COND #( WHEN ls-Impuesto IS INITIAL THEN 21 ELSE ls-Impuesto )
                        Situacion = COND #( WHEN ls-Situacion IS INITIAL
                                            THEN zif_tl_tipos=>situacion_presupuesto-borrador
                                            ELSE ls-Situacion )
                        Fecha     = COND #( WHEN ls-Fecha IS INITIAL
                                            THEN cl_abap_context_info=>get_system_date( )
                                            ELSE ls-Fecha ) ) ).
  ENDMETHOD.
```

- `keys` trae las claves (`%tky`) de las instancias que han disparado la determination: puede ser más de una a la vez.
- `WITH CORRESPONDING #( keys )` lee exactamente esas.
- **Solo se rellena lo que está vacío**, para no pisar lo que haya escrito el usuario. Un impuesto de 0 % escrito al crear el presupuesto se convertiría en 21: es el mismo comportamiento que un `default=` de Odoo, que solo actúa si no se da otro valor.

## Leer de otro objeto de negocio

`copiarTitular` copia en el presupuesto la razón social y el documento del titular. Los lee de **otro BO**, `zi_tltitular`, con un `READ ENTITIES` normal, sin `IN LOCAL MODE`, porque no es el nuestro:

```abap
  METHOD copiarTitular.
    " 1. Leer de NUESTRO BO (local mode) que titular tiene cada presupuesto
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    DELETE lt_presupuestos WHERE TitularUUID IS INITIAL.   " sin titular, nada que copiar
    CHECK lt_presupuestos IS NOT INITIAL.

    " 2. Leer del OTRO BO (sin local mode) los datos de esos titulares
    READ ENTITIES OF zi_tltitular
      ENTITY Titular FIELDS ( RazonSocial DocumentoId )
      WITH VALUE #( FOR ls IN lt_presupuestos ( TitularUUID = ls-TitularUUID ) )
      RESULT DATA(lt_titulares).

    " 3. Escribir la copia en cada presupuesto
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( TitularNombre TitularDocumento )
        WITH VALUE #( FOR ls IN lt_presupuestos
                      " t: el titular de este presupuesto (fila vacia si no se encuentra)
                      LET t = VALUE #( lt_titulares[ TitularUUID = ls-TitularUUID ] OPTIONAL ) IN
                      ( %tky             = ls-%tky
                        TitularNombre    = t-RazonSocial
                        TitularDocumento = t-DocumentoId ) ).
  ENDMETHOD.
```

- `CHECK` sale del método si la condición no se cumple: si ningún presupuesto tiene titular, no hay nada que copiar.
- `LET t = ... IN` declara una variable auxiliar dentro del `FOR`. `VALUE #( tabla[ ... ] OPTIONAL )` devuelve una fila vacía en lugar de una excepción si no la encuentra.
- Como solo se dispara al **cambiar** `TitularUUID`, los datos quedan congelados después: si el titular cambia de razón social, sus presupuestos no cambian.
- Si hay que pasar un campo de un BO a un método de la clase de reglas con otro tipo (un `char` a un `string`, un `dec` a un `decfloat34`), conviértelo con `CONV #( )`.

## Recalcular la cabecera desde los hijos

Los importes del presupuesto dependen de sus partidas y de su impuesto. Para no escribir el cálculo dos veces, va en una **acción interna** de la raíz, que solo puede llamar el propio BO:

```bdef
  // Solo la puede llamar el propio BO (no sale como boton)
  internal action recalcularImportes;
  // Si cambia el impuesto, recalcular
  determination recalcularPorTipo on modify { field Impuesto; }
  ...
  // en la entidad Partida:
  determination calcularPartida on modify { create; field Cantidad, PrecioUnitario; }
```

```abap
  METHOD recalcularImportes.
    " Una sola lectura para dos cosas: las cabeceras y, por la composicion, sus partidas
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_presupuestos)
      ENTITY Presupuesto BY \_Partidas FIELDS ( Cantidad PrecioUnitario ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_partidas).

    " Tabla con el tipo exacto que espera el UPDATE de la entidad Presupuesto
    DATA lt_update TYPE TABLE FOR UPDATE zi_tlpresupuesto\\Presupuesto.
    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      " Las partidas de este presupuesto, en el formato de la clase de reglas
      DATA(lt_calculo) = VALUE zif_tl_tipos=>tt_partidas(
        FOR p IN lt_partidas WHERE ( PresupuestoUUID = ls_presu-PresupuestoUUID )
        ( cantidad = p-Cantidad precio_unitario = p-PrecioUnitario ) ).
      " Las formulas son las del Bloque 1: no se repiten, se llaman
      DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( lt_calculo ).
      APPEND VALUE #( %tky    = ls_presu-%tky
                      Neto    = lv_neto
                      Cuota   = zcl_tl_calculos=>cuota_impuesto( iv_neto = lv_neto iv_impuesto = CONV #( ls_presu-Impuesto ) )
                      Importe = zcl_tl_calculos=>importe_presupuesto( iv_neto     = lv_neto
                                                                      iv_impuesto = CONV #( ls_presu-Impuesto ) ) )
        TO lt_update.
    ENDLOOP.

    " Escribir todas las cabeceras de una vez
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto UPDATE FIELDS ( Neto Cuota Importe ) WITH lt_update.
  ENDMETHOD.
```

**Las fórmulas no se repiten, se llaman**: son las de la clase de reglas, con sus tests del Bloque 1. Es la razón de haberlas escrito primero.

La partida calcula su importe y pide a su cabecera que se recalcule:

```abap
  METHOD calcularPartida.
    " 1. El importe de cada partida cambiada
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida FIELDS ( Cantidad PrecioUnitario ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida
        UPDATE FIELDS ( ImportePartida )
        WITH VALUE #( FOR p IN lt_partidas
                      ( %tky           = p-%tky
                        ImportePartida = zcl_tl_calculos=>importe_partida(
                                           iv_cantidad        = p-Cantidad
                                           iv_precio_unitario = CONV #( p-PrecioUnitario ) ) ) ).

    " 2. Sus presupuestos (navegando al padre), cada uno una sola vez
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Partida BY \_Presupuesto FIELDS ( PresupuestoUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cabeceras).
    SORT lt_cabeceras BY PresupuestoUUID.
    DELETE ADJACENT DUPLICATES FROM lt_cabeceras COMPARING PresupuestoUUID.

    " 3. Pedir a cada cabecera que se recalcule
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto EXECUTE recalcularImportes FROM CORRESPONDING #( lt_cabeceras ).
  ENDMETHOD.
```

`BY \_Presupuesto` lee el padre de cada partida. Si se han cambiado dos partidas del mismo presupuesto, saldría dos veces: por eso se quitan los duplicados antes de recalcular.

**¿Y si se borra una partida?** El borrado no es un cambio de `Cantidad` ni de `PrecioUnitario`, así que `calcularPartida` no se dispara. Para que los importes queden bien al guardar, la acción `Prepare` (que Fiori ejecuta justo antes de guardar un borrador) recalcula siempre:

```bdef
  // Al guardar, recalcular siempre (cubre el borrado de partidas)
  determination importesAlGuardar on save { create; update; }
  // Prepare se ejecuta antes de activar un borrador: aqui se le dice que la incluya
  draft determine action Prepare { determination ( always ) importesAlGuardar; }
```

`importesAlGuardar` solo hace `EXECUTE recalcularImportes` con sus `keys`. Mientras se edita, tras borrar una partida, el importe que se ve está desfasado hasta guardar. Si tu versión de RAP admite `delete` como disparador del hijo (`on modify { create; delete; field ... }`), se recalcula al momento: lo comprobarás en un ejercicio.

## Avisar a la interfaz: *side effects*

Las *determinations* recalculan en el servidor, pero Fiori **no se entera**. Cuando el usuario cambia la cantidad de una partida en un presupuesto en edición, la app envía ese cambio al borrador y vuelve a leer **solo la partida** (lo que ha tocado). `calcularPartida` ha recalculado también el neto, la cuota y el importe del presupuesto, pero la cabecera sigue mostrando los valores de antes hasta que se recarga la página. Para el usuario, la app parece rota.

Los ***side effects*** le dicen a Fiori qué más tiene que volver a leer. Se declaran en la BDEF, en cada entidad:

```bdef
define behavior for ZI_TlPresupuesto alias Presupuesto
...
{
  ...
  // Que mas tiene que volver a leer Fiori despues de cada cambio
  side effects
  {
    field Impuesto affects field Cuota, field Importe;
    action aceptar affects $self;
  }
}

define behavior for ZI_TlPartida alias Partida
...
{
  ...
  side effects
  {
    // Cambiar una partida refresca su importe y los de su cabecera
    field Cantidad, PrecioUnitario affects field ImportePartida,
                                           field _Presupuesto.Neto,
                                           field _Presupuesto.Cuota,
                                           field _Presupuesto.Importe;
  }
}
```

- `field X affects field Y`: si cambia `X`, vuelve a leer `Y`.
- `field _Presupuesto.Neto`: un campo de **otra** entidad, a través de una association (aquí, la cabecera de la partida).
- `action aceptar affects $self`: tras ejecutar la acción, vuelve a leer el registro entero.
- La BDEF de **proyección** (4.1) tiene que declarar `use side effects;` para que los publique el servicio.

Es la otra mitad de un `@api.onchange` de Odoo: allí, el formulario pinta solo todo lo que devuelve el método; en RAP la lógica (*determination*) y el aviso a la interfaz (*side effect*) son piezas separadas, y es muy fácil olvidar la segunda. Los *side effects* no cambian datos: solo dicen qué refrescar. Por eso no se notan en los tests con EML, sino en la app (4.6).

> **Comprueba en tu versión** la sintaxis exacta para los campos de otra entidad y para el borrado de un hijo (por ejemplo, `entity _Partidas affects field Importe` en la cabecera). Si el editor no la acepta, pulsa **Ctrl+Espacio** dentro de `side effects` para ver las opciones.

## Crear un hijo: la hoja de costes

La orden del taller debe nacer con su hoja de costes. Lo hace una determination de la orden que crea el hijo a través de la composición:

```bdef
  // Al crear la orden, crear tambien su hoja de costes
  determination crearHojaCostes on modify { create; }
```

```abap
  METHOD crearHojaCostes.
    " Las hojas que ya tengan estas ordenes (normalmente ninguna)
    READ ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden BY \_HojaCostes FIELDS ( HojaUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hojas).

    " Tipo de la tabla para crear hijos por la composicion _HojaCostes
    DATA lt_crear TYPE TABLE FOR CREATE zi_tlorden\\Orden\_HojaCostes.
    LOOP AT keys INTO DATA(ls_key).
      " Nunca dos hojas para la misma orden
      CHECK NOT line_exists( lt_hojas[ OrdenUUID = ls_key-OrdenUUID ] ).
      APPEND VALUE #( %tky    = ls_key-%tky
                      %target = VALUE #( ( %cid      = |HOJA{ sy-tabix }|
                                           %is_draft = ls_key-%is_draft
                                           Garantia  = abap_false ) ) ) TO lt_crear.
    ENDLOOP.
    CHECK lt_crear IS NOT INITIAL.                    " nada que crear

    MODIFY ENTITIES OF zi_tlorden IN LOCAL MODE
      ENTITY Orden CREATE BY \_HojaCostes FIELDS ( Garantia ) WITH lt_crear.
  ENDMETHOD.
```

`%is_draft` en el hijo: si la orden se está creando como borrador, su hoja también lo es, y se guardarán juntas. La asociación es `internal create` (3.1): desde Fiori no se puede crear una hoja suelta, pero la lógica de la orden sí puede.

## Preparación del entorno de trabajo

Se amplían tus BDEF de 3.1 y tus clases de 3.2. Tras añadir cada determination a la BDEF, crea su método con **Ctrl+1** → *Add missing method*. Activa la BDEF y la clase juntas.

## Ejercicios

Para crear los métodos no hace falta escribir la firma a mano: después de declarar una pieza en la BDEF, pon el cursor sobre su nombre y pulsa **Ctrl+1** → *Add missing method*. Eclipse la añade a la clase local de esa entidad con la firma correcta. Las firmas son de dos tipos:

```abap
" Una determination: se ejecuta sola cuando se cumple su disparador
METHODS valoresPorDefecto FOR DETERMINE ON MODIFY
  IMPORTING keys FOR Presupuesto~valoresPorDefecto.

" Una accion (tambien las internas): se ejecuta cuando alguien la llama con EXECUTE
METHODS recalcularTotales FOR MODIFY
  IMPORTING keys FOR ACTION Presupuesto~recalcularTotales.
```

Las de `on save` son iguales, pero con `FOR DETERMINE ON SAVE`.

1. **El presupuesto.**
    - **Dónde:** BDEF `ZI_GorPresupuesto`; clase `zbp_i_gorpresupuesto`, clases locales `lhc_presupuesto` y `lhc_linea`.
    - **En la BDEF:** seis piezas, cada una con un comentario `//` que diga qué hace:

        | Pieza | Entidad | Declaración | Qué hace (informe) |
        |---|---|---|---|
        | `valoresPorDefecto` | `Presupuesto` | `determination valoresPorDefecto on modify { create; }` | `Iva` 21, `Estado` `no_aprobado` y `Fecha` de hoy, si están vacíos (§3.6) |
        | `copiarCliente` | `Presupuesto` | `determination copiarCliente on modify { field ClienteUUID; }` | Copia en `NombreCliente` el nombre completo del cliente (usa tu `nombre_completo`) y su `Nif`, `Direccion` y `Telf` (§3.6, `_onchange_cliente_id`) |
        | `recalcularTotales` | `Presupuesto` | `internal action recalcularTotales;` | `BaseImponible`, `CuotaIva` y `Total` desde las líneas, con tus `base_imponible`, `cuota_iva` y `total_presupuesto` |
        | `recalcularPorIva` | `Presupuesto` | `determination recalcularPorIva on modify { field Iva; }` | Ejecuta `recalcularTotales` |
        | `totalesAlGuardar` | `Presupuesto` | `determination totalesAlGuardar on save { create; update; }`, y en `Prepare` con `determination ( always ) totalesAlGuardar;` | Ejecuta `recalcularTotales` |
        | `calcularLinea` | `Linea` | `determination calcularLinea on modify { create; field Uds, Precio; }` | `TotalLinea` con tu `total_linea`, y ejecuta `recalcularTotales` en su presupuesto |

    - **Firmas:** con **Ctrl+1** sobre cada nombre, como se explica arriba.
    - **Qué hace cada método:** los tres pasos del taller: leer con `READ ENTITIES ... IN LOCAL MODE`, calcular con tu `zcl_gor_reglas` y escribir con `MODIFY ENTITIES ... IN LOCAL MODE`. `copiarCliente` lee el cliente de **otro** BO (`zi_gorcliente`), sin `IN LOCAL MODE`, como `copiarTitular`.
    - **Comprueba:** activa la BDEF y la clase sin errores. El comportamiento se prueba en el ejercicio 2.

2. **Pruébalo con EML.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.3 Valores por defecto y totales`.
    - **Qué hace:** crea, como en el ejercicio 6 de 3.2, un presupuesto **sin IVA ni estado** para Elena con una línea de 10 × 100, y guarda. Después léelo con `SELECT SINGLE FROM zi_gorpresupuesto FIELDS Iva, Estado, Fecha, NombreCliente, Telf, BaseImponible, Total WHERE ...` y escríbelo.
    - **Comprueba:** IVA 21, estado `no_aprobado`, fecha de hoy, `Elena Vidal Soler` y su teléfono copiados, base 1000 y total **1210** (paso 2 de §12.7). Si el total sale 0, revisa que `calcularLinea` llama a `recalcularTotales` del presupuesto (con `EXECUTE` sobre `ENTITY Presupuesto`), y no solo calcula la línea.

3. **La obra y su gasto.**
    - **Dónde:** BDEF `ZI_GorObra`, entidad `Obra`; clase `zbp_i_gorobra`, clase local `lhc_obra`.
    - **En la BDEF:** `determination crearGasto on modify { create; }`.
    - **Qué hace:** crea la ficha de gastos de la obra si no la tiene (§11.5, punto 5), con `MODIFY ENTITIES ... IN LOCAL MODE ENTITY Obra CREATE BY \_Gasto`, como `crearHojaCostes` del taller. Antes de crearla, lee con `READ ENTITIES ... BY \_Gasto` si ya existe.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, crea una obra con EML y guarda. `SELECT COUNT( * ) FROM zi_gorgasto WHERE ObraUUID = ...` debe dar **1**. Modifica la descripción de la misma obra y guarda: sigue dando 1, porque el disparador es solo `create`.

4. **El resto.** Añade estas determinations, cada una en la BDEF y la clase local de su entidad, con **Ctrl+1** para la firma:

    | BO / entidad | Determination | Disparador | Qué hace (informe) |
    |---|---|---|---|
    | Trabajador | `valoresPorDefecto` | `create` | `CosteHoraEstandar` 20 si está vacío (§3.2) |
    | Falta | `calcularDias` | `create; field FechaInicio, FechaFin` | `Dias` con tu `dias_falta`; `Tipo` `vacaciones` y fechas de hoy si están vacíos (§3.12) |
    | Proveedor | `calcularTotal` | `create; field Base, Iva` | `Total` con tu `total_proveedor` (§3.3) |
    | Ingreso | `valoresPorDefecto` | `create` | `Fecha` de hoy |
    | Ingreso | `copiarDeObra` | `field ObraUUID` | `NombreObra` = descripción de la obra y `ClienteUUID` = su cliente (§3.8, `_onchange_obra_id`) |
    | Presupuesto | `clienteDeObra` | `field ObraUUID` | Si la obra tiene cliente, lo pone como cliente del presupuesto (§3.6, `_onchange_obra_id`). Al cambiar `ClienteUUID` se disparará sola `copiarCliente` |
    | Parte de trabajo | `valoresPorDefecto` | `create` | `Fecha` de hoy |
    | Parte de trabajo | acción interna `recalcularTotales` | — | `HorasTotales` y `CosteTotal` con tus `horas_parte` y `coste_parte` (§3.9) |
    | Línea de parte | `congelarTarifa` | `field TrabajadorUUID` | `CosteHora` = `CosteHoraEstandar` del trabajador (§3.9, `_onchange_trabajador_id`) |
    | Línea de parte | `calcularSubtotal` | `create; field Horas, CosteHora` | `CosteSubtotal` con tu `coste_subtotal`, y recalcula su parte |
    | Partes de especialista y de proveedor | `valoresPorDefecto` | `create` | `Fecha` de hoy y `EstadoPago` `pendiente` |

    Para comprobar las de la falta y el proveedor, añade un bloque `" 3.3 El resto` a `ZCL_GOR_EML_DEMO`: crea una falta de `TRB0001` del 01/12/2026 al 05/12/2026 y un proveedor con base 100 e IVA 21, guarda y lee con `SELECT`: **5** días y total **121**. Las del ingreso y el parte se prueban en los ejercicios siguientes y en 3.8.

5. **Los *side effects*.**
    - **Dónde:** BDEF `ZI_GorPresupuesto` y BDEF `ZI_GorParteTrabajo`, un bloque `side effects { ... }` dentro de las llaves de cada entidad, como en el taller.
    - **Qué contiene:**
        - en `Linea`: `field Uds, Precio affects field TotalLinea, field _Presupuesto.BaseImponible, field _Presupuesto.CuotaIva, field _Presupuesto.Total;`
        - en `Presupuesto`: `field Iva affects field CuotaIva, field Total;`, y `action aprobar affects $self;` y `action desaprobar affects $self;` (las acciones las crearás en 3.5: añade estas dos líneas entonces);
        - en la línea del parte de trabajo: `field Horas, CosteHora, TrabajadorUUID affects field CosteHora, field CosteSubtotal, field _Parte.HorasTotales, field _Parte.CosteTotal;`
    - **Comprueba:** activa sin errores. El efecto solo se ve en la app: lo comprobarás en 4.6, cambiando unidades en una línea y viendo que el total de la cabecera cambia sin recargar.

6. **La tarifa congelada.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.3 Tarifa congelada`.
    - **Qué hace:** crea un parte de trabajo para `OBR0001` con una línea de 8 h de `TRB0001` (20 €/h) y guarda. Cambia con `MODIFY ... UPDATE` la tarifa de `TRB0001` a 25 y guarda. Lee la línea con `SELECT SINGLE ... CosteHora, CosteSubtotal`. Al final, deja la tarifa otra vez en 20.
    - **Comprueba:** `CosteHora` sigue en **20** y `CosteSubtotal` en **160** (paso 5 de §12.7): la línea guardó la tarifa del momento y no le afecta el cambio posterior.

7. **De nuevo la ficha.** Ejecuta `ZCL_GOR_COMPROBAR_CDS` (2.5): el parte del ejercicio 6 suma 160 € a `OBR0001`, así que fallarán sus gastos y su beneficio. ¿Coinciden los nuevos valores con lo que esperas? Vuelve a ejecutar `ZCL_GOR_DATOS_DEMO` para dejar los datos como estaban.

8. **Investiga.** Prueba a añadir `delete` al disparador de `calcularLinea` y activa. Si tu sistema lo acepta, comprueba con EML que borrar una línea recalcula el total sin esperar a guardar. Si no, anota el mensaje. En los dos casos, explica en un comentario de la BDEF por qué existe `totalesAlGuardar`.

## Comprueba tu solución automáticamente (opcional)

Pega [3_3_ltcl_determinations.abap](materiales/tests/3_3_ltcl_determinations.abap) en la pestaña **Test Classes** de `zbp_i_gorpresupuesto` y ejecuta con **Ctrl+Shift+F10**: **3 tests en verde**. Estos tests usan EML sobre **dobles** de las tablas: no tocan tus datos de demo. Cómo funciona se explica en [3.8](./3_8_proyecto.md).

---

**Siguiente:** [3.4. Validations](./3_4_validations.md)
