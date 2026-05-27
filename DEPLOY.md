# Деплой Passport Editor на VPS (Docker)

Краткая памятка, чтобы не терять контекст между сессиями.

## Окружение

| Что | Значение |
|-----|----------|
| Сервер | `77.222.63.161` (SSH пользователь `root`) |
| Каталог на сервере | `/opt/passport_editor_new` |
| Репозиторий | `https://github.com/mstukalov90-source/Passport_Editor.git` |
| Разработка | ветка **`main`** (локально: `/Users/mihail/PY/GeoDjango`) |
| Прод | ветка **`deploy/vps-docker`** (`docker-compose.yml`, `.env`, правки под VPS) |

**SSH:** ключ на локальной машине, например `~/PY/id_rsa/id_rsa` (в чат и в git не класть).

| Контейнер | Назначение |
|-----------|------------|
| `passport_web` | Django + Gunicorn, снаружи **порт 80** → `8000` внутри |
| `passport_db` | PostGIS 16, снаружи **5433** → `5432` внутри |
| `portainer` | панель Docker (локально на сервере) |

Секреты: **`/opt/passport_editor_new/.env`** (`DJANGO_*`, `POSTGIS_*` и т.д.) — не в репозитории.

На VPS в `.env` обязательно: **`DJANGO_ENABLE_ADMIN=0`** (маршрут `/admin/` не монтируется).

**Локальная БД для разработки:** Docker-контейнер `postgis-db`, БД `geodb` (как на проде по имени).

## Две ветки — зачем так

- **`main`** — весь код, миграции, шаблоны, `pass_viewer/static/…`. **Без** `docker-compose.yml`.
- **`deploy/vps-docker`** — то же после merge из `main`, плюс:
  - `docker-compose.yml` (migrate → **collectstatic** → gunicorn);
  - `pass_map/urls.py` с раздачей **`/media/`** и **`/static/`** при `DEBUG=False`;
  - зафиксированные merge-коммиты продакшена.

После деплоя для разработки снова: `git checkout main`.

## Обычное обновление (только код, БД не трогаем)

Подходит, если схема и данные на проде уже актуальны (только правки в Python/шаблонах/статике).

### 1. Локально (из репозитория GeoDjango)

```bash
cd /Users/mihail/PY/GeoDjango   # или свой путь к клону
git fetch origin main deploy/vps-docker
git checkout deploy/vps-docker
git reset --hard origin/deploy/vps-docker
git merge -X theirs --no-edit origin/main   # при конфликтах — код из main
git push origin deploy/vps-docker
```

При merge из `main` в деплой-ветку **не затирать** без проверки:
- `docker-compose.yml` (должен остаться `collectstatic`);
- `pass_map/urls.py` (маршруты `media/` и `static/` через `serve`).

Если после merge их нет — вернуть из предыдущего коммита `deploy/vps-docker` или дописать вручную (см. раздел «Продакшен: статика и media»).

### 2. На VPS

```bash
cd /opt/passport_editor_new
git fetch origin deploy/vps-docker
git reset --hard origin/deploy/vps-docker
docker compose up -d --build
```

### 3. Проверка

```bash
docker logs --tail 50 passport_web
```

Ожидаемо в логах:
- `Running migrations` → `No migrations to apply` (или список применённых);
- `X static files copied to '/app/staticfiles'` (или `unmodified`);
- `Starting gunicorn`.

Снаружи:

```bash
curl -I http://77.222.63.161/
curl -I http://77.222.63.161/static/pass_viewer/js/home.js   # ожидается 200
curl -s -o /dev/null -w "%{http_code}" http://77.222.63.161/admin/   # ожидается 404
```

### 4. Вернуться к разработке

```bash
git checkout main
git pull origin main
```

## Обновление с полной перезаливкой БД

Когда на локальной машине новые таблицы/столбцы **и заполненные данные**, а на прод нужна копия 1:1.

Примеры таблиц, которые переносились дампом (не исчерпывающий список): `pass_objects`, `hood`, `ods_request`, `oozt`, `rzd`, `dgi`, `odh`, `ozn`, `renew`, `users`, …

