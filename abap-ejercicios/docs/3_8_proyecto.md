---
title: "3.8. Proyecto: comportamiento de Clientes y Obras"
parent: "3. Comportamiento con RAP"
nav_order: 8
---

# 3.8. Proyecto: comportamiento de Clientes y Obras

{% raw %}
Aplica el bloque 3 a las dos primeras entidades de `gestion_bd`.

## Criterio de «listo»

- [ ] BDEF de `ZI_GorCliente` y `ZI_GorObra` activas con `create`, `update`, `delete` y `strict ( 2 )`.
- [ ] Clases de implementación activas y sin errores.
- [ ] Una determination *on modify* y otra *on save* en Cliente.
- [ ] Una validation en Cliente (nombre obligatorio).
- [ ] Una action `cerrarObra` en Obra con estado 'C' → 'F'.
- [ ] Push con abapGit («Fase 2-3: comportamiento de Cliente y Obra»).

## Ejercicios

1. **Fase 2.** Crea la BDEF de `ZI_GorCliente` y su clase de implementación. Aunque no tenga lógica, debe activar sin errores.
2. **Fase 3.** Implementa en Cliente la determination de fecha y de número, y la validation del nombre.
3. **Acción.** Implementa `cerrarObra` en Obra con un mensaje de error si el estado no es 'C'.

> **Si algo no compila**, copia el mensaje exacto y consúltalo. Es lo que más vas a aprender.


---

**Siguiente:** [4.1. Proyecciones](4_1_proyecciones.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/3_8_proyecto.md){: .fs-2 }
{% endraw %}
