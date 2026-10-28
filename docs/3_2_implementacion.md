# 3.2. La clase de implementación

La BDEF declara **qué** hace cada objeto de negocio; la **clase de implementación** (*behavior pool*) dice **cómo**. En esta unidad ves cómo es la del titular del taller y crearás las diez de tu ERP, todavía casi vacías, para que las BDEF activen. Y aprenderás **EML** (*Entity Manipulation Language*), el lenguaje con el que se leen y modifican los objetos de negocio desde ABAP. Lo usaremos en toda la lógica del bloque y en los tests.

## La clase y sus pestañas

Una clase de comportamiento es una clase global **abstracta y vacía**. Todo el código va en sus clases **locales**, en la pestaña inferior **Local Types**:

```abap
" La clase global: abstracta, final y vacia. Solo dice de que BO es el comportamiento
CLASS zbp_i_tltitular DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_tltitular.
ENDCLASS.

CLASS zbp_i_tltitular IMPLEMENTATION.
ENDCLASS.
```

En *Local Types* hay una clase **manejadora** (*handler*, `lhc_`) por entidad, con un método por cada cosa que declara la BDEF. Para el titular, de momento, solo los permisos:

```abap
" Manejadora de la entidad Titular (lhc = local handler class)
CLASS lhc_titular DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " Firma generada por Eclipse: RAP la llama antes de cada operacion
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Titular RESULT result.
ENDCLASS.

CLASS lhc_titular IMPLEMENTATION.
  METHOD get_global_authorizations.
    " De momento se permite todo; los roles llegan en 6.1
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.
ENDCLASS.
```

Cada vez que añadamos una *determination*, una *validation* o una acción a la BDEF, aparecerá aquí su método. **No hace falta escribir las firmas a mano**: con el cursor sobre el nombre en la BDEF, **Ctrl+1** → *Add missing method*.

## Crear la clase

1. En la BDEF, cursor sobre el nombre de la clase (`zbp_i_tltitular`) → **Ctrl+1** → *Create behavior implementation class*.
2. Eclipse crea la clase con *Local Types* ya rellena: un `lhc_titular` con `get_global_authorizations` vacío.
3. Completa `get_global_authorizations` como arriba y activa la clase. Después activa la BDEF.

## EML: leer y modificar objetos de negocio

EML son sentencias ABAP para trabajar con un BO **a través de su comportamiento**: al crear un titular con EML se ejecutan sus *determinations* y *validations*, igual que si lo creara un usuario desde Fiori. Con ABAP SQL directo (como en 2.5) no se ejecuta nada de eso.

**Crear:**

```abap
    " Crear un titular a traves de su comportamiento (se ejecuta su logica)
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular                                   " alias de la BDEF
        CREATE FIELDS ( RazonSocial DocumentoId Contacto )   " campos que se informan
        WITH VALUE #( ( %cid        = 'nuevo'           " id temporal: aun no hay UUID
                        RazonSocial = 'Autoescuela Pilar'
                        DocumentoId = 'B50999888'
                        Contacto    = '976333444' ) )
      MAPPED   DATA(ls_mapped)                         " %cid -> UUID asignado
      FAILED   DATA(ls_failed)                         " que instancias fallaron
      REPORTED DATA(ls_reported).                      " con que mensajes

    " Guardar: aqui se ejecutan las validations; si una falla, no se guarda nada
    COMMIT ENTITIES RESPONSE OF zi_tltitular
      FAILED   DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).
```

- `ENTITY Titular` usa el **alias** de la BDEF.
- `FIELDS ( ... )` dice qué campos se informan; el resto queda vacío (o lo rellena una *determination*).
- `%cid` es un identificador temporal de la petición: todavía no hay UUID, y con `%cid` se puede referir al registro nuevo en la misma sentencia (por ejemplo, para crearle partidas).
- `MAPPED` devuelve el UUID asignado a cada `%cid`; `FAILED`, las instancias que fallaron; `REPORTED`, los mensajes.
- **`COMMIT ENTITIES`** guarda. Antes del *commit* se ejecutan las *determinations* y *validations* «on save», y si alguna falla no se guarda nada. Es como el `env.cr.commit()` del `odoo shell` (§13.3 del informe): sin él, los cambios se pierden.

**Leer:**

