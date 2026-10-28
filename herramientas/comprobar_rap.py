#!/usr/bin/env python3
"""Comprobaciones de coherencia de RAP que abaplint no hace.

abaplint revisa la sintaxis de ABAP y de CDS, pero trata los tipos de RAP como
desconocidos: no sabe si un campo usado en EML existe en la vista, ni si cada
determination de la BDEF tiene su metodo. Este script cruza los fuentes del taller
(docs/materiales/taller) y avisa de lo que impediria activar en el sistema:

1. BDEF: cada campo de field(), mapping y side effects existe en la vista; cada
   columna del mapping existe en la tabla; la tabla de borradores tiene todos los
   campos de la vista.
2. Clases de comportamiento: cada determination, validation y accion de la BDEF tiene
   su metodo, y cada metodo apunta a una pieza que existe.
3. EML: los campos de FIELDS ( ... ) existen en la entidad; %action-X y %element-X
   existen en el objeto de negocio.
4. Proyecciones y metadata extensions: los campos y las acciones existen.

Uso: python3 herramientas/comprobar_rap.py   (termina con codigo 1 si hay errores)
"""
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent / "docs" / "materiales" / "taller"
SRC = RAIZ / "src"
TABLAS = RAIZ / "tablas"
errores = []


def error(fichero, texto):
    errores.append(f"{fichero.relative_to(RAIZ) if isinstance(fichero, Path) else fichero}: {texto}")


def sin_comentarios(texto, abap=False):
    if abap:
        lineas = []
        for linea in texto.splitlines():
            if linea.lstrip().startswith("*"):
                continue
            # quitar comentario " fuera de literales (aproximado: el ultimo " sin | ni ' detras)
            m = re.match(r'^((?:[^"\'`|]|\'[^\']*\'|`[^`]*`|\|[^|]*\|)*)"', linea)
            lineas.append(m.group(1) if m else linea)
        return "\n".join(lineas)
    texto = re.sub(r"/\*.*?\*/", "", texto, flags=re.S)
    return re.sub(r"//.*", "", texto)


# ---------- tablas ----------

def columnas_tabla(nombre):
    f = TABLAS / f"{nombre.lower()}.tabl.ddl"
    if not f.exists():
        return None
    texto = sin_comentarios(f.read_text())
    cuerpo = texto[texto.index("{") + 1: texto.rindex("}")]
    cols = set()
    for linea in cuerpo.split(";"):
        linea = linea.strip()
        m = re.match(r'(?:"?%?\w+"?\s*:\s*)?include\s+(\w+)', linea)
        if m and "include" in linea:
            sub = columnas_tabla(m.group(1))
            cols |= sub or set()
            continue
        m = re.match(r"(?:key\s+)?(\w+)\s*:", linea)
        if m:
            cols.add(m.group(1).lower())
    return cols


# ---------- vistas CDS ----------

class Vista:
    def __init__(self, fichero):
        self.fichero = fichero
        texto = sin_comentarios(fichero.read_text())
        m = re.search(r"define\s+(?:root\s+)?(?:view\s+entity|abstract\s+entity)\s+(\w+)", texto, re.I)
        self.nombre = m.group(1) if m else fichero.name.split(".")[0]
        self.proyeccion = re.search(r"as\s+projection\s+on\s+(\w+)", texto, re.I)
        self.base = self.proyeccion.group(1) if self.proyeccion else None
        # quitar anotaciones (pueden llevar llaves, corchetes y comas)
        texto = re.sub(r"@[\w.]+\s*:\s*(\[(?:[^\[\]]|\[[^\]]*\])*\]|\{[^}]*\}|'[^']*'|[\w#.]+)", "", texto)
        cuerpo = texto[texto.index("{") + 1:]
        cuerpo = cuerpo[:cuerpo.index("}")]
        self.campos = set()
        self.asociaciones = set(re.findall(r"\bas\s+(_\w+)", texto[:texto.index("{")]))
        limpio = cuerpo
        for parte in self._partes(limpio):
            parte = parte.strip()
            if not parte:
                continue
            m = re.search(r"\bas\s+(\w+)\s*$", parte, re.I)
            if m:
                self.campos.add(m.group(1))
                continue
            m = re.match(r"(?:key\s+)?(\w+)\s*(?::\s*redirected.*)?$", parte, re.I | re.S)
            if m:
                nombre = m.group(1)
                if nombre.startswith("_"):
                    self.asociaciones.add(nombre)
                else:
                    self.campos.add(nombre)
                continue
            m = re.match(r"(\w+)\s*:\s*[\w.]+", parte)          # entidad abstracta: Campo : tipo
            if m:
                self.campos.add(m.group(1))

    @staticmethod
    def _partes(texto):
        """Separa por comas de primer nivel (fuera de parentesis)."""
        nivel, actual = 0, ""
        for c in texto:
            if c in "([":
                nivel += 1
            elif c in ")]":
                nivel -= 1
            if c == "," and nivel == 0:
                yield actual
                actual = ""
            else:
                actual += c
        yield actual


