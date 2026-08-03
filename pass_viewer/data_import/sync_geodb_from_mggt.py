"""
Full daily sync: mggt_asu (read-only) → geodb.

Keyed GIS tables: compare attrs + reprojected geometry; INSERT / UPDATE / DELETE.
pass_objects / odh / ozn rows with rootid IS NULL and non-empty request_id are kept.
rzd: full replace. ods_request: replace from master.bidregistry with status filter.
dgi: after attrs sync, recompute rent via set_dgi_rent.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable, Iterator

from django.db import connections, transaction
from psycopg2.extras import execute_values

from pass_viewer.data_import.dgi_rent import set_dgi_rent
from pass_viewer.data_import.json_loaders import ODS_REQUEST_COLUMNS
from pass_viewer.data_import.reproject_geodb_from_mggt import (
    GEODB_ALIAS,
    QGIS_ALIAS,
    SPECS,
    GeomSyncSpec,
    _mark_qgis_session_read_only,
    _quote_ident,
    sync_rzd,
    wgs84_geom_sql,
)

# Local-only / generated columns never overwritten from mggt_asu.
LOCAL_SKIP_COLUMNS: frozenset[str] = frozenset(
    {
        "id",
        "gid",
        "ogc_fid",
        "request_id",
        "created_at",
        "properties",
        "rent",
        "aprove",
        "approve",
        "short_sobstv_rr",
        "geom",
        "geometry",
    }
)

# geodb column (lowercase) → preferred source column names (case-sensitive candidates).
COLUMN_ALIASES: dict[str, dict[str, tuple[str, ...]]] = {
    "ozn": {
        "ownerlegalpersonalid": (
            "OwnerLegalPersonId",
            "ownerlegalpersonid",
            "OwnerLegalPersonalId",
        ),
        "rootid": ("RootId", "rootid"),
        "departmentlegalpersonid": ("DepartmentLegalPersonId", "departmentlegalpersonid"),
        "startdate": ("StartDate", "startdate"),
        "datesurvey": ("DateSurvey", "datesurvey"),
        "createtype": ("CreateType", "createtype"),
    },
    "pass_objects": {
        "rootid": ("RootId", "rootid"),
        "objectid": ("ObjectId", "objectid"),
        "startdate": ("StartDate", "startdate"),
        "datesurvey": ("DateSurvey", "datesurvey"),
        "createtype": ("CreateType", "createtype"),
        "ownerlegalpersonid": ("OwnerLegalPersonId", "ownerlegalpersonid"),
        "name": ("Name", "name"),
    },
    "odh": {
        "rootid": ("RootId", "rootid"),
        "objectid": ("ObjectId", "objectid"),
        "startdate": ("StartDate", "startdate"),
        "datesurvey": ("DateSurvey", "datesurvey"),
        "createtype": ("CreateType", "createtype"),
        "grbslegalpersonid": ("GrbsLegalPersonId", "grbslegalpersonid"),
        "name": ("Name", "name"),
    },
}

TABLES_PRESERVE_NULL_ROOTID_REQUEST: frozenset[str] = frozenset(
    {"pass_objects", "odh", "ozn"}
)

GIS_TABLE_ORDER: tuple[str, ...] = (
    "pass_objects",
    "odh",
    "ozn",
    "dgi",
    "oozt",
    "rzd",
)

FULL_TABLE_ORDER: tuple[str, ...] = GIS_TABLE_ORDER + ("ods_request",)

ODS_BIDREGISTRY_SCHEMA = "master"
ODS_BIDREGISTRY_TABLE_CANDIDATES: tuple[str, ...] = (
    "bidregistry",
    "BidRegistry",
    "bidregistry_view",
)

# Filter from product requirement (mggt_asu.master.bidregistry).
ODS_BIDREGISTRY_WHERE = """
    b."BrStatusName" <> 'Аннулирована'::text
    AND b."InspectionDatePlan" >= '2027-01-01 00:00:00'::timestamp without time zone
    AND b."ReasonName" <> '["Изменение/определение характеристик зеленых насаждений"]'::text
