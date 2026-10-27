#!/usr/bin/env python3
"""Genera un .ics con los recordatorios del trial de SAP BTP (90 dias).

Uso:  python3 generar_recordatorios.py AAAA-MM-DD > trial.ics
La fecha es la de REGISTRO del trial. Importa el .ics en tu calendario.
Eventos: login cada 30 dias, revision (dia 60), copia final (dia 75),
caducidad (dia 90).
"""
import sys
from datetime import date, timedelta


def evento(uid, dia, titulo):
    d = dia.strftime("%Y%m%d")
    fin = (dia + timedelta(days=1)).strftime("%Y%m%d")
    return ["BEGIN:VEVENT", f"UID:{uid}@sap-trial", f"DTSTAMP:{d}T000000Z",
            f"DTSTART;VALUE=DATE:{d}", f"DTEND;VALUE=DATE:{fin}",
            f"SUMMARY:{titulo}", "END:VEVENT"]


def main():
    if len(sys.argv) != 2:
        sys.exit("Uso: generar_recordatorios.py AAAA-MM-DD")
    try:
        d0 = date.fromisoformat(sys.argv[1])
    except ValueError:
        sys.exit("Fecha no valida; usa AAAA-MM-DD")
    ev = [
        (25, 25, "SAP trial: inicia sesion (limite 30 dias)"),
        (30, 30, "SAP trial: LIMITE de login de 30 dias"),
        (55, 55, "SAP trial: inicia sesion (limite 30 dias)"),
        (60, 60, "SAP trial: revisar que todo esta en GitHub"),
        (75, 75, "SAP trial: COPIA FINAL (push con abapGit)"),
        (85, 85, "SAP trial: ultimo aviso, caduca en 5 dias"),
        (90, 90, "SAP trial: CADUCA hoy"),
    ]
    lin = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//sap-trial//ES"]
    for n, (dias, _, t) in enumerate(ev):
        lin += evento(f"ev{n}", d0 + timedelta(days=dias), t)
    lin.append("END:VCALENDAR")
    sys.stdout.write("\r\n".join(lin) + "\r\n")


if __name__ == "__main__":
    main()