VISTAS = {}
for f in SRC.rglob("*.ddls.asddls"):
    v = Vista(f)
    VISTAS[v.nombre.lower()] = v


def campos_de(vista):
    v = VISTAS.get(vista.lower())
    return v.campos if v else set()


# ---------- BDEF ----------

class Entidad:
    def __init__(self, vista, alias):
        self.vista, self.alias = vista, alias
        self.acciones, self.determinaciones, self.validaciones = set(), set(), set()
        self.internas = set()
        self.persistente = self.borrador = None
        self.eventos = set()


class Bdef:
    def __init__(self, fichero):
        self.fichero = fichero
        texto = sin_comentarios(fichero.read_text())
        self.texto = texto
        m = re.search(r"implementation\s+in\s+class\s+(\w+)", texto, re.I)
        self.clase = m.group(1).lower() if m else None
        self.proyeccion = bool(re.match(r"\s*projection", texto))
        self.entidades = {}
        for bloque in re.finditer(r"define\s+behavior\s+for\s+(\w+)(?:\s+alias\s+(\w+))?(.*?)\{(.*?)\n\}",
                                  texto, re.S | re.I):
            vista, alias, cabecera, cuerpo = bloque.groups()
            e = Entidad(vista, alias or vista)
            m = re.search(r"persistent\s+table\s+(\w+)", cabecera)
            e.persistente = m.group(1) if m else None
            m = re.search(r"draft\s+table\s+(\w+)", cabecera)
            e.borrador = m.group(1) if m else None
            e.cuerpo = cuerpo
            for nombre in re.findall(r"(?<!draft )(?<!determine )\b(?:internal\s+)?action\s+(?:\([^)]*\)\s*)?(\w+)", cuerpo):
                e.acciones.add(nombre)
            e.internas = set(re.findall(r"internal\s+action\s+(\w+)", cuerpo))
            e.determinaciones = set(re.findall(r"(?<!\( always \) )\bdetermination\s+(\w+)\s+on", cuerpo))
            e.validaciones = set(re.findall(r"\bvalidation\s+(\w+)\s+on", cuerpo))
            e.eventos = set(re.findall(r"\bevent\s+(\w+)", cuerpo))
            self.entidades[e.alias.lower()] = e

    def comprobar(self):
        for e in self.entidades.values():
            campos = campos_de(e.vista)
            if not campos:
                error(self.fichero, f"la vista {e.vista} no existe")
                continue
            vista = VISTAS[e.vista.lower()]
            # field ( ... ) a, b;
            for lista in re.findall(r"field\s*\([^)]*\)\s*([^;]+);", e.cuerpo):
                for campo in re.split(r"[\s,]+", lista.strip()):
                    if campo and campo not in campos:
                        error(self.fichero, f"{e.alias}: el campo {campo} de field() no esta en {e.vista}")
            # use action / use association en proyecciones
            for a in re.findall(r"association\s+(_\w+)", e.cuerpo):
                if a not in vista.asociaciones:
                    error(self.fichero, f"{e.alias}: la association {a} no esta expuesta en {e.vista}")
            # mapping
            for m in re.finditer(r"mapping\s+for\s+(\w+)[^{]*\{(.*?)\}", e.cuerpo, re.S):
                cols = columnas_tabla(m.group(1)) or set()
                for izq, der in re.findall(r"(\w+)\s*=\s*(\w+)\s*;", m.group(2)):
                    if izq not in campos:
                        error(self.fichero, f"{e.alias}: mapping, {izq} no esta en {e.vista}")
                    if der.lower() not in cols:
                        error(self.fichero, f"{e.alias}: mapping, {der} no esta en la tabla {m.group(1)}")
            # side effects: field X affects field Y, field _A.Z
            for m in re.finditer(r"side\s+effects\s*\{(.*?)\}", e.cuerpo, re.S):
                for parte in re.findall(r"field\s+([\w.]+)", m.group(1)):
                    if "." in parte:
                        asoc, campo = parte.split(".")
                        destino = self._destino(e, asoc)
                        if destino and campo not in campos_de(destino):
                            error(self.fichero, f"{e.alias}: side effect, {parte} no existe")
                    elif parte not in campos:
                        error(self.fichero, f"{e.alias}: side effect, {parte} no esta en {e.vista}")
                for accion in re.findall(r"action\s+(\w+)", m.group(1)):
                    if accion not in e.acciones:
                        error(self.fichero, f"{e.alias}: side effect de una accion que no existe ({accion})")
            # Prepare: validations y determinations declaradas
            for m in re.finditer(r"draft\s+determine\s+action\s+Prepare\s*\{(.*?)\}", e.cuerpo, re.S):
                for tipo, nombre in re.findall(r"(validation|determination)\s+(?:\(\s*always\s*\)\s*)?([\w~]+)", m.group(1)):
                    alias, _, pieza = nombre.rpartition("~")
                    ent = self.entidades.get(alias.lower()) if alias else e
                    conjunto = (ent.validaciones if tipo == "validation" else ent.determinaciones) if ent else set()
                    if pieza not in conjunto:
                        error(self.fichero, f"Prepare: {tipo} {nombre} no esta declarada")
            # tablas de borradores con todos los campos
            if e.borrador:
                cols = columnas_tabla(e.borrador)
                if cols is None:
                    error(self.fichero, f"{e.alias}: no existe la tabla de borradores {e.borrador}")
                else:
                    for campo in campos:
                        if campo.lower() not in cols:
                            error(self.fichero, f"{e.alias}: el borrador {e.borrador} no tiene {campo.lower()}")
            if e.persistente and columnas_tabla(e.persistente) is None:
                error(self.fichero, f"{e.alias}: no existe la tabla {e.persistente}")

    def _destino(self, entidad, asoc):
        texto = VISTAS[entidad.vista.lower()].fichero.read_text()
        m = re.search(rf"(?:of|to|parent)\s+(\w+)\s+as\s+{asoc}\b", texto)
        return m.group(1) if m else None


