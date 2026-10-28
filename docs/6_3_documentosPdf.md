# 6.3. Documentos imprimibles

> **Zona menos verificada.** El servicio de formularios PDF (*Forms Service by Adobe*) puede no estar disponible en el trial, y la API XCO para hojas de cálculo que se usa como alternativa no se ha probado contra un sistema real. Comprueba la disponibilidad antes de planificar esta unidad; es opcional para el portfolio.

`gestion_bd` imprime tres documentos (§8 del informe): el **presupuesto** para el cliente, el **parte de trabajo** y el **seguimiento de gastos** de la obra. En SAP hay dos caminos.

## Camino 1: formularios PDF

El camino de una empresa es el servicio de formularios de Adobe: una **plantilla** de formulario diseñada aparte, que recibe los datos (los mismos que ve el usuario en pantalla) y devuelve un PDF. En ABAP Cloud se rellena desde código con la API de *Output Management* o del servicio de formularios, normalmente desde una acción como `imprimirPresupuesto`.

**Regla de oro**: el formulario **no calcula nada**. Recibe los números ya calculados, para que el PDF diga siempre lo mismo que la pantalla.

Antes de seguir este camino, comprueba en el cockpit de tu trial si tienes el servicio de formularios. Si no lo tienes, pasa al camino 2.

## Camino 2: una hoja de cálculo como adjunto

Con la biblioteca **XCO** de ABAP Cloud se puede generar un fichero `.xlsx` y guardarlo como **adjunto** del registro, en la tabla de archivos de 3.6. El usuario lo descarga desde la pestaña de adjuntos. En el taller, la acción `exportarPresupuesto` del presupuesto:

```abap
  METHOD exportarPresupuesto.
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario ImportePartida )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    LOOP AT keys INTO DATA(ls_key).
      TYPES: BEGIN OF ty_fila,
               concepto TYPE string,
               cantidad TYPE i,
               precio   TYPE string,
               importe  TYPE string,
             END OF ty_fila.
      DATA lt_filas TYPE STANDARD TABLE OF ty_fila WITH EMPTY KEY.
      lt_filas = VALUE #( ( concepto = 'Concepto' precio = 'Precio' importe = 'Importe' ) ).
      LOOP AT lt_partidas INTO DATA(ls_partida) WHERE PresupuestoUUID = ls_key-PresupuestoUUID.
        APPEND VALUE #( concepto = ls_partida-Concepto cantidad = ls_partida-Cantidad
                        precio   = |{ ls_partida-PrecioUnitario DECIMALS = 2 }|
                        importe  = |{ ls_partida-ImportePartida DECIMALS = 2 }| ) TO lt_filas.
      ENDLOOP.

      " Hoja de calculo con una pestana y las filas desde A1
      DATA(lo_documento) = xco_cp_xlsx=>document->empty( )->write_access( ).
      DATA(lo_hoja) = lo_documento->get_workbook( )->worksheet->at_position( 1 ).
      DATA(lo_patron) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
      lo_hoja->select( lo_patron )->row_stream( )->operation->write_from( REF #( lt_filas ) )->execute( ).
      DATA(lv_fichero) = lo_documento->get_file_content( ).

      MODIFY ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
        ENTITY Presupuesto CREATE BY \_Fotos FIELDS ( Imagen TipoMime NombreFichero )
        WITH VALUE #( ( %tky    = ls_key-%tky
                        %target = VALUE #( ( %cid          = 'XLSX'
                                             %is_draft     = ls_key-%is_draft
                                             Imagen        = lv_fichero
                                             TipoMime      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                             NombreFichero = 'presupuesto.xlsx' ) ) ) ).
    ENDLOOP.
  ENDMETHOD.
```

Los nombres de los métodos de XCO son largos y encadenados; si alguno no existe en tu versión, busca la clase `XCO_CP_XLSX` con **F2** y el ejemplo de la documentación de XCO.

## Ejercicios

1. **Disponibilidad.** Averigua si tu trial tiene el servicio de formularios y anota lo que encuentres y dónde.
2. **El presupuesto.** Con el camino que te funcione, haz que el presupuesto del ERP se pueda descargar con los datos de §8: cliente (los datos **copiados** en el presupuesto), líneas, base imponible, IVA y total.
3. **Los otros dos.** Haz lo mismo con el parte de trabajo (horas y trabajadores) y con el seguimiento de gastos de la obra (ingresos, gastos, beneficio real y saldo pendiente, leídos de `ZI_GorObraFinanzas`).
4. **Investiga.** Si ninguno de los dos caminos funciona en tu sistema, describe en `diseno.md` cómo resolvería esto una empresa con S/4HANA y qué pondrías en el README.

---

**Siguiente:** [6.4. Migración de datos desde Odoo](./6_4_migracion.md)
