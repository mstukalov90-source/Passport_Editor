"""
GeoJSON property key aliases per table/column.

Dynamic import matches column names case-insensitively, but some DB columns
differ from export field names (e.g. ozn.ownerlegalpersonalid vs OwnerLegalPersonId).
"""

from __future__ import annotations

from typing import Any

# table -> column (lowercase) -> extra GeoJSON property keys to try
TABLE_COLUMN_ALIASES: dict[str, dict[str, tuple[str, ...]]] = {
    "ozn": {
        "rootid": ("RootId",),
        "name": ("Name",),
        "descr": ("Descr",),
        "address": ("Address",),
        "vri": ("Vri",),
        "sobstv_rr": ("SobstvRr",),
        "departmentlegalpersonid": ("DepartmentLegalPersonId",),
        "ownerlegalpersonalid": ("OwnerLegalPersonId", "ownerlegalpersonid"),
        "startdate": ("StartDate",),
        "datesurvey": ("DateSurvey",),
        "createtype": ("CreateType",),
        "request_id": ("PassBrId", "RequestId"),
    },
}


def match_geojson_property(
    props: dict[str, Any],
    column_name: str,
    *,
    table_name: str | None = None,
) -> Any:
    if not isinstance(props, dict):
        return None

    lower_props = {str(k).lower(): k for k in props}
    candidates: list[str] = [column_name, column_name.lower()]

    if table_name:
        table_aliases = TABLE_COLUMN_ALIASES.get(table_name, {})
        extra = table_aliases.get(column_name.lower(), ())
        candidates.extend(extra)

    seen: set[str] = set()
    for key in candidates:
        lk = key.lower()
        if lk in seen:
            continue
        seen.add(lk)
        if key in props:
            return props[key]
        if lk in lower_props:
            return props[lower_props[lk]]
    return None
