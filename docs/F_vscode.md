---
title: "F. El mismo flujo en VS Code"
parent: "Anexos"
nav_order: 6
---

# F. El mismo flujo en VS Code

{% raw %}
> **Pendiente de probar.** Este anexo resume lo publicado sobre la extensión oficial de SAP para VS Code y lo que **hay que comprobar** en el trial antes de usarla para el proyecto. Los apuntes siguen hechos para Eclipse con ADT.

## Qué es

SAP publicó en mayo de 2026 la extensión **ABAP Development Tools for VS Code**, pensada para el modelo ABAP Cloud. Según su ficha y los primeros artículos, se conecta a SAP BTP ABAP Environment por HTTP e incluye:

- Editor con autocompletado, formateador, navegación y búsqueda de referencias.
- Creación y activación de objetos del diccionario, CDS y RAP (BDEF, *service bindings*…).
- Depurador, ABAP Unit y ATC.
- Gestión de transportes.

## Qué comprobar en tu trial

| Qué | Por qué importa | Cómo |
|---|---|---|
| Se conecta al trial | Es un sistema compartido con su propio inicio de sesión | *ABAP: New Destination*, tipo HTTP, con la URL de la instancia |
| Funciona en Linux | La ficha no lo dice | Instálala en tu Ubuntu |
| **abapGit** | Es tu copia de seguridad (5.2). En Eclipse es un plugin | Busca una vista o comando de abapGit; si no hay, sigue usando Eclipse para el *push* |
| Vista previa del *service binding* | Es la forma de ver tus apps (4.2) | Abre un *binding* publicado |
| Crear tablas de borradores con un clic | En Eclipse es **Ctrl+1** (3.1) | Prueba con una BDEF nueva |
| Atajos | Los de los apuntes son de Eclipse | Anota los equivalentes en la tabla de abajo |

## Equivalencias de atajos

Rellénala al probarla:

| Acción | Eclipse (ADT) | VS Code |
|---|---|---|
| Activar | Ctrl+F3 | |
| Ejecutar clase de consola | F9 | |
| Tests de la clase | Ctrl+Shift+F10 | |
| Abrir objeto | Ctrl+Shift+A | |
| Corrección rápida | Ctrl+1 | |
| Información del elemento | F2 | |
| Ir a la definición | F3 | |
| Data Preview | F8 | |

## Recomendación

Para el proyecto, **Eclipse** sigue siendo la opción segura: es la herramienta completa, la de los tutoriales de SAP y probablemente la de la empresa. VS Code puede ser cómodo para editar y para usar asistentes de IA, pero no cambies de herramienta a mitad de un bloque. Si lo pruebas, hazlo con el paquete `ZEJ`.

---

**Siguiente:** [Restaurar en un trial nuevo](RESTAURAR.html)

[Mejorar esta página](https://github.com/pdawgabriel-hub/abap-ejercicios/edit/main/docs/F_vscode.md){: .fs-2 }
{% endraw %}
