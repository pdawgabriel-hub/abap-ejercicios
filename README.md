# abap-ejercicios

Apuntes en español para aprender **SAP ABAP Cloud y RAP** construyendo un proyecto real.

- **Apuntes:** https://pdawgabriel-hub.github.io/abap-ejercicios/
- **Proyecto:** https://github.com/pdawgabriel-hub/erp-obras-reformas-sap

## Para qué es este repositorio

Lo escribí para prepararme las prácticas de 2º de DAW (CIFP Carlos III) en una empresa que trabaja con SAP. En vez de hacer ejercicios sueltos, el objetivo es reimplementar en SAP una aplicación que ya funciona: `gestion_bd`, el módulo de Odoo que desarrollé para una empresa de construcción y reformas y que usa en producción.

Los apuntes se organizan como un proyecto guiado, en ocho bloques que van del lenguaje ABAP hasta las apps Fiori, la calidad del código y la publicación en GitHub:

- **La teoría** se explica con un proyecto de ejemplo, un taller mecánico, con el código completo.
- **Los ejercicios** construyen, pieza a pieza, el **ERP de Obras y Reformas**, tomando el taller como modelo pero sin copiar su código.
- **Los tests** de ABAP Unit de cada unidad comprueban si cada pieza del ERP está bien.

El resultado de los ejercicios vive en su propio repositorio, [erp-obras-reformas-sap](https://github.com/pdawgabriel-hub/erp-obras-reformas-sap). Este contiene los apuntes, los tests y las herramientas de apoyo. También sirve de copia de seguridad del paquete de pruebas `ZEJ`, porque el sistema de pruebas de SAP caduca cada 90 días.

> El código de los apuntes se ha escrito siguiendo la documentación de SAP, pero todavía no se ha compilado contra un sistema real.
