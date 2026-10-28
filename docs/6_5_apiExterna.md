# 6.5. Consumir APIs externas

> **Zona menos verificada.** Las clases del cliente HTTP y de JSON que se usan aquí están liberadas para ABAP Cloud, pero no se han probado contra el trial. Comprueba también que tu trial permite llamadas a Internet: si no, la llamada fallará con un error de destino.

En 4.5 tu ERP **ofrecía** una API. Aquí hace lo contrario: **usa** una API de otro. Muchas aplicaciones de gestión se apoyan en servicios externos (tipos de cambio, validación de direcciones, festivos…). En esta unidad, el taller consulta los **días festivos** en una API REST pública para avisar si se anota una jornada en un festivo. Tú harás lo mismo con los partes de trabajo del ERP.

## El cliente HTTP de ABAP Cloud

En ABAP Cloud solo se pueden usar las clases liberadas. Para HTTP son dos:

| Clase | Para qué |
|---|---|
| `cl_http_destination_provider` | Construir el **destino**: a qué URL (y con qué credenciales) se llama |
| `cl_web_http_client_manager` | Crear el **cliente** que hace la petición sobre ese destino |

Y para leer el JSON de la respuesta, la clase liberada `/ui2/cl_json`, que lo convierte en una tabla interna con los campos que declares.

## El ejemplo: festivos del taller

La API pública `date.nager.at` devuelve los festivos de un país y un año en JSON:

```http
GET https://date.nager.at/api/v3/PublicHolidays/2026/ES
```

```json
[
  { "date": "2026-01-01", "localName": "Año Nuevo", "name": "New Year's Day",
    "global": true, "counties": null },
  { "date": "2026-04-23", "localName": "Día de Aragón", "name": "Saint George's Day",
    "global": false, "counties": [ "ES-AR" ] }
]
```

`global` dice si es festivo en todo el país; si no, `counties` lista las comunidades donde lo es (`ES-AR` es Aragón). La clase del taller:

```abap
CLASS zcl_tl_festivos DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES tt_textos TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES: BEGIN OF ty_festivo,
             date       TYPE string,
             local_name TYPE string,
             global     TYPE abap_bool,
             counties   TYPE tt_textos,
           END OF ty_festivo.
    TYPES tt_festivos TYPE STANDARD TABLE OF ty_festivo WITH EMPTY KEY.

    " Festivos de un anio en Espania, de la API publica date.nager.at
    CLASS-METHODS del_anio
      IMPORTING iv_anio            TYPE i
      RETURNING VALUE(rt_festivos) TYPE tt_festivos
      RAISING   cx_static_check.
ENDCLASS.

CLASS zcl_tl_festivos IMPLEMENTATION.
  METHOD del_anio.
    DATA(lo_destino) = cl_http_destination_provider=>create_by_url(
                         |https://date.nager.at/api/v3/PublicHolidays/{ iv_anio }/ES| ).
    DATA(lo_cliente) = cl_web_http_client_manager=>create_by_http_destination( lo_destino ).

    DATA(lo_respuesta) = lo_cliente->execute( if_web_http_client=>get ).
    DATA(lv_estado) = lo_respuesta->get_status( )-code.
    DATA(lv_json) = lo_respuesta->get_text( ).
    lo_cliente->close( ).

    IF lv_estado <> 200.
      RAISE EXCEPTION NEW zcx_tl_aviso( iv_mensaje = |La API de festivos ha respondido { lv_estado }| ).
    ENDIF.

    /ui2/cl_json=>deserialize( EXPORTING json        = lv_json
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data        = rt_festivos ).
  ENDMETHOD.
ENDCLASS.
```