"""


@dataclass(frozen=True)
class AttrMapping:
    """One attribute column copied from source → geodb."""

    geodb_col: str
    source_col: str  # actual name in source (for quoting)
    typname: str


@dataclass(frozen=True)
class KeyedSyncPlan:
    spec: GeomSyncSpec
    attrs: tuple[AttrMapping, ...]
    source_geom_col: str


def _fetch_table_columns(
    alias: str,
    schema: str,
    table: str,
) -> list[dict[str, Any]]:
    """Return [{name, typname, skip_insert}] for schema.table."""
    with connections[alias].cursor() as cursor:
        if alias == QGIS_ALIAS:
            _mark_qgis_session_read_only(cursor)
        cursor.execute(
            """
            SELECT
                a.attname AS name,
                t.typname AS typname,
                a.attgenerated AS generated,
                a.attidentity AS identity,
                pg_get_expr(d.adbin, d.adrelid) AS default_expr
            FROM pg_attribute a
            JOIN pg_class c ON a.attrelid = c.oid
            JOIN pg_namespace n ON c.relnamespace = n.oid
            JOIN pg_type t ON a.atttypid = t.oid
            LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
            WHERE n.nspname = %s
              AND c.relname = %s
              AND a.attnum > 0
              AND NOT a.attisdropped
            ORDER BY a.attnum
            """,
            [schema, table.strip('"')],
        )
        rows = cursor.fetchall()
    result: list[dict[str, Any]] = []
    for name, typname, generated, identity, default_expr in rows:
        skip = (generated or "") == "s"
        if (identity or "") in ("a", "d"):
            skip = True
        if default_expr and "nextval(" in default_expr:
            skip = True
        result.append({"name": name, "typname": typname, "skip_insert": skip})
    return result


def _resolve_source_column(
    geodb_col: str,
    source_by_lower: dict[str, str],
    *,
    table_name: str,
) -> str | None:
    aliases = COLUMN_ALIASES.get(table_name, {}).get(geodb_col.lower(), ())
    for candidate in (geodb_col, *aliases):
        hit = source_by_lower.get(candidate.lower())
        if hit is not None:
            return hit
    return source_by_lower.get(geodb_col.lower())


def _pick_source_geom_column(source_cols: list[dict[str, Any]]) -> str:
    by_lower = {c["name"].lower(): c["name"] for c in source_cols}
    for candidate in ("Geometry", "geometry", "geom", "wkb_geometry"):
        if candidate.lower() in by_lower:
            return by_lower[candidate.lower()]
    raise ValueError("Source table has no geometry column (Geometry/geometry/geom).")


def build_keyed_sync_plan(spec: GeomSyncSpec) -> KeyedSyncPlan:
    """Introspect both DBs and map syncable attribute columns."""
    source_cols = _fetch_table_columns(
        QGIS_ALIAS, spec.source_schema, spec.source_table.strip('"')
    )
    geodb_cols = _fetch_table_columns(GEODB_ALIAS, "public", spec.geodb_table)
    source_by_lower = {c["name"].lower(): c["name"] for c in source_cols}
    source_geom = _pick_source_geom_column(source_cols)

    attrs: list[AttrMapping] = []
    for col in geodb_cols:
        name = col["name"]
        lower = name.lower()
        if col["skip_insert"] or lower in LOCAL_SKIP_COLUMNS:
            continue
        if lower == spec.geodb_key.lower():
            # Key is selected separately as jk.
            continue
        if col["typname"] == "geometry":
            continue
        src = _resolve_source_column(name, source_by_lower, table_name=spec.name)
        if src is None:
            continue
        attrs.append(AttrMapping(geodb_col=name, source_col=src, typname=col["typname"]))

    return KeyedSyncPlan(
        spec=spec,
        attrs=tuple(attrs),
        source_geom_col=source_geom,
    )


def _source_attr_select_sql(plan: KeyedSyncPlan) -> str:
    spec = plan.spec
    geom_expr = _quote_ident(plan.source_geom_col)
    wgs = wgs84_geom_sql(geom_expr, as_multipolygon=spec.as_multipolygon)
    attr_sql = ", ".join(
        f"t.{_quote_ident(a.source_col)} AS {_quote_ident('a_' + a.geodb_col)}"
        for a in plan.attrs
    )
    attr_part = f", {attr_sql}" if attr_sql else ""
    return f"""
        SELECT
            {spec.source_key_sql} AS jk
            {attr_part},
            ST_AsEWKB({wgs}) AS ewkb
        FROM {spec.source_schema}.{spec.source_table} t
        WHERE {geom_expr} IS NOT NULL
          AND NOT ST_IsEmpty({geom_expr})
          AND {spec.source_key_sql} IS NOT NULL
    """


def _source_keys_sql(plan: KeyedSyncPlan) -> str:
    spec = plan.spec
    geom_expr = _quote_ident(plan.source_geom_col)
    return f"""
        SELECT {spec.source_key_sql} AS jk
        FROM {spec.source_schema}.{spec.source_table} t
        WHERE {geom_expr} IS NOT NULL
          AND NOT ST_IsEmpty({geom_expr})
          AND {spec.source_key_sql} IS NOT NULL
    """


def _iter_qgis_batches(
    select_sql: str,
    *,
    batch_size: int,
    cursor_name: str = "sync_geodb_stream",
) -> Iterator[list[tuple[Any, ...]]]:
    conn = connections[QGIS_ALIAS]
    conn.ensure_connection()
    raw = conn.connection
    assert raw is not None

    old_autocommit = raw.autocommit
    if old_autocommit:
        raw.autocommit = False
    try:
        with raw.cursor() as setup:
            _mark_qgis_session_read_only(setup)
        named = raw.cursor(name=cursor_name)
        named.itersize = batch_size
        try:
            named.execute(select_sql)
            while True:
                rows = named.fetchmany(batch_size)
                if not rows:
                    break
                batch = [tuple(r) for r in rows if r[0] is not None]
                if batch:
                    yield batch
        finally:
            named.close()
            raw.rollback()
    finally:
        raw.autocommit = old_autocommit


def _stage_create_sql(plan: KeyedSyncPlan) -> str:
    cast = plan.spec.geodb_key_cast
    parts = [f"jk {cast}"]
    for a in plan.attrs:
        # Use text for staging flexibility; cast on merge.
        parts.append(f"{_quote_ident('a_' + a.geodb_col)} text")
    parts.append("ewkb bytea")
    return f"CREATE TEMP TABLE sync_stage ({', '.join(parts)}) ON COMMIT DROP"


def _stage_insert_template(plan: KeyedSyncPlan) -> str:
    n = 1 + len(plan.attrs) + 1  # jk + attrs + ewkb
    return "(" + ", ".join(["%s"] * n) + ")"


def _changed_predicate_sql(plan: KeyedSyncPlan) -> str:
    """True when any sync attr or geom differs between target t and stage s."""
    parts: list[str] = []
    for a in plan.attrs:
        tcol = f"t.{_quote_ident(a.geodb_col)}"
        scol = f"s.{_quote_ident('a_' + a.geodb_col)}"
        # Compare as text to avoid type mismatch on staging.
        parts.append(f"({tcol})::text IS DISTINCT FROM ({scol})")
    parts.append(
        """(
            t.geom IS NULL
            OR s.ewkb IS NULL
            OR NOT ST_Equals(t.geom, ST_GeomFromEWKB(s.ewkb))
        )"""
    )
    return " OR ".join(parts)


def _stage_cast_expr(a: AttrMapping) -> str:
    """SQL expression casting staged text column to geodb type."""
    scol = f"s.{_quote_ident('a_' + a.geodb_col)}"
    if a.typname == "jsonb":
        return f"COALESCE({scol}::jsonb, '{{}}'::jsonb)"
    if a.typname in ("text", "varchar", "bpchar"):
        return scol
    if a.typname in (
        "int2",
        "int4",
        "int8",
        "float4",
        "float8",
        "numeric",
        "timestamp",
        "timestamptz",
        "date",
        "bool",
        "boolean",
    ):
        return f"NULLIF(BTRIM({scol}), '')::{a.typname}"
    return f"{scol}::{a.typname}"


def _merge_from_stage(plan: KeyedSyncPlan) -> dict[str, int]:
    """INSERT / UPDATE / DELETE against geodb using TEMP sync_stage. Returns counts."""
    spec = plan.spec
    tbl = _quote_ident(spec.geodb_table)
    jk = _quote_ident(spec.geodb_key)
    cast = spec.geodb_key_cast
    changed = _changed_predicate_sql(plan)

    set_parts: list[str] = []
    for a in plan.attrs:
        set_parts.append(f"{_quote_ident(a.geodb_col)} = {_stage_cast_expr(a)}")
    set_parts.append("geom = ST_GeomFromEWKB(s.ewkb)")
    set_clause = ", ".join(set_parts)

    insert_cols = [jk] + [_quote_ident(a.geodb_col) for a in plan.attrs] + ["geom"]
    insert_select = (
        [f"s.jk::{cast}"]
        + [_stage_cast_expr(a) for a in plan.attrs]
        + ["ST_GeomFromEWKB(s.ewkb)"]
    )

    with connections[GEODB_ALIAS].cursor() as cursor:
        cursor.execute(
            f"""
            UPDATE {tbl} AS t
            SET {set_clause}
            FROM sync_stage s
            WHERE t.{jk} = s.jk::{cast}
              AND ({changed})
            """
        )
        updated = cursor.rowcount

        cursor.execute(
            f"""
            INSERT INTO {tbl} ({', '.join(insert_cols)})
            SELECT {', '.join(insert_select)}
            FROM sync_stage s
            WHERE NOT EXISTS (
                SELECT 1 FROM {tbl} t WHERE t.{jk} = s.jk::{cast}
            )
              AND s.ewkb IS NOT NULL
            """
        )
        inserted = cursor.rowcount

        # Orphan delete: keyed rows not in stage.
        # NULL rootid rows are excluded by `t.key IS NOT NULL` — preserves local request rows.
        cursor.execute(
            f"""
            DELETE FROM {tbl} t
            WHERE t.{jk} IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1 FROM sync_stage s WHERE s.jk::{cast} = t.{jk}
              )
            """
        )
        deleted = cursor.rowcount

    return {
        "updated": int(updated),
        "inserted": int(inserted),
        "deleted": int(deleted),
    }


def _dry_run_keyed_counts(plan: KeyedSyncPlan) -> dict[str, int]:
    """Counts without persistent writes (keys-only compare)."""
    spec = plan.spec
    source_keys: set[Any] = set()
    for batch in _iter_qgis_batches(
        _source_keys_sql(plan), batch_size=5000, cursor_name="sync_geodb_keys"
    ):
        source_keys.update(row[0] for row in batch)

    with connections[GEODB_ALIAS].cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {_quote_ident(spec.geodb_key)}
            FROM {_quote_ident(spec.geodb_table)}
            WHERE {_quote_ident(spec.geodb_key)} IS NOT NULL
            """
        )
        geodb_keys = {row[0] for row in cursor.fetchall()}

    would_insert = len(source_keys - geodb_keys)
    would_delete = len(geodb_keys - source_keys)
    # Upper bound for updates: keys present on both sides (attrs may or may not differ).
    would_update = len(source_keys & geodb_keys)
    return {
        "source_rows": len(source_keys),
        "geodb_keys": len(geodb_keys),
        "inserted": would_insert,
        "updated": would_update,
        "deleted": would_delete,
        "dry_run": 1,
    }


