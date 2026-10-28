@EndUserText.label : 'Taller - Campos de una foto'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
// Una estructura no es una tabla: solo agrupa campos para incluirlos en otras
define structure ztl_s_foto {
  imagen                : abap.rawstring(0);   // el fichero, en binario
  tipo_mime             : abap.char(128);   // image/png, application/pdf...
  nombre_fichero        : abap.char(128);   // como se llamaba al subirlo
}