BDEFS = {}
for f in SRC.rglob("*.bdef.asbdef"):
    b = Bdef(f)
    BDEFS[f.name.split(".")[0]] = b

for b in BDEFS.values():
    b.comprobar()


# ---------- clases de comportamiento ----------

def bdef_de_bo(bo):
    return BDEFS.get(bo.lower())


for f in SRC.rglob("*.clas.locals_imp.abap"):
    texto = sin_comentarios(f.read_text(), abap=True)
    clase = f.name.split(".")[0]
    bdef = next((b for b in BDEFS.values() if b.clase == clase), None)
    if not bdef:
        continue
    # Metodos declarados: FOR <tipo> ... FOR Alias~pieza
    declarados = {}
    for tipo, alias, pieza in re.findall(
            r"METHODS\s+\w+\s+FOR\s+(DETERMINE ON (?:MODIFY|SAVE)|VALIDATE ON SAVE|MODIFY)\s+"
            r"IMPORTING\s+keys\s+FOR\s+(?:ACTION\s+)?(\w+)~(\w+)", texto, re.I):
        declarados.setdefault(alias.lower(), set()).add(pieza)
        ent = bdef.entidades.get(alias.lower())
        if not ent:
            error(f, f"la entidad {alias} no esta en la BDEF")
        elif pieza not in ent.acciones | ent.determinaciones | ent.validaciones:
            error(f, f"{alias}~{pieza} no esta declarada en la BDEF")
    for alias, ent in bdef.entidades.items():
        for pieza in ent.acciones | ent.determinaciones | ent.validaciones:
            if pieza not in declarados.get(alias, set()):
                error(f, f"falta el metodo de {ent.alias}~{pieza}")
    if re.search(r"features\s*:\s*instance", bdef.texto) and "FOR INSTANCE FEATURES" not in texto:
        error(f, "la BDEF usa features : instance y falta get_instance_features")
    if "precheck" in bdef.texto and "FOR PRECHECK" not in texto:
        error(f, "la BDEF usa precheck y falta su metodo")
    if "with additional save" in bdef.texto and "save_modified" not in texto:
        error(f, "la BDEF usa with additional save y falta save_modified")


# ---------- EML en cualquier clase ----------

def entidad_de(bo, alias):
    b = bdef_de_bo(bo)
    if not b:
        return None
    return b.entidades.get(alias.lower())


