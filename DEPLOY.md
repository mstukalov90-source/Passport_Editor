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
| `passport_db` | PostGIS 16, снаружи **5433** → `5432` внутри |

Отдельный **Nginx не используется** — `/static/` и `/media/` отдаёт Gunicorn через маршруты в `pass_map/urls.py`.

Секреты: **`/opt/passport_editor_new/.env`** (`DJANGO_*`, `POSTGIS_*` и т.д.) — не в репозитории.

**Локальная БД для разработки:** Docker-контейнер `postgis-db`, БД `geodb` (как на проде по имени).

### RED OS: Docker Hub недоступен

На `172.21.197.77` `docker pull` идёт через `registry.red-soft.ru` и падает. Образы **не тянутся**, а **загружаются** со старого VPS (`docker save` → `scp` → `docker load`). Запуск:

```bash
cd /opt/passport_editor_new
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d
```

Файл [`docker-compose.images.yml`](docker-compose.images.yml) — только override образов, в git.

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

Снаружи:

```bash
curl -I http://172.21.197.77/
curl -I http://172.21.197.77/static/pass_viewer/js/home.js   # ожидается 200
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

## Известные нюансы

- **Ветка `main` без `docker-compose.yml`** — деплой MGGT через **`deploy/mggt-docker`**, старый VPS — **`deploy/vps-docker`**.
- **`.env` на новом VPS:** `POSTGIS_DB_HOST=db`, `POSTGIS_DB_PORT=5432`; в `DJANGO_ALLOWED_HOSTS` — IP/домен нового сервера.
- **RED OS / registry.red-soft.ru:** использовать `docker-compose.images.yml` и перенос образов `docker save`/`load`.
- **HTTPS:** в текущем стеке нет TLS; только HTTP :80. HTTPS — отдельный reverse-proxy или балансировщик.
- **Merge `main` → deploy:** при конфликтах в шаблонах/views обычно берём **`main`**. Файлы инфраструктуры деплоя — проверять руками.
- **Чистая БД без дампа:** для реальных данных надёжнее полный дамп.
- **Долгая заливка БД:** SSH может оборваться; сверять `count(*)` по ключевым таблицам.

## Безопасность

- Не коммитить `.env`, пароли БД, `DJANGO_SECRET_KEY`.
- Не дублировать в документации логины/пароли пользователей.

---

*Последнее состояние продакшена MGGT: `172.21.197.77`, ветка `deploy/mggt-docker`, дамп `geodb` со старого VPS `77.222.63.161` (ветка `deploy/vps-docker`), образы через `docker-compose.images.yml`.*
