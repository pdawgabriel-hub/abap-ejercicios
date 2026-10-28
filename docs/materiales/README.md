# Materiales

Todo lo que acompaña a las unidades y no es teoría.

| Carpeta | Qué contiene | Cómo se usa |
|---|---|---|
| [taller/](./taller/README.md) | El **proyecto de ejemplo** completo (taller RuedaLibre): todas sus tablas, vistas, comportamientos, servicios y clases, en formato abapGit y comprobados automáticamente | Consúltalo mientras haces los ejercicios: cada unidad enlaza sus objetos. Opcionalmente, se puede importar en el sistema |
| [tests/](./tests/) | Los **tests del ERP**, uno o varios por unidad | Al final de cada unidad, pega el fichero en la pestaña *Test Classes* que indique la unidad y ejecútalo con **Ctrl+Shift+F10** |

## Los tests del ERP

| Unidad | Fichero | Dónde se pega |
|---|---|---|
| 1.2 | [1_2_ltcl_presupuesto.abap](./tests/1_2_ltcl_presupuesto.abap) | *Test Classes* de `ZCL_GOR_REGLAS` |
| 1.3 | [1_3_ltcl_estados.abap](./tests/1_3_ltcl_estados.abap) | Igual, debajo de las anteriores |
| 1.4 | [1_4_ltcl_sumas.abap](./tests/1_4_ltcl_sumas.abap) | Igual |
| 1.6 | [1_6_ltcl_presupuesto_obj.abap](./tests/1_6_ltcl_presupuesto_obj.abap), [1_6_ltcl_parte.abap](./tests/1_6_ltcl_parte.abap) | *Test Classes* de `ZCL_GOR_PRESUPUESTO` y de `ZCL_GOR_PARTE_TRABAJO` |
| 1.7 | [1_7_ltcl_validaciones.abap](./tests/1_7_ltcl_validaciones.abap), [1_7_ltcl_parte_horas.abap](./tests/1_7_ltcl_parte_horas.abap) | `ZCL_GOR_REGLAS` y `ZCL_GOR_PARTE_TRABAJO` |
| 1.8 | [1_8_ltcl_escenario.abap](./tests/1_8_ltcl_escenario.abap) | `ZCL_GOR_REGLAS` |
| 2.5 | [2_5_comprobar_cds.abap](./tests/2_5_comprobar_cds.abap) | Es una clase de consola entera: `ZCL_GOR_COMPROBAR_CDS` |
| 3.3 | [3_3_ltcl_determinations.abap](./tests/3_3_ltcl_determinations.abap) | *Test Classes* de `zbp_i_gorpresupuesto` |
| 3.4 | [3_4_ltcl_validations.abap](./tests/3_4_ltcl_validations.abap) | Igual |
| 3.5 | [3_5_ltcl_actions.abap](./tests/3_5_ltcl_actions.abap), [3_5_ltcl_borrar_obra.abap](./tests/3_5_ltcl_borrar_obra.abap) | `zbp_i_gorpresupuesto` y `zbp_i_gorobra` |
| 3.7 | [3_7_ltcl_codigos.abap](./tests/3_7_ltcl_codigos.abap) | `ZCL_GOR_REGLAS` |
| 3.8 | [3_8_escenario_12_7.abap](./tests/3_8_escenario_12_7.abap) | Para comparar con tus tests de `ZCL_GOR_ESCENARIO` |

La unidad de cada test explica qué resultado debe dar («N tests en verde»). Si falla uno, lee el mensaje: dice qué valor esperaba y cuál ha salido.
