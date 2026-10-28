---
title: "3.5. Actions"
parent: "3. Comportamiento con RAP"
nav_order: 5
---

# 3.5. Actions

{% raw %}
Una *action* es una operación de negocio con nombre propio, más allá de crear, modificar y borrar: en Fiori aparece como un **botón**. Es el equivalente de los métodos `action_*` de Odoo. En esta unidad las vemos con el taller: **aceptar** un presupuesto (que cambia el importe de la orden), **vincularlo** a una orden y dos reglas que se aplican **al borrar**: una orden con abonos no se puede borrar, y una orden sin abonos se lleva consigo sus jornadas, albaranes y facturas. Tú harás las acciones del ERP: aprobar y desaprobar (§11.5, punto 1), vincular (el asistente de §3.15), marcar un parte como pagado, y las reglas de borrado de la obra (§11.5, punto 12).

## Declarar una acción

```sql
  action ( features : instance ) aceptar         result [1] $self;
  action ( features : instance ) volverABorrador result [1] $self;
```

- `result [1] $self`: la acción devuelve la propia instancia, ya modificada. Así Fiori refresca la pantalla con el estado nuevo.
- `( features : instance )`: si el botón está **activo o no** se decide por instancia, con código (*feature control*). No tiene sentido aceptar un presupuesto ya aceptado.

## Implementar una acción

```abap
  METHOD aceptar.
    MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto
        UPDATE FIELDS ( Situacion )
        WITH VALUE #( FOR k IN keys ( %tky      = k-%tky
                                      Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) ).

    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    result = VALUE #( FOR p IN lt_presupuestos ( %tky = p-%tky %param = p ) ).
  ENDMETHOD.
```

No hay nada más que hacer: el importe de la orden se calcula en `ZI_TlOrdenImporte` (2.4) sumando los presupuestos aceptados, así que la próxima lectura ya lo refleja.

## Feature control: activar y desactivar botones

```sql
define behavior for ZI_TlPresupuesto alias Presupuesto
...
{
  ...
  action ( features : instance ) aceptar result [1] $self;
```

```abap
  METHOD get_instance_features.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Situacion OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    result = VALUE #( FOR p IN lt_presupuestos
      LET lv_aceptado = xsdbool( p-Situacion = zif_tl_tipos=>situacion_presupuesto-aceptado ) IN
      ( %tky                    = p-%tky
        %action-aceptar         = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %action-volverABorrador = COND #( WHEN lv_aceptado = abap_true
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-vincularAOrden  = COND #( WHEN p-OrdenUUID IS INITIAL
                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.
```

El método aparece en cuanto una operación de la BDEF lleva `features : instance` (**Ctrl+1** → *Add missing method*). El *feature control* no es solo visual: si alguien ejecuta con EML una acción desactivada, RAP la rechaza.

## Acciones con parámetro

En el taller, un presupuesto que se hizo antes de abrir la orden se vincula después a ella. Si la acción estuviera en la orden, tendría que modificar **otro** BO (el presupuesto), y eso complica las cosas (bloqueos, borradores). Por eso la acción está **en el presupuesto** y recibe la orden como parámetro: solo modifica su propio BO.

El parámetro es una **entidad abstracta**: una estructura CDS que no lee ninguna tabla.

```sql
@EndUserText.label: 'Taller - Orden a la que vincular'
define abstract entity ZA_TlVincularOrden
{
  OrdenRef : abap.char(8);
}
```

```sql
  action ( features : instance ) vincularAOrden parameter ZA_TlVincularOrden result [1] $self;
```

```abap
  METHOD vincularAOrden.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_presu) = VALUE #( lt_presupuestos[ PresupuestoUUID = ls_key-PresupuestoUUID ] OPTIONAL ).
      SELECT SINGLE FROM ztl_orden
        FIELDS orden_uuid, titular_uuid
        WHERE orden_ref = @ls_key-%param-OrdenRef
        INTO @DATA(ls_orden).

      IF sy-subrc <> 0 OR ls_orden-titular_uuid <> ls_presu-TitularUUID.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-presupuesto.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |La orden { ls_key-%param-OrdenRef } no existe o es de otro titular| ) )
               TO reported-presupuesto.
        CONTINUE.
      ENDIF.

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

```sql
  delete ( features : instance, precheck );
