#!/usr/bin/env python3
"""Genera los diagramas relacionales (SVG) del ERP y del taller para los apuntes.

Uso:  python3 herramientas/generar_diagramas.py
Escribe docs/materiales/diagramas/erp_modelo.svg y taller_modelo.svg.

Cada modelo es una lista de tablas (columna de la rejilla, posicion vertical y
campos) y una lista de relaciones hijo -> padre. Las lineas van por los pasillos
entre columnas; si las tablas no estan en columnas vecinas, por debajo de todo.
No se dibujan los campos de administracion ni las tablas satelite.
"""
import os
from xml.sax.saxutils import escape

ANCHO = 250        # ancho de cada tabla
PASILLO = 110      # espacio entre columnas
FILA = 18          # alto de cada campo
CABECERA = 36      # alto de la cabecera de una tabla
SEP_V = 34         # espacio vertical entre tablas de la misma columna
MARGEN = 30

COLOR = {
    "raiz": "#1f5f8b",     # cabecera de una tabla raiz
    "hija": "#4f8a5b",     # cabecera de una tabla hija (composicion)
    "pk": "#b8860b",
    "fk": "#7a3e9d",
    "linea": "#555555",
    "fondo": "#ffffff",
    "borde": "#9aa5b1",
    "texto": "#1d2733",
    "tipo": "#6b7785",
}


class Tabla:
    def __init__(self, nombre, desc, col, campos, raiz=True):
        self.nombre, self.desc, self.col, self.raiz = nombre, desc, col, raiz
        # campos: (nombre, tipo, marca) con marca en "", "PK", "FK"
        self.campos = campos
        self.x = self.y = 0

    @property
    def alto(self):
        return CABECERA + FILA * len(self.campos) + 6

    def y_campo(self, nombre):
        for i, (n, _, _) in enumerate(self.campos):
            if n == nombre:
                return self.y + CABECERA + FILA * i + FILA / 2 + 2
        raise KeyError(f"{self.nombre}.{nombre}")


def colocar(tablas):
    por_col = {}
    for t in tablas:
        por_col.setdefault(t.col, []).append(t)
    for col, lista in por_col.items():
        y = MARGEN + 40
        for t in lista:
            t.x = MARGEN + col * (ANCHO + PASILLO)
            t.y = y
            y += t.alto + SEP_V
    fondo = max(t.y + t.alto for t in tablas)
    ancho = MARGEN * 2 + (max(t.col for t in tablas) + 1) * (ANCHO + PASILLO) - PASILLO
    return ancho, fondo


