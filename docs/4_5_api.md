# 4.5. El servicio como API

> **Zona menos verificada.** Las URL exactas, la forma de exponer un objeto con *draft* como Web API y los pasos para dar acceso desde fuera (*communication arrangements*) dependen de la versión del sistema y de lo que permita el trial compartido. Toma esta unidad como guía de qué buscar y contrasta con el editor del *binding* y la documentación oficial.

Hasta ahora, el servicio OData lo ha usado una sola aplicación: Fiori. Pero un servicio OData es una **API REST**: cualquier programa que hable HTTP puede leer y escribir en tu ERP a través de él, con las mismas *determinations*, *validations* y permisos que la app. En esta unidad vemos cómo publicar el servicio del taller **para otros sistemas** y cómo usarlo con peticiones HTTP. Tú harás lo mismo con tu ERP y traducirás a OData la API que propone el informe técnico (§12.5).

## OData: REST con convenciones

En una API REST «a mano», cada equipo decide sus URL, sus filtros y su formato. **OData** fija todo eso:

| Qué | Cómo en OData | Ejemplo en el taller |
|---|---|---|
| Una colección | `/<EntitySet>` | `GET /Orden` |
| Un registro | `/<EntitySet>(<clave>)` | `GET /Orden(OrdenUUID=…,IsActiveEntity=true)` |
| Navegar por una relación | `/<registro>/<association>` | `GET /Orden(…)/_HojaCostes` |
| Filtrar | `$filter` | `?$filter=Matricula eq '1234ABC'` |
| Elegir campos | `$select` | `?$select=OrdenRef,Matricula` |
| Traer relacionados | `$expand` | `?$expand=_Titular` |
| Ordenar y paginar | `$orderby`, `$top`, `$skip` | `?$orderby=OrdenRef desc&$top=10` |
| Contar | `$count` | `?$count=true` |
| Buscar | `$search` | `?$search=garcia` |
| Crear, modificar, borrar | `POST`, `PATCH`, `DELETE` | `POST /Orden` |
| Una acción | `POST /<registro>/<espacio de nombres>.<acción>` | `POST /Presupuesto(…)/….aceptar` |
| Qué hay en el servicio | `/$metadata` | La descripción de entidades, campos y acciones |

El JSON de las respuestas y las peticiones tiene siempre la misma forma, y `$metadata` describe el servicio entero: por eso Fiori Elements puede generar las pantallas sin programarlas, y cualquier cliente OData puede usar el servicio sin documentación aparte.

En Odoo, lo equivalente sería la API externa (JSON-RPC o XML-RPC, con `search_read`, `create`, `write`…), o una API REST escrita a mano con controladores, como la que propone §12.5 del informe para una reimplementación.

## UI o Web API

Un mismo servicio se puede publicar con dos tipos de *binding*:

| Tipo | Para quién | Anotaciones de Fiori | *Draft* |
|---|---|---|---|
| **OData V4 - UI** | Una app Fiori | Sí | Sí: crear o editar pasa por un borrador que luego se activa |
| **OData V4 - Web API** | Otros sistemas (integraciones, scripts) | No | No: se trabaja directamente con los registros activos |

Para que otro programa cree una orden, el borrador estorba: tendría que crear el borrador, rellenarlo y activarlo, en tres peticiones. Por eso, para integraciones se publica un servicio aparte con *binding* **Web API**:

```cds
@EndUserText.label: 'Taller - API para otros sistemas'
// Otro servicio sobre las mismas proyecciones: solo las raices que usaria otro sistema
define service ZAPI_TL_TALLER {
  expose ZC_TlOrden       as Orden;
  expose ZC_TlPresupuesto as Presupuesto;
  expose ZC_TlPartida     as Partida;
  expose ZC_TlTitular     as Titular;
}
```

Y el *binding* `ZAPI_TL_TALLER_O4`, de tipo **OData V4 - Web API**. Las proyecciones pueden ser las mismas que las de la app. Si tu sistema no deja publicar como Web API una proyección que usa *draft*, crea una proyección aparte para la API (por ejemplo `ZAPI_TlOrden`) cuya BDEF de proyección no tenga `use draft`.

## Leer

Con el *binding* publicado, el editor muestra la **URL del servicio**. Para leer basta un navegador (con la sesión del trial iniciada):

```http
GET <url del servicio>/Orden?$select=OrdenRef,Matricula&$orderby=OrdenRef&$top=5
```

```json
{
  "@odata.context": "$metadata#Orden(OrdenRef,Matricula)",
  "value": [
    { "OrdenUUID": "6f1d…", "OrdenRef": "ORD0001", "Matricula": "1234ABC" },
    { "OrdenUUID": "a07c…", "OrdenRef": "ORD0002", "Matricula": "5678DEF" }
  ]
}
```

Una orden con su titular y su hoja de costes:

```http
GET <url del servicio>/Orden(OrdenUUID=6f1d…)?$expand=_Titular($select=RazonSocial),_HojaCostes
```

Los UUID van sin comillas, con el formato `8-4-4-4-12`. En un servicio con *draft*, la clave lleva además `IsActiveEntity=true`.

## Escribir: el token CSRF

Para escribir hace falta, además de iniciar sesión, un **token CSRF**: una protección para que otra web no pueda enviar peticiones en tu nombre. Se pide con un `GET` cualquiera y se devuelve en cada escritura:

```bash
# 1. Pedir el token (y guardar la cookie de sesion)
curl -s -c cookies.txt -u USUARIO:CLAVE -H "X-CSRF-Token: Fetch" -D - \
     "<url del servicio>/" -o /dev/null | grep -i x-csrf-token

# 2. Crear una orden con ese token
curl -s -b cookies.txt -u USUARIO:CLAVE -H "X-CSRF-Token: <token>" \
     -H "Content-Type: application/json" -X POST "<url del servicio>/Orden" \
     -d '{ "Matricula": "9999ZZZ", "Averia": "Ruido al frenar", "TitularUUID": "3b2a…" }'
```

La respuesta trae la orden creada, ya con su `OrdenRef`: la ha puesto la *determination* de numeración, exactamente igual que si la hubiera creado alguien desde la app. Si una *validation* falla (por ejemplo, falta la matrícula), la respuesta es un **error 400** con el mensaje de la validation en el JSON.

Modificar y borrar:

```http
PATCH  <url>/Orden(OrdenUUID=…)        { "Averia": "Ruido al frenar en frio" }
DELETE <url>/Orden(OrdenUUID=…)
```

Una acción se llama con `POST` sobre el registro, con el nombre completo de la acción. El espacio de nombres sale en el `$metadata` (algo como `com.sap.gateway.srvd_a2x.zapi_tl_taller.v0001`):

```http
POST <url>/Presupuesto(PresupuestoUUID=…)/com.sap.gateway.srvd_a2x.zapi_tl_taller.v0001.aceptar
{}
```

## Acceso desde fuera

El navegador puede leer porque ya tiene tu sesión del trial. Un programa externo necesita su propio usuario. En SAP BTP eso se hace con tres piezas:

1. Un **Communication Scenario** (objeto de ADT) que incluye el servicio como *inbound service*.
2. Un **Communication System** y un **Communication User** (usuario y contraseña técnicos), en las apps de administración del sistema.
3. Un **Communication Arrangement**, que une el escenario con el sistema y el usuario. Con ese usuario y su contraseña se hacen las peticiones de arriba (`-u USUARIO:CLAVE`).

En el trial compartido es posible que tu usuario no pueda crear las piezas 2 y 3. Si es así, prueba las lecturas desde el navegador y las escrituras desde el propio sistema con EML (3.2), y anota en el README cómo se haría.

> **Código completo del taller:** [ZAPI_TL_TALLER](./materiales/taller/src/srv/zapi_tl_taller.srvd.srvdsrv). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

La Service Definition y el *binding* de la API van en `ZGOR_SRV`, con el prefijo `ZAPI_GOR`. Para las peticiones, cualquier cliente HTTP: `curl`, Postman, o una extensión de VS Code como *REST Client*.

## Ejercicios

1. **La API del ERP.**
    - **Dónde:** `ZGOR_SRV`: la Service Definition `ZAPI_GOR_ERP` (descripción `ERP - API para otros sistemas`) y su binding `ZAPI_GOR_ERP_O4`, de tipo **OData V4 - Web API**.
    - **Qué contiene:** como `ZAPI_TL_TALLER`, las raíces que necesitaría otro sistema: clientes, presupuestos (con líneas), obras (con su ficha de gastos), ingresos y la ficha financiera (`ZC_GorObraFinanzas`). Si el binding no se deja publicar por el *draft*, crea para las raíces que lo necesiten proyecciones de API (`ZAPI_GorCliente`…) cuya BDEF de proyección no tenga `use draft`.
    - **Comprueba:** publica el binding y abre en el navegador `<url del servicio>/Cliente?$top=2`: devuelve un JSON con dos clientes.

2. **Lecturas.** Escribe en `diseno.md` la petición de cada caso y pruébala en el navegador:
    - las obras de un cliente, por su código, con su ficha financiera (`$filter` sobre la ruta `_Cliente/ClienteId` y `$expand=_Finanzas`);
    - los presupuestos aprobados de 2026, ordenados por total de mayor a menor;
    - las obras con salud `rojo`, solo con código, descripción y beneficio;
    - cuántos ingresos hay en total, sin traerlos (`$count`).

    **Comprueba:** con los datos de 2.5, el primero da una obra para `CLI0001` (`OBR0001`, con su ficha); el segundo, tres presupuestos con totales 2200, 1452 y 1210; el tercero, solo `OBR0002`; el cuarto, **4**.

3. **La API de §12.5.** El informe propone una API REST mínima para una reimplementación. Haz en `diseno.md` una tabla con cada línea de §12.5 y su equivalente en tu servicio OData. Por ejemplo, `GET /buscar/clientes?q=juan perez` es `GET /Cliente?$search=juan perez`, y `POST /obras/{id}/vincular-presupuesto` es la acción `vincularAObra` sobre el presupuesto. Marca las que no tengan equivalente directo y explica por qué.

4. **Escribir (si el trial lo permite).**
    - **Dónde:** un terminal, con `curl`, y un usuario de comunicación (sección «Acceso desde fuera»).
    - **Qué haces:** pide el token CSRF; crea un cliente con `POST` **sin teléfono**; créalo bien; aprueba un presupuesto con la acción `aprobar`.
    - **Comprueba:** el primer `POST` responde **400** con el mensaje de tu validation; el segundo, **201** con el cliente y su código `CLI…`; la acción devuelve el presupuesto con `Estado` `aprobado`.

5. **El mismo servicio, dos usos.** Compara el `$metadata` de `ZUI_GOR_COMERCIAL_O4` (UI) con el de `ZAPI_GOR_ERP_O4` (Web API). ¿Qué hay en uno que no está en el otro? Busca `IsActiveEntity` y las anotaciones `UI`.

6. **Investiga.** ¿Qué es una petición `$batch` en OData y por qué la usa Fiori? Anota un caso del ERP en el que una integración la necesitaría.

---

**Siguiente:** [4.6. Proyecto: las tres apps](./4_6_proyecto.md)
