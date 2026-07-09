from django.urls import path

from . import api_views
from .views import landing

app_name = "approval"

urlpatterns = [
    path("", landing, name="landing"),
    path("api/bootstrap/", api_views.api_bootstrap, name="api_bootstrap"),
    path("api/cases/", api_views.api_create_case, name="api_create_case"),
    path("api/cases/<uuid:case_id>/", api_views.api_case_detail, name="api_case_detail"),
    path("api/cases/<uuid:case_id>/messages/", api_views.api_post_message, name="api_post_message"),
    path("api/cases/<uuid:case_id>/approve/", api_views.api_approve_case, name="api_approve_case"),
    path("api/attachments/<int:attachment_id>/", api_views.api_download_attachment, name="api_download_attachment"),
]