```abap
    " Leer: las claves de las instancias van en la tabla de WITH
    READ ENTITIES OF zi_tltitular
      ENTITY Titular
        FIELDS ( TitularRef RazonSocial ) WITH VALUE #( ( TitularUUID = lv_uuid ) )
      RESULT DATA(lt_titulares)                        " una fila por instancia leida
      FAILED DATA(ls_failed_read).
```

**Modificar y borrar:**

```abap
    " Varias operaciones en una sola sentencia: cambiar y despues borrar
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular
        UPDATE FIELDS ( Contacto )                     " solo se cambia Contacto WITH VALUE #( ( TitularUUID = lv_uuid Contacto = '976000111' ) )
      ENTITY Titular
        DELETE FROM VALUE #( ( TitularUUID = lv_uuid ) )
      FAILED DATA(ls_failed_mod).
    COMMIT ENTITIES.                                   " sin commit, no se guarda nada
```

**Hijos a través de la raíz** (`CREATE BY \_Partidas`): se crea el presupuesto y su partida en la misma sentencia, enlazados por `%cid_ref`:

```abap
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        " 1. La cabecera, con el id temporal 'p1'
        CREATE FIELDS ( TitularUUID Impuesto ) WITH VALUE #( ( %cid = 'p1' TitularUUID = lv_titular Impuesto = 21 ) )
        " 2. Sus partidas, colgando de 'p1' (%cid_ref); %target son las filas hijas
        CREATE BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario )
          WITH VALUE #( ( %cid_ref = 'p1'
                          %target  = VALUE #( ( %cid = 'pa1' Concepto = 'Kit de embrague'
                                                Cantidad = 1 PrecioUnitario = 320 ) ) ) )
      MAPPED DATA(ls_mapped_p).
```

La barra invertida de `\_Partidas` es parte de la sintaxis: indica que se navega por una association.

## Algunas piezas de EML

| Pieza | Qué es |
|---|---|
| `%tky` | La clave de una instancia **incluyendo si es borrador o activa**. Dentro de la lógica, siempre se propaga tal cual: `%tky = ls_titular-%tky` |
| `%is_draft` | `if_abap_behv=>mk-on` si es un borrador. Desde una clase de consola, por defecto se trabaja con datos activos |
| `IN LOCAL MODE` | Dentro de la clase de comportamiento: se saltan los permisos y los campos `readonly`. Es como el `sudo()` de Odoo para la lógica del propio BO |
| `failed-titular`, `reported-titular` | Dentro de la lógica, las tablas donde se marca qué instancias fallan y con qué mensaje. El nombre es el alias en minúsculas |

## Preparación del entorno de trabajo

Una clase `zbp_i_gor<raíz>` por BDEF, en `ZGOR_BUS`. La de pruebas de EML, en `ZGOR_TEST`:

```text
ZGOR_BUS
├── ZI_GorCliente (BDEF) + ZBP_I_GORCLIENTE
├── ZI_GorTrabajador (BDEF) + ZBP_I_GORTRABAJADOR
├── ...                                         (diez en total)
ZGOR_TEST
└── ZCL_GOR_EML_DEMO                            ← nueva
```

## Ejercicios

1. **La clase del cliente.**
    - **Dónde:** abre tu BDEF de `ZI_GorCliente`, pon el cursor sobre `zbp_i_gorcliente` (en la primera línea) y pulsa **Ctrl+1** → *Create behavior implementation class*. Paquete `ZGOR_BUS`.
    - **Qué contiene:** Eclipse genera la clase global vacía y, en la pestaña *Local Types*, la clase `lhc_cliente` con el método `get_global_authorizations`. Rellénalo como el del titular: `result` con `%create`, `%update`, `%delete` y `%action-Edit` a `if_abap_behv=>auth-allowed`, con un comentario que diga que en 6.1 se cambiará por una comprobación de verdad.
    - **Comprueba:** activa la clase y después la BDEF (**Ctrl+Shift+F3** con las dos abiertas). En *Problems* no debe quedar ningún error del cliente.

2. **Las demás clases.**
    - **Dónde:** las otras nueve BDEF, igual que el ejercicio anterior. Los nombres, `zbp_i_` seguido del nombre de la vista: `zbp_i_gorpresupuesto`, `zbp_i_gortrabajador`…
    - **Qué contiene:** en las que tienen hijos, Eclipse crea un `lhc_` por entidad (`lhc_presupuesto`, `lhc_linea`…), pero solo la raíz tiene `get_global_authorizations`: los hijos dependen de ella.
    - **Comprueba:** clic derecho en `ZGOR_BUS` → **Activate**, con todo seleccionado. Debe activar sin errores.

