"""Tests for DGI sub-layer classification (moscow vs private, renovation, rent)."""

from pass_viewer.dgi_layers import (
    DGI_LAYER_KEYS,
    DGI_LAYER_SPECS,
    DGI_MOSCOW_MARKER_CITY,
    DGI_MOSCOW_MARKER_NO_DATA,
    DGI_RENOVATION_MARKER,
    build_dgi_ownership_extra_sql,
    build_dgi_renovation_extra_sql,
    build_dgi_rent_extra_sql,
    classify_dgi_ownership,
    classify_dgi_renovation,
    normalize_dgi_aprove_payload,
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


def test_classify_dgi_renovation():
    assert classify_dgi_renovation(DGI_RENOVATION_MARKER) is True
    assert classify_dgi_renovation("  " + DGI_RENOVATION_MARKER.lower() + "  ") is True
    assert classify_dgi_renovation("город Москва") is False
    assert classify_dgi_renovation(None) is False
    assert classify_dgi_renovation("") is False


def test_build_sql_fragments():
    col = 't."short_sobstv_rr"'
    moscow_sql = build_dgi_ownership_extra_sql(col, "moscow")
    private_sql = build_dgi_ownership_extra_sql(col, "private")
    assert "ILIKE" in moscow_sql
    assert DGI_MOSCOW_MARKER_CITY in moscow_sql
    assert "IS NULL" in private_sql


def test_build_renovation_sql_fragments():
    col = 't."zemlepol_dgi"'
    match_sql = build_dgi_renovation_extra_sql(col, is_renovation=True)
    exclude_sql = build_dgi_renovation_extra_sql(col, is_renovation=False)
    assert match_sql.startswith(" AND ")
    assert exclude_sql.startswith(" AND ")
    assert DGI_RENOVATION_MARKER in match_sql
    assert "NOT" in exclude_sql
    assert "ILIKE" in match_sql


def test_build_rent_sql_fragments():
    col = 't."rent"'
    with_rent = build_dgi_rent_extra_sql(col, True)
    without_rent = build_dgi_rent_extra_sql(col, False)
    assert "IS TRUE" in with_rent
    assert "IS NOT TRUE" in without_rent
    assert with_rent.startswith(" AND ")
    assert without_rent.startswith(" AND ")


def test_dgi_layer_specs_cover_ownership_and_rent():
    assert set(DGI_LAYER_KEYS) == set(DGI_LAYER_SPECS)
    assert DGI_LAYER_SPECS["dgi_moscow_rent"] == {"ownership": "moscow", "with_rent": True}
    assert DGI_LAYER_SPECS["dgi_moscow_no_rent"] == {"ownership": "moscow", "with_rent": False}
    assert DGI_LAYER_SPECS["dgi_private_rent"] == {"ownership": "private", "with_rent": True}
    assert DGI_LAYER_SPECS["dgi_private_no_rent"] == {"ownership": "private", "with_rent": False}
    assert DGI_LAYER_SPECS["dgi_renovation"] == {"kind": "renovation"}
    assert "dgi_renovation" in DGI_LAYER_KEYS


def test_normalize_dgi_aprove_private_over_10():
    parsed = normalize_dgi_aprove_payload(
        {"percent": 11.2, "ownership": "private", "approved_at": "2026-01-01T00:00:00Z"},
        "tester",
    )
    assert parsed is not None
    assert parsed["percent"] == 11.2
    assert parsed["ownership"] == "private"


def test_normalize_dgi_aprove_rejects_low_percent():
    assert normalize_dgi_aprove_payload({"percent": 10, "ownership": "private"}, "u") is None


def test_build_sql_fragments_dgi_intersection_alias_d():
    col = 'd."short_sobstv_rr"'
    moscow_sql = build_dgi_ownership_extra_sql(col, "moscow")
    assert 'd."short_sobstv_rr"' in moscow_sql
    assert "ILIKE" in moscow_sql


def test_sql_table_geom_drawable_clause():
    from pass_viewer.views import _sql_table_geom_drawable_clause

    clause = _sql_table_geom_drawable_clause("t.geom")
    assert clause.startswith(" AND ")
    assert "t.geom IS NOT NULL" in clause
    assert "ST_IsEmpty(t.geom)" in clause
