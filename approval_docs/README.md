# Документация модуля «Согласование»

| Документ | Описание |
|----------|----------|
| [PROD_DEPLOY.md](PROD_DEPLOY.md) | **Первый деплой на прод** (MGGT, сейчас 172.21.197.77, цель 192.168.1.40): чеклист, `.env`, миграции, smoke-тесты |
| [DATA_MODEL.md](DATA_MODEL.md) | Схема `approval`: таблицы, поля, связи, primary vs event, геометрия чата |
| [QGIS_API.md](QGIS_API.md) | HTTP API для QGIS: upsert, чтение чатов/геометрии, сообщения, approve/revoke |
| [QGIS_LAYERS_API.md](QGIS_LAYERS_API.md) | HTTP API для QGIS: read-only слои отрисованных заявок и досъёмов (`/api/qgis/…`) |
| [QGIS_INTEGRATION.md](QGIS_INTEGRATION.md) | Полная инструкция для QGIS-модуля: API, прямая запись в `geodb`, подключения к БД |
