# 6.1. Seguridad: autorizaciones y roles

> **Bloque 6 · Ampliaciones.** Tu ERP ya hace todo lo esencial. Este bloque añade lo que en Odoo completaba la aplicación: permisos por grupo, moneda y menú, documentos imprimibles, la carga de datos reales, el dashboard y el calendario. Son unidades más independientes entre sí: puedes hacerlas en el orden que quieras.

> **Zona menos verificada.** Lo que se programa (objetos de autorización, comprobaciones en el comportamiento) es estable. Lo que se configura en las apps de administración (roles, catálogos, asignación a usuarios) cambia con las versiones y, en un trial **compartido**, puede que tu usuario no tenga permiso para hacerlo. Contrasta con la documentación antes de dar nada por cierto.

En Odoo, la seguridad son los **grupos** y el fichero `ir.model.access.csv` (§5 del informe): qué grupo puede leer, crear, modificar o borrar cada modelo. En SAP hay tres piezas:

| Pieza | Qué es | Dónde se crea |
|---|---|---|
| **Objeto de autorización** | Un «permiso» con campos, típicamente la actividad (`ACTVT`: 01 crear, 02 modificar, 03 ver, 06 borrar) | ADT: *Authorization Field* y *Authorization Object* |
| **IAM App** y **Business Catalog** | Qué servicios y qué valores del objeto de autorización van juntos | ADT: *IAM App* y *Business Catalog* |
| **Business Role** | El conjunto de catálogos que se asigna a un usuario: el equivalente a un grupo de Odoo | App de administración *Maintain Business Roles* |

## Comprobar el permiso en el comportamiento

En 3.2 dejaste `get_global_authorizations` permitiendo todo. Ahora consulta el objeto de autorización. En el taller, solo el jefe de taller puede borrar órdenes:

```abap
  METHOD get_global_authorizations.
    " Por defecto, todo permitido; borrar, solo con la actividad 06
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).

    " Solo si en esta llamada se pregunta por borrar
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      " Tiene el usuario la actividad 06 (borrar) del objeto ZTL_TALLER?
      AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '06'.
      IF sy-subrc <> 0.                                " no la tiene
        result-%delete = if_abap_behv=>auth-unauthorized.
        " Mensaje general (%global), no de una orden concreta
        APPEND VALUE #( %msg    = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text     = 'Solo el jefe de taller puede borrar ordenes' )
                        %global = if_abap_behv=>mk-on ) TO reported-orden.
      ENDIF.
    ENDIF.
  ENDMETHOD.
```

- `requested_authorizations` dice qué está pidiendo comprobar el framework en esta llamada.
- `AUTHORITY-CHECK` devuelve `sy-subrc = 0` si el usuario tiene el permiso. En ABAP Cloud solo se puede usar con objetos de autorización **propios** o liberados.
- `%global` en el mensaje: no se refiere a una instancia concreta.

## Permisos que dependen del registro: autorización por instancia

La autorización **global** responde a «¿puede este usuario modificar órdenes?». A veces la respuesta depende de **cuál**: en el taller, una orden con la hoja de costes **cerrada** (cobrada del todo) ya no la modifica cualquiera, solo el jefe de taller. Para eso está la autorización **por instancia**, que se declara junto a la global:

```bdef
define behavior for ZI_TlOrden alias Orden
...
// global: por tipo de operacion; instance: ademas, registro a registro
authorization master ( global, instance )
```

```abap
  METHOD get_instance_authorizations.
    " Hojas cerradas de las ordenes pedidas
    SELECT FROM zi_tlordenresumen FIELDS OrdenUUID
      FOR ALL ENTRIES IN @keys WHERE OrdenUUID = @keys-OrdenUUID AND EstadoHoja = 'cerrada'
      INTO TABLE @DATA(lt_cerradas).

    AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '70'.    " 70 = administrar
    DATA(lv_es_jefe) = xsdbool( sy-subrc = 0 ).     " abap_true si tiene la actividad

    " Para cada orden pedida: bloqueada si esta cerrada y el usuario no es jefe
    result = VALUE #( FOR k IN keys
      LET lv_bloqueada = xsdbool( line_exists( lt_cerradas[ OrdenUUID = k-OrdenUUID ] )
                                  AND lv_es_jefe = abap_false ) IN
      ( %tky         = k-%tky
        %update      = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed )
        %delete      = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed )
        %action-Edit = COND #( WHEN lv_bloqueada = abap_true THEN if_abap_behv=>auth-unauthorized
                                                             ELSE if_abap_behv=>auth-allowed ) ) ).
  ENDMETHOD.
```

- Recibe las claves de las instancias (`keys`) y devuelve, **para cada una**, qué operaciones se permiten.
- Fiori desactiva *Editar* y *Eliminar* en las órdenes bloqueadas; con EML, la operación vuelve como `FAILED`.
- La diferencia con el *feature control* (3.5) es el motivo: el *feature control* dice si una operación **tiene sentido** en ese estado (aprobar un presupuesto ya aprobado), para cualquier usuario; la autorización por instancia dice si **este usuario** puede hacerla.
- `70` es una actividad estándar de SAP («administrar»), que el objeto de autorización del taller incluye entre sus valores.