for f in list(SRC.rglob("*.abap")):
    texto = sin_comentarios(f.read_text(), abap=True)
    for sentencia in re.findall(r"(?:READ|MODIFY)\s+ENTITIES\s+OF\s+\w+.*?\.(?=\s|$)", texto, re.S | re.I):
        bo = re.search(r"ENTITIES\s+OF\s+(\w+)", sentencia, re.I).group(1)
        b = bdef_de_bo(bo)
        if not b:
            continue
        # Trozos que empiezan en ENTITY <alias>
        for trozo in re.split(r"(?=\bENTITY\s+\w+)", sentencia)[1:]:
            alias = re.match(r"ENTITY\s+(\w+)", trozo).group(1)
            ent = b.entidades.get(alias.lower())
            if not ent:
                error(f, f"EML: la entidad {alias} no existe en {bo}")
                continue
            # FIELDS ( ... ) de la entidad o, tras BY \_x, de la entidad destino
            for by, campos in re.findall(r"(?:BY\s+\\(_\w+)\s+)?(?:UPDATE\s+|CREATE\s+(?:BY\s+\\_\w+\s+)?)?FIELDS\s*\(([^)]*)\)", trozo, re.I):
                destino = ent.vista
                m = re.search(r"CREATE\s+BY\s+\\(_\w+)\s+FIELDS", trozo, re.I)
                asoc = by or (m.group(1) if m and f"FIELDS ({campos})".replace(" ", "") in trozo.replace(" ", "")[trozo.replace(" ", "").find("CREATEBY"):] else None)
                if asoc:
                    destino = b._destino(ent, asoc) or destino
                for campo in campos.split():
                    if campo not in campos_de(destino):
                        error(f, f"EML: {campo} no esta en {destino}")
            for accion in re.findall(r"EXECUTE\s+(\w+)", trozo, re.I):
                if accion not in ent.acciones:
                    error(f, f"EML: la accion {accion} no existe en {alias}")
    # %action-X, %element-X: existen en algun BO de la clase
    bo_clase = re.findall(r"ENTITIES\s+OF\s+(\w+)", texto, re.I)
    acciones = set().union(*[e.acciones for bo in bo_clase if bdef_de_bo(bo)
                              for e in bdef_de_bo(bo).entidades.values()]) if bo_clase else set()
    campos_bo = set().union(*[campos_de(e.vista) for bo in bo_clase if bdef_de_bo(bo)
                              for e in bdef_de_bo(bo).entidades.values()]) if bo_clase else set()
    for accion in re.findall(r"%action-(\w+)", texto):
        if accion not in acciones | {"Edit", "Activate", "Discard", "Resume", "Prepare"}:
            error(f, f"%action-{accion} no existe")
    for campo in re.findall(r"%element-(\w+)", texto):
        if campos_bo and campo not in campos_bo:
            error(f, f"%element-{campo} no existe")


# ---------- proyecciones y metadata extensions ----------

for v in VISTAS.values():
    if v.base:
        base = campos_de(v.base)
        if not base:
            error(v.fichero, f"la vista base {v.base} no existe")
        texto = sin_comentarios(v.fichero.read_text())
        cuerpo = texto[texto.index("{") + 1: texto.rindex("}")]
        for campo in v.campos:
            # campos propios (no los que vienen por ruta, que llevan alias)
            if re.search(rf"^\s*(?:key\s+)?{campo}\s*[,}}]?\s*$", cuerpo, re.M) and campo not in base:
                error(v.fichero, f"{campo} no esta en {v.base}")

for f in SRC.rglob("*.ddlx.asddlxs"):
    texto = sin_comentarios(f.read_text())
    m = re.search(r"annotate\s+(?:entity|view)\s+(\w+)", texto, re.I)
    campos = campos_de(m.group(1)) if m else set()
    if not campos:
        error(f, f"anota una vista que no existe ({m.group(1) if m else '?'})")
        continue
    cuerpo = texto[texto.index("{", m.end()) + 1: texto.rindex("}")]
    sin_anot = re.sub(r"@[\w.]+\s*:\s*(\[(?:[^\[\]]|\[[^\]]*\])*\]|\{[^}]*\}|'[^']*'|[\w#.]+)", "", cuerpo)
    for campo in re.findall(r"(\w+)\s*;", sin_anot):
        if campo not in campos:
            error(f, f"{campo} no esta en {m.group(1)}")
    for accion in re.findall(r"dataAction\s*:\s*'(\w+)'", texto):
        if not any(accion in e.acciones for b in BDEFS.values() for e in b.entidades.values()):
            error(f, f"la accion {accion} no existe")


if errores:
    print("\n".join(errores))
    print(f"comprobar_rap: {len(errores)} error(es)")
    sys.exit(1)
print(f"comprobar_rap: 0 errores ({len(VISTAS)} vistas, {len(BDEFS)} BDEF)")
