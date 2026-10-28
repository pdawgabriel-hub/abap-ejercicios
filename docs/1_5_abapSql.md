# 1.5. Tablas de base de datos y ABAP SQL

Hasta ahora todo vivía en memoria y desaparecía al terminar la ejecución. En esta unidad creamos tablas de base de datos y aprendemos a leer y escribir en ellas con **ABAP SQL**. El ejemplo son las dos primeras tablas del taller, titulares y órdenes; tú crearás las dos primeras del ERP, clientes y obras. Serán definitivas: en el Bloque 2 crearás el resto con el mismo patrón y, encima de todas, el modelo CDS.

## Tablas en ABAP Cloud

En ABAP Cloud no hay transacción SE11: una tabla se escribe como **código** en Eclipse, con el objeto **Database Table**. Así es la de titulares del taller:

```cds
@EndUserText.label : 'Taller - Titulares'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_tit {
  // Clave: el mandante y un UUID (16 bytes) que identifica la fila
  key client            : abap.clnt not null;
  key titular_uuid      : sysuuid_x16 not null;
  // Codigo visible para las personas (TIT0001): un campo normal, no la clave
  titular_ref           : abap.char(8);
  razon_social          : abap.char(100);
  documento_id          : abap.char(12);
  contacto              : abap.char(20);
  poblacion             : abap.char(60);
  cp                    : abap.char(5);
  // Campos de administracion: los rellena RAP (quien y cuando crea y modifica)
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
```

Cuatro decisiones que se repetirán en **todas** las tablas, del taller y de tu ERP:

- **`client`** es el mandante: la primera columna de clave de toda tabla de datos de negocio. ABAP SQL lo rellena y lo filtra solo; nunca lo escribimos.
- **La clave técnica es un UUID** (`sysuuid_x16`, 16 bytes), no el código. El código visible (`titular_ref`, `TIT0001`) es un campo normal. En Odoo pasa lo mismo: `id` es la clave y el código sale de una secuencia. Así, el código se puede generar al guardar (3.7) y nunca hay que cambiar una clave.
- **Los cinco campos de administración** del final (quién creó, cuándo, quién cambió por última vez…) los rellenará RAP automáticamente en el Bloque 3. Usan tipos estándar (`abp_*`) que el framework reconoce. Equivalen a los `create_uid`, `create_date`, `write_uid` y `write_date` de Odoo.
- **Las columnas van en minúsculas y sin tildes**, y el nombre de la tabla no pasa de 16 caracteres.

Las anotaciones del principio son las que genera el asistente al crear la tabla. La única que cambia de una tabla a otra es `@EndUserText.label`.

## Una relación

Una orden pertenece a un titular. En Odoo sería un `Many2one`: una columna con el id del otro registro. Aquí es exactamente igual, una columna con el UUID del titular:

```cds
@EndUserText.label : 'Taller - Ordenes de reparacion'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_orden {
  key client            : abap.clnt not null;
  key orden_uuid        : sysuuid_x16 not null;
  orden_ref             : abap.char(8);
  matricula             : abap.char(10);
  averia                : abap.char(255);
  // Relacion con el titular: guarda su UUID (como un Many2one de Odoo)
  titular_uuid          : sysuuid_x16;
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
}
```

¿Y el importe de la orden, el rendimiento, el saldo pendiente…? **No se guardan**: se calcularán al leer, a partir de los presupuestos, las jornadas y los abonos, en las vistas CDS del Bloque 2. Por eso la tabla de órdenes es tan corta.

## ABAP SQL

ABAP SQL es SQL con sintaxis ABAP. Las variables de ABAP llevan **`@`** delante, para distinguirlas de las columnas:

```abap
    " Leer: tabla, columnas, condicion, orden y destino
    SELECT FROM ztl_tit
      FIELDS titular_ref, razon_social, contacto
      WHERE cp = '50001'
      ORDER BY razon_social
      INTO TABLE @DATA(lt_titulares).          " @: variable de ABAP; DATA(...) la declara

    " Una sola fila
    SELECT SINGLE FROM ztl_tit
      FIELDS *
      WHERE titular_ref = 'TIT0001'
      INTO @DATA(ls_titular).
    IF sy-subrc <> 0.
      out->write( 'No existe' ).
    ENDIF.
```

- `INTO TABLE @DATA(...)` declara la tabla interna de resultado con las columnas pedidas.
- `SELECT SINGLE` lee como mucho una fila. Si no encuentra ninguna, `sy-subrc` es distinto de 0.
- Cada `SELECT` es una sola sentencia y termina con un único punto, al final.

