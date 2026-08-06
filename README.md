# Passport Editor (GeoDjango)

Веб-приложение для просмотра и редактирования границ объектов городского хозяйства на интерактивной карте (Django + PostGIS + Leaflet).

Подробнее для пользователей: [USER_GUIDE.md](USER_GUIDE.md).  
Деплой на MGGT: [DEPLOY.md](DEPLOY.md).

## Требования

- Python 3.12+
- PostGIS (локально обычно Docker-контейнер `postgis-db`, БД `geodb`, порт `5433`)
- GDAL / GEOS, совместимые с `gdal==3.6.2` из [requirements.txt](requirements.txt)
  - macOS (Homebrew): `GDAL_LIBRARY_PATH` и `GEOS_LIBRARY_PATH` — см. [.env.example](.env.example)

## Быстрый старт

```bash
cd GeoDjango
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt -r requirements-dev.txt
playwright install chromium
cp .env.example .env       # при необходимости отредактировать пути GDAL и QGIS_DB_*
./scripts/local_postgis_up.sh
./scripts/sync_geodb_from_prod.sh --save dumps/geodb_initial.sql.gz --yes   # первый раз: полный дамп с прода
python manage.py check_db_connections
python manage.py runserver
```

Откройте http://127.0.0.1:8000/ — логин учётками из таблицы `users` (после синхронизации с прода — те же, что на проде).

Если контейнер пустой и дамп не нужен: `python manage.py migrate` и `python manage.py ensure_e2e_user`.

### Локальная geodb (Docker)

| Файл | Назначение |
|------|------------|
| [docker-compose.local.yml](docker-compose.local.yml) | PostGIS 16, контейнер `postgis-db`, порт `5433` |
| [scripts/local_postgis_up.sh](scripts/local_postgis_up.sh) | Поднять контейнер |
| [scripts/sync_geodb_from_prod.sh](scripts/sync_geodb_from_prod.sh) | Полная копия geodb с прода (только чтение прода) |

Повторная заливка без обращения к проду:

```bash
./scripts/sync_geodb_from_prod.sh --from-file dumps/geodb_initial.sql.gz --yes
```

Скрипт синхронизации **пересоздаёт только локальную** `geodb`. Прод не изменяется (`pg_dump`). После заливки пароль роли `postgres` сбрасывается на `postgres` (как в `docker-compose.local.yml`).

**Важно:** не держите одновременно SSH-туннель `ssh -L 5433:...` и локальный Docker на порту `5433` — подключения с Mac могут уйти на прод. Остановите туннель: `pkill -f 'ssh.*-L 5433:127.0.0.1:5433'`.

### QGIS-витрина (alias `qgis`)

Вторая БД в [`pass_map/settings.py`](pass_map/settings.py) — alias `qgis`, переменные `QGIS_DB_*`. Имя БД: **`mggt_asu`** на `172.21.197.51`.

```text
QGIS_DB_HOST=172.21.197.51
QGIS_DB_PORT=5432
QGIS_DB_NAME=mggt_asu
QGIS_DB_USER=mstukalov
QGIS_DB_PASSWORD=<ваш пароль>
```

Миграции Django на alias `qgis` **не запускать** — схема принадлежит QGIS.

### Опционально: прод geodb через SSH

Для отладки напрямую на прод-данных (не для ежедневной разработки): шаблон [`.env.prod-remote.example`](.env.prod-remote.example).

```bash
ssh -N -L 5433:127.0.0.1:5433 pasp-ssh-user@172.21.197.77
```

Остановите локальный `postgis-db`, если порт `5433` занят. **Не запускайте** `migrate` на прод geodb.

### Проверка подключений

```bash
python manage.py check_db_connections
```

Проверяет `default` (локальная geodb) и `qgis` (mggt_asu).

### Сид данных (опционально)

Положите файлы в каталог [`import/`](import/) (имя файла = имя таблицы: `pass_objects.geojson`, `ods_request.json`, …).
По умолчанию команда ищет данные в `import/`, если каталог существует.

