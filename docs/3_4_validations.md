# 3.4. Validations

Una *validation* comprueba que los datos son correctos **antes de guardar** y, si no lo son, impide el guardado con un mensaje. Es el `@api.constrains` de Odoo. En esta unidad las vemos con el presupuesto del taller, y tú implementarás **todas** las reglas de §11.4 del informe. Para las que no dependen de otra entidad ya tienes tus métodos `validar_*` de [1.7](./1_7_excepciones.md): cada *validation* solo tiene que llamarlos y convertir su excepción en un mensaje de RAP.

## Declaración

Una validation se declara en la BDEF, dentro de la entidad a la que pertenece, y se añade a la acción `Prepare`:

```bdef
define behavior for ZI_TlPresupuesto alias Presupuesto
...
{
  ...
  // Se comprueba al guardar si el presupuesto es nuevo (create)
  // o si ha cambiado el campo Impuesto
  validation validarImpuesto on save { create; field Impuesto; }

  // Prepare se ejecuta justo antes de guardar un borrador:
  // aqui se listan TODAS las validations del objeto de negocio
  draft determine action Prepare
  {
    validation validarImpuesto;
    determination ( always ) importesAlGuardar;   // la de 3.3
  }
}
```

- Las validations son siempre **`on save`**: se ejecutan al guardar, no a cada cambio.
- El disparador indica cuándo hace falta volver a comprobar: al crear, o si cambia el impuesto.
- **Toda validation debe figurar en `Prepare`**. Así, Fiori la ejecuta al pulsar *Guardar* sobre el borrador y muestra los errores **antes** de intentar activar. Si se olvida, el borrador no da error pero luego no se puede guardar, y el usuario no sabe por qué.

En la clase de comportamiento, cada validation es un método con esta firma, dentro de la clase local de su entidad (`lhc_presupuesto`):

```abap
    " Firma de una validation: recibe las claves de las instancias que hay que comprobar
    METHODS validarImpuesto FOR VALIDATE ON SAVE
      IMPORTING keys FOR Presupuesto~validarImpuesto.
```

Puedes escribirla a mano o generarla con **Ctrl+1** sobre el nombre en la BDEF (*Add missing method*).

## Implementación: de la excepción al mensaje

```abap
  METHOD validarImpuesto.
    " 1. Leer el impuesto de los presupuestos que hay que comprobar.
    "    IN LOCAL MODE: lectura interna del propio BO, sin comprobar permisos.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( Impuesto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      " 2. Borrar el mensaje que esta validation dejo la vez anterior (si lo hubo).
      "    Una entrada SIN %msg y con el mismo %state_area lo limpia.
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'IMPUESTO' ) TO reported-presupuesto.

      " 3. Comprobar con la clase de reglas: si el impuesto no vale, lanza ZCX_TL_AVISO
      TRY.
          zcl_tl_calculos=>comprobar_impuesto( CONV #( ls_presu-Impuesto ) ).   " CONV: de dec a decfloat34
        CATCH zcx_tl_aviso INTO DATA(lx_aviso).
          " 4a. failed: esta instancia NO se guarda
          APPEND VALUE #( %tky = ls_presu-%tky ) TO failed-presupuesto.
          " 4b. reported: el mensaje que vera el usuario
          APPEND VALUE #( %tky              = ls_presu-%tky
                          %state_area       = 'IMPUESTO'                          " grupo de la validation
                          %msg              = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = lx_aviso->get_text( ) )   " texto de la excepcion
                          %element-Impuesto = if_abap_behv=>mk-on )             " marca la casilla en Fiori
                 TO reported-presupuesto.
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
      " Una fila del mismo tipo que las de reported-presupuesto
      DATA ls_mensaje LIKE LINE OF reported-presupuesto.
      ls_mensaje = VALUE #( %tky        = ls_presu-%tky
                            %state_area = 'IMPUESTO'
                            %msg        = new_message_with_text(
                                            severity = if_abap_behv_message=>severity-error
                                            text     = lx_aviso->get_text( ) ) ).

      " Buscar en %element el campo cuyo nombre trae la excepcion (por ejemplo 'Impuesto')
      ASSIGN COMPONENT lx_aviso->mv_elemento OF STRUCTURE ls_mensaje-%element TO FIELD-SYMBOL(<lv_marca>).
      IF sy-subrc = 0.                         " el campo existe: marcarlo
        <lv_marca> = if_abap_behv=>mk-on.
      ENDIF.
      APPEND ls_mensaje TO reported-presupuesto.
```

