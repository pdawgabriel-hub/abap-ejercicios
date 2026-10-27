#!/usr/bin/env python3
"""Genera una clase ABAP (classrun) que inserta en una tabla Z los datos de un CSV.

Uso:
  python3 generar_carga.py clientes.csv zgor_cli zcl_gor_carga_cli \
      --uuid cliente_uuid --dates fecha_alta > zcl_gor_carga_cli.abap

El CSV debe tener cabecera con los NOMBRES DE COLUMNA de la tabla ABAP (en
minusculas, como en la definicion de la tabla) y estar en UTF-8.
  --uuid   campo UUID de la clave (se genera con CL_SYSTEM_UUID).
  --dates  campos de fecha; se convierten de AAAA-MM-DD a AAAAMMDD.
  --clear  anade un DELETE FROM de la tabla antes de insertar (solo para pruebas).
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
    a = ap.parse_args()
    fechas = {c.strip().lower() for c in a.dates.split(",") if c.strip()}

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
    if a.clear:
        out.append(f"    DELETE FROM {a.tabla}.")
    for fila in filas:
        out.append("    APPEND VALUE #(")
        if a.uuid:
            out.append(f"      {a.uuid} = cl_system_uuid=>create_uuid_x16_static( )")
        for col, val in fila.items():
            col = col.strip().lower()
            val = (val or "").strip()
            if col in fechas and val:
                val = val.replace("-", "")[:8]
            out.append(f"      {col} = {lit(val)}")
        out.append("    ) TO lt_datos.")
    out.append(f"    INSERT {a.tabla} FROM TABLE @lt_datos.")
    out.append("    out->write( |Filas insertadas: { sy-dbcnt }| ).")
    out.append("  ENDMETHOD.")
    out.append("ENDCLASS.")
    print("\n".join(out))


if __name__ == "__main__":
    main()
