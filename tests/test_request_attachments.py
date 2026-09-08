from __future__ import annotations

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse


@pytest.mark.django_db
def test_request_side_urls_resolve() -> None:
    assert reverse("request_ods_status") == "/add-object/request-status/"
    assert reverse("request_bid_comments") == "/add-object/request-comments/"
    assert reverse("list_request_attachments") == "/add-object/request-attachments/"
    assert reverse("upload_request_attachment") == "/add-object/request-attachments/upload/"


@pytest.mark.django_db
def test_ods_status_anonymous_redirects(client) -> None:
    response = client.get(reverse("request_ods_status"), {"request_id": "1"})
    assert response.status_code == 302
    assert "/accounts/login/" in response.url


@pytest.mark.django_db
def test_upload_rejects_missing_request_id(client, e2e_credentials) -> None:
    assert client.login(
        username=e2e_credentials["username"],
        password=e2e_credentials["password"],
    )
    pdf = SimpleUploadedFile("a.pdf", b"%PDF-1.4", content_type="application/pdf")
    response = client.post(reverse("upload_request_attachment"), {"file": pdf})
    assert response.status_code == 400
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_upload_rejects_disallowed_extension(client, e2e_credentials) -> None:
    assert client.login(
        username=e2e_credentials["username"],
        password=e2e_credentials["password"],
    )
    txt = SimpleUploadedFile("note.txt", b"hello", content_type="text/plain")
    response = client.post(
        reverse("upload_request_attachment"),
        {"request_id": "12345", "file": txt},
    )
    assert response.status_code == 400
    body = response.json()
    assert body["ok"] is False
    assert "PDF" in body["error"]


@pytest.mark.django_db
def test_list_attachments_empty_without_brid(client, e2e_credentials) -> None:
    assert client.login(
        username=e2e_credentials["username"],
        password=e2e_credentials["password"],
    )
    response = client.get(reverse("list_request_attachments"))
    assert response.status_code == 200
    assert response.json() == {"ok": True, "files": []}
