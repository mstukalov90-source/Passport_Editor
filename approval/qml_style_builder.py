"""Build Leaflet-ready style manifest from QGIS QML layer styles."""

from __future__ import annotations

import json
import re
import shutil
import unicodedata
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

from django.conf import settings

from .work_layer_labels import load_work_layer_labels

TABLE_QML_ALIASES: dict[str, str] = {
    "PlanarStructurePoly": "PlanarStructure",
}

GEOMETRY_TYPES = {
    "0": "point",
    "1": "line",
    "2": "polygon",
}

_FILTER_EQ_RE = re.compile(
    r'^\s*"([^"]+)"\s*=\s*\'((?:\'\'|[^\'])*)\'\s*$',
    re.IGNORECASE,
)
_FILTER_NULL_RE = re.compile(r'^\s*"([^"]+)"\s+is\s+null\s*$', re.IGNORECASE)
_FILTER_NOT_NULL_RE = re.compile(r'^\s*"([^"]+)"\s+is\s+not\s+null\s*$', re.IGNORECASE)

_COLOR_RE = re.compile(
    r"^(?P<r>\d+),(?P<g>\d+),(?P<b>\d+),(?P<a>\d+)",
)


def _qml_dir() -> Path:
    return Path(getattr(settings, "APPROVAL_LAYER_STYLES_QML_DIR", settings.BASE_DIR / "approval" / "layer_styles" / "qml"))


def _manifest_path() -> Path:
    return Path(
        getattr(
            settings,
            "APPROVAL_LAYER_STYLES_MANIFEST",
            settings.BASE_DIR / "approval" / "static" / "approval" / "work_layer_styles.json",
        )
    )


def _svg_source_dir() -> Path:
    return Path(getattr(settings, "APPROVAL_LAYER_STYLES_SVG_SOURCE", settings.BASE_DIR / "approval" / "layer_styles" / "svg"))


def _svg_static_dir() -> Path:
    return Path(
        getattr(
            settings,
            "APPROVAL_LAYER_STYLES_SVG_STATIC",
            settings.BASE_DIR / "approval" / "static" / "approval" / "icons" / "svg",
        )
    )


def _svg_index_path() -> Path:
    return Path(
        getattr(
            settings,
            "APPROVAL_LAYER_STYLES_SVG_INDEX",
            settings.BASE_DIR / "approval" / "static" / "approval" / "svg_index.json",
        )
    )


def _option_value(layer_el: ET.Element, name: str) -> str | None:
    for opt in layer_el.findall(".//Option"):
        if opt.get("name") == name and opt.get("type") == "QString":
            return opt.get("value")
    return None


def parse_qgis_color(raw: str | None) -> dict[str, Any] | None:
    if not raw:
        return None
    match = _COLOR_RE.match(raw.strip())
    if not match:
        return None
    r = int(match.group("r"))
    g = int(match.group("g"))
    b = int(match.group("b"))
    a = int(match.group("a"))
    return {
        "color": f"#{r:02x}{g:02x}{b:02x}",
        "opacity": round(a / 255, 3),
    }


def parse_filter(filter_text: str | None) -> dict[str, Any] | None:
    if not filter_text:
        return None
    text = filter_text.strip()
    if not text:
        return None

    match = _FILTER_EQ_RE.match(text)
    if match:
        return {
            "type": "eq",
            "field": match.group(1),
            "value": match.group(2).replace("''", "'"),
        }

    match = _FILTER_NULL_RE.match(text)
    if match:
        return {"type": "null", "field": match.group(1)}

    match = _FILTER_NOT_NULL_RE.match(text)
    if match:
        return {"type": "not_null", "field": match.group(1)}

    return None


def _mm_to_px(value: str | None, default: float = 2.0) -> float:
    if not value:
        return default
    try:
        return max(0.5, round(float(value) * 3.78, 2))
    except (TypeError, ValueError):
        return default


def _map_unit_to_px(value: str | None, default: float = 2.0) -> float:
    if not value:
        return default
    try:
        return max(0.5, round(float(value) * 4.0, 2))
    except (TypeError, ValueError):
        return default


def _width_to_px(value: str | None, unit: str | None, default: float = 2.0) -> float:
    if unit == "MM":
        return _mm_to_px(value, default)
    return _map_unit_to_px(value, default)


