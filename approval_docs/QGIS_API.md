# HTTP API: приём согласований из QGIS

Документ для разработчика QGIS-модуля, который создаёт или обновляет согласование через веб-приложение «Согласование» (Django, приложение `approval`).

Связанные материалы:

- [QGIS_INTEGRATION.md](QGIS_INTEGRATION.md) — полная инструкция по интеграции (в т.ч. прямая запись в БД как fallback)
- [DEPLOY.md](../DEPLOY.md) — деплой на `172.21.197.77`, переменные `.env`

---

## Обзор

| Параметр | Значение |
|----------|----------|
| Метод | `POST` |
| URL (прод) | `http://172.21.197.77/approval/api/qgis/approves/` |
| Content-Type | `application/json` |
| Аутентификация | не требуется |
| Идемпотентность | upsert по полю `incoming_guid` |

API в одной транзакции:

1. INSERT или UPDATE строки в `approval.approves`
2. При первом создании — триггер БД создаёт основной чат (`approval.cases`, `is_primary = true`)
3. Заголовок основного чата устанавливается из поля `name`; `owners` primary — `OwnerLegalPersonId` объекта съёмки из `mggt_asu` по `TaskGUID = incoming_guid`
4. Для каждого элемента `events[]` — INSERT или UPDATE события (`approval.cases`, `is_primary = false`) и его геометрии (`approval.geometry`, SRID 4326)

---

## Доступ и безопасность

### Только внутренний адрес сервера

Запросы принимаются **только** при обращении напрямую к внутреннему IP сервера МГГТ:

```
http://172.21.197.77/approval/api/qgis/approves/
```

| Адрес | Результат |
|-------|-----------|
| `http://172.21.197.77/...` | Разрешён |
| `https://border-ogh.mggt.ru/...` | **403 Forbidden** |

Публичный домен `border-ogh.mggt.ru` терминирует TLS на корпоративном reverse-proxy. Для QGIS API он **не используется** — приложение проверяет заголовок `Host` и отклоняет запросы с публичного домена.

Контейнер `passport_web` слушает **порт 80** (HTTP). Шифрование на внутреннем IP отсутствует.

### Настройки сервера (`.env`)

```text
# Разрешённые значения Host для QGIS API (через запятую)
APPROVAL_QGIS_ALLOWED_HOSTS=172.21.197.77,127.0.0.1,localhost,testserver

# Справочный URL (для документации и клиентов)
APPROVAL_QGIS_API_URL=http://172.21.197.77/approval/api/qgis/approves/
```

На проде `172.21.197.77` уже входит в `DJANGO_ALLOWED_HOSTS`. После изменения `.env` пересоздать контейнер:

```bash
sudo docker compose -f docker-compose.yml -f docker-compose.images.yml up -d --force-recreate web
```

---

## Запрос

### Тело (JSON)

**Верхний уровень**

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `incoming_guid` | string (UUID v4) | да | Внешний идентификатор задания. Генерируется **один раз в QGIS**. Ключ upsert и `TaskGUID` для слоёв съёмки на карте |
| `v_root` | array[string] | нет | Список rootid участников согласования, например `["141564", "4066869", "1289566312"]`. Может отсутствовать |
| `user` | string | да | Логин инспектора (записывается в `approval.approves.user`) |
| `name` | string | да | Название согласования (отображается в веб-UI и как заголовок основного чата) |
| `events` | array[object] | да | Список событий согласования (см. ниже) |
| `brid` | string | нет | Справочная информация из QGIS; **игнорируется** API |

**Каждый элемент `events[]`**

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `n_root` | string | да | RootId смежного паспорта; ключ upsert события внутри согласования |
| `owners` | array[string] | да | `OwnerLegalPersonId` стороны смежного паспорта (минимум 1). Владелец объекта съёмки добавляется автоматически по `incoming_guid` |
| `name` | string | да | Заголовок события (`approval.cases.title`) |
| `geometry` | GeoJSON object | да | Геометрия события. SRID **4326** (WGS84) |

**Агрегация в `approval.approves`:**

- `n_root` = уникальные `events[].n_root` в порядке появления
- `owners` = владелец объекта съёмки (`TaskGUID = incoming_guid`) + объединение всех `events[].owners` (уникальные, порядок сохраняется)

**Event case** (`is_primary = false`):

- `owners` = владелец объекта съёмки + стороны из `events[].owners` (после дедупликации 1 или 2 уникальных `OwnerLegalPersonId`; совпадение владельцев допустимо)

**Primary case** (`is_primary = true`):

- создаётся автоматически при INSERT в `approves`
- `title = name`, геометрии **нет**
- `owners` = один `OwnerLegalPersonId`, найденный в `mggt_asu` по `TaskGUID = incoming_guid`
- инспектор (`user`) видит согласование через `approves.user`

### Пример значений

