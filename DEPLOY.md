# Деплой Passport Editor (MGGT / Docker)

Краткая памятка, чтобы не терять контекст между сессиями.

## Окружение

| Что | Значение |
|-----|----------|
| **Прод-сервер** | `172.21.197.77` (SSH пользователь `pasp-ssh-user`, Docker через `sudo`) |
| **Публичный URL** | `https://border-ogh.mggt.ru` (TLS на корпоративном reverse-proxy; приложение слушает HTTP :80) |
| Каталог на сервере | `/opt/passport_editor_new` |
| Репозиторий (сервер) | `https://hub.mos.ru/m.stukalov90/Passport_Editor.git` |
| Репозиторий (разработка) | `https://github.com/mstukalov90-source/Passport_Editor.git` |
| Разработка | ветка **`main`** (локально: `/Users/mihail/PY/GeoDjango`) |
| Прод | ветка **`deploy/mggt-docker`** (`docker-compose.yml`, `docker-compose.images.yml`, `.env`) |
| Архив | старый VPS `77.222.63.161`, ветка **`deploy/vps-docker`** — только для отката/истории |

**SSH:** настроенный доступ `pasp-ssh-user@172.21.197.77` (ключи и пароли в чат и в git не класть).

| Контейнер | Назначение |
|-----------|------------|
| `passport_web` | Django + Gunicorn, снаружи **порт 80** → `8000` внутри |
| `passport_db` | PostGIS 16; на хосте **только** `127.0.0.1:5433` → `5432` (не `0.0.0.0`); между контейнерами — `db:5432` |

Отдельный **Nginx в стеке не используется** — `/static/` и `/media/` отдаёт Gunicorn через маршруты в `pass_map/urls.py`. HTTPS терминируется на корпоративном reverse-proxy.

Секреты: **`/opt/passport_editor_new/.env`** (`DJANGO_*`, `POSTGIS_*` и т.д.) — не в репозитории.

**Локальная БД для разработки:** Docker-контейнер `postgis-db` через [`docker-compose.local.yml`](docker-compose.local.yml) (`./scripts/local_postgis_up.sh`), БД `geodb`, порт `5433`. Первичное наполнение: [`scripts/sync_geodb_from_prod.sh`](scripts/sync_geodb_from_prod.sh) (полный `pg_dump` с `172.21.197.77`, прод только читается).

## Переменные `.env` на проде

Файл `/opt/passport_editor_new/.env` (не в git). Минимальный набор:

```text
DJANGO_SECRET_KEY=...
DJANGO_ALLOWED_HOSTS=172.21.197.77,border-ogh.mggt.ru
DJANGO_CSRF_TRUSTED_ORIGINS=https://border-ogh.mggt.ru
DJANGO_USE_X_FORWARDED_HOST=1
DJANGO_ENABLE_ADMIN=0
POSTGIS_DB_HOST=db
POSTGIS_DB_PORT=5432
POSTGIS_DB_NAME=geodb
POSTGIS_DB_USER=postgres
POSTGIS_DB_PASSWORD=...
# GIS_* (производительность карты):
GIS_DEFER_MAP_CONTEXT_LAYERS=1
GIS_ADJACENT_NEARBY_METERS=25
```

- **`DJANGO_ENABLE_ADMIN=0`** — маршрут `/admin/` не монтируется.
- **`DJANGO_CSRF_TRUSTED_ORIGINS`** и **`DJANGO_USE_X_FORWARDED_HOST`** — обязательны для работы через `https://border-ogh.mggt.ru` (proxy headers обрабатываются в `settings.py` на ветке `deploy/mggt-docker`).
- **`APPROVAL_QGIS_ALLOWED_HOSTS`** (опционально) — через какие `Host` принимается `POST /approval/api/qgis/approves/`. По умолчанию `172.21.197.77,127.0.0.1,localhost,testserver`. Публичный домен `border-ogh.mggt.ru` в список **не** добавлять — QGIS вызывает API напрямую по `http://172.21.197.77/...`.
- После изменения `.env` переменные в контейнер подхватываются через **`docker compose ... up -d --force-recreate web`**, а не только `docker restart`.

