"""Access rules for the QGIS ingest API (internal host only)."""

from django.conf import settings


def request_host_name(request) -> str:
    return (request.get_host() or "").split(":")[0].strip().lower()


def qgis_api_host_allowed(request) -> bool:
    allowed = getattr(settings, "APPROVAL_QGIS_ALLOWED_HOSTS", None) or []
    if not allowed:
        return True
    host = request_host_name(request)
    return host in {item.lower() for item in allowed}
