# Desarrollo con SAP ABAP Cloud y RAP

Los contenidos que se presentan a continuación enseñan **ABAP Cloud** y el modelo **RAP** (*ABAP RESTful Application Programming Model*) sobre el trial gratuito de SAP BTP, construyendo paso a paso el **ERP de Obras y Reformas**: la reimplementación en SAP de `gestion_bd`, un módulo de Odoo para gestionar obras y reformas.

> **Estructura por bloques.** El material está organizado en **ocho bloques**. Cada bloque agrupa unidades con teoría, ejemplos y ejercicios, y termina con una unidad de **Proyecto** que integra lo visto. Las horas son orientativas. El plan de esta organización está en [PLAN_proyecto_guiado.md](./PLAN_proyecto_guiado.md).
>
> **Dos proyectos.** La teoría se explica con un proyecto de ejemplo, el **taller RuedaLibre**, con el código completo. Los ejercicios construyen **tu ERP** tomando el taller como modelo: indican qué crear, con qué campos y datos y qué resultado debe salir, pero no dan el código. Los tests de la carpeta [materiales/tests](https://github.com/pdawgabriel-hub/abap-ejercicios/tree/main/docs/materiales/tests) comprueban cada solución. Los dos proyectos se presentan en el Bloque 0.
>
> **Aviso.** El código se ha escrito siguiendo la documentación de SAP, pero **no se ha compilado contra un sistema real**. Si algo da error al activar, copia el mensaje exacto: es parte del aprendizaje. Las unidades menos verificadas lo indican al principio.

**Antes de empezar:** todo el material comparte el mismo entorno (Eclipse con ADT y una cuenta trial de SAP BTP). Prepáralo siguiendo [0.1. Preparación del entorno](./00_instalacionEntorno.md). La cuenta trial dura **90 días** y hay que entrar al menos una vez cada 30: el repositorio es tu copia de seguridad ([5.3](./5_3_ciclo90dias.md)).

| Bloque | Contenido | Horas |
|-------:|-----------|------:|
| 0 | Introducción y entorno: el trial, ABAP Cloud y los dos proyectos | 6 |
| 1 | Fundamentos del lenguaje: las reglas de negocio en ABAP | 24 |
| 2 | Modelo de datos con CDS | 16 |
| 3 | Comportamiento con RAP | 30 |
| 4 | Servicios, apps Fiori y API | 20 |
| 5 | Calidad, Git y ciclo de 90 días | 8 |
| 6 | Ampliaciones del proyecto | 32 |
| 7 | Cierre del proyecto | 6 |

---

## Bloque 0. Introducción y entorno

Antes de escribir una línea de ABAP: el entorno de trabajo, qué es ABAP Cloud y los dos proyectos de estos apuntes, cada uno con su guía técnica y su modelo de datos.

1. [Preparación del entorno](./00_instalacionEntorno.md)
2. [Introducción: ABAP Cloud y SAP BTP](./01_introduccion.md)
3. [Los dos proyectos](./0_3_dosProyectos.md)
4. [Guía técnica del ERP de Obras y Reformas](./0_4_erp.md)
5. [Guía técnica del taller RuedaLibre](./0_5_taller.md)

## Bloque 1. Fundamentos del lenguaje

El lenguaje ABAP, aprendido escribiendo las reglas de negocio del ERP en una clase con tests, `ZCL_GOR_REGLAS`.

1. [Tu primer programa: clases ejecutables](./1_1_classrun.md)
2. [Variables, tipos de datos y plantillas de texto](./1_2_tipos.md)
3. [Control de flujo y funciones de cadena](./1_3_flujo.md)
4. [Tablas internas](./1_4_tablasInternas.md)
5. [Tablas de base de datos y ABAP SQL](./1_5_abapSql.md)
6. [Clases y objetos (ABAP OO)](./1_6_oo.md)
7. [Excepciones](./1_7_excepciones.md)
8. [Pruebas con ABAP Unit](./1_8_abapUnit.md)
9. *Proyecto:* [simulación de una obra](./1_9_proyecto.md)

## Bloque 2. Modelo de datos con CDS

Las tablas de todas las entidades y, encima, el modelo CDS: relaciones y cálculos al leer. El ERP queda cargado con datos de prueba y con la ficha financiera de cada obra calculada por una vista.

1. [Tablas persistentes en ADT](./2_1_tablas.md)
2. [CDS View Entities](./2_2_cds.md)
3. [Associations y composiciones](./2_3_associations.md)
4. [Campos calculados y Data Preview](./2_4_calculados.md)
5. *Proyecto:* [el ERP con datos](./2_5_proyecto.md)

## Bloque 3. Comportamiento con RAP

Crear, modificar, borrar, calcular y validar: el comportamiento de los diez objetos de negocio, hasta ejecutar el escenario de §12.7 del informe como test automático.

1. [Behavior Definition managed](./3_1_behaviorDefinition.md)
2. [La clase de implementación](./3_2_implementacion.md)
3. [Determinations](./3_3_determinations.md)
4. [Validations](./3_4_validations.md)
5. [Actions](./3_5_actions.md)
6. [Composiciones: hijos y tablas satélite](./3_6_composiciones.md)
7. [Numeración](./3_7_numeracion.md)
8. *Proyecto:* [el escenario completo como test](./3_8_proyecto.md)

## Bloque 4. Servicios y apps Fiori

La interfaz y la API: proyecciones, servicios OData, anotaciones de Fiori y el mismo servicio publicado como API para otros sistemas, hasta tener tres apps con las que repetir a mano el escenario.

1. [Proyecciones](./4_1_proyecciones.md)
2. [Service Definition y Service Binding](./4_2_servicio.md)
3. [Metadata Extensions y la interfaz](./4_3_metadataExtensions.md)
4. [Comprobar y depurar](./4_4_depurar.md)
5. [El servicio como API](./4_5_api.md)
6. *Proyecto:* [las tres apps](./4_6_proyecto.md)

## Bloque 5. Calidad, Git y ciclo de 90 días

Que el proyecto dure: control de calidad, GitHub y la restauración en un trial nuevo.

1. [ATC y calidad de código](./5_1_atc.md)
2. [abapGit: tu código en GitHub](./5_2_abapgit.md)
3. [El ciclo de 90 días](./5_3_ciclo90dias.md)
4. *Proyecto:* [ensayo de restauración](./5_4_proyecto.md)

## Bloque 6. Ampliaciones del proyecto

Lo que completaba la aplicación en Odoo: permisos, moneda y menú, documentos, migración de datos, dashboard y calendario; el uso de APIs externas, cómo se extiende un S/4HANA y los eventos de negocio. Son unidades independientes; algunas dependen de lo que permita el trial.

1. [Seguridad: autorizaciones y roles](./6_1_seguridad.md)
2. [Moneda y Fiori Launchpad](./6_2_monedaLaunchpad.md)
3. [Documentos imprimibles](./6_3_documentosPdf.md)
4. [Migración de datos desde Odoo](./6_4_migracion.md)
5. [Dashboard y calendario](./6_5_dashboard.md)
6. [Consumir APIs externas](./6_6_apiExterna.md)
7. [S/4HANA: extender lo estándar](./6_7_s4hana.md)
8. [Business events](./6_8_eventos.md)

## Bloque 7. Cierre del proyecto

Del ERP terminado al portfolio.

1. [Comprobación final](./7_1_comprobacion.md)
2. [El README del portfolio](./7_2_readme.md)
3. [Explicarlo en 5 minutos](./7_3_explicacion.md)

## Anexos

- [A. ABAP clásico: lo mínimo](./A_clasico.md)
- [B. Convenciones de nombres](./B_nombres.md)
- [C. Glosario](./C_glosario.md)
- [D. Planificación y hoja de ruta](./D_planificacion.md)
- [E. Reglas de negocio](./E_reglas.md)
- [F. El mismo flujo en VS Code](./F_vscode.md)
- [Restaurar en un trial nuevo](./RESTAURAR.md)
