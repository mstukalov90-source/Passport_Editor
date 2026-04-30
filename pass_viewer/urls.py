from django.urls import path

from .views import (
    add_object,
    add_recap,
    auto_remove_intersections,
    check_dgi_intersections,
    check_new_object_relations,
    delete_owned_object,
    export_geometry,
    export_new_object_geometry,
    home,
    main,
    open_owned_object,
    save_recap_object,
    save_new_object,
)

urlpatterns = [
    path('', home, name='home'),
    path('add-object/', add_object, name='add_object'),
    path('add-recap/', add_recap, name='add_recap'),
    path('add-object/check-relations/', check_new_object_relations, name='check_new_object_relations'),
    path('add-object/check-dgi-intersections/', check_dgi_intersections, name='check_dgi_intersections'),
    path('add-object/auto-remove-intersections/', auto_remove_intersections, name='auto_remove_intersections'),
    path('add-object/export-geometry/', export_new_object_geometry, name='export_new_object_geometry'),
    path('add-object/save/', save_new_object, name='save_new_object'),
    path('add-recap/save/', save_recap_object, name='save_recap_object'),
    path('owned/open/', open_owned_object, name='open_owned_object'),
    path('owned/delete/', delete_owned_object, name='delete_owned_object'),
    path('main/', main, name='main'),
    path('main/export-geometry/', export_geometry, name='export_geometry'),
]
