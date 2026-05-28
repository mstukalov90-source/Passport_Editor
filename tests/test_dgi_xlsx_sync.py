"""Unit tests for dgi.xlsx parsing (no database)."""

from openpyxl import Workbook

from pass_viewer.data_import.dgi_xlsx_sync import _load_rows_from_xlsx


def _write_sample_xlsx(path):
    wb = Workbook()
    ws = wb.active
    ws.append(["fid", "descr", "address", "sobstv_rr", "Short_sobstv_rr"])
    ws.append([1, "77:01:0002015:4", "Test address", "Owner LLC", "ЧС"])
    ws.append([2, "50:02:0000418:241", None, "Person", "ФЛ"])
    ws.append([3, None, "skip me", "x", "y"])
    ws.append([4, "77:01:0002015:4", "Dup", "Dup owner", "Д"])
    wb.save(path)
    wb.close()


def test_load_rows_from_xlsx_dedupes_by_descr(tmp_path):
    path = tmp_path / "dgi.xlsx"
    _write_sample_xlsx(path)

    unique, skipped, duplicates = _load_rows_from_xlsx(path)

    assert skipped == 1
    assert duplicates == 1
    assert len(unique) == 2
    assert unique["77:01:0002015:4"] == ("77:01:0002015:4", "Д", "Dup", "Dup owner")
    assert unique["50:02:0000418:241"] == ("50:02:0000418:241", "ФЛ", None, "Person")


def test_insert_batch_rows_order():
    from pass_viewer.data_import.dgi_xlsx_sync import _insert_batch_rows

    rows = [("d1", "short", "addr", "owner")]
    assert _insert_batch_rows(rows) == [("d1", "addr", "owner", "short")]
