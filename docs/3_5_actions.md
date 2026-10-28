# 3.5. Actions

Una *action* es una operación de negocio con nombre propio, más allá de crear, modificar y borrar: en Fiori aparece como un **botón**. Es el equivalente de los métodos `action_*` de Odoo. En esta unidad las vemos con el taller: **aceptar** un presupuesto (que cambia el importe de la orden), **vincularlo** a una orden y dos reglas que se aplican **al borrar**: una orden con abonos no se puede borrar, y una orden sin abonos se lleva consigo sus jornadas, albaranes y facturas. Tú harás las acciones del ERP: aprobar y desaprobar (§11.5, punto 1), vincular (el asistente de §3.15), marcar un parte como pagado, y las reglas de borrado de la obra (§11.5, punto 12).

## Declarar una acción

```bdef
  // Dos botones; si estan activos lo decide el codigo, presupuesto a presupuesto
  action ( features : instance ) aceptar         result [1] $self;
  action ( features : instance ) volverABorrador result [1] $self;
```

- `result [1] $self`: la acción devuelve la propia instancia, ya modificada. Así Fiori refresca la pantalla con el estado nuevo.
- `( features : instance )`: si el botón está **activo o no** se decide por instancia, con código (*feature control*). No tiene sentido aceptar un presupuesto ya aceptado.

## Implementar una acción

```abap
  METHOD aceptar.
    " 1. Cambiar la situacion de cada presupuesto recibido
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Situacion )
        WITH VALUE #( FOR k IN keys ( %tky      = k-%tky
                                      Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) ).

    " 2. Devolver la instancia ya cambiada (result [1] $self): Fiori pinta el estado nuevo
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    result = VALUE #( FOR p IN lt_presupuestos ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.
```

No hay nada más que hacer: el importe de la orden se calcula en `ZI_TlOrdenImporte` (2.4) sumando los presupuestos aceptados, así que la próxima lectura ya lo refleja.

## Feature control: activar y desactivar botones

```bdef
define behavior for ZI_TlPresupuesto alias Presupuesto
...
{
  ...
  // features : instance -> RAP llamara a get_instance_features
  action ( features : instance ) aceptar result [1] $self;
```

```abap
  METHOD get_instance_features.
    " Leer lo que decide el estado de los botones
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Situacion OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " Una fila por presupuesto, con el estado (enabled/disabled) de cada accion
    result = VALUE #( FOR p IN lt_presupuestos
      LET lv_aceptado = xsdbool( p-Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) IN
      ( %tky                    = p-%tky
        %action-aceptar         = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %action-volverABorrador = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        " Vincular solo si todavia no tiene orden
        %action-vincularAOrden  = COND #( WHEN p-OrdenUUID IS INITIAL
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.
```

El método aparece en cuanto una operación de la BDEF lleva `features : instance` (**Ctrl+1** → *Add missing method*). El *feature control* no es solo visual: si alguien ejecuta con EML una acción desactivada, RAP la rechaza.

## Acciones con parámetro

En el taller, un presupuesto que se hizo antes de abrir la orden se vincula después a ella. Si la acción estuviera en la orden, tendría que modificar **otro** BO (el presupuesto), y eso complica las cosas (bloqueos, borradores). Por eso la acción está **en el presupuesto** y recibe la orden como parámetro: solo modifica su propio BO.

El parámetro es una **entidad abstracta**: una estructura CDS que no lee ninguna tabla.

```cds
@EndUserText.label: 'Taller - Orden a la que vincular'
// abstract: no lee ninguna tabla, solo define los campos del parametro
define abstract entity ZA_TlVincularOrden
{
  OrdenRef : abap.char(8);          // lo que teclea el usuario: ORD0001
}
```

```bdef
  // parameter: la accion pide datos al usuario (Fiori abre un dialogo)
  action ( features : instance ) vincularAOrden parameter ZA_TlVincularOrden result [1] $self;
```