1. **Сначала** выкатить код (раздел выше), чтобы версии миграций и приложения совпадали с дампом.
2. Остановить веб, пересоздать `geodb`, залить дамп **без** `--clean` (с `--clean` часто падает на `DROP EXTENSION postgis`).

**На VPS:**

```bash
docker stop passport_web
docker exec passport_db psql -U postgres -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='geodb' AND pid <> pg_backend_pid();"
docker exec passport_db dropdb -U postgres --if-exists geodb
docker exec passport_db createdb -U postgres geodb
```

**С локальной машины** (подставить путь к ключу; контейнер БД должен быть запущен):

```bash
docker exec postgis-db pg_dump -U postgres -d geodb --no-owner --no-privileges \
  | ssh -i ~/.ssh/ВАШ_КЛЮЧ -o IdentitiesOnly=yes root@77.222.63.161 \
  "docker exec -i passport_db psql -v ON_ERROR_STOP=1 -U postgres -d geodb"
```

**Снова поднять веб:**

```bash
ssh -i ~/.ssh/ВАШ_КЛЮЧ root@77.222.63.161 "docker start passport_web"
```

**Сверка данных** (пример — подставить свои таблицы):

```bash
# локально
docker exec postgis-db psql -U postgres -d geodb -At -c \
  "SELECT 'oozt',count(*) FROM oozt UNION ALL SELECT 'rzd',count(*) FROM rzd UNION ALL SELECT 'pass_objects',count(*) FROM pass_objects;"

# на VPS — те же цифры
ssh ... "docker exec passport_db psql -U postgres -d geodb -At -c \"...\""
```

После заливки `passport_web` при старте снова выполнит `migrate` — обычно `No migrations to apply`.

## Продакшен: статика и media

С v1.1.x JS вынесен в `pass_viewer/static/pass_viewer/js/`, в шаблонах — `{% static '…' %}`.

На проде **`DEBUG=False`**, поэтому в **`deploy/vps-docker`** обязательно:

1. **`docker-compose.yml`** — перед Gunicorn:
   ```text
   python manage.py collectstatic --noinput
   ```
2. **`pass_map/urls.py`** — маршруты (помимо `include` приложения):
   ```python
   path('media/<path:path>', serve, {'document_root': settings.MEDIA_ROOT}),
   path('static/<path:path>', serve, {'document_root': settings.STATIC_ROOT}),
   ```

Без этого: карта/форма без JS (404 на `/static/…`) или не качаются экспорты из `/media/exports/…`.

Локально при `runserver` и `DEBUG=True` статика часто отдаётся автоматически; на VPS — только через `collectstatic` + маршруты выше.

## Перезапуск и сброс сессий (зависание / разлогинить всех)

```bash
cd /opt/passport_editor_new
docker compose restart
docker exec passport_db psql -U postgres -d geodb -c \
  "TRUNCATE django_session RESTART IDENTITY CASCADE;"
```

Только веб (без сброса сессий): `docker restart passport_web`.

## Ежедневное обновление `ods_request` (12:00 МСК)

Выгрузка ОДС приходит как `ods_request.json`. Раз в сутки cron проверяет файл в контейнере; если он есть — таблица `ods_request` перезаписывается, файл удаляется. Если файла нет — запуск завершается без ошибки (БД не трогается).

**Команда (внутри контейнера или локально):**

```bash
python manage.py sync_ods_request_if_present
python manage.py sync_ods_request_if_present --dry-run   # только подсчёт строк
```

**Положить файл на VPS перед 12:00** (путь в контейнере — `/app/ods_request.json`):

```bash
docker cp /path/on/host/ods_request.json passport_web:/app/ods_request.json
```

**Cron на хосте** (`crontab -e` у `root`):

```cron
0 12 * * * TZ=Europe/Moscow /opt/passport_editor_new/scripts/sync_ods_request_daily.sh >> /var/log/ods_request_sync.log 2>&1
```

Обёртка: `scripts/sync_ods_request_daily.sh` (вызов `docker exec passport_web …`). После деплоя кода: `chmod +x /opt/passport_editor_new/scripts/sync_ods_request_daily.sh`.

**Проверка вручную:**

```bash
/opt/passport_editor_new/scripts/sync_ods_request_daily.sh
tail -20 /var/log/ods_request_sync.log
```