def _parse_simple_line(layer_el: ET.Element) -> dict[str, Any]:
    style: dict[str, Any] = {"kind": "line"}
    color = parse_qgis_color(_option_value(layer_el, "line_color"))
    if color:
        style["color"] = color["color"]
        style["opacity"] = color["opacity"]
    unit = _option_value(layer_el, "line_width_unit")
    style["weight"] = _width_to_px(_option_value(layer_el, "line_width"), unit, 2.0)
    if _option_value(layer_el, "use_custom_dash") == "1":
        dash = _option_value(layer_el, "customdash")
        if dash:
            style["dashArray"] = dash.replace(";", ", ")
    return style


def _parse_simple_fill(layer_el: ET.Element) -> dict[str, Any]:
    style: dict[str, Any] = {"kind": "polygon"}
    fill = parse_qgis_color(_option_value(layer_el, "color"))
    if fill:
        style["fillColor"] = fill["color"]
        style["fillOpacity"] = fill["opacity"]
    outline = parse_qgis_color(_option_value(layer_el, "outline_color"))
    if outline:
        style["color"] = outline["color"]
        style["opacity"] = outline["opacity"]
    unit = _option_value(layer_el, "outline_width_unit")
    style["weight"] = _width_to_px(_option_value(layer_el, "outline_width"), unit, 1.0)
    fill_style = _option_value(layer_el, "style")
    if fill_style and fill_style != "solid":
        style["fillPattern"] = fill_style
    return style


def _parse_simple_marker(layer_el: ET.Element) -> dict[str, Any]:
    style: dict[str, Any] = {"kind": "point"}
    fill = parse_qgis_color(_option_value(layer_el, "color"))
    if fill:
        style["fillColor"] = fill["color"]
        style["fillOpacity"] = fill["opacity"]
    outline = parse_qgis_color(_option_value(layer_el, "outline_color"))
    if outline:
        style["color"] = outline["color"]
    unit = _option_value(layer_el, "size_unit")
    style["radius"] = _width_to_px(_option_value(layer_el, "size"), unit, 5.0)
    marker_name = _option_value(layer_el, "name")
    if marker_name:
        style["markerShape"] = marker_name
    return style


def _extract_svg_field(layer_el: ET.Element) -> str | None:
    for opt in layer_el.findall(".//Option[@name='expression']"):
        expr = opt.get("value") or ""
        field_match = re.search(r'&quot;([A-Za-z_][A-Za-z0-9_]*)&quot;', expr)
        if field_match:
            field = field_match.group(1)
            if field not in {"Svg", "SvgMarkerPath", "Svg_HAPoint", "Svg_VAPoint"}:
                continue
            if field in {"Svg_HAPoint", "Svg_VAPoint"}:
                continue
            return field
    return None


def _svg_from_expression(expr: str | None, qml_dir: Path) -> str | None:
    if not expr:
        return None
    for match in re.finditer(r"'/([^']+\.svg)'", expr):
        normalized = _normalize_svg_path(match.group(1), qml_dir)
        if normalized:
            return normalized
    for match in re.finditer(r"/([^/']+\.svg)", expr):
        basename = match.group(1)
        if (_svg_source_dir() / basename).is_file():
            return basename
    return None


def _normalize_svg_path(raw: str | None, qml_dir: Path) -> str | None:
    if not raw:
        return None
    text = raw.strip()
    if not text.lower().endswith(".svg"):
        return None
    if "MggtAsu" in text or "@MggtAsu" in text:
        return None
    basename = Path(text.replace("\\", "/")).name
    if (_svg_source_dir() / basename).is_file():
        return basename
    candidate = qml_dir / "svg" / basename
    if candidate.is_file():
        return basename
    parts = text.replace("\\", "/").split("/svg/")
    if len(parts) > 1:
        tail = parts[-1].lstrip("/")
        if (_svg_source_dir() / tail).is_file():
            return tail
    return None


def _parse_svg_marker(layer_el: ET.Element, qml_dir: Path) -> dict[str, Any]:
    style: dict[str, Any] = {"kind": "point"}
    fill = parse_qgis_color(_option_value(layer_el, "color"))
    if fill:
        style["fillColor"] = fill["color"]
    unit = _option_value(layer_el, "size_unit")
    style["iconSize"] = _width_to_px(_option_value(layer_el, "size"), unit, 18.0)
    svg_field = _extract_svg_field(layer_el)
    if svg_field:
        style["svgField"] = svg_field
    svg_path = _normalize_svg_path(_option_value(layer_el, "name"), qml_dir)
    if not svg_path:
        for opt in layer_el.findall(".//Option[@name='expression']"):
            svg_path = _svg_from_expression(opt.get("value"), qml_dir)
            if svg_path:
                break
    if svg_path:
        style["svg"] = svg_path
    return style