```bash
python manage.py import_seed_from_files --list
python manage.py import_seed_from_files --dry-run --all   # подсчёт без записи
python manage.py import_seed_from_files --all               # TRUNCATE + загрузка
python manage.py import_seed_from_files --table ods_request
```

Большие GeoJSON (сотни МБ–ГБ) читаются потоково; полный импорт может занять десятки минут.
Миграции для загрузки не нужны — только существующие таблицы в PostGIS.

## Роли пользователей

Роль задаётся в таблице `users` (`ExternalUser.role`). Логика scope: [`pass_viewer/roles.py`](pass_viewer/roles.py); доступ к согласованиям: [`approval/access.py`](approval/access.py).

| Роль | Объекты / заявки на home | ОДС | Согласования | Запись |
|------|--------------------------|-----|--------------|--------|
| **BD** | `OwnerLegalPersonId` пользователя | да | свои (`cases.owners` содержит ID) | да |
| **MGGT** | все заявки сайта (с `request_id`, без `rootid`); паспорта скрыты | нет | все; фильтр «Мои/Все»; глобальный инспектор | да |
| **DEP** | `DepartmentLegalPersonId = OwnerLegalPersonId` пользователя | да | как у BD | да |
| **DEP+** | `OwnerLegalPersonId IN (список)` | да (объединение по всем ID) | любой ID из списка ∈ `cases.owners` | да |
| **SUP** | паспорта в выбранном районе `hood` + все заявки сайта | нет | все, только просмотр | нет |

Поля в `users`, связанные с ролями:

| Поле | Колонка БД | Назначение |
|------|------------|------------|
| `role` | `role` | `BD` / `MGGT` / `DEP` / `DEP+` / `SUP` (по умолчанию `BD`) |
| `owner_legal_person_id` | `OwnerLegalPersonId` | один ID для BD / DEP (и fallback) |
| `owner_legal_person_ids` | `OwnerLegalPersonIds` | массив ID для **DEP+** (источник правды) |
| `display_name` | `display_name` | заголовок home (`h2`) только для **DEP+** |
| `hood_scope` | `hood_scope` | пространственный фильтр по районам (для BD и др.) |

**SUP** при входе выбирает район (`hood.gid`); без выбора список объектов пуст.  
**DEP+**: для home лимит выборки GIS выше обычных 500/таблица (до 10000), иначе при многих ID список обрезается.

Назначить роль локально (пример DEP+):

```bash
python manage.py shell -c "
from pass_viewer.models import ExternalUser
u = ExternalUser.objects.get(login='4')
u.role = 'DEP+'
u.owner_legal_person_ids = ['9000022', '10231426']  # …
u.display_name = 'Префектура ЦАО'
u.save()
"
```

Тесты: [`tests/test_user_roles.py`](tests/test_user_roles.py).

## Проверки качества

```bash
# Линтер
ruff check pass_map pass_viewer

# pre-commit (ruff на каждый commit; один раз: pre-commit install)
pre-commit run --all-files

# Быстрые smoke-тесты (Django client, без браузера)
pytest -m "not e2e"

# E2E smoke (Playwright; нужны PostGIS и chromium)
pytest -m e2e --browser chromium
```

### pre-commit

```bash
pip install -r requirements-dev.txt
pre-commit install          # хук в .git/hooks/pre-commit
pre-commit run --all-files  # прогон вручную до push
```

Хуки: `ruff check --fix` для `pass_map/` и `pass_viewer/`.

Smoke-тесты создают отдельную `test_geodb` и таблицу `users` через ORM (без полного `migrate` и без `pass_objects`).  
Для разработки с полными GIS-данными используйте `./scripts/sync_geodb_from_prod.sh` или сид из `import/`.  
Перед первым E2E: `playwright install chromium` и запущенный PostGIS (`./scripts/local_postgis_up.sh`).

## CI

Одинаковые проверки: **ruff** → **pytest smoke** → **Playwright E2E** (PostGIS 16, GDAL через `apt`, скрипты [`scripts/ci_install_deps.sh`](scripts/ci_install_deps.sh) и [`scripts/ci_resolve_gdal_paths.sh`](scripts/ci_resolve_gdal_paths.sh)).