### RED OS: Docker Hub недоступен

На `172.21.197.77` `docker pull` идёт через `registry.red-soft.ru` и падает. Образы **не тянутся**, а **загружаются** через `docker save` → `scp` → `docker load` (с Mac/CI или из бэкапа). Запуск:

```bash
cd /opt/passport_editor_new
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d
```

Файл [`docker-compose.images.yml`](docker-compose.images.yml) — override образов и монтирование `.:/app` (код с диска после `git pull`).

### Git на MGGT и токен развёртывания (hub.mos.ru)

На hub.mos.ru для этого проекта доступны **токены развёртывания** (Deploy Token), не Deploy keys. На сервере `172.21.197.77` настроено:

- remote: `https://hub.mos.ru/m.stukalov90/Passport_Editor.git`
- учётные данные: `~/.git-credentials` (права `600`), `git config credential.helper store`
- ветка: `deploy/mggt-docker`, каталог `/opt/passport_editor_new`

Токен и имя пользователя токена (**не** название вроде `mggt-…-readonly`, а значение поля «Имя пользователя», например `moshub+deploy-token-…`) **не коммитить** и не писать в этот файл.

**Проверка:**

```bash
cd /opt/passport_editor_new
git fetch origin deploy/mggt-docker
git status -sb
```

#### Создать новый токен (если истёк или заменяете)

1. `https://hub.mos.ru/m.stukalov90/Passport_Editor` → **Settings** → **Repository** → **Deploy tokens**
2. Имя: `mggt-172.21.197.77-readonly`, право **`read_repository`**, без write
3. Сохранить **имя пользователя** и **токен** (показывается один раз)

На сервере обновить `~/.git-credentials` (одна строка):

```text
https://ИМЯ_ПОЛЬЗОВАТЕЛЯ_ТОКЕНА:ТОКЕН@hub.mos.ru
```

```bash
chmod 600 ~/.git-credentials
git config --global credential.helper store
```

#### Первичная привязка каталога (если git ещё не инициализирован)

`.env` на диске — **не перезаписывать** (в `.gitignore`).

```bash
cd /opt/passport_editor_new
git init
git remote add origin https://hub.mos.ru/m.stukalov90/Passport_Editor.git
git fetch origin deploy/mggt-docker
git checkout -f -B deploy/mggt-docker origin/deploy/mggt-docker
```

## Ветки — зачем так

- **`main`** — весь код, миграции, шаблоны, `pass_viewer/static/…`. **Без** `docker-compose.yml`.
- **`deploy/mggt-docker`** — прод на **172.21.197.77** (RED OS): merge из `main` плюс:
  - `docker-compose.yml`, **`docker-compose.images.yml`** (образы без Docker Hub);
  - `pass_map/urls.py` с раздачей **`/media/`** и **`/static/`** при `DEBUG=False`;
  - `pass_map/settings.py` с `ALLOWED_HOSTS`, `CSRF_TRUSTED_ORIGINS`, proxy headers из `.env`.
- **`deploy/vps-docker`** — архивный прод на **77.222.63.161**; не смешивать с MGGT.

После работы с деплоем: `git checkout main`.

## История миграции (2026-05)

Первичный перенос на MGGT выполнен в мае 2026:

1. Код и образы (`postgis/postgis:16-3.4`, `passport_editor_new-web:latest`) перенесены со старого VPS.
2. `.env` настроен: `POSTGIS_DB_HOST=db`, `POSTGIS_DB_PORT=5432`, IP в `DJANGO_ALLOWED_HOSTS`.
3. БД: `pg_dump` со старого VPS → `pg_restore` на MGGT; сверка ключевых таблиц совпала.
4. Git на сервере привязан к hub.mos.ru (Deploy Token).
5. Позже добавлен домен `border-ogh.mggt.ru`, CSRF/proxy vars в `.env`.

