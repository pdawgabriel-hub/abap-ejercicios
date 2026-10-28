---
title: "5.4. Proyecto: ensayo de restauración"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 4
---

# 5.4. Proyecto: ensayo de restauración

{% raw %}
Cerramos el Bloque 5 comprobando lo que todo el bloque promete: que tu ERP se puede **reconstruir desde GitHub**. Un repositorio del que nunca se ha restaurado nada no es una copia de seguridad, es una esperanza. Mejor descubrir ahora, con tiempo, que falta algo, que el día 90.

| Apartado | Qué aporta al proyecto |
|---|---|
| 5.1 ATC | Lo que se sube está limpio |
| 5.2 abapGit | El código en GitHub y el *pull* |
| 5.3 Ciclo de 90 días | Lo que no está en GitHub y cómo se recupera |
| 2.5 Datos de demo | Los datos se recrean con una clase |
| 3.8 Escenario | La prueba de que lo restaurado funciona igual |

## El diseño

Lo ideal es restaurar en un **trial nuevo**. Si todavía no quieres gastar el actual, hay un ensayo parcial que no pone en riesgo nada: restaurar en un **paquete nuevo** del mismo sistema no es posible con los mismos nombres (los objetos ya existen), pero sí puedes comprobar que el repositorio está completo y que el proceso funciona:

1. **Comprobación del repositorio:** clona `erp-obras-reformas-sap` en tu equipo y revisa que en `src/` está **todo** lo de la lista de abajo.
2. **Restauración real:** cuando abras el segundo trial, sigue el anexo [Restaurar](RESTAURAR.html) y mide cuánto tardas.

Lista de lo que debe estar en `src/`:

- [ ] Las 37 tablas y sus tablas de borradores, y las dos estructuras.
- [ ] Todas las vistas `ZI_Gor*`, las de cálculo y participantes, y `ZA_GorVincularObra`.
- [ ] Las 10 BDEF y sus 10 clases de comportamiento.
- [ ] `ZIF_GOR_TIPOS`, `ZCL_GOR_REGLAS` (con sus tests), `ZCX_GOR_REGLA` y las clases de 1.6.
- [ ] Las proyecciones `ZC_Gor*`, sus BDEF y metadata extensions, y los 3 servicios con sus *bindings*.
- [ ] `ZCL_GOR_DATOS_DEMO`, `ZCL_GOR_COMPROBAR_CDS` y `ZCL_GOR_ESCENARIO`.

## Ejercicios

1. **ATC y tests.** Pasa el ATC a `ZGOR` (sin prioridad 1, y las de prioridad 2 justificadas) y ejecuta todos los tests: en verde.
2. **Push final.** Sube todo con el mensaje «Bloques 1 a 5 completos».
3. **Comprueba el repositorio.** Clona el repositorio en tu equipo y repasa la lista de arriba. Si falta algo, súbelo.
4. **Restaura.** En un trial nuevo (o, si aún no lo tienes, cuando lo abras), sigue el anexo de restauración: *pull*, activar, `ZCL_GOR_DATOS_DEMO`, `ZCL_GOR_COMPROBAR_CDS` (0 errores) y los tests de `ZGOR` (todos en verde). Publica los tres *bindings* y abre una app.
5. **Mide.** Apunta cuánto has tardado y qué pasos han fallado o no estaban escritos. Corrige el anexo de restauración con lo que hayas aprendido.

## Comprueba tu solución

Tras la restauración: `ZCL_GOR_COMPROBAR_CDS` dice «0 errores», todos los tests en verde y las tres apps abren. Si lo consigues, el sistema SAP ya es desechable.

---

**Siguiente:** [6. Ampliaciones del proyecto](bloque_B6.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_4_proyecto.md){: .fs-2 }
{% endraw %}
