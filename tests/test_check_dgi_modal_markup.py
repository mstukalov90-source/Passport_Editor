"""Smoke-тесты модалки проверки пересечений на /personal/ (переключатель З/У | ОГХ)."""

from __future__ import annotations

import json

import pytest
from django.urls import reverse

TEST_GEOMETRY = {
    "type": "Polygon",
    "coordinates": [
        [
            [37.60, 55.70],
            [37.61, 55.70],
            [37.61, 55.71],
            [37.60, 55.71],
            [37.60, 55.70],
        ]
    ],
}


def _login(client, e2e_credentials):
    assert client.login(
        username=e2e_credentials["username"],
        password=e2e_credentials["password"],
    )


@pytest.mark.django_db
def test_personal_check_dgi_modal_markup(client, e2e_credentials):
    # Client request imports middleware/views (needs GDAL env).
    try:
        from pass_viewer import views as _views  # noqa: F401
    except Exception as exc:
        pytest.skip(f"views unavailable in this env: {exc}")

    _login(client, e2e_credentials)
    for url_name in ("personal_account", "home"):
        response = client.get(reverse(url_name))
        assert response.status_code == 200
        html = response.content.decode("utf-8")

        assert "Пересечение с З/У и ОГХ" in html
        assert 'id="check-dgi-mode-toggle"' in html
        assert 'data-dgi-mode="zu"' in html
        assert 'data-dgi-mode="ogx"' in html
        assert 'id="check-dgi-modal-close"' in html
        assert "Детальный анализ пересечений" in html
        # Кнопка OK удалена — закрытие через крестик в шапке.
        assert ">OK</button>" not in html


@pytest.mark.django_db
def test_check_ogx_intersections_endpoint(client, e2e_credentials):
    try:
        from pass_viewer import views as _views  # noqa: F401
    except Exception as exc:
        pytest.skip(f"views unavailable in this env: {exc}")

    _login(client, e2e_credentials)
    url = reverse("check_ogx_intersections")

    response = client.post(url, data="{}", content_type="application/json")
    assert response.status_code == 400

    response = client.post(
        url,
        data=json.dumps({"geometry": TEST_GEOMETRY, "rootid": "12345", "request_id": ""}),
        content_type="application/json",
    )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert "intersects" in data
    for field in ("percent_dt", "percent_odh", "percent_oo", "percent_top"):
        assert field in data


@pytest.mark.django_db
def test_check_ogx_intersections_requires_login(client):
    try:
        from pass_viewer import views as _views  # noqa: F401
    except Exception as exc:
        pytest.skip(f"views unavailable in this env: {exc}")

    response = client.post(
        reverse("check_ogx_intersections"),
        data=json.dumps({"geometry": TEST_GEOMETRY}),
        content_type="application/json",
    )
    assert response.status_code == 302
