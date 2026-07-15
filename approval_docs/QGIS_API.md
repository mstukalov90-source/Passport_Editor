# HTTP API: QGIS ↔ согласование

Документ для разработчика QGIS-модуля: **создание** согласований, **чтение** чатов/геометрии и **запись** сообщений через приложение `approval`.

Связанные материалы:

- [DATA_MODEL.md](DATA_MODEL.md) — схема `approval`, смысл сущностей и связи
- [QGIS_INTEGRATION.md](QGIS_INTEGRATION.md) — интеграция, fallback прямая запись в БД
- [DEPLOY.md](../DEPLOY.md) — деплой на `172.21.197.77`, переменные `.env`

Базовый URL (прод): `http://172.21.197.77/approval/api/qgis/`

---

## Обзор эндпоинтов

| Метод | URL | Назначение |
|-------|-----|------------|
| POST | `approves/` | Upsert согласования из QGIS (ingest) |
| GET | `approves/?user=` | Список доступных согласований |
| GET | `approves/<approve_id>/?user=` | Деталь согласования + доступные cases |
| GET | `approves/by-guid/<incoming_guid>/?user=` | То же по `incoming_guid` |
| GET | `approves/<approve_id>/geometries/?user=` | GeoJSON FeatureCollection геометрий |
| GET | `cases/<case_id>/?user=` | Чат события: сообщения, вложения, геометрии |
| POST | `cases/<case_id>/messages/` | Новое сообщение (+ geometry / files) |
| POST | `cases/<case_id>/approve/` | Согласовать событие от имени `user` |
| POST | `cases/<case_id>/revoke/` | Снять своё согласование |

Content-Type для JSON: `application/json`. Django session **не** используется.

---

## Доступ и безопасность

### Host allowlist

Все эндпоинты QGIS API принимают запросы **только** при обращении к внутреннему IP:

```
http://172.21.197.77/approval/api/qgis/...
```

| Адрес | Результат |
|-------|-----------|
| `http://172.21.197.77/...` | Разрешён |
| `https://border-ogh.mggt.ru/...` | **403 Forbidden** |

Публичный домен для QGIS API **не используется**.

### Логин (`user`)

Auth выполняется в QGIS. Сервер **доверяет** переданному логину после проверки Host.

| Тип запроса | Как передать `user` |
|-------------|---------------------|
| GET | обязательный query: `?user=asidorov` |
| POST (сообщения / approve / revoke) | поле JSON `user` и/или query `?user=` |
| POST upsert | поле JSON `user` (логин инспектора в `approves.user`) |

Без `user` на read/write-эндпоинтах → **400**.

Фильтрация видимости — как в веб-модуле ([`access.py`](../approval/access.py)):

- инспектор: `approves.user == login`
- участник: `login` в `cases.participant_logins`
- владелец: `users.OwnerLegalPersonId` входит в `cases.owners`

Нет доступа → **404** (событие/согласование «не найдено»).

### Настройки (`.env`)

```text
APPROVAL_QGIS_ALLOWED_HOSTS=172.21.197.77,127.0.0.1,localhost,testserver
APPROVAL_QGIS_API_URL=http://172.21.197.77/approval/api/qgis/approves/
```

---

## 1. Upsert согласования (ingest)

| Параметр | Значение |
|----------|----------|
| Метод | `POST` |
| URL | `/approval/api/qgis/approves/` |
| Аутентификация | Host only; `user` в теле = инспектор |

В одной транзакции:

1. INSERT или UPDATE `approval.approves`
2. При первом создании — триггер создаёт primary case (`is_primary = true`)
3. Primary: `title = name`, `owners` из `mggt_asu` по `TaskGUID = incoming_guid`, без геометрии
4. Для каждого `events[]` — upsert event case + geometry (SRID 4326)

### Тело (JSON)

**Верхний уровень**

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `incoming_guid` | string (UUID v4) | да | Внешний id задания; ключ upsert и `TaskGUID` слоёв съёмки |
| `v_root` | array[string] | нет | rootid участников; может отсутствовать |
| `user` | string | да | Логин инспектора (`approves.user`) |
| `name` | string | да | Название согласования / заголовок primary |
| `events` | array[object] | да | События (см. ниже) |
| `brid` | string | нет | Игнорируется API |

**Каждый элемент `events[]`**

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `n_root` | string | да | RootId смежного паспорта; ключ upsert события |
| `owners` | array[string] | да | `OwnerLegalPersonId` стороны (минимум 1); владелец съёмки добавляется автоматически |
| `name` | string | да | Заголовок события |
| `geometry` | GeoJSON object | да | Геометрия события, SRID **4326** |

