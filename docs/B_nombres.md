# B. Convenciones de nombres

Los nombres de los objetos siguen unas reglas fijas. En el trial, además, todos los usuarios comparten el sistema: antes de crear un objeto, comprueba con **Ctrl+Shift+A** que su nombre está libre (1.1).

## Prefijos de los proyectos

| Proyecto | Paquete | Prefijo de objetos | Para qué |
|---|---|---|---|
| Taller RuedaLibre (ejemplos) | `ZEJ` | `ZTL`, `ztl_`, `ZI_Tl`, `ZC_Tl`, `ZCL_TL_` | Probar los ejemplos de la teoría |
| ERP de Obras y Reformas | `ZGOR` y sus subpaquetes | `ZGOR`, `zgor_`, `ZI_Gor`, `ZC_Gor`, `ZCL_GOR_` | Tu proyecto |

## Objetos del ERP

| Objeto | Convención | Ejemplo | Límite |
|---|---|---|---|
| Paquetes | `ZGOR`, `ZGOR_DDIC`, `ZGOR_CDS`, `ZGOR_BUS`, `ZGOR_SRV`, `ZGOR_TEST` | | 30 |
| Tabla | `zgor_<entidad>`; hija `zgor_<padre>_<hija>`; satélites `_obs`, `_inc`, `_arc` | `zgor_presu_lin`, `zgor_obra_inc` | **16** |
| Tabla de borradores | La tabla con `_d` | `zgor_presu_lin_d` | **16** |
| Estructura | `zgor_s_<nombre>` | `zgor_s_bitacora` | 30 |
| Vista interface | `ZI_Gor<Entidad>` | `ZI_GorPresupuesto` | 30 |
| Vista de cálculo | `ZI_Gor<Entidad><Qué>` | `ZI_GorObraFinanzas`, `ZI_GorTrabAcum` | 30 |
| Entidad abstracta (parámetro de una acción o de un evento) | `ZA_Gor<Nombre>` | `ZA_GorVincularObra` | 30 |
| Proyección | `ZC_Gor<Entidad>` | `ZC_GorObra` | 30 |
| Metadata extension | Igual que la proyección | `ZC_GorObra` | 30 |
| BDEF | Igual que la vista raíz | `ZI_GorObra` | 30 |
| Clase de comportamiento | `zbp_i_gor<raíz>` | `zbp_i_gorobra` | 30 |
| Service Definition | `ZUI_GOR_<ÁREA>` | `ZUI_GOR_COMERCIAL` | 30 |
| Service Binding | La definición con `_O4` | `ZUI_GOR_COMERCIAL_O4` | 30 |
| Servicio para otros sistemas (Web API) | `ZAPI_GOR_<NOMBRE>`, *binding* con `_O4` | `ZAPI_GOR_ERP_O4` | 30 |
| Interfaz de tipos | `ZIF_GOR_<NOMBRE>` | `ZIF_GOR_TIPOS` | 30 |
| Clase | `ZCL_GOR_<NOMBRE>` | `ZCL_GOR_REGLAS` | 30 |
| Excepción | `ZCX_GOR_<NOMBRE>` | `ZCX_GOR_REGLA` | 30 |
| Objeto de autorización | `ZGOR_<NOMBRE>` | `ZGOR_ERP` | 10 |

## Campos

| Dónde | Convención | Ejemplo |
|---|---|---|
| Columnas de tabla | minúsculas con guiones bajos, sin tildes | `coste_hora_estandar` |
| Clave técnica | `<entidad>_uuid` | `obra_uuid` |
| Código visible | `<entidad>_id` (ERP) | `obra_id` → `OBR0001` |
| Alias en CDS | *CamelCase*; UUID con `UUID`, código con `Id` | `ObraUUID`, `ObraId`, `CosteHoraEstandar` |
| Associations | Guion bajo y nombre en *CamelCase* | `_Cliente`, `_Lineas`, `_Finanzas` |

## Variables y parámetros en ABAP

| Prefijo | Significa | Ejemplo |
|---|---|---|
| `lv_`, `ls_`, `lt_`, `lo_` | Variable local: valor, estructura, tabla, objeto | `lv_base`, `lt_lineas` |
| `mv_`, `ms_`, `mt_`, `mo_` | Atributo de la clase | `mt_lineas` |
| `iv_`, `is_`, `it_`, `io_` | Parámetro de entrada | `iv_iva`, `it_lineas` |
| `rv_`, `rs_`, `rt_` | Valor devuelto | `rv_total`, `rs_kpi` |
| `lx_` | Excepción capturada | `lx_error` |
| `ty_`, `tt_` | Tipo de estructura, tipo de tabla | `ty_presu_linea`, `tt_presu_lineas` |
| `lc_` | Constante local | `lc_iva` |
| `<ls_…>` | *Field symbol* | `<ls_linea>` |

Los alias de las entidades en las BDEF van en *CamelCase* singular (`Obra`, `Linea`, `Observacion`) y son los que se usan en EML (`ENTITY Obra`) y en `failed-obra` / `reported-obra`.

---

**Siguiente:** [C. Glosario](./C_glosario.md)
