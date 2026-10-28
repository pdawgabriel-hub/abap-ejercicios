# 6.6. S/4HANA: extender lo estándar

> **Zona menos verificada.** La parte teórica describe cómo se trabaja en S/4HANA; el trial de BTP **no es un S/4HANA** y no la permite practicar. La parte práctica usa el *sandbox* público de SAP, cuya URL, formato y condiciones de uso pueden cambiar: compruébalos en la web del *SAP Business Accelerator Hub* antes de empezar.

Tu ERP se ha construido **desde cero**: sus propias tablas de clientes, presupuestos y obras. En una empresa que usa **S/4HANA**, el ERP de SAP, casi nunca se hace así: S/4HANA ya trae clientes, proveedores, pedidos, facturas, materiales y contabilidad, y el trabajo consiste en **usar y extender** lo que hay. Esta unidad explica cómo, y termina con una práctica real: consultar los clientes de un S/4HANA de demostración a través de su API y compararlos con los de tu ERP, sin guardar nada.

## Qué trae S/4HANA

S/4HANA cubre los procesos de una empresa: ventas, compras, almacén, producción, finanzas… Sus datos maestros más importantes:

| Objeto estándar | Qué es | En tu ERP sería… |
|---|---|---|
| **Business Partner** | Cualquier persona u organización con la que se trabaja: clientes, proveedores, empleados… Un solo objeto con **roles** | Cliente, Proveedor y Especialista |
| Producto (material) | Lo que se compra, se vende o se fabrica | — |
| Pedido de venta, oferta | Lo que se vende y a quién | Presupuesto |
| Proyecto (*Enterprise Project*) | Un trabajo con fases, costes y facturación | Obra |
| Factura, cobro, contabilidad | El dinero | Ingreso y ficha de gastos |

Fíjate en la primera fila: en S/4HANA no habría una tabla de clientes y otra de proveedores, sino un único *Business Partner* con el rol que toque. Si tu ERP fuera una extensión de un S/4HANA, `zgor_cli` no existiría: la obra apuntaría a un *Business Partner*.

## *Clean core*: cómo se extiende

SAP pide a sus clientes mantener el **núcleo limpio** (*clean core*): no modificar el código ni las tablas de SAP, para poder actualizar el sistema sin romper nada. En su lugar, hay tres formas de extender, de la más sencilla a la más potente:

| Forma | Quién | Qué permite | Dónde |
|---|---|---|---|
| **Extensibilidad *key user*** | Un consultor o usuario avanzado, sin programar | Campos propios en objetos estándar, lógica sencilla, formularios | Apps de Fiori del propio S/4HANA |
| **Extensibilidad de desarrollador** (*on-stack*) | Un programador ABAP Cloud | Objetos propios (como tu ERP) dentro del S/4HANA, usando solo objetos **liberados** de SAP | Eclipse, en el mismo sistema |
| **Extensión *side-by-side*** | Un programador | Una aplicación aparte, en BTP, que habla con S/4HANA por API | SAP BTP (como tu trial) |

Tu ERP, tal como está, es una extensión *side-by-side*: vive en BTP. La misma técnica (ABAP Cloud, RAP, solo objetos liberados) sirve para la extensibilidad de desarrollador dentro de S/4HANA. Por eso lo que has aprendido se aplica directamente.

## Objetos liberados y BO estándar

En la extensibilidad de desarrollador se usan los objetos de SAP que tienen un **contrato de liberación** (el estado *Released* que viste con `I_Country` en 2.3):

- **Vistas CDS liberadas**, para leer: `I_BusinessPartner`, `I_Customer`, `I_Product`…
- **Interfaces de BO** liberadas, para escribir con EML sobre objetos estándar, igual que con los tuyos: por ejemplo, `MODIFY ENTITIES OF I_BusinessPartnerTP_3 …` crea un *Business Partner* pasando por todas las validaciones de SAP.
- **APIs OData** (como la de 4.5, pero de SAP), para leer y escribir desde fuera.

Las tres se buscan en el **SAP Business Accelerator Hub** (`api.sap.com`), el catálogo de todo lo que SAP publica.

## Práctica: la API de *Business Partner*

El *Business Accelerator Hub* ofrece un ***sandbox***: un S/4HANA de demostración con datos de prueba, al que se pueden hacer peticiones de lectura. Para usarlo, entra en `api.sap.com` con una cuenta de SAP, busca la API **Business Partner (A2X)** y copia tu **clave de API** (*Show API Key*).

Es una API OData (versión 2) como la de 4.5:

```http
GET https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner
    ?$top=5&$select=BusinessPartner,BusinessPartnerFullName,BusinessPartnerCategory
    &$expand=to_BusinessPartnerAddress
APIKey: <tu clave>
Accept: application/json
```

