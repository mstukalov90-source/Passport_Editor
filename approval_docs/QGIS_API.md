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

API выполняет в одной транзакции то же, что SQL-процедура из [QGIS_INTEGRATION.md](QGIS_INTEGRATION.md):

1. INSERT или UPDATE строки в `approval.approves`
2. При первом создании — триггер БД создаёт основной чат (`approval.cases`, `is_primary = true`)
3. Заголовок основного чата устанавливается из поля `name`
4. INSERT или UPDATE геометрии в `approval.geometry` (SRID 4326), привязанной к основному чату

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

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `incoming_guid` | string (UUID v4) | да | Внешний идентификатор задания. Генерируется **один раз в QGIS**. Ключ upsert и `TaskGUID` для слоёв съёмки на карте |
| `n_root` | array[string] | да | Список rootid смежных паспортов, например `["09811"]` |
| `v_root` | array[string] (ровно 2) | да | Пара rootid, например `["10482", "09811"]` |
| `name` | string | да | Название согласования (отображается в веб-UI и как заголовок основного чата) |
| `owners` | array[string] | да | Список `OwnerLegalPersonId` организаций, которым видно согласование. Без него запись создастся, но **никто её не увидит** |
| `geometry` | GeoJSON object | да | Контур или линия зоны согласования. SRID **4326** (WGS84) |

### Пример значений

```json
{
  "incoming_guid": "2e333940-831b-48f5-9751-acd0c2880974",
  "n_root": ["09811"],
  "v_root": ["10482", "09811"],
  "name": "Согласование границ паспорта ДТ-10482",
  "owners": ["10233594", "10233595"],
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [37.605, 55.748],
        [37.618, 55.748],
        [37.618, 55.756],
        [37.605, 55.756],
        [37.605, 55.748]
      ]
    ]
  }
}
```

### Геометрия

- Допустимые типы GeoJSON: `Polygon`, `LineString`, `MultiPolygon`, `MultiLineString` и другие, поддерживаемые PostGIS
- Координаты в WGS84 (долгота, широта)
- Если исходная геометрия в другой СК (например МСК), трансформируйте в **4326** на стороне QGIS до отправки

### Идентификаторы: что генерировать, что не передавать

| Идентификатор | Кто создаёт | Комментарий |
|---------------|-------------|-------------|
| `incoming_guid` | **QGIS** | Единственный UUID, который модуль обязан сгенерировать |
| `approve_id` | **API / БД** | Возвращается в ответе, не передаётся в запросе |
| `primary_case_id` | **API / БД** (триггер) | Возвращается в ответе |
| `geometry_id` | **API / БД** | Возвращается в ответе |

---

## Ответ

### Успех (HTTP 200)

```json
{
  "ok": true,
  "created": true,
  "approve_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "incoming_guid": "2e333940-831b-48f5-9751-acd0c2880974",
  "primary_case_id": "f7e8d9c0-b1a2-3456-7890-abcdef123456",
  "geometry_id": 123
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| `ok` | boolean | Всегда `true` при успехе |
| `created` | boolean | `true` — запись создана впервые; `false` — выполнен upsert |
| `approve_id` | string (UUID) | Внутренний id в `approval.approves` |
| `incoming_guid` | string (UUID) | Эхо переданного идентификатора |
| `primary_case_id` | string (UUID) | Id основного чата (`is_primary = true`) |
| `geometry_id` | integer | Id строки в `approval.geometry` |

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
| **400** | Невалидный JSON, отсутствуют обязательные поля, неверный UUID, `v_root` ≠ 2 элемента, пустой `owners` |
| **403** | Запрос не через внутренний IP (`Host` не в `APPROVAL_QGIS_ALLOWED_HOSTS`) |
| **409** | Согласование уже полностью согласовано (`approved = true`) — upsert запрещён |
| **500** | Неожиданная ошибка сервера или БД |

### Поведение upsert

Повторный `POST` с тем же `incoming_guid`:

- обновляет `n_root`, `v_root`, `name`, `owners` в `approval.approves`
- синхронизирует `n_root` и `owners` у основного чата (`approval.cases`, `is_primary = true`)
- обновляет заголовок основного чата
- обновляет геометрию основного события (или создаёт, если её не было)

Upsert **запрещён**, если согласование уже имеет `approved = true` (все стороны согласовали).

---

## Примеры вызова

### curl

```bash
curl -X POST 'http://172.21.197.77/approval/api/qgis/approves/' \
  -H 'Content-Type: application/json' \
  -d '{
    "incoming_guid": "2e333940-831b-48f5-9751-acd0c2880974",
    "n_root": ["09811"],
    "v_root": ["10482", "09811"],
    "name": "Согласование границ паспорта ДТ-10482",
    "owners": ["10233594", "10233595"],
    "geometry": {
      "type": "Polygon",
      "coordinates": [[[37.605,55.748],[37.618,55.748],[37.618,55.756],[37.605,55.756],[37.605,55.748]]]
    }
  }'