`LIKE LINE OF` declara una estructura con el tipo de una fila de otra tabla. Si el nombre no existe como campo, `ASSIGN` no falla: `sy-subrc` vale distinto de 0 y simplemente no se marca nada. Por eso, en 1.7, el campo de la excepción se escribe con el nombre de la vista en *CamelCase*.

## Validations entre objetos de negocio

Algunas reglas miran otra entidad. En el taller: «el titular de un presupuesto es el de su orden». Se leen los datos del otro BO y se compara:

```abap
  METHOD validarTitularDeOrden.
    " 1. Titular y orden de los presupuestos que hay que comprobar
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto FIELDS ( TitularUUID OrdenUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_presupuestos).

    " Los presupuestos sin orden no tienen nada que comprobar
    DELETE lt_presupuestos WHERE OrdenUUID IS INITIAL.
    CHECK lt_presupuestos IS NOT INITIAL.           " si no queda ninguno, salir

    " 2. Titular de cada orden. Es OTRO objeto de negocio: se lee sin IN LOCAL MODE
    READ ENTITIES OF zi_tlorden
      ENTITY Orden FIELDS ( TitularUUID )
      WITH VALUE #( FOR p IN lt_presupuestos ( OrdenUUID = p-OrdenUUID ) )
      RESULT DATA(lt_ordenes).

    " 3. Comparar uno a uno
    LOOP AT lt_presupuestos INTO DATA(ls_presu).
      APPEND VALUE #( %tky = ls_presu-%tky %state_area = 'TITULAR_ORDEN' ) TO reported-presupuesto.

      " La orden de este presupuesto (fila vacia si no se encuentra)
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

## Probar una validation con código

Para comprobar una validation no hace falta la app: basta una clase de consola que intente guardar algo incorrecto y escriba lo que devuelve RAP. En el taller:

```abap
    " Intentar crear un presupuesto con un impuesto imposible
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( TitularUUID Impuesto )
        WITH VALUE #( ( %cid = 'P1' TitularUUID = lv_titular Impuesto = 150 ) ).

    " Guardar y recoger lo que ha fallado (FAILED) y los mensajes (REPORTED)
    COMMIT ENTITIES RESPONSE OF zi_tlpresupuesto
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed-presupuesto IS INITIAL.
      out->write( 'ERROR: se ha guardado y no deberia' ).
    ELSE.
      " Texto del primer mensaje: %msg es un objeto con el interfaz IF_MESSAGE
      out->write( ls_reported-presupuesto[ 1 ]-%msg->if_message~get_text( ) ).
    ENDIF.