## Обычное обновление (только код, БД не трогаем)

Подходит, если схема и данные на проде уже актуальны (только правки в Python/шаблонах/статике).

### 1. Локально (из репозитория GeoDjango)

```bash
cd /Users/mihail/PY/GeoDjango   # или свой путь к клону
git fetch origin main deploy/mggt-docker
git checkout deploy/mggt-docker
git reset --hard origin/deploy/mggt-docker
git merge -X theirs --no-edit origin/main   # при конфликтах — код из main
git push origin deploy/mggt-docker
git push hub deploy/mggt-docker             # hub — remote на hub.mos.ru
```

При merge из `main` в деплой-ветку **не затирать** без проверки:
- `docker-compose.yml` (должен остаться `collectstatic`);
- `pass_map/urls.py` (маршруты `media/` и `static/` через `serve`);
- `pass_map/settings.py` (prod env vars для CSRF/proxy).

### 2. На сервере (обновление кода)

```bash
cd /opt/passport_editor_new
git fetch origin deploy/mggt-docker
git reset --hard origin/deploy/mggt-docker
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d --force-recreate web
```

`--force-recreate web` нужен для `collectstatic` и подхвата `.env`. Флаг **`--build` не использовать** на RED OS (registry недоступен).

Перед `git reset` на сервере убедиться, что push в hub уже дошёл (иначе можно получить старый коммит).

### 3. Проверка

```bash
sudo docker logs --tail 50 passport_web
```

Ожидаемо в логах:
- `Running migrations` → `No migrations to apply` (или список применённых);
- `X static files copied to '/app/staticfiles'` (или `unmodified`);
- `Starting gunicorn`.

Снаружи:

```bash
curl -I http://172.21.197.77/
curl -I https://border-ogh.mggt.ru/
curl -I https://border-ogh.mggt.ru/static/pass_viewer/js/home.js   # ожидается 200
curl -s -o /dev/null -w "%{http_code}" https://border-ogh.mggt.ru/admin/   # 404 при DJANGO_ENABLE_ADMIN=0
```

### 4. Вернуться к разработке

```bash
git checkout main
git pull origin main
```

## Обновление Docker-образа

Когда изменились зависимости в `requirements.txt` или Dockerfile (новые пакеты: `django-axes`, `openpyxl` и т.д.). На RED OS образ **не собирают** — переносят с Mac/CI.

```bash
# на Mac (RED OS = linux/amd64), ветка deploy/mggt-docker
cd /Users/mihail/PY/GeoDjango
git checkout deploy/mggt-docker
docker build --platform linux/amd64 -t passport_editor_new-web:latest .
docker save passport_editor_new-web:latest | gzip > web.tar.gz
scp web.tar.gz pasp-ssh-user@172.21.197.77:/tmp/
```

На сервере:

```bash
gunzip -c /tmp/web.tar.gz | sudo docker load
cd /opt/passport_editor_new
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d --force-recreate web
```

Без `--platform linux/amd64` на Mac получится arm64-образ → `exec format error` на сервере.

## Обновление с полной перезаливкой БД

Когда на локальной машине новые таблицы/столбцы **и заполненные данные**, а на прод нужна копия 1:1.

Примеры таблиц для сверки: `pass_objects`, `hood`, `ods_request`, `oozt`, `rzd`, `dgi`, `odh`, `ozn`, `renew`, `users`, `recaps`, …

1. **Сначала** выкатить код (раздел выше), чтобы версии миграций совпадали с дампом.
2. Остановить веб, пересоздать `geodb`, залить дамп **без** `--clean` (с `--clean` часто падает на `DROP EXTENSION postgis`).

**На сервере:**

```bash
sudo docker stop passport_web
sudo docker exec passport_db psql -U postgres -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='geodb' AND pid <> pg_backend_pid();"
sudo docker exec passport_db dropdb -U postgres --if-exists geodb
sudo docker exec passport_db createdb -U postgres geodb
```

