# 3.2. La clase de implementación

La BDEF declara **qué** hace cada objeto de negocio; la **clase de implementación** (*behavior pool*) dice **cómo**. En esta unidad ves cómo es la del titular del taller y crearás las diez de tu ERP, todavía casi vacías, para que las BDEF activen. Y aprenderás **EML** (*Entity Manipulation Language*), el lenguaje con el que se leen y modifican los objetos de negocio desde ABAP. Lo usaremos en toda la lógica del bloque y en los tests.

## La clase y sus pestañas

Una clase de comportamiento es una clase global **abstracta y vacía**. Todo el código va en sus clases **locales**, en la pestaña inferior **Local Types**:

```abap
CLASS zbp_i_tltitular DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_tltitular.
ENDCLASS.

CLASS zbp_i_tltitular IMPLEMENTATION.
ENDCLASS.
```

En *Local Types* hay una clase **manejadora** (*handler*, `lhc_`) por entidad, con un método por cada cosa que declara la BDEF. Para el titular, de momento, solo los permisos:

```abap
CLASS lhc_titular DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
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
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular
        CREATE FIELDS ( RazonSocial DocumentoId Contacto )
        WITH VALUE #( ( %cid        = 'nuevo'
                        RazonSocial = 'Autoescuela Pilar'
                        DocumentoId = 'B50999888'
                        Contacto    = '976333444' ) )
      MAPPED   DATA(ls_mapped)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    COMMIT ENTITIES RESPONSE OF zi_tltitular
      FAILED   DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).
```

- `ENTITY Cliente` usa el **alias** de la BDEF.
- `FIELDS ( ... )` dice qué campos se informan; el resto queda vacío (o lo rellena una *determination*).
- `%cid` es un identificador temporal de la petición: todavía no hay UUID, y con `%cid` se puede referir al registro nuevo en la misma sentencia (por ejemplo, para crearle partidas).
- `MAPPED` devuelve el UUID asignado a cada `%cid`; `FAILED`, las instancias que fallaron; `REPORTED`, los mensajes.
- **`COMMIT ENTITIES`** guarda. Antes del *commit* se ejecutan las *determinations* y *validations* «on save», y si alguna falla no se guarda nada. Es como el `env.cr.commit()` del `odoo shell` (§13.3 del informe): sin él, los cambios se pierden.

**Leer:**

```abap
    READ ENTITIES OF zi_tltitular
      ENTITY Titular
        FIELDS ( TitularRef RazonSocial ) WITH VALUE #( ( TitularUUID = lv_uuid ) )
      RESULT DATA(lt_titulares)
      FAILED DATA(ls_failed_read).
```

**Modificar y borrar:**

```abap
    MODIFY ENTITIES OF zi_tltitular
      ENTITY Titular
        UPDATE FIELDS ( Contacto ) WITH VALUE #( ( TitularUUID = lv_uuid Contacto = '976000111' ) )
      ENTITY Titular
        DELETE FROM VALUE #( ( TitularUUID = lv_uuid ) )
      FAILED DATA(ls_failed_mod).
    COMMIT ENTITIES.
```

**Hijos a través de la raíz** (`CREATE BY \_Partidas`): se crea el presupuesto y su partida en la misma sentencia, enlazados por `%cid_ref`:

```abap
    MODIFY ENTITIES OF zi_tlpresupuesto
      ENTITY Presupuesto
        CREATE FIELDS ( TitularUUID Impuesto ) WITH VALUE #( ( %cid = 'p1' TitularUUID = lv_titular Impuesto = 21 ) )
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

```
ZGOR_BUS
├── ZI_GorCliente (BDEF) + ZBP_I_GORCLIENTE
├── ZI_GorTrabajador (BDEF) + ZBP_I_GORTRABAJADOR
├── ...                                         (diez en total)
ZGOR_TEST
└── ZCL_GOR_EML_DEMO                            ← nueva
```

## Ejercicios

1. **El cliente.** Crea `zbp_i_gorcliente` con *Ctrl+1* desde tu BDEF. Su `get_global_authorizations` debe permitir, de momento, crear, modificar, borrar y editar. Activa la clase y la BDEF.
2. **Las demás.** Haz lo mismo con las otras nueve BDEF. En las que tienen hijos, Eclipse crea un `lhc_` por entidad, pero solo la raíz tiene `get_global_authorizations` (los hijos dependen de ella). Activa todo junto (clic derecho en `ZGOR_BUS` → *Activate*).
3. **Crear con EML.** Crea en `ZGOR_TEST` la clase ejecutable `ZCL_GOR_EML_DEMO`. Crea con EML la clienta Elena Vidal Soler (C/ Sol 3, Zaragoza, 600222333), guarda con `COMMIT ENTITIES` y escribe en la consola su UUID nuevo (sale en `MAPPED`) y si hubo errores al guardar.
4. **Leer, cambiar y borrar.** En la misma clase, lee la clienta recién creada, cámbiale el teléfono, vuelve a leerla para comprobarlo y bórrala, guardando tras cada modificación. Comprueba en el Data Preview de `ZI_GorCliente` que ha desaparecido.
5. **Mira los campos de administración.** Crea otra vez a Elena y **no** la borres. En el Data Preview, `CreatedBy`, `CreatedAt` y `LastChangedAt` tienen valor, porque los ha rellenado RAP gracias a las anotaciones `@Semantics` de 2.2. `ClienteId` sigue vacío: lo pondrás en 3.7.
6. **Un presupuesto con línea.** Crea con EML, en una sola sentencia, un presupuesto para Elena con IVA 21 y una línea de 10 uds a 100 €, y guarda. Comprueba en el Data Preview que la línea apunta al presupuesto. `TotalLinea`, `BaseImponible` y `Total` siguen a 0: los calcularán tus *determinations* de 3.3.
7. **Investiga.** Intenta cambiar con EML (sin `IN LOCAL MODE`, desde tu clase de consola) el campo `ClienteId` de Elena. ¿Qué devuelve `FAILED` o `REPORTED`? ¿Por qué la lógica del propio BO sí podrá escribirlo?

---

**Siguiente:** [3.3. Determinations](./3_3_determinations.md)
