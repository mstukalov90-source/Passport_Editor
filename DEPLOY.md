# Деплой Passport Editor на VPS (Docker)

Краткая памятка, чтобы не терять контекст между сессиями.

## Окружение

| Что | Значение |
|-----|----------|
| **Прод-сервер** | `172.21.197.77` (SSH пользователь `pasp-ssh-user`, Docker через `sudo`) |
| Каталог на сервере | `/opt/passport_editor_new` |
| Репозиторий | `git@hub.mos.ru:m.stukalov90/Passport_Editor.git` (корп. GitLab) |
| Резерв / миграция | старый VPS `77.222.63.161` (`root`, ключ `~/PY/id_rsa/id_rsa`) |
| Разработка | ветка **`main`** (локально: `/Users/mihail/PY/GeoDjango`) |
| Прод (MGGT) | ветка **`deploy/mggt-docker`** (`docker-compose.yml`, `docker-compose.images.yml`, `.env`) |
| Старый VPS (архив) | `77.222.63.161`, ветка **`deploy/vps-docker`** — дампы и откат |

**SSH:** ключ на локальной машине `~/PY/id_rsa/id_rsa` для старого VPS; на новый — настроенный доступ `pasp-ssh-user@172.21.197.77` (в чат и в git не класть).

| Контейнер | Назначение |
|-----------|------------|
| `passport_web` | Django + Gunicorn, снаружи **порт 80** → `8000` внутри |
| `passport_db` | PostGIS 16; на хосте **только** `127.0.0.1:5433` → `5432` (не `0.0.0.0`); между контейнерами — `db:5432` |

Отдельный **Nginx не используется** — `/static/` и `/media/` отдаёт Gunicorn через маршруты в `pass_map/urls.py`.

Секреты: **`/opt/passport_editor_new/.env`** (`DJANGO_*`, `POSTGIS_*` и т.д.) — не в репозитории.

На VPS в `.env` обязательно: **`DJANGO_ENABLE_ADMIN=0`** (маршрут `/admin/` не монтируется).

**Локальная БД для разработки:** Docker-контейнер `postgis-db`, БД `geodb` (как на проде по имени).

### RED OS: Docker Hub недоступен

На `172.21.197.77` `docker pull` идёт через `registry.red-soft.ru` и падает. Образы **не тянутся**, а **загружаются** со старого VPS (`docker save` → `scp` → `docker load`). Запуск:

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

#### Обновление кода через git (без пересборки образа)

```bash
cd /opt/passport_editor_new
git fetch origin deploy/mggt-docker
git reset --hard origin/deploy/mggt-docker
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d
```

Флаг **`--build` не использовать** на RED OS (registry недоступен), пока образ не обновляли через `docker save`/`load` с другой машины.

#### 6. Если старый VPS (`77.222.63.161`) выключен

| Задача | Без старого сервера |
|--------|---------------------|
| Обновить Python/шаблоны | `git pull` + `compose up -d` (без `--build`) |
| Обновить образ приложения | Собрать на Mac/CI → `docker save` → `docker load` на MGGT |
| Свежий дамп БД | Хранить локальные архивы `geodb.dump`; старый VPS недоступен |
| Образ PostGIS | Уже в Docker на MGGT; при сбое — `docker save` из бэкапа |

## Ветки — зачем так

- **`main`** — весь код, миграции, шаблоны, `pass_viewer/static/…`. **Без** `docker-compose.yml`.
- **`deploy/mggt-docker`** — прод на **172.21.197.77** (RED OS): merge из `main` плюс:
  - `docker-compose.yml`, **`docker-compose.images.yml`** (образы без Docker Hub);
  - `pass_map/urls.py` с раздачей **`/media/`** и **`/static/`** при `DEBUG=False`.
- **`deploy/vps-docker`** — прежний прод на **77.222.63.161**; не смешивать с MGGT.

После работы с деплоем: `git checkout main`.

## Первичный деплой на новый VPS (сделано 2026-05-22)

1. Код: `rsync` ветки `deploy/mggt-docker` (далее — git + Deploy Key, см. раздел выше).
2. `.env`: скопирован со старого VPS; в `DJANGO_ALLOWED_HOSTS` добавлен `172.21.197.77`; `POSTGIS_DB_HOST=db`, `POSTGIS_DB_PORT=5432`.
3. Образы: `postgis/postgis:16-3.4` и `passport_editor_new-web:latest` со старого VPS.
4. БД: `pg_dump -Fc` с `77.222.63.161` → `pg_restore` на новом; сверка `pass_objects` / `oozt` / `rzd` / `users` — совпало.
5. Проверка: `curl -I http://172.21.197.77/` (302), `/static/pass_viewer/js/home.js` (200).

