# HTTP API: QGIS ↔ слои заявок и досъёмов

Документ для разработчика QGIS-модуля: **read-only** GeoJSON-слои и списки отрисованных
заявок и досъёмов через приложение `pass_viewer`. Создание и правка этих сущностей остаются
в веб-приложении — API только отдаёт данные для отображения в QGIS.

Связанные материалы:

- [QGIS_API.md](QGIS_API.md) — основной QGIS API модуля «Согласование» (`/approval/api/qgis/`)
- [QGIS_INTEGRATION.md](QGIS_INTEGRATION.md) — полная инструкция для QGIS-модуля, подключения к БД
- [DATA_MODEL.md](DATA_MODEL.md) — схема `approval` (для контекста основного API)

Базовый URL (прод): `https://border-ogh.mggt.ru/api/qgis/`

Обратите внимание: **без** префикса `/approval` — эндпоинты живут в приложении
`pass_viewer`, а не в модуле согласования.

---

## Обзор эндпоинтов

| Метод | URL | Назначение |
|-------|-----|------------|
| GET | `requests/?user=` | GeoJSON-слой отрисованных заявок (все источники: ДТ/ОДХ/ОЗН/ТОП) |
| GET | `recaps/?user=` | GeoJSON-слой досъёмов (`recaps`) |
| GET | `requests/list/?user=` | Список всех заявок (без геометрии) |
| GET | `recaps/list/?user=` | Список всех досъёмов (без геометрии) |

Content-Type ответа: `application/json`. Django session **не** используется,
CSRF-токен не нужен. POST/PUT/DELETE отсутствуют — всё API только читается.

Слой (`requests/`, `recaps/`) и список (`requests/list/`, `recaps/list/`) принимают
одинаковые фильтры и правила доступа; различие только в формате ответа: слой —
GeoJSON FeatureCollection с геометрией, список — компактный JSON для реестров
и pick-листов.

---

## Доступ и безопасность

### Host allowlist

Общий с основным QGIS API allowlist (`APPROVAL_QGIS_ALLOWED_HOSTS`, см. `.env`):

| Адрес | Результат |
|-------|-----------|
| `https://border-ogh.mggt.ru/...` | Разрешён (основной путь) |
| `http://172.21.197.77/...` или `http://192.168.1.40/...` | Разрешён (переходный период) |
| произвольный другой Host | **403 Forbidden** |

### Логин (`user`) и роль

Auth выполняется в QGIS. Сервер доверяет логину из query-параметра `?user=<логин>`
(обязателен, иначе **400**).

Слои отдают **все** заявки и досъёмы без фильтра по владельцу, поэтому логин
дополнительно проверяется по роли в таблице `users`:

| Роль (`users.role`) | Доступ |
|---------------------|--------|
| `MGGT` | разрешён |
| `SUP` | разрешён |
| `BD`, `DEP`, `DEP+`, неизвестный логин | **403 Forbidden** |

---

## Данные: что такое «отрисованная заявка» и «досъём»

Сущности не имеют ORM-моделей — это строки raw PostGIS-таблиц в `geodb`
(default connection приложения):

| Сущность | Таблицы | Признак |
|----------|---------|---------|
| Отрисованная заявка | `pass_objects` (ДТ), `odh` (ОДХ), `ozn` (ОЗН), `top` (ТОП) | `request_id` непустой **и** `rootid` пустой |
| Досъём | `recaps` | строка таблицы; ключ `recap_id`, привязка к заявке через `request_id` |

`source` в properties — метка таблицы-источника заявки (`ДТ` / `ОДХ` / `ОЗН` / `ТОП`).
Геометрия — WGS84, SRID **4326** (MultiPolygon или иная валидная 2D-геометрия).

---

## 1. Слой заявок

```
GET /api/qgis/requests/?user=<логин>
```

### Параметры (query)

| Параметр | Обязателен | Значение |
|----------|------------|----------|
| `user` | да | логин сотрудника (MGGT/SUP) |
| `request_id` | нет | фильтр по номеру заявки, только цифры, точное совпадение |
| `source` | нет | источник: `ДТ`, `ОДХ`, `ОЗН`, `ТОП`; псевдонимы `ОО` → ОЗН, `TOP` → ТОП; регистр не важен |

Невалидный `request_id` (не цифры) → **400**; неизвестный `source` → **400**.

### Ответ (200)

GeoJSON FeatureCollection в обёртке API:

```json
{
  "ok": true,
  "current_user": "asidorov",
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [ [ [ [37.61, 55.72], [37.62, 55.72], [37.62, 55.73], [37.61, 55.72] ] ] ]
      },
      "properties": {
        "source": "ДТ",
        "request_id": "141564",
        "rootid": null,
        "name": "Заявка 141564",
        "owner_legal_person_id": "9000022",
        "owner_legal_person_name": "ООО Пример",
        "customer_legal_person_id": null,
        "customer_legal_person_name": null,
        "department_legal_person_id": null,
        "department_legal_person_name": null,
        "startdate": null,
        "datesurvey": null,
        "createtype": null
      }
    }
  ]
}
```

### Properties

| Поле | Смысл |
|------|-------|
| `source` | метка источника: `ДТ` / `ОДХ` / `ОЗН` / `ТОП` |
| `request_id` | номер заявки (BrId в АСУ ОДС) |
| `rootid` | всегда `null` для отрисованной заявки (заполняется после склейки в паспорт) |
| `name` | название объекта |
| `owner_legal_person_id` / `owner_legal_person_name` | владелец (для ОДХ — по полю заказчика, если у строки нет владельца) |
| `customer_legal_person_id` / `customer_legal_person_name` | заказчик (ОДХ), иначе `null` |
| `department_legal_person_id` / `department_legal_person_name` | департамент, иначе `null` |
| `startdate`, `datesurvey`, `createtype` | метаданные GIS-таблицы, если колонки есть, иначе `null` |

---

## 2. Слой досъёмов

```
GET /api/qgis/recaps/?user=<логин>
```

### Параметры (query)

| Параметр | Обязателен | Значение |
|----------|------------|----------|
| `user` | да | логин сотрудника (MGGT/SUP) |
| `request_id` | нет | фильтр по номеру заявки, только цифры |
| `recap_id` | нет | фильтр по номеру досъёма, только цифры |

Фильтры комбинируются по И. Невалидные значения → **400**.

### Ответ (200)

Та же обёртка; properties короче:

```json
{
  "ok": true,
  "current_user": "asidorov",
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[37.61, 55.72], [37.62, 55.72], [37.62, 55.73], [37.61, 55.72]]]
      },
      "properties": {
        "recap_id": "77",
        "request_id": "141564",
        "name": "Досъём по заявке 141564",
        "owner_legal_person_id": "9000022",
        "owner_legal_person_name": "ООО Пример"
      }
    }
  ]
}
```

Фичи упорядочены по `recap_id` по возрастанию.

---

## 3. Список заявок (без геометрии)

```
GET /api/qgis/requests/list/?user=<логин>
```

Те же параметры и правила доступа, что у слоя заявок (`user` обязателен;
`request_id`, `source` — опциональные фильтры). Отдаёт **все** заявки, по одной
записи на строку источника (как фичи слоя), но без геометрии — удобно для реестров
и pick-листов в плагине.

### Ответ (200)

```json
{
  "ok": true,
  "current_user": "asidorov",
  "count": 2,
  "requests": [
    {
      "source": "ДТ",
      "request_id": "141564",
      "rootid": null,
      "name": "Заявка 141564",
      "owner_legal_person_id": "9000022",
      "owner_legal_person_name": "ООО Пример",
      "customer_legal_person_id": null,
      "customer_legal_person_name": null,
      "department_legal_person_id": null,
      "department_legal_person_name": null,
      "startdate": null,
      "datesurvey": null,
      "createtype": null
    },
    {
      "source": "ТОП",
      "request_id": "005",
      "rootid": null,
      "name": "Заявка 005",
      "owner_legal_person_id": "9000031",
      "owner_legal_person_name": "ООО Другая",
      "customer_legal_person_id": null,
      "customer_legal_person_name": null,
      "department_legal_person_id": null,
      "department_legal_person_name": null,
      "startdate": null,
      "datesurvey": null,
      "createtype": null
    }
  ]
}
```

Поля записей идентичны `properties` фич слоя заявок (см. таблицу в разделе 1):
все ключи присутствуют всегда, отсутствующие данные — `null`. `count` — число записей.

---

## 4. Список досъёмов (без геометрии)

```
GET /api/qgis/recaps/list/?user=<логин>
```

Те же параметры, что у слоя досъёмов (`user` обязателен; `request_id`, `recap_id` —
опциональные фильтры, комбинируются по И).

### Ответ (200)

```json
{
  "ok": true,
  "current_user": "asidorov",
  "count": 1,
  "recaps": [
    {
      "recap_id": "77",
      "request_id": "141564",
      "name": "Досъём по заявке 141564",
      "owner_legal_person_id": "9000022",
      "owner_legal_person_name": "ООО Пример"
    }
  ]
}
```

Записи упорядочены по `recap_id` по возрастанию. Поля идентичны `properties`
фич слоя досъёмов.

---

## Коды HTTP

