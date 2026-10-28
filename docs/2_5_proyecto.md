# 2.5. Proyecto: el ERP con datos

Cerramos el Bloque 2 llenando la base de datos. En Odoo, el `post_init_hook` de `hooks.py` genera al instalar un conjunto de datos de ejemplo coherente (§6 del informe). Aquí haremos lo mismo con una clase de consola, `ZCL_GOR_DATOS_DEMO`, con una diferencia: en vez de datos aleatorios, crearemos **cuatro obras pensadas para probar casos concretos**. La primera es exactamente la del escenario de §12.7. Después comprobaremos que la ficha financiera que calcula `ZI_GorObraFinanzas` coincide, céntimo a céntimo, con la que calculó la simulación de 1.9.

| Apartado | Qué aporta al proyecto |
|---|---|
| 2.1 Tablas | Las 16 tablas que se rellenan |
| 2.2 Vistas | Los nombres con los que se comprueban los datos |
| 2.3 Relaciones | La navegación con rutas: de la obra a su cliente, a sus partes… |
| 2.4 Cálculos | La ficha financiera, que no se inserta: se lee |
| 1.2 a 1.8 | `ZCL_GOR_REGLAS` calcula los campos que **sí** se guardan (totales de presupuesto y de parte, días de falta…) |

## El diseño

**Las cuatro obras** cubren las ramas de cada `case` de `ZI_GorObraFinanzas`:

| Obra | Cliente | Qué tiene | Ficha esperada |
|---|---|---|---|
| `OBR0001` | `CLI0001` Juan Pérez | El escenario de §12.7 completo: presupuesto aprobado de 10 × 100 € (IVA 21), 8 h de `TRB0001` y 8 h de `TRB0002` a 20 €/h, proveedor 200 €, especialista 150 €, cobros de 500 € y 710 € | Total 1210, gastos 670, beneficio 540, debe 0, 100 %, `pagado`, `verde`, `finalizado` |
| `OBR0002` | `CLI0002` Ana Ruiz | Presupuesto aprobado de 1 × 2000 € con IVA 10; 60 h de `TRB0003` a 18 €/h; proveedor 1500 €; cobro de 2200 € | Total 2200, gastos 2580, beneficio −380, debe 0, 100 %, `pagado`, **`rojo`**, `finalizado` |
| `OBR0003` | `CLI0003` Luis Mena | Presupuesto aprobado de 20 × 45 € + 1 × 300 € (IVA 21) y otro **no aprobado** de 800 €; 8 h de `TRB0004` a 25 €/h y 8 h de `TRB0001` a 20 €/h; cobro de 600 € | Total 1452, gastos 360, beneficio 240, debe 852, 41.3 %, `parcial`, `ambar`, `proceso` |
| `OBR0004` | `CLI0004` Marta Gil | Solo un presupuesto **no aprobado** de 1000 € | Todo a 0, `pendiente`, `ambar`, `proceso` |

Además: el cliente `CLI0005` (Construcciones Ebro SL, una empresa sin apellidos) con un presupuesto `PREP0006` **sin obra**, que usaremos en 3.5 para vincularlo; dos faltas de trabajadores, y una ficha de gastos por obra. En el Bloque 3, la ficha la creará RAP automáticamente; aquí la insertamos a mano.

**El modelo: los datos de demo del taller.** El taller tiene su propia clase, `ZCL_TL_DATOS_DEMO`, que carga el caso `ORD0001` de [0.5](./0_5_taller.md) y otras órdenes. Su estructura te sirve de modelo. Cada grupo de datos va en un método, y como unos datos apuntan a otros (la orden al titular, el tramo a la jornada), la clase guarda en una tabla *hashed* el UUID que generó para cada código:

```abap
CLASS zcl_tl_datos_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    " Una pareja codigo -> UUID: 'TIT0001' -> el UUID que se le genero
    TYPES: BEGIN OF ty_uuid,
             ref  TYPE string,
             uuid TYPE sysuuid_x16,
           END OF ty_uuid.
    " Hashed: se busca siempre por el codigo completo, y rapido
    DATA mt_uuids TYPE HASHED TABLE OF ty_uuid WITH UNIQUE KEY ref.

    " nuevo: crea un UUID para un codigo; de: devuelve el que ya se creo
    METHODS nuevo
      IMPORTING iv_ref         TYPE string
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    METHODS de
      IMPORTING iv_ref         TYPE string
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
    " Un metodo por grupo de datos, en el orden en que se llaman
    METHODS vaciar.
    METHODS crear_fichas.
    METHODS crear_caso_ord0001.
    METHODS crear_otras_ordenes.
    METHODS sellar.
ENDCLASS.

CLASS zcl_tl_datos_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Primero se borra todo: asi la clase se puede ejecutar las veces que haga falta
    vaciar( ).
    " Despues, de lo que no depende de nada a lo que depende de otros
    crear_fichas( ).
    crear_caso_ord0001( ).
    crear_otras_ordenes( ).
    sellar( ).
    out->write( |Datos del taller creados: { lines( mt_uuids ) } registros| ).
  ENDMETHOD.

  METHOD nuevo.
    " Genera un UUID y lo apunta con su referencia para usarlo despues
    TRY.
        rv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.
    INSERT VALUE #( ref = iv_ref uuid = rv_uuid ) INTO TABLE mt_uuids.
  ENDMETHOD.

  METHOD de.
    " Si el codigo no existe, lanza cx_sy_itab_line_not_found
    rv_uuid = mt_uuids[ ref = iv_ref ]-uuid.
  ENDMETHOD.
  ...
ENDCLASS.
```