```json
{
  "incoming_guid": "956c45bb-dc44-46a7-9944-9d1996fec147",
  "v_root": ["141564", "4066869", "1289566312"],
  "user": "asidorov",
  "brid": "46998",
  "name": "Согласование заявки из графика паспортизации 46998",
  "events": [
    {
      "n_root": "10001260",
      "owners": ["9000022"],
      "name": "Согласование заявок по паспортизации 46998 и паспорта 10001260",
      "geometry": {
        "type": "Point",
        "coordinates": [37.618173936455285, 55.720464618162595]
      }
    },
    {
      "n_root": "12345148",
      "owners": ["9000022"],
      "name": "Согласование заявок по паспортизации 46998 и паспорта 12345148",
      "geometry": {
        "type": "Point",
        "coordinates": [37.61776133391202, 55.720827777176524]
      }
    }
  ]
}
```

### Геометрия

- Допустимые типы GeoJSON: `Point`, `Polygon`, `LineString`, `MultiPolygon`, `MultiLineString` и другие, поддерживаемые PostGIS
- Координаты в WGS84 (долгота, широта)
- Если исходная геометрия в другой СК (например МСК), трансформируйте в **4326** на стороне QGIS до отправки

### Идентификаторы: что генерировать, что не передавать

| Идентификатор | Кто создаёт | Комментарий |
|---------------|-------------|-------------|
| `incoming_guid` | **QGIS** | Единственный UUID, который модуль обязан сгенерировать |
| `approve_id` | **API / БД** | Возвращается в ответе, не передаётся в запросе |
| `primary_case_id` | **API / БД** (триггер) | Возвращается в ответе |
| `events[].case_id` | **API / БД** | Возвращается в ответе для каждого события |
| `events[].geometry_id` | **API / БД** | Возвращается в ответе для каждого события |

---

## Ответ

### Успех (HTTP 200)

```json
{
  "ok": true,
  "created": true,
  "approve_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "incoming_guid": "956c45bb-dc44-46a7-9944-9d1996fec147",
  "primary_case_id": "f7e8d9c0-b1a2-3456-7890-abcdef123456",
  "events": [
    {
      "n_root": "10001260",
      "case_id": "11111111-1111-1111-1111-111111111111",
      "geometry_id": 42,
      "created": true,
      "skipped": false
    },
    {
      "n_root": "12345148",
      "case_id": "22222222-2222-2222-2222-222222222222",
      "geometry_id": 43,
      "created": true,
      "skipped": false
    }
  ]
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| `ok` | boolean | Всегда `true` при успехе |
| `created` | boolean | `true` — согласование создано впервые; `false` — выполнен upsert |
| `approve_id` | string (UUID) | Внутренний id в `approval.approves` |
| `incoming_guid` | string (UUID) | Эхо переданного идентификатора |
| `primary_case_id` | string (UUID) | Id основного чата (`is_primary = true`) |
| `events` | array | Результат upsert по каждому событию |
| `events[].n_root` | string | RootId события |
| `events[].case_id` | string (UUID) | Id события в `approval.cases` |
| `events[].geometry_id` | integer \| null | Id геометрии в `approval.geometry` |
| `events[].created` | boolean | `true` — событие создано; `false` — обновлено |
| `events[].skipped` | boolean | `true` — событие уже согласовано, изменения пропущены |

### Ошибка (HTTP 4xx / 5xx)

```json
{
  "ok": false,
  "error": "Описание ошибки на русском языке"
}
```

### Коды HTTP

| Код | Когда возникает |
|-----|-----------------|
| **200** | Согласование создано или обновлено |
| **400** | Невалидный JSON, отсутствуют обязательные поля, неверный UUID, пустой `events`/`user`, дублирующийся `n_root`, не найден `OwnerLegalPersonId` по `TaskGUID` |
| **403** | Запрос не через внутренний IP (`Host` не в `APPROVAL_QGIS_ALLOWED_HOSTS`) |
| **409** | Согласование уже полностью согласовано (`approved = true`), либо `incoming_guid` уже занят другим `user` — upsert запрещён |
| **500** | Неожиданная ошибка сервера или БД |

### Поведение upsert

Повторный `POST` с тем же `incoming_guid`:

- разрешён **только тому же** `user`, что уже записан в `approval.approves.user`; чужой `user` получает HTTP 409
- обновляет `user`, `name`, агрегированные `n_root` и `owners` в `approval.approves`
- обновляет `v_root`, только если поле передано в запросе
- обновляет заголовок и `owners` основного чата (owner из `mggt_asu`)
- для каждого `events[]` сопоставляет событие по `n_root`: обновляет title/owners/geometry или создаёт новое
- **не удаляет** события, отсутствующие в новом payload
- **не изменяет** события, у которых `approved = true` (`skipped: true` в ответе)

Upsert **запрещён**, если согласование уже имеет `approved = true`, либо если `user` в запросе отличается от уже сохранённого.

---

## Примеры вызова

### curl

```bash
curl -X POST 'http://172.21.197.77/approval/api/qgis/approves/' \
  -H 'Content-Type: application/json' \
  -d '{
    "incoming_guid": "956c45bb-dc44-46a7-9944-9d1996fec147",
    "v_root": ["141564", "4066869", "1289566312"],
    "user": "asidorov",
    "name": "Согласование заявки из графика паспортизации 46998",
    "events": [
      {
        "n_root": "10001260",
        "owners": ["9000022"],
        "name": "Согласование заявок по паспортизации 46998 и паспорта 10001260",
        "geometry": {
          "type": "Point",
          "coordinates": [37.618173936455285, 55.720464618162595]
        }
      }
    ]
  }'