```

Si el guardado falla, no se escribe nada en la base de datos: puedes comprobarlo con un `SELECT COUNT( * )` sobre la tabla antes y después.

## Mensajes con clase de mensajes

`new_message_with_text` sirve para el portfolio. En un proyecto real, los textos van en una **clase de mensajes** (objeto *Message Class* en ADT) y la excepción implementa `IF_T100_MESSAGE`, para poder traducirlos sin tocar el código. Si en la empresa ves `%msg = NEW zcx_...( textid = ... )`, es eso. El cambio desde nuestro diseño es pequeño: solo cambia cómo se construye la excepción.

> **Código completo del taller:** [zbp_i_tlpresupuesto](./materiales/taller/src/bus/zbp_i_tlpresupuesto.clas.locals_imp.abap) (y validations con `ASSIGN COMPONENT` en [zbp_i_tltitular](./materiales/taller/src/bus/zbp_i_tltitular.clas.locals_imp.abap)). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Trabajas sobre objetos que ya existen: las BDEF de 3.1 y sus clases de comportamiento (paquete `ZGOR_BUS`), y la clase de consola `ZCL_GOR_EML_DEMO` (paquete `ZGOR_TEST`, de 3.2). No hay que crear objetos nuevos.

En todos los ejercicios, el orden es el mismo:

1. En la **BDEF**: declarar la validation en su entidad y añadirla a `Prepare`.
2. En la **clase de comportamiento**, pestaña *Local Types*, clase local de esa entidad (`lhc_…`): añadir la firma del método en la definición y el método en la implementación.
3. **Activar** la BDEF y la clase a la vez (**Ctrl+Shift+F3** con las dos abiertas).
4. **Comprobar** con una clase de consola o con el test.

## Ejercicios

1. **El IVA del presupuesto.**
    - **Dónde:** BDEF `ZI_GorPresupuesto`, entidad `Presupuesto`; clase `zbp_i_gorpresupuesto`, clase local `lhc_presupuesto`.
    - **En la BDEF:** `validation validarIva on save { create; field Iva; }`, y `validation validarIva;` dentro de `draft determine action Prepare`.
    - **Firma:** `METHODS validarIva FOR VALIDATE ON SAVE IMPORTING keys FOR Presupuesto~validarIva.`
    - **Qué hace:** lee el `Iva` de cada presupuesto, llama a tu `zcl_gor_reglas=>validar_iva( )` y, si lanza `ZCX_GOR_REGLA`, añade la instancia a `failed-presupuesto` y el mensaje a `reported-presupuesto`, con `%state_area = 'IVA'` y `%element-Iva` marcado. Al principio de cada vuelta, limpia el mensaje anterior.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, como en «Probar una validation con código», crea un presupuesto de Elena con `Iva = 150` y guarda. Debe escribir **«El IVA debe estar entre 0 y 100 (es 150)»** (el texto de tu `validar_iva`). Después, escribe cuántos presupuestos hay con `SELECT COUNT( * ) FROM zgor_presu` antes y después del intento: el número no cambia.

2. **El cliente de la obra.**
    - **Dónde:** la misma BDEF y la misma clase local.
    - **En la BDEF:** `validation validarClienteDeObra on save { create; field ClienteUUID, ObraUUID; }`, y en `Prepare`.
    - **Firma:** `METHODS validarClienteDeObra FOR VALIDATE ON SAVE IMPORTING keys FOR Presupuesto~validarClienteDeObra.`
    - **Qué hace** (§11.4): si el presupuesto tiene obra y la obra tiene cliente, ese cliente tiene que ser el del presupuesto. Si no, error en el campo `ClienteUUID` con el texto «El cliente del presupuesto debe ser el de su obra». Lee la obra de **otro** BO (`zi_gorobra`), como `validarTitularDeOrden`.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, intenta guardar un presupuesto de Ana (`CLI0002`) para `OBR0001` (que es de Juan): debe escribir ese mensaje. Repite con Juan como cliente: se guarda y `FAILED` está vacío.

3. **Las demás validaciones.** Para cada fila: declárala en la entidad indicada de su BDEF y en la `Prepare` de la **raíz**, escribe su método en la clase local de esa entidad y marca el campo de `mv_campo` de la excepción (con `ASSIGN COMPONENT`). La firma es siempre `METHODS <nombre> FOR VALIDATE ON SAVE IMPORTING keys FOR <alias>~<nombre>.`

    | BDEF (alias de la entidad) | Validation y disparador | Comprueba (§11.4) | Usa |
    |---|---|---|---|
    | `ZI_GorCliente` (`Cliente`) | `validarObligatorios` · `create; field Nombre, Direccion, Telf` | Nombre, dirección y teléfono tienen valor | `validar_obligatorio` |
    | `ZI_GorCliente` (`Cliente`) | `validarNifUnico` · `create; field Nif` | Si tiene NIF, no hay otro cliente con el mismo | `SELECT COUNT( * ) FROM zgor_cli WHERE nif = … AND cliente_uuid <> …` |
    | `ZI_GorTrabajador` (`Trabajador`) | `validarTrabajador` · `create; field Nombre, Apellido, CosteHoraEstandar` | Nombre y apellido; coste/hora ≥ 0 | `validar_obligatorio`, `validar_no_negativo` |
    | `ZI_GorTrabajador` (`Falta`) | `validarFechas` · `create; field FechaInicio, FechaFin` | Fin ≥ inicio | `validar_fechas` |
    | `ZI_GorProveedor` (`Proveedor`) | `validarBase` · `create; field Base` | Base ≥ 0 | `validar_no_negativo` |
    | `ZI_GorEspecialista` (`Especialista`) | `validarEspecialista` · `create; field Nombre, Importe` | Nombre; importe ≥ 0 | `validar_obligatorio`, `validar_no_negativo` |
    | `ZI_GorPresupuesto` (`Presupuesto`) | `validarCliente` · `create; field ClienteUUID` | Tiene cliente | `ClienteUUID IS INITIAL` |
    | `ZI_GorObra` (`Obra`) | `validarCambioCliente` · `field ClienteUUID` | Si tiene cliente, ninguno de sus presupuestos ni de sus ingresos con cliente es de otro (§3.5) | `SELECT` sobre `zgor_presu` y `zgor_ing` |
    | `ZI_GorObra` (`Gasto`) | `validarFechasObra` · `create; field InicioObra, FinObra` | Fin ≥ inicio | `validar_fechas` |
    | `ZI_GorIngreso` (`Ingreso`) | `validarIngreso` · `create; field ObraUUID, ClienteUUID` | Tiene obra (§3.8); el cliente, si lo tiene, es el de la obra | `ObraUUID IS INITIAL` y lectura de `zi_gorobra` |
    | `ZI_GorParteTrabajo` (`ParteTrabajo`) | `validarParte` · `create; field ObraUUID, Descripcion` | Obra y descripción | `validar_obligatorio` |
    | `ZI_GorParteTrabajo` (`Linea`) | `validarLinea` · `create; field TrabajadorUUID, Horas` | Trabajador; 0 ≤ horas ≤ 24 | `validar_horas` |
    | `ZI_GorParteEsp` y `ZI_GorParteProv` | `validarParteExterno` · `create; field ObraUUID, Importe` | Obra y especialista (o proveedor); importe > 0 | `validar_importe_positivo` |

    En la `Prepare` de la raíz, las validations de una entidad hija llevan delante su alias: `validation Falta~validarFechas;`.

4. **El paso 9 de §12.7, con código.**
    - **Dónde:** una clase de consola nueva, `ZCL_GOR_PASO9`, en `ZGOR_TEST` (*New → ABAP Class*, descripción `Paso 9 del escenario: casos rechazados`).
    - **Qué hace:** un intento de guardar por cada caso, cada uno con su `MODIFY ENTITIES` y su `COMMIT ENTITIES RESPONSE`: una línea de parte de 25 h, una de −1 h, un parte de proveedor de 0 €, un presupuesto con IVA 150 y una falta con fin anterior al inicio. Para cada uno escribe una línea `<caso>: <mensaje>`.
    - **Comprueba:** salen **5 líneas**, todas con mensaje (ninguna «se ha guardado»), y los textos son los de tus métodos `validar_*` de 1.7.

5. **Investiga.** En tu `validarIva`, quita la línea que limpia el mensaje anterior (la del `%state_area` sin `%msg`) y activa. Cuando tengas la app del Bloque 4: pon un IVA de 150, guarda, corrige a 21 y vuelve a guardar. ¿Qué pasa con el mensaje? Vuelve a poner la línea y anota la explicación en un comentario del método.

## Comprueba tu solución automáticamente (opcional)

Pega [3_4_ltcl_validations.abap](materiales/tests/3_4_ltcl_validations.abap) en la pestaña **Test Classes** de `zbp_i_gorpresupuesto`, debajo de la de 3.3, y ejecuta con **Ctrl+Shift+F10**: **6 tests en verde** (3 + 3).

---

**Siguiente:** [3.5. Actions](./3_5_actions.md)
