# Деплой Passport Editor на VPS (Docker)

Краткая памятка, чтобы не терять контекст между сессиями.

## Окружение

| Что | Значение |
|-----|----------|
| Сервер | `77.222.63.161` (SSH пользователь `root`) |
| Каталог на сервере | `/opt/passport_editor_new` |
| Репозиторий | `https://github.com/mstukalov90-source/Passport_Editor.git` |
| Прод-ветка | `deploy/vps-docker` (содержит `docker-compose.yml`, настройки под VPS) |
| Разработка | `main` — в прод на сервер попадает через merge в `deploy/vps-docker` |

**SSH:** ключ на локальной машине, например `~/PY/id_rsa/id_rsa` (в чат не вставлять).

На сервере приложение слушает **порт 80** → контейнер `passport_web` (`8000` внутри). БД: контейнер `passport_db`, снаружи часто **5433** → `5432` внутри. Секреты и `DJANGO_*` — в **`/opt/passport_editor_new/.env`** (не в репозитории).

## Обычное обновление (только код, без смены схемы/данных БД)

1. Локально (клон деплоя или основной репо с двумя remotes):

   ```bash
   git fetch origin main deploy/vps-docker
   git checkout deploy/vps-docker
   git reset --hard origin/deploy/vps-docker
   git merge -X theirs --no-edit origin/main   # при конфликтах приоритет у main
   git push origin deploy/vps-docker
   ```

2. На VPS:

   ```bash
   cd /opt/passport_editor_new
   git fetch origin deploy/vps-docker
   git reset --hard origin/deploy/vps-docker
   docker compose up -d --build
   ```

3. Проверка: `docker logs --tail 40 passport_web` (миграции + старт gunicorn), снаружи `curl -I http://77.222.63.161/`.

**Важно:** ветка `main` без `docker-compose.yml` — депой всегда из **`deploy/vps-docker`**.

## Обновление с полной перезаливкой БД

Когда на локальной машине актуальные данные (новые таблицы/столбцы/наполнение), а на прод нужно то же самое:

1. Сначала выкатить код (шаги выше), чтобы миграции и код совпадали.
2. Локально: контейнер PostGIS с рабочей БД (например `postgis-db`, БД `geodb`, пользователь из `docker inspect`).
3. Кратко остановить веб на VPS, пересоздать БД `geodb`, залить дамп **без** `--clean` (иначе возможны ошибки с `DROP EXTENSION postgis`):

   ```bash
   # на VPS
   docker stop passport_web
   docker exec passport_db psql -U postgres -d postgres -c \
     "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='geodb' AND pid <> pg_backend_pid();"
   docker exec passport_db dropdb -U postgres --if-exists geodb
   docker exec passport_db createdb -U postgres geodb
   docker start passport_web   # опционально позже, после заливки
   ```

   С локальной машины (подставить свой путь к ключу):

   ```bash
   docker exec postgis-db pg_dump -U postgres -d geodb --no-owner --no-privileges \
     | ssh -i ~/.ssh/ВАШ_КЛЮЧ -o IdentitiesOnly=yes root@77.222.63.161 \
     "docker exec -i passport_db psql -v ON_ERROR_STOP=1 -U postgres -d geodb"
   ssh ... "docker start passport_web"
   ```

После старта `passport_web` снова выполнит `migrate` — при полном дампе обычно «No migrations to apply» или догонятся только недостающие записи в `django_migrations`.

## Перезапуск и сброс сессий (зависание / разлогинить всех)

```bash
cd /opt/passport_editor_new
docker compose restart
docker exec passport_db psql -U postgres -d geodb -c "TRUNCATE django_session RESTART IDENTITY CASCADE;"
```

## Известные нюансы (уже решались на этом проекте)

- **Скачивание файлов из `/media/`** в проде: в `deploy/vps-docker` в `pass_map/urls.py` должна быть раздача `media/` не только при `DEBUG=True` (через `django.views.static.serve`), иначе экспорты по URL не отдаются.
- **Чистая БД и миграции:** в цепочке миграций есть шаги, завязанные на наличие таблиц вроде `pass_objects` / `odh`; для пустой БД в деплой-ветке добавлен bootstrap в ранних миграциях — полный дамп с рабочей машины всё равно надёжнее, если нужны именно данные.

## Безопасность

- Не коммитить пароли БД и `DJANGO_SECRET_KEY` в git.
- Учётные данные тестовых пользователей в документации не дублировать.

---

*Файл можно держать в репозитории рядом с кодом и дополнять по мере смены хоста, портов или процедуры CI.*