def sync_keyed_table_full(
    name: str,
    *,
    dry_run: bool = False,
    batch_size: int = 2000,
) -> dict[str, int]:
    """
    Full sync for one keyed GIS table.

    Returns source_rows, inserted, updated, deleted (and geodb_keys / dry_run flag).
    """
    spec = SPECS[name]
    plan = build_keyed_sync_plan(spec)

    if dry_run:
        return _dry_run_keyed_counts(plan)

    select_sql = _source_attr_select_sql(plan)
    source_rows = 0

    with transaction.atomic(using=GEODB_ALIAS):
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute(_stage_create_sql(plan))
            raw_cursor = getattr(cursor, "cursor", cursor)
            template = _stage_insert_template(plan)
            insert_sql = "INSERT INTO sync_stage VALUES %s"

            for batch in _iter_qgis_batches(select_sql, batch_size=batch_size):
                # Convert attr values to text for staging; keep jk and ewkb as-is.
                staged: list[tuple[Any, ...]] = []
                for row in batch:
                    jk = row[0]
                    ewkb = row[-1]
                    if ewkb is None:
                        continue
                    mids = tuple(
                        None if v is None else str(v) for v in row[1:-1]
                    )
                    staged.append((jk, *mids, ewkb))
                if not staged:
                    continue
                execute_values(
                    raw_cursor,
                    insert_sql,
                    staged,
                    template=template,
                    page_size=len(staged),
                )
                source_rows += len(staged)
                if source_rows == len(staged) or source_rows % (batch_size * 5) < len(
                    staged
                ):
                    print(
                        f"  … {spec.name}: staged={source_rows}",
                        flush=True,
                    )

            # Index for join performance.
            cursor.execute(
                f"CREATE INDEX ON sync_stage (jk)"
            )

        counts = _merge_from_stage(plan)

    counts["source_rows"] = source_rows
    counts["geodb_keys"] = 0
    counts["dry_run"] = 0
    return counts