`de` lanza `cx_sy_itab_line_not_found` si se pide una referencia que no se ha creado. Es lo que se quiere: un error en los datos de demo debe verse enseguida, no esconderse.

**Los campos que se guardan se calculan antes de insertar**, con la clase de reglas. Así crea el taller el presupuesto de `ORD0001` y sus partidas:

```abap
    " 1. Las partidas, solo con lo que se teclea
    DATA(lt_partidas) = VALUE zif_tl_tipos=>tt_partidas(
      ( concepto = `Horas de diagnosis` cantidad = 4 precio_unitario = 45 )
      ( concepto = `Kit de embrague`    cantidad = 1 precio_unitario = 320 ) ).
    " 2. Lo que se guarda calculado, con la clase de reglas (no a mano)
    DATA(lv_neto) = zcl_tl_calculos=>neto_presupuesto( lt_partidas ).

    " 3. La cabecera: nuevo( ) crea su UUID; de( ) busca los que ya existen
    DATA lt_prs TYPE STANDARD TABLE OF ztl_prs WITH EMPTY KEY.
    lt_prs = VALUE #( ( presupuesto_uuid  = nuevo( `PRS0001` )
                        presupuesto_ref   = 'PRS0001'
                        fecha             = '20261002'
                        titular_uuid      = de( `TIT0001` )
                        orden_uuid        = de( `ORD0001` )
                        " copia de los datos del titular, como en el presupuesto real
                        titular_nombre    = 'Transportes Moncayo SL'
                        titular_documento = 'B50111222'
                        impuesto          = 21
                        situacion         = zif_tl_tipos=>situacion_presupuesto-aceptado
                        neto              = lv_neto
                        cuota             = zcl_tl_calculos=>cuota_impuesto( iv_neto = lv_neto iv_impuesto = 21 )
                        importe           = zcl_tl_calculos=>importe_presupuesto( iv_neto = lv_neto iv_impuesto = 21 ) ) ).
    INSERT ztl_prs FROM TABLE @lt_prs.

    " 4. Las partidas en la tabla: FOR recorre lt_partidas; INDEX INTO da 1, 2...
    "    para que cada partida tenga su propia referencia (PRS0001-1, PRS0001-2)
    DATA lt_par TYPE STANDARD TABLE OF ztl_prs_par WITH EMPTY KEY.
    lt_par = VALUE #( FOR ls_partida IN lt_partidas INDEX INTO lv_i
                      ( partida_uuid     = nuevo( |PRS0001-{ lv_i }| )
                        presupuesto_uuid = de( `PRS0001` )
                        concepto         = ls_partida-concepto
                        cantidad         = ls_partida-cantidad
                        precio_unitario  = ls_partida-precio_unitario
                        importe_partida  = zcl_tl_calculos=>importe_partida(
                                             iv_cantidad        = ls_partida-cantidad
                                             iv_precio_unitario = ls_partida-precio_unitario ) ) ).
    INSERT ztl_prs_par FROM TABLE @lt_par.
```

**Los campos de administración** se rellenan todos al final, en `sellar`, con un `UPDATE` por tabla, para no repetirlos en cada fila:

```abap
  METHOD sellar.
    " Fecha y hora actuales, con fracciones de segundo
    DATA lv_ahora TYPE timestampl.
    GET TIME STAMP FIELD lv_ahora.
    " El usuario que ejecuta la clase
    DATA(lv_usuario) = cl_abap_context_info=>get_user_technical_name( ).

    " Sin WHERE: se actualizan todas las filas de la tabla
    UPDATE ztl_tit SET created_by      = @lv_usuario, created_at      = @lv_ahora,
                       last_changed_by = @lv_usuario, last_changed_at = @lv_ahora,
                       local_last_changed_at = @lv_ahora.
    " ... lo mismo para cada tabla del taller
  ENDMETHOD.
```

