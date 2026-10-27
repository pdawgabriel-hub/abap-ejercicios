---
title: "5.2. abapGit: tu código en GitHub"
parent: "5. Calidad, Git y ciclo de 90 días"
nav_order: 2
---

# 5.2. abapGit: tu código en GitHub

{% raw %}
El código ABAP vive en el sistema, no en ficheros. **abapGit** lo serializa y lo sincroniza con un repositorio de GitHub. Es la forma de tener tu proyecto en GitHub y de **restaurarlo** cuando caduque el trial ([5.3](5_3_ciclo90dias.html)).

## Preparación

1. Crea en GitHub el repositorio vacío (`abap-ejercicios` o `gestion-bd-sap`).
2. Crea un **Personal Access Token** con permiso de escritura sobre repositorios (*Settings → Developer settings → Personal access tokens*). Guárdalo en un gestor de contraseñas. **Nunca lo subas.**

## Primer enlace

1. En Eclipse abre la vista **abapGit Repositories** (*Window → Show View*; si no aparece, usa la app *abapGit Repositories* del lanzador Fiori).
2. **Link** / **New Online** y pega la URL del repositorio.
3. Elige el paquete (`ZEJ` o `ZGOR`) y modo **Prefix** o **Full** según te proponga la herramienta.
4. Introduce usuario y token.
5. **Stage** de los objetos, escribe el mensaje y **Push**.

> abapGit genera él mismo los ficheros de `src/` y `.abapgit.xml`. **No los escribas a mano.**

## Rutina de commit

1. Activa todos los objetos.
2. Pasa el ATC ([5.1](5_1_atc.html)).
3. Push con mensaje descriptivo («Fase 3: validations de Cliente»).
4. Una vez por semana, comprueba en GitHub que el commit está.

## Ejercicios

1. **Primer push.** Sube la clase `ZCL_EJ_HOLA` de [0.1](00_instalacionEntorno.html).
2. **Pull de prueba.** Edita el README en GitHub y haz *Pull* desde Eclipse.
3. **Conflicto.** Explica qué harías si cambias el mismo objeto en el sistema y en GitHub.


---

**Siguiente:** [5.3. El ciclo de 90 días](5_3_ciclo90dias.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/5_2_abapgit.md){: .fs-2 }
{% endraw %}
