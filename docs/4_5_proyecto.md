# 4.5. Proyecto: las tres apps

Cerramos el Bloque 4 usando el ERP **como lo usaría la oficina de una empresa de reformas**: sin EML ni Data Preview, solo con las tres apps. Repetirás a mano el escenario de §12.7 del informe, de la creación de la obra al último cobro, y guardarás capturas de cada paso para el README del portfolio.

| Apartado | Qué aporta al proyecto |
|---|---|
| 4.1 Proyecciones | Qué ve y qué puede hacer cada app |
| 4.2 Servicios | Las tres apps: comercial, financiera y de recursos |
| 4.3 Anotaciones | Listas, filtros, pestañas, tarjetas KPI, semáforo y botones |
| 4.4 Depurar | Cómo localizar lo que falle durante el recorrido |
| Bloque 3 | Todo lo que pasa al guardar: cálculos, validaciones, códigos |

## El diseño

El recorrido sigue la tabla de §12.7. Antes de empezar, ejecuta `ZCL_GOR_DATOS_DEMO` (2.5) para tener clientes y trabajadores, y apunta en cada paso **qué esperas ver** antes de mirar: si no coincide, es un error (tuyo o de la app).

| Paso | App | Qué haces | Qué debes ver |
|---|---|---|---|
| 1 | Comercial → Obras | Crear una obra para un cliente nuevo | Al guardar, tiene código `OBR…` y su ficha de gastos `GAS…` en la pestaña de seguimiento. Total 0, `pendiente` |
| 2 | Comercial → Presupuestos | Presupuesto con una línea de 10 × 100 € para esa obra | Al elegir la obra se pone su cliente y se copian sus datos. Base 1000, cuota 210, total 1210. La obra sigue en 0 |
| 3 | Presupuestos | Botón *Aprobar* | Estado `aprobado`; *Aprobar* se desactiva. La obra vale 1210 |
| 4 | Recursos → Partes de trabajo | Parte con 8 h de dos trabajadores de 20 €/h | El coste/h se rellena solo al elegir el trabajador. Subtotales de 160; la obra suma 320 de mano de obra |
| 5 | Recursos → Trabajadores | Subir la tarifa de uno a 25 €/h | El parte del paso 4 no cambia |
| 6 | Recursos → Partes de proveedor y de especialista | 200 € y 150 € | Gastos de la obra: 670 |
| 7 | Financiero → Ingresos | Cobro de 500 € | Ficha: beneficio −170, pendiente 710, margen 540, 41.3 %, `parcial`, semáforo **rojo** |
| 8 | Ingresos | Cobro de 710 € | Beneficio 540, pendiente 0, 100 %, `pagado`, semáforo **verde**, ficha `finalizado` |
| 9 | Varias | Línea de 25 h, parte externo de 0 €, IVA 150, falta con fin anterior al inicio | Cada uno, un mensaje en rojo en su casilla; no se guarda |
| 10 | Comercial → Clientes | Buscar «Juan Pérez» | Sale aunque nombre y apellidos estén en columnas distintas |
| 11 | Obras | Intentar borrar la obra | El botón *Eliminar* está desactivado |
| 12 | Obras → pestaña de seguimiento | Intentar borrar la ficha de gastos | No hay botón para hacerlo |
| 13 | Presupuestos | Presupuesto de otro cliente para la obra | Mensaje de error; no se guarda |

## Preparación del entorno de trabajo

Las tres apps de 4.2 publicadas y con sus anotaciones de 4.3. En el repositorio `erp-obras-reformas-sap`, una carpeta `docs/capturas/` para las imágenes.

## Ejercicios

1. **El recorrido.** Haz los 13 pasos de la tabla, en orden, solo desde las apps. En cada paso, comprueba lo que debes ver y haz una captura de pantalla (`docs/capturas/paso_01.png`, etc.).
2. **Lo que falle.** Si algún paso no da lo esperado, localiza la capa con la tabla de 4.4, escribe un test que lo reproduzca (en `ZCL_GOR_ESCENARIO` o en la clase de comportamiento que toque), corrígelo y repite el paso.
3. **Repite el 11b.** Crea otra obra con un presupuesto aprobado y un parte de trabajo, **sin cobros**, y bórrala desde la app. El presupuesto debe quedar sin obra y el parte, desaparecer.
4. **La experiencia de uso.** Anota en `diseno.md` tres cosas que en Odoo eran más cómodas y tres que en Fiori lo son más. Te servirán para la explicación en 5 minutos del Bloque 7.
5. **Investiga.** Abre la app de presupuestos en dos navegadores (o en una ventana privada) con tu usuario y edita el mismo presupuesto en los dos. ¿Qué pasa en el segundo? Relaciónalo con el bloqueo de los borradores de 3.1.

## Comprueba tu solución

- Los 13 pasos dan lo esperado y tienes sus capturas.
- Clic derecho en `ZGOR` → **Run As → ABAP Unit Test**: todos en verde.
- Haz *push* con abapGit de lo que tengas (o espera a [5.2](./5_2_abapgit.md)).

---

**Siguiente:** [5.1. ATC y calidad de código](./5_1_atc.md)