def _parse_symbol(symbol_el: ET.Element, qml_dir: Path) -> dict[str, Any]:
    symbol_type = symbol_el.get("type", "")
    merged: dict[str, Any] = {"kind": symbol_type or "unknown"}
    uses_svg_marker = False
    for layer in symbol_el.findall("./layer"):
        layer_class = layer.get("class", "")
        if layer_class == "SimpleLine":
            merged.update(_parse_simple_line(layer))
        elif layer_class == "SimpleFill":
            merged.update(_parse_simple_fill(layer))
        elif layer_class == "SimpleMarker":
            merged.update(_parse_simple_marker(layer))
        elif layer_class == "SvgMarker":
            uses_svg_marker = True
            merged.update(_parse_svg_marker(layer, qml_dir))
    if uses_svg_marker:
        merged.setdefault("svgField", "Svg")
    return merged


def _is_vertex_rule(rule_el: ET.Element) -> bool:
    label = (rule_el.get("label") or "").strip().lower()
    if label == "вершины":
        return True
    filt = rule_el.get("filter") or ""
    return "fid" in filt.lower() and "is not null" in filt.lower()


def resolve_qml_path(table_name: str, qml_dir: Path | None = None) -> Path | None:
    directory = qml_dir or _qml_dir()
    candidates = [table_name, TABLE_QML_ALIASES.get(table_name, "")]
    for base in candidates:
        if not base:
            continue
        for prefix in ("WorkLayers_", "MasterLayers_"):
            path = directory / f"{prefix}{base}.qml"
            if path.is_file():
                return path
    return None


def parse_qml_file(path: Path) -> dict[str, Any]:
    root = ET.parse(path).getroot()
    qml_dir = path.parent
    geom_code = root.findtext("layerGeometryType")
    geometry = GEOMETRY_TYPES.get((geom_code or "").strip(), "polygon")

    renderer = root.find("renderer-v2")
    if renderer is None:
        return {"geometry": geometry, "rules": [], "fields": []}

    symbols: dict[str, dict[str, Any]] = {}
    symbols_parent = renderer.find("symbols")
    if symbols_parent is not None:
        for symbol_el in symbols_parent.findall("symbol"):
            symbol_id = symbol_el.get("name")
            if symbol_id is None:
                continue
            symbols[symbol_id] = _parse_symbol(symbol_el, qml_dir)

    rules: list[dict[str, Any]] = []
    fields: set[str] = set()
    default_rule_index: int | None = None

    rules_parent = renderer.find("rules")
    if rules_parent is not None:
        for rule_el in rules_parent.findall("rule"):
            if _is_vertex_rule(rule_el):
                continue
            label = (rule_el.get("label") or "").strip()
            filt = parse_filter(rule_el.get("filter"))
            symbol_id = rule_el.get("symbol")
            style = symbols.get(symbol_id or "", {})
            if not style:
                continue
            entry: dict[str, Any] = {"label": label, "style": style}
            if filt:
                entry["filter"] = filt
                fields.add(filt["field"])
            rules.append(entry)
            lower_label = label.lower()
            if default_rule_index is None and ("нет данных" in lower_label or filt and filt.get("type") == "null"):
                default_rule_index = len(rules) - 1

    elif renderer.get("type") == "singleSymbol":
        symbol_id = renderer.get("symbol") or "0"
        style = symbols.get(symbol_id, {})
        if style:
            label = path.stem.replace("WorkLayers_", "").replace("MasterLayers_", "")
            rules.append({"label": label, "style": style})
            default_rule_index = 0

    if default_rule_index is None and rules:
        default_rule_index = len(rules) - 1

    for rule in rules:
        style = rule.get("style", {})
        if style.get("svgField"):
            fields.add(style["svgField"])

    return {
        "geometry": geometry,
        "rules": rules,
        "fields": sorted(fields),
        "defaultRule": default_rule_index,
        "qmlFile": path.name,
    }


def collect_table_names() -> list[str]:
    labels = load_work_layer_labels()
    if labels:
        return sorted(labels.keys())
    qml_dir = _qml_dir()
    names: set[str] = set()
    for path in qml_dir.glob("WorkLayers_*.qml"):
        names.add(path.stem.replace("WorkLayers_", ""))
    return sorted(names)


def build_manifest(*, tables: list[str] | None = None) -> dict[str, Any]:
    labels = load_work_layer_labels()
    qml_dir = _qml_dir()
    manifest_tables: dict[str, Any] = {}
    target_tables = tables or collect_table_names()

    for table_name in target_tables:
        qml_path = resolve_qml_path(table_name, qml_dir)
        if not qml_path:
            continue
        parsed = parse_qml_file(qml_path)
        parsed["label"] = labels.get(table_name, table_name)
        manifest_tables[table_name] = parsed

    return {
        "version": 1,
        "tables": manifest_tables,
    }


