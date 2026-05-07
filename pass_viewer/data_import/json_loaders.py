"""
Load row-oriented JSON files into known tables (non-geometry).
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Tuple

from django.db import connection, transaction

from pass_viewer.models import ExternalUser


def _load_json_array(path: Path) -> List[Dict[str, Any]]:
    raw = json.loads(path.read_text(encoding='utf-8'))
    if isinstance(raw, dict) and 'rows' in raw:
        raw = raw['rows']
    if not isinstance(raw, list):
        raise ValueError('JSON root must be an array of objects or {"rows": [...]}')
    return [row for row in raw if isinstance(row, dict)]


def import_users(path: Path, *, dry_run: bool = False) -> Tuple[int, int]:
    """
    Insert/update users from JSON. Accepted keys per row:
    login, password, OwnerLegalPersonId | owner_legal_person_id | ownerlegalpersonalid
    """
    rows = _load_json_array(path)
    created = updated = 0
    if dry_run:
        return len(rows), 0

    with transaction.atomic():
        for row in rows:
            login = str(row.get('login') or '').strip()
            if not login:
                continue
            password = str(row.get('password') or '')
            owner = row.get('OwnerLegalPersonId')
            if owner is None:
                owner = row.get('owner_legal_person_id')
            if owner is None:
                owner = row.get('ownerlegalpersonalid')
            owner_str = '' if owner is None else str(owner)

            obj, was_created = ExternalUser.objects.update_or_create(
                login=login,
                defaults={
                    'password': password,
                    'owner_legal_person_id': owner_str or None,
                },
            )
            if was_created:
                created += 1
            else:
                updated += 1
    return created, updated


def import_id_names(path: Path, *, dry_run: bool = False) -> Tuple[int, int]:
    """
    Upsert id_names from JSON array of {"LegalPersonId": "...", "name": "..."}
    (keys are matched case-insensitively).
    """
    rows = _load_json_array(path)
    if dry_run:
        return len(rows), 0

    inserted = 0
    with transaction.atomic():
        with connection.cursor() as cursor:
            for row in rows:
                pid = _pick(row, 'LegalPersonId', 'legalpersonid', 'legal_person_id')
                name = _pick(row, 'name', 'Name')
                if pid is None or name is None:
                    continue
                cursor.execute(
                    """
                    INSERT INTO id_names ("LegalPersonId", "name")
                    VALUES (%s, %s)
                    ON CONFLICT ("LegalPersonId") DO UPDATE SET
                        "name" = EXCLUDED."name"
                    """,
                    [str(pid).strip(), str(name).strip()],
                )
                # rowcount unreliable for upsert across drivers; approximate as inserts
                inserted += 1
    return inserted, 0


def _pick(row: Dict[str, Any], *candidates: str) -> Any:
    lower = {str(k).lower(): v for k, v in row.items()}
    for c in candidates:
        if c in row:
            return row[c]
        cl = c.lower()
        if cl in lower:
            return lower[cl]
    return None
