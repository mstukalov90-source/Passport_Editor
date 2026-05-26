"""
Stream GeoJSON FeatureCollections and batch-UPDATE date / type columns on GIS tables.

Uses ijson so multi-gigabyte files are not loaded into memory whole.
"""

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass
from typing import Any

import ijson
from django.db import connection, transaction
from psycopg2.extras import execute_values


@dataclass(frozen=True)
class TableSyncSpec:
    table: str
    join_column: str
    join_sql_type: str  # cast for VALUES row, e.g. int or text


SPECS = {
    "pass_objects": TableSyncSpec("pass_objects", "objectid", "int"),
    "odh": TableSyncSpec("odh", "objectid", "int"),
    "ozn": TableSyncSpec("ozn", "rootid", "text"),
}


def iter_geojson_features(path: str) -> Iterator[dict]:
    with open(path, "rb") as f:
        for feature in ijson.items(f, "features.item", use_float=True):
            if isinstance(feature, dict):
                yield feature


def pick_property(props: dict[str, Any], *candidates: str) -> Any:
    if not isinstance(props, dict):
        return None
    for c in candidates:
        if c in props:
            return props[c]
    lower = {str(k).lower(): k for k in props}
    for c in candidates:
        lk = c.lower()
        if lk in lower:
            return props[lower[lk]]
    return None


def as_ts_string(value: Any) -> str | None:
    if value is None:
        return None
    if isinstance(value, (dict, list)):
        return None
    s = str(value).strip()
    if not s:
        return None
    return s


def as_text(value: Any) -> str | None:
    if value is None:
        return None
    if isinstance(value, (dict, list)):
        return None
    s = str(value).strip()
    return s or None


def _join_value(spec: TableSyncSpec, props: dict[str, Any]) -> Any:
    if spec.join_column == "objectid":
        v = pick_property(props, "ObjectId", "objectid")
        if v is None:
            return None
        try:
            return int(v)
        except (TypeError, ValueError):
            return None
    if spec.join_column == "rootid":
        v = pick_property(props, "RootId", "rootid")
        if v is None:
            return None
        return str(v).strip() or None
    raise ValueError(f"Unsupported join column {spec.join_column!r}")


def _row_from_feature(spec: TableSyncSpec, feature: dict) -> tuple[Any, ...] | None:
    props = feature.get("properties") or {}
    if not isinstance(props, dict):
        props = {}
    join_val = _join_value(spec, props)
    if join_val is None:
        return None
    start = as_ts_string(pick_property(props, "StartDate", "startdate"))
    survey = as_ts_string(pick_property(props, "DateSurvey", "datesurvey"))
    ctype = as_text(pick_property(props, "CreateType", "createtype"))
    return (join_val, start, survey, ctype)


def _update_sql(spec: TableSyncSpec) -> str:
    tbl = spec.table
    jc = spec.join_column
    cast = spec.join_sql_type
    return f"""
        UPDATE {tbl} AS t
        SET
            startdate = v.sd::timestamptz,
            datesurvey = v.ds::timestamptz,
            createtype = v.ct::varchar
        FROM (VALUES %s) AS v(jk, sd, ds, ct)
        WHERE t.{jc} = v.jk::{cast}
    """


def _update_sql_ozn() -> str:
    # ozn.createtype is text, not varchar
    return """
        UPDATE ozn AS t
        SET
            startdate = v.sd::timestamptz,
            datesurvey = v.ds::timestamptz,
            createtype = v.ct::text
        FROM (VALUES %s) AS v(jk, sd, ds, ct)
        WHERE t.rootid = v.jk::text
    """


def sync_table(
    table: str,
    path: str,
    *,
    dry_run: bool = False,
    batch_size: int = 1000,
) -> tuple[int, int, int]:
    """
    Returns (features_seen, rows_batched, skipped_no_join_key).
    """
    spec = SPECS.get(table)
    if not spec:
        raise ValueError(f"Unknown table {table!r}; expected one of {sorted(SPECS)}")

    sql = _update_sql_ozn() if table == "ozn" else _update_sql(spec)
    template = "(%s, %s, %s, %s)"

    seen = 0
    skipped = 0
    batched = 0
    batch: list[tuple[Any, ...]] = []

    def flush_batch() -> None:
        nonlocal batch, batched
        if not batch or dry_run:
            batch = []
            return
        with transaction.atomic():
            with connection.cursor() as dj_cursor:
                # psycopg2.extras.execute_values needs the underlying DB-API cursor
                raw_cursor = getattr(dj_cursor, "cursor", dj_cursor)
                execute_values(
                    raw_cursor,
                    sql,
                    batch,
                    template=template,
                    page_size=len(batch),
                )
        batched += len(batch)
        batch = []

    for feature in iter_geojson_features(path):
        seen += 1
        row = _row_from_feature(spec, feature)
        if row is None:
            skipped += 1
            continue
        batch.append(row)
        if len(batch) >= batch_size:
            flush_batch()

    flush_batch()
    return seen, batched, skipped
