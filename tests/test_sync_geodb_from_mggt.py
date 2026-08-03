"""Unit tests for sync_geodb_from_mggt helpers (no live DB)."""

from pass_viewer.data_import.sync_geodb_from_mggt import (
    COLUMN_ALIASES,
    FULL_TABLE_ORDER,
    LOCAL_SKIP_COLUMNS,
    ODS_BIDREGISTRY_WHERE,
    TABLES_PRESERVE_NULL_ROOTID_REQUEST,
    _resolve_source_column,
    resolve_sync_tables,
)


def test_full_table_order_includes_ods_and_gis():
    assert "pass_objects" in FULL_TABLE_ORDER
    assert "ods_request" in FULL_TABLE_ORDER
    assert FULL_TABLE_ORDER[-1] == "ods_request"
    assert "dgi" in FULL_TABLE_ORDER


def test_resolve_sync_tables_default_and_single():
    assert resolve_sync_tables(None) == list(FULL_TABLE_ORDER)
    assert resolve_sync_tables("dgi") == ["dgi"]
    assert resolve_sync_tables("ods_request") == ["ods_request"]


def test_resolve_sync_tables_unknown():
    try:
        resolve_sync_tables("nope")
        assert False, "expected ValueError"
    except ValueError as exc:
        assert "Unknown table" in str(exc)


def test_ozn_owner_alias_maps_to_ownerlegalpersonalid():
    source_by_lower = {
        "ownerlegalpersonid": "OwnerLegalPersonId",
        "rootid": "RootId",
    }
    hit = _resolve_source_column(
        "ownerlegalpersonalid",
        source_by_lower,
        table_name="ozn",
    )
    assert hit == "OwnerLegalPersonId"
    assert "ownerlegalpersonalid" in COLUMN_ALIASES["ozn"]


def test_ods_bidregistry_where_matches_product_filter():
    assert "Аннулирована" in ODS_BIDREGISTRY_WHERE
    assert "2027-01-01" in ODS_BIDREGISTRY_WHERE
    assert "Изменение/определение характеристик зеленых насаждений" in ODS_BIDREGISTRY_WHERE
    assert "BrStatusName" in ODS_BIDREGISTRY_WHERE
    assert "InspectionDatePlan" in ODS_BIDREGISTRY_WHERE
    assert "ReasonName" in ODS_BIDREGISTRY_WHERE


def test_local_skip_and_preserve_null_rootid_tables():
    assert "request_id" in LOCAL_SKIP_COLUMNS
    assert "rent" in LOCAL_SKIP_COLUMNS
    assert "short_sobstv_rr" in LOCAL_SKIP_COLUMNS
    assert TABLES_PRESERVE_NULL_ROOTID_REQUEST == {"pass_objects", "odh", "ozn"}