**Агрегация в `approves`:** `n_root` и `owners` собираются из `events[]` (+ owner съёмки).

### Пример запроса

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
    }
  ]
}
```

### Успешный ответ (200)

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
    }
  ]
}
```

### Поведение upsert

- тот же `incoming_guid` — только тот же `user` (иначе 409)
- обновляет агрегаты, title primary, события по `n_root`
- **не удаляет** отсутствующие в payload события
- уже согласованные события — `skipped: true`
- полностью согласованный approve — 409

### Коды HTTP (upsert)

| Код | Когда |
|-----|-------|
| 200 | Создано/обновлено |
| 400 | Невалидный payload / нет owner в `mggt_asu` |
| 403 | Публичный Host |
| 409 | Уже согласовано или чужой `user` |
| 500 | Ошибка сервера |

---

## 2. Список согласований

```
GET /approval/api/qgis/approves/?user=asidorov
```

**Ответ:**

```json
{
  "ok": true,
  "current_user": "asidorov",
  "approves": [
    {
      "id": "...",
      "incoming_guid": "...",
      "name": "...",
      "approved": false,
      "user": "asidorov",
      "owners": ["OWNER_TASK", "9000022"],
      "n_root": ["10001260"],
      "v_root": ["141564"],
      "cases_count": 3,
      "created_at": "15.07.2026 09:00",
      "updated_at": "15.07.2026 09:05"
    }
  ]
}
```

---

## 3. Деталь согласования

```
GET /approval/api/qgis/approves/<approve_id>/?user=asidorov
GET /approval/api/qgis/approves/by-guid/<incoming_guid>/?user=asidorov
```

Возвращает заголовок approve и массив `cases` (только доступные логину). Формат case — summary: title, status, approvals, participants, **geometry** события (без ленты сообщений).

```json
{
  "ok": true,
  "current_user": "asidorov",
  "approve": { "...": "..." },
  "primary_case_id": "...",
  "cases": [
    {
      "id": "...",
      "title": "...",
      "is_primary": false,
      "approved": false,
      "n_root": "10001260",
      "geometry": { "type": "Point", "coordinates": [37.61, 55.72] },
      "messages_count": 2
    }
  ]
}
```

---

## 4. Геометрии (слой для карты QGIS)

```
GET /approval/api/qgis/approves/<approve_id>/geometries/?user=asidorov
```

Ответ — FeatureCollection (корневые `type`/`features` + `ok`):

| properties | Описание |
|------------|----------|
| `geometry_id` | id в `approval.geometry` |
| `approve_id` | UUID согласования |
| `case_id` | UUID события |
| `message_id` | id сообщения или `null` (геометрия события) |
| `label` | подпись |
| `n_root` | root события |
| `is_primary` | primary case? |
| `owner_legal_person_id` | владелец, если задан |

**Два вида геометрии:**

- `message_id IS NULL` — геометрия **события** (из upsert `events[].geometry`)
- `message_id` задан — геометрия, прикреплённая к **сообщению чата**

---

## 5. Деталь события / чат

```
GET /approval/api/qgis/cases/<case_id>/?user=asidorov
```

`case` включает summary + `messages[]`. Поля сообщения:

| Поле | Описание |
|------|----------|
| `id` | id сообщения |
| `author` | логин автора |
| `text` | текст |
| `time` | время (локальный формат) |
| `parent_id` | ответ на сообщение |
| `attachments` | файлы (`url` для скачивания через веб-путь attachments) |
| `geometry` / `geometries` | GeoJSON геометрии(й) сообщения |
| `reactions` | реакции `in_progress` / `done` |

---

## 6. Отправка сообщения

```
POST /approval/api/qgis/cases/<case_id>/messages/
Content-Type: application/json
```

```json
{
  "user": "asidorov",
  "body": "Комментарий из QGIS",
  "parent_id": null,
  "geometry": { "type": "Point", "coordinates": [37.6, 55.7] }
}
```

или `geometries: [ ... ]` — несколько. Допустим multipart (`body`, `user`, `geometry`/`geometries` JSON-строки, `files`).

Если кейс уже `approved` — новые сообщения запрещены (400).

**Ответ:** `{ ok, message, case, current_user }`.

---

## 7. Согласовать / отозвать

```
POST /approval/api/qgis/cases/<case_id>/approve/
POST /approval/api/qgis/cases/<case_id>/revoke/
```

```json
{ "user": "asidorov" }
```

Логика та же, что в вебе: инспектор пишет в `case_approvals` по `approver_login`; владелец — по `owner_legal_person_id`. Событие закрывается, когда собраны все требуемые стороны (+ инспектор при наличии).

