# C. Glosario

| Término | Significado |
|---|---|
| **ABAP Cloud** | Modelo de desarrollo de ABAP que solo permite objetos liberados por SAP |
| **abapGit** | Cliente de Git para ABAP: serializa los objetos en ficheros y los sincroniza con un repositorio (5.2) |
| **Action** | Operación de negocio con nombre propio, más allá de crear, modificar y borrar; en Fiori, un botón (3.5) |
| **ADT** | *ABAP Development Tools*: el plugin de Eclipse para desarrollar ABAP |
| **Association** | Relación declarada entre dos vistas CDS, que se navega solo cuando se usa (2.3) |
| **API** | Interfaz para que un programa use a otro. En RAP, un servicio OData es una API REST (4.5) |
| **ATC** | *ABAP Test Cockpit*: análisis estático de calidad (5.1) |
| **BDEF** | *Behavior Definition*: declara el comportamiento de un objeto de negocio (3.1) |
| **Business event** | Aviso que lanza un objeto de negocio («se ha registrado un ingreso») para que otros reaccionen sin acoplarse a él (6.8) |
| **Business Partner** | El objeto de S/4HANA para clientes, proveedores y demás personas u organizaciones, con roles (6.7) |
| **BO** | *Business Object*: objeto de negocio RAP, una raíz con sus hijos |
| **BTP** | *Business Technology Platform*: la plataforma en la nube de SAP |
| **Business Catalog / Role** | Agrupación de permisos y apps, y conjunto de catálogos que se asigna a un usuario (6.1) |
| **CDS** | *Core Data Services*: el lenguaje de las vistas y del modelo de datos (2.2) |
| **Clean Core** | No modificar el núcleo de SAP; extender solo con APIs liberadas (6.7) |
| **Extensibilidad** | Formas de ampliar S/4HANA sin modificarlo: *key user*, de desarrollador y *side-by-side* (6.7) |
| **Communication Arrangement** | Configuración que da acceso a un servicio desde fuera (*inbound*) o a un servicio externo (*outbound*), con su usuario o destino (4.5, 6.6) |
| **Composition** | Relación padre-hijo en la que el hijo no existe sin el padre (2.3) |
| **CSRF (token)** | Protección de las peticiones que escriben: se pide un token con un `GET` y se envía en cada `POST`, `PATCH` o `DELETE` (4.5) |
| **Determination** | Lógica que rellena o recalcula campos al crear, modificar o guardar (3.3) |
| **Draft** | Borrador: los cambios en edición van a una tabla aparte hasta que se guardan (3.1) |
| **EML** | *Entity Manipulation Language*: sentencias ABAP para leer y modificar BO (3.2) |
| **Feature control** | Decidir por código si una operación o acción está disponible para una instancia (3.5) |
| **Fiori Elements** | Apps generadas a partir de las anotaciones del servicio, sin programar la interfaz (4.3) |
| **Managed** | Modo de RAP en el que el framework lee y escribe las tablas; el programador añade solo la lógica |
| **Metadata extension** | Fichero con las anotaciones de interfaz de una proyección (4.3) |
| **OData** | Protocolo REST de los servicios de SAP; la versión 4 es la de las apps nuevas |
| **Proyección** | Capa de vistas (`ZC_`) que adapta el modelo a una app concreta (4.1) |
| **RAP** | *ABAP RESTful Application Programming Model* |
| **S/4HANA** | El ERP de SAP: ventas, compras, finanzas, producción… (6.7) |
| **Service Binding / Definition** | Qué entidades forman un servicio y con qué protocolo se publica (4.2) |
| ***Side effects*** | Declaración en la BDEF de qué campos debe volver a leer Fiori cuando cambia otro o se ejecuta una acción (3.3) |
| **Tabla interna** | Lista en memoria de filas del mismo tipo (1.4) |
| **Orden de transporte** | Paquete de cambios que viaja de desarrollo a calidad y a producción (5.2) |
| **Test double** | Sustituto de una tabla o vista durante un test (3.8) |
| **Trial** | Cuenta gratuita de SAP BTP, de 90 días (5.3) |
| **Web API** | Tipo de *binding* para publicar un servicio a otros sistemas, sin anotaciones de Fiori ni *draft* (4.5) |
| **Validation** | Comprobación al guardar que impide guardar datos incorrectos (3.4) |

---

**Siguiente:** [D. Planificación y hoja de ruta](./D_planificacion.md)
