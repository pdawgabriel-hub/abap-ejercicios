# 6.7. Business events

> **Zona menos verificada.** Los eventos de RAP y su consumo dentro del mismo sistema existen en las versiones recientes de ABAP Cloud, pero la sintaxis exacta no se ha probado contra el trial. Si el editor no acepta algo, pulsa **F1** sobre la palabra clave y consulta la documentación de *RAP Business Events*.

Hasta ahora, cuando algo pasaba en un objeto de negocio, la reacción estaba programada **dentro** de él: al crear una orden, su *determination* crea la hoja de costes. Pero a veces lo que pasa en un objeto le interesa a **otros**: cuando el titular termina de pagar una orden, quizá el departamento de contabilidad quiera registrarlo, o un sistema externo quiera enviar un correo de agradecimiento. Si el abono tuviera que llamar a cada uno de ellos, quedaría atado a todos.

Un ***business event*** invierte la relación: el objeto **anuncia** «ha pasado esto» y quien esté interesado **se suscribe**, sin que el objeto sepa quién escucha. Es el patrón publicador-suscriptor (como los *signals* de Django o los eventos del DOM en JavaScript).

## Declarar y lanzar un evento

En el taller, el abono anuncia que se ha registrado. El evento se declara en la BDEF de la raíz, con un parámetro opcional para los datos que acompañan al aviso:

```cds
@EndUserText.label: 'Taller - Datos del evento AbonoRegistrado'
// Los datos que viajan con el aviso
define abstract entity ZA_TlAbonoRegistrado
{
  OrdenUUID       : sysuuid_x16;
  CantidadAbonada : abap.dec(15,2);
}
```

```bdef
// El evento se lanza al guardar: hace falta el guardado adicional
managed with additional save implementation in class zbp_i_tlabono unique;
...
define behavior for ZI_TlAbono alias Abono
...
{
  create;
  ...
  // El BO anuncia que algo ha pasado; no sabe quien escucha
  event AbonoRegistrado parameter ZA_TlAbonoRegistrado;
}
```

Un evento se lanza **al guardar**, cuando ya es seguro que el cambio ha quedado escrito. Por eso necesita el guardado adicional (como el borrado de la orden en 3.5):

```abap
CLASS lsc_zi_tlabono DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_tlabono IMPLEMENTATION.
  METHOD save_modified.
    CHECK create-abono IS NOT INITIAL.               " solo si se crean abonos
    " Un evento por abono creado, con sus datos en %param
    RAISE ENTITY EVENT zi_tlabono~AbonoRegistrado
      FROM VALUE #( FOR ls IN create-abono
                    ( %key   = ls-%key
                      %param = VALUE #( OrdenUUID       = ls-OrdenUUID
                                        CantidadAbonada = ls-CantidadAbonada ) ) ).
  ENDMETHOD.
ENDCLASS.
```

`create-abono` trae los abonos que se están creando en este guardado; `RAISE ENTITY EVENT` anuncia un evento por cada uno.

## Escuchar un evento

Un **manejador de eventos** es una clase global vacía, `FOR EVENTS OF` el BO, con una clase local que tiene un método por evento:

```abap
" Clase global vacia: solo dice de que BO escucha eventos
CLASS zcl_tl_escucha_abonos DEFINITION PUBLIC ABSTRACT FINAL FOR EVENTS OF zi_tlabono.
ENDCLASS.

CLASS zcl_tl_escucha_abonos IMPLEMENTATION.
ENDCLASS.
```

