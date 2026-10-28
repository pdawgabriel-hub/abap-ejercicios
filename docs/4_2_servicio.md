# 4.2. Service Definition y Service Binding

Las proyecciones dicen **qué** se expone; falta decir **por dónde**. Un servicio OData se publica con dos objetos:

- **Service Definition**: qué entidades forman el servicio y con qué nombre.
- **Service Binding**: con qué protocolo se publica. Para una app Fiori Elements, **OData V4 - UI**.

En el taller hay un solo servicio. Tu ERP tendrá tres, uno por área de trabajo, como los menús de Odoo agrupan los modelos (§4 del informe).

## El servicio del taller

```cds
@EndUserText.label: 'Taller - Servicio de gestion'
define service ZUI_TL_TALLER {
  // expose <vista> as <nombre en el servicio>: una linea por entidad que vera la app
  expose ZC_TlOrden        as Orden;
  expose ZC_TlHojaCostes   as HojaCostes;
  expose ZC_TlOrdenFoto    as OrdenFoto;
  expose ZC_TlPresupuesto  as Presupuesto;
  expose ZC_TlPartida      as Partida;
  expose ZC_TlTitular      as Titular;     // tambien la ayuda de busqueda
  expose ZI_TlOrdenResumen as Resumen;     // solo lectura
}
```

- **Se exponen todas las entidades** que la app va a mostrar, también los hijos y lo que se usa como ayuda de búsqueda.
- El **alias** (`as Orden`) es el nombre del conjunto de datos en OData. En la vista previa elegirás la app por ese nombre.
- `ZI_TlOrdenResumen` se expone directamente, sin proyección, porque es de solo lectura y no tiene comportamiento.

## Publicar

1. Clic derecho en el paquete → **New → Other ABAP Repository Object → Service Definition**. Escribe el contenido y activa.
2. Clic derecho sobre la Service Definition → **New Service Binding**. Nombre: el de la definición con `_O4` al final (`ZUI_TL_TALLER_O4`). Tipo **OData V4 - UI**.
3. Activa el binding y pulsa **Publish** en el editor del binding. Tarda unos segundos.

## Vista previa

Con el binding publicado, el editor muestra las entidades del servicio. Selecciona una raíz (`Orden`) y pulsa **Preview**: se abre en el navegador una app Fiori Elements de tipo *List Report*, con la lista y, al pulsar una fila, la página de detalle (*Object Page*). Es una app real, contra tus datos reales.

Sin anotaciones de interfaz se verá casi vacía: una tabla sin columnas y un botón «Go». Las columnas, filtros y secciones llegan en 4.3.

Para ver el servicio en bruto, abre la URL del servicio (en el editor del binding) y añade `/$metadata`: es el XML que describe las entidades, sus campos y sus acciones. Fiori Elements construye las pantallas leyendo exactamente eso.

> **En el trial**, la vista previa abre el navegador del sistema y puede pedirte iniciar sesión otra vez. Si se abre en blanco, copia la URL a otro navegador.

## Preparación del entorno de trabajo

Las Service Definitions y Bindings van en `ZGOR_SRV`. Los nombres siguen el [Anexo B](./B_nombres.md): `ZUI_GOR_<ÁREA>` y `ZUI_GOR_<ÁREA>_O4`.

## Ejercicios

1. **Los tres servicios.**
    - **Dónde:** en `ZGOR_SRV`, clic derecho → **New → Other ABAP Repository Object** → *Business Services* → **Service Definition**. Tres: `ZUI_GOR_COMERCIAL`, `ZUI_GOR_FINANCIERO` y `ZUI_GOR_RECURSOS`.
    - **Qué contienen:** una línea `expose <proyeccion> as <Nombre>;` por entidad, como `ZUI_TL_TALLER`:

        | Servicio | Expone | Para quién |
        |---|---|---|
        | `ZUI_GOR_COMERCIAL` | Cliente, Presupuesto y Obra, con todos sus hijos, y `ZC_GorObraFinanzas` | El día a día comercial: presupuestar y abrir obras |
        | `ZUI_GOR_FINANCIERO` | Ingreso (con sus hijos), `ZC_GorObraFinanzas` y la Obra como ayuda de búsqueda | Cobros y seguimiento económico |
        | `ZUI_GOR_RECURSOS` | Trabajador (con faltas), Proveedor, Especialista y los tres tipos de parte, con sus hijos | Mano de obra y costes externos |

        Si una entidad sirve de ayuda de búsqueda en un servicio (el cliente en el presupuesto, el trabajador en la línea de parte), tiene que estar expuesta **en ese servicio**.
    - **Comprueba:** activa los tres sin avisos.

2. **Los bindings.**
    - **Dónde:** clic derecho en cada Service Definition → **New Service Binding**. Nombres `ZUI_GOR_COMERCIAL_O4`, `ZUI_GOR_FINANCIERO_O4` y `ZUI_GOR_RECURSOS_O4`, tipo **OData V4 - UI**.
    - **Qué hace:** activa cada binding y pulsa **Publish** en su editor.
    - **Comprueba:** en el editor del binding, la lista *Entity Set and Association* muestra todas las entidades del servicio.

3. **Primera vista previa.** En el binding de `ZUI_GOR_COMERCIAL_O4`, selecciona `Obra` y pulsa **Preview**. En el navegador, pulsa **Go**: aunque no haya columnas, debe decir que hay **4** obras. Pulsa una fila: se abre la página de detalle, todavía vacía. Las columnas llegan en 4.3.

4. **El metadato.** En el editor del binding, el enlace *Service URL* abre el documento de servicio; añádele `$metadata` al final. Busca la entidad `Obra`, la acción `aprobar` y el campo `ClienteNombre`, y anota en `diseno.md` qué es cada cosa.

5. **Investiga.** ¿Qué pasa si en `ZUI_GOR_COMERCIAL` quitas la exposición de `ZC_GorCliente` y activas? Lee el aviso. Vuelve a ponerla.

---

**Siguiente:** [4.3. Metadata Extensions y la interfaz](./4_3_metadataExtensions.md)