def dibujar(titulo, tablas, relaciones, nota):
    ancho, fondo = colocar(tablas)
    idx = {t.nombre: t for t in tablas}
    uso_pasillo = {}      # columna del pasillo (a la derecha de col) -> lineas ya puestas
    uso_fondo = [0]
    lineas = []

    def hueco(col):
        n = uso_pasillo.get(col, 0)
        uso_pasillo[col] = n + 1
        return MARGEN + col * (ANCHO + PASILLO) + ANCHO + 14 + n * 9

    for hijo, campo, padre, card_h, card_p in relaciones:
        h, p = idx[hijo], idx[padre]
        yh, yp = h.y_campo(campo), p.y_campo(p.campos[0][0])
        if p.col == h.col + 1 or p.col == h.col - 1 or p.col == h.col:
            if p.col > h.col:
                gx = hueco(h.col)
                xh, xp = h.x + ANCHO, p.x
            elif p.col < h.col:
                gx = hueco(p.col)
                xh, xp = h.x, p.x + ANCHO
            else:
                gx = hueco(h.col)
                xh, xp = h.x + ANCHO, p.x + ANCHO
            puntos = [(xh, yh), (gx, yh), (gx, yp), (xp, yp)]
        else:
            # Por debajo de todo
            yb = fondo + 24 + uso_fondo[0] * 10
            uso_fondo[0] += 1
            if p.col > h.col:
                g1, xh = hueco(h.col), h.x + ANCHO
                g2, xp = hueco(p.col - 1), p.x
            else:
                g1, xh = hueco(h.col - 1), h.x
                g2, xp = hueco(p.col), p.x + ANCHO
            puntos = [(xh, yh), (g1, yh), (g1, yb), (g2, yb), (g2, yp), (xp, yp)]
        lineas.append((puntos, card_h, card_p))

    alto = fondo + 40 + uso_fondo[0] * 10 + 70
    s = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{ancho}" height="{alto}" '
         f'viewBox="0 0 {ancho} {alto}" font-family="Helvetica, Arial, sans-serif">',
         f'<rect width="100%" height="100%" fill="{COLOR["fondo"]}"/>',
         f'<text x="{MARGEN}" y="{MARGEN + 8}" font-size="18" font-weight="bold" '
         f'fill="{COLOR["texto"]}">{escape(titulo)}</text>']

    for puntos, ch, cp in lineas:
        d = " ".join(f"{x:.0f},{y:.0f}" for x, y in puntos)
        s.append(f'<polyline points="{d}" fill="none" stroke="{COLOR["linea"]}" '
                 f'stroke-width="1.3" stroke-linejoin="round"/>')
        (x0, y0), (x1, _) = puntos[0], puntos[1]
        (xn, yn), (xm, _) = puntos[-1], puntos[-2]
        # Hijo: etiqueta junto a la tabla. Padre: junto al pasillo, para que
        # no se monten las de varias relaciones que llegan a la misma tabla.
        for (xa, ya, xt, anc, etiqueta) in (
                (x0, y0, x0 + (4 if x1 > x0 else -4), "start" if x1 > x0 else "end", ch),
                (xn, yn, xm + (3 if xn > xm else -3), "start" if xn > xm else "end", cp)):
            s.append(f'<circle cx="{xa:.0f}" cy="{ya:.0f}" r="2.5" fill="{COLOR["linea"]}"/>')
            s.append(f'<text x="{xt:.0f}" y="{ya - 4:.0f}" font-size="10" text-anchor="{anc}" '
                     f'fill="{COLOR["linea"]}">{escape(etiqueta)}</text>')

    for t in tablas:
        cab = COLOR["raiz"] if t.raiz else COLOR["hija"]
        s.append(f'<rect x="{t.x}" y="{t.y}" width="{ANCHO}" height="{t.alto}" rx="6" '
                 f'fill="{COLOR["fondo"]}" stroke="{COLOR["borde"]}"/>')
        s.append(f'<path d="M{t.x},{t.y + CABECERA} v-{CABECERA - 6} a6,6 0 0 1 6,-6 '
                 f'h{ANCHO - 12} a6,6 0 0 1 6,6 v{CABECERA - 6} z" fill="{cab}"/>')
        s.append(f'<text x="{t.x + 10}" y="{t.y + 16}" font-size="13" font-weight="bold" '
                 f'fill="#ffffff">{escape(t.nombre)}</text>')
        s.append(f'<text x="{t.x + 10}" y="{t.y + 30}" font-size="10" fill="#e8eef3">'
                 f'{escape(t.desc)}</text>')
        for i, (n, tipo, marca) in enumerate(t.campos):
            y = t.y + CABECERA + FILA * i + FILA / 2 + 6
            peso = "bold" if marca == "PK" else "normal"
            s.append(f'<text x="{t.x + 10}" y="{y:.0f}" font-size="11" font-weight="{peso}" '
                     f'fill="{COLOR["texto"]}">{escape(n)}</text>')
            s.append(f'<text x="{t.x + ANCHO - 34}" y="{y:.0f}" font-size="10" text-anchor="end" '
                     f'fill="{COLOR["tipo"]}">{escape(tipo)}</text>')
            if marca:
                s.append(f'<text x="{t.x + ANCHO - 8}" y="{y:.0f}" font-size="9" font-weight="bold" '
                         f'text-anchor="end" fill="{COLOR["pk" if marca == "PK" else "fk"]}">{marca}</text>')

    yl = alto - 46
    s.append(f'<rect x="{MARGEN}" y="{yl}" width="14" height="10" fill="{COLOR["raiz"]}"/>')
    s.append(f'<text x="{MARGEN + 20}" y="{yl + 9}" font-size="11" fill="{COLOR["texto"]}">'
             f'Tabla raiz de un objeto de negocio</text>')
    s.append(f'<rect x="{MARGEN + 230}" y="{yl}" width="14" height="10" fill="{COLOR["hija"]}"/>')
    s.append(f'<text x="{MARGEN + 250}" y="{yl + 9}" font-size="11" fill="{COLOR["texto"]}">'
             f'Tabla hija (composicion)</text>')
    s.append(f'<text x="{MARGEN + 430}" y="{yl + 9}" font-size="11" fill="{COLOR["texto"]}">'
             f'PK clave · FK referencia · N / 1 / 0..1 cardinalidad</text>')
    s.append(f'<text x="{MARGEN}" y="{yl + 28}" font-size="11" fill="{COLOR["tipo"]}">'
             f'{escape(nota)}</text>')
    s.append("</svg>")
    return "\n".join(s)


