"""
Reproject MSC-77 (980077) geometries from mggt_asu into local geodb (EPSG:4326).

Transform uses spatial_ref_sys.proj4text (same pipeline as approval.work_layers.geom_to_wgs84_sql).
mggt_asu is read-only; only geodb is updated.
"""

from __future__ import annotations

from collections.abc import Iterable, Iterator, Sequence
from dataclasses import dataclass
from typing import Any

from approval.work_layers import geom_to_wgs84_sql
from django.db import connections, transaction
from psycopg2.extras import execute_values

QGIS_ALIAS = "qgis"
GEODB_ALIAS = "default"

RZD_ATTR_COLUMNS: tuple[str, ...] = (
    "fid",
    "changeauth",
    "changedate",
    "comment_",
    "createdate",
    "doc",
    "guid",
    "name",
    "shape_area",
    "shape_length",
    "text",
    "zonelineco",
    "zonerhagui",
    "zonerhanum",
)


@dataclass(frozen=True)
class GeomSyncSpec:
    """Key-matched geometry UPDATE from mggt_asu → geodb."""

    name: str
    geodb_table: str
    geodb_key: str
    geodb_key_cast: str  # SQL cast for VALUES key column, e.g. int / text
    source_schema: str
    source_table: str  # quoted if needed, without schema
    source_key_sql: str  # expression selected as key (already typed for geodb)
    source_geom_sql: str  # geometry column expression (quoted ident)
    as_multipolygon: bool = True


SPECS: dict[str, GeomSyncSpec] = {
    "pass_objects": GeomSyncSpec(
        name="pass_objects",
        geodb_table="pass_objects",
        geodb_key="rootid",
        geodb_key_cast="int",
        source_schema="master",
        source_table='"YardPoly"',
        source_key_sql='"RootId"::int',
        source_geom_sql='"Geometry"',
    ),
    "odh": GeomSyncSpec(
        name="odh",
        geodb_table="odh",
        geodb_key="rootid",
        geodb_key_cast="int",
        source_schema="master",
        source_table='"OdhPoly"',
        source_key_sql='"RootId"::int',
        source_geom_sql='"Geometry"',
    ),
    "ozn": GeomSyncSpec(
        name="ozn",
        geodb_table="ozn",
        geodb_key="rootid",
        geodb_key_cast="text",
        source_schema="master",
        source_table='"OznPoly"',
        source_key_sql='"RootId"::text',
        source_geom_sql='"Geometry"',
        as_multipolygon=False,
    ),
    "dgi": GeomSyncSpec(
        name="dgi",
        geodb_table="dgi",
        geodb_key="descr",
        geodb_key_cast="text",
        source_schema="gis",
        source_table="dgi",
        source_key_sql="descr",
        source_geom_sql='"Geometry"',
    ),
    "oozt": GeomSyncSpec(
        name="oozt",
        geodb_table="oozt",
        geodb_key="nomer1",
        geodb_key_cast="text",
        source_schema="gis",
        source_table="oozt",
        source_key_sql="nomer1",
        source_geom_sql='"Geometry"',
    ),
}

TABLE_ORDER: tuple[str, ...] = (
    "pass_objects",
    "odh",
    "ozn",
    "dgi",
    "oozt",
    "rzd",
)


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def wgs84_geom_sql(geom_expr: str, *, as_multipolygon: bool) -> str:
    """MSC-77 geom → WGS84 MultiPolygon (or Geometry) expression."""
    transformed = geom_to_wgs84_sql(f"ST_Force2D({geom_expr})")
    valid = f"ST_MakeValid({transformed})"
    if as_multipolygon:
        body = f"ST_Multi(ST_CollectionExtract({valid}, 3))"
    else:
        body = valid
    return f"ST_SetSRID({body}, 4326)"


def _source_from_where(spec: GeomSyncSpec) -> str:
    return f"""
        FROM {spec.source_schema}.{spec.source_table} t
        WHERE {spec.source_geom_sql} IS NOT NULL
          AND NOT ST_IsEmpty({spec.source_geom_sql})
          AND {spec.source_key_sql} IS NOT NULL
    """


def _source_select_sql(spec: GeomSyncSpec) -> str:
    geom = wgs84_geom_sql(spec.source_geom_sql, as_multipolygon=spec.as_multipolygon)
    return f"""
        SELECT
            {spec.source_key_sql} AS jk,
            ST_AsEWKB({geom}) AS ewkb
        {_source_from_where(spec)}
    """


def _source_count_sql(spec: GeomSyncSpec) -> str:
    return f"SELECT count(*) {_source_from_where(spec)}"


def _update_sql(spec: GeomSyncSpec) -> str:
    tbl = _quote_ident(spec.geodb_table)
    jk = _quote_ident(spec.geodb_key)
    return f"""
        UPDATE {tbl} AS t
        SET geom = ST_GeomFromEWKB(v.ewkb)
        FROM (VALUES %s) AS v(jk, ewkb)
        WHERE t.{jk} = v.jk::{spec.geodb_key_cast}
    """


def _mark_qgis_session_read_only(cursor) -> None:
    """Best-effort read-only; this module never issues writes on qgis."""
    try:
        cursor.execute("SET default_transaction_read_only = on")
    except Exception:
        pass


