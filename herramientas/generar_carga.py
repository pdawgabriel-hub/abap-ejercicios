#!/usr/bin/env python3
"""Genera una clase ABAP (classrun) que inserta en una tabla Z los datos de un CSV.

Uso:
  python3 generar_carga.py clientes.csv zgor_cli zcl_gor_carga_cli \
      --uuid cliente_uuid > zcl_gor_carga_cli.abap
  python3 generar_carga.py obras.csv zgor_obra zcl_gor_carga_obra \
      --uuid obra_uuid --ref cliente_uuid=zgor_cli.cliente_id:cliente > zcl_gor_carga_obra.abap

El CSV debe tener cabecera con los NOMBRES DE COLUMNA de la tabla ABAP (en
minusculas, como en la definicion de la tabla) y estar en UTF-8.
  --uuid   campo UUID de la clave (se genera con CL_SYSTEM_UUID).
  --dates  campos de fecha; se convierten de AAAA-MM-DD a AAAAMMDD.
  --clear  anade un DELETE FROM de la tabla antes de insertar (solo para pruebas).
  --ref    relacion por codigo: COLUMNA_UUID=TABLA.COLUMNA_CODIGO:COLUMNA_CSV.
           La columna del CSV trae el codigo (CLI0001) y la clase busca su UUID
           en la tabla indicada, que ya debe estar cargada. Se puede repetir.
El resultado se pega en una clase nueva de Eclipse y se ejecuta con F9.
"""
import argparse
import csv
import sys


def lit(valor):
    return "'" + valor.replace("'", "''") + "'"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv")
    ap.add_argument("tabla")
    ap.add_argument("clase")
    ap.add_argument("--uuid", default="")
    ap.add_argument("--dates", default="")
    ap.add_argument("--clear", action="store_true")
    ap.add_argument("--ref", action="append", default=[])
    a = ap.parse_args()
    fechas = {c.strip().lower() for c in a.dates.split(",") if c.strip()}

    # --ref cliente_uuid=zgor_cli.cliente_id:cliente
    refs = []
    for r in a.ref:
        try:
            destino, resto = r.split("=", 1)
            origen, col_csv = resto.split(":", 1)
            tabla_ref, col_codigo = origen.split(".", 1)
        except ValueError:
            sys.exit(f"--ref mal escrito: {r} (formato COL_UUID=TABLA.COL_CODIGO:COL_CSV)")
        refs.append((destino.strip().lower(), tabla_ref.strip().lower(),
                     col_codigo.strip().lower(), col_csv.strip().lower()))
    cols_ref = {r[3] for r in refs}

    with open(a.csv, newline="", encoding="utf-8") as f:
        filas = list(csv.DictReader(f))
    if not filas:
        sys.exit("El CSV no tiene filas")

    out = []
    out.append(f"CLASS {a.clase} DEFINITION PUBLIC FINAL CREATE PUBLIC.")
    out.append("  PUBLIC SECTION.")
    out.append("    INTERFACES if_oo_adt_classrun.")
    out.append("ENDCLASS.")
    out.append("")
    out.append(f"CLASS {a.clase} IMPLEMENTATION.")
    out.append("  METHOD if_oo_adt_classrun~main.")
    out.append(f"    DATA lt_datos TYPE STANDARD TABLE OF {a.tabla} WITH EMPTY KEY.")
    for n, (destino, tabla_ref, col_codigo, _) in enumerate(refs, 1):
        out.append(f"    \" UUID de {tabla_ref} por su codigo")
        out.append(f"    SELECT FROM {tabla_ref} FIELDS {col_codigo} AS codigo, {destino} AS uuid")
        out.append(f"      INTO TABLE @DATA(lt_ref_{n}).")
    if a.clear:
        out.append(f"    DELETE FROM {a.tabla}.")
    out.append("    TRY.")
    for fila in filas:
        out.append("        APPEND VALUE #(")
        if a.uuid:
            out.append(f"          {a.uuid} = cl_system_uuid=>create_uuid_x16_static( )")
        for n, (destino, _, _, col_csv) in enumerate(refs, 1):
            codigo = (fila.get(col_csv) or "").strip()
            if not codigo:
                continue
            out.append(f"          {destino} = VALUE #( lt_ref_{n}[ codigo = {lit(codigo)} ]-uuid OPTIONAL )")
        for col, val in fila.items():
            col = col.strip().lower()
            if col in cols_ref:
                continue
            val = (val or "").strip()
            if col in fechas and val:
                val = val.replace("-", "")[:8]
            out.append(f"          {col} = {lit(val)}")
        out.append("        ) TO lt_datos.")
    out.append("      CATCH cx_uuid_error.")
    out.append("        out->write( 'No se pudo generar un UUID' ).")
    out.append("        RETURN.")
    out.append("    ENDTRY.")
    out.append(f"    INSERT {a.tabla} FROM TABLE @lt_datos.")
    out.append("    out->write( |Filas insertadas: { sy-dbcnt }| ).")
    out.append("  ENDMETHOD.")
    out.append("ENDCLASS.")
    print("\n".join(out))


if __name__ == "__main__":
    main()
