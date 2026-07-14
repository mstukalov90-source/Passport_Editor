from django.urls import path

from . import api_views
from .views import landing

app_name = "approval"

urlpatterns = [
    path("", landing, name="landing"),
    path("api/qgis/approves/", api_views.api_qgis_upsert_approve, name="api_qgis_upsert_approve"),
    path("api/bootstrap/", api_views.api_bootstrap, name="api_bootstrap"),
    path("api/cases/", api_views.api_create_case, name="api_create_case"),
    path("api/cases/<uuid:case_id>/", api_views.api_case_detail, name="api_case_detail"),
    path("api/cases/<uuid:case_id>/messages/", api_views.api_post_message, name="api_post_message"),
    path("api/cases/<uuid:case_id>/approve/", api_views.api_approve_case, name="api_approve_case"),
    path("api/cases/<uuid:case_id>/revoke/", api_views.api_revoke_case, name="api_revoke_case"),
    path(
        "api/messages/<int:message_id>/reactions/",
        api_views.api_message_reaction,
        name="api_message_reaction",
    ),
    path("api/attachments/<int:attachment_id>/", api_views.api_download_attachment, name="api_download_attachment"),
]