---

## Геометрия: требования

- GeoJSON, координаты WGS84 (долгота, широта), SRID **4326**
- Типы: Point, Polygon, LineString, Multi\* и др., поддерживаемые PostGIS
- Если исходные данные в МСК — трансформировать в 4326 **на стороне QGIS** до отправки

---

## Идентификаторы

| Идентификатор | Кто создаёт |
|---------------|-------------|
| `incoming_guid` | **QGIS** (один раз) |
| `approve_id`, `case_id` | API / БД |
| `geometry.id` | БД (identity) |

---

## Примеры вызова

### Upsert (curl)

```bash
curl -X POST 'http://172.21.197.77/approval/api/qgis/approves/' \
  -H 'Content-Type: application/json' \
  -d '{
    "incoming_guid": "956c45bb-dc44-46a7-9944-9d1996fec147",
    "user": "asidorov",
    "name": "Согласование заявки 46998",
    "events": [
      {
        "n_root": "10001260",
        "owners": ["9000022"],
        "name": "Событие по паспорту 10001260",
        "geometry": { "type": "Point", "coordinates": [37.618, 55.720] }
      }
    ]
  }'
```

### Чтение списка и чата (Python)

```python
import requests

BASE = "http://172.21.197.77/approval/api/qgis"
USER = "asidorov"

approves = requests.get(f"{BASE}/approves/", params={"user": USER}, timeout=30).json()
approve_id = approves["approves"][0]["id"]

detail = requests.get(
    f"{BASE}/approves/{approve_id}/",
    params={"user": USER},
    timeout=30,
).json()

case_id = detail["cases"][0]["id"]
chat = requests.get(
    f"{BASE}/cases/{case_id}/",
    params={"user": USER},
    timeout=30,
).json()

# слой для карты
fc = requests.get(
    f"{BASE}/approves/{approve_id}/geometries/",
    params={"user": USER},
    timeout=30,
).json()

# сообщение с геометрией
requests.post(
    f"{BASE}/cases/{case_id}/messages/",
    json={
        "user": USER,
        "body": "Уточнение границы",
        "geometry": {"type": "Point", "coordinates": [37.62, 55.72]},
    },
    timeout=30,
).raise_for_status()
```

---

## Проверка после отправки

### Веб-интерфейс

```
https://border-ogh.mggt.ru/approval/
```

### SQL

```sql
SELECT id, incoming_guid, n_root, v_root, name, owners, "user", approved
FROM approval.approves
WHERE incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;

SELECT c.id, c.is_primary, c.title, c.n_root, c.owners, c.status
FROM approval.cases c
JOIN approval.approves a ON a.id = c.approve_id
WHERE a.incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;

SELECT g.id, g.case_id, g.message_id, ST_AsText(g.geom), g.label
FROM approval.geometry g
JOIN approval.approves a ON a.id = g.approve_id
WHERE a.incoming_guid = '956c45bb-dc44-46a7-9944-9d1996fec147'::uuid;
```

---

## Связь с картой съёмки

Веб-карта подгружает объекты из **`mggt_asu`** (`work.*`), фильтруя по **`TaskGUID` = `incoming_guid`**. GUID в API и в съёмке должен совпадать.

---

## Типичные ошибки

| Симптом | Причина | Решение |
|---------|---------|---------|
| HTTP 403 | Запрос через `border-ogh.mggt.ru` | `http://172.21.197.77/...` |
| HTTP 400, `user` | Нет логина на GET/POST read-write | Передать `?user=` / поле `user` |
| HTTP 404 | Нет доступа по логину | Проверить inspector / owners / participants |
| HTTP 409 | Уже согласовано / чужой upsert user | Другой GUID или тот же `user` |
| HTTP 400, OwnerLegalPersonId | Нет `TaskGUID` в `mggt_asu` | Сначала записать съёмку |
| Геометрия не на карте | Неверный SRID | Только 4326 |

---

## Реализация в кодовой базе

| Компонент | Путь |
|-----------|------|
| QGIS views | `approval/qgis_api_views.py` |
| Веб views | `approval/api_views.py` |
| Бизнес-логика | `approval/events_service.py` |
| Доступ | `approval/access.py` |
| Host check | `approval/qgis_access.py` |
| URL | `approval/urls.py` → `api/qgis/...` |
| Тесты | `tests/test_approval_qgis_api.py` |
| Настройки | `pass_map/settings.py` → `APPROVAL_QGIS_*` |

---

## Локальная разработка

```bash
cd GeoDjango
python manage.py runserver
curl 'http://127.0.0.1:8000/approval/api/qgis/approves/?user=asidorov'
```
