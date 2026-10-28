@EndUserText.label: 'Taller - Datos del evento AbonoRegistrado'
// Los datos que viajan con el aviso
define abstract entity ZA_TlAbonoRegistrado
{
  OrdenUUID       : sysuuid_x16;
  CantidadAbonada : abap.dec(15,2);
}
