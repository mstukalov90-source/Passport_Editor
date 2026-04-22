from django.urls import path

from .views import export_geometry, home, main

urlpatterns = [
    path('', home, name='home'),
    path('main/', main, name='main'),
    path('main/export-geometry/', export_geometry, name='export_geometry'),
]