- `create_by_url` y `create_by_http_destination` pueden lanzar excepciones (`cx_http_dest_provider_error`, `cx_web_http_client_error`). El método las deja pasar con `RAISING cx_static_check`, que las incluye a todas: quien llame decide qué hacer.
- `execute( if_web_http_client=>get )` hace la petición. Para un `POST`, antes se rellena el cuerpo con `lo_cliente->get_http_request( )->set_text( … )` y las cabeceras con `set_header_field( … )`.
- **Siempre** se comprueba el código de estado. Un 404 o un 500 no lanza excepción por sí solo.
- `pretty_mode-camel_case` hace que el campo JSON `localName` se guarde en el componente `local_name`. Los campos del JSON que no estén en la estructura (`name`, `fixed`…) se ignoran.

## No llamar a la API en cada guardado

Llamar a Internet desde una *validation* que se ejecuta en cada guardado sería lento y frágil: si la API no responde, nadie podría guardar una jornada. El taller hace otra cosa: una clase de consola carga los festivos **una vez al año** en una tabla propia, `ztl_festivo` (fecha y nombre), y la validation solo consulta esa tabla. Es una **caché**: la API es la fuente y la tabla es la copia que usa el día a día.

La validation de la jornada, con un **aviso** que no bloquea el guardado:

```abap
      SELECT SINGLE nombre FROM ztl_festivo WHERE fecha = @ls_jornada-Dia INTO @DATA(lv_festivo).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky        = ls_jornada-%tky
                        %state_area = 'FESTIVO'
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-warning
                                        text     = |El { ls_jornada-Dia DATE = USER } es festivo ({ lv_festivo })| )
                        %element-Dia = if_abap_behv=>mk-on ) TO reported-jornada.
      ENDIF.
```

Con `severity-warning` (y sin añadir nada a `failed`), Fiori muestra el aviso en amarillo pero deja guardar: a veces se trabaja en festivo.

## En una empresa: destinos configurados

`create_by_url` escribe la URL en el código. Vale para una API pública sin credenciales y para aprender. En un sistema real, la URL y las credenciales se configuran fuera del código, con un **Communication Arrangement** de salida (*outbound*) o un destino del servicio *Destination* de BTP, y el código los pide por nombre (`cl_http_destination_provider=>create_by_comm_arrangement( … )`). Así, cambiar de entorno (pruebas, producción) no exige tocar el código.

## Preparación del entorno de trabajo

La clase de la API va en `ZGOR_BUS`; la tabla de festivos, en `ZGOR_DDIC`; la clase de carga, en `ZGOR_TEST`.

## Ejercicios

1. **La clase de la API.** Crea `ZCL_GOR_FESTIVOS` con un método estático que devuelva los festivos de un año en España. Ejecútala desde una clase de consola para 2026 y escribe cuántos festivos hay y los tres primeros.
2. **Los de tu comunidad.** Añade un parámetro con el código de la comunidad (por ejemplo `ES-MD`) y devuelve solo los festivos nacionales (`global`) y los de esa comunidad. Compara cuántos salen para dos comunidades distintas.
3. **La caché.** Crea la tabla `zgor_festivo` (`fecha` dats como clave junto a `client`, y `nombre` char(80)) y una clase de consola `ZCL_GOR_CARGA_FESTIVOS` que la vacíe y la rellene con los festivos del año y la comunidad que indiques. Ejecútala.
4. **El aviso.** Añade a tu parte de trabajo una validation `avisarFestivo` (`create; field Fecha`) que, si la fecha es festivo según `zgor_festivo`, añada un **aviso** (no un error) con el nombre del festivo. Pruébalo con EML: el parte se guarda y `REPORTED` trae el aviso.
5. **En el calendario.** Añade a `ZI_GorCalendario` (6.4) una sexta rama con los festivos de `zgor_festivo`.
6. **Investiga.** ¿Qué pasa en tu validation si un año no has cargado los festivos? ¿Y si la API cambia el formato de su JSON? Anota en `diseno.md` cómo lo detectarías y qué harías.

---

**Siguiente:** [6.6. S/4HANA: extender lo estándar](./6_6_s4hana.md)