```

### Python (requests)

```python
import requests

response = requests.post(
    "http://172.21.197.77/approval/api/qgis/approves/",
    json={
        "incoming_guid": "956c45bb-dc44-46a7-9944-9d1996fec147",
        "v_root": ["141564", "4066869", "1289566312"],
        "user": "asidorov",
        "name": "Согласование заявки из графика паспортизации 46998",
        "events": [
            {
                "n_root": "10001260",
                "owners": ["9000022"],
                "name": "Согласование заявок по паспортизации 46998 и паспорта 10001260",
                "geometry": {
                    "type": "Point",
                    "coordinates": [37.618173936455285, 55.720464618162595],
                },
            }
        ],
    },
    timeout=30,
)
response.raise_for_status()
print(response.json())
```

---

## Проверка после отправки

### Веб-интерфейс

Войти под пользователем, у которого `users."OwnerLegalPersonId"` входит в `owners` события или primary, и открыть:

```
https://border-ogh.mggt.ru/approval/
```

На карте должны отобразиться геометрии событий и слои съёмки (при совпадении `incoming_guid` с `TaskGUID` в `mggt_asu`).

### SQL (на сервере)

```bash
sudo docker exec -it passport_db psql -U postgres -d geodb
```

```sql
SELECT id, incoming_guid, n_root, v_root, name, owners, "user", approved
FROM approval.approves
WHERE incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;

SELECT c.id, c.is_primary, c.title, c.n_root, c.owners, c.status
FROM approval.cases c
JOIN approval.approves a ON a.id = c.approve_id
WHERE a.incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;

SELECT g.id, c.n_root, ST_AsText(g.geom), g.label
FROM approval.geometry g
JOIN approval.cases c ON c.id = g.case_id
JOIN approval.approves a ON a.id = g.approve_id
WHERE a.incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;
```

---

## Связь с картой съёмки

Веб-карта подгружает объекты из БД **`mggt_asu`** (`172.21.197.51`), схема `work`, фильтруя по **`TaskGUID`** = **`incoming_guid`**.

Поэтому `incoming_guid`, который QGIS передаёт в API, должен **совпадать** с `TaskGUID` в таблицах `work.*` на `172.21.197.51`. По этому же GUID API определяет `OwnerLegalPersonId` для primary case.

---

## Типичные ошибки

| Симптом | Причина | Решение |
|---------|---------|---------|
| HTTP 403 | Запрос через `border-ogh.mggt.ru` | Использовать `http://172.21.197.77/...` |
| HTTP 409 | Согласование уже согласовано | Не повторять upsert; создать новое с другим `incoming_guid` |
| HTTP 409, другим пользователем | `incoming_guid` уже создан другим `user` | Повторять upsert только тем же `user`, либо взять другой `incoming_guid` |
| HTTP 400, `events` | Пустой или отсутствующий массив | Передать хотя бы одно событие |
| HTTP 400, OwnerLegalPersonId | Нет объекта с `TaskGUID = incoming_guid` в `mggt_asu` | Убедиться, что съёмка записана в `work.*` до отправки |
| Согласование не видно в веб-UI | Неверный `owners` в events или owner primary | Проверить `OwnerLegalPersonId` в payload и в `mggt_asu` |
| Геометрия не на карте | Неверный SRID или пустая geometry | GeoJSON в WGS84 (4326) |
| Слои съёмки не видны | `incoming_guid` ≠ `TaskGUID` | Использовать один GUID в API и в `mggt_asu` |

---

## Реализация в кодовой базе

| Компонент | Путь |
|-----------|------|
| View | `approval/api_views.py` → `api_qgis_upsert_approve` |
| Бизнес-логика | `approval/events_service.py` → `upsert_approve_from_qgis` |
| Lookup owner | `approval/work_layers.py` → `resolve_task_owner_legal_person_id` |
| Проверка Host | `approval/qgis_access.py` → `qgis_api_host_allowed` |
| URL | `approval/urls.py` → `api/qgis/approves/` |
| Тесты | `tests/test_approval_qgis_api.py` |
| Настройки | `pass_map/settings.py` → `APPROVAL_QGIS_*` |

---

## Локальная разработка

При отладке на Mac/CI endpoint доступен на `http://127.0.0.1:8000/approval/api/qgis/approves/` (runserver). `127.0.0.1` входит в `APPROVAL_QGIS_ALLOWED_HOSTS` по умолчанию.

```bash
cd GeoDjango
python manage.py runserver
curl -X POST 'http://127.0.0.1:8000/approval/api/qgis/approves/' \
  -H 'Content-Type: application/json' \
  -d '{"incoming_guid":"956c45bb-dc44-46a7-9944-9d1996fec147","v_root":["141564"],"user":"asidorov","name":"Тест","events":[{"n_root":"10001260","owners":["9000022"],"name":"Событие","geometry":{"type":"Point","coordinates":[37.61,55.72]}}]}'
```