def _resolve_bidregistry_table() -> str:
    """Return quoted master.<table> for bidregistry."""
    with connections[QGIS_ALIAS].cursor() as cursor:
        _mark_qgis_session_read_only(cursor)
        cursor.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
              AND lower(table_name) = ANY(%s)
            ORDER BY CASE lower(table_name)
                WHEN 'bidregistry' THEN 0
                WHEN 'bidregistry_view' THEN 1
                ELSE 2
            END
            LIMIT 1
            """,
            [
                ODS_BIDREGISTRY_SCHEMA,
                [c.lower() for c in ODS_BIDREGISTRY_TABLE_CANDIDATES],
            ],
        )
        row = cursor.fetchone()
    if not row:
        raise ValueError(
            f"No bidregistry table in {ODS_BIDREGISTRY_SCHEMA} "
            f"(tried {ODS_BIDREGISTRY_TABLE_CANDIDATES})"
        )
    return f"{ODS_BIDREGISTRY_SCHEMA}.{_quote_ident(row[0])}"


# Canonical SELECT for ods_request (product formula). ownerid/grbsid come from cls joins.
# DISTINCT ON: Shortname can match multiple CustomerLegalPerson rows.
ODS_BIDREGISTRY_SELECT_SQL = f"""
    SELECT DISTINCT ON (b."BrId")
        b."BrId",
        b."BrStatusName",
        b."CreateTypeName",
        b."ReasonName",
        b."PassportizationTypeName",
        b."ObjectTypeName",
        b."OwnerName",
        b."GrbsName",
        b."ShortObjectId",
        b."ShortObjectRootId",
        b."ObjectName",
        b."ObjectArea",
        b."InspectionDatePlan",
        owner."Id" AS ownerid,
        grbs."Id" AS grbsid
    FROM master."BidRegistry" b
    LEFT JOIN cls."CustomerLegalPerson" owner
        ON owner."Shortname" = b."OwnerName"
    LEFT JOIN cls."CustomerLegalPerson" grbs
        ON grbs."Shortname" = b."GrbsName"
    WHERE {ODS_BIDREGISTRY_WHERE}
      AND b."BrId" IS NOT NULL
    ORDER BY b."BrId", owner."Id" NULLS LAST, grbs."Id" NULLS LAST