def _iter_source_batches(
    select_sql: str,
    *,
    batch_size: int,
) -> Iterator[list[tuple[Any, Any]]]:
    """Stream (key, ewkb) rows from mggt_asu via a server-side cursor."""
    conn = connections[QGIS_ALIAS]
    conn.ensure_connection()
    raw = conn.connection
    assert raw is not None

    # Named cursors require a real transaction (autocommit off).
    old_autocommit = raw.autocommit
    if old_autocommit:
        raw.autocommit = False
    try:
        with raw.cursor() as setup:
            _mark_qgis_session_read_only(setup)
        named = raw.cursor(name="reproject_geodb_stream")
        named.itersize = batch_size
        try:
            named.execute(select_sql)
            while True:
                rows = named.fetchmany(batch_size)
                if not rows:
                    break
                batch = [
                    (jk, ewkb)
                    for jk, ewkb in rows
                    if jk is not None and ewkb is not None
                ]
                if batch:
                    yield batch
        finally:
            named.close()
            raw.rollback()
    finally:
        raw.autocommit = old_autocommit


def _flush_update_batch(spec: GeomSyncSpec, batch: Sequence[tuple[Any, Any]]) -> int:
    if not batch:
        return 0
    sql = _update_sql(spec)
    with transaction.atomic(using=GEODB_ALIAS):
        with connections[GEODB_ALIAS].cursor() as dj_cursor:
            raw_cursor = getattr(dj_cursor, "cursor", dj_cursor)
            execute_values(
                raw_cursor,
                sql,
                batch,
                template="(%s, %s)",
                page_size=len(batch),
            )
    return len(batch)


def sync_keyed_table(
    name: str,
    *,
    dry_run: bool = False,
    batch_size: int = 2000,
) -> dict[str, int]:
    """
    Update geodb.<table>.geom from matching mggt_asu rows.

    Returns counts: source_rows, updated, geodb_keys (dry-run only).
    """
    spec = SPECS[name]

    if dry_run:
        with connections[QGIS_ALIAS].cursor() as cursor:
            _mark_qgis_session_read_only(cursor)
            cursor.execute(_source_count_sql(spec))
            source_rows = int(cursor.fetchone()[0])
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute(
                f"""
                SELECT count(DISTINCT {_quote_ident(spec.geodb_key)})
                FROM {_quote_ident(spec.geodb_table)}
                WHERE {_quote_ident(spec.geodb_key)} IS NOT NULL
                """
            )
            geodb_keys = int(cursor.fetchone()[0])
        return {
            "source_rows": source_rows,
            "geodb_keys": geodb_keys,
            "updated": 0,
        }

    source_rows = 0
    updated = 0
    for batch in _iter_source_batches(_source_select_sql(spec), batch_size=batch_size):
        source_rows += len(batch)
        updated += _flush_update_batch(spec, batch)
        if source_rows == len(batch) or source_rows % (batch_size * 5) < len(batch):
            print(
                f"  … {spec.name}: streamed={source_rows} updated={updated}",
                flush=True,
            )

    return {"source_rows": source_rows, "updated": updated, "geodb_keys": 0}


def _rzd_select_sql() -> str:
    geom = wgs84_geom_sql("geometry", as_multipolygon=True)
    attrs = ", ".join(
        "fid::int AS fid" if col == "fid" else col for col in RZD_ATTR_COLUMNS
    )
    return f"""
        SELECT {attrs}, ST_AsEWKB({geom}) AS ewkb
        FROM gis.railroadline
        WHERE geometry IS NOT NULL
          AND NOT ST_IsEmpty(geometry)
    """


def sync_rzd(*, dry_run: bool = False) -> dict[str, int]:
    """Replace geodb.rzd with reprojected gis.railroadline rows."""
    select_sql = _rzd_select_sql()

    with connections[QGIS_ALIAS].cursor() as cursor:
        _mark_qgis_session_read_only(cursor)
        cursor.execute(select_sql)
        rows = cursor.fetchall()

    if dry_run:
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute("SELECT count(*) FROM rzd")
            geodb_count = int(cursor.fetchone()[0])
        return {
            "source_rows": len(rows),
            "geodb_keys": geodb_count,
            "updated": 0,
        }

    attr_n = len(RZD_ATTR_COLUMNS)
    col_list = ", ".join(_quote_ident(c) for c in RZD_ATTR_COLUMNS) + ", geom"
    value_placeholders = ", ".join(["%s"] * attr_n + ["ST_GeomFromEWKB(%s)"])
    insert_sql = f"INSERT INTO rzd ({col_list}) VALUES ({value_placeholders})"

    with transaction.atomic(using=GEODB_ALIAS):
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute("TRUNCATE TABLE rzd RESTART IDENTITY")
            for row in rows:
                cursor.execute(insert_sql, list(row))

    return {"source_rows": len(rows), "updated": len(rows), "geodb_keys": 0}


def resolve_tables(table: str | None) -> list[str]:
    if not table:
        return list(TABLE_ORDER)
    if table not in SPECS and table != "rzd":
        known = ", ".join(TABLE_ORDER)
        raise ValueError(f"Unknown table {table!r}. Known: {known}")
    return [table]


def run_reproject(
    tables: Iterable[str],
    *,
    dry_run: bool = False,
    batch_size: int = 2000,
) -> list[tuple[str, dict[str, int]]]:
    results: list[tuple[str, dict[str, int]]] = []
    for name in tables:
        if name == "rzd":
            stats = sync_rzd(dry_run=dry_run)
        else:
            stats = sync_keyed_table(name, dry_run=dry_run, batch_size=batch_size)
        results.append((name, stats))
    return results
