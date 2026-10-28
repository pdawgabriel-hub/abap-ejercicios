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

El resultado de los ejercicios vive en su propio repositorio, [erp-obras-reformas-sap](https://github.com/pdawgabriel-hub/erp-obras-reformas-sap). Este contiene los apuntes, los tests y las herramientas de apoyo. También sirve de copia de seguridad del paquete de pruebas `ZEJ`, porque la cuenta de pruebas de SAP caduca cada 90 días.

> El código de los apuntes se ha escrito siguiendo la documentación de SAP, pero todavía no se ha compilado contra un sistema real.
