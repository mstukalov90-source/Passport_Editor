from datetime import datetime

from django.utils import timezone

from recheck.services import _normalize_changes, add_business_days


def test_add_business_days_skips_weekend():
    friday = timezone.make_aware(datetime(2026, 9, 18, 12, 0))
    assert add_business_days(friday, 1) == timezone.make_aware(datetime(2026, 9, 21, 12, 0))
    assert add_business_days(friday, 5) == timezone.make_aware(datetime(2026, 9, 25, 12, 0))


def test_normalize_changes_removes_unchanged_values():
    result = _normalize_changes(
        [
            {"field_name": "name", "old_value": "Старое", "new_value": "Новое"},
            {"field_name": "type", "old_value": "A", "new_value": "A"},
        ]
    )
    assert result == [
        {
            "field_name": "name",
            "field_label": "name",
            "old_value": "Старое",
            "new_value": "Новое",
        }
    ]


def test_normalize_changes_rejects_duplicate_fields():
    try:
        _normalize_changes(
            [
                {"field_name": "name", "old_value": "A", "new_value": "B"},
                {"field_name": "name", "old_value": "B", "new_value": "C"},
            ]
        )
    except ValueError as exc:
        assert "несколько раз" in str(exc)
    else:
        raise AssertionError("Duplicate fields must be rejected")
