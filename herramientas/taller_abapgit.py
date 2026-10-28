#!/usr/bin/env python3
"""Genera los ficheros XML de abapGit del taller (docs/materiales/taller).

El codigo fuente se escribe a mano; este script solo crea los metadatos que abapGit
guarda junto a cada objeto:

- Clases, interfaces, vistas CDS, BDEF, metadata extensions, service definitions y
  controles de acceso: un .xml con su nombre y su descripcion (la primera linea de
  comentario o el @EndUserText.label).
- Tablas y estructuras: se escriben en tablas/*.tabl.ddl (el mismo DDL que se teclea
  en ADT) y aqui se traducen al .tabl.xml de src/ddic que entienden abapGit y abaplint.
- Paquetes: un package.devc.xml por carpeta de src/.

Uso: python3 herramientas/taller_abapgit.py
"""
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent / "docs" / "materiales" / "taller"
SRC = RAIZ / "src"
TABLAS = RAIZ / "tablas"

PAQUETES = {
    "": "Taller RuedaLibre (proyecto de ejemplo)",
    "ddic": "Taller - Tablas y estructuras",
    "cds": "Taller - Vistas CDS",
    "bus": "Taller - Reglas y comportamiento RAP",
    "srv": "Taller - Proyecciones y servicios",
    "test": "Taller - Clases de consola y datos de demo",
}

CABECERA = '<?xml version="1.0" encoding="utf-8"?>\n'


def envolver(serializador: str, cuerpo: str) -> str:
    return (f'{CABECERA}<abapGit version="v1.0.0" serializer="LCL_OBJECT_{serializador}" '
            f'serializer_version="v1.0.0">\n <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">\n'
            f'  <asx:values>\n{cuerpo}  </asx:values>\n </asx:abap>\n</abapGit>\n')


def limpiar(texto: str) -> str:
    return texto[:60].replace("&", "y").replace("<", "").replace(">", "")


def descripcion(fichero: Path) -> str:
    """La etiqueta @EndUserText.label o la primera linea de comentario del fuente."""
    texto = fichero.read_text(encoding="utf-8")
    m = re.search(r"@EndUserText\.label\s*:\s*'([^']*)'", texto)
    if m:
        return limpiar(m.group(1))
    for linea in texto.splitlines():
        linea = linea.strip()
        if linea.startswith('"') or linea.startswith("//"):
            return limpiar(linea.lstrip('"/').strip())
    return fichero.name.split(".")[0]


# ---------- clases e interfaces ----------

def xml_clase(nombre, texto, con_tests):
    tests = "    <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>\n" if con_tests else ""
    return envolver("CLAS", f"""   <VSEOCLASS>
    <CLSNAME>{nombre}</CLSNAME>
    <LANGU>S</LANGU>
    <DESCRIPT>{texto}</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
{tests}   </VSEOCLASS>
""")


def xml_interfaz(nombre, texto):
    return envolver("INTF", f"""   <VSEOINTERF>
    <CLSNAME>{nombre}</CLSNAME>
    <LANGU>S</LANGU>
    <DESCRIPT>{texto}</DESCRIPT>
    <EXPOSURE>2</EXPOSURE>
    <STATE>1</STATE>
    <UNICODE>X</UNICODE>
   </VSEOINTERF>
""")


# ---------- objetos de texto (CDS, BDEF...) ----------

def xml_ddls(nombre, texto, fuente):
    if "define abstract entity" in fuente:
        tipo = "A"
    elif "as projection on" in fuente:
        tipo = "P"
    else:
        tipo = "W"
    return envolver("DDLS", f"""   <DDLS>
    <DDLNAME>{nombre}</DDLNAME>
    <DDLANGUAGE>S</DDLANGUAGE>
    <DDTEXT>{texto}</DDTEXT>
    <SOURCE_TYPE>{tipo}</SOURCE_TYPE>
   </DDLS>
""")


def xml_simple(serializador, etiqueta, nombre, texto):
    return envolver(serializador, f"""   <{etiqueta}>
    <NAME>{nombre}</NAME>
    <DESCRIPTION>{texto}</DESCRIPTION>
    <LANGUAGE>S</LANGUAGE>
   </{etiqueta}>
""")


def xml_paquete(texto):
    return envolver("DEVC", f"""   <DEVC>
    <CTEXT>{texto}</CTEXT>
   </DEVC>
""")


# ---------- tablas ----------

TIPOS = {
    "clnt": ("CLNT", 3), "char": ("CHAR", None), "dec": ("DEC", None), "int4": ("INT4", 10),
    "int8": ("INT8", 19), "dats": ("DATS", 8), "tims": ("TIMS", 6), "string": ("STRG", 0),
    "rawstring": ("RSTR", 0), "cuky": ("CUKY", 5), "curr": ("CURR", None), "numc": ("NUMC", None),
}


def campos_de_ddl(texto):
    """Devuelve (etiqueta, [campos]) leyendo un 'define table' o un 'define structure'."""
    etiqueta = re.search(r"@EndUserText\.label\s*:\s*'([^']*)'", texto).group(1)
    cuerpo = texto[texto.index("{") + 1: texto.rindex("}")]
    campos = []
    for linea in cuerpo.splitlines():
        linea = linea.split("//")[0].strip().rstrip(";").strip()
        if not linea:
            continue
        m = re.match(r'(?:"?(%?\w+)"?\s*:\s*)?include\s+(\w+)$', linea)
        if m:
            campos.append({"include": m.group(2).upper(), "grupo": (m.group(1) or "").upper()})
            continue
        m = re.match(r"(key\s+)?(\w+)\s*:\s*([\w.]+)(?:\((\d+)(?:,\s*(\d+))?\))?(\s+not null)?$", linea)
        if not m:
            raise ValueError(f"Linea no reconocida: {linea}")
        clave, nombre, tipo, leng, dec, notnull = m.groups()
        campo = {"nombre": nombre.upper(), "clave": bool(clave), "notnull": bool(notnull)}
        if tipo.startswith("abap."):
            interno, fijo = TIPOS[tipo[5:]]
            campo.update(datatype=interno, leng=int(leng) if leng else fijo, decimals=int(dec) if dec else 0)
        else:
            campo["rollname"] = tipo.upper()
        campos.append(campo)
    return etiqueta, campos


