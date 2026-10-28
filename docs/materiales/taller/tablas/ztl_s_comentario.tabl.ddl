@EndUserText.label : 'Taller - Campos de una nota o un aviso'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
// Una estructura no es una tabla: solo agrupa campos para incluirlos en otras
define structure ztl_s_comentario {
  comentario            : abap.string(0);   // texto sin limite de longitud
}