```json
{ "d": { "results": [
  { "BusinessPartner": "1000000", "BusinessPartnerFullName": "Inlandskunde DE 1",
    "BusinessPartnerCategory": "2",
    "to_BusinessPartnerAddress": { "results": [ { "CityName": "Berlin", "PostalCode": "10117",
                                                  "StreetName": "…" } ] } } ] } }
```

`BusinessPartnerCategory` es `1` para una persona y `2` para una organización. En OData V2 la lista viene dentro de `d.results`.

En el taller, una clase de consola lee los *Business Partner* con el cliente HTTP de 6.5 y los muestra. No se guarda nada: los datos del *sandbox* son inventados, y el objetivo es ver cómo es un objeto estándar de SAP por dentro. Lo nuevo respecto a 6.5 es la cabecera con la clave y la forma del JSON:

```abap
    " La URL: servicio de Business Partner, 5 registros, 2 campos, en JSON
    DATA(lo_destino) = cl_http_destination_provider=>create_by_url(
      |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner| &&
      |?$top=5&$select=BusinessPartner,BusinessPartnerFullName&$format=json| ).
    DATA(lo_cliente) = cl_web_http_client_manager=>create_by_http_destination( lo_destino ).
    " El sandbox pide la clave de API en una cabecera (lv_clave: nunca escrita en el codigo)
    lo_cliente->get_http_request( )->set_header_field( i_name = 'APIKey' i_value = lv_clave ).
    DATA(lo_respuesta) = lo_cliente->execute( if_web_http_client=>get ).

    " OData V2: { "d": { "results": [ ... ] } }
    TYPES: BEGIN OF ty_bp,
             business_partner           TYPE string,
             business_partner_full_name TYPE string,
           END OF ty_bp.
    TYPES: BEGIN OF ty_resultados,
             results TYPE STANDARD TABLE OF ty_bp WITH EMPTY KEY,
           END OF ty_resultados.
    " La estructura imita el JSON por fuera: d -> results -> lista
    DATA: BEGIN OF ls_respuesta,
            d TYPE ty_resultados,
          END OF ls_respuesta.
    /ui2/cl_json=>deserialize( EXPORTING json        = lo_respuesta->get_text( )
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data        = ls_respuesta ).
    lo_cliente->close( ).
```

Con `pretty_mode-camel_case`, el campo JSON `BusinessPartnerFullName` va al componente `business_partner_full_name`. Después, la clase del taller escribe en la consola cada *Business Partner* junto al campo del titular en el que encajaría: es una forma de comparar el modelo estándar con el propio, sin guardar nada.

**La clave de API no va en el código ni en GitHub.** Para practicar, pásala como constante en una clase que no subas, o léela de una tabla propia que rellenas a mano. En una empresa iría en un destino configurado (6.5).

## Preparación del entorno de trabajo

Una cuenta en `api.sap.com` con la clave de la API de *Business Partner*. La clase de consulta va en `ZGOR_TEST`.

## Ejercicios

1. **El mapa estándar.** Haz en `diseno.md` una tabla con cada entidad de tu ERP y el objeto estándar de S/4HANA que la cubriría (o «ninguno»). Para tres de ellas, busca en el *Business Accelerator Hub* la vista CDS o la API liberada que usarías y apunta su nombre.
2. **Si fuera una extensión.** Explica en media página cómo cambiaría tu modelo de datos si el ERP se construyera **dentro** de un S/4HANA: qué tablas desaparecerían, a qué apuntarían las obras y los partes, y qué se ganaría y se perdería.
3. **Leer el *sandbox*.** Prueba en el navegador o con `curl` la petición de los 5 primeros *Business Partner* con su dirección. Anota qué campos traen el nombre, la calle, el código postal y la ciudad, y dónde estaría el NIF (pista: `to_BusinessPartnerTax`).
4. **Consultar desde ABAP.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_CONSULTAR_BP`, descripción `Consulta de Business Partner del sandbox`, con `if_oo_adt_classrun`. La clave de API, en una constante privada que **no** subas a GitHub (quítala antes del *push* o pon la clase fuera de `ZGOR`).
    - **Qué hace:** como la consulta del taller, lee 5 *Business Partner* de tipo organización (`$filter=BusinessPartnerCategory eq '2'`) con su dirección y su NIF (con `$expand=to_BusinessPartnerAddress,to_BusinessPartnerTax`), y escribe en la consola cada uno junto al campo de tu cliente en el que encajaría cada dato: nombre, dirección, código postal, NIF.
    - **Comprueba:** la consola muestra **5** bloques, cada uno con sus cuatro líneas `Nombre -> zgor_cli-nombre`… Anota en `diseno.md` qué datos de tu cliente no tienen equivalente en el *Business Partner* y cuáles del *Business Partner* no tienes tú.
5. **Investiga.** En la documentación de la API de *Business Partner*, ¿qué roles (`to_BusinessPartnerRole`) tendría un cliente y cuáles un proveedor? ¿Cómo encajarían tus especialistas?

---

**Siguiente:** [6.7. Business events](./6_7_eventos.md)