**Escribir:**

```abap
    " Tabla interna con las mismas columnas que la tabla de base de datos
    DATA lt_nuevos TYPE STANDARD TABLE OF ztl_tit WITH EMPTY KEY.
    lt_nuevos = VALUE #( ( titular_uuid = lv_uuid titular_ref = 'TIT0001'
                           razon_social = 'Transportes Moncayo SL' contacto = '976111222' cp = '50001' ) ).

    INSERT ztl_tit FROM TABLE @lt_nuevos.        " varias filas (tabla interna)
    INSERT ztl_tit FROM @ls_titular.             " una (estructura)

    UPDATE ztl_tit SET contacto = '976999888' WHERE titular_ref = 'TIT0001'.
    out->write( |Filas modificadas: { sy-dbcnt }| ).

    DELETE FROM ztl_orden WHERE orden_ref = 'ORD0003'.
```

`sy-dbcnt` cuenta las filas afectadas por la última sentencia.

**Agrupar y unir:**

```abap
    " Cuantas ordenes tiene cada titular: una fila por titular_uuid
    SELECT FROM ztl_orden
      FIELDS titular_uuid, COUNT( * ) AS ordenes          " AS da nombre a la columna calculada
      GROUP BY titular_uuid
      INTO TABLE @DATA(lt_por_titular).

    " Ordenes con la razon social de su titular
    SELECT FROM ztl_orden AS o                             " o y t son alias de las tablas
      INNER JOIN ztl_tit AS t ON t~titular_uuid = o~titular_uuid   " solo ordenes con titular
      FIELDS o~orden_ref, o~matricula, t~razon_social
      ORDER BY o~orden_ref
      INTO TABLE @DATA(lt_ordenes).
```

En las uniones, `alias~columna` indica de qué tabla es cada columna. Con `LEFT OUTER JOIN` salen también las filas de la izquierda que no tienen pareja.

> **Cuidado con el `DELETE` sin `WHERE`.** Vacía la tabla entera. Úsalo solo en clases de pruebas, para empezar desde cero, y nunca en código que toque datos reales.

> **Espacios en los paréntesis.** `COUNT( * )`, como `VALUE #( ... )` y las llamadas a métodos, lleva un espacio después de abrir y antes de cerrar el paréntesis.

## UUID nuevos

Cada fila necesita un UUID. Lo genera una clase liberada:

```abap
    TRY.
        " Clase liberada de SAP que genera un UUID nuevo
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.                     " por si falla: se trata en 1.7
        out->write( 'No se pudo generar el UUID' ).
    ENDTRY.
```

El método puede lanzar una excepción, y ABAP obliga a tratarla con `TRY ... CATCH`. Lo explicamos en [1.7](./1_7_excepciones.md); de momento, usa este patrón.

> **ABAP Cloud solo deja usar objetos liberados.** Puedes leer y escribir tus propias tablas, pero no las tablas estándar de SAP. Para datos estándar se usan las vistas CDS liberadas. Si intentas usar algo no liberado, el editor lo marca como error.

> **Código completo del taller:** las tablas [ztl_tit](./materiales/taller/tablas/ztl_tit.tabl.ddl) y [ztl_orden](./materiales/taller/tablas/ztl_orden.tabl.ddl) y [zcl_tl_sql_demo](./materiales/taller/src/test/zcl_tl_sql_demo.clas.abap). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Las tablas van en `ZGOR_DDIC` y la clase de pruebas, en `ZGOR_TEST`. Para crear una tabla: clic derecho en el paquete → **New → Other ABAP Repository Object** → *Database Table*. Al terminar:

```text
ZGOR
├── ZGOR_DDIC
│   ├── ZGOR_CLI           ← Clientes (nueva)
│   └── ZGOR_OBRA          ← Obras (nueva)
├── ZGOR_BUS               (1.2 a 1.4)
└── ZGOR_TEST
    ├── ZCL_GOR_INICIO, ZCL_GOR_TIPOS_DEMO
    └── ZCL_GOR_SQL_DEMO   ← pruebas de ABAP SQL (nueva)
```

## Ejercicios