## Leer solo lo permitido: control de acceso CDS

Con `@AccessControl.authorizationCheck: #CHECK` en una vista y un objeto **Access Control** (DCL), RAP filtra las **filas** que puede ver cada usuario: por ejemplo, que cada mecánico solo vea sus jornadas.

```cds
@EndUserText.label: 'Taller - Jornadas: solo con permiso de lectura'
@MappingRole: true
// Regla de lectura de la vista: que filas puede ver cada usuario
define role ZI_TlJornada {
  grant select on ZI_TlJornada
    // Solo quien tenga la actividad 03 (ver) del objeto del taller
    where () = aspect pfcg_auth( ZTL_TALLER, ACTVT = '03' );
}
```

Las vistas que no lo necesitan siguen con `#NOT_REQUIRED`.

## Los roles del ERP

En `gestion_bd` hay dos grupos con los **mismos** permisos (§5): *Administrativa* y *Jefe / Administrador*. La única regla especial, que la ficha de gastos no se crea ni se borra a mano, ya la garantiza tu BDEF (3.1), para todos los usuarios. Así que en el ERP la seguridad sirve sobre todo para que **solo** esos dos roles puedan entrar.

> **Código completo del taller:** [los permisos de la orden](./materiales/taller/src/bus/zbp_i_tlorden.clas.locals_imp.abap) y [el control de acceso de las jornadas](./materiales/taller/src/cds/zi_tljornada.dcls.asdcls). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

El objeto de autorización va en `ZGOR_BUS`; los cambios de permisos, en tus diez clases de comportamiento. El catálogo y los roles se crean en las apps de administración del trial, si tu usuario tiene acceso.

## Ejercicios

1. **El objeto de autorización.**
    - **Dónde:** clic derecho en `ZGOR_BUS` → **New → Other ABAP Repository Object** → *Authorization Object*. Nombre `ZGOR_ERP`, descripción `ERP de Obras y Reformas`.
    - **Qué contiene:** el campo `ACTVT` con las actividades 01 (crear), 02 (modificar), 03 (ver), 06 (borrar) y 70 (administrar), como `ZTL_TALLER`.
    - **Comprueba:** activa sin errores.
2. **Comprobarlo.**
    - **Dónde:** el método `get_global_authorizations` de las diez clases de comportamiento (el que dejaste permitiéndolo todo en 3.2).
    - **Qué hace:** como el del taller, un `AUTHORITY-CHECK OBJECT 'ZGOR_ERP' ID 'ACTVT' FIELD '01'` cuando se pide `%create`, `'02'` para `%update` y `%action-Edit`, y `'06'` para `%delete`. Si `sy-subrc` no es 0, la operación queda `if_abap_behv=>auth-unauthorized` y se añade un mensaje a `reported`.
    - **Comprueba:** ejecuta `ZCL_GOR_EML_DEMO`. Si tu usuario del trial no tiene el objeto en ningún rol, **todas** las escrituras fallan con tu mensaje: es la prueba de que la comprobación funciona. Para seguir trabajando, completa el ejercicio 3 o, si no puedes, deja temporalmente el `AUTHORITY-CHECK` en un `IF 1 = 0` comentado.
3. **Catálogo y roles.** Crea la *IAM App* de cada uno de tus tres servicios y un *Business Catalog* `ZGOR_BC_ERP` con las tres y con `ZGOR_ERP` en todas las actividades. Si tu trial lo permite, crea los roles `ZGOR_ADMINISTRATIVA` y `ZGOR_JEFE` con ese catálogo y asígnate uno. Si no lo permite, anota hasta dónde has llegado y qué mensaje te ha dado.
4. **Tabla de permisos.** Haz en `diseno.md` la tabla de §5 del informe traducida a SAP: qué rol puede hacer qué en cada BO. Señala qué regla la cumple la BDEF y cuál el objeto de autorización.
5. **Autorización por instancia.** Una regla que no está en el informe: una obra **pagada del todo** (estado de gasto `finalizado`) solo la puede modificar o borrar quien tenga la actividad `70` de `ZGOR_ERP` (el rol de jefe).
    - **Dónde:** BDEF `ZI_GorObra` y clase local `lhc_obra`.
    - **En la BDEF:** `authorization master ( global, instance )`. Con **Ctrl+1**, Eclipse añade `get_instance_authorizations`.
    - **Qué hace:** lee `EstadoGasto` de `ZI_GorObraFinanzas` para cada obra de `keys`; si es `finalizado`, comprueba la actividad `70` y, sin ella, deja `%update` y `%delete` como `unauthorized`.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, modifica la descripción de `OBR0001` (pagada en los datos de demo): sin la actividad 70, `FAILED` trae la obra. Modifica `OBR0003` (no pagada): se guarda. Explica en `diseno.md` por qué es una autorización y no un *feature control*.
6. **Investiga.** ¿Qué ve en las apps un usuario **sin** ningún rol del ERP? Si no puedes probarlo con otro usuario, búscalo en la documentación y anótalo.

---

**Siguiente:** [6.2. Moneda y Fiori Launchpad](./6_2_monedaLaunchpad.md)