При ошибке импорта (битый JSON) файл **не** удаляется; транзакция откатывает изменения в БД.

## Ночная уборка (04:20 МСК)

Три задания cron: старые файлы экспорта, «сироты» в GIS-таблицах и точки комментариев без заявки в GIS.

| Задача | Команда | Условие |
|--------|---------|---------|
| `media/exports` | `cleanup_media_exports` | файлы старше **7** суток |
| `pass_objects`, `odh`, `ozn` | `cleanup_orphan_gis_rows` | непустой `request_id` нет в `ods_request."BrId"`, `created_at` старше **40** суток |
| `pass_comment_points` | `cleanup_orphan_comment_points` | непустой `request_id` нет ни в `pass_objects`, ни в `odh`, ни в `ozn`, `created_at` старше **40** суток |

**Команды (внутри контейнера или локально):**

```bash
python manage.py cleanup_media_exports
python manage.py cleanup_media_exports --dry-run

python manage.py cleanup_orphan_gis_rows
python manage.py cleanup_orphan_gis_rows --dry-run

python manage.py cleanup_orphan_comment_points
python manage.py cleanup_orphan_comment_points --dry-run
```

**Cron на хосте** (`crontab -e` у `root`):

```cron
20 4 * * * TZ=Europe/Moscow /opt/passport_editor_new/scripts/cleanup_media_exports_daily.sh >> /var/log/cleanup_media_exports.log 2>&1
20 4 * * * TZ=Europe/Moscow /opt/passport_editor_new/scripts/cleanup_orphan_gis_daily.sh >> /var/log/cleanup_orphan_gis.log 2>&1
20 4 * * * TZ=Europe/Moscow /opt/passport_editor_new/scripts/cleanup_orphan_comment_points_daily.sh >> /var/log/cleanup_orphan_comment_points.log 2>&1
```

Обёртки: `scripts/cleanup_media_exports_daily.sh`, `scripts/cleanup_orphan_gis_daily.sh`, `scripts/cleanup_orphan_comment_points_daily.sh`. После деплоя:

```bash
chmod +x /opt/passport_editor_new/scripts/cleanup_media_exports_daily.sh
chmod +x /opt/passport_editor_new/scripts/cleanup_orphan_gis_daily.sh
chmod +x /opt/passport_editor_new/scripts/cleanup_orphan_comment_points_daily.sh
```

**Проверка вручную:**

```bash
/opt/passport_editor_new/scripts/cleanup_media_exports_daily.sh
/opt/passport_editor_new/scripts/cleanup_orphan_gis_daily.sh
/opt/passport_editor_new/scripts/cleanup_orphan_comment_points_daily.sh
tail -20 /var/log/cleanup_media_exports.log
tail -20 /var/log/cleanup_orphan_gis.log
tail -20 /var/log/cleanup_orphan_comment_points.log
```

Строки с пустым `request_id` не удаляются. Таблицы `recaps`, `dgi`, `renew` не затрагиваются.

## Известные нюансы

- **Ветка `main` без `docker-compose.yml`** — деплой только через **`deploy/vps-docker`**.
- **Merge `main` → deploy:** при конфликтах в шаблонах/views обычно берём **`main`** (`-X theirs` при checkout на `deploy/vps-docker` и merge `origin/main`). Файлы инфраструктуры деплоя — проверять руками.
- **Чистая БД без дампа:** ранние миграции завязаны на `pass_objects` / `odh`; для пустого прода надёжнее полный дамп с dev-машины, если нужны реальные данные.
- **Push с VPS на GitHub** часто не настроен (HTTPS без токена) — коммиты в `deploy/vps-docker` делаем **локально** и пушим оттуда.
- **Долгая заливка БД:** SSH может оборваться в конце; если счётчики строк на VPS совпали с локальными — дамп применился; при необходимости `docker start passport_web`.

## Безопасность

- Не коммитить `.env`, пароли БД, `DJANGO_SECRET_KEY`.
- Не дублировать в документации логины/пароли пользователей.

---

*Последнее согласованное состояние продакшена: merge `main` (v1.1.6+) в `deploy/vps-docker`, `collectstatic`, дамп `geodb` с локального `postgis-db`.*
