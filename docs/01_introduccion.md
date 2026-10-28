---
title: "0.2. Introducción: ABAP Cloud y SAP BTP"
parent: "0. Introducción y entorno"
nav_order: 2
---

# 0.2. Introducción: ABAP Cloud y SAP BTP

{% raw %}
En esta unidad entiendes **dónde** vas a trabajar y **por qué** ABAP Cloud tiene las reglas que tiene. No hay código: es el mapa del terreno.

## ABAP Cloud y Clean Core

ABAP Cloud no es otro lenguaje: es el mismo ABAP con **reglas más estrictas** y un modelo de programación obligatorio (CDS para los datos, RAP para la lógica transaccional). SAP lo introdujo por el *Clean Core*: en un sistema gestionado por SAP en la nube no puedes modificar objetos estándar ni tocar estructuras internas, porque eso rompería las actualizaciones automáticas. Solo se pueden usar **APIs liberadas** (*released APIs*).

| Tema | ABAP clásico | ABAP Cloud |
|---|---|---|
| Acceso a datos | `SELECT` sobre cualquier tabla estándar | Solo sobre tus tablas y objetos liberados (normalmente CDS) |
| Interfaz de usuario | Dynpros, Web Dynpro, ALV | Fiori Elements generado a partir de metadatos |
| Programa de prueba | `REPORT` + `WRITE` | Clase con `IF_OO_ADT_CLASSRUN` |
| Modularizar | `FORM`/`PERFORM`, módulos de función | Clases y métodos |
| Crear tablas | SE11 (SAP GUI) | Código en Eclipse (*Database Table*) |
| Herramienta | SAP GUI (SE80, SE24…) | Eclipse con ADT |

> **En un proyecto de empresa.** Si el cliente usa S/4HANA Cloud, el código nuevo será ABAP Cloud. Si es on-premise, puede seguir en clásico o adoptar RAP. Aprender RAP cubre ambos casos y el lenguaje (tablas internas, SQL, clases) es el mismo. Lo que verás en clásico está resumido en el [Anexo A](A_clasico.html).

## Cómo está organizado SAP BTP

SAP BTP (*Business Technology Platform*) es la plataforma cloud de SAP. Tu acceso se organiza en contenedores anidados, distintos del *mandante* del ABAP clásico (que es una partición dentro de un sistema ya instalado):

1. **Global account**: tu cuenta raíz en BTP (la que registraste).
2. **Subaccount**: unidad dentro de una región (por ejemplo `eu10`) donde activas servicios.
3. **Espacio**: necesario en el trial para crear servicios.
4. **Instancia de ABAP Environment**: tu sistema ABAP Cloud, con su propia URL.

En el trial, SAP crea la cuenta global, la subaccount y el espacio la primera vez que entras, y la instancia ABAP se crea con un *booster* (un asistente automático).

## Qué hay debajo (y no administras)

Hay un servidor de aplicaciones ABAP real sobre una base de datos SAP HANA Cloud. No tienes acceso al sistema operativo, al kernel ni a la base de datos directamente. Aun así, las reglas de rendimiento que ya conoces siguen valiendo: no hagas `SELECT` dentro de bucles y pide solo los campos que necesitas.

## Tus herramientas

| Herramienta | Para qué la usas |
|---|---|
| Eclipse + ABAP Development Tools (ADT) | Escribir todo el código: tablas, CDS, comportamiento, clases |
| Cockpit de BTP (navegador) | Crear la cuenta y la instancia, ver su estado, copiar la URL, gestionar usuarios y roles |
| Preview de Fiori Elements | Probar tu app desde el editor del Service Binding |
| Fiori Launchpad | El menú de aplicaciones |
| abapGit | Sincronizar un paquete con GitHub |

## Ciclo de vida de una petición RAP

Cuando el usuario pulsa «Guardar» en tu app Fiori, la petición recorre estas capas:

```text
Fiori Elements  ->  Service Binding  ->  Runtime RAP            ->  CDS + tabla
(UI generada)       (OData -> RAP)       (determinations,           (HANA Cloud)
                                          validations, actions)
```

> **Puente a lo que ya conoces.** Es el recorrido petición HTTP → router → controlador → base de datos de cualquier aplicación web. La diferencia es que aquí el framework hace casi toda la fontanería (OData, tipos, concurrencia): tú escribes CDS, comportamiento y lógica.

## Paquetes, Software Components y transportes

- **Paquete**: carpeta lógica de objetos (empieza por `Z` o `Y` en desarrollo propio).
- **Software Component**: contenedor de más alto nivel. En el trial hay uno ya preparado.
- **Transportes**: los cambios se agrupan en una orden de transporte (la eliges al crear objetos). En el trial solo tienes un sistema, así que solo verás ese gesto.

## Autorizaciones en cloud

Los permisos se organizan por aplicación: un *Business Catalog* agrupa apps Fiori, se asigna a un *Business Role* y el rol al usuario. Lo verás en [6.1](6_1_seguridad.html).

## Draft handling

Cuando un usuario rellena un formulario Fiori sin pulsar «Guardar», RAP puede guardar un **borrador** en una tabla de sombra, separado del registro activo. Se activa con `with draft;` en la Behavior Definition y exige una tabla de borrador y alguna acción más.

> **En estos apuntes, todo con draft.** Es lo que espera el usuario de una app Fiori (editar, guardar o descartar, como en un formulario de Odoo) y lo que vas a ver en los proyectos RAP de empresa. Tiene algunas piezas más, que se explican en [3.1](3_1_behaviorDefinition.html).

## Ejercicios

1. **Clean Core.** Explica con tus palabras qué es y por qué una tabla estándar no se puede modificar en la nube.
2. **De Odoo a RAP.** De las restricciones de la tabla comparativa, ¿cuál crees que más te va a costar viniendo de Odoo? Justifícalo.
3. **Mapa mental.** Dibuja (a mano o en texto) el recorrido de una petición desde el navegador hasta la tabla, nombrando cada capa.


---

**Siguiente:** [0.3. Los dos proyectos](0_3_dosProyectos.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/01_introduccion.md){: .fs-2 }
{% endraw %}
