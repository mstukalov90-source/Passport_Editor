"""Справочники юридических лиц из mggt_asu для подсказок формы заявки на регистрацию.

Данные читаются из удалённой БД (алиас ``qgis``) сырым SQL — Django-моделей на ней нет.
Списки кэшируются в процессе: свежие данные — 10 минут, при сбое подключения повторная
попытка не раньше чем через минуту, чтобы не подвешивать рендер формы на таймаут.
При недоступности БД функции возвращают пустой список — форма остаётся рабочей без подсказок.
"""

import logging
import time

from django.db import connections

logger = logging.getLogger(__name__)

QGIS_ALIAS = "qgis"

_REFERENCE_TTL_SECONDS = 600
_FAILURE_TTL_SECONDS = 60

# key -> (момент загрузки, данные; None = последняя попытка не удалась)
_cache: dict[str, tuple[float, list[dict] | None]] = {}

_DEPARTMENT_SQL = """
    SELECT "Shortname", "Fullname"
    FROM cls."DepartmentLegalPerson"
    ORDER BY "Shortname"
"""

_CUSTOMER_SQL = """
    SELECT "Shortname", "Fullname"
    FROM cls."CustomerLegalPerson"
    ORDER BY "Shortname"
"""


def _mark_qgis_session_read_only(cursor) -> None:
    """Best-effort read-only; этот модуль не делает запись в qgis."""
    try:
        cursor.execute("SET default_transaction_read_only = on")
    except Exception:
        pass


def _fetch_legal_persons(sql: str) -> list[dict]:
    with connections[QGIS_ALIAS].cursor() as cursor:
        _mark_qgis_session_read_only(cursor)
        cursor.execute(sql)
        rows = cursor.fetchall()
    seen_shortnames: set[str] = set()
    items: list[dict] = []
    for shortname, fullname in rows:
        shortname = (shortname or "").strip()
        fullname = (fullname or "").strip()
        if not shortname or not fullname or shortname in seen_shortnames:
            continue
        seen_shortnames.add(shortname)
        items.append({"shortname": shortname, "fullname": fullname})
    return items


def _cached(key: str, sql: str) -> list[dict]:
    now = time.monotonic()
    hit = _cache.get(key)
    if hit is not None:
        cached_at, items = hit
        if items is not None and now - cached_at < _REFERENCE_TTL_SECONDS:
            return items
        if items is None and now - cached_at < _FAILURE_TTL_SECONDS:
            return []
    try:
        items = _fetch_legal_persons(sql)
    except Exception:
        logger.warning("Справочник %s недоступен: форма заявки отрисована без подсказок", key)
        _cache[key] = (now, None)
        return []
    _cache[key] = (now, items)
    return items


def list_executive_authorities() -> list[dict]:
    """Органы исполнительной власти: cls.\"DepartmentLegalPerson\"."""
    return _cached("executive_authorities", _DEPARTMENT_SQL)


def list_institutions() -> list[dict]:
    """Учреждения: cls.\"CustomerLegalPerson\"."""
    return _cached("institutions", _CUSTOMER_SQL)
