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