```abap
  METHOD vincularAOrden.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_presu) = VALUE #( lt_presupuestos[ PresupuestoUUID = ls_key-PresupuestoUUID ] OPTIONAL ).
      " Buscar la orden por el codigo que llega en el parametro
      SELECT SINGLE FROM ztl_orden
        FIELDS orden_uuid, titular_uuid
        WHERE orden_ref = @ls_key-%param-OrdenRef
        INTO @DATA(ls_orden).

      " No existe, o es de otro titular: marcar como fallida y explicar por que
      IF sy-subrc <> 0 OR ls_orden-titular_uuid <> ls_presu-TitularUUID.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-presupuesto.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |La orden { ls_key-%param-OrdenRef } no existe o es de otro titular| ) )
               TO reported-presupuesto.
        CONTINUE.                                     " siguiente presupuesto
      ENDIF.

      " Todo bien: enlazar el presupuesto con la orden
      MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
        ENTITY Presupuesto
          UPDATE FIELDS ( OrdenUUID ) WITH VALUE #( ( %tky = ls_key-%tky OrdenUUID = ls_orden-orden_uuid ) ).
    ENDLOOP.

    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_resultado).
    result = VALUE #( FOR p IN lt_resultado ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.
```

- `%param` contiene los parámetros de la acción para cada instancia.
- La orden se busca por su referencia en la **tabla** `ztl_orden`: solo hace falta su UUID y su titular, y leer la tabla (en vez de la vista) facilita los tests de 3.8.
- En el taller, toda orden tiene titular, así que basta con comparar. En tu ERP, una obra puede no tener cliente: piensa qué debe pasar entonces.

## Al borrar: *precheck* y guardado adicional

**Una orden con abonos no se puede borrar.** Se declara en el `delete`:

```bdef
  // Boton desactivable (features) y comprobacion previa al borrado (precheck)
  delete ( features : instance, precheck );
```

- Con `features : instance`, `get_instance_features` puede desactivar el botón *Eliminar* (`%delete = if_abap_behv=>fc-o-disabled`) si la orden tiene abonos.
- Con `precheck`, un método se ejecuta **antes** de borrar y puede impedirlo con un mensaje, aunque el borrado venga de EML:

```abap
  METHOD precheck_delete.
    " Que ordenes de las que se quieren borrar tienen abonos (una sola consulta)
    SELECT DISTINCT orden_uuid FROM ztl_abo
      FOR ALL ENTRIES IN @keys WHERE orden_uuid = @keys-OrdenUUID
      INTO TABLE @DATA(lt_con_abonos).

    LOOP AT keys INTO DATA(ls_key).
      " Sin abonos: se puede borrar, siguiente
      CHECK line_exists( lt_con_abonos[ orden_uuid = ls_key-OrdenUUID ] ).
      APPEND VALUE #( %tky = ls_key-%tky ) TO failed-orden.
      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'No se puede borrar una orden con abonos' ) )
             TO reported-orden.
    ENDLOOP.
  ENDMETHOD.
```

**Una orden sin abonos se borra con lo que solo existe por ella.** La hoja de costes se borra sola, porque es su hija. Pero las jornadas, albaranes y facturas son **otros BO** que apuntan a la orden, y los presupuestos hay que conservarlos desvinculados. Para eso hay un **guardado adicional**: código que se ejecuta al guardar, después de que RAP escriba la orden.

```bdef
// with additional save: despues de que RAP guarde, se ejecuta nuestro save_modified
managed with additional save implementation in class zbp_i_tlorden unique;
```