```

- Con `features : instance`, `get_instance_features` puede desactivar el botón *Eliminar* (`%delete = if_abap_behv=>fc-o-disabled`) si la orden tiene abonos.
- Con `precheck`, un método se ejecuta **antes** de borrar y puede impedirlo con un mensaje, aunque el borrado venga de EML:

```abap
  METHOD precheck_delete.
    SELECT DISTINCT orden_uuid FROM ztl_abo
      FOR ALL ENTRIES IN @keys WHERE orden_uuid = @keys-OrdenUUID
      INTO TABLE @DATA(lt_con_abonos).

    LOOP AT keys INTO DATA(ls_key).
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

```sql
managed with additional save implementation in class zbp_i_tlorden unique;
```

```abap
CLASS lsc_zi_tlorden DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_tlorden IMPLEMENTATION.
  METHOD save_modified.
    DATA lv_sin_orden TYPE sysuuid_x16.

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

1. **Aprobar y desaprobar.** Añade a tu presupuesto las acciones `aprobar` y `desaprobar` (cambian `Estado` a `aprobado` o `no_aprobado` y devuelven la propia instancia), con *feature control*: `aprobar` solo activa si no está aprobado, y `desaprobar` al revés. Con EML (`EXECUTE aprobar` y *commit*), aprueba `PREP0005` (el de `OBR0004`). En el Data Preview de `ZI_GorObraFinanzas`, `OBR0004` debe pasar de total 0 a **1210**. Desapruébalo y vuelve a 0.
2. **Vincular.** Crea la entidad abstracta `ZA_GorVincularObra`, con un campo `ObraId` (`abap.char(8)`), y la acción `vincularAObra` en el presupuesto, con ese parámetro. Reglas (§3.15): solo para presupuestos **sin obra** (*feature control*), y la obra debe existir y, si tiene cliente, ser del cliente del presupuesto; si no, error con mensaje. Con EML, vincula `PREP0006` (de `CLI0005`, sin obra) a `OBR0001`: debe fallar, porque es de Juan. Crea una obra para `CLI0005` y vincúlalo a ella: ahora sí. Después, inténtalo otra vez: el *feature control* lo impide.
3. **Borrar obras.** Una obra con ingresos no se borra (§3.5, `_unlink_sin_ingresos`): pon en la obra `delete ( features : instance, precheck )`, con el botón desactivado y el *precheck* rechazando el borrado si tiene ingresos. Con EML, intenta borrar `OBR0001`: debe fallar (paso 11 de §12.7).
4. **El guardado adicional.** Al borrar una obra sin ingresos (§3.5, `unlink`): se borran sus partes de trabajo con sus líneas y sus partes de especialista y de proveedor, y sus presupuestos se quedan **sin obra**. Su ficha de gastos se borra sola, por la composición. Pruébalo con el paso 11b de §12.7: crea con EML una obra con un presupuesto aprobado y un parte de trabajo de 8 h de `TRB0002`, **sin ingresos**, y bórrala. Comprueba que han desaparecido su ficha de gastos y el parte, que el presupuesto sigue sin obra y que `ZI_GorTrabAcum` de `TRB0002` ha vuelto a sus 8 h de antes.
5. **Más restricciones al borrar.** Odoo no deja borrar (§11.6, `RESTRICT`): un cliente con presupuestos, un trabajador con líneas de parte, ni un proveedor o especialista con partes. Implementa un `precheck` para cada uno.
6. **Marcar como pagado.** Añade a los partes de especialista y de proveedor la acción `marcarPagado` (pone `EstadoPago` a `pagado`), activa solo si el parte está `pendiente`.
7. **Investiga.** ¿Qué pasa si quitas `( features : instance )` de tu `aprobar` pero dejas `%action-aprobar` en `get_instance_features`? Activa y lee el error. Anota la relación entre las dos piezas.

## Comprueba tu solución automáticamente (opcional)

- [3_5_ltcl_actions.abap](materiales/tests/3_5_ltcl_actions.abap) en `zbp_i_gorpresupuesto`, debajo de las anteriores: **9 tests en verde** (6 + 3).
- [3_5_ltcl_borrar_obra.abap](materiales/tests/3_5_ltcl_borrar_obra.abap) en `zbp_i_gorobra`: **2 tests en verde**.

---

**Siguiente:** [3.6. Composiciones: hijos y tablas satélite](3_6_composiciones.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_5_actions.md){: .fs-2 }
{% endraw %}