"""


def _ods_select_sql() -> tuple[str, list[str]]:
    return ODS_BIDREGISTRY_SELECT_SQL, list(ODS_REQUEST_COLUMNS)


def sync_ods_request_from_bidregistry(*, dry_run: bool = False) -> dict[str, int]:
    """
    Replace geodb.ods_request with filtered master."BidRegistry" rows.

    ownerid / grbsid resolved via cls."CustomerLegalPerson" Shortname joins.
    Deletes rows whose BrId is not in the filtered source set (via TRUNCATE+INSERT).
    """
    select_sql, columns = _ods_select_sql()

    with connections[QGIS_ALIAS].cursor() as cursor:
        _mark_qgis_session_read_only(cursor)
        cursor.execute(select_sql)
        rows = cursor.fetchall()

    if dry_run:
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute("SELECT count(*) FROM ods_request")
            geodb_count = int(cursor.fetchone()[0])
            owner_filled = sum(1 for r in rows if r[columns.index("ownerid")] is not None)
            grbs_filled = sum(1 for r in rows if r[columns.index("grbsid")] is not None)
        return {
            "source_rows": len(rows),
            "geodb_keys": geodb_count,
            "inserted": len(rows),
            "updated": 0,
            "deleted": geodb_count,  # full replace
            "dry_run": 1,
            "ownerid_filled": owner_filled,
            "grbsid_filled": grbs_filled,
        }

    placeholders = ", ".join(["%s"] * len(columns))
    quoted_cols = ", ".join(
        _quote_ident(c) if any(ch.isupper() for ch in c) else c for c in columns
    )
    insert_sql = f"INSERT INTO ods_request ({quoted_cols}) VALUES ({placeholders})"

    with transaction.atomic(using=GEODB_ALIAS):
        with connections[GEODB_ALIAS].cursor() as cursor:
            cursor.execute("TRUNCATE TABLE ods_request RESTART IDENTITY")
            for row in rows:
                cursor.execute(insert_sql, list(row))

    return {
        "source_rows": len(rows),
        "inserted": len(rows),
        "updated": 0,
        "deleted": 0,
        "geodb_keys": 0,
        "dry_run": 0,
    }


def resolve_sync_tables(table: str | None) -> list[str]:
    if not table:
        return list(FULL_TABLE_ORDER)
    if table not in FULL_TABLE_ORDER and table not in SPECS:
        known = ", ".join(FULL_TABLE_ORDER)
        raise ValueError(f"Unknown table {table!r}. Known: {known}")
    return [table]


def run_full_sync(
    tables: Iterable[str],
    *,
    dry_run: bool = False,
    batch_size: int = 2000,
) -> list[tuple[str, dict[str, int]]]:
    """
    Sync selected tables. After dgi (when included and not dry_run), runs set_dgi_rent.
    """
    results: list[tuple[str, dict[str, int]]] = []
    table_list = list(tables)
    for name in table_list:
        if name == "rzd":
            stats = sync_rzd(dry_run=dry_run)
            # Normalize keys for CLI display.
            stats = {
                "source_rows": stats.get("source_rows", 0),
                "inserted": stats.get("updated", 0) if not dry_run else 0,
                "updated": 0,
                "deleted": stats.get("geodb_keys", 0) if dry_run else 0,
                "geodb_keys": stats.get("geodb_keys", 0),
                "dry_run": 1 if dry_run else 0,
            }
        elif name == "ods_request":
            stats = sync_ods_request_from_bidregistry(dry_run=dry_run)
        else:
            stats = sync_keyed_table_full(
                name, dry_run=dry_run, batch_size=batch_size
            )
        results.append((name, stats))

        if name == "dgi" and not dry_run:
            rent_stats = set_dgi_rent(dry_run=False)
            results.append(
                (
                    "dgi.rent",
                    {
                        "source_rows": 0,
                        "inserted": 0,
                        "updated": int(rent_stats.get("updated", 0)),
                        "deleted": 0,
                        "geodb_keys": 0,
                        "dry_run": 0,
                        "true_count": int(rent_stats.get("true_count", 0)),
                        "false_count": int(rent_stats.get("false_count", 0)),
                    },
                )
            )
    return results