## Обычное обновление (только код, БД не трогаем)

Подходит, если схема и данные на проде уже актуальны (только правки в Python/шаблонах/статике).

### 1. Локально (из репозитория GeoDjango)

```bash
cd /Users/mihail/PY/GeoDjango   # или свой путь к клону
git fetch origin main deploy/mggt-docker
git checkout deploy/mggt-docker
git reset --hard origin/deploy/mggt-docker
git merge -X theirs --no-edit origin/main   # при конфликтах — код из main
git push origin deploy/mggt-docker          # и при необходимости: git push hub deploy/mggt-docker
```

При merge из `main` в деплой-ветку **не затирать** без проверки:
- `docker-compose.yml` (должен остаться `collectstatic`);
- `pass_map/urls.py` (маршруты `media/` и `static/` через `serve`).

### 2. На VPS (обновление кода)

**Через git** (после настройки Deploy Key — см. «Git на MGGT»):

```bash
cd /opt/passport_editor_new
git fetch origin deploy/mggt-docker
git reset --hard origin/deploy/mggt-docker
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d
```

**Через rsync** (как при первичном деплое):

```bash
# с локальной машины, ветка deploy/mggt-docker
rsync -avz --exclude 'venv/' --exclude '.git/' --exclude '.env' \
  ./ pasp-ssh-user@172.21.197.77:/opt/passport_editor_new/
ssh pasp-ssh-user@172.21.197.77 'cd /opt/passport_editor_new && sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d'
```

Если `--build` недоступен (нет registry) — пересобрать образ на старом/другом хосте, `docker save`, загрузить на прод, затем `up -d` с `docker-compose.images.yml`.

### 3. Проверка

```bash
sudo docker logs --tail 50 passport_web
```

Ожидаемо в логах:
- `Running migrations` → `No migrations to apply` (или список применённых);
- `X static files copied to '/app/staticfiles'` (или `unmodified`);
- `Starting gunicorn`.

Снаружи (MGGT):

```bash
curl -I http://172.21.197.77/
curl -I http://172.21.197.77/static/pass_viewer/js/home.js   # ожидается 200
curl -s -o /dev/null -w "%{http_code}" http://172.21.197.77/admin/   # ожидается 404 при DJANGO_ENABLE_ADMIN=0
```

### 4. Вернуться к разработке

```bash
git checkout main
git pull origin main
```

## Обновление с полной перезаливкой БД

Когда нужна копия данных 1:1 со старого или dev-окружения.

Примеры таблиц для сверки: `pass_objects`, `hood`, `ods_request`, `oozt`, `rzd`, `dgi`, `odh`, `ozn`, `renew`, `users`, …

1. **Сначала** выкатить код (раздел выше).
2. Остановить веб, пересоздать `geodb`, залить дамп **без** `--clean`.

**Дамп на старом VPS (`77.222.63.161`):**

```bash
ssh -i ~/PY/id_rsa/id_rsa -o IdentitiesOnly=yes root@77.222.63.161
docker exec passport_db pg_dump -U postgres -d geodb --no-owner --no-privileges -Fc > /tmp/geodb.dump
```

**На новом VPS (`172.21.197.77`):**

```bash
sudo docker stop passport_web
sudo docker exec passport_db psql -U postgres -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='geodb' AND pid <> pg_backend_pid();"
sudo docker exec passport_db dropdb -U postgres --if-exists geodb
sudo docker exec passport_db createdb -U postgres geodb
sudo docker exec -i passport_db pg_restore -U postgres -d geodb --no-owner --no-privileges < /tmp/geodb.dump
sudo docker start passport_web
```

**Сверка** (пример):

```bash
# старый VPS
ssh -i ~/PY/id_rsa/id_rsa root@77.222.63.161 \
  "docker exec passport_db psql -U postgres -d geodb -At -c \
  \"SELECT 'pass_objects',count(*) FROM pass_objects UNION ALL SELECT 'users',count(*) FROM users;\""

# новый VPS
ssh pasp-ssh-user@172.21.197.77 \
  "sudo docker exec passport_db psql -U postgres -d geodb -At -c \
  \"SELECT 'pass_objects',count(*) FROM pass_objects UNION ALL SELECT 'users',count(*) FROM users;\""
```

