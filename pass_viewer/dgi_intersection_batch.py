"""
Daily batch: compute DGI intersection percents for all GIS passports/requests
and store a snapshot in public.dgi_intersection_results.
"""

from __future__ import annotations

import json
import logging
from collections.abc import Callable
from datetime import datetime
from typing import Any

from django.conf import settings
from django.db import connection, transaction
from django.utils import timezone

logger = logging.getLogger(__name__)

RESULTS_TABLE = "dgi_intersection_results"


def compute_pct_sum(
    moscow_rent: float,
    private_rent: float,
    private_no_rent: float,
) -> float:
    """Same formula as PassViewer.buildCheckDgiModalHtml (utils.js)."""
    return round(
        float(moscow_rent or 0) + float(private_rent or 0) + float(private_no_rent or 0),
        2,
    )


def percents_dict_to_row_fields(percents: dict[str, Any]) -> dict[str, float]:
    moscow_rent = round(float(percents.get("dgi_moscow_rent") or 0), 2)
    private_rent = round(float(percents.get("dgi_private_rent") or 0), 2)
    private_no_rent = round(float(percents.get("dgi_private_no_rent") or 0), 2)
    moscow_no_rent = round(float(percents.get("dgi_moscow_no_rent") or 0), 2)
    return {
        "pct_moscow_rent": moscow_rent,
        "pct_private_rent": private_rent,
        "pct_private_no_rent": private_no_rent,
        "pct_sum": compute_pct_sum(moscow_rent, private_rent, private_no_rent),
        "pct_moscow_no_rent": moscow_no_rent,
        "pct_renew": round(float(percents.get("renew") or 0), 2),
        "pct_oozt": round(float(percents.get("oozt") or 0), 2),
        "pct_rzd": round(float(percents.get("rzd") or 0), 2),
    }


def row_to_modal_payload(row: dict[str, Any]) -> dict[str, Any]:
    """Build payload compatible with PassViewer.buildCheckDgiModalHtml / check_dgi_intersections."""
    moscow_rent = float(row.get("pct_moscow_rent") or 0)
    private_rent = float(row.get("pct_private_rent") or 0)
    private_no_rent = float(row.get("pct_private_no_rent") or 0)
    moscow_no_rent = float(row.get("pct_moscow_no_rent") or 0)
    renew = float(row.get("pct_renew") or 0)
    oozt = float(row.get("pct_oozt") or 0)
    rzd = float(row.get("pct_rzd") or 0)
    pct_sum = float(row.get("pct_sum") or 0)
    moscow = round(moscow_rent + moscow_no_rent, 2)
    private = round(private_rent + private_no_rent, 2)
    intersects = pct_sum > 0 or moscow_no_rent > 0 or renew > 0 or oozt > 0 or rzd > 0
    return {
        "ok": True,
        "intersects": intersects,
        "percent_moscow": moscow,
        "percent_private": private,
        "percent_moscow_rent": moscow_rent,
        "percent_moscow_no_rent": moscow_no_rent,
        "percent_private_rent": private_rent,
        "percent_private_no_rent": private_no_rent,
        "percent_renew": renew,
        "percent_oozt": oozt,
        "percent_rzd": rzd,
        "intersects_moscow": moscow > 0,
        "intersects_private": private > 0,
        "percent_sum": pct_sum,
    }


def _quote_ident(name: str) -> str:
    return '"' + str(name).replace('"', '""') + '"'


def _table_exists(cursor, table_name: str) -> bool:
    cursor.execute(
        """
        SELECT EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = %s
        )
        """,
        [table_name],
    )
    return bool(cursor.fetchone()[0])


def _column_exists(cursor, table_name: str, column_name: str) -> bool:
    cursor.execute(
        """
        SELECT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = %s
              AND lower(column_name) = lower(%s)
        )
        """,
        [table_name, column_name],
    )
    return bool(cursor.fetchone()[0])