**С локальной dev-машины** (основной путь — pipe, plain SQL):

```bash
docker exec postgis-db pg_dump -U postgres -d geodb --no-owner --no-privileges \
  | ssh pasp-ssh-user@172.21.197.77 \
  "sudo docker exec -i passport_db psql -v ON_ERROR_STOP=1 -U postgres -d geodb"
```

Альтернатива — custom format (`pg_dump -Fc` → `scp` → `pg_restore`).

**Снова поднять веб:**

```bash
ssh pasp-ssh-user@172.21.197.77 \
  "sudo docker compose -f /opt/passport_editor_new/docker-compose.yml \
   -f /opt/passport_editor_new/docker-compose.images.yml up -d --force-recreate web"
```

**Сверка** (пример):

```bash
# локально
docker exec postgis-db psql -U postgres -d geodb -At -c \
  "SELECT 'pass_objects',count(*) FROM pass_objects UNION ALL SELECT 'users',count(*) FROM users;"

# на MGGT — те же цифры
ssh pasp-ssh-user@172.21.197.77 \
  "sudo docker exec passport_db psql -U postgres -d geodb -At -c \
  \"SELECT 'pass_objects',count(*) FROM pass_objects UNION ALL SELECT 'users',count(*) FROM users;\""
```

После заливки `passport_web` при старте снова выполнит `migrate` — обычно `No migrations to apply`. Долгая заливка: SSH может оборваться в конце; если счётчики совпали — дамп применился.

## Продакшен: статика и media

С v1.1.x JS вынесен в `pass_viewer/static/pass_viewer/js/`, в шаблонах — `{% static '…' %}`.

На проде **`DEBUG=False`**, поэтому в **`deploy/mggt-docker`** обязательно:

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

Volume **`media_data`** хранит `/app/media` (экспорты).

## Перезапуск и сброс сессий (зависание / разлогинить всех)

```bash
cd /opt/passport_editor_new
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml restart
sudo docker exec passport_db psql -U postgres -d geodb -c \
  "TRUNCATE django_session RESTART IDENTITY CASCADE;"
```

Только веб (без сброса сессий): `sudo docker restart passport_web`.

## Ежедневное обновление `ods_request` (12:00 МСК)

Выгрузка ОДС приходит как `ods_request.json`. Раз в сутки cron проверяет файл в контейнере; если он есть — таблица `ods_request` перезаписывается, файл удаляется. Если файла нет — запуск завершается без ошибки (БД не трогается).

**Команда (внутри контейнера или локально):**

```bash
python manage.py sync_ods_request_if_present
python manage.py sync_ods_request_if_present --dry-run   # только подсчёт строк
```

**Положить файл на сервер перед 12:00** (путь в контейнере — `/app/ods_request.json`):