| Код | Когда | Тело |
|-----|-------|------|
| 200 | успех | FeatureCollection (см. выше) |
| 400 | нет `user`; `request_id`/`recap_id` не цифры; неизвестный `source` | `{"ok": false, "error": "…"}` |
| 403 | Host не в allowlist; логин не MGGT/SUP | `{"ok": false, "error": "…"}` |
| 500 | ошибка БД / неожиданное исключение | `{"ok": false, "error": "Не удалось получить слой/список заявок или досъёмов."}` |

---

## Использование в QGIS

Слой добавляется как «Vector Layer → Protocol: HTTP» (GeoJSON) с URL вида:

```text
https://border-ogh.mggt.ru/api/qgis/requests/?user=asidorov
https://border-ogh.mggt.ru/api/qgis/requests/?user=asidorov&source=ДТ
https://border-ogh.mggt.ru/api/qgis/recaps/?user=asidorov&request_id=141564
```

- EPSG слоя — **4326** (WGS84), QGIS перепроецирует автоматически.
- В `properties` достаточно полей для подписей и фильтров слоя
  (`request_id`, `source`, `name`, `owner_legal_person_name`, …).
- Слои статичны на момент загрузки — обновление = перезагрузка слоя (F5 в слое).
- Для срезов по районам/владельцам фильтруйте в QGIS по properties или запрашивайте
  с `request_id` / `source`.
- Для реестров и диалогов выбора (без загрузки геометрии) используйте списки
  `requests/list/`, `recaps/list/` — обычный HTTP GET, ответ JSON.

---

## Примеры вызова

### curl

```bash
# все отрисованные заявки
curl 'https://border-ogh.mggt.ru/api/qgis/requests/?user=asidorov'

# заявки одного источника и одной заявки
curl 'https://border-ogh.mggt.ru/api/qgis/requests/?user=asidorov&source=ДТ&request_id=141564'

# досъёмы по заявке
curl 'https://border-ogh.mggt.ru/api/qgis/recaps/?user=asidorov&request_id=141564'

# списки без геометрии
curl 'https://border-ogh.mggt.ru/api/qgis/requests/list/?user=asidorov'
curl 'https://border-ogh.mggt.ru/api/qgis/recaps/list/?user=asidorov&request_id=141564'
```

### Python

```python
import requests

BASE = "https://border-ogh.mggt.ru/api/qgis"
USER = "asidorov"

layer = requests.get(f"{BASE}/requests/", params={"user": USER}, timeout=30).json()
assert layer["ok"]
for feature in layer["features"]:
    props = feature["properties"]
    print(props["source"], props["request_id"], props["name"])

recaps = requests.get(
    f"{BASE}/recaps/",
    params={"user": USER, "request_id": "141564"},
    timeout=30,
).json()

# реестр всех заявок без геометрии
registry = requests.get(f"{BASE}/requests/list/", params={"user": USER}, timeout=30).json()
assert registry["ok"]
for item in registry["requests"]:
    print(item["source"], item["request_id"], item["name"])
```

---

## Реализация в кодовой базе

| Компонент | Путь |
|-----------|------|
| QGIS views | `pass_viewer/qgis_api_views.py` |
| SQL-билдеры слоёв и списков | `pass_viewer/qgis_layers.py` |
| Host check (общий) | `approval/qgis_access.py` |
| Роли | `pass_viewer/roles.py` (`resolve_user_scope`, `sees_all_approvals`) |
| URL | `pass_viewer/urls.py` → `api/qgis/requests/`, `api/qgis/recaps/` + `list/` |
| Тесты | `tests/test_qgis_layers_api.py` |
| Настройки | `pass_map/settings.py` → `APPROVAL_QGIS_ALLOWED_HOSTS` (общий allowlist) |

---

## Локальная разработка

```bash
cd GeoDjango
python manage.py runserver
curl 'http://127.0.0.1:8000/api/qgis/requests/?user=<логин MGGT/SUP из users>'
curl 'http://127.0.0.1:8000/api/qgis/recaps/?user=<логин MGGT/SUP из users>'
curl 'http://127.0.0.1:8000/api/qgis/requests/list/?user=<логин MGGT/SUP из users>'
curl 'http://127.0.0.1:8000/api/qgis/recaps/list/?user=<логин MGGT/SUP из users>'
```

---

## Ограничения и планы

- Только чтение: создание/правка/удаление заявок и досъёмов — в веб-приложении
  (`add-object/save/`, `add-recap/save/`).
- Нет bbox-фильтрации и пагинации: слой отдаётся целиком. При росте объёма данных
  добавить `bbox` (ST_Intersects с envelope) — координировать с командой GeoDjango.
- Обновление кэша слоёв — на стороне QGIS (перезагрузка слоя).
