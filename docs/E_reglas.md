# E. Reglas de negocio

Resumen de las reglas de §11 del informe técnico de `gestion_bd` y de **dónde** las implementa tu ERP. Sirve para comprobar, al final, que no se ha quedado ninguna fuera.

## Fórmulas (§11.2)

| Regla | Clase de reglas | Se guarda con | Se calcula al leer en |
|---|---|---|---|
| Total de línea, base, cuota y total del presupuesto | `total_linea`, `base_imponible`, `cuota_iva`, `total_presupuesto` (1.2, 1.4) | *Determinations* del presupuesto (3.3) | — |
| Total de la obra (presupuestos aprobados) | `total_obra` (1.4) | — | `ZI_GorObraTotal` (2.4) |
| Coste de línea de parte y totales del parte | `coste_subtotal`, `horas_parte`, `coste_parte` (1.2, 1.4) | *Determinations* del parte (3.3) | — |
| Horas y coste de mano de obra de la obra | — | — | `ZI_GorObraMoo` (2.4) |
| Gastos, ingresos, beneficio, debe, margen, % cobrado | `kpi_obra` (1.8) | — | `ZI_GorObraFinanzas` (2.4) |
| Estado de pago, salud, estado de la ficha | `estado_pago`, `salud_obra`, `estado_gasto` (1.3) | — | `ZI_GorObraFinanzas` (2.4) |
| Horas y euros del trabajador | — | — | `ZI_GorTrabAcum` (2.4) |
| Días de una falta | `dias_falta` (1.2) | *Determination* de la falta (3.3) | — |
| Total del proveedor | `total_proveedor` (1.2) | *Determination* del proveedor (3.3) | — |
| Participantes de una obra | `participantes` (1.4) | — | `ZI_GorObraTrab`, `ZI_GorObraProv`, `ZI_GorObraEsp` (2.3) |

## Validaciones (§11.4)

| Regla | Clase de reglas (1.7) | *Validation* (3.4) |
|---|---|---|
| IVA entre 0 y 100 | `validar_iva` | Presupuesto |
| Horas entre 0 y 24 | `validar_horas` | Línea de parte |
| Importe > 0 en partes externos | `validar_importe_positivo` | Partes de especialista y de proveedor |
| Coste/hora, base e importe de especialista ≥ 0 | `validar_no_negativo` | Trabajador, proveedor, especialista |
| Fin ≥ inicio | `validar_fechas` | Falta, ficha de gastos |
| Obligatorios | `validar_obligatorio` | Todos |
| Códigos y NIF únicos | — | Códigos: 3.7; NIF: cliente |
| Una sola ficha de gastos por obra | — | Composición `[0..1]` (2.3) y *determination* (3.3) |
| Cliente del presupuesto o del ingreso = el de su obra | — | Presupuesto, ingreso; y la obra al cambiar de cliente |
| No borrar una obra con ingresos | — | *Precheck* (3.5) |

## Decisiones de diseño (§11.5)

| Punto | Dónde |
|---|---|
| 1. El precio de la obra no se escribe | `ZI_GorObraTotal` + acciones `aprobar` y `desaprobar` (2.4, 3.5) |
| 2. Beneficio = caja | `BeneficioReal` en `ZI_GorObraFinanzas`; test del paso 7 (1.8, 3.8) |
| 3. Tarifa congelada | `congelarTarifa` (3.3); test del paso 5 |
| 4. Datos del cliente copiados | `copiarCliente` (3.3) |
| 5. La ficha de gastos nace y muere con la obra | Composición `[0..1]`, `crearGasto`, sin `delete` (2.3, 3.1, 3.3) |
| 6. Participantes deducidos | Vistas de participantes (2.3) |
| 7. `debe` siempre en vivo | `ZI_GorObraFinanzas` (2.4) |
| 8. Códigos legibles | `asignarCodigo` (3.7) |
| 9. Bitácoras con autor y fecha | Campos de administración y `@Semantics` (2.2, 3.6) |
| 10. Buscar por lo que la gente recuerda | `coincide_busqueda` (1.4) y búsqueda de Fiori (4.1, 4.3) |
| 11. Dashboard por fecha real | Vistas de 6.5 |
| 12. Borrar una obra borra lo suyo | Guardado adicional de la obra (3.5, 3.6) |
| 13. Presupuestos e ingresos del cliente de su obra | *Validations* (3.4) y `vincularAObra` (3.5) |
| 14. Borrar no deja restos | Adjuntos en la propia fila; composiciones (3.6) |

## Traducción de conceptos Odoo → SAP

| En Odoo | En SAP (RAP) | Dónde |
|---|---|---|
| `models.Model` | Tabla + vista CDS interface + BDEF | 2.1, 2.2, 3.1 |
| `compute` con `store=True` | *Determination* que guarda | 3.3 |
| `compute` sin `store` | Campo o vista CDS calculada | 2.4 |
| `@api.onchange` | *Determination* `on modify` | 3.3 |
| `@api.constrains`, `_sql_constraints` | *Validation* | 3.4 |
| `create()` con secuencia | *Determination* `on save` | 3.7 |
| `unlink()` sobrescrito | *Precheck* y guardado adicional | 3.5 |
| `ondelete='cascade'` | Composición | 2.3 |
| Botón (`action_*`) | *Action* | 3.5 |
| `TransientModel` (asistente) | *Action* con parámetro | 3.5 |
| Modelo con `_auto = False` | Vista CDS con `union all` | 6.5 |
| Vistas XML | Proyección + metadata extension | 4.1, 4.3 |
| `menuitem` | Fiori Launchpad | 6.2 |
| Grupos e `ir.model.access.csv` | Objeto de autorización, catálogos y roles | 6.1 |
| `TransactionCase` | ABAP Unit con dobles | 1.8, 3.8 |
| `onchange` que devuelve valores al formulario | *Determination* + *side effects* | 3.3 |
| `post_init_hook` (datos de demo) | Clase de consola `ZCL_GOR_DATOS_DEMO` | 2.5 |
| API externa de Odoo (JSON-RPC) o la API REST de §12.5 | Servicio OData con *binding* Web API | 4.5 |

---

**Siguiente:** [F. El mismo flujo en VS Code](./F_vscode.md)
