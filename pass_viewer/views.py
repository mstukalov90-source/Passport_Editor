import json
import uuid
import zipfile
from pathlib import Path

import psycopg2
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.db import connection
from django.views.decorators.http import require_POST
from osgeo import ogr, osr

from .forms import EntryPointForm


def _quote_ident(identifier):
    return '"' + str(identifier).replace('"', '""') + '"'


def _resolve_column_name(cursor, table_name, preferred_name):
    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [table_name, preferred_name],
    )
    row = cursor.fetchone()
    return row[0] if row else preferred_name


def _get_current_user_owner_id(username):
    db = settings.EXTERNAL_USERS_DB
    users_table = getattr(settings, 'EXTERNAL_USERS_TABLE', 'users')
    login_field_pref = getattr(settings, 'EXTERNAL_USERS_LOGIN_FIELD', 'login')
    owner_field_pref = getattr(settings, 'EXTERNAL_USERS_OWNER_FIELD', 'OwnerLegalPersonId')

    with psycopg2.connect(
        dbname=db['NAME'],
        user=db['USER'],
        password=db['PASSWORD'],
        host=db['HOST'],
        port=db['PORT'],
    ) as conn:
        with conn.cursor() as cursor:
            login_field = _resolve_column_name(cursor, users_table, login_field_pref)
            owner_field = _resolve_column_name(cursor, users_table, owner_field_pref)
            query = (
                f"SELECT {_quote_ident(owner_field)} FROM {_quote_ident(users_table)} "
                f"WHERE {_quote_ident(login_field)} = %s LIMIT 1"
            )
            cursor.execute(query, [username])
            row = cursor.fetchone()
            return row[0] if row else None


def _get_owned_objects(owner_legal_person_id):
    table = settings.GIS_OBJECT_TABLE
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
        query = (
            f"SELECT ctid::text, {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, "
            f"{_quote_ident(request_id_field)}::text "
            f"FROM {_quote_ident(table)} "
            f"WHERE {_quote_ident(owner_field)} = %s "
            f"ORDER BY {_quote_ident(name_field)} ASC NULLS LAST, {_quote_ident(rootid_field)} ASC "
            f"LIMIT 500"
        )
        cursor.execute(query, [owner_legal_person_id])
        rows = cursor.fetchall()

    return [
        {
            'object_key': row[0],
            'rootid': row[1],
            'name': row[2] or '',
            'request_id': row[3] or '',
        }
        for row in rows
    ]


def _build_where_clause(entry_point, rootid_field, name_field):
    raw_rootid = (entry_point.get('rootid') or '').strip()
    if raw_rootid.lower() in {'none', 'null'}:
        raw_rootid = ''

    if raw_rootid:
        # Compare as text so rootid can be safely passed from UI.
        return f"{rootid_field}::text = %s", [raw_rootid]
    return f"{name_field} ILIKE %s", [(entry_point.get('name') or '').strip()]


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
    intersects_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_Intersects("
        f"   t.{geom_field},"
        "   s.geom"
        " ) AND NOT ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), neighbors AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM neighbors"
    )
    nearby_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), nearby AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_DWithin("
        f"   t.{geom_field}::geography,"
        "   s.geom::geography, 10"
        " ) AND NOT ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " ) AND NOT ST_Intersects("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM nearby"
    )

    with connection.cursor() as cursor:
        cursor.execute(selected_sql, where_params)
        selected_row = cursor.fetchone()
        selected_geometry = selected_row[0] if selected_row else None
        selected_rootid = selected_row[1] if selected_row else None
        selected_name = selected_row[2] if selected_row else None
        if not selected_geometry:
            return None

        cursor.execute(intersects_sql, where_params)
        intersects_row = cursor.fetchone()

        cursor.execute(touches_sql, where_params)
        touches_row = cursor.fetchone()

        cursor.execute(nearby_sql, where_params)
        nearby_row = cursor.fetchone()

    return {
        'selected': selected_geometry,
        'selected_rootid': selected_rootid,
        'selected_name': selected_name,
        'intersects': intersects_row[0] if intersects_row else None,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
    }


def _export_geometry_files(geometry, properties=None):
    properties = properties or {}
    export_properties = {
        'name': (properties.get('name') or ''),
        'OwnerLegalPersonId': (
            None if properties.get('OwnerLegalPersonId') is None else str(properties.get('OwnerLegalPersonId'))
        ),
        'request_id': (properties.get('request_id') or ''),
    }

    export_root = Path(settings.MEDIA_ROOT) / 'exports'
    export_root.mkdir(parents=True, exist_ok=True)
    export_id = uuid.uuid4().hex
    export_dir = export_root / export_id
    export_dir.mkdir(parents=True, exist_ok=True)

    feature = {'type': 'Feature', 'properties': export_properties, 'geometry': geometry}
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
    layer.CreateField(ogr.FieldDefn('name', ogr.OFTString))
    layer.CreateField(ogr.FieldDefn('owner_id', ogr.OFTString))
    layer.CreateField(ogr.FieldDefn('request_id', ogr.OFTString))
    definition = layer.GetLayerDefn()
    ogr_feature = ogr.Feature(definition)
    ogr_feature.SetField('id', 1)
    ogr_feature.SetField('name', export_properties.get('name') or '')
    ogr_feature.SetField('owner_id', export_properties.get('OwnerLegalPersonId') or '')
    ogr_feature.SetField('request_id', export_properties.get('request_id') or '')
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