def _collect_svg_references(manifest: dict[str, Any]) -> set[str]:
    refs: set[str] = set()
    for table in manifest.get("tables", {}).values():
        for rule in table.get("rules", []):
            svg = rule.get("style", {}).get("svg")
            if svg:
                refs.add(svg)
    return refs


def _index_key_variants(relative_path: str) -> list[str]:
    keys = [relative_path]
    basename = Path(relative_path).name
    if basename not in keys:
        keys.append(basename)
    for value in (basename, relative_path):
        normalized = unicodedata.normalize("NFC", value)
        if normalized not in keys:
            keys.append(normalized)
    return keys


def build_svg_index(relative_paths: list[str] | None = None) -> dict[str, str]:
    source = _svg_source_dir()
    if relative_paths is None:
        if not source.is_dir():
            return {}
        relative_paths = sorted(path.relative_to(source).as_posix() for path in source.rglob("*.svg"))

    index: dict[str, str] = {}
    for rel_path in relative_paths:
        for key in _index_key_variants(rel_path):
            index[key] = rel_path
    return index


def sync_svg_static_tree(*, clean: bool = True) -> list[str]:
    source = _svg_source_dir()
    target = _svg_static_dir()
    if clean and target.exists():
        shutil.rmtree(target)
    target.mkdir(parents=True, exist_ok=True)

    copied: list[str] = []
    if not source.is_dir():
        return copied

    for src in sorted(source.rglob("*.svg")):
        rel = src.relative_to(source)
        dest = target / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        copied.append(rel.as_posix())
    return copied


def write_svg_index(index: dict[str, str] | None = None, *, relative_paths: list[str] | None = None) -> Path:
    data = index if index is not None else build_svg_index(relative_paths)
    path = _svg_index_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def load_svg_index() -> dict[str, str]:
    path = _svg_index_path()
    if not path.is_file():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def copy_referenced_svgs(manifest: dict[str, Any], *, clean: bool = True) -> list[str]:
    """Backward-compatible alias for sync_svg_static_tree."""
    return sync_svg_static_tree(clean=clean)


def write_manifest(manifest: dict[str, Any] | None = None, *, copy_svgs: bool = True) -> Path:
    data = manifest or build_manifest()
    path = _manifest_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    if copy_svgs:
        copied_paths = sync_svg_static_tree(clean=True)
        write_svg_index(relative_paths=copied_paths)
    return path


def load_manifest() -> dict[str, Any]:
    path = _manifest_path()
    if not path.is_file():
        return {"version": 1, "tables": {}}
    return json.loads(path.read_text(encoding="utf-8"))


def _hex_to_rgba(hex_color: str, opacity: float = 1.0) -> str:
    text = (hex_color or "").strip()
    if not text.startswith("#"):
        return hex_color
    raw = text[1:]
    if len(raw) == 3:
        raw = "".join(ch * 2 for ch in raw)
    if len(raw) != 6:
        return hex_color
    try:
        r = int(raw[0:2], 16)
        g = int(raw[2:4], 16)
        b = int(raw[4:6], 16)
    except ValueError:
        return hex_color
    alpha = max(0.0, min(1.0, float(opacity)))
    return f"rgba({r}, {g}, {b}, {alpha})"


def default_swatch_style(table_name: str, manifest: dict[str, Any] | None = None) -> dict[str, str]:
    data = manifest or load_manifest()
    table = data.get("tables", {}).get(table_name, {})
    rules = table.get("rules") or []
    default_idx = table.get("defaultRule")
    rule = None
    if isinstance(default_idx, int) and 0 <= default_idx < len(rules):
        rule = rules[default_idx]
    elif rules:
        rule = rules[-1]
    style = (rule or {}).get("style", {})
    kind = style.get("kind", "")
    if kind in {"line", "point"}:
        color = style.get("color") or style.get("fillColor") or "#64748b"
        return {"borderColor": color, "background": color}
    fill = style.get("fillColor") or "#94a3b8"
    fill_opacity = style.get("fillOpacity", 0.55)
    stroke = style.get("color") or fill
    swatch: dict[str, str] = {
        "borderColor": stroke,
        "background": _hex_to_rgba(fill, fill_opacity),
    }
    if style.get("dashArray"):
        swatch["borderStyle"] = "dashed"
    return swatch