1. **La tabla de clientes.**
    - **Dónde:** clic derecho en `ZGOR_DDIC` → **New → Other ABAP Repository Object** → *Database Table*. Nombre `zgor_cli`, descripción `Clientes`.
    - **Qué contiene:** las cuatro decisiones del taller (`client`, clave UUID, código aparte y los cinco campos de administración al final) y estas columnas propias, en este orden (§3.1 del informe). Añade comentarios `//` como en `ztl_tit`.

    | Columna | Tipo | Notas |
    |---|---|---|
    | `cliente_uuid` | `sysuuid_x16`, clave | |
    | `cliente_id` | `abap.char(8)` | Código `CLI0001` |
    | `nombre` | `abap.char(60)` | |
    | `apellidos` | `abap.char(80)` | |
    | `nif` | `abap.char(12)` | |
    | `direccion` | `abap.char(120)` | |
    | `cod_postal` | `abap.char(5)` | |
    | `telf` | `abap.char(20)` | |

    - **Comprueba:** la tabla activa sin errores (**Ctrl+F3**).

2. **La tabla de obras.**
    - **Dónde:** igual, en `ZGOR_DDIC`. Nombre `zgor_obra`, descripción `Obras`.
    - **Qué contiene:** `obra_uuid` (clave), `obra_id` (`abap.char(8)`), `descripcion` (`abap.char(255)`) y `cliente_uuid` (`sysuuid_x16`), con `client` y los cinco de administración. Ningún campo calculado de la obra de Odoo (§3.5) va en la tabla: explícalo en un comentario `//` encima de las columnas.
    - **Comprueba:** activa sin errores.

3. **Clientes de prueba.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_SQL_DEMO`, descripción `Pruebas de ABAP SQL`. Ejecutable.
    - **Qué hace:** en `main`, vacía las dos tablas (`DELETE FROM`, primero las obras) y después inserta, con un solo `INSERT ... FROM TABLE`, estos tres clientes, cada uno con su UUID nuevo:

    | Código | Nombre | Apellidos | NIF | Dirección | CP | Teléfono |
    |---|---|---|---|---|---|---|
    | `CLI0001` | Juan | Pérez López | 12345678Z | C/ Mayor 1, Madrid | 28001 | 600111222 |
    | `CLI0002` | Ana | Ruiz Gil | 23456789X | C/ Sol 2, Madrid | 28001 | 600333444 |
    | `CLI0003` | Luis | Mena | 34567890Y | Av. Norte 8, Madrid | 28045 | 600555666 |

    - **Comprueba:** escribe `sy-dbcnt` después del `INSERT`: debe salir **3**.

4. **Obras de prueba.**
    - **Dónde:** el mismo `main`, a continuación.
    - **Qué hace:** inserta cuatro obras: `OBR0001` (Reforma de baño) y `OBR0002` (Cocina) de Juan, `OBR0003` (Pintura) de Ana y `OBR0004` (Tejado) sin cliente. Para poner el cliente, guarda los UUID en variables al crear los clientes o léelos con `SELECT SINGLE`.
    - **Comprueba:** `sy-dbcnt` vale **4**.

5. **Consultas.** En el mismo `main`, escribe en la consola el resultado de cada consulta, con un título antes:
    - Los clientes del CP 28001, ordenados por apellidos: deben salir 2.
    - El número de obras por cliente: Juan 2, Ana 1 y una fila con UUID vacío para la obra sin cliente.
    - Las obras con el nombre de su cliente, primero con `INNER JOIN` (3 filas) y después con `LEFT OUTER JOIN` (4). Explica en un comentario por qué cambia el número.
6. **Modificar y borrar.** En el mismo `main`: cambia el teléfono de `CLI0002` a 600999888 y borra `OBR0004`.
    - **Comprueba:** escribe `sy-dbcnt` después de cada sentencia (**1** y **1**) y vuelve a leer las obras: quedan 3.
7. **Los campos de administración.** Al final del `main`, lee de `zgor_cli` el código, `created_by` y `created_at` de los tres clientes y escríbelos. Salen vacíos, porque has insertado con SQL directo: en el Bloque 3 los rellenará RAP. (Si quieres ver las filas sin escribir código, también puedes abrir la tabla con **F8**, *Data Preview*.)
8. **Investiga.** En Odoo, `nif` es único (§3.1). Busca si en ABAP Cloud se puede declarar un índice único sobre una tabla propia y anota lo que encuentres y en qué fuente. En el Bloque 3 la unicidad se comprobará con una *validation*, que además da un mensaje claro al usuario.

En esta unidad no hay test automático: los datos de base de datos se comprueban mirándolos. En el Bloque 3 llegarán los tests que trabajan con tablas.

---

**Siguiente:** [1.6. Clases y objetos (ABAP OO)](./1_6_oo.md)
