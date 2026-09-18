from django.urls import path

from . import qgis_api_views, views

app_name = "recheck"

urlpatterns = [
    path("", views.landing, name="landing"),
    path("api/bootstrap/", views.api_bootstrap, name="api_bootstrap"),
    path("api/map-layer/", views.api_map_layer, name="api_map_layer"),
    path("api/lookup-options/", views.api_lookup_options, name="api_lookup_options"),
    path(
        "api/events/<uuid:event_id>/object-requests/",
        views.api_create_object_request,
        name="api_create_object_request",
    ),
    path("api/events/<uuid:event_id>/messages/", views.api_post_message, name="api_post_message"),
    path("api/events/<uuid:event_id>/approve/", views.api_approve, name="api_approve"),
    path("api/qgis/changes/", qgis_api_views.list_changes, name="qgis_changes"),
    path(
        "api/qgis/requests/<uuid:request_id>/complete/",
        qgis_api_views.complete_request,
        name="qgis_complete_request",
    ),
]
