# CI на корпоративном GitLab (hub.mos.ru)

Пайплайн: [`.gitlab-ci.yml`](.gitlab-ci.yml) — те же проверки, что в GitHub Actions: `ruff`, pytest smoke, Playwright E2E.

Remote в git:

```text
hub  git@hub.mos.ru:m.stukalov90/Passport_Editor.git
```

## Что нужно на стороне GitLab

1. **Shared Runners** с executor **Docker** (уточните у админов hub.mos.ru, если пайплайн «pending» без job).
2. **Доступ к образам** `python:3.12-bookworm` и `postgis/postgis:16-3.4` (Docker Hub или внутреннее зеркало).
3. В проекте: **Settings → CI/CD → General pipelines** — pipelines **enabled**.

## Первый запуск

```bash
cd GeoDjango
git push hub main
```

В GitLab: **Build → Pipelines** — должен появиться pipeline с stages `lint` → `test` → `e2e`.

Ручной запуск: **Build → Pipelines → Run pipeline** (ветка `main`).

## Если Docker Hub заблокирован

В **Settings → CI/CD → Variables** добавьте (пример):

| Variable | Value |
|----------|--------|
| `POSTGIS_IMAGE` | `registry.hub.mos.ru/.../postgis:16-3.4` |
| `PYTHON_IMAGE` | `registry.hub.mos.ru/.../python:3.12-bookworm` |

Имена registry уточните у администраторов hub.mos.ru.

## Отличия от GitHub

| | GitHub Actions | GitLab CI |
|---|----------------|-----------|
| Конфиг | `.github/workflows/ci.yml` | `.gitlab-ci.yml` |
| PostGIS | service `localhost:5432` | service alias `postgis` |
| GDAL pip | `scripts/ci_install_deps.sh` | тот же скрипт |
| Тестовая БД | `test_geodb` без GIS-миграций | то же (pytest, см. README) |

## MosHub / старый GitLab

В `.gitlab-ci.yml` **не используется** `rules:` в блоке `default` — MosHub сообщает: *«default config содержит неизвестные ключи: rules»*.  
Вместо этого на каждом job указан классический `only:` (ветки + `merge_requests`).

## Типичные проблемы

| Симптом | Решение |
|---------|---------|
| *недействительна: default … unknown keys: rules* | Обновите `.gitlab-ci.yml` с `main`; в `default` только `image` и `cache` |
| Pipeline pending, нет runner | Включить shared runners / назначить project runner |
| `pull access denied` для image | Задать `POSTGIS_IMAGE` / `PYTHON_IMAGE` из корп. registry |
| GDAL / osgeo import error | В логе job проверить `System GDAL version` и шаг `ci_install_deps.sh` |
| `ogdi/.../libgdal.so: undefined symbol: GDALVersionInfo` | Не использовать `find /usr/lib` для GDAL; нужен [`scripts/ci_resolve_gdal_paths.sh`](scripts/ci_resolve_gdal_paths.sh) |
| E2E timeout на Playwright | Увеличить job timeout; проверить установку chromium в логе `e2e` |

## Синхронизация с GitHub

Оба remote можно держать параллельно:

```bash
git push origin main
git push hub main
```

GitHub Actions и GitLab CI не конфликтуют — разные файлы конфигурации.
