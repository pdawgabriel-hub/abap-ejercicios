---
title: "Restaurar en un trial nuevo"
parent: "Anexos"
nav_order: 5
---

{% raw %}
# Restaurar este repositorio en un trial nuevo

El sistema SAP es desechable; este repositorio es la copia de seguridad.
Cuando caduque el trial (o lo vayas a perder), sigue estos pasos.

## Antes de que caduque (dia ~75)

1. Activa todos los objetos y pasa el ATC.
2. Haz push con abapGit de todos los paquetes (`ZEJ`).
3. En GitHub, comprueba que el ultimo commit esta.
4. Apunta lo que abapGit NO guarda: usuarios, roles, configuracion del cockpit.

## En el trial nuevo

1. Registra el trial nuevo y ejecuta el booster "Prepare an Account for ABAP Trial".
2. Anota la fecha de registro y genera recordatorios:
   `python3 herramientas/generar_recordatorios.py AAAA-MM-DD > trial.ics`
3. En Eclipse (ADT) crea el proyecto ABAP Cloud con la nueva instancia.
4. Crea el paquete `ZEJ` (mismo nombre que antes) y la orden de transporte.
5. Abre la vista abapGit Repositories, enlaza este repositorio y haz **Pull**.
6. Activa todos los objetos (Ctrl+Shift+F3 sobre el paquete).
7. Ejecuta los tests de ABAP Unit (Ctrl+Shift+F10) para comprobar la restauracion.

Si el nombre de paquete ya esta ocupado o el pull da errores, copia el mensaje
exacto y consultalo antes de borrar nada.
{% endraw %}
