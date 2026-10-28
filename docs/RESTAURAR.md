---
title: "Restaurar en un trial nuevo"
parent: "Anexos"
nav_order: 7
---

# Restaurar en un trial nuevo

{% raw %}
El sistema SAP es desechable; los repositorios son la copia de seguridad (5.3). Cuando caduque el trial, o lo vayas a perder, sigue estos pasos. Apunta al final lo que hayas tenido que hacer distinto.

## Antes de que caduque (día ~75)

1. Activa todos los objetos, ejecuta los tests de `ZGOR` (en verde) y pasa el ATC.
2. Haz *push* con abapGit de los dos paquetes: `ZGOR` → `erp-obras-reformas-sap` y `ZEJ` → `abap-ejercicios`.
3. En GitHub, comprueba que el último commit de cada repositorio está.
4. Apunta abajo lo que abapGit **no** guarda.

## En el trial nuevo

1. Registra el trial y ejecuta el booster **Prepare an Account for ABAP Trial**.
2. Apunta la fecha de registro y genera los recordatorios: `python3 herramientas/generar_recordatorios.py AAAA-MM-DD > trial.ics`.
3. En Eclipse, crea el proyecto ABAP Cloud con la nueva instancia (0.1).
4. Comprueba con **Ctrl+Shift+A** que `ZGOR` y `ZEJ` siguen libres. Si no, para: hay que cambiar de prefijo antes de traer nada.
5. Crea el paquete `ZGOR` (en `ZLOCAL`, con el mismo nombre y descripción que antes). Los subpaquetes los creará el *pull*.
6. En la vista **abapGit Repositories**, enlaza `erp-obras-reformas-sap` con `ZGOR` y haz **Pull**. Repite con `abap-ejercicios` y `ZEJ`.
7. Activa todo `ZGOR` (clic derecho → *Activate*). Si algo no activa a la primera, vuelve a activar: a veces el orden importa.
8. Publica los tres *service bindings* (`ZUI_GOR_*_O4`).
9. Ejecuta `ZCL_GOR_DATOS_DEMO` y después `ZCL_GOR_COMPROBAR_CDS`: «0 errores».
10. Ejecuta los tests de `ZGOR`: todos en verde. Abre una app.

Si el *pull* da errores, copia el mensaje exacto y consúltalo antes de borrar nada.

## Lo que abapGit no guarda

| Qué | Cómo se repite |
|---|---|
| El usuario y su acceso a la instancia | Booster del paso 1 |
| La publicación de los *bindings* | Paso 8 |
| Roles y catálogos asignados (6.1) | A mano, si los usaste |
| Datos | `ZCL_GOR_DATOS_DEMO` |
| Ajustes de Eclipse | A mano |
| (añade aquí lo que encuentres) | |

---

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/RESTAURAR.md){: .fs-2 }
{% endraw %}