def xml_tabla(nombre, etiqueta, campos, estructura):
    filas = []
    for c in campos:
        if "include" in c:
            grupo = f"\n     <GROUPNAME>{c['grupo']}</GROUPNAME>" if c["grupo"] else ""
            filas.append(f"""    <DD03P>
     <FIELDNAME>.INCLUDE</FIELDNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <PRECFIELD>{c['include']}</PRECFIELD>
     <MASK>      S</MASK>
     <DDTEXT>Include</DDTEXT>
     <COMPTYPE>S</COMPTYPE>{grupo}
    </DD03P>""")
            continue
        partes = [f"     <FIELDNAME>{c['nombre']}</FIELDNAME>"]
        if c["clave"]:
            partes.append("     <KEYFLAG>X</KEYFLAG>")
        if "rollname" in c:
            partes += [f"     <ROLLNAME>{c['rollname']}</ROLLNAME>", "     <ADMINFIELD>0</ADMINFIELD>"]
            if c["notnull"]:
                partes.append("     <NOTNULL>X</NOTNULL>")
            partes.append("     <COMPTYPE>E</COMPTYPE>")
        else:
            partes += ["     <ADMINFIELD>0</ADMINFIELD>", f"     <DATATYPE>{c['datatype']}</DATATYPE>",
                       f"     <LENG>{c['leng']:06d}</LENG>"]
            if c["decimals"]:
                partes.append(f"     <DECIMALS>{c['decimals']:06d}</DECIMALS>")
            if c["notnull"]:
                partes.append("     <NOTNULL>X</NOTNULL>")
            partes.append(f"     <MASK>  {c['datatype']}</MASK>")
        filas.append("    <DD03P>\n" + "\n".join(partes) + "\n    </DD03P>")
    if estructura:
        dd02 = f"""   <DD02V>
    <TABNAME>{nombre}</TABNAME>
    <DDLANGUAGE>S</DDLANGUAGE>
    <TABCLASS>INTTAB</TABCLASS>
    <DDTEXT>{etiqueta}</DDTEXT>
   </DD02V>
"""
    else:
        dd02 = f"""   <DD02V>
    <TABNAME>{nombre}</TABNAME>
    <DDLANGUAGE>S</DDLANGUAGE>
    <TABCLASS>TRANSP</TABCLASS>
    <DDTEXT>{etiqueta}</DDTEXT>
    <CONTFLAG>A</CONTFLAG>
    <EXCLASS>1</EXCLASS>
   </DD02V>
"""
    return envolver("TABL", dd02 + "   <DD03P_TABLE>\n" + "\n".join(filas) + "\n   </DD03P_TABLE>\n")


def main():
    # Paquetes
    for carpeta, texto in PAQUETES.items():
        destino = SRC / carpeta
        destino.mkdir(parents=True, exist_ok=True)
        (destino / "package.devc.xml").write_text(xml_paquete(texto), encoding="utf-8")

    for fuente in sorted(SRC.rglob("*.clas.abap")):
        nombre = fuente.name.split(".")[0]
        con_tests = (fuente.parent / f"{nombre}.clas.testclasses.abap").exists()
        (fuente.parent / f"{nombre}.clas.xml").write_text(
            xml_clase(nombre.upper(), descripcion(fuente), con_tests), encoding="utf-8")
    for fuente in sorted(SRC.rglob("*.intf.abap")):
        nombre = fuente.name.split(".")[0]
        (fuente.parent / f"{nombre}.intf.xml").write_text(
            xml_interfaz(nombre.upper(), descripcion(fuente)), encoding="utf-8")
    for fuente in sorted(SRC.rglob("*.ddls.asddls")):
        nombre = fuente.name.split(".")[0]
        (fuente.parent / f"{nombre}.ddls.xml").write_text(
            xml_ddls(nombre.upper(), descripcion(fuente), fuente.read_text(encoding="utf-8")), encoding="utf-8")
    for patron, serializador, etiqueta in (("*.bdef.asbdef", "BDEF", "BDEF"),
                                           ("*.ddlx.asddlxs", "DDLX", "DDLX"),
                                           ("*.srvd.srvdsrv", "SRVD", "SRVD"),
                                           ("*.dcls.asdcls", "DCLS", "DCLS")):
        for fuente in sorted(SRC.rglob(patron)):
            nombre = fuente.name.split(".")[0]
            tipo = fuente.name.split(".")[1]
            (fuente.parent / f"{nombre}.{tipo}.xml").write_text(
                xml_simple(serializador, etiqueta, nombre.upper(), descripcion(fuente)), encoding="utf-8")

    for ddl in sorted(TABLAS.glob("*.tabl.ddl")):
        nombre = ddl.name.split(".")[0]
        texto = ddl.read_text(encoding="utf-8")
        etiqueta, campos = campos_de_ddl(texto)
        (SRC / "ddic" / f"{nombre}.tabl.xml").write_text(
            xml_tabla(nombre.upper(), etiqueta, campos, "define structure" in texto), encoding="utf-8")
    print("XML generados en", SRC)


if __name__ == "__main__":
    main()
