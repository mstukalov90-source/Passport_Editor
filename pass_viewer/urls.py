from django.urls import path

from .views import (
    add_object,
    check_new_object_relations,
    delete_owned_object,
    export_geometry,
    export_new_object_geometry,
    home,
    main,
    open_owned_object,
    save_new_object,
)

urlpatterns = [
    path('', home, name='home'),
    path('add-object/', add_object, name='add_object'),
    path('add-object/check-relations/', check_new_object_relations, name='check_new_object_relations'),
    path('add-object/export-geometry/', export_new_object_geometry, name='export_new_object_geometry'),
    path('add-object/save/', save_new_object, name='save_new_object'),
    path('owned/open/', open_owned_object, name='open_owned_object'),
    path('owned/delete/', delete_owned_object, name='delete_owned_object'),
    path('main/', main, name='main'),
    path('main/export-geometry/', export_geometry, name='export_geometry'),
]
