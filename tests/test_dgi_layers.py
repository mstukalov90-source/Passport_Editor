"""Tests for DGI sub-layer classification (moscow vs private)."""

from pass_viewer.dgi_layers import (
    DGI_MOSCOW_MARKER_CITY,
    DGI_MOSCOW_MARKER_NO_DATA,
    build_dgi_ownership_extra_sql,
    classify_dgi_ownership,
)


def test_classify_moscow_by_substring():
    assert classify_dgi_ownership("г. " + DGI_MOSCOW_MARKER_CITY) == "moscow"
    assert classify_dgi_ownership(DGI_MOSCOW_MARKER_NO_DATA) == "moscow"
    assert classify_dgi_ownership("  " + DGI_MOSCOW_MARKER_CITY.upper() + "  ") == "moscow"


def test_classify_private():
    assert classify_dgi_ownership("ЧС") == "private"
    assert classify_dgi_ownership(None) == "private"
    assert classify_dgi_ownership("") == "private"
    assert classify_dgi_ownership("Физическое лицо") == "private"


def test_build_sql_fragments():
    col = 't."short_sobstv_rr"'
    moscow_sql = build_dgi_ownership_extra_sql(col, "moscow")
    private_sql = build_dgi_ownership_extra_sql(col, "private")
    assert "ILIKE" in moscow_sql
    assert DGI_MOSCOW_MARKER_CITY in moscow_sql
    assert "IS NULL" in private_sql


def test_sql_table_geom_drawable_clause():
    from pass_viewer.views import _sql_table_geom_drawable_clause

    clause = _sql_table_geom_drawable_clause("t.geom")
    assert clause.startswith(" AND ")
    assert "t.geom IS NOT NULL" in clause
    assert "ST_IsEmpty(t.geom)" in clause