```abap
" lsc = local saver class: interviene en el momento de guardar
CLASS lsc_zi_tlorden DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_tlorden IMPLEMENTATION.
  METHOD save_modified.
    DATA lv_sin_orden TYPE sysuuid_x16.               " UUID vacio

    " delete-orden: las ordenes que se acaban de borrar
    LOOP AT delete-orden INTO DATA(ls_orden).
      " Jornadas con sus tramos (primero los tramos)
      DELETE FROM ztl_jor_tra WHERE jornada_uuid IN ( SELECT jornada_uuid FROM ztl_jor
                                                      WHERE orden_uuid = @ls_orden-OrdenUUID ).
      DELETE FROM ztl_jor WHERE orden_uuid = @ls_orden-OrdenUUID.
      " Albaranes y facturas
      DELETE FROM ztl_alb WHERE orden_uuid = @ls_orden-OrdenUUID.
      DELETE FROM ztl_fac WHERE orden_uuid = @ls_orden-OrdenUUID.
      " Los presupuestos se conservan, sin orden
      UPDATE ztl_prs SET orden_uuid = @lv_sin_orden WHERE orden_uuid = @ls_orden-OrdenUUID.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

Esto escribe con SQL en tablas de **otros** BO, saltándose su comportamiento. Es una decisión consciente, y la explicaremos en el README del portfolio:

- **Funciona sin dejar números atrasados**: la mano de obra, los costes de la orden… se calculan al leer (2.4), así que no hay nada que recalcular. En tu ERP, compáralo con el motivo por el que Odoo tenía que borrar por el ORM (§3.5).
- **Limitaciones**: el ATC (5.1) avisará de que se modifican tablas ajenas; si alguien tuviera un **borrador** abierto de una de esas jornadas, quedaría huérfano; y la fecha de modificación de los presupuestos no cambia. Para el volumen de un taller (o de una empresa de reformas), es aceptable.

En 3.6, el guardado adicional tendrá que borrar también los avisos y fotos de las jornadas, albaranes y facturas.

## Preparación del entorno de trabajo

Tu entidad abstracta va en `ZGOR_CDS`. Lo demás amplía tus BDEF y clases de comportamiento.

## Ejercicios

Como en 3.3, las firmas se crean con **Ctrl+1** → *Add missing method* sobre el nombre de cada pieza en la BDEF. Para que las reconozcas, son estas:

```abap
" Una accion que devuelve la propia instancia (result [1] $self)
METHODS aprobar FOR MODIFY
  IMPORTING keys FOR ACTION Presupuesto~aprobar RESULT result.

" Feature control: un metodo para todas las acciones y operaciones con ( features : instance )
METHODS get_instance_features FOR INSTANCE FEATURES
  IMPORTING keys REQUEST requested_features FOR Presupuesto RESULT result.

" Precheck: se ejecuta antes de borrar, y puede rechazarlo
METHODS precheck_delete FOR PRECHECK
  IMPORTING keys FOR DELETE Obra.
```

1. **Aprobar y desaprobar.**
    - **Dónde:** BDEF `ZI_GorPresupuesto`, entidad `Presupuesto`; clase `zbp_i_gorpresupuesto`, clase local `lhc_presupuesto`.
    - **En la BDEF:** `action ( features : instance ) aprobar result [1] $self;` y lo mismo para `desaprobar`. Añade también los dos *side effects* que dejaste pendientes en el ejercicio 5 de 3.3.
    - **Qué hace:** `aprobar` cambia `Estado` a `aprobado` y `desaprobar` a `no_aprobado`, y las dos devuelven en `result` la instancia leída después del cambio, como `aceptar` del taller. En `get_instance_features`, `aprobar` solo está activa si el presupuesto **no** está aprobado, y `desaprobar` al revés.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, bloque `" 3.5 Aprobar`: lee el UUID de `PREP0005` (el de `OBR0004`) con `SELECT SINGLE`, ejecuta `MODIFY ENTITIES ... EXECUTE aprobar` y `COMMIT ENTITIES`, y escribe `Total` de `zi_gorobrafinanzas` para `OBR0004`: pasa de 0 a **1210**. Ejecuta `desaprobar` y vuelve a 0. Si intentas `aprobar` dos veces seguidas, la segunda debe aparecer en `FAILED`.

2. **Vincular a una obra.**
    - **Dónde:** una *Data Definition* nueva en `ZGOR_CDS`, `ZA_GorVincularObra` (plantilla *Define Abstract Entity*, descripción `Obra a la que vincular`); y la BDEF y la clase del presupuesto.
    - **Qué contiene:** la entidad abstracta, con un solo campo, `ObraId : abap.char(8);`. En la BDEF, `action ( features : instance ) vincularAObra parameter ZA_GorVincularObra result [1] $self;`.
    - **Qué hace** (§3.15): busca la obra por su código (`%param-ObraId`); si no existe, o si tiene cliente y no es el del presupuesto, error en `failed` y `reported` con mensaje. Si todo está bien, pone `ObraUUID`. En `get_instance_features`, la acción solo está activa para presupuestos **sin obra**.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, bloque `" 3.5 Vincular`:
        1. vincula `PREP0006` (de `CLI0005`, sin obra) a `OBR0001`: debe fallar con tu mensaje, porque es de Juan;
        2. crea con EML una obra para `CLI0005` y vincúlalo a ella: `FAILED` vacío y `SELECT SINGLE ObraUUID FROM zgor_presu` ya tiene valor;
        3. inténtalo otra vez: el *feature control* lo impide y aparece en `FAILED`.

