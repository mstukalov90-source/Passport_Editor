import json
import uuid
import zipfile
from pathlib import Path

from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.db import connection
from django.views.decorators.http import require_POST
from osgeo import ogr, osr

from .forms import EntryPointForm


def _build_where_clause(entry_point, rootid_field, name_field):
    if entry_point.get('rootid'):
        return f"{rootid_field} = %s", [entry_point['rootid']]
    return f"{name_field} ILIKE %s", [entry_point['name']]


def _get_map_layers(entry_point):
    table = settings.GIS_OBJECT_TABLE
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    geom_field = settings.GIS_OBJECT_GEOM_FIELD

    where_clause, where_params = _build_where_clause(entry_point, rootid_field, name_field)
    selected_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {rootid_field} AS rootid, {name_field} AS name, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        ") "
        "SELECT ST_AsGeoJSON(geom), rootid::text, name::text FROM selected"
    )
    touches_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), neighbors AS ("
        f" SELECT t.{geom_field} AS geom FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
        ") "
        "SELECT ST_AsGeoJSON(ST_Collect(geom)) FROM neighbors"
    )
    nearby_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), nearby AS ("
        f" SELECT t.{geom_field} AS geom FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_DWithin("
        f"   t.{geom_field}::geography,"
        "   s.geom::geography, 10"
        " ) AND NOT ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
        ") "
        "SELECT ST_AsGeoJSON(ST_Collect(geom)) FROM nearby"
    )

    with connection.cursor() as cursor:
        cursor.execute(selected_sql, where_params)
        selected_row = cursor.fetchone()
        selected_geometry = selected_row[0] if selected_row else None
        selected_rootid = selected_row[1] if selected_row else None
        selected_name = selected_row[2] if selected_row else None
        if not selected_geometry:
            return None

        cursor.execute(touches_sql, where_params)
        touches_row = cursor.fetchone()

        cursor.execute(nearby_sql, where_params)
        nearby_row = cursor.fetchone()

    return {
        'selected': selected_geometry,
        'selected_rootid': selected_rootid,
        'selected_name': selected_name,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
    }


def _export_geometry_files(geometry):
    export_root = Path(settings.MEDIA_ROOT) / 'exports'
    export_root.mkdir(parents=True, exist_ok=True)
    export_id = uuid.uuid4().hex
    export_dir = export_root / export_id
    export_dir.mkdir(parents=True, exist_ok=True)

    feature = {'type': 'Feature', 'properties': {}, 'geometry': geometry}
    feature_collection = {'type': 'FeatureCollection', 'features': [feature]}
    geojson_path = export_dir / 'edited_object.geojson'
    geojson_path.write_text(json.dumps(feature_collection, ensure_ascii=False), encoding='utf-8')

    shp_path = export_dir / 'edited_object.shp'
    driver = ogr.GetDriverByName('ESRI Shapefile')
    datasource = driver.CreateDataSource(str(shp_path))
    spatial_ref = osr.SpatialReference()
    spatial_ref.ImportFromEPSG(4326)
    layer = datasource.CreateLayer('edited_object', spatial_ref, ogr.wkbUnknown)
    layer.CreateField(ogr.FieldDefn('id', ogr.OFTInteger))
    definition = layer.GetLayerDefn()
    ogr_feature = ogr.Feature(definition)
    ogr_feature.SetField('id', 1)
    ogr_geometry = ogr.CreateGeometryFromJson(json.dumps(geometry))
    ogr_feature.SetGeometry(ogr_geometry)
    layer.CreateFeature(ogr_feature)
    ogr_feature = None
    datasource = None

    zip_path = export_dir / 'edited_object_shp.zip'
    with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        for ext in ('shp', 'shx', 'dbf', 'prj', 'cpg'):
            part = export_dir / f'edited_object.{ext}'
            if part.exists():
                archive.write(part, arcname=part.name)

    base_url = settings.MEDIA_URL.rstrip('/')
    geojson_url = f"{base_url}/exports/{export_id}/edited_object.geojson"
    shapefile_url = f"{base_url}/exports/{export_id}/edited_object_shp.zip"
    return geojson_url, shapefile_url


@login_required
def home(request):
    if request.method == 'POST':
        form = EntryPointForm(request.POST)
        if form.is_valid():
            request.session['entry_point'] = {
                'rootid': form.cleaned_data.get('rootid', ''),
                'name': form.cleaned_data.get('name', ''),
            }
            return redirect('main')
    else:
        form = EntryPointForm()

    return render(request, 'pass_viewer/home.html', {'form': form})


@login_required
def main(request):
    entry_point = request.session.get('entry_point')
    if not entry_point:
        return redirect('home')

    layers = None
    query_error = None

    try:
        layers = _get_map_layers(entry_point)
    except Exception:
        query_error = (
            'Не удалось получить геометрию из PostGIS. '
            'Проверьте настройки таблицы/полей в settings.py.'
        )

    return render(
        request,
        'pass_viewer/main.html',
        {
            'entry_point': entry_point,
            'map_layers': layers,
            'selected_geometry_json': layers['selected'] if layers else None,
            'selected_rootid': layers['selected_rootid'] if layers else None,
            'selected_name': layers['selected_name'] if layers else None,
            'touches_geometry_json': layers['touches'] if layers else None,
            'nearby_geometry_json': layers['nearby'] if layers else None,
            'query_error': query_error,
        },
    )


@login_required
@require_POST
def export_geometry(request):
    entry_point = request.session.get('entry_point')
    if not entry_point:
        return JsonResponse({'ok': False, 'error': 'Сначала выберите объект.'}, status=400)

    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Ошибка формирования файлов экспорта.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'geojson_url': geojson_url, 'shapefile_url': shapefile_url})
