"""
Compute dgi.rent from tip_doc_dgi.

Rule matches the Excel AutoFilter on tip_doc_dgi in ДГИ.xlsx:
  tip_doc_dgi ILIKE '%ДОГОВОР АРЕНДЫ%'
"""

from __future__ import annotations

from typing import Any

from django.conf import settings
from django.db import connection, transaction

# Substring used in SQL ILIKE and for unit tests / docs.
RENT_TIP_DOC_SUBSTRING = "ДОГОВОР АРЕНДЫ"

RENT_SQL_PREDICATE = f"COALESCE(tip_doc_dgi ILIKE '%{RENT_TIP_DOC_SUBSTRING}%', false)"


def dgi_table_name() -> str:
    return getattr(settings, "GIS_DGI_TABLE", "dgi")


def set_dgi_rent(*, dry_run: bool = False) -> dict[str, Any]:
    """
    Set rent = (tip_doc_dgi ILIKE '%ДОГОВОР АРЕНДЫ%') for all rows.

    Returns counts: true_count, false_count, updated (rows touched by UPDATE when not dry_run).
    """
    table = dgi_table_name()
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT to_regclass(%s) IS NOT NULL
              AND EXISTS (
                SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'public'
                  AND table_name = %s
                  AND column_name = 'rent'
              )
            """,
            [f"public.{table}", table],
        )
        if not cursor.fetchone()[0]:
            raise ValueError(
                f'Table "{table}" or column rent is missing; run migrations first.'
            )

        if dry_run:
            cursor.execute(
                f"""
                SELECT
                    COUNT(*) FILTER (WHERE {RENT_SQL_PREDICATE}) AS true_count,
                    COUNT(*) FILTER (WHERE NOT ({RENT_SQL_PREDICATE})) AS false_count
                FROM {table}
                """
            )
            true_count, false_count = cursor.fetchone()
            return {
                "true_count": true_count,
                "false_count": false_count,
                "updated": 0,
                "dry_run": True,
            }

        with transaction.atomic():
            cursor.execute(
                f"""
                UPDATE {table}
                SET rent = ({RENT_SQL_PREDICATE})
                """
            )
            updated = cursor.rowcount
            cursor.execute(
                f"""
                SELECT
                    COUNT(*) FILTER (WHERE rent IS TRUE) AS true_count,
                    COUNT(*) FILTER (WHERE rent IS FALSE) AS false_count
                FROM {table}
                """
            )
            true_count, false_count = cursor.fetchone()

    return {
        "true_count": true_count,
        "false_count": false_count,
        "updated": updated,
        "dry_run": False,
    }
