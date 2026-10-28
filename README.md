# abap-ejercicios

Apuntes en español para aprender **SAP ABAP Cloud y RAP** construyendo un proyecto real.

- **Apuntes:** https://pdawgabriel-hub.github.io/abap-ejercicios/
- **Proyecto:** https://github.com/pdawgabriel-hub/erp-obras-reformas-sap

## Para qué es este repositorio

Es un curso práctico de ABAP Cloud y RAP. En vez de ejercicios sueltos, propone reimplementar en SAP una aplicación completa: `gestion_bd`, un módulo de Odoo para gestionar obras y reformas (clientes, presupuestos, obras, mano de obra, costes externos y cobros).

Los apuntes se organizan como un proyecto guiado, en ocho bloques que van del lenguaje ABAP hasta las apps Fiori, la calidad del código y la publicación en GitHub:

- **La teoría** se explica con un proyecto de ejemplo, un taller mecánico, con el código completo.
- **Los ejercicios** construyen, pieza a pieza, el **ERP de Obras y Reformas**, tomando el taller como modelo pero sin copiar su código.
- **Los tests** de ABAP Unit de cada unidad comprueban si cada pieza del ERP está bien.

## El proyecto

El ERP gestiona clientes, presupuestos con líneas e IVA, obras, partes de trabajo con las horas de los trabajadores, partes de proveedores y especialistas, cobros y la ficha financiera de cada obra (beneficio real, pendiente de cobro y su «salud»). La base de datos que lo soporta sigue este esquema:

![Esquema de la base de datos del ERP de Obras y Reformas](./docs/images/erp_modelo.svg)

La teoría usa como ejemplo un taller mecánico, con su propio modelo:

![Esquema de la base de datos del taller RuedaLibre](./docs/images/taller_modelo.svg)

## Contenidos

- [Índice de los apuntes](./docs/README.md)
- [Guía técnica del ERP](./docs/0_4_erp.md) y [guía técnica del taller](./docs/0_5_taller.md)
- [Materiales](./docs/materiales/README.md): el [código completo del taller](./docs/materiales/taller/README.md), en formato abapGit, y los tests del ERP

El resultado de los ejercicios vive en su propio repositorio, [erp-obras-reformas-sap](https://github.com/pdawgabriel-hub/erp-obras-reformas-sap). Este contiene los apuntes, el código completo del taller, los tests y las herramientas de apoyo. Es además un repositorio de abapGit: con un *pull* sobre un paquete `ZTL` se importa el taller entero en un sistema.

En cada *push*, [GitHub Actions](./.github/workflows/comprobar-taller.yml) comprueba el código del taller con [abaplint](https://abaplint.org) y con [herramientas/comprobar_rap.py](./herramientas/comprobar_rap.py).

> El código pasa las comprobaciones automáticas, pero todavía no se ha activado en un sistema real.
