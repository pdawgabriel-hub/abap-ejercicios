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
    " Las partidas de los presupuestos pedidos
    READ ENTITIES OF zi_tlpresupuesto IN LOCAL MODE
      ENTITY Presupuesto BY \_Partidas FIELDS ( Concepto Cantidad PrecioUnitario ImportePartida )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partidas).

    LOOP AT keys INTO DATA(ls_key).
      " Una fila de la hoja: todo texto, salvo la cantidad
      TYPES: BEGIN OF ty_fila,
               concepto TYPE string,
               cantidad TYPE i,
               precio   TYPE string,
               importe  TYPE string,
             END OF ty_fila.
      DATA lt_filas TYPE STANDARD TABLE OF ty_fila WITH EMPTY KEY.
      " Primera fila: los titulos de las columnas
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
      DATA(lv_fichero) = lo_documento->get_file_content( ).   " el .xlsx en binario

      " Guardarlo como adjunto del presupuesto (la lista de 3.6)

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

> **Código completo del taller:** el método `exportarPresupuesto` de [zbp_i_tlpresupuesto](./materiales/taller/src/bus/zbp_i_tlpresupuesto.clas.locals_imp.abap). Todos los objetos, en [materiales/taller](./materiales/taller/README.md).

## Preparación del entorno de trabajo

Si usas la hoja de cálculo, la acción va en la BDEF y la clase del presupuesto (`ZGOR_BUS`) y el fichero se guarda en su lista de archivos de 3.6. Si usas el servicio de formularios, sigue su documentación.

## Ejercicios

1. **Disponibilidad.** Averigua si tu trial tiene el servicio de formularios y anota lo que encuentres y dónde.
2. **El presupuesto.** Con el camino que te funcione, haz que el presupuesto del ERP se pueda descargar con los datos de §8: cliente (los datos **copiados** en el presupuesto), líneas, base imponible, IVA y total. Si usas el camino 2:
    - **Dónde:** BDEF `ZI_GorPresupuesto` (`action exportarPresupuesto result [1] $self;`, y `use action` en la proyección), clase local `lhc_presupuesto` y la metadata extension de `ZC_GorPresupuesto` (el botón, `type: #FOR_ACTION`).
    - **Qué hace:** como `exportarPresupuesto` del taller, pero las primeras filas de la hoja son los datos del cliente y las últimas, base imponible, IVA y total. El fichero se guarda en la lista de archivos del presupuesto (3.6) con `Tipo` `otro`.
    - **Comprueba:** en `ZCL_GOR_EML_DEMO`, ejecuta la acción sobre `PREP0001` y guarda: `SELECT COUNT( * ) FROM zgor_presu_arc` sube en 1, con `nombre_archivo` `presupuesto.xlsx`. En la vista previa, descárgalo desde la pestaña *Archivos* y ábrelo con LibreOffice: 1210 en el total.
3. **Los otros dos.** Haz lo mismo con el parte de trabajo (horas y trabajadores) y con el seguimiento de gastos de la obra (ingresos, gastos, beneficio real y saldo pendiente, leídos de `ZI_GorObraFinanzas`).
4. **Investiga.** Si ninguno de los dos caminos funciona en tu sistema, describe en `diseno.md` cómo resolvería esto una empresa con S/4HANA y qué pondrías en el README.

---

**Siguiente:** [6.4. Dashboard y calendario](./6_4_dashboard.md)