U = "uuid"


def erp():
    T = Tabla
    tablas = [
        T("zgor_presu_lin", "Lineas de presupuesto", 0, [
            ("linea_uuid", U, "PK"), ("presupuesto_uuid", U, "FK"), ("descripcion", "char 255", ""),
            ("uds", "int4", ""), ("precio", "dec 15,2", ""), ("total_linea", "dec 15,2", "")], raiz=False),
        T("zgor_presu_pv", "Proveedores del presupuesto", 0, [
            ("presu_prov_uuid", U, "PK"), ("presupuesto_uuid", U, "FK"), ("proveedor_uuid", U, "FK")], raiz=False),
        T("zgor_presu_es", "Especialistas del presupuesto", 0, [
            ("presu_esp_uuid", U, "PK"), ("presupuesto_uuid", U, "FK"), ("especialista_uuid", U, "FK")], raiz=False),
        T("zgor_presu", "Presupuestos", 1, [
            ("presupuesto_uuid", U, "PK"), ("presupuesto_id", "char 8", ""), ("fecha", "dats", ""),
            ("cliente_uuid", U, "FK"), ("obra_uuid", U, "FK"), ("nombre_cliente", "char 140", ""),
            ("nif", "char 12", ""), ("direccion", "char 120", ""), ("telf", "char 20", ""),
            ("iva", "dec 5,2", ""), ("estado", "char 15", ""), ("base_imponible", "dec 15,2", ""),
            ("cuota_iva", "dec 15,2", ""), ("total", "dec 15,2", "")]),
        T("zgor_cli", "Clientes", 1, [
            ("cliente_uuid", U, "PK"), ("cliente_id", "char 8", ""), ("nombre", "char 60", ""),
            ("apellidos", "char 80", ""), ("nif", "char 12", ""), ("direccion", "char 120", ""),
            ("cod_postal", "char 5", ""), ("telf", "char 20", "")]),
        T("zgor_obra", "Obras", 2, [
            ("obra_uuid", U, "PK"), ("obra_id", "char 8", ""), ("descripcion", "char 255", ""),
            ("cliente_uuid", U, "FK")]),
        T("zgor_gasto", "Ficha de gastos (1:1 con la obra)", 2, [
            ("gasto_uuid", U, "PK"), ("obra_uuid", U, "FK"), ("gasto_id", "char 8", ""),
            ("presupuesto_uuid", U, "FK"), ("direccion_obra", "char 120", ""), ("inicio_obra", "dats", ""),
            ("fin_obra", "dats", ""), ("solicitud_obra", "dats", ""), ("mandante", "boolean", ""),
            ("gestion_licencia", "boolean", ""), ("pago_icio", "boolean", "")], raiz=False),
        T("zgor_ing", "Ingresos (cobros)", 2, [
            ("ingreso_uuid", U, "PK"), ("ingreso_id", "char 8", ""), ("obra_uuid", U, "FK"),
            ("cliente_uuid", U, "FK"), ("nombre_obra", "char 255", ""), ("tipo", "char 30", ""),
            ("fecha", "dats", ""), ("documento", "char 20", ""), ("num_documento", "char 30", ""),
            ("importe", "dec 15,2", "")]),
        T("zgor_pt", "Partes de trabajo", 3, [
            ("parte_uuid", U, "PK"), ("fecha", "dats", ""), ("descripcion", "char 255", ""),
            ("obra_uuid", U, "FK"), ("horas_totales", "dec 7,2", ""), ("coste_total", "dec 15,2", "")]),
        T("zgor_pe", "Partes de especialista", 3, [
            ("parte_uuid", U, "PK"), ("obra_uuid", U, "FK"), ("especialista_uuid", U, "FK"),
            ("fecha", "dats", ""), ("descripcion", "char 255", ""), ("documento", "char 30", ""),
            ("importe", "dec 15,2", ""), ("estado_pago", "char 15", "")]),
        T("zgor_pp", "Partes de proveedor", 3, [
            ("parte_uuid", U, "PK"), ("obra_uuid", U, "FK"), ("proveedor_uuid", U, "FK"),
            ("fecha", "dats", ""), ("descripcion", "char 255", ""), ("documento", "char 30", ""),
            ("importe", "dec 15,2", ""), ("estado_pago", "char 15", "")]),
        T("zgor_pt_lin", "Lineas de parte de trabajo", 4, [
            ("linea_uuid", U, "PK"), ("parte_uuid", U, "FK"), ("trabajador_uuid", U, "FK"),
            ("horas", "dec 5,2", ""), ("coste_hora", "dec 15,2", ""), ("coste_subtotal", "dec 15,2", "")],
            raiz=False),
        T("zgor_trab", "Trabajadores", 4, [
            ("trabajador_uuid", U, "PK"), ("trabajador_id", "char 8", ""), ("tipo", "char 40", ""),
            ("nombre", "char 60", ""), ("apellido", "char 80", ""), ("telf", "char 20", ""),
            ("coste_hora_estandar", "dec 15,2", "")]),
        T("zgor_esp", "Especialistas", 4, [
            ("especialista_uuid", U, "PK"), ("especialista_id", "char 8", ""), ("tipo", "char 40", ""),
            ("ref", "char 30", ""), ("comunicacion_parte", "char 255", ""), ("nombre", "char 80", ""),
            ("observaciones", "char 255", ""), ("telf", "char 20", ""), ("correo", "char 80", ""),
            ("importe", "dec 15,2", "")]),
        T("zgor_prov", "Proveedores", 4, [
            ("proveedor_uuid", U, "PK"), ("proveedor_id", "char 8", ""), ("nombre", "char 80", ""),
            ("direccion", "char 120", ""), ("telf", "char 20", ""), ("correo", "char 80", ""),
            ("tipo", "char 40", ""), ("ref", "char 30", ""), ("documento", "char 20", ""),
            ("num_documento", "char 30", ""), ("base", "dec 15,2", ""), ("iva", "dec 5,2", ""),
            ("total", "dec 15,2", "")]),
        T("zgor_falta", "Faltas de trabajador", 5, [
            ("falta_uuid", U, "PK"), ("trabajador_uuid", U, "FK"), ("fecha_inicio", "dats", ""),
            ("fecha_fin", "dats", ""), ("tipo", "char 15", ""), ("motivo", "char 255", ""),
            ("dias", "int4", "")], raiz=False),
    ]
    rel = [
        ("zgor_presu_lin", "presupuesto_uuid", "zgor_presu", "N", "1"),
        ("zgor_presu_pv", "presupuesto_uuid", "zgor_presu", "N", "1"),
        ("zgor_presu_es", "presupuesto_uuid", "zgor_presu", "N", "1"),
        ("zgor_presu", "cliente_uuid", "zgor_cli", "N", "1"),
        ("zgor_presu", "obra_uuid", "zgor_obra", "N", "0..1"),
        ("zgor_obra", "cliente_uuid", "zgor_cli", "N", "0..1"),
        ("zgor_gasto", "obra_uuid", "zgor_obra", "0..1", "1"),
        ("zgor_gasto", "presupuesto_uuid", "zgor_presu", "N", "0..1"),
        ("zgor_ing", "obra_uuid", "zgor_obra", "N", "1"),
        ("zgor_ing", "cliente_uuid", "zgor_cli", "N", "0..1"),
        ("zgor_pt", "obra_uuid", "zgor_obra", "N", "1"),
        ("zgor_pe", "obra_uuid", "zgor_obra", "N", "1"),
        ("zgor_pp", "obra_uuid", "zgor_obra", "N", "1"),
        ("zgor_pt_lin", "parte_uuid", "zgor_pt", "N", "1"),
        ("zgor_pt_lin", "trabajador_uuid", "zgor_trab", "N", "1"),
        ("zgor_pe", "especialista_uuid", "zgor_esp", "N", "1"),
        ("zgor_pp", "proveedor_uuid", "zgor_prov", "N", "1"),
        ("zgor_falta", "trabajador_uuid", "zgor_trab", "N", "1"),
        ("zgor_presu_pv", "proveedor_uuid", "zgor_prov", "N", "1"),
        ("zgor_presu_es", "especialista_uuid", "zgor_esp", "N", "1"),
    ]
    nota = ("Todas las tablas llevan ademas client y los 5 campos de administracion. "
            "No se dibujan las 21 tablas satelite (_obs, _inc, _arc).")
    return dibujar("ERP de Obras y Reformas - modelo relacional (ZGOR)", tablas, rel, nota)