En el Bloque 3 importa que `last_changed_at` tenga valor: RAP lo usa para detectar si otra persona ha cambiado el registro mientras lo editabas.

## Preparación del entorno de trabajo

Las dos clases van en `ZGOR_TEST`. La comprobación la descargas de los materiales. Al terminar:

```text
ZGOR_TEST
├── (clases del Bloque 1)
├── ZCL_GOR_DATOS_DEMO       ← nueva
└── ZCL_GOR_COMPROBAR_CDS    ← nueva (de los materiales)
```

Puedes ejecutar `ZCL_GOR_DATOS_DEMO` tantas veces como quieras: lo primero que hace es vaciar las tablas. **Solo** en tu sistema de pruebas.

## Ejercicios

1. **El esqueleto.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_DATOS_DEMO`, descripción `Datos de demo del ERP`.
    - **Qué contiene:** la misma estructura que la del taller:
        - el tipo `ty_uuid` (`ref TYPE string`, `uuid TYPE sysuuid_x16`) y el atributo `mt_uuids`, tabla *hashed* con clave única `ref`;
        - `registrar( iv_ref ) → rv_uuid`, que crea el UUID y lo apunta, y `uuid_de( iv_ref ) → rv_uuid`, que lo busca;
        - los métodos sin parámetros `vaciar`, `crear_maestros`, `crear_escenario`, `crear_otras_obras` y `sellar`, de momento vacíos.

        El `main` los llama en ese orden y termina con `out->write( |Datos del ERP creados: { lines( mt_uuids ) } registros| )`. Comenta cada parte como en el taller.
    - **Comprueba:** activa y ejecuta (**F9**): debe escribir `Datos del ERP creados: 0 registros`.

2. **Vaciar.**
    - **Dónde:** el método `vaciar`.
    - **Qué hace:** un `DELETE FROM` por cada una de las 16 tablas. Empieza por las hijas (líneas, faltas, relaciones N:M, ficha de gastos) y termina por las raíces. Las tablas no tienen claves foráneas, así que el orden no daría error, pero así te acostumbras al orden en que se borra en la vida real.
    - **Comprueba:** ejecuta la clase y después `ZCL_GOR_SQL_DEMO`: los `SELECT COUNT( * )` de clientes y obras deben dar **0** (los datos de 1.5 y 2.4 ya no están).

3. **Maestros.**
    - **Dónde:** el método `crear_maestros`.
    - **Qué hace:** cada entidad, en su tabla interna y con un solo `INSERT ... FROM TABLE`, registrando cada UUID con su código (`registrar( `CLI0001` )`):

        | Entidad | Registros |
        |---|---|
        | Clientes | `CLI0001` Juan Pérez López (NIF 12345678Z, CP 28001); `CLI0002` Ana Ruiz Gil (28001); `CLI0003` Luis Mena Sanz (28045); `CLI0004` Marta Gil Romero (50001); `CLI0005` Construcciones Ebro SL (sin apellidos, 50003). Todos con dirección y teléfono |
        | Trabajadores | `TRB0001` Pedro Sánchez y `TRB0002` Rosa Martín (Oficial 1ª, 20 €/h); `TRB0003` Diego Ortega (Peón, 18 €/h); `TRB0004` Lucía Navarro (Encargada, 25 €/h) |
        | Faltas | `TRB0001`: vacaciones del 03/08/2026 al 14/08/2026; `TRB0003`: baja médica del 05/10/2026 al 07/10/2026. Calcula `dias` con `zcl_gor_reglas=>dias_falta( )`: 12 y 3 |
        | Proveedores | `PROV0001` Materiales Centro, `PROV0002` Cerámicas Levante, `PROV0003` Fontanería Express. `base` 200, 450 y 90, `iva` 21, y `total` con `total_proveedor( )` |
        | Especialistas | `ESP0001` Javier Rubio (Electricista, 150 €), `ESP0002` Sara León (Arquitecta, 900 €), `ESP0003` Iván Prieto (Fontanero, 120 €) |

        Las faltas no tienen código: regístralas con un nombre cualquiera (`FALTA1`) o usa `cl_system_uuid` directamente.
    - **Comprueba:** ejecuta: debe escribir `15 registros` (o 17, si registraste las faltas). En `ZCL_GOR_SQL_DEMO`, `SELECT dias FROM zgor_falta` debe dar 12 y 3.

4. **El escenario.**
    - **Dónde:** el método `crear_escenario`.
    - **Qué hace:** todo lo de `OBR0001` según la tabla de la sección «El diseño»:
        - la obra y su ficha de gastos `GAS0001` (inicio 07/09/2026, fin 16/10/2026);
        - el presupuesto `PREP0001` del 01/09/2026, con la copia de los datos de Juan y su línea «Reforma integral de baño»;
        - un parte de trabajo del 08/09/2026 con sus dos líneas: `coste_subtotal` de cada línea con `coste_subtotal( )`, y `horas_totales` y `coste_total` del parte con `horas_parte( )` y `coste_parte( )`;
        - un parte de proveedor (`PROV0001`, 200 €, pagado) y uno de especialista (`ESP0001`, 150 €, pagado);
        - los ingresos `ING0001` (500 €, 15/09/2026) e `ING0002` (710 €, 20/10/2026).

        Separa cada grupo con un comentario (`" Presupuesto PREP0001`…). Ningún importe calculado se escribe a mano: todos salen de `zcl_gor_reglas`.
    - **Comprueba:** en `ZCL_GOR_SQL_DEMO`, lee la ficha de `OBR0001` como en el ejercicio 7 de 2.4: total 1210, ingresos 1210, debe 0, `pagado`.

