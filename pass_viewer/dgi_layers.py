"""DGI sub-layer classification by short_sobstv_rr (moscow vs private ownership)."""

from __future__ import annotations

DGI_MOSCOW_MARKER_CITY = "город Москва"
DGI_MOSCOW_MARKER_NO_DATA = "Нет данных о правообладателе"


def _sql_ilike_contains_fragment(literal: str) -> str:
    escaped = str(literal).replace("'", "''")
    # ``%%`` — literal ``%`` for ILIKE; psycopg2 otherwise treats ``%`` as a param placeholder.
    return f"'%%{escaped}%%'"


def build_dgi_ownership_extra_sql(short_sobstv_col_expr: str, ownership: str) -> str:
    """
    SQL fragment starting with `` AND `` for table alias column expression, e.g. ``t."short_sobstv_rr"``.
    ownership: ``moscow`` | ``private``
    """
    p_city = _sql_ilike_contains_fragment(DGI_MOSCOW_MARKER_CITY)
    p_nodata = _sql_ilike_contains_fragment(DGI_MOSCOW_MARKER_NO_DATA)
    moscow_match = f"({short_sobstv_col_expr} ILIKE {p_city} OR {short_sobstv_col_expr} ILIKE {p_nodata})"
    if ownership == "moscow":
        return f" AND ({short_sobstv_col_expr} IS NOT NULL AND ({moscow_match}))"
    return f" AND ({short_sobstv_col_expr} IS NULL OR NOT ({moscow_match}))"


def classify_dgi_ownership(short_sobstv_rr: str | None) -> str:
    """Return ``moscow`` or ``private`` for a raw short_sobstv_rr value (client/tests)."""
    raw = str(short_sobstv_rr or "").strip()
    if not raw:
        return "private"
    lower = raw.lower()
    if DGI_MOSCOW_MARKER_CITY.lower() in lower or DGI_MOSCOW_MARKER_NO_DATA.lower() in lower:
        return "moscow"
    return "private"