def taller():
    T = Tabla
    tablas = [
        T("ztl_prs_par", "Partidas de presupuesto", 0, [
            ("partida_uuid", U, "PK"), ("presupuesto_uuid", U, "FK"), ("concepto", "char 120", ""),
            ("cantidad", "int4", ""), ("precio_unitario", "dec 15,2", ""), ("importe_partida", "dec 15,2", "")],
            raiz=False),
        T("ztl_prs_dis", "Distribuidores previstos", 0, [
            ("prs_dis_uuid", U, "PK"), ("presupuesto_uuid", U, "FK"), ("distribuidor_uuid", U, "FK")],
            raiz=False),
        T("ztl_prs", "Presupuestos", 1, [
            ("presupuesto_uuid", U, "PK"), ("presupuesto_ref", "char 8", ""), ("fecha", "dats", ""),
            ("titular_uuid", U, "FK"), ("orden_uuid", U, "FK"), ("titular_nombre", "char 100", ""),
            ("titular_documento", "char 12", ""), ("impuesto", "dec 5,2", ""), ("situacion", "char 15", ""),
            ("neto", "dec 15,2", ""), ("cuota", "dec 15,2", ""), ("importe", "dec 15,2", "")]),
        T("ztl_tit", "Titulares", 1, [
            ("titular_uuid", U, "PK"), ("titular_ref", "char 8", ""), ("razon_social", "char 100", ""),
            ("documento_id", "char 12", ""), ("contacto", "char 20", ""), ("poblacion", "char 60", ""),
            ("cp", "char 5", "")]),
        T("ztl_orden", "Ordenes de reparacion", 2, [
            ("orden_uuid", U, "PK"), ("orden_ref", "char 8", ""), ("matricula", "char 10", ""),
            ("averia", "char 255", ""), ("titular_uuid", U, "FK")]),
        T("ztl_hco", "Hoja de costes (1:1 con la orden)", 2, [
            ("hoja_uuid", U, "PK"), ("orden_uuid", U, "FK"), ("hoja_ref", "char 8", ""),
            ("fecha_entrada", "dats", ""), ("fecha_entrega", "dats", ""), ("garantia", "boolean", "")],
            raiz=False),
        T("ztl_abo", "Abonos del titular", 2, [
            ("abono_uuid", U, "PK"), ("abono_ref", "char 8", ""), ("orden_uuid", U, "FK"),
            ("titular_uuid", U, "FK"), ("fecha", "dats", ""), ("cantidad_abonada", "dec 15,2", ""),
            ("medio_pago", "char 20", "")]),
        T("ztl_jor", "Registros de jornada", 3, [
            ("jornada_uuid", U, "PK"), ("orden_uuid", U, "FK"), ("dia", "dats", ""),
            ("trabajo", "char 255", ""), ("tiempo_total", "dec 7,2", ""), ("coste_total", "dec 15,2", "")]),
        T("ztl_alb", "Albaranes de recambios", 3, [
            ("albaran_uuid", U, "PK"), ("orden_uuid", U, "FK"), ("distribuidor_uuid", U, "FK"),
            ("fecha", "dats", ""), ("importe_neto", "dec 15,2", ""), ("liquidado", "boolean", "")]),
        T("ztl_fac", "Facturas de subcontrata", 3, [
            ("factura_uuid", U, "PK"), ("orden_uuid", U, "FK"), ("subcontrata_uuid", U, "FK"),
            ("fecha", "dats", ""), ("importe_neto", "dec 15,2", ""), ("liquidado", "boolean", "")]),
        T("ztl_jor_tra", "Tramos de la jornada", 4, [
            ("tramo_uuid", U, "PK"), ("jornada_uuid", U, "FK"), ("mecanico_uuid", U, "FK"),
            ("tiempo", "dec 5,2", ""), ("tarifa_aplicada", "dec 15,2", ""), ("coste_tramo", "dec 15,2", "")],
            raiz=False),
        T("ztl_mec", "Mecanicos", 4, [
            ("mecanico_uuid", U, "PK"), ("mecanico_ref", "char 8", ""), ("nombre", "char 60", ""),
            ("apellidos", "char 80", ""), ("categoria", "char 40", ""), ("tarifa_base", "dec 15,2", "")]),
        T("ztl_dis", "Distribuidores", 4, [
            ("distribuidor_uuid", U, "PK"), ("distribuidor_ref", "char 8", ""), ("nombre", "char 80", ""),
            ("neto", "dec 15,2", ""), ("impuesto", "dec 5,2", ""), ("bruto", "dec 15,2", "")]),
        T("ztl_sub", "Subcontratas", 4, [
            ("subcontrata_uuid", U, "PK"), ("subcontrata_ref", "char 8", ""), ("nombre", "char 80", ""),
            ("oficio", "char 40", ""), ("tarifa_referencia", "dec 15,2", "")]),
        T("ztl_aus", "Ausencias del mecanico", 5, [
            ("ausencia_uuid", U, "PK"), ("mecanico_uuid", U, "FK"), ("desde", "dats", ""),
            ("hasta", "dats", ""), ("motivo", "char 60", ""), ("jornadas", "int4", "")], raiz=False),
    ]
    rel = [
        ("ztl_prs_par", "presupuesto_uuid", "ztl_prs", "N", "1"),
        ("ztl_prs_dis", "presupuesto_uuid", "ztl_prs", "N", "1"),
        ("ztl_prs", "titular_uuid", "ztl_tit", "N", "1"),
        ("ztl_prs", "orden_uuid", "ztl_orden", "N", "0..1"),
        ("ztl_orden", "titular_uuid", "ztl_tit", "N", "1"),
        ("ztl_hco", "orden_uuid", "ztl_orden", "0..1", "1"),
        ("ztl_abo", "orden_uuid", "ztl_orden", "N", "1"),
        ("ztl_abo", "titular_uuid", "ztl_tit", "N", "1"),
        ("ztl_jor", "orden_uuid", "ztl_orden", "N", "1"),
        ("ztl_alb", "orden_uuid", "ztl_orden", "N", "1"),
        ("ztl_fac", "orden_uuid", "ztl_orden", "N", "1"),
        ("ztl_jor_tra", "jornada_uuid", "ztl_jor", "N", "1"),
        ("ztl_jor_tra", "mecanico_uuid", "ztl_mec", "N", "1"),
        ("ztl_alb", "distribuidor_uuid", "ztl_dis", "N", "1"),
        ("ztl_fac", "subcontrata_uuid", "ztl_sub", "N", "1"),
        ("ztl_aus", "mecanico_uuid", "ztl_mec", "N", "1"),
        ("ztl_prs_dis", "distribuidor_uuid", "ztl_dis", "N", "1"),
    ]
    nota = ("Todas las tablas llevan ademas client y los 5 campos de administracion. "
            "No se dibujan las tablas de notas, avisos y fotos (_not, _avi, _fot).")
    return dibujar("Taller RuedaLibre - modelo relacional (ZTL)", tablas, rel, nota)


def main():
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    destino = os.path.join(raiz, "docs", "materiales", "diagramas")
    os.makedirs(destino, exist_ok=True)
    for nombre, svg in (("erp_modelo.svg", erp()), ("taller_modelo.svg", taller())):
        with open(os.path.join(destino, nombre), "w", encoding="utf-8") as f:
            f.write(svg)
        print("escrito", os.path.join("docs", "materiales", "diagramas", nombre))


if __name__ == "__main__":
    main()