```abap
" lhe = local handler of events (pestana Local Types)
CLASS lhe_abono DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    " Se ejecuta con cada AbonoRegistrado; it_abonos trae los eventos recibidos
    METHODS al_registrar FOR ENTITY EVENT it_abonos FOR Abono~AbonoRegistrado.
ENDCLASS.

CLASS lhe_abono IMPLEMENTATION.
  METHOD al_registrar.
    " Si con este abono la orden queda liquidada, se apunta en el registro de cobros
    LOOP AT it_abonos INTO DATA(ls_abono).
      " La situacion de la orden ya incluye este abono (ya esta guardado)
      SELECT SINGLE FROM zi_tlordenresumen FIELDS SituacionCobro
        WHERE OrdenUUID = @ls_abono-%param-OrdenUUID INTO @DATA(lv_situacion).
      IF lv_situacion = 'liquidado'.
        TRY.
            DATA(ls_log) = VALUE ztl_cobro_log( log_uuid   = cl_system_uuid=>create_uuid_x16_static( )
                                                orden_uuid = ls_abono-%param-OrdenUUID
                                                mensaje    = 'Orden liquidada' ).
            INSERT ztl_cobro_log FROM @ls_log.
          CATCH cx_uuid_error.
            " Sin UUID no se apunta; el abono ya esta guardado de todos modos
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

El manejador se ejecuta **después** de que el abono se haya guardado, en su propia unidad de trabajo: si falla, el abono no se deshace. Es lo que se quiere: un fallo en la contabilidad no debe impedir registrar un cobro.

Los mismos eventos pueden salir del sistema hacia otras aplicaciones (en BTP, con el servicio *Event Mesh*), sin cambiar la BDEF: el objeto sigue anunciando y no sabe quién escucha.

## Preparación del entorno de trabajo

La entidad abstracta del evento va en `ZGOR_CDS`, el manejador en `ZGOR_BUS` y la tabla de registro en `ZGOR_DDIC`.

## Ejercicios

1. **El evento.**
    - **Dónde:** una entidad abstracta nueva en `ZGOR_CDS`, `ZA_GorIngresoRegistrado` (campos `ObraUUID : sysuuid_x16;` e `Importe : abap.dec(15,2);`); la BDEF y la clase de `ZI_GorIngreso`.
    - **En la BDEF:** la primera línea pasa a `managed with additional save implementation in class zbp_i_goringreso unique;`, y en la entidad, `event IngresoRegistrado parameter ZA_GorIngresoRegistrado;`.
    - **Qué hace:** en `save_modified` de la clase `lsc_` (créala con **Ctrl+1**), `RAISE ENTITY EVENT zi_goringreso~IngresoRegistrado FROM ...` con una fila por cada ingreso de `create-ingreso`, como el abono del taller.
    - **Comprueba:** activa sin errores; el efecto se ve en el ejercicio 3.
2. **El registro.**
    - **Dónde:** la tabla `zgor_cobro_log` en `ZGOR_DDIC` (`client`, `log_uuid` clave, `obra_uuid`, `momento` `timestampl`, `mensaje` `abap.char(120)`), y la clase `ZCL_GOR_ESCUCHA_INGRESOS` en `ZGOR_BUS`, `FOR EVENTS OF zi_goringreso`, con su clase local y un método `FOR ENTITY EVENT ... FOR Ingreso~IngresoRegistrado`, como `zcl_tl_escucha_abonos`.
    - **Qué hace:** el manejador, cuando un ingreso deja la obra **pagada** (`EstadoPago = 'pagado'` en `ZI_GorObraFinanzas`), apunta «Obra cobrada del todo» con la fecha y la hora.
3. **Pruébalo.** En `ZCL_GOR_EML_DEMO`, con EML, registra los dos ingresos del escenario de §12.7 sobre una obra nueva (500 y 710). Tras el segundo, `zgor_cobro_log` debe tener una línea; tras el primero, ninguna. Ten en cuenta que el manejador se ejecuta después del *commit*: espera un momento antes de mirar la tabla.
4. **Otro suscriptor.** Añade un segundo método al mismo manejador, o un segundo manejador, que reaccione al mismo evento de otra forma (por ejemplo, escribir en la consola de errores si el ingreso supera el total de la obra, el caso de §11.6). Comprueba que el ingreso no ha tenido que cambiar.
5. **Investiga.** ¿Qué diferencia hay entre resolver el ejercicio 2 con un evento y hacerlo con una *determination* del ingreso? Piensa en qué pasaría si escribir en el registro fallara.

---

**Siguiente:** [7.1. Comprobación final](./7_1_comprobacion.md)
