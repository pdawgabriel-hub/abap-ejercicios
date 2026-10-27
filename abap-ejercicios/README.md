# abap-ejercicios

Apuntes y ejercicios de **SAP ABAP Cloud y RAP** (SAP BTP ABAP Environment, trial gratuito).

- Apuntes: https://pdawgabriel-hub.github.io/abap-ejercicios/
- Proyecto asociado: https://github.com/pdawgabriel-hub/gestion-bd-sap

## Contenido

| Carpeta | Qué hay |
|---|---|
| `docs/` | El sitio de apuntes (Jekyll, tema just-the-docs) |
| `ejercicios/` | Esqueletos de clase y sus tests de ABAP Unit |
| `herramientas/` | Scripts: cargador de datos desde CSV, recordatorios del trial, instalador de Eclipse |
| `src/` | **Lo genera abapGit** al hacer push del paquete `ZEJ`. No se escribe a mano |

## Publicar los apuntes

1. Sube el repositorio a GitHub.
2. *Settings, Pages*: origen **Deploy from a branch**, rama `main`, carpeta `/docs`.
3. La web queda en la URL de arriba (tarda un par de minutos).

Si el tema no carga, se puede fijar una versión del tema en `docs/_config.yml`
(`remote_theme: just-the-docs/just-the-docs@v0.10.0`) o probar en local con `docs/Gemfile`.

## Uso de los ejercicios

Cada fichero `ejercicios/zcl_ej_*.abap` es un esqueleto con métodos vacíos (`" TODO`) y
cada `*_test.abap` su test. Se pegan en Eclipse (ADT) en la clase correspondiente.
Las instrucciones están en los apuntes.

## Si caduca el trial

Mira `RESTAURAR.md`. El repositorio es la copia de seguridad; el sistema SAP es desechable.

> El código no se ha compilado contra un sistema real. Si algo da error al activar,
> copia el mensaje exacto y revisa los apuntes.