| Платформа | Конфиг | Документация |
|-----------|--------|--------------|
| **GitLab** (hub.mos.ru) | [`.gitlab-ci.yml`](.gitlab-ci.yml) | [GITLAB_CI.md](GITLAB_CI.md) |
| GitHub | [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | ниже |

Пуш на корпоративный GitLab:

```bash
git push hub main
```

Локально на Mac — `gdal==3.6.2` из `requirements.txt` и пути из `.env.example` (Homebrew).

### Первый прогон CI на GitHub

1. Закоммитьте и запушьте ветку с `.github/workflows/ci.yml` в `main` (или откройте PR в `main`).
2. На GitHub: **Actions** → workflow **CI** → последний run.
3. Локально перед push (рекомендуется):

   ```bash
   ruff check pass_map pass_viewer
   pre-commit run --all-files
   pytest -m "not e2e"
   ```

4. Если упал job **test** / **e2e** с `undefined symbol: GDALVersionInfo` и путём `ogdi/.../libgdal.so` — CI должен использовать `ci_resolve_gdal_paths.sh`, не `find /usr/lib`.
5. Если упал job **test** / **e2e** на шаге установки GDAL — смотрите лог `Install Python dependencies`; версия pip `gdal` должна совпасть с `gdal-config --version` на runner.
6. Если упал **e2e** на Playwright — перезапуск run; при повторе проверьте лог PostGIS health.

Просмотр статуса с CLI (если установлен `gh`):

```bash
gh run list --workflow=ci.yml
gh run watch
```

## Структура тестов

| Путь | Назначение |
|------|------------|
| [tests/test_auth_smoke.py](tests/test_auth_smoke.py) | Редирект на login, вход, загрузка home |
| [tests/test_user_roles.py](tests/test_user_roles.py) | Роли BD / MGGT / DEP / DEP+ / SUP: scope и согласования |
| [tests/test_build_page_js.py](tests/test_build_page_js.py) | `_extracted/` и собранные `.js` в синхроне |
| [tests/test_home_js_smoke.py](tests/test_home_js_smoke.py) | Символы home.js (фильтр ОДС, досъёмы, TOP) |
| [tests/test_main_js_smoke.py](tests/test_main_js_smoke.py) | Символы main.js (смежные слои, auto-remove) |
| [tests/e2e/test_smoke.py](tests/e2e/test_smoke.py) | Браузер: login, home, статика, page-config |
| [pass_viewer/management/commands/ensure_e2e_user.py](pass_viewer/management/commands/ensure_e2e_user.py) | Тестовый пользователь в таблице `users` |
| [pass_viewer/management/commands/check_db_connections.py](pass_viewer/management/commands/check_db_connections.py) | Проверка PostGIS: `default` (geodb) и `qgis` (mggt_asu) |
| [scripts/local_postgis_up.sh](scripts/local_postgis_up.sh) | Локальный Docker PostGIS |
| [scripts/sync_geodb_from_prod.sh](scripts/sync_geodb_from_prod.sh) | Полная синхронизация geodb с прода |

## Основные команды

```bash
python manage.py migrate
python manage.py ensure_e2e_user
python manage.py check_db_connections
python manage.py collectstatic --noinput
python manage.py runserver
```

## Page JS (`home.js`, `main.js`, …)

Источник правды — снимки в [`pass_viewer/static/pass_viewer/js/_extracted/`](pass_viewer/static/pass_viewer/js/_extracted/), не готовые файлы в `pass_viewer/js/`.

После правок в `_extracted/`:

```bash
python3 pass_viewer/static/build_page_js.py --page home   # одна страница
python3 pass_viewer/static/build_page_js.py --all         # все страницы
python3 pass_viewer/static/build_page_js.py --check       # проверка синхронизации (CI)
```

В коммит включайте **и** `_extracted/*.js`, **и** сгенерированные `home.js` / `main.js` / `add-object.js` / `add-recap.js`.

Не запускайте `build_page_js.py` без `--page` / `--all` / `--check` — полная пересборка только через `--all`.
