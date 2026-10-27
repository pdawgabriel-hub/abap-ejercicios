---
title: "1.5. Tablas de base de datos y ABAP SQL"
parent: "1. Fundamentos del lenguaje"
nav_order: 5
---

# 1.5. Tablas de base de datos y ABAP SQL

{% raw %}
> **Cómo ejecutar los ejemplos.** Los ejemplos muestran solo el **contenido del método `main`** de una clase ejecutable. Pégalos dentro de la plantilla de [1.1](1_1_classrun.html) (cambiando el nombre de la clase), activa con **Ctrl+F3** y ejecuta con **F9**.

Las tablas persistentes se crean en Eclipse como **Database Table** (código en el editor de ADT; no hay SE11). Para leer y escribir usas **ABAP SQL**: un SQL con sintaxis ABAP donde las variables de ABAP llevan `@`. Recuerda que en ABAP Cloud solo puedes acceder a **tus propias tablas** y a objetos liberados.

## Las dos tablas del ejemplo

Crea dos objetos **Database Table** (clic derecho en el paquete → *New → Other ABAP Repository Object → Database Table*), pega el contenido y actívalos.

```sql
@EndUserText.label : 'Taller - Propietarios'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_propietario {
  key client  : abap.clnt not null;
  key id_prop : abap.numc(6) not null;
  nombre      : abap.char(60);
  telefono    : abap.char(15);
}
```

```sql
@EndUserText.label : 'Taller - Vehiculos'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table ztl_vehiculo {
  key client    : abap.clnt not null;
  key matricula : abap.char(10) not null;
  id_prop       : abap.numc(6);
  marca         : abap.char(30);
  modelo        : abap.char(30);
  anio          : abap.numc(4);
}
```

## Insertar, leer, agrupar, unir, actualizar y borrar

```abap
    DELETE FROM ztl_vehiculo.
    DELETE FROM ztl_propietario.

    DATA lt_prop TYPE STANDARD TABLE OF ztl_propietario WITH EMPTY KEY.
    lt_prop = VALUE #( ( id_prop = '000001' nombre = 'Ana Ruiz'  telefono = '600111222' )
                       ( id_prop = '000002' nombre = 'Luis Mena' telefono = '600333444' ) ).
    INSERT ztl_propietario FROM TABLE @lt_prop.

    DATA lt_veh TYPE STANDARD TABLE OF ztl_vehiculo WITH EMPTY KEY.
    lt_veh = VALUE #(
      ( matricula = '1234ABC' id_prop = '000001'
        marca = 'Seat' modelo = 'Ibiza' anio = '2015' )
      ( matricula = '5678DEF' id_prop = '000001'
        marca = 'Ford' modelo = 'Focus' anio = '2019' )
      ( matricula = '9012GHI' id_prop = '000002'
        marca = 'Seat' modelo = 'Leon' anio = '2021' ) ).
    INSERT ztl_vehiculo FROM TABLE @lt_veh.

    SELECT FROM ztl_vehiculo
      FIELDS matricula, marca, anio
      WHERE anio >= '2018'
      ORDER BY anio
      INTO TABLE @DATA(lt_recientes).
    out->write( lt_recientes ).

    SELECT FROM ztl_vehiculo
      FIELDS marca, COUNT( * ) AS total
      GROUP BY marca
      INTO TABLE @DATA(lt_marcas).
    out->write( lt_marcas ).

    SELECT FROM ztl_vehiculo AS v
      INNER JOIN ztl_propietario AS p ON v~id_prop = p~id_prop
      FIELDS v~matricula, v~marca, p~nombre
      INTO TABLE @DATA(lt_con_dueno).
    out->write( lt_con_dueno ).

    UPDATE ztl_vehiculo SET marca = 'SEAT' WHERE matricula = '1234ABC'.
    out->write( |Filas modificadas: { sy-dbcnt }| ).

    DELETE FROM ztl_vehiculo WHERE matricula = '9012GHI'.
    out->write( |Filas borradas: { sy-dbcnt }| ).
```

> **Cuidado con el `DELETE` sin `WHERE`.** Vacía la tabla entera. Úsalo solo en tablas de pruebas como estas y no lo dejes en ningún programa que toque datos reales.

> **Espacios en los paréntesis.** En ABAP SQL, `COUNT( * )` lleva espacios tras abrir y antes de cerrar el paréntesis. Lo mismo vale para `VALUE #( ... )` y las llamadas a métodos.

## Ejercicios

1. **Clientes.** Crea la tabla de Clientes de tu proyecto (diseño de [1.9](1_9_proyecto.html)), cárgala con 5 clientes de prueba y recupéralos ordenados por nombre.
2. **Join.** Haz una consulta con `JOIN` entre Obras y Clientes (créalas primero) que muestre el nombre del cliente de cada obra.
3. **Agrupar.** Escribe una consulta con `GROUP BY` que cuente cuántas obras tiene cada cliente.


---

**Siguiente:** [1.6. Clases y objetos (ABAP OO)](1_6_oo.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/1_5_abapSql.md){: .fs-2 }
{% endraw %}
