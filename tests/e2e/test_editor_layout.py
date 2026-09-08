"""Browser checks for the three-column editor shell."""

from __future__ import annotations

import pytest
from django.urls import reverse


def _login(page, live_server, e2e_credentials) -> None:
    page.goto(f"{live_server.url}{reverse('login')}")
    page.fill('input[name="username"]', e2e_credentials["username"])
    page.fill('input[name="password"]', e2e_credentials["password"])
    page.get_by_role("button", name="Войти").click()
    page.wait_for_url(f"{live_server.url}/", wait_until="load")


@pytest.mark.e2e
@pytest.mark.django_db
def test_add_object_three_column_map_and_hidden_ods(page, live_server, e2e_credentials):
    _login(page, live_server, e2e_credentials)
    page.goto(f"{live_server.url}{reverse('add_object')}")
    page.wait_for_selector(".add-object-workspace", state="visible")
    workspace = page.locator(".add-object-workspace")
    assert workspace.is_visible()
    map_el = page.locator("#map")
    assert map_el.is_visible()
    map_box = map_el.bounding_box()
    panel_box = page.locator(".add-object-panel--map").bounding_box()
    assert map_box and panel_box
    assert map_box["height"] > 200
    assert abs(map_box["height"] - panel_box["height"]) < 40
    export_btn = page.locator("#save-geometry-btn")
    assert export_btn.is_visible()
    assert export_btn.inner_text().strip() == "Выгрузить объекты"
    assert page.locator("#ods-request-status-section").is_hidden()
    assert page.locator("#db-comments-section").is_hidden()
    assert page.locator("#attachments-section").is_hidden()
    assert page.locator("#layer-opacity-slider").is_visible()
    page.locator(".layer-panel-row__expand").first.click()
    assert page.locator(".layer-panel-row").first.evaluate("el => el.classList.contains('is-open')")
    page.locator("#layer-opacity-slider").fill("40")
    assert page.locator("#layer-opacity-slider").input_value() == "40"