5. **Las otras obras.**
    - **Dónde:** el método `crear_otras_obras`.
    - **Qué hace:** `OBR0002`, `OBR0003` y `OBR0004` según la tabla, cada una con su ficha de gastos (`GAS0002` a `GAS0004`), y el presupuesto `PREP0006` de `CLI0005` **sin obra** (1 × 5000 €, IVA 21, no aprobado). Numera los presupuestos `PREP0002` a `PREP0006` y los ingresos `ING0003` y `ING0004`.
    - **Comprueba:** `SELECT COUNT( * ) FROM zgor_presu WHERE obra_uuid IS INITIAL` debe dar **1** (el `PREP0006`).

6. **Sellar.**
    - **Dónde:** el método `sellar`.
    - **Qué hace:** un `UPDATE` con los cinco campos de administración por cada una de las 16 tablas.
    - **Comprueba:** ejecuta la clase completa sin ningún *dump*. `SELECT COUNT( * ) FROM zgor_obra WHERE last_changed_at IS INITIAL` debe dar **0**.

7. **Navega por los datos.**
    - **Dónde:** `ZCL_GOR_SQL_DEMO`, un bloque nuevo con el comentario `" 2.5 Comprobar los datos de demo`.
    - **Qué hace:** tres lecturas con rutas:
        - la ficha de `OBR0001`: `ObraId, \_Cliente-Nombre, \_Finanzas-Total, \_Finanzas-Gastos, \_Finanzas-Salud`;
        - los trabajadores de `OBR0001`, desde `zi_gorobratrab` filtrando por la obra: `\_Trabajador-TrabajadorId`;
        - el acumulado de `TRB0001`: `TrabajadorId, \_Acumulado-HorasTotales, \_Acumulado-TotalEuros`.
    - **Comprueba:** `OBR0001` con Juan, 1210, 670 y `verde`; los trabajadores `TRB0001` y `TRB0002`; y `TRB0001` con **16 h y 320 €** (8 h en `OBR0001` y 8 h en `OBR0003`).

8. **Comprueba la ficha.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_COMPROBAR_CDS`, con el código de [2_5_comprobar_cds.abap](materiales/tests/2_5_comprobar_cds.abap).
    - **Qué hace:** lee cada obra de `ZI_GorObraFinanzas`, la compara con la tabla de la sección «El diseño» y escribe `OK` o el campo que no cuadra.
    - **Comprueba:** ejecútala con **F9**. Si algo falla, el error puede estar en los datos (ejercicios 3 a 5) o en las vistas (2.4): lee esa obra en `ZI_GorObraImportes` para ver qué suma no cuadra.

9. **Investiga.** Cambia en `ZCL_GOR_DATOS_DEMO` el estado del presupuesto de 800 € de `OBR0003` a `aprobado` y vuelve a ejecutar las dos clases. ¿Qué campos fallan ahora? Calcula a mano los valores nuevos, compruébalos con la lectura del ejercicio 7 y deja el estado como estaba.

## Comprueba tu solución automáticamente

`ZCL_GOR_COMPROBAR_CDS` (ejercicio 8) debe terminar con **«0 errores»**: 4 obras × 10 campos, más los acumulados de los 4 trabajadores y los participantes de `OBR0001`. No es un test de ABAP Unit, porque lee los datos reales de la base de datos. En [3.8](./3_8_proyecto.md) escribiremos el escenario como test de verdad, con las tablas sustituidas por dobles.

---

**Siguiente:** [3.1. Behavior Definition managed](./3_1_behaviorDefinition.md)
