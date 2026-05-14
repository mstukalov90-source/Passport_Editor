from django.db import migrations, models


def _quote_ident(identifier):
    return '"' + str(identifier).replace('"', '""') + '"'


def _resolve_id_names_columns(cursor, table_name):
    """Return (id_field, name_field) using the same discovery rules as views._get_id_names_lookup_context."""
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = %s
        LIMIT 1
        """,
        [table_name],
    )
    if not cursor.fetchone():
        return None, None

    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
        """,
        [table_name],
    )
    columns = {row[0] for row in cursor.fetchall()}
    lowered = {column.lower(): column for column in columns}

    id_candidates = [
        'OwnerLegalPersonId',
        'CustomerLegalPersonId',
        'DepartmentLegalPersonId',
        'LegalPersonId',
        'id',
    ]
    name_candidates = ['name', 'Name', 'title', 'Title', 'full_name', 'short_name']

    id_field = None
    for candidate in id_candidates:
        key = candidate.lower()
        if key in lowered:
            id_field = lowered[key]
            break
    if not id_field:
        id_like = [column for column in columns if column.lower().endswith('id')]
        id_field = id_like[0] if id_like else None

    name_field = None
    for candidate in name_candidates:
        key = candidate.lower()
        if key in lowered:
            name_field = lowered[key]
            break
    if not name_field:
        name_like = [column for column in columns if 'name' in column.lower()]
        name_field = name_like[0] if name_like else None

    return id_field, name_field


def _hood_scope_backfill(apps, schema_editor, *, set_true):
    from django.conf import settings

    table = getattr(settings, 'GIS_ID_NAMES_TABLE', 'id_names')
    connection = schema_editor.connection
    value = set_true
    pattern = '%жилищник%'
    with connection.cursor() as cursor:
        id_field, name_field = _resolve_id_names_columns(cursor, table)
        if not id_field or not name_field:
            return
        t = _quote_ident(table)
        id_col = _quote_ident(id_field)
        name_col = _quote_ident(name_field)
        sql = f"""
            UPDATE users u
            SET hood_scope = %s
            FROM {t} n
            WHERE u."OwnerLegalPersonId" IS NOT NULL
              AND u."OwnerLegalPersonId"::text = n.{id_col}::text
              AND n.{name_col}::text ILIKE %s
        """
        cursor.execute(sql, [value, pattern])


def forward_hood_scope_sql(apps, schema_editor):
    _hood_scope_backfill(apps, schema_editor, set_true=True)


def reverse_hood_scope_sql(apps, schema_editor):
    _hood_scope_backfill(apps, schema_editor, set_true=False)


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0012_create_hood_table'),
    ]

    operations = [
        migrations.AddField(
            model_name='externaluser',
            name='hood_scope',
            field=models.BooleanField(default=False),
        ),
        migrations.RunPython(forward_hood_scope_sql, reverse_hood_scope_sql),
    ]
