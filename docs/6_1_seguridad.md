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

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '06'.
      IF sy-subrc <> 0.
        result-%delete = if_abap_behv=>auth-unauthorized.
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

```sql
define behavior for ZI_TlOrden alias Orden
...
authorization master ( global, instance )
```

```abap
  METHOD get_instance_authorizations.
    " Hojas cerradas de las ordenes pedidas
    SELECT FROM zi_tlordenresumen FIELDS OrdenUUID
      FOR ALL ENTRIES IN @keys WHERE OrdenUUID = @keys-OrdenUUID AND EstadoHoja = 'cerrada'
      INTO TABLE @DATA(lt_cerradas).

    AUTHORITY-CHECK OBJECT 'ZTL_TALLER' ID 'ACTVT' FIELD '70'.    " 70 = administrar
    DATA(lv_es_jefe) = xsdbool( sy-subrc = 0 ).

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

```sql
@EndUserText.label: 'Taller - Jornadas: solo con permiso de lectura'
@MappingRole: true
define role ZI_TlJornada {
  grant select on ZI_TlJornada
    where () = aspect pfcg_auth( ZTL_TALLER, ACTVT = '03' );
}
```

Las vistas que no lo necesitan siguen con `#NOT_REQUIRED`.

## Los roles del ERP

En `gestion_bd` hay dos grupos con los **mismos** permisos (§5): *Administrativa* y *Jefe / Administrador*. La única regla especial, que la ficha de gastos no se crea ni se borra a mano, ya la garantiza tu BDEF (3.1), para todos los usuarios. Así que en el ERP la seguridad sirve sobre todo para que **solo** esos dos roles puedan entrar.

## Ejercicios

1. **El objeto de autorización.** Crea en `ZGOR_BUS` el objeto `ZGOR_ERP` con el campo `ACTVT` (actividades 01, 02, 03, 06 y 70).
2. **Comprobarlo.** En las diez clases de comportamiento, haz que `get_global_authorizations` compruebe `ZGOR_ERP` con la actividad que corresponda a cada operación (crear, modificar, borrar). Sin permiso, la operación queda `unauthorized` con un mensaje claro.
3. **Catálogo y roles.** Crea la *IAM App* de cada uno de tus tres servicios y un *Business Catalog* `ZGOR_BC_ERP` con las tres y con `ZGOR_ERP` en todas las actividades. Si tu trial lo permite, crea los roles `ZGOR_ADMINISTRATIVA` y `ZGOR_JEFE` con ese catálogo y asígnate uno. Si no lo permite, anota hasta dónde has llegado y qué mensaje te ha dado.
4. **Tabla de permisos.** Haz en `diseno.md` la tabla de §5 del informe traducida a SAP: qué rol puede hacer qué en cada BO. Señala qué regla la cumple la BDEF y cuál el objeto de autorización.
5. **Autorización por instancia.** Una regla que no está en el informe y que puedes añadir: una obra **pagada del todo** (estado de gasto `finalizado`) solo la puede modificar o borrar quien tenga la actividad `70` de `ZGOR_ERP` (el rol de jefe). Declara `authorization master ( global, instance )` en la obra, implementa `get_instance_authorizations` leyendo `ZI_GorObraFinanzas` y comprueba con EML que, sin esa actividad, modificar `OBR0001` (pagada en los datos de demo) devuelve `FAILED`. Explica en `diseno.md` por qué es una autorización y no un *feature control*.
6. **Investiga.** ¿Qué ve en las apps un usuario **sin** ningún rol del ERP? Si no puedes probarlo con otro usuario, búscalo en la documentación y anótalo.

---

**Siguiente:** [6.2. Moneda y Fiori Launchpad](./6_2_monedaLaunchpad.md)
