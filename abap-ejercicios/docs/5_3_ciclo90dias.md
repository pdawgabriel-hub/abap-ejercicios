---
title: "5.3. El ciclo de 90 días"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 3
---

# 5.3. El ciclo de 90 días

{% raw %}
El trial de SAP BTP dura **90 días desde el registro** y al final se elimina la cuenta con sus datos. Hay que iniciar sesión al menos cada **30 días**. Después se puede abrir un trial nuevo. La documentación no dice nada de la duración de la instancia ABAP: **consúltalo en el cockpit** y apúntalo.

## Estrategia

- El **GitHub es la copia de seguridad**; el sistema es desechable.
- Un repositorio por tipo de trabajo: ejercicios (`abap-ejercicios`) y proyecto (`gestion-bd-sap`).
- Datos de prueba reproducibles con `herramientas/generar_carga.py`.

## Calendario

| Día | Qué hacer |
|---|---|
| 0 | Registro. Apunta la fecha y genera recordatorios (`generar_recordatorios.py`) |
| Cada ≤ 30 | Inicia sesión en el cockpit (evita el cierre por inactividad) |
| ~60 | Revisa que todo está subido y probado |
| ~75 | **Copia de seguridad final**: push de todo, descarga de datos |
| 90 | Caducidad |
| 90+ | Nuevo trial y [restauración](RESTAURAR.html) |

## Restaurar en un trial nuevo

1. Registra el trial nuevo y ejecuta el booster «Prepare an Account for ABAP Trial».
2. Conecta ADT con la nueva instancia.
3. Enlaza los repositorios con abapGit y haz **Pull** (primero el de ejercicios, luego el proyecto).
4. Activa los objetos y recarga los datos de prueba.
5. Comprueba el servicio y la app.

El documento paso a paso está en `RESTAURAR.md` de cada repositorio.

## Ejercicios

1. **Fecha.** Apunta tu fecha de registro y calcula las fechas clave.
2. **Simulacro.** Haz un pull en un paquete nuevo para comprobar que el repositorio es completo.
3. **Lo que no se guarda.** Haz una lista de lo que abapGit **no** guarda (usuarios, configuración del cockpit, datos) y dónde lo anotas.


---

**Siguiente:** [5.4. Proyecto: control de calidad y copia](5_4_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_3_ciclo90dias.md){: .fs-2 }
{% endraw %}