def _resolve_column_name(cursor, table_name: str, preferred: str) -> str:
    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = %s
        """,
        [table_name],
    )
    columns = [row[0] for row in cursor.fetchall()]
    lowered = {c.lower(): c for c in columns}
    hit = lowered.get(preferred.lower())
    if hit:
        return hit
    raise ValueError(f"Column {preferred!r} not found on {table_name}")


def _gis_municipal_table_specs() -> list[tuple[str, str, list[str]]]:
    from pass_viewer.views import _gis_municipal_table_specs as specs

    return list(specs())


def _classify_object_kind(rootid: str | None, request_id: str | None) -> str | None:
    root = str(rootid or "").strip()
    req = str(request_id or "").strip()
    if root:
        return "passport"
    if req:
        return "request"
    return None


def _iter_gis_objects(
    *,
    limit: int | None = None,
    rayon_ilike: str | None = None,
) -> list[dict[str, Any]]:
    """Load GIS objects with geometry for batch compute.

    If ``rayon_ilike`` is set (e.g. ``%амосков%``), only objects intersecting
    matching ``hood.rayon`` polygons are included.
    """
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD

    items: list[dict[str, Any]] = []
    with connection.cursor() as cursor:
        if rayon_ilike:
            if not _table_exists(cursor, "hood"):
                raise ValueError('Table "hood" is missing; cannot filter by rayon.')
            cursor.execute(
                "SELECT count(*) FROM hood WHERE rayon ILIKE %s",
                [rayon_ilike],
            )
            if int(cursor.fetchone()[0] or 0) == 0:
                raise ValueError(f"No hood rows match rayon ILIKE {rayon_ilike!r}.")

        for source_label, table, owner_field_candidates in _gis_municipal_table_specs():
            if not _table_exists(cursor, table):
                continue
            if not _column_exists(cursor, table, rootid_field) or not _column_exists(
                cursor, table, name_field
            ):
                continue
            if not _column_exists(cursor, table, geom_field_pref):
                continue

            rootid_col = _resolve_column_name(cursor, table, rootid_field)
            name_col = _resolve_column_name(cursor, table, name_field)
            geom_col = _resolve_column_name(cursor, table, geom_field_pref)

            owner_expr = "NULL::text AS owner_legal_person_id"
            for candidate in owner_field_candidates:
                if _column_exists(cursor, table, candidate):
                    owner_col = _resolve_column_name(cursor, table, candidate)
                    owner_expr = f"t.{_quote_ident(owner_col)}::text AS owner_legal_person_id"
                    break

            from_sql = f"FROM {_quote_ident(table)} t"
            params: list[Any] = []
            if rayon_ilike:
                from_sql = (
                    f"FROM {_quote_ident(table)} t "
                    f"JOIN hood h ON h.rayon ILIKE %s "
                    f"AND t.{_quote_ident(geom_col)} && h.geom "
                    f"AND ST_Intersects(ST_MakeValid(t.{_quote_ident(geom_col)}), h.geom)"
                )
                params.append(rayon_ilike)

            if _column_exists(cursor, table, request_id_field_pref):
                rid_col = _resolve_column_name(cursor, table, request_id_field_pref)
                query = (
                    f"SELECT t.{_quote_ident(rootid_col)}::text, t.{_quote_ident(name_col)}::text, "
                    f"t.{_quote_ident(rid_col)}::text AS request_id, {owner_expr}, "
                    f"ST_AsGeoJSON(ST_Force2D(t.{_quote_ident(geom_col)}))::text "
                    f"{from_sql} "
                    f"WHERE t.{_quote_ident(geom_col)} IS NOT NULL "
                    f"AND NOT ST_IsEmpty(t.{_quote_ident(geom_col)}) "
                    f"AND ("
                    f"  (t.{_quote_ident(rootid_col)} IS NOT NULL AND BTRIM(t.{_quote_ident(rootid_col)}::text) <> '')"
                    f"  OR (t.{_quote_ident(rid_col)} IS NOT NULL AND BTRIM(t.{_quote_ident(rid_col)}::text) <> '')"
                    f")"
                )
            else:
                query = (
                    f"SELECT t.{_quote_ident(rootid_col)}::text, t.{_quote_ident(name_col)}::text, "
                    f"''::text AS request_id, {owner_expr}, "
                    f"ST_AsGeoJSON(ST_Force2D(t.{_quote_ident(geom_col)}))::text "
                    f"{from_sql} "
                    f"WHERE t.{_quote_ident(geom_col)} IS NOT NULL "
                    f"AND NOT ST_IsEmpty(t.{_quote_ident(geom_col)}) "
                    f"AND t.{_quote_ident(rootid_col)} IS NOT NULL "
                    f"AND BTRIM(t.{_quote_ident(rootid_col)}::text) <> ''"
                )

            if limit is not None:
                remaining = limit - len(items)
                if remaining <= 0:
                    break
                query += f" LIMIT {int(remaining)}"

            cursor.execute(query, params)
            for row in cursor.fetchall():
                rootid = (row[0] or "").strip() or None
                name = row[1] or ""
                request_id = (row[2] or "").strip() or None
                owner_id = (row[3] or "").strip() or None
                geom_json = (row[4] or "").strip()
                kind = _classify_object_kind(rootid, request_id)
                if not kind or not geom_json:
                    continue
                try:
                    geometry = json.loads(geom_json)
                except json.JSONDecodeError:
                    continue
                items.append(
                    {
                        "table_name": table,
                        "source_label": source_label,
                        "object_kind": kind,
                        "rootid": rootid,
                        "request_id": request_id,
                        "name": name,
                        "owner_legal_person_id": owner_id,
                        "geometry": geometry,
                    }
                )
                if limit is not None and len(items) >= limit:
                    return items
    return items


def _replace_results(rows: list[tuple[Any, ...]], *, calculated_at: datetime) -> int:
    insert_sql = f"""
        INSERT INTO {RESULTS_TABLE} (
            table_name, source_label, object_kind, rootid, request_id, name,
            owner_legal_person_id,
            pct_moscow_rent, pct_private_rent, pct_private_no_rent, pct_sum,
            pct_moscow_no_rent, pct_renew, pct_oozt, pct_rzd,
            calculated_at
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
    """
    with transaction.atomic():
        with connection.cursor() as cursor:
            if not _table_exists(cursor, RESULTS_TABLE):
                raise ValueError(
                    f'Table "{RESULTS_TABLE}" is missing; run migrations first.'
                )
            cursor.execute(f"TRUNCATE TABLE {RESULTS_TABLE} RESTART IDENTITY")
            for row in rows:
                cursor.execute(insert_sql, list(row))
    return len(rows)


def run_dgi_intersection_batch(
    *,
    limit: int | None = None,
    rayon: str | None = None,
    progress: Callable[[str], None] | None = None,
) -> dict[str, int]:
    """
    Recompute DGI intersection percents and replace dgi_intersection_results.

    ``rayon`` — optional hood.rayon substring (ILIKE %rayon%).
    Returns counts: scanned, stored, errors.
    """
    # Import here to avoid circular import at module load.
    from pass_viewer.views import _get_dgi_intersection_percents_split

    log = progress or (lambda _msg: None)
    rayon_ilike = None
    if rayon:
        text = str(rayon).strip()
        if text:
            rayon_ilike = text if "%" in text else f"%{text}%"
            log(f"Filtering by hood.rayon ILIKE {rayon_ilike!r}")

    objects = _iter_gis_objects(limit=limit, rayon_ilike=rayon_ilike)
    log(f"Loaded {len(objects)} GIS objects with geometry")

    calculated_at = timezone.now()
    rows: list[tuple[Any, ...]] = []
    errors = 0

    for idx, obj in enumerate(objects, start=1):
        try:
            percents = _get_dgi_intersection_percents_split(obj["geometry"])
            fields = percents_dict_to_row_fields(percents)
        except Exception:
            errors += 1
            logger.exception(
                "dgi intersection batch failed for %s rootid=%s request_id=%s",
                obj.get("table_name"),
                obj.get("rootid"),
                obj.get("request_id"),
            )
            continue

        rows.append(
            (
                obj["table_name"],
                obj["source_label"],
                obj["object_kind"],
                obj["rootid"],
                obj["request_id"],
                obj["name"],
                obj["owner_legal_person_id"],
                fields["pct_moscow_rent"],
                fields["pct_private_rent"],
                fields["pct_private_no_rent"],
                fields["pct_sum"],
                fields["pct_moscow_no_rent"],
                fields["pct_renew"],
                fields["pct_oozt"],
                fields["pct_rzd"],
                calculated_at,
            )
        )
        if idx == 1 or idx % 50 == 0 or idx == len(objects):
            log(f"  … computed {idx}/{len(objects)} (errors={errors})")

    stored = _replace_results(rows, calculated_at=calculated_at)
    log(f"Stored {stored} rows in {RESULTS_TABLE} (errors={errors})")
    return {"scanned": len(objects), "stored": stored, "errors": errors}


def serialize_result_row(row: dict[str, Any]) -> dict[str, Any]:
    """JSON-friendly row for the list API."""
    calculated_at = row.get("calculated_at")
    if isinstance(calculated_at, datetime):
        calculated_at_str = calculated_at.isoformat()
    else:
        calculated_at_str = str(calculated_at or "")
    return {
        "id": row.get("id"),
        "table_name": row.get("table_name") or "",
        "source_label": row.get("source_label") or "",
        "object_kind": row.get("object_kind") or "",
        "rootid": row.get("rootid") or "",
        "request_id": row.get("request_id") or "",
        "name": row.get("name") or "",
        "owner_legal_person_id": row.get("owner_legal_person_id") or "",
        "pct_moscow_rent": float(row.get("pct_moscow_rent") or 0),
        "pct_private_rent": float(row.get("pct_private_rent") or 0),
        "pct_private_no_rent": float(row.get("pct_private_no_rent") or 0),
        "pct_sum": float(row.get("pct_sum") or 0),
        "pct_moscow_no_rent": float(row.get("pct_moscow_no_rent") or 0),
        "pct_renew": float(row.get("pct_renew") or 0),
        "pct_oozt": float(row.get("pct_oozt") or 0),
        "pct_rzd": float(row.get("pct_rzd") or 0),
        "calculated_at": calculated_at_str,
        "modal": row_to_modal_payload(row),
    }


def list_dgi_intersection_results_for_scope(
    scope,
    *,
    has_sup_hood: bool = False,
) -> list[dict[str, Any]]:
    """
    Return stored results filtered to the same objects the user sees on home.
    Sorted by pct_sum DESC.
    """
    from pass_viewer.roles import (
        FILTER_DEPARTMENT,
        FILTER_NONE,
        FILTER_OWNER,
        ROLE_DEP_PLUS,
        ROLE_MGGT,
        ROLE_SUP,
    )

    with connection.cursor() as cursor:
        if not _table_exists(cursor, RESULTS_TABLE):
            return []

    # Prefer owner SQL filter when it matches home semantics.
    where_sql = ""
    params: list[Any] = []

    if scope.role == ROLE_MGGT:
        where_sql = "WHERE object_kind = 'request'"
    elif scope.role == ROLE_SUP:
        if not has_sup_hood:
            return []
        from pass_viewer.views import _load_home_objects_for_scope

        owned, _ = _load_home_objects_for_scope(scope, has_sup_hood=True)
        keys = {
            (
                (item.get("source_label") or "").strip(),
                (item.get("rootid") or "").strip(),
                (item.get("request_id") or "").strip(),
            )
            for item in owned
        }
        return _fetch_results_matching_keys(keys)
    elif scope.role == ROLE_DEP_PLUS:
        if not scope.owner_ids:
            return []
        where_sql = "WHERE owner_legal_person_id = ANY(%s)"
        params = [list(scope.owner_ids)]
    elif scope.filter_field == FILTER_DEPARTMENT:
        if not scope.owner_id:
            return []
        from pass_viewer.views import _get_owned_objects

        owned = _get_owned_objects(
            scope.owner_id,
            filter_mode=FILTER_DEPARTMENT,
            row_limit=10000,
        )
        keys = {
            (
                (item.get("source_label") or "").strip(),
                (item.get("rootid") or "").strip(),
                (item.get("request_id") or "").strip(),
            )
            for item in owned
        }
        return _fetch_results_matching_keys(keys)
    elif scope.filter_field == FILTER_OWNER:
        if not scope.owner_id:
            return []
        where_sql = "WHERE owner_legal_person_id = %s"
        params = [scope.owner_id]
    elif scope.filter_field == FILTER_NONE:
        where_sql = ""
    else:
        if not scope.owner_id:
            return []
        where_sql = "WHERE owner_legal_person_id = %s"
        params = [scope.owner_id]

    return _fetch_results(where_sql, params)


def _fetch_results(where_sql: str, params: list[Any]) -> list[dict[str, Any]]:
    query = f"""
        SELECT
            id, table_name, source_label, object_kind, rootid, request_id, name,
            owner_legal_person_id,
            pct_moscow_rent, pct_private_rent, pct_private_no_rent, pct_sum,
            pct_moscow_no_rent, pct_renew, pct_oozt, pct_rzd, calculated_at
        FROM {RESULTS_TABLE}
        {where_sql}
        ORDER BY pct_sum DESC, name ASC NULLS LAST, rootid ASC NULLS LAST
    """
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        columns = [col[0] for col in cursor.description]
        return [serialize_result_row(dict(zip(columns, row, strict=True))) for row in cursor.fetchall()]


def _fetch_results_matching_keys(
    keys: set[tuple[str, str, str]],
) -> list[dict[str, Any]]:
    if not keys:
        return []
    all_rows = _fetch_results("", [])
    matched = [
        row
        for row in all_rows
        if (
            (row.get("source_label") or "").strip(),
            (row.get("rootid") or "").strip(),
            (row.get("request_id") or "").strip(),
        )
        in keys
    ]
    return matched