3. **Borrar obras.**
    - **Dónde:** BDEF `ZI_GorObra`, entidad `Obra`; clase `zbp_i_gorobra`, clase local `lhc_obra`.
    - **En la BDEF:** cambia `delete;` por `delete ( features : instance, precheck );`.
    - **Qué hace** (§3.5, `_unlink_sin_ingresos`): en `get_instance_features`, `%delete` desactivado si la obra tiene ingresos (cuéntalos con `SELECT COUNT( * ) FROM zgor_ing`); en `precheck_delete`, la misma comprobación, con el mensaje «No se puede borrar una obra con ingresos».
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, intenta borrar `OBR0001` con `MODIFY ... DELETE` y guarda: debe escribir el mensaje, y `SELECT COUNT( * ) FROM zgor_obra WHERE obra_id = 'OBR0001'` sigue dando 1 (paso 11 de §12.7).

4. **El guardado adicional.**
    - **Dónde:** la BDEF `ZI_GorObra` y la clase `zbp_i_gorobra`, pestaña *Local Types*.
    - **En la BDEF:** la primera línea pasa a `managed with additional save implementation in class zbp_i_gorobra unique;`. Con **Ctrl+1** sobre ella, Eclipse crea la clase `lsc_zi_gorobra` con el método `save_modified`.
    - **Qué hace** (§3.5, `unlink`): para cada obra de `delete-obra`, borra sus partes de trabajo con sus líneas y sus partes de especialista y de proveedor (`DELETE FROM` sobre las tablas), y deja sus presupuestos **sin obra** (`UPDATE zgor_presu SET obra_uuid = ...`). La ficha de gastos no hay que borrarla: se borra sola por la composición.
    - **Comprueba** (paso 11b de §12.7): en `ZCL_GOR_EML_DEMO`, crea con EML una obra con un presupuesto aprobado y un parte de trabajo de 8 h de `TRB0002`, **sin ingresos**, y bórrala. Con `SELECT COUNT( * )`: 0 fichas de gastos y 0 partes de esa obra, y el presupuesto sigue existiendo, sin obra. `ZI_GorTrabAcum` de `TRB0002` vuelve a sus 8 h de antes.

5. **Más restricciones al borrar.**
    - **Dónde:** las BDEF y clases del cliente, el trabajador, el proveedor y el especialista.
    - **En la BDEF:** `delete ( precheck );` en cada raíz.
    - **Qué hace** (§11.6, `RESTRICT`): rechaza el borrado de un cliente con presupuestos, de un trabajador con líneas de parte y de un proveedor o especialista con partes, cada uno con su mensaje.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, intenta borrar `CLI0001`, `TRB0001`, `PROV0001` y `ESP0001`: cuatro mensajes, y los cuatro siguen en la base de datos.

6. **Marcar como pagado.**
    - **Dónde:** las BDEF y clases de `ZI_GorParteEsp` y `ZI_GorParteProv`.
    - **En la BDEF:** `action ( features : instance ) marcarPagado result [1] $self;`.
    - **Qué hace:** pone `EstadoPago` a `pagado`; solo está activa si el parte está `pendiente`.
    - **Comprueba:** crea con EML un parte de proveedor pendiente, ejecuta `marcarPagado`, guarda y léelo: `pagado`. Ejecútala otra vez: aparece en `FAILED`.

7. **Investiga.** ¿Qué pasa si quitas `( features : instance )` de tu `aprobar` pero dejas `%action-aprobar` en `get_instance_features`? Activa y lee el error. Anota la relación entre las dos piezas.

## Comprueba tu solución automáticamente (opcional)

- [3_5_ltcl_actions.abap](materiales/tests/3_5_ltcl_actions.abap) en `zbp_i_gorpresupuesto`, debajo de las anteriores: **9 tests en verde** (6 + 3).
- [3_5_ltcl_borrar_obra.abap](materiales/tests/3_5_ltcl_borrar_obra.abap) en `zbp_i_gorobra`: **2 tests en verde**.

---

**Siguiente:** [3.6. Composiciones: hijos y tablas satélite](./3_6_composiciones.md)
