from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0002_create_recaps_table'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                CREATE TABLE IF NOT EXISTS id_names (
                    "LegalPersonId" text NOT NULL,
                    "name" text NOT NULL,
                    CONSTRAINT id_names_pkey PRIMARY KEY ("LegalPersonId")
                );

                COMMENT ON TABLE id_names IS
                    'Справочник: идентификатор юр. лица (как в OwnerLegalPersonId / CustomerLegalPersonId / DepartmentLegalPersonId) и отображаемое имя';
            """,
            reverse_sql="""
                DROP TABLE IF EXISTS id_names;
            """,
        ),
    ]
