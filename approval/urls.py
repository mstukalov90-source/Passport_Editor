from django.urls import path

from . import api_views, qgis_api_views
from .views import landing

app_name = "approval"

urlpatterns = [
    path("", landing, name="landing"),
    # QGIS API (host allowlist + login query/body param `user`)
    path("api/qgis/approves/", qgis_api_views.api_qgis_approves, name="api_qgis_upsert_approve"),
    path(
        "api/qgis/approves/by-guid/<uuid:incoming_guid>/",
        qgis_api_views.api_qgis_approve_by_guid,
        name="api_qgis_approve_by_guid",
    ),
    path(
        "api/qgis/approves/<uuid:approve_id>/",
        qgis_api_views.api_qgis_approve_detail,
        name="api_qgis_approve_detail",
    ),
    path(
        "api/qgis/approves/<uuid:approve_id>/geometries/",
        qgis_api_views.api_qgis_approve_geometries,
        name="api_qgis_approve_geometries",
    ),
    path(
        "api/qgis/cases/<uuid:case_id>/",
        qgis_api_views.api_qgis_case_detail,
        name="api_qgis_case_detail",
    ),
    path(
        "api/qgis/cases/<uuid:case_id>/messages/",
        qgis_api_views.api_qgis_post_message,
        name="api_qgis_post_message",
    ),
    path(
        "api/qgis/cases/<uuid:case_id>/approve/",
        qgis_api_views.api_qgis_approve_case,
        name="api_qgis_approve_case",
    ),
    path(
        "api/qgis/cases/<uuid:case_id>/revoke/",
        qgis_api_views.api_qgis_revoke_case,
        name="api_qgis_revoke_case",
    ),
    # Web session API
    path("api/bootstrap/", api_views.api_bootstrap, name="api_bootstrap"),
    path("api/cases/", api_views.api_create_case, name="api_create_case"),
    path("api/cases/<uuid:case_id>/", api_views.api_case_detail, name="api_case_detail"),
    path("api/cases/<uuid:case_id>/messages/", api_views.api_post_message, name="api_post_message"),
    path("api/cases/<uuid:case_id>/approve/", api_views.api_approve_case, name="api_approve_case"),
    path("api/cases/<uuid:case_id>/revoke/", api_views.api_revoke_case, name="api_revoke_case"),
    path(
        "api/cases/<uuid:case_id>/change-owner/",
        api_views.api_change_case_owner,
        name="api_change_case_owner",
    ),
    path(
        "api/cases/<uuid:case_id>/participants/",
        api_views.api_add_case_participant,
        name="api_add_case_participant",
    ),
    path(
        "api/messages/<int:message_id>/reactions/",
        api_views.api_message_reaction,
        name="api_message_reaction",
    ),
    path("api/attachments/<int:attachment_id>/", api_views.api_download_attachment, name="api_download_attachment"),
    path("approves/delete/", api_views.delete_approve, name="delete_approve"),
]