**С локальной dev-машины** (pipe, plain SQL, без `--clean`):

```bash
docker exec postgis-db pg_dump -U postgres -d geodb --no-owner --no-privileges \
  | ssh pasp-ssh-user@172.21.197.77 \
  "sudo docker exec -i passport_db psql -v ON_ERROR_STOP=1 -U postgres -d geodb"
```

## Продакшен: статика и media

С v1.1.x JS вынесен в `pass_viewer/static/pass_viewer/js/`, в шаблонах — `{% static '…' %}`.

На проде **`DEBUG=False`**, поэтому в **`deploy/mggt-docker`** (и **`deploy/vps-docker`**) обязательно:

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

Volume **`media_data`** хранит `/app/media` (экспорты). При миграции с старого VPS — архив volume и распаковка в новый (через контейнер `postgis/postgis`, т.к. `alpine` на RED OS не тянется).

## Перезапуск и сброс сессий

```bash
cd /opt/passport_editor_new
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml restart
sudo docker exec passport_db psql -U postgres -d geodb -c \
  "TRUNCATE django_session RESTART IDENTITY CASCADE;"
```

Только веб: `sudo docker restart passport_web`.

## Ежедневное обновление `ods_request` (12:00 МСК)

Выгрузка ОДС приходит как `ods_request.json`. Раз в сутки cron проверяет файл в контейнере; если он есть — таблица `ods_request` перезаписывается, файл удаляется. Если файла нет — запуск завершается без ошибки (БД не трогается).

**Команда (внутри контейнера или локально):**

```bash
python manage.py sync_ods_request_if_present
python manage.py sync_ods_request_if_present --dry-run   # только подсчёт строк
```

**Положить файл на VPS перед 12:00** (путь в контейнере — `/app/ods_request.json`):

```bash
cp /path/on/host/ods_request.json /opt/passport_editor_new/ods_request.json
# или: sudo docker cp ... passport_web:/app/ods_request.json
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

- **Ветка `main` без `docker-compose.yml`** — деплой MGGT через **`deploy/mggt-docker`**, старый VPS — **`deploy/vps-docker`**.
- **`.env` на новом VPS:** `POSTGIS_DB_HOST=db`, `POSTGIS_DB_PORT=5432`; в `DJANGO_ALLOWED_HOSTS` — IP/домен нового сервера.
- **RED OS / registry.red-soft.ru:** использовать `docker-compose.images.yml` и перенос образов `docker save`/`load`.
- **HTTPS:** в текущем стеке нет TLS; только HTTP :80. HTTPS — отдельный reverse-proxy или балансировщик.
- **Merge `main` → deploy:** при конфликтах в шаблонах/views обычно берём **`main`**. Файлы инфраструктуры деплоя — проверять руками.
- **Чистая БД без дампа:** для реальных данных надёжнее полный дамп.
- **Долгая заливка БД:** SSH может оборваться; сверять `count(*)` по ключевым таблицам.
- **firewalld + Docker:** при включённом `firewalld` без правил для docker-подсети приложение может отдавать **500 на всех страницах** (в логах/тесте: `OperationalError: ... db (172.18.x.x):5432 ... No route to host`). См. раздел ниже.

## firewalld (RED OS / MGGT)

На `172.21.197.77` используется **firewalld**. Его **не отключают** — настраивают явные правила.

### Что должно быть открыто / закрыто

| Назначение | Как |
|------------|-----|
| Сайт (HTTP) | `http` (и при необходимости `https`) в зоне `public` |
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
# при HTTPS: sudo firewall-cmd --permanent --add-service=https
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

После правки `.env` (например `DJANGO_ENABLE_ADMIN=0`) переменные в контейнер подхватываются через **`docker compose ... up -d --force-recreate web`**, а не только `docker restart`.

## Безопасность

- Не коммитить `.env`, пароли БД, `DJANGO_SECRET_KEY`.
- Не дублировать в документации логины/пароли пользователей.
- Postgres: bind `127.0.0.1:5433:5432` в compose + не открывать `5433` в firewalld.
- firewalld: разрешить `http` и docker-подсеть в `trusted`; не отключать firewall целиком.

---

*Последнее состояние продакшена MGGT: `172.21.197.77`, ветка `deploy/mggt-docker` (v1.6.5+), образы через `docker-compose.images.yml`, bind `.:/app`, Postgres `127.0.0.1:5433`, firewalld с `trusted` для `172.18.0.0/16`.*
