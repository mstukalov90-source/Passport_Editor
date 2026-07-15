"""Parse Russian layer titles from create_work.sql COMMENT ON TABLE."""

from __future__ import annotations

import re
from functools import lru_cache
from pathlib import Path

from django.conf import settings

_COMMENT_RE = re.compile(
    r'COMMENT\s+ON\s+TABLE\s+"work"\."([^"]+)"\s+IS\s+\'((?:\'\'|[^\'])*)\'',
    re.IGNORECASE,
)

# topopassport CAD layers (not listed in create_work.sql work schema comments)
TOPOGRAPHY_LAYER_LABELS: dict[str, str] = {
    "topolines": "Линии топоосновы",
    "topopoint": "Точки топоосновы",
    "topotext": "Тексты топоосновы",
}


def _sql_path() -> Path:
    return Path(getattr(settings, "APPROVAL_LAYER_STYLES_SQL", settings.BASE_DIR / "approval" / "layer_styles" / "create_work.sql"))


@lru_cache(maxsize=1)
def load_work_layer_labels() -> dict[str, str]:
    path = _sql_path()
    if not path.is_file():
        return dict(TOPOGRAPHY_LAYER_LABELS)
    text = path.read_text(encoding="utf-8")
    labels: dict[str, str] = dict(TOPOGRAPHY_LAYER_LABELS)
    for match in _COMMENT_RE.finditer(text):
        table_name = match.group(1)
        title = match.group(2).replace("''", "'")
        labels[table_name] = title
    return labels


def work_layer_label(table_name: str) -> str:
    return load_work_layer_labels().get(table_name, table_name)
