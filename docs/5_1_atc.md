---
title: "5.1. ATC y calidad de código"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 1
---

# 5.1. ATC y calidad de código

{% raw %}
**ATC** (ABAP Test Cockpit) es el analizador estático de SAP. En ABAP Cloud también comprueba que solo usas APIs liberadas.

## Cómo lanzarlo

Clic derecho sobre el paquete (o la clase) → **Run As → ABAP Test Cockpit** (o *ATC with...* para elegir variante). Los resultados salen en la vista *ATC Problems*.

## Qué mirar

- **Errores de prioridad 1 y 2**: corrígelos siempre.
- **Uso de APIs no liberadas**: sustitúyelas por la alternativa liberada.
- **Avisos de rendimiento**, como un `SELECT` dentro de un bucle.

## Ejercicios

1. **Primer ATC.** Pásalo por el paquete de ejercicios y apunta los avisos.
2. **Un `SELECT` en bucle.** Escríbelo mal a propósito, detecta el aviso y corrígelo con `FOR ALL ENTRIES` o un `JOIN`.
3. **Antes de publicar.** Añade pasar el ATC a tu checklist de commit.


---

**Siguiente:** [5.2. abapGit: tu código en GitHub](5_2_abapgit.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_1_atc.md){: .fs-2 }
{% endraw %}
