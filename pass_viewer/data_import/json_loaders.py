"""
Load row-oriented JSON files into known tables (non-geometry).
"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from django.db import connection, transaction

from pass_viewer.models import ExternalUser


# Column order must match ods_request table (migrations 0014 + 0015; excluding id).
ODS_REQUEST_COLUMNS: Tuple[str, ...] = (
    'BrId',
    'BrStatusName',
    'CreateTypeName',
    'ReasonName',
    'PassportizationTypeName',
    'ObjectTypeName',
    'OwnerName',
    'GrbsName',
    'ShortObjectId',
    'ShortObjectRootId',
    'ObjectName',
    'ObjectArea',
    'InspectionDatePlan',
    'ownerid',
    'grbsid',
)


def _pick(row: Dict[str, Any], *candidates: str) -> Any:
    lower = {str(k).lower(): v for k, v in row.items()}
    for c in candidates:
        if c in row:
            return row[c]
        cl = c.lower()
        if cl in lower:
            return lower[cl]
    return None


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


def _load_ods_request_rows(path: Path) -> List[Dict[str, Any]]:
    raw = json.loads(path.read_text(encoding='utf-8'))
    if isinstance(raw, dict) and 'bidregistry_view' in raw:
        rows = raw['bidregistry_view']
    elif isinstance(raw, dict) and 'rows' in raw:
        rows = raw['rows']
    elif isinstance(raw, list):
        rows = raw
    else:
        rows = [raw]
    if not isinstance(rows, list):
        raise ValueError('ods_request.json: expected bidregistry_view / rows array or top-level array')
    return [row for row in rows if isinstance(row, dict)]


def _ods_ts(value: Any) -> Optional[str]:
    if value is None or value == '':
        return None
    if isinstance(value, str):
        s = value.strip()
        if not s:
            return None
        if s.endswith('Z'):
            s = s[:-1] + '+00:00'
        try:
            datetime.fromisoformat(s)
        except ValueError:
            return s
        return s
    return None


def _ods_row_tuple(row: Dict[str, Any]) -> Tuple[Any, ...]:
    out: List[Any] = []
    for col in ODS_REQUEST_COLUMNS:
        v = _pick(row, col, col.lower())
        if col == 'InspectionDatePlan':
            out.append(_ods_ts(v))
            continue
        if v is None or v == '':
            out.append(None)
        elif isinstance(v, (dict, list)):
            out.append(json.dumps(v, ensure_ascii=False))
        else:
            out.append(v)
    return tuple(out)


def import_ods_request(path: Path, *, dry_run: bool = False, append: bool = False) -> Tuple[int, int]:
    """
    Load ods_request.json into ``ods_request``.

    Expects ``{"bidregistry_view": [ {...}, ... ]}`` (or a top-level array / ``rows``).
    """
    rows = _load_ods_request_rows(path)
    if dry_run:
        return len(rows), 0

    placeholders = ', '.join(['%s'] * len(ODS_REQUEST_COLUMNS))
    quoted_cols = ', '.join(
        '"' + c.replace('"', '""') + '"' if any(ch.isupper() for ch in c) else c
        for c in ODS_REQUEST_COLUMNS
    )
    insert_sql = f'INSERT INTO ods_request ({quoted_cols}) VALUES ({placeholders})'

    with transaction.atomic():
        with connection.cursor() as cursor:
            if not append:
                cursor.execute('TRUNCATE TABLE ods_request RESTART IDENTITY')
            for row in rows:
                cursor.execute(insert_sql, _ods_row_tuple(row))
    return len(rows), 0


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
