---
title: "5.3. El ciclo de 90 días"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 3
---

# 5.3. El ciclo de 90 días

{% raw %}
El trial de SAP BTP dura **90 días desde el registro**. Al terminar, se elimina la cuenta con todo lo que contiene. Además, hay que **iniciar sesión al menos cada 30 días**: si no, se puede cerrar antes. Después se puede abrir un trial nuevo y empezar de cero. La página de SAP no dice cuánto dura la **instancia ABAP** dentro del trial: **consúltalo en el cockpit** (en la instancia del servicio ABAP) y apúntalo.

Con estas reglas, el sistema SAP es **desechable**. Lo que no se puede perder es el repositorio.

## Qué se guarda y dónde

| Qué | Dónde está a salvo | Cómo se recupera |
|---|---|---|
| Código: tablas, vistas, BDEF, clases, servicios | GitHub, con abapGit (5.2) | *Pull* |
| Datos de prueba | `ZCL_GOR_DATOS_DEMO` (2.5), que está en GitHub con el código | Ejecutarla |
| Diseño, decisiones, capturas | `docs/` del repositorio | Ya están |
| Usuario, *bindings* publicados, configuración del cockpit | **En ningún sitio** | Repetir a mano: apúntalo en el anexo [Restaurar](RESTAURAR.html) |

Por eso los datos de demo se crean con una clase y no a mano: así forman parte del código.

## El calendario

| Día | Qué hacer |
|---|---|
| 0 | Registro. Apunta la fecha y genera los recordatorios con `herramientas/generar_recordatorios.py` |
| Cada ≤ 30 | Inicia sesión en el cockpit (evita el cierre por inactividad) |
| ~60 | Revisa que todo está subido; ensayo de restauración si no lo has hecho (5.4) |
| ~75 | **Copia final**: tests en verde, ATC y *push* de todo. Comprueba en GitHub el último commit |
| 90 | Caducidad |
| 90+ | Trial nuevo y [restauración](RESTAURAR.html) |

```bash
python3 herramientas/generar_recordatorios.py 2026-12-01 > trial.ics
```

Importa `trial.ics` en tu calendario. El fichero está en `.gitignore`: no se sube.

## Planificar los ciclos

En 90 días caben, con margen, los Bloques 2 a 5 si trabajas con regularidad. Una forma de repartirlo (ajústala en el [Anexo D](D_planificacion.html)):

- **Antes del trial:** el Bloque 1 casi entero se puede escribir y razonar sin sistema; pruébalo en cuanto abras el trial.
- **Primer trial:** Bloques 1 a 5, con un ensayo de restauración hacia el día 60.
- **Segundo trial:** restaurar y seguir con los Bloques 6 y 7.

## Ejercicios

1. **Fechas.** Apunta tu fecha de registro, la de caducidad y las de los avisos. Genera los recordatorios.
2. **La instancia.** Busca en el cockpit cuánto dura tu instancia ABAP y si coincide con la cuenta. Anótalo en el anexo de restauración.
3. **Lo que no se guarda.** Completa la lista de la tabla con todo lo que has configurado a mano desde 0.1 (usuarios, *bindings* publicados, ajustes de Eclipse…) y dónde lo anotas.
4. **Investiga.** ¿Qué pasa con los objetos que creaste en `ZLOCAL` si el trial es compartido y caduca **tu** cuenta? ¿Siguen ahí para los demás? Anota lo que encuentres y la fuente.

---

**Siguiente:** [5.4. Proyecto: ensayo de restauración](5_4_proyecto.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_3_ciclo90dias.md){: .fs-2 }
{% endraw %}