```

### Python (stdlib)

```python
import json
import urllib.request

API_URL = "http://172.21.197.77/approval/api/qgis/approves/"

payload = {
    "incoming_guid": "2e333940-831b-48f5-9751-acd0c2880974",
    "n_root": ["09811"],
    "v_root": ["10482", "09811"],
    "name": "Согласование границ паспорта ДТ-10482",
    "owners": ["10233594", "10233595"],
    "geometry": {
        "type": "Polygon",
        "coordinates": [
            [[37.605, 55.748], [37.618, 55.748], [37.618, 55.756], [37.605, 55.756], [37.605, 55.748]]
        ],
    },
}

req = urllib.request.Request(
    API_URL,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"},
    method="POST",
)
with urllib.request.urlopen(req) as resp:
    result = json.loads(resp.read())
    print(result)
```

### Python (requests)

```python
import requests

response = requests.post(
    "http://172.21.197.77/approval/api/qgis/approves/",
    json={
        "incoming_guid": "2e333940-831b-48f5-9751-acd0c2880974",
        "n_root": ["09811"],
        "v_root": ["10482", "09811"],
        "name": "Согласование границ паспорта ДТ-10482",
        "owners": ["10233594", "10233595"],
        "geometry": {
            "type": "Polygon",
            "coordinates": [
                [[37.605, 55.748], [37.618, 55.748], [37.618, 55.756], [37.605, 55.756], [37.605, 55.748]]
            ],
        },
    },
    timeout=30,
)
response.raise_for_status()
print(response.json())
```

---

## Проверка после отправки

### Веб-интерфейс

Войти под пользователем, у которого `users."OwnerLegalPersonId"` входит в `owners`, и открыть:

```
https://border-ogh.mggt.ru/approval/
```

На карте должны отобразиться геометрия основного события и слои съёмки (при совпадении `incoming_guid` с `TaskGUID` в `mggt_asu`).

### SQL (на сервере)

```bash
sudo docker exec -it passport_db psql -U postgres -d geodb
```

```sql
SELECT id, incoming_guid, n_root, v_root, name, owners, approved
FROM approval.approves
WHERE incoming_guid = '2e333940-831b-48f5-9751-acd0c2880974'::uuid;

SELECT c.id, c.is_primary, c.title, c.status
FROM approval.cases c
JOIN approval.approves a ON a.id = c.approve_id
WHERE a.incoming_guid = '2e333940-831b-48f5-9751-acd0c2880974'::uuid;

SELECT g.id, ST_AsText(g.geom), g.label
FROM approval.geometry g
JOIN approval.approves a ON a.id = g.approve_id
WHERE a.incoming_guid = '2e333940-831b-48f5-9751-acd0c2880974'::uuid;
```

---

## Связь с картой съёмки

Веб-карта подгружает объекты из БД **`mggt_asu`** (`172.21.197.51`), схема `work`, фильтруя по **`TaskGUID`** = **`incoming_guid`**.

Поэтому `incoming_guid`, который QGIS передаёт в API, должен **совпадать** с `TaskGUID` в таблицах `work.*` на `172.21.197.51`.

---

## Типичные ошибки

| Симптом | Причина | Решение |
|---------|---------|---------|
| HTTP 403 | Запрос через `border-ogh.mggt.ru` | Использовать `http://172.21.197.77/...` |
| HTTP 409 | Согласование уже согласовано | Не повторять upsert; создать новое с другим `incoming_guid` |
| HTTP 400, `v_root` | Массив не из 2 элементов | Передать ровно 2 rootid |
| Согласование не видно в веб-UI | Пустой или неверный `owners` | Указать `OwnerLegalPersonId` всех сторон |
| Геометрия не на карте | Неверный SRID или пустая geometry | GeoJSON в WGS84 (4326) |
| Слои съёмки не видны | `incoming_guid` ≠ `TaskGUID` | Использовать один GUID в API и в `mggt_asu` |

---

## Реализация в кодовой базе

| Компонент | Путь |
|-----------|------|
| View | `approval/api_views.py` → `api_qgis_upsert_approve` |
| Бизнес-логика | `approval/events_service.py` → `upsert_approve_from_qgis` |
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
  -d '{"incoming_guid":"...","n_root":["09811"],"v_root":["10482","09811"],"name":"Тест","owners":["OWNER_A"],"geometry":{"type":"Polygon","coordinates":[[[37.6,55.75],[37.61,55.75],[37.61,55.76],[37.6,55.76],[37.6,55.75]]]}}'
```
