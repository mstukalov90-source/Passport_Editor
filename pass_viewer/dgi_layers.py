"""DGI sub-layer classification by zemlepol_dgi, short_sobstv_rr, and rent."""

from __future__ import annotations

DGI_MOSCOW_MARKER_CITY = "город Москва"
DGI_MOSCOW_MARKER_NO_DATA = "Нет данных о правообладателе"
DGI_RENOVATION_MARKER = "МОСКОВСКИЙ ФОНД РЕНОВАЦИИ ЖИЛОЙ ЗАСТРОЙКИ"

# Map panel / auto-remove / deferred load keys: renovation + ownership × rent.
DGI_LAYER_KEYS = (
    "dgi_moscow_rent",
    "dgi_moscow_no_rent",
    "dgi_private_rent",
    "dgi_private_no_rent",
    "dgi_renovation",
)

DGI_LAYER_SPECS = {
    "dgi_moscow_rent": {"ownership": "moscow", "with_rent": True},
    "dgi_moscow_no_rent": {"ownership": "moscow", "with_rent": False},
    "dgi_private_rent": {"ownership": "private", "with_rent": True},
    "dgi_private_no_rent": {"ownership": "private", "with_rent": False},
    "dgi_renovation": {"kind": "renovation"},
}


def _sql_ilike_contains_fragment(literal: str) -> str:
    escaped = str(literal).replace("'", "''")
    # ``%%`` — literal ``%`` for ILIKE; psycopg2 otherwise treats ``%`` as a param placeholder.
    return f"'%%{escaped}%%'"


def _sql_ilike_exact_fragment(literal: str) -> str:
    escaped = str(literal).replace("'", "''")
    return f"'{escaped}'"


def build_dgi_renovation_match_sql(zemlepol_col_expr: str) -> str:
    """Boolean SQL expression: zemlepol matches renovation fund marker."""
    marker = _sql_ilike_exact_fragment(DGI_RENOVATION_MARKER)
    return f"(TRIM(BOTH FROM COALESCE({zemlepol_col_expr}, '')) ILIKE {marker})"


def build_dgi_renovation_extra_sql(zemlepol_col_expr: str, *, is_renovation: bool) -> str:
    """
    SQL fragment starting with `` AND `` for zemlepol_dgi column expression.
    is_renovation True → match fund marker; False → exclude it (null/other).
    """
    match = build_dgi_renovation_match_sql(zemlepol_col_expr)
    if is_renovation:
        return f" AND ({match})"
    return f" AND (NOT ({match}))"


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


def build_dgi_rent_extra_sql(rent_col_expr: str, with_rent: bool) -> str:
    """
    SQL fragment starting with `` AND `` for rent column expression, e.g. ``t."rent"``.
    with_rent True → rent IS TRUE; False → rent IS NOT TRUE (false or null).
    """
    if with_rent:
        return f" AND ({rent_col_expr} IS TRUE)"
    return f" AND ({rent_col_expr} IS NOT TRUE)"


def normalize_dgi_aprove_payload(raw, username: str) -> dict | None:
    """Parse client ``dgi_aprove`` for jsonb storage after >10% private overlap consent."""
    if not isinstance(raw, dict):
        return None
    try:
        percent = float(raw.get("percent"))
    except (TypeError, ValueError):
        return None
    if percent <= 10:
        return None
    ownership = str(raw.get("ownership") or "private").strip().lower()
    if ownership != "private":
        return None
    approved_at = str(raw.get("approved_at") or "").strip()
    if not approved_at:
        approved_at = None
    return {
        "approved_at": approved_at,
        "percent": round(percent, 2),
        "user": str(username or "").strip(),
        "ownership": ownership,
    }


def finalize_dgi_aprove_record(record: dict | None, username: str) -> dict | None:
    """Apply server-side username and timestamp defaults before DB write."""
    if not record:
        return None
    from django.utils import timezone
    from django.utils.dateparse import parse_datetime

    approved_at = record.get("approved_at")
    if approved_at:
        parsed = parse_datetime(str(approved_at))
        if parsed is not None:
            if timezone.is_naive(parsed):
                approved_at = timezone.make_aware(
                    parsed, timezone.get_current_timezone()
                ).isoformat()
            else:
                approved_at = parsed.isoformat()
        else:
            approved_at = timezone.now().isoformat()
    else:
        approved_at = timezone.now().isoformat()
    return {
        "approved_at": approved_at,
        "percent": record.get("percent"),
        "user": str(username or "").strip(),
        "ownership": record.get("ownership") or "private",
    }


def classify_dgi_ownership(short_sobstv_rr: str | None) -> str:
    """Return ``moscow`` or ``private`` for a raw short_sobstv_rr value (client/tests)."""
    raw = str(short_sobstv_rr or "").strip()
    if not raw:
        return "private"
    lower = raw.lower()
    if DGI_MOSCOW_MARKER_CITY.lower() in lower or DGI_MOSCOW_MARKER_NO_DATA.lower() in lower:
        return "moscow"
    return "private"


def classify_dgi_renovation(zemlepol_dgi: str | None) -> bool:
    """True when zemlepol_dgi matches the renovation fund marker."""
    raw = str(zemlepol_dgi or "").strip()
    if not raw:
        return False
    return raw.casefold() == DGI_RENOVATION_MARKER.casefold()
