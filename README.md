# Passport Editor (GeoDjango)

Веб-приложение для просмотра и редактирования границ объектов городского хозяйства на интерактивной карте (Django + PostGIS + Leaflet).

Подробнее для пользователей: [USER_GUIDE.md](USER_GUIDE.md).  
Деплой на VPS: [DEPLOY.md](DEPLOY.md).

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
cp .env.example .env       # при необходимости отредактировать пути GDAL и БД
python manage.py migrate
python manage.py ensure_e2e_user
python manage.py runserver
```

Откройте http://127.0.0.1:8000/ — для входа используйте учётку из `.env` (`E2E_LOGIN` / `E2E_PASSWORD` после `ensure_e2e_user`).

### Сид данных (опционально)

Если в корне проекта есть JSON/GeoJSON-файлы таблиц:

```bash
python manage.py import_seed_from_files --list
python manage.py import_seed_from_files --table users
```

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

Хуки: `ruff check --fix` и `ruff format` только для `pass_map/` и `pass_viewer/`.

Smoke-тесты создают отдельную `test_geodb` и таблицу `users` через ORM (без полного `migrate` и без `pass_objects`).  
Для разработки приложения по-прежнему нужны `python manage.py migrate` и сид GIS-таблиц.  
Перед первым E2E: `playwright install chromium` и запущенный PostGIS.

## CI vs локальная macOS

В GitHub Actions (`.github/workflows/ci.yml`): `ruff`, pytest smoke, Playwright E2E, PostGIS 16, GDAL через `apt`.  
На CI пакет `gdal` для pip подбирается под версию из `gdal-config` (скрипт [`scripts/ci_install_deps.sh`](scripts/ci_install_deps.sh)).  
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

4. Если упал job **test** / **e2e** на шаге установки GDAL — смотрите лог `Install Python dependencies`; версия pip `gdal` должна совпасть с `gdal-config --version` на runner.
5. Если упал **e2e** на Playwright — перезапуск run; при повторе проверьте лог PostGIS health.

Просмотр статуса с CLI (если установлен `gh`):

```bash
gh run list --workflow=ci.yml
gh run watch
```

## Структура тестов

| Путь | Назначение |
|------|------------|
| [tests/test_auth_smoke.py](tests/test_auth_smoke.py) | Редирект на login, вход, загрузка home |
| [tests/e2e/test_smoke.py](tests/e2e/test_smoke.py) | Браузер: login, home, статика, page-config |
| [pass_viewer/management/commands/ensure_e2e_user.py](pass_viewer/management/commands/ensure_e2e_user.py) | Тестовый пользователь в таблице `users` |

## Основные команды

```bash
python manage.py migrate
python manage.py ensure_e2e_user
python manage.py collectstatic --noinput
python manage.py runserver
```
