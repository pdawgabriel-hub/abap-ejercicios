# 6.2. Moneda y Fiori Launchpad

> **Zona menos verificada.** La forma de anotar importes con moneda en vistas con decimales (`abap.dec`) y los pasos para publicar apps en el Launchpad dependen de la versión del sistema y de los servicios disponibles en el trial. Úsala como guía de qué buscar y contrasta con la documentación oficial.

Dos detalles de acabado: que los importes se vean **como dinero** (con su símbolo y su formato) y que las apps tengan un **menú** de entrada, como el menú «Gestión de Obras» de Odoo (§4 del informe).

## Importes con moneda

En las tablas guardamos los importes como `abap.dec(15,2)`, sin moneda: el ERP trabaja siempre en euros (§12.1). Fiori los muestra como números. Para que los muestre como importes, la vista necesita decirle **qué campo es la moneda** de cada importe. En el taller se añade a la proyección un campo de moneda constante y cada importe se anota con él:

```sql
define root view entity ZC_TlPresupuesto
  provider contract transactional_query
  as projection on ZI_TlPresupuesto
{
  ...
      @Semantics.amount.currencyCode: 'Moneda'
      Importe,
      Moneda,
  ...
}
```

`Moneda` tiene que existir en la vista de debajo. La forma más sencilla es añadirla a la vista interface como constante, `cast( 'EUR' as abap.cuky ) as Moneda` (y marcarla como `readonly` en la BDEF, y regenerar la tabla de borradores, que gana una columna).

Según la versión, `@Semantics.amount.currencyCode` exige que el importe sea de tipo `abap.curr`. Si tu sistema da un error en la anotación, hay dos salidas: convertir en la vista (`cast( importe as abap.curr(15,2) )`) o, para el portfolio, dejar los importes como números y poner «(€)» en la etiqueta de las columnas. Elige una y explícala en el README.

## El Launchpad

Cada *binding* OData V4 - UI permite una vista previa (4.2), pero eso no es un menú. En SAP, las apps se agrupan en el **Fiori Launchpad**: una página de inicio con un **mosaico** (*tile*) por app, agrupados por áreas. Es el equivalente a los `menuitem` de Odoo.

El camino habitual en BTP:

1. Generar una app Fiori Elements para el servicio (en *SAP Business Application Studio*, con el asistente de Fiori, eligiendo el servicio y la entidad principal) y desplegarla en el sistema ABAP.
2. Registrar la app en una *IAM App* y en el *Business Catalog* de 6.1.
3. Asignar el catálogo a un rol: el mosaico aparece en el Launchpad de los usuarios con ese rol.

En el trial, el paso 1 necesita una suscripción a *Business Application Studio*, que puede no estar disponible o tener límites. Si no puedes desplegar, la vista previa del *binding* sigue siendo una app completa: para el portfolio basta con capturas y con explicar en el README cómo se publicaría.

## Ejercicios

1. **Euros.** Añade la moneda a los importes de una entidad de tu ERP (el presupuesto) con la opción que funcione en tu sistema. Compruébalo en la vista previa: el total debe salir con el símbolo de euro.
2. **Todos los importes.** Si el ejercicio 1 ha funcionado, extiéndelo al resto de importes: líneas, ingresos, partes y la ficha financiera.
3. **El menú.** Diseña en `diseno.md` el menú del Launchpad del ERP a partir del de Odoo (§4: «Análisis Financiero» y «Consultar datos»): qué mosaicos habría, de qué servicio sale cada uno y en qué grupo va.
4. **Una app desplegada (opcional).** Si tienes acceso a *Business Application Studio*, genera y despliega la app de obras y ábrela desde el Launchpad.
5. **Investiga.** Busca la diferencia entre una app *List Report* y una *Worklist* en Fiori Elements. ¿Cuál encajaría mejor para la lista de cobros pendientes?

---

**Siguiente:** [6.3. Documentos imprimibles](./6_3_documentosPdf.md)