```bash
sudo docker cp /path/on/host/ods_request.json passport_web:/app/ods_request.json
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

## Синхронизация dgi.xlsx (краткий собственник)

Файл `dgi.xlsx` в корне проекта (в git не коммитится) дополняет таблицу `dgi`: столбец `Short_sobstv_rr` → `short_sobstv_rr`, сопоставление по `descr`. Новые `descr` из файла вставляются в БД (при обязательной геометрии — заглушка `POLYGON EMPTY` до появления реальной геометрии).

1. Выкатить код и применить миграции: `python manage.py migrate`
2. Положить актуальный `dgi.xlsx` в `BASE_DIR` (рядом с `manage.py`)
3. Проверка без записи: `python manage.py sync_dgi_from_xlsx --dry-run`
4. Импорт: `python manage.py sync_dgi_from_xlsx`
5. При необходимости обновить ещё `address` / `sobstv_rr` из xlsx: `python manage.py sync_dgi_from_xlsx --sync-attrs`

На больших объёмах (~300k строк) удобен индекс по `descr`. Для ускорения UPDATE можно создать индекс на проде после анализа типа колонки, например: `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dgi_descr ON dgi ((descr::text));`

## Известные нюансы

- **Ветка `main` без `docker-compose.yml`** — деплой только через **`deploy/mggt-docker`**.
- **Merge `main` → deploy:** при конфликтах в шаблонах/views обычно берём **`main`** (`-X theirs`). Файлы инфраструктуры деплоя — проверять руками.
- **RED OS / registry.red-soft.ru:** использовать `docker-compose.images.yml` и перенос образов `docker save`/`load`; **`--build` на сервере не использовать**.
- **HTTPS:** TLS терминируется на корпоративном reverse-proxy (`border-ogh.mggt.ru` → HTTP :80 на `172.21.197.77`). В `.env` обязательны `DJANGO_CSRF_TRUSTED_ORIGINS` и `DJANGO_USE_X_FORWARDED_HOST=1`.
- **Чистая БД без дампа:** для реальных данных надёжнее полный дамп с dev-машины.
- **Push с сервера на GitHub** не настроен — коммиты в `deploy/mggt-docker` делаем **локально** и пушим в `origin` + `hub`.
- **firewalld + Docker:** при включённом `firewalld` без правил для docker-подсети приложение может отдавать **500 на всех страницах** (`OperationalError: ... No route to host`). См. раздел ниже.

## firewalld (RED OS / MGGT)

На `172.21.197.77` используется **firewalld**. Его **не отключают** — настраивают явные правила.

### Что должно быть открыто / закрыто

| Назначение | Как |
|------------|-----|
| Сайт (HTTP) | `http` в зоне `public` |
| Postgres с интернета/сети | **закрыт**: в `docker-compose.yml` — `127.0.0.1:5433:5432`; в firewalld **не** добавлять `5433/tcp` |
| `passport_web` → `passport_db` | внутри docker-сети (`POSTGIS_DB_HOST=db`, порт `5432`), не через host `5433` |

### Обязательное правило для Docker

Трафик между контейнерами идёт по IP docker-подсети (на MGGT обычно `172.18.0.0/16`). Его нужно разрешить в зоне **trusted**:

```bash
# узнать актуальную подсеть (если сеть пересоздавалась)
sudo docker network inspect passport_editor_new_default \
  --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}'

# типично на MGGT:
sudo firewall-cmd --permanent --zone=trusted --add-source=172.18.0.0/16
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
sudo firewall-cmd --zone=trusted --list-all
```

Предупреждения `ALREADY_ENABLED: http` и `NOT_ENABLED: 5433:tcp` при настройке — **нормальны**.

### Проверка после включения firewalld

```bash
# с хоста: Postgres снаружи недоступен (bind только localhost)
sudo ss -ltnp | awk 'NR==1 || /:5433/'

# из контейнера web — БД доступна
sudo docker exec passport_web python -c "\
import os; os.environ.setdefault('DJANGO_SETTINGS_MODULE','pass_map.settings'); \
import django; django.setup(); from django.db import connection; connection.cursor(); print('DB_OK')"

curl -I http://127.0.0.1/
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/admin/   # 404 при DJANGO_ENABLE_ADMIN=0
```

Если снова **500 на всех страницах** при включённом firewalld — сначала проверить `DB_OK` в контейнере; при ошибке `No route to host` — не хватает `trusted` для docker-подсети (или подсеть сменилась после `docker network` recreate).

## Безопасность

- Не коммитить `.env`, пароли БД, `DJANGO_SECRET_KEY`.
- Не дублировать в документации логины/пароли пользователей.
- Postgres: bind `127.0.0.1:5433:5432` в compose + не открывать `5433` в firewalld.
- firewalld: разрешить `http` и docker-подсеть в `trusted`; не отключать firewall целиком.

---

*Последнее состояние продакшена MGGT: `172.21.197.77`, домен `https://border-ogh.mggt.ru`, ветка `deploy/mggt-docker` (v2.2.x+), образы через `docker-compose.images.yml`, bind `.:/app`, Postgres `127.0.0.1:5433`, firewalld с `trusted` для `172.18.0.0/16`.*
