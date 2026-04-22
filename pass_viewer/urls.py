from django.urls import path

from .views import export_geometry, home, main, open_owned_object

urlpatterns = [
    path('', home, name='home'),
    path('owned/open/', open_owned_object, name='open_owned_object'),
    path('main/', main, name='main'),
    path('main/export-geometry/', export_geometry, name='export_geometry'),
]