def _get_new_object_relations(geometry):
    table = settings.GIS_OBJECT_TABLE
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    geometry_json = json.dumps(geometry)

    intersects_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    nearby_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name FROM {table} t, input i"
        f" WHERE ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object('rootid', rootid::text, 'name', name::text)"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )

    with connection.cursor() as cursor:
        cursor.execute(intersects_sql, [geometry_json])
        intersects_row = cursor.fetchone()
        cursor.execute(touches_sql, [geometry_json])
        touches_row = cursor.fetchone()
        cursor.execute(nearby_sql, [geometry_json])
        nearby_row = cursor.fetchone()

    return {
        'intersects': intersects_row[0] if intersects_row else None,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
    }


def _ensure_request_id_column(cursor, table_name, request_id_field):
    cursor.execute(
        f"ALTER TABLE {_quote_ident(table_name)} "
        f"ADD COLUMN IF NOT EXISTS {_quote_ident(request_id_field)} text"
    )


def _create_new_object(username, geometry, name, request_id):
    owner_id = _get_current_user_owner_id(username)
    if owner_id is None:
        raise ValueError('Не найден OwnerLegalPersonId пользователя в users_db.')

    table = settings.GIS_OBJECT_TABLE
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            f"{_quote_ident(rootid_field)}, "
            f"{_quote_ident(name_field)}, "
            f"{_quote_ident(owner_field)}, "
            f"{_quote_ident(request_id_field)}, "
            f"{_quote_ident(geom_field)}"
            ") VALUES (%s, %s, %s, %s, ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))"
        )
        cursor.execute(insert_query, [None, name, owner_id, request_id, json.dumps(geometry)])
    return owner_id


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

    owner_id = None
    owned_objects = []
    owned_objects_error = None
    try:
        owner_id = _get_current_user_owner_id(request.user.username)
        if owner_id is not None:
            owned_objects = _get_owned_objects(owner_id)
    except Exception:
        owned_objects_error = (
            'Не удалось получить список объектов пользователя. '
            'Проверьте поле OwnerLegalPersonId в users_db и geodb.'
        )

    return render(
        request,
        'pass_viewer/home.html',
        {
            'form': form,
            'owner_id': owner_id,
            'owned_objects': owned_objects,
            'owned_objects_error': owned_objects_error,
        },
    )


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
            'intersects_geometry_json': layers['intersects'] if layers else None,
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


@login_required
@require_POST
def export_new_object_geometry(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)
    properties = payload.get('properties') or {}
    if not isinstance(properties, dict):
        properties = {}

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry, properties=properties)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Ошибка формирования файлов экспорта.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'geojson_url': geojson_url, 'shapefile_url': shapefile_url})


@login_required
@require_POST
def save_new_object(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    name = (payload.get('name') or '').strip()
    request_id = (payload.get('request_id') or '').strip()
    if not name:
        return JsonResponse({'ok': False, 'error': 'Укажите название (name).'}, status=400)
    if not request_id:
        return JsonResponse({'ok': False, 'error': 'Укажите номер заявки (request_id).'}, status=400)

    try:
        owner_id = _create_new_object(
            username=request.user.username,
            geometry=geometry,
            name=name,
            request_id=request_id,
        )
    except ValueError as exc:
        return JsonResponse({'ok': False, 'error': str(exc)}, status=400)
    except Exception:
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить объект в geodb.'}, status=500)

    return JsonResponse({'ok': True, 'owner_id': owner_id})


@login_required
@require_POST
def open_owned_object(request):
    rootid = (request.POST.get('rootid') or '').strip()
    name = (request.POST.get('name') or '').strip()
    if rootid.lower() in {'none', 'null'}:
        rootid = ''
    if not rootid and not name:
        return redirect('home')

    request.session['entry_point'] = {
        'rootid': rootid,
        'name': '' if rootid else name,
    }
    return redirect('main')


@login_required
@require_POST
def delete_owned_object(request):
    object_key = (request.POST.get('object_key') or '').strip()
    if not object_key:
        return redirect('home')

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return redirect('home')

    table = settings.GIS_OBJECT_TABLE
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
        delete_query = (
            f"DELETE FROM {_quote_ident(table)} "
            f"WHERE ctid = %s::tid "
            f"  AND {_quote_ident(owner_field)} = %s "
            f"  AND {_quote_ident(rootid_field)} IS NULL "
            f"  AND {_quote_ident(request_id_field)} IS NOT NULL"
        )
        cursor.execute(delete_query, [object_key, owner_id])

    return redirect('home')


@login_required
def add_object(request):
    return render(request, 'pass_viewer/add_object.html')


@login_required
@require_POST
def check_new_object_relations(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    try:
        layers = _get_new_object_relations(geometry)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Не удалось получить связанные объекты из PostGIS.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'layers': layers})