3. **Crear con EML.**
    - **Dónde:** clic derecho en `ZGOR_TEST` → **New → ABAP Class**. Nombre `ZCL_GOR_EML_DEMO`, descripción `Pruebas de EML con el ERP`, con la interfaz `if_oo_adt_classrun`. A partir de aquí, cada ejercicio es un bloque de `main` separado por un comentario (`" 3.2 Crear`).
    - **Qué hace:** con `MODIFY ENTITIES OF zi_gorcliente ENTITY Cliente CREATE FIELDS ( Nombre Apellidos Direccion Telf ) WITH ...` crea la clienta Elena Vidal Soler (C/ Sol 3, Zaragoza, 600222333), con un `%cid` cualquiera (`'ELENA'`). Recoge `MAPPED`, `FAILED` y `REPORTED`, y después guarda con `COMMIT ENTITIES` recogiendo también su `FAILED` y `REPORTED`.
    - **Comprueba:** escribe en la consola el UUID que aparece en `mapped-cliente[ 1 ]-ClienteUUID` y si `failed` está vacío. Después, `SELECT COUNT( * ) FROM zi_gorcliente WHERE nombre = 'Elena'` debe dar **1**.

    > Si `COMMIT ENTITIES` devuelve errores y Elena no aparece, mira `reported`: lo más probable es que falte un campo obligatorio del ejercicio 1 de 3.1.

4. **Leer, cambiar y borrar.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.2 Leer, cambiar y borrar`.
    - **Qué hace:** con el UUID de Elena (léelo con `SELECT SINGLE` si lo necesitas):
        - `READ ENTITIES` para leer su teléfono y escribirlo;
        - `MODIFY ... UPDATE FIELDS ( Telf )` con `600999000`, `COMMIT ENTITIES` y otra lectura para comprobarlo;
        - `MODIFY ... DELETE` y `COMMIT ENTITIES`.
    - **Comprueba:** la consola debe mostrar `600222333` y después `600999000`, y al final `SELECT COUNT( * ) FROM zi_gorcliente WHERE nombre = 'Elena'` debe dar **0**.

5. **Los campos de administración.**
    - **Dónde:** el mismo `main`: comenta el bloque de borrar (con **Ctrl+<**) y vuelve a ejecutar la clase, para que Elena quede creada.
    - **Qué hace:** lee de `zi_gorcliente` los campos `ClienteId, CreatedBy, CreatedAt, LastChangedAt` de Elena y escríbelos.
    - **Comprueba:** `CreatedBy`, `CreatedAt` y `LastChangedAt` tienen valor, porque los ha rellenado RAP gracias a las anotaciones `@Semantics` de 2.2. `ClienteId` sale **vacío**: lo pondrás en 3.7.

6. **Un presupuesto con línea.**
    - **Dónde:** `ZCL_GOR_EML_DEMO`, bloque `" 3.2 Presupuesto con linea`.
    - **Qué hace:** en **una sola** sentencia `MODIFY ENTITIES OF zi_gorpresupuesto`, crea un presupuesto para Elena con IVA 21 (`ENTITY Presupuesto CREATE ... %cid = 'P1'`) y, con `CREATE BY \_Lineas`, una línea de 10 uds a 100 € que apunta al presupuesto por su `%cid_ref = 'P1'`. Guarda con `COMMIT ENTITIES`.
    - **Comprueba:** lee la línea con `SELECT FROM zi_gorpresulin FIELDS Uds, Precio, TotalLinea, \_Presupuesto-Total WHERE ...` (ruta de 2.3): 10 y 100, pero `TotalLinea` y `Total` siguen a **0**. Los calcularán tus *determinations* de 3.3.

7. **Investiga.** Intenta cambiar con EML (sin `IN LOCAL MODE`, desde tu clase de consola) el campo `ClienteId` de Elena. ¿Qué devuelve `FAILED` o `REPORTED`? ¿Por qué la lógica del propio BO sí podrá escribirlo? Contéstalo en un comentario encima del bloque.

---

**Siguiente:** [3.3. Determinations](./3_3_determinations.md)
