# 3.4. Validations

Una *validation* comprueba que los datos son correctos **antes de guardar** y, si no lo son, impide el guardado con un mensaje. Es el `@api.constrains` de Odoo. En esta unidad las vemos con el presupuesto del taller, y tú implementarás **todas** las reglas de §11.4 del informe. Para las que no dependen de otra entidad ya tienes tus métodos `validar_*` de [1.7](./1_7_excepciones.md): cada *validation* solo tiene que llamarlos y convertir su excepción en un mensaje de RAP.

## Declaración

```sql
  validation validarImpuesto on save { create; field Impuesto; }

  draft determine action Prepare
  {
    validation validarImpuesto;
    determination ( always ) importesAlGuardar;
  }
```

- Las validations son siempre **`on save`**: se ejecutan al guardar, no a cada cambio.
- El disparador indica cuándo hace falta volver a comprobar: al crear, o si cambia el impuesto.
- **Toda validation debe figurar en `Prepare`**. Así, Fiori la ejecuta al pulsar *Guardar* sobre el borrador y muestra los errores **antes** de intentar activar. Si se olvida, el borrador no da error pero luego no se puede guardar, y el usuario no sabe por qué.

## Implementación: de la excepción al mensaje

```abap
  METHOD validarImpuesto.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      " Borra el mensaje anterior de esta validation (si lo habia)
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'IMPUESTO' ) TO reported-presupuesto.

      TRY.
          zcl_tl_calculos=>comprobar_impuesto( CONV #( ls_presu-Impuesto ) ).
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          APPEND VALUE #( %tky = ls_presu-%tky ) TO failed-presupuesto.
          APPEND VALUE #( %tky              = ls_presu-%tky
                          %state_area       = 'IMPUESTO'
                          %msg              = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) )
                          %element-Impuesto = if_abap_behv=>mk-on ) TO reported-presupuesto.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
```

- **`failed-presupuesto`** marca la instancia como fallida: no se guarda.
- **`reported-presupuesto`** lleva el mensaje. `%element-Impuesto` hace que Fiori señale **la casilla** del impuesto, no solo el formulario.
- **`%state_area`** agrupa los mensajes de una validation. Con draft, el mensaje se queda en el borrador hasta que la validation vuelva a ejecutarse; por eso, al empezar, se añade una entrada **sin mensaje** con el mismo `%state_area`, que borra el anterior. Si no, el error seguiría saliendo aunque el usuario lo hubiera corregido.
- El texto del mensaje es el de la excepción: está escrito **una sola vez**, en la clase de reglas, y lo usan igual los tests del Bloque 1 y la app.

## Marcar el campo que dice la excepción

En `validarImpuesto` el campo está escrito a mano (`%element-Impuesto`). Si una validation llama a varios métodos de comprobación, cada uno con su campo, es más cómodo marcar el que diga la excepción (`mv_elemento`). Para eso se accede a un componente **por su nombre**, con `ASSIGN COMPONENT`:

```abap
      DATA ls_mensaje LIKE LINE OF reported-presupuesto.
      ls_mensaje = VALUE #( %tky        = ls_presu-%tky
                            %state_area = 'IMPUESTO'
                            %msg        = new_message_with_text(
                                            severity = if_abap_behv_message=>severity-error
                                            text     = lx_aviso->get_text( ) ) ).
      ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
      IF sy-subrc = 0.
        <lv_marca> = if_abap_behv=>mk-on.
      ENDIF.
      APPEND ls_mensaje TO reported-presupuesto.
```

`LIKE LINE OF` declara una estructura con el tipo de una fila de otra tabla. Si el nombre no existe como campo, `ASSIGN` no falla: `sy-subrc` vale distinto de 0 y simplemente no se marca nada. Por eso, en 1.7, el campo de la excepción se escribe con el nombre de la vista en *CamelCase*.

## Validations entre objetos de negocio

Algunas reglas miran otra entidad. En el taller: «el titular de un presupuesto es el de su orden». Se leen los datos del otro BO y se compara:

```abap
  METHOD validarTitularDeOrden.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).
    DELETE lt_presupuestos WHERE OrdenUUID IS INITIAL.
    CHECK lt_presupuestos IS NOT INITIAL.

    READ ENTITIES OF zi_tlorden
      ENTITY Orden FIELDS ( TitularUUID )
      WITH VALUE #( FOR p IN lt_presupuestos ( OrdenUUID = p-OrdenUUID ) )
      RESULT DATA(lt_ordenes).

    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'TITULAR_ORDEN' ) TO reported-presupuesto.
      DATA(ls_orden) = VALUE #( lt_ordenes[ OrdenUUID = ls_presu-OrdenUUID ] OPTIONAL ).
      IF ls_orden-TitularUUID IS NOT INITIAL AND ls_orden-TitularUUID <> ls_presu-TitularUUID.
        APPEND VALUE #( %tky = ls_presu-%tky ) TO failed-presupuesto.
        APPEND VALUE #( %tky                 = ls_presu-%tky
                        %state_area          = 'TITULAR_ORDEN'
                        %msg                 = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = 'El presupuesto debe ser del titular de la orden' )
                        %element-TitularUUID = if_abap_behv=>mk-on ) TO reported-presupuesto.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
```

Algunas reglas **no son validations**:

- **Unicidad** de un dato (el documento de identidad de un titular, por ejemplo): se comprueba con un `SELECT` sobre la tabla («¿hay otro titular con este documento y distinto UUID?»), dentro de una validation.
- **«No se borra una orden con abonos»** no es una comprobación al guardar, sino al **borrar**. Va en [3.5](./3_5_actions.md).

## Mensajes con clase de mensajes

`new_message_with_text` sirve para el portfolio. En un proyecto real, los textos van en una **clase de mensajes** (objeto *Message Class* en ADT) y la excepción implementa `IF_T100_MESSAGE`, para poder traducirlos sin tocar el código. Si en la empresa ves `%msg = NEW zcx_...( textid = ... )`, es eso. El cambio desde nuestro diseño es pequeño: solo cambia cómo se construye la excepción.

## Preparación del entorno de trabajo

Se amplían las BDEF y las clases. Recuerda añadir cada validation a la `Prepare` de **su** BO.

## Ejercicios

1. **El IVA.** Añade a tu presupuesto `validarIva` (`create; field Iva`), que use tu `validar_iva` y marque el campo `Iva`, y añádela a su `Prepare`. Con EML, crea un presupuesto con IVA 150 y guarda con `COMMIT ENTITIES RESPONSE OF zi_gorpresupuesto FAILED DATA(ls_f) REPORTED DATA(ls_r)`. Escribe en la consola el texto del mensaje: `ls_r-presupuesto[ 1 ]-%msg->if_message~get_text( )`. Comprueba en el Data Preview que el presupuesto **no** se ha guardado.
2. **El cliente de la obra.** Añade `validarClienteDeObra` (`create; field ClienteUUID, ObraUUID`): si el presupuesto tiene obra y la obra tiene cliente, tiene que ser el mismo (§11.4). Pruébala con EML: un presupuesto de Ana (`CLI0002`) para `OBR0001`, que es de Juan, no debe guardarse.
3. **Todas las demás.** Implementa estas. Las de la columna «Método» llaman a tu `ZCL_GOR_REGLAS`; el campo que se marca es el de `mv_campo` de la excepción:

    | BO / entidad | Validation | Comprueba (§11.4) | Método |
    |---|---|---|---|
    | Cliente | `validarObligatorios` | Nombre, dirección y teléfono | `validar_obligatorio` |
    | Cliente | `validarNifUnico` | No hay otro cliente con el mismo NIF (si tiene) | `SELECT` sobre `zgor_cli` con `cliente_uuid <> ...` |
    | Trabajador | `validarTrabajador` | Nombre y apellido; `CosteHoraEstandar ≥ 0` | `validar_obligatorio`, `validar_no_negativo` |
    | Falta | `validarFechas` | `FechaFin ≥ FechaInicio` | `validar_fechas` |
    | Proveedor | `validarBase` | `Base ≥ 0` | `validar_no_negativo` |
    | Especialista | `validarEspecialista` | Nombre; `Importe ≥ 0` | `validar_obligatorio`, `validar_no_negativo` |
    | Presupuesto | `validarCliente` | Tiene cliente | — (`ClienteUUID IS INITIAL`) |
    | Obra | `validarCambioCliente` | Si tiene cliente, ninguno de sus presupuestos ni ingresos (con cliente) es de otro (§3.5) | `SELECT` sobre `zgor_presu` y `zgor_ing` |
    | Gasto | `validarFechasObra` | `FinObra ≥ InicioObra` | `validar_fechas` |
    | Ingreso | `validarIngreso` | Tiene obra (§3.8: siempre); el cliente, si lo tiene, es el de la obra | — y lectura de `zi_gorobra` |
    | Parte de trabajo | `validarParte` | Obra y descripción | `validar_obligatorio` |
    | Línea de parte | `validarLinea` | Trabajador; `0 ≤ Horas ≤ 24` | `validar_horas` |
    | Partes de especialista y proveedor | `validarParteExterno` | Obra y especialista (o proveedor); `Importe > 0` | `validar_importe_positivo` |

    Los hijos (falta, gasto, línea de parte) declaran su validation en su propia entidad de la BDEF, pero se añaden a la `Prepare` de la **raíz**: `validation Falta~validarFechas;`.

4. **El paso 9 con EML.** En `ZCL_GOR_EML_DEMO`, intenta guardar cada caso del paso 9 de §12.7 y escribe el mensaje que devuelve cada uno: línea de 25 h, línea de −1 h, parte externo de 0 €, IVA 150 y falta con fin anterior al inicio. Todos deben fallar con el mismo texto que viste en 1.7.
5. **Investiga.** En tu `validarIva`, quita la línea que añade la entrada vacía con `%state_area` y activa. Ya con la app del Bloque 4 (o apúntalo para entonces): pon un IVA de 150, guarda, corrige a 21 y vuelve a guardar. ¿Qué pasa con el mensaje? Vuelve a poner la línea.

## Comprueba tu solución automáticamente (opcional)

Pega [3_4_ltcl_validations.abap](materiales/tests/3_4_ltcl_validations.abap) en la pestaña **Test Classes** de `zbp_i_gorpresupuesto`, debajo de la de 3.3: **6 tests en verde** (3 + 3).

---

**Siguiente:** [3.5. Actions](./3_5_actions.md)
