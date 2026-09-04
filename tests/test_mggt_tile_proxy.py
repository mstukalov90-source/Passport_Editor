"""Tests for the same-origin МГГТ tile proxy."""

from __future__ import annotations

from io import BytesIO
from pathlib import Path
from unittest.mock import patch
from urllib.error import HTTPError, URLError
from urllib.request import Request

from django.contrib.auth.models import AnonymousUser
from django.test import RequestFactory
from django.urls import reverse
from pass_viewer.tile_proxy import build_upstream_url, clear_tile_cache, proxy_mggt_tile

PNG_BYTES = b"\x89PNG\r\n\x1a\n" + b"\x00" * 24
ROOT = Path(__file__).resolve().parents[1]


class _FakeTileResponse:
    def __init__(self, body: bytes, content_type: str = "image/png", status: int = 200):
        self.status = status
        self.headers = {"Content-Type": content_type}
        self._body = body

    def read(self, n: int = -1) -> bytes:
        if n is None or n < 0:
            return self._body
        return self._body[:n]

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class _AuthUser:
    is_authenticated = True
    is_active = True
    pk = 1
    id = 1
    username = "tileuser"


def _tile_url(*, layer: str = "mggt", z: int = 10, x: int = 618, y: int = 319) -> str:
    return reverse("mggt_tile", kwargs={"layer": layer, "z": z, "x": x, "y": y})


def _request(path: str, *, authenticated: bool = True):
    request = RequestFactory().get(path)
    request.user = _AuthUser() if authenticated else AnonymousUser()
    return request


def _get_tile(*, layer: str = "mggt", z: int = 10, x: int = 618, y: int = 319, authenticated: bool = True):
    path = _tile_url(layer=layer, z=z, x=x, y=y)
    return proxy_mggt_tile(_request(path, authenticated=authenticated), layer=layer, z=z, x=x, y=y)


def _request_url(mock_urlopen) -> str:
    first = mock_urlopen.call_args.args[0]
    if isinstance(first, Request):
        return first.full_url
    return str(first)


def setup_function() -> None:
    clear_tile_cache()


def teardown_function() -> None:
    clear_tile_cache()


def test_anonymous_tile_returns_png():
    with patch(
        "pass_viewer.tile_proxy.urlopen",
        return_value=_FakeTileResponse(PNG_BYTES),
    ):
        response = _get_tile(authenticated=False)

    assert response.status_code == 200
    assert response["Content-Type"] == "image/png"
    assert response["Cache-Control"] == "public, max-age=86400"
    assert response.content == PNG_BYTES


def test_unknown_layer_is_404_and_does_not_fetch():
    with patch("pass_viewer.tile_proxy.urlopen") as mock_urlopen:
        response = _get_tile(layer="osm")
    assert response.status_code == 404
    mock_urlopen.assert_not_called()


def test_zoom_above_native_is_404_and_does_not_fetch():
    with patch("pass_viewer.tile_proxy.urlopen") as mock_urlopen:
        response = _get_tile(z=18)
    assert response.status_code == 404
    mock_urlopen.assert_not_called()


def test_successful_proxy_returns_png_and_allowlisted_upstream():
    with patch(
        "pass_viewer.tile_proxy.urlopen",
        return_value=_FakeTileResponse(PNG_BYTES),
    ) as mock_urlopen:
        response = _get_tile()

    assert response.status_code == 200
    assert response["Content-Type"] == "image/png"
    assert response["Cache-Control"] == "public, max-age=86400"
    assert response.content == PNG_BYTES

    upstream = _request_url(mock_urlopen)
    assert upstream.startswith("http://ngtst.mggt:8080/api/component/render/tile?")
    assert "resource=296153" in upstream
    assert "nd=204" in upstream
    assert "z=10" in upstream
    assert "x=618" in upstream
    assert "y=319" in upstream
    assert "evil" not in upstream


def test_scale2000_uses_allowlisted_resource_id():
    with patch(
        "pass_viewer.tile_proxy.urlopen",
        return_value=_FakeTileResponse(PNG_BYTES),
    ) as mock_urlopen:
        response = _get_tile(layer="scale2000")

    assert response.status_code == 200
    upstream = _request_url(mock_urlopen)
    assert "resource=232992" in upstream
    assert "resource=296153" not in upstream


def test_upstream_timeout_returns_404():
    with patch("pass_viewer.tile_proxy.urlopen", side_effect=URLError("timed out")):
        response = _get_tile()
    assert response.status_code == 404


def test_upstream_http_error_returns_404():
    with patch(
        "pass_viewer.tile_proxy.urlopen",
        side_effect=HTTPError(
            "http://ngtst.mggt:8080/missing",
            502,
            "Bad Gateway",
            hdrs=None,
            fp=BytesIO(b""),
        ),
    ):
        response = _get_tile()
    assert response.status_code == 404


def test_build_upstream_url_does_not_accept_client_host(settings):
    settings.MGGT_TILE_UPSTREAM_BASE = "http://ngtst.mggt:8080/api/component/render/tile"
    url = build_upstream_url("296153", 10, 618, 319)
    assert url.startswith("http://ngtst.mggt:8080/")
    assert "resource=296153" in url
    assert "http://evil.example" not in url


def test_basemap_js_splits_tile_urls_by_protocol():
    source = (ROOT / "pass_viewer/static/pass_viewer/js/basemap.js").read_text(encoding="utf-8")
    assert "/tiles/mggt/{z}/{x}/{y}.png" in source
    assert "/tiles/scale2000/{z}/{x}/{y}.png" in source
    assert "http://ngtst.mggt" in source
    assert "resource=296153" in source
    assert "resource=232992" in source
    assert "location.protocol === 'https:'" in source
    assert "passviewer:mggt_available_v4" in source


def test_pdf_export_skips_same_origin_cors():
    source = (ROOT / "pass_viewer/static/pass_viewer/js/pdf-export.js").read_text(encoding="utf-8")
    assert "function isSameOriginTileUrl" in source
    assert "if (isSameOriginTileUrl(layer._url))" in source
