"""Tests for work layer label parsing."""

from __future__ import annotations

from pathlib import Path

import pytest
from approval.work_layer_labels import load_work_layer_labels, work_layer_label
from django.conf import settings


@pytest.fixture(autouse=True)
def _point_labels_sql(settings, tmp_path):
    sql = Path(settings.BASE_DIR) / "approval" / "layer_styles" / "create_work.sql"
    settings.APPROVAL_LAYER_STYLES_SQL = sql
    load_work_layer_labels.cache_clear()
    yield
    load_work_layer_labels.cache_clear()


def test_load_work_layer_labels_contains_dts_poly():
    labels = load_work_layer_labels()
    assert labels["DtsPoly"] == "Дорожно-тропиночная сеть"


def test_work_layer_label_fallback():
    assert work_layer_label("UnknownTable") == "UnknownTable"


def test_work_layer_label_known():
    assert work_layer_label("LawnPoly") == "Газоны"
