"""Same-origin HTTPS proxy for internal МГГТ raster tiles."""

from __future__ import annotations

import logging
import threading
from collections import OrderedDict
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, HttpResponseNotFound
from django.views.decorators.http import require_GET

logger = logging.getLogger(__name__)

MGGT_MAX_NATIVE_ZOOM = 17
CACHE_MAX_ENTRIES = 64
CACHE_CONTROL = "private, max-age=86400"
MAX_TILE_BYTES = 2 * 1024 * 1024
_LAYER_SETTING_KEYS = {
    "mggt": "MGGT_TILE_RESOURCE_ID",
    "scale2000": "SCALE_2000_TILE_RESOURCE_ID",
}

_cache_lock = threading.Lock()
_tile_cache: OrderedDict[tuple[str, int, int, int], tuple[bytes, str]] = OrderedDict()


def clear_tile_cache() -> None:
    with _cache_lock:
        _tile_cache.clear()


def _int_setting(name: str, default: int) -> int:
    try:
        return int(getattr(settings, name, default))
    except (TypeError, ValueError):
        return default


def _resource_id_for_layer(layer: str) -> str | None:
    setting_name = _LAYER_SETTING_KEYS.get(layer)
    if not setting_name:
        return None
    value = str(getattr(settings, setting_name, "") or "").strip()
    return value or None


def build_upstream_url(resource_id: str, z: int, x: int, y: int) -> str:
    base = str(getattr(settings, "MGGT_TILE_UPSTREAM_BASE", "") or "").strip()
    nd = str(getattr(settings, "MGGT_TILE_ND", "204") or "204").strip()
    query = urlencode({"resource": resource_id, "nd": nd, "z": z, "x": x, "y": y})
    separator = "&" if "?" in base else "?"
    return f"{base}{separator}{query}"


def _cache_get(key: tuple[str, int, int, int]) -> tuple[bytes, str] | None:
    with _cache_lock:
        if key not in _tile_cache:
            return None
        _tile_cache.move_to_end(key)
        return _tile_cache[key]


def _cache_put(key: tuple[str, int, int, int], value: tuple[bytes, str]) -> None:
    with _cache_lock:
        _tile_cache[key] = value
        _tile_cache.move_to_end(key)
        while len(_tile_cache) > CACHE_MAX_ENTRIES:
            _tile_cache.popitem(last=False)


def fetch_upstream_tile(url: str) -> tuple[bytes, str] | None:
    timeout = _int_setting("MGGT_TILE_TIMEOUT_SECONDS", 5)
    request = Request(
        url,
        method="GET",
        headers={"User-Agent": "PassportEditor-tile-proxy/1.0"},
    )
    try:
        with urlopen(request, timeout=timeout) as response:
            status = getattr(response, "status", 200)
            if status != 200:
                return None
            content_type = response.headers.get("Content-Type", "image/png") or "image/png"
            lowered = content_type.lower()
            if "html" in lowered or "json" in lowered or lowered.startswith("text/"):
                return None
            body = response.read(MAX_TILE_BYTES + 1)
            if not body or len(body) > MAX_TILE_BYTES:
                return None
            return body, content_type.split(";")[0].strip() or "image/png"
    except HTTPError as exc:
        logger.warning("mggt tile proxy HTTP %s for %s", exc.code, url)
        return None
    except (URLError, TimeoutError, OSError) as exc:
        logger.warning("mggt tile proxy upstream error for %s: %s", url, exc)
        return None


def _tile_response(body: bytes, content_type: str) -> HttpResponse:
    response = HttpResponse(body, content_type=content_type)
    response["Cache-Control"] = CACHE_CONTROL
    return response


@login_required
@require_GET
def proxy_mggt_tile(request, layer: str, z: int, x: int, y: int):
    resource_id = _resource_id_for_layer(layer)
    if resource_id is None:
        return HttpResponseNotFound()
    if z < 0 or z > MGGT_MAX_NATIVE_ZOOM or x < 0 or y < 0:
        return HttpResponseNotFound()

    cache_key = (layer, int(z), int(x), int(y))
    cached = _cache_get(cache_key)
    if cached is not None:
        return _tile_response(*cached)

    url = build_upstream_url(resource_id, int(z), int(x), int(y))
    fetched = fetch_upstream_tile(url)
    if fetched is None:
        return HttpResponseNotFound()
    _cache_put(cache_key, fetched)
    return _tile_response(*fetched)
