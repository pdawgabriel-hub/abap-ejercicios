# 7.1. Comprobación final

> **Bloque 7 · Cierre del proyecto.** El ERP está construido. Este último bloque lo convierte en un **portfolio**: comprobar que todo funciona de principio a fin, contarlo bien en el README y saber explicarlo en cinco minutos.

Antes de enseñar el proyecto a nadie, una última pasada con la misma lista que usaría un equipo antes de entregar. Cada punto remite a la unidad donde se hizo.

## La lista

**El código**

- [ ] Todo activo: clic derecho en `ZGOR` → *Activate*, sin errores ([2.1](./2_1_tablas.md) a [4.3](./4_3_metadataExtensions.md)).
- [ ] Todos los tests en verde: clic derecho en `ZGOR` → *Run As → ABAP Unit Test* ([1.8](./1_8_abapUnit.md), [3.8](./3_8_proyecto.md)).
- [ ] ATC sin prioridad 1; las de prioridad 2 corregidas o justificadas en `diseno.md` ([5.1](./5_1_atc.md)).
- [ ] Ningún resto de pruebas: clases de consola que ya no sirven borradas, o explicadas como herramientas.

**El comportamiento**

- [ ] El escenario de §12.7, a mano, en las apps, con sus capturas ([4.6](./4_6_proyecto.md)).
- [ ] `ZCL_GOR_COMPROBAR_CDS` dice «0 errores» con los datos de demo ([2.5](./2_5_proyecto.md)).
- [ ] Las reglas de borrado: obra con cobros, obra sin cobros, cliente con presupuestos ([3.5](./3_5_actions.md)).

**La copia**

- [ ] Último *push* hecho y comprobado en GitHub ([5.2](./5_2_abapgit.md)).
- [ ] Restauración ensayada en un trial nuevo, con el tiempo que tarda apuntado ([5.4](./5_4_proyecto.md)).

**Lo opcional (Bloque 6)**

- [ ] Para cada unidad del Bloque 6, o hecha, o explicado en el README por qué no (por ejemplo, el servicio de formularios no está en el trial).

## Ejercicios

1. **Pasa la lista.** Marca cada punto. Lo que no puedas marcar, arréglalo o anótalo como pendiente en el README.
2. **Cuenta.** Apunta, para el README: número de tablas, vistas, BO, tests y líneas de la clase de reglas. Sale en el *Project Explorer* y en la vista de resultados de ABAP Unit.
3. **Una prueba en frío.** Pide a alguien que no conozca el proyecto que siga el anexo de restauración con tu repositorio. Lo que le cueste es lo que falta por explicar.

---

**Siguiente:** [7.2. El README del portfolio](./7_2_readme.md)
