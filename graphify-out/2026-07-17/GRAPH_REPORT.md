# Graph Report - GeoDjango  (2026-07-17)

## Corpus Check
- 180 files · ~1,031,232 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2712 nodes · 5651 edges · 190 communities (135 shown, 55 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 97 edges (avg confidence: 0.59)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `68e52247`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- main.js
- home.js
- add_object.js
- add-object.js
- add_recap.js
- add-recap.js
- split_object.js
- home.js
- json_loaders.py
- views.py
- geojson_dynamic.py
- test_adjacent_relations.py
- _quote_ident
- test_owned_recaps.py
- main.js
- _get_map_layers
- hood_scope.py
- test_dgi_layers.py
- clearMapDisplayedUserDrawings
- checkRelations
- pdf-export.js
- dgi_xlsx_sync.py
- urls.py
- finishDossierPolygon
- checkRelations
- runSaveAndExportFlow
- renderRelationLayers
- home
- build_page_js.py
- _create_new_object
- basemap.js
- applyOwnedFilters
- Руководство пользователя сервисом отрисовки границ ОГХ
- Деплой Passport Editor (MGGT / Docker)
- clearDrawSnapPreview
- geometry-multipolygon-save.js
- clearDrawSnapPreview
- runSaveAndExportFlow
- views.py
- CI на корпоративном GitLab (hub.mos.ru)
- renderRelationLayers
- BaseCommand
- page_config.py
- updateDossierToolbarState
- refreshObjectLayersControl
- map-controller.js
- models.py
- bindCommentPointLayer
- buildNewGeometryBeyondSelected
- _load_rows_from_xlsx
- cleanup_orphan_comment_points.py
- attachPromptSnapHandlers
- attachPromptSnapHandlers
- runSaveAndExportFlow
- attachPromptSnapHandlers
- Passport Editor (GeoDjango)
- test_smoke.py
- 3. Главная страница
- 0013_externaluser_hood_scope.py
- renderRelationLayers
- getMergeCheckboxPayload
- buildNewGeometryBeyondSelected
- user_guide.py
- sync_geodb_from_prod.sh
- cleanup_orphan_gis_rows.py
- refreshAutoRemoveModalOptions
- refreshAutoRemoveModalOptions
- applyHomeWorkflowOdsSyncNotifications
- renderRelationLayers
- ci_resolve_gdal_paths.sh
- conftest.py
- test_add_recap_js_smoke.py
- HTTP API: приём согласований из QGIS
- clearDrawSnapPreview
- renderOwnedRecapsList
- Быстрый старт
- AppConfig
- landing.js
- forms.py
- Обычное обновление (только код, БД не трогаем)
- Git на MGGT и токен развёртывания (hub.mos.ru)
- _remove_intersections_from_geometry
- dgi-export-gate.js
- refreshAutoRemoveModalOptions
- geometry-ops.js
- page_config.py
- conftest.py
- test_approval_smoke.py
- firewalld (RED OS / MGGT)
- closeEntryRequestModal
- cancelCommentPointMode
- test_auth_smoke.py
- test_geometry_multipolygon_export.py
- test_home_js_smoke.py
- 4. Карта редактирования объекта
- main
- settings.py
- 0009_deploy_seed_import_tooling.py
- clearHomeOghSpecialModes
- test_build_page_js.py
- test_main_js_smoke.py
- 0001_create_approval_schema.py
- asgi.py
- wsgi.py
- 0001_create_users_table.py
- 0002_create_recaps_table.py
- 0003_create_id_names_table.py
- 0004_create_ozn_table.py
- 0005_add_missing_reference_columns.py
- 0006_add_ownerlegalpersonalid_to_ozn.py
- 0007_create_renew_table.py
- 0008_add_request_id_to_ozn.py
- 0010_add_spatial_and_request_indexes.py
- 0011_add_geojson_date_columns.py
- 0012_create_hood_table.py
- 0014_create_ods_request_table.py
- 0015_add_ods_request_short_object_root_id.py
- 0016_add_created_at_to_gis_tables.py
- 0018_create_top_table.py
- 0019_add_dgi_short_sobstv_rr.py
- 0020_create_auto_remove_square_table.py
- 0021_auto_remove_square_precision.py
- 0022_auto_remove_square_use_square_meters.py
- 0023_auto_remove_square_add_type.py
- 0024_add_dgi_aprove.py
- 0025_add_oozt_rzd_spatial_indexes.py
- clearPassportConfirmState
- closeEntryRecapModal
- playwright.config.py
- ci_install_deps.sh
- cleanup_media_exports_daily.sh
- cleanup_orphan_comment_points_daily.sh
- cleanup_orphan_gis_daily.sh
- local_postgis_up.sh
- sync_ods_request_daily.sh
- __init__.py
- work_layers.py
- test_approval_events.py
- test_ods_recap.py
- event_draw.js
- 0002_cases_approved_chat_files.py
- 0003_approves_neighbour_guid.py
- 6.1. geodb — запись согласования (схема `approval`)
- cleanup_orphan_gis_rows.py
- Command
- 4. Пошаговая процедура (SQL, альтернатива HTTP API)
- clearPopupHighlight
- Запрос
- ExternalUser
- 0009_case_participant_logins.py
- 0005_cases_roots_message_geometry.py
- 0006_inspector_and_case_roots.py
- runSaveAndExportFlow
- forms.py
- work_layer_label
- tickAdjacentHighlightPulse
- lookupSvgHotspot
- 6. Подключение к БД (сервер МГГТ)
- svgIconUrl
- _layer_stack_sort_key
- refreshAutoRemoveModalOptions
- cancelCommentPointMode
- geometryLayerKey
- cleanup_orphan_gis_rows.py
- Command
- Command
- 3. Главная страница

## God Nodes (most connected - your core abstractions)
1. `_quote_ident()` - 40 edges
2. `Case` - 39 edges
3. `Approve` - 32 edges
4. `landing()` - 31 edges
5. `el()` - 27 edges
6. `_get_map_layers()` - 27 edges
7. `_valid_payload()` - 26 edges
8. `_resolve_column_name()` - 25 edges
9. `_post_qgis_approve()` - 25 edges
10. `_normalize_source_label()` - 24 edges

## Surprising Connections (you probably didn't know these)
- `test_get_owner_id_for_username()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  tests/test_approval_map_data.py → approval/access.py
- `test_get_accessible_approves_for_inspector_without_owner_id()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  tests/test_approval_access.py → approval/access.py
- `test_get_accessible_approves_filters_by_owner()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  tests/test_approval_map_data.py → approval/access.py
- `test_adjacent_select_sql_accepts_work_schema()` --calls--> `_adjacent_select_sql()`  [EXTRACTED]
  tests/test_approval_adjacent_map.py → approval/work_adjacent.py
- `test_adjacent_select_sql_uses_master_schema_by_default()` --calls--> `_adjacent_select_sql()`  [EXTRACTED]
  tests/test_approval_adjacent_map.py → approval/work_adjacent.py

## Import Cycles
- None detected.

## Communities (190 total, 55 thin omitted)

### Community 0 - "main.js"
Cohesion: 0.02
Nodes (101): addCommentPointButton, addPolygonButton, adjacentDtPassportsGroup, applyPopupHighlight(), autoRemoveDgiMoscowCheckbox, autoRemoveDgiPrivateCheckbox, autoRemoveDtCheckbox, autoRemoveIntersectionsButton (+93 more)

### Community 1 - "home.js"
Cohesion: 0.02
Nodes (89): addObjectEntryBtn, approvalNotificationsBtn, approvalNotificationsPanel, approvalSelectEl, approvalSelectWrapEl, confirmPendingForm, confirmPendingHidden, entryGeometryDetailFieldset (+81 more)

### Community 2 - "add_object.js"
Cohesion: 0.02
Nodes (90): addCommentPointButton, addPolygonButton, autoRemoveDgiMoscowCheckbox, autoRemoveDgiPrivateCheckbox, autoRemoveDtCheckbox, autoRemoveIntersectionsButton, autoRemoveModal, autoRemoveModalCancel (+82 more)

### Community 3 - "add-object.js"
Cohesion: 0.05
Nodes (88): addSignalTapeLayer(), applyCutGeometry(), applyGeometryToEditableGroup(), applyPopupHighlight(), applySnappedVertex(), attachPromptSnapHandlers(), autoRemoveIntersections(), bindCommentPointLayer() (+80 more)

### Community 4 - "add_recap.js"
Cohesion: 0.03
Nodes (77): addCommentPointButton, addDossierButton, adjacentDtPassportsGroup, applyPopupHighlight(), autoRemoveDgiMoscowCheckbox, autoRemoveDgiPrivateCheckbox, autoRemoveDtCheckbox, autoRemoveIntersectionsButton (+69 more)

### Community 5 - "add-recap.js"
Cohesion: 0.07
Nodes (63): addSignalTapeLayer(), applyGeometryToDossierGroup(), applyPopupHighlight(), autoRemoveIntersections(), bindCommentPointLayer(), bindDossierPolygonPopup(), buildCommentPointPopupHtml(), buildCurrentGeometry() (+55 more)

### Community 6 - "split_object.js"
Cohesion: 0.07
Nodes (59): applyCutGeometry(), applyGeometryToEditableGroup(), applySelectionPolygonFromDrawLayer(), basemapControl, bindPartPopup(), buildCurrentGeometry(), buildMergedGeometryFromEditableLayers(), cancelButton (+51 more)

### Community 7 - "home.js"
Cohesion: 0.06
Nodes (51): applyHomeWorkflowOdsSyncNotifications(), applyOwnedFilters(), buildOdsSyncChangeMessages(), buildOwnedMapKey(), clearHomeOghSpecialModes(), clearPassportConfirmState(), closeEntryRecapModal(), closeEntryRequestModal() (+43 more)

### Community 8 - "json_loaders.py"
Cohesion: 0.19
Nodes (15): Helpers for loading seed / reference data from JSON and GeoJSON files.  Expected, build_default_registry(), _comment_points_table(), expected_file_names(), expected_filename(), expected_files_doc(), iter_known_tables(), Registry of database tables that can be populated from flat files during deploy. (+7 more)

### Community 9 - "views.py"
Cohesion: 0.08
Nodes (43): finalize_dgi_aprove_record(), Apply server-side username and timestamp defaults before DB write., geometry_intersects_allowed_hood(), geometry_norm: GeoJSON geometry dict (not Feature/FC)., _build_merge_allowed_sets(), cancel_pending_entry(), _check_recap_uniqueness(), _comment_points_table_name() (+35 more)

### Community 10 - "geojson_dynamic.py"
Cohesion: 0.19
Nodes (13): buildCurrentGeometryFromSelected(), buildExportGeometry(), clearPendingRepairedGeometry(), clearSaveModalMessages(), closeSaveModal(), exportObjectFiles(), getEditableGeometryForSave(), hideSaveModalFixUi() (+5 more)

### Community 11 - "test_adjacent_relations.py"
Cohesion: 0.07
Nodes (44): _adjacent_layers_for_json_response(), _build_map_adjacent_dt_combined_sql(), _build_map_request_layer_branch(), _build_map_requests_sql(), _build_map_requests_sql_for_source(), _build_new_object_request_layer_branch(), _build_new_object_request_objects_sql(), _defer_map_context_layers() (+36 more)

### Community 12 - "_quote_ident"
Cohesion: 0.12
Nodes (46): get_hood_cte_prefix_sql(), get_hood_intersects_ha_sql(), get_hood_intersects_sql_suffix(), Returns (sql_suffix, [params]) to AND into a WHERE clause, e.g.       AND ST_Int, Leading ``WITH ha AS (...), `` fragment (comma included) and its params., ``AND ST_Intersects((SELECT g FROM ha), ...)`` when scope active/empty; empty st, _adjacent_nearby_meters(), _append_merge_table_select_parts() (+38 more)

### Community 13 - "test_owned_recaps.py"
Cohesion: 0.24
Nodes (6): AppConfig, delete_approve(), ApprovalConfig, delete_approve_for_inspector(), Approve, PassViewerConfig

### Community 14 - "main.js"
Cohesion: 0.11
Nodes (21): applyPopupHighlight(), bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), clearPopupHighlight(), closeCommentPointModal(), deleteCommentPointById(), detachPromptSnapHandlers() (+13 more)

### Community 15 - "_get_map_layers"
Cohesion: 0.12
Nodes (16): Media и вложения, Архитектура на проде, Бизнес-логика (важно для приёмки), Настройка QGIS-модуля, Откат, Первый деплой модуля «Согласование» на прод (MGGT), После первого деплоя, Предварительные условия (+8 more)

### Community 16 - "hood_scope.py"
Cohesion: 0.15
Nodes (24): bind_hood_scope(), clear_hood_scope(), get_hood_allowed_districts_geojson(), get_hood_cte_prefix_and_intersects_clause(), _hood_min_overlap_ratio(), _hood_owner_geom_union_sql_and_params(), _hood_owner_union_cte_sql(), _hood_spatial_scope_active() (+16 more)

### Community 17 - "test_dgi_layers.py"
Cohesion: 0.13
Nodes (20): build_dgi_ownership_extra_sql(), classify_dgi_ownership(), normalize_dgi_aprove_payload(), DGI sub-layer classification by short_sobstv_rr (moscow vs private ownership)., SQL fragment starting with `` AND `` for table alias column expression, e.g. ``t, Parse client ``dgi_aprove`` for jsonb storage after >10% private overlap consent, Return ``moscow`` or ``private`` for a raw short_sobstv_rr value (client/tests)., _sql_ilike_contains_fragment() (+12 more)

### Community 18 - "clearMapDisplayedUserDrawings"
Cohesion: 0.15
Nodes (25): applyCutGeometry(), applyGeometryToEditableGroup(), bindEditablePolygonPopup(), buildEditableDeletePopupHtml(), cancelAddObjectMode(), cancelCutMode(), captureMapCanvasForPdf(), checkRelations() (+17 more)

### Community 19 - "checkRelations"
Cohesion: 0.13
Nodes (24): applyCutGeometry(), applyGeometryToEditableGroup(), autoRemoveIntersections(), buildCurrentGeometry(), buildCurrentGeometryFromSelected(), buildExportGeometry(), checkDgiIntersections(), checkRelations() (+16 more)

### Community 20 - "pdf-export.js"
Cohesion: 0.15
Nodes (20): addMapLandscapePage(), addPortraitContentPages(), buildAndSavePdf(), buildIntersectionBlockElement(), buildObjectInfoElement(), buildObjectInfoFromContext(), captureLeafletMapPngCanvas(), collectBoundsFromGeoJson() (+12 more)

### Community 21 - "dgi_xlsx_sync.py"
Cohesion: 0.11
Nodes (27): _as_text(), DgiXlsxSyncStats, _fetch_table_meta(), _flush_batches(), _insert_batch_rows(), _insert_sql(), _load_rows_from_xlsx(), _normalize_header() (+19 more)

### Community 22 - "urls.py"
Cohesion: 0.10
Nodes (46): _append_auto_remove_mask_parts(), _append_intersection_mask_union_part(), auto_remove_intersections(), _auto_remove_mask_context(), _auto_remove_source_tokens(), _auto_remove_square_table_name(), _build_where_clause(), check_dgi_intersections() (+38 more)

### Community 23 - "finishDossierPolygon"
Cohesion: 0.21
Nodes (13): clearDrawSnapPreview(), clearPendingRepairedGeometry(), clearStartVertexFlag(), closeDeletePolygonModal(), collectSnapGuideLines(), deletePendingPolygon(), finishDossierPolygon(), getFirstVertexFromDrawer() (+5 more)

### Community 24 - "checkRelations"
Cohesion: 0.15
Nodes (20): applyCutGeometry(), applyGeometryToEditableGroup(), autoRemoveIntersections(), buildCurrentGeometry(), checkDgiIntersections(), checkRelations(), closeAutoRemoveModal(), closeDeletePolygonModal() (+12 more)

### Community 25 - "runSaveAndExportFlow"
Cohesion: 0.14
Nodes (19): autoRemoveIntersections(), buildCurrentGeometry(), buildExportGeometry(), checkDgiIntersections(), clearPendingRepairedGeometry(), clearSaveModalMessages(), closeAutoRemoveModal(), closeSaveModal() (+11 more)

### Community 26 - "renderRelationLayers"
Cohesion: 0.13
Nodes (19): addSignalTapeLayer(), bindCommentPointLayer(), bindPdfExportLink(), buildCommentPointPopupHtml(), captureMapCanvasForPdf(), closeCommentPointModal(), deleteCommentPointById(), formatDgiShortSobstvRr() (+11 more)

### Community 27 - "home"
Cohesion: 0.43
Nodes (4): Command, _detect_source_srid(), _pick_prop(), _text_or_none()

### Community 28 - "build_page_js.py"
Cohesion: 0.24
Nodes (14): apply_forward_replacements(), apply_reverse_replacements(), build_all_pages(), build_page(), build_page_content(), check_all_pages(), main(), Path (+6 more)

### Community 29 - "_create_new_object"
Cohesion: 0.13
Nodes (25): get_accessible_cases_queryset(), is_inspector_for_approve(), _normalized_participant_logins(), Access control for approval workflows., user_can_access_case(), aggregate_approve_owners(), resolve_event_case_owners(), validate_case_owners() (+17 more)

### Community 30 - "basemap.js"
Cohesion: 0.25
Nodes (12): applyPopupHighlight(), bindButtonListeners(), buildBasemapButtonsHtml(), buttonScope(), clearPopupHighlight(), findControlContainer(), getCachedMggtAvailability(), probeMggtAvailability() (+4 more)

### Community 31 - "applyOwnedFilters"
Cohesion: 0.18
Nodes (17): applyOwnedFilters(), buildOwnedMapKey(), getActiveOwnedListTab(), getOwnedItemTabName(), getSelectedRequestStatusSet(), getSelectedSourceSet(), initOwnedMap(), initRequestStatusFilter() (+9 more)

### Community 32 - "Руководство пользователя сервисом отрисовки границ ОГХ"
Cohesion: 0.11
Nodes (18): 10. Ограничения по районам, 11. Ручной поиск объекта, 12. Рекомендации по работе, 13. Типичные сообщения, 14. Словарь терминов, 15. Поддержка, 1. Назначение системы, 2. Вход в систему (+10 more)

### Community 33 - "Деплой Passport Editor (MGGT / Docker)"
Cohesion: 0.07
Nodes (27): 1. Локально (из репозитория GeoDjango), 2. На сервере (обновление кода), 3. Проверка, 4. Вернуться к разработке, firewalld (RED OS / MGGT), Git на MGGT и токен развёртывания (hub.mos.ru), RED OS: Docker Hub недоступен, Безопасность (+19 more)

### Community 34 - "clearDrawSnapPreview"
Cohesion: 0.21
Nodes (13): bindEditablePolygonPopup(), buildEditableDeletePopupHtml(), cancelAddObjectMode(), cancelCutMode(), clearDrawSnapPreview(), clearStartVertexFlag(), finishCreatedPolygon(), getFirstVertexFromDrawer() (+5 more)

### Community 35 - "geometry-multipolygon-save.js"
Cohesion: 0.23
Nodes (8): buildGeometryForExport(), closeRingCoordinates(), countDistinctRingVertices(), layerLatLngsToPolygonCoordinates(), mergePolygonGeometriesForExport(), readGeometriesFromLeafletGroup(), requiresMultipolygonSave(), validateMultipolygonTargetGeometry()

### Community 36 - "clearDrawSnapPreview"
Cohesion: 0.21
Nodes (13): bindEditablePolygonPopup(), buildEditableDeletePopupHtml(), cancelAddObjectMode(), cancelCutMode(), clearDrawSnapPreview(), clearStartVertexFlag(), finishCreatedPolygon(), getFirstVertexFromDrawer() (+5 more)

### Community 37 - "runSaveAndExportFlow"
Cohesion: 0.24
Nodes (15): import_id_names(), import_ods_request(), import_users(), _load_json_array(), _load_ods_request_rows(), _ods_row_tuple(), _ods_ts(), _pick() (+7 more)

### Community 38 - "views.py"
Cohesion: 0.07
Nodes (37): BaseBackend, DockerUsersTableBackend, Create or update the E2E test user in the users table (idempotent)., ExternalUser, Meta, Tests for progressive approval map-layer API., _post_qgis_approve(), _qgis_get() (+29 more)

### Community 39 - "CI на корпоративном GitLab (hub.mos.ru)"
Cohesion: 0.25
Nodes (8): CI на корпоративном GitLab (hub.mos.ru), MosHub / старый GitLab, Если Docker Hub заблокирован, Отличия от GitHub, Первый запуск, Синхронизация с GitHub, Типичные проблемы, Что нужно на стороне GitLab

### Community 40 - "renderRelationLayers"
Cohesion: 0.20
Nodes (12): addSignalTapeLayer(), bindPdfExportLink(), clearRelationLayers(), fetchPdfExportData(), filterOutSelectedRootid(), formatDgiShortSobstvRr(), renderRecapsLayer(), renderReferenceSignalLayers() (+4 more)

### Community 41 - "BaseCommand"
Cohesion: 0.05
Nodes (90): Command, build_manifest(), build_svg_index(), _collect_svg_references(), collect_table_names(), copy_referenced_svgs(), default_swatch_style(), _extract_svg_field() (+82 more)

### Community 42 - "page_config.py"
Cohesion: 0.14
Nodes (32): serialize_approve_option(), _event_case(), _login(), _message_with_attachment(), _primary_case(), Tests for approval events, chats, and unanimous approval., test_bootstrap_returns_primary_case(), test_closed_case_rejects_new_message() (+24 more)

### Community 43 - "updateDossierToolbarState"
Cohesion: 0.14
Nodes (20): applyGeometryToDossierGroup(), autoRemoveIntersections(), bindDossierPolygonPopup(), buildCurrentGeometry(), buildEditableDeletePopupHtml(), buildExportGeometry(), checkDgiIntersections(), checkRelations() (+12 more)

### Community 44 - "refreshObjectLayersControl"
Cohesion: 0.20
Nodes (11): bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), closeCommentPointModal(), deleteCommentPointById(), ensureCommentPickCapture(), loadCommentPointsForMap(), openCommentPointModal() (+3 more)

### Community 45 - "map-controller.js"
Cohesion: 0.42
Nodes (10): cancelCutMode(), cancelSelectionPolygonMode(), clearSplitDrawFinishFlag(), getFirstVertexFromPolygonDrawer(), getLastVertexFromPolylineDrawer(), refreshToolbar(), setEditMode(), startCutMode() (+2 more)

### Community 46 - "models.py"
Cohesion: 0.24
Nodes (19): add_case_participant(), _approvals_progress(), _case_is_fully_approved(), _case_participants(), _case_preview(), _case_status_class(), change_case_owner(), _inspector_approved() (+11 more)

### Community 47 - "bindCommentPointLayer"
Cohesion: 0.20
Nodes (10): bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), closeCommentPointModal(), deleteCommentPointById(), ensureCommentPickCapture(), loadCommentPointsForMap(), openCommentPointModal() (+2 more)

### Community 48 - "buildNewGeometryBeyondSelected"
Cohesion: 0.22
Nodes (10): bindPdfExportLink(), buildNewGeometryBeyondSelected(), captureMapCanvasForPdf(), countPolygonLikeGeometriesInCollection(), extractPolygonGeometriesFromCollection(), fetchPdfExportData(), hasNewPolygonBeyondSelected(), runPdfExportDownload() (+2 more)

### Community 50 - "cleanup_orphan_comment_points.py"
Cohesion: 0.33
Nodes (6): _build_orphan_where(), _column_exists(), Command, _not_exists_ref_clause(), Delete pass_comment_points rows whose request_id is not in pass_objects / odh /, _table_exists()

### Community 51 - "attachPromptSnapHandlers"
Cohesion: 0.28
Nodes (9): applySnappedVertex(), attachPromptSnapHandlers(), findNearestCandidate(), findNearestSnapTarget(), nearestPointOnSegment(), setSnapCircleVisualState(), snapLastDrawVertexIfNeeded(), startSnapBindingLoop() (+1 more)

### Community 52 - "attachPromptSnapHandlers"
Cohesion: 0.28
Nodes (9): applySnappedVertex(), attachPromptSnapHandlers(), findNearestCandidate(), findNearestSnapTarget(), nearestPointOnSegment(), setSnapCircleVisualState(), snapLastDrawVertexIfNeeded(), startSnapBindingLoop() (+1 more)

### Community 53 - "runSaveAndExportFlow"
Cohesion: 0.25
Nodes (9): clearPendingRepairedGeometry(), clearSaveModalMessages(), closeSaveModal(), exportObjectFiles(), hideSaveModalFixUi(), openSaveModal(), runSaveAndExportFlow(), saveObjectToDb() (+1 more)

### Community 54 - "attachPromptSnapHandlers"
Cohesion: 0.28
Nodes (9): applySnappedVertex(), attachPromptSnapHandlers(), findNearestCandidate(), findNearestSnapTarget(), nearestPointOnSegment(), setSnapCircleVisualState(), snapLastDrawVertexIfNeeded(), startSnapBindingLoop() (+1 more)

### Community 55 - "Passport Editor (GeoDjango)"
Cohesion: 0.13
Nodes (15): CI, Page JS (`home.js`, `main.js`, …), Passport Editor (GeoDjango), pre-commit, QGIS-витрина (alias `qgis`), Быстрый старт, Локальная geodb (Docker), Опционально: прод geodb через SSH (+7 more)

### Community 56 - "test_smoke.py"
Cohesion: 0.25
Nodes (4): _dismiss_home_workflow_modal_if_open(), Browser smoke tests (Playwright)., home.js opens #home-workflow-modal after scripts run; close it to unblock clicks, test_user_guide_modal_opens()

### Community 57 - "3. Главная страница"
Cohesion: 0.20
Nodes (20): load_manifest(), build_schema_feature_collection(), build_topopassport_feature_collection(), _feature_select_sql(), _max_features(), Load approval map features from mggt_asu.work / topopassport schemas., Return actual column name matching preferred_name case-insensitively, or None., _resolve_column_name() (+12 more)

### Community 58 - "0013_externaluser_hood_scope.py"
Cohesion: 0.39
Nodes (7): forward_hood_scope_sql(), _hood_scope_backfill(), Migration, _quote_ident(), Return (id_field, name_field) using the same discovery rules as views._get_id_na, _resolve_id_names_columns(), reverse_hood_scope_sql()

### Community 59 - "renderRelationLayers"
Cohesion: 0.29
Nodes (8): addSignalTapeLayer(), filterByRequestedName(), filterOutSelectedRootid(), formatDgiShortSobstvRr(), renderRecapsLayer(), renderRelationLayers(), renderRenewLayer(), renderTopLayer()

### Community 60 - "getMergeCheckboxPayload"
Cohesion: 0.32
Nodes (8): closeMergeRequestModal(), getMergeCheckboxPayload(), getMergeGeometryDetailMode(), normalizeMergeSourceLabel(), openMergeRequestModalWithSources(), resetMergeTargetOptionRows(), submitMergePassportsContinue(), submitMergeRequestModal()

### Community 61 - "buildNewGeometryBeyondSelected"
Cohesion: 0.29
Nodes (8): buildNewGeometryBeyondSelected(), countPolygonLikeGeometriesInCollection(), extractPolygonGeometriesFromCollection(), fetchPdfExportData(), filterOutSelectedRootid(), hasNewPolygonBeyondSelected(), toGeometryFromPolygonList(), toIntersectionGeometry()

### Community 62 - "user_guide.py"
Cohesion: 0.36
Nodes (7): _add_heading_ids(), _enhance_images(), load_user_guide_html(), Render USER_GUIDE.md as HTML for the home page modal., Match USER_GUIDE anchor style, e.g. ``8. Объединение паспортов`` → ``8-объединен, _rewrite_image_paths(), _slugify_heading()

### Community 63 - "sync_geodb_from_prod.sh"
Cohesion: 0.46
Nodes (7): print_local_counts(), print_prod_counts(), recreate_local_geodb(), reset_local_postgres_password(), restore_sql_stream(), sync_geodb_from_prod.sh script, usage()

### Community 66 - "refreshAutoRemoveModalOptions"
Cohesion: 0.29
Nodes (7): countGroupFeatures(), isAutoRemoveSourceDisplayed(), openAutoRemoveModal(), refreshAutoRemoveModalOptions(), refreshLayerPanelCounts(), resetAutoRemoveCheckboxes(), syncLayerPanelCheckboxes()

### Community 67 - "refreshAutoRemoveModalOptions"
Cohesion: 0.29
Nodes (7): countGroupFeatures(), isAutoRemoveSourceDisplayed(), openAutoRemoveModal(), refreshAutoRemoveModalOptions(), refreshLayerPanelCounts(), resetAutoRemoveCheckboxes(), syncLayerPanelCheckboxes()

### Community 68 - "applyHomeWorkflowOdsSyncNotifications"
Cohesion: 0.33
Nodes (7): applyHomeWorkflowOdsSyncNotifications(), buildOdsSyncChangeMessages(), collectCurrentOdsSyncStatuses(), getHomeOdsSyncStorageKey(), readOdsSyncSnapshot(), renderHomeWorkflowOdsSyncChanges(), writeOdsSyncSnapshot()

### Community 69 - "renderRelationLayers"
Cohesion: 0.38
Nodes (7): addSignalTapeLayer(), formatDgiShortSobstvRr(), renderRecapsLayer(), renderReferenceSignalLayers(), renderRelationLayers(), renderRenewLayer(), renderTopLayer()

### Community 70 - "ci_resolve_gdal_paths.sh"
Cohesion: 0.29
Nodes (3): GDAL_LIBRARY_PATH, GEOS_LIBRARY_PATH, ci_resolve_gdal_paths.sh script

### Community 71 - "conftest.py"
Cohesion: 0.25
Nodes (3): django_db_use_migrations(), Shared pytest fixtures., Smoke tests only need ORM tables (users); GIS tables come from seed/import.

### Community 74 - "HTTP API: приём согласований из QGIS"
Cohesion: 0.07
Nodes (30): 1. Upsert согласования (ingest), 2. Список согласований, 3. Деталь согласования, 4. Геометрии (слой для карты QGIS), 5. Деталь события / чат, 6. Отправка сообщения, 7. Согласовать / отозвать, Host allowlist (+22 more)

### Community 75 - "clearDrawSnapPreview"
Cohesion: 0.50
Nodes (4): findNearestCandidate(), findNearestSnapTarget(), nearestPointOnSegment(), snapLastDrawVertexIfNeeded()

### Community 76 - "renderOwnedRecapsList"
Cohesion: 0.47
Nodes (6): deleteOwnedRecap(), downloadOwnedRecap(), openOwnedRecapsModal(), ownedRecapsEscapeHtml(), renderOwnedRecapsList(), updateOwnedRecapsBadge()

### Community 77 - "Быстрый старт"
Cohesion: 0.42
Nodes (8): check_duplicate_primary_cases(), print_local_counts(), print_prod_counts(), prod_pg_dump(), restore_sql_stream(), sync_approval_from_prod.sh script, truncate_local_approval(), usage()

### Community 78 - "AppConfig"
Cohesion: 0.11
Nodes (34): ApproveAlreadyApprovedError, ApproveUserConflictError, attach_geometry_to_message(), attachment_allowed_extensions(), attachment_max_bytes(), build_geometries_feature_collection(), create_case_with_geometry(), create_event_from_adjacent() (+26 more)

### Community 79 - "landing.js"
Cohesion: 0.10
Nodes (25): addGeometryLayer(), adjacentBaseStyle(), adjacentFeatureKey(), applyStyleToGeometryLayer(), attachSignalTapeHatching(), bindReferenceLayerPopup(), clearEventGeometries(), clearPendingMessageGeometry() (+17 more)

### Community 80 - "forms.py"
Cohesion: 0.13
Nodes (34): get_accessible_approve(), get_accessible_approves(), get_owner_id_for_username(), api_bootstrap(), _format_dt(), get_cases_queryset(), Short approve payload for QGIS list/detail headers., serialize_approve_qgis_summary() (+26 more)

### Community 81 - "Обычное обновление (только код, БД не трогаем)"
Cohesion: 0.10
Nodes (20): 10. Проверка после отправки, 11. Миграции схемы, 12. Контакты по доработкам, 1. Что передаёт QGIS-модуль, 2. UUID и идентификаторы: что генерировать, что не трогать, 3. Схема данных и связи, 4. Пошаговая процедура (SQL, альтернатива HTTP API), 5. Полный пример транзакции (+12 more)

### Community 82 - "Git на MGGT и токен развёртывания (hub.mos.ru)"
Cohesion: 0.19
Nodes (15): _column_exists(), _is_bottom_polygon_key(), _layer_panel_sort_key(), _layer_stack_sort_key(), list_work_layer_tables(), _owner_lookup_table_order(), Registry of mggt_asu.work / topopassport tables usable as approval map layers., Return OwnerLegalPersonId for a work-layer object with the given TaskGUID. (+7 more)

### Community 83 - "_remove_intersections_from_geometry"
Cohesion: 0.40
Nodes (5): 5.1. Статика и маршрут, 5.2. QGIS API (с сервера или машины в сети МГГТ), 5.3. Веб-интерфейс, 5.4. SQL-контроль, Шаг 5. Smoke-тесты после деплоя

### Community 85 - "refreshAutoRemoveModalOptions"
Cohesion: 0.10
Nodes (34): build_map_layer_load_order(), Ordered specs for sequential client-side loading., landing_page_config(), Page bootstrap config for approval templates (json_script)., build_layer_groups(), build_reference_layer_groups(), build_topopassport_layer_groups(), format_survey_page_title() (+26 more)

### Community 87 - "page_config.py"
Cohesion: 0.23
Nodes (14): add_object_page_config(), add_recap_page_config(), _adjacent_nearby_meters_for_page(), build_page_config(), _defer_map_context_layers_for_page(), _editor_api_urls(), home_page_config(), main_page_config() (+6 more)

### Community 88 - "conftest.py"
Cohesion: 0.40
Nodes (3): _ensure_e2e_user_per_test(), E2E fixtures (Playwright + live_server)., Recreate E2E user inside each test transaction (visible to live_server).

### Community 89 - "test_approval_smoke.py"
Cohesion: 0.10
Nodes (71): addPendingMessageGeometry(), applySoftCaseDetail(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks() (+63 more)

### Community 90 - "firewalld (RED OS / MGGT)"
Cohesion: 0.09
Nodes (34): as_text(), as_ts_string(), _join_value(), pick_property(), Any, Stream GeoJSON FeatureCollections and batch-UPDATE date / type columns on GIS ta, Returns (features_seen, rows_batched, skipped_no_join_key)., _row_from_feature() (+26 more)

### Community 91 - "closeEntryRequestModal"
Cohesion: 0.50
Nodes (4): closeEntryRequestModal(), getEntryGeometryDetailMode(), handleEntryRequestCancel(), submitEntryRequestModal()

### Community 92 - "cancelCommentPointMode"
Cohesion: 0.22
Nodes (19): _adjacent_layer_for_root(), adjacent_poly_tables(), adjacent_primary_schema_name(), _adjacent_property_pairs(), adjacent_schema_name(), _adjacent_select_sql(), _append_features(), count_adjacent_features() (+11 more)

### Community 94 - "test_geometry_multipolygon_export.py"
Cohesion: 0.67
Nodes (3): Unit tests for polygon normalization helpers in geometry-multipolygon-save.js., _run_js_tests(), test_geometry_multipolygon_export_helpers()

### Community 100 - "clearHomeOghSpecialModes"
Cohesion: 0.67
Nodes (3): clearHomeOghSpecialModes(), setHomeOghBoundariesEditMode(), setHomeOghSplitPassportMode()

### Community 139 - "__init__.py"
Cohesion: 0.28
Nodes (20): _actor_context(), api_add_case_participant(), api_approve_case(), api_case_detail(), api_change_case_owner(), api_create_adjacent_event(), api_create_case(), api_download_attachment() (+12 more)

### Community 159 - "work_layers.py"
Cohesion: 0.10
Nodes (34): landing(), adjacent_root_ids(), build_adjacent_features(), collect_adjacent_roots(), format_adjacent_roots_message(), Merge n_root from approve and event cases; derive v_roots excluding n_roots., build_adjacent_layer_groups(), Tests for adjacent passport layers on the approval map. (+26 more)

### Community 160 - "test_approval_events.py"
Cohesion: 0.14
Nodes (21): _login(), Integration tests for inspector access to approval chats., test_adjacent_event_requires_neighbor_owner(), test_bootstrap_hides_can_delete_for_owner(), test_bootstrap_marks_can_delete_for_inspector(), test_duplicate_adjacent_n_root_returns_400(), test_inspector_bootstrap_without_owner_id(), test_inspector_can_add_owner_and_login_participants() (+13 more)

### Community 161 - "test_ods_recap.py"
Cohesion: 0.12
Nodes (15): AuthenticationForm, URL configuration for pass_map project.  The `urlpatterns` list routes URLs to v, EntryPointForm, RussianAuthenticationForm, _annotate_and_filter_ods_registry_against_gis(), _build_owned_passports_geojson(), _entry_point_needs_request_id(), home() (+7 more)

### Community 162 - "event_draw.js"
Cohesion: 0.45
Nodes (11): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), removeBrushPreviewLayer(), startDrawer() (+3 more)

### Community 165 - "6.1. geodb — запись согласования (схема `approval`)"
Cohesion: 0.17
Nodes (17): applyTextLabelSize(), buildTextLabelIcon(), fitTaskGuidBounds(), fitVisibleBounds(), getLayerStylesManifest(), getSvgHotspots(), hideDbLoadingModal(), initLayerPanelControls() (+9 more)

### Community 166 - "cleanup_orphan_gis_rows.py"
Cohesion: 0.22
Nodes (12): Progressive map layer loading for the approval landing page., Return GeoJSON features for one progressive load chunk., resolve_map_layer_features(), build_reference_layer_features(), _features_from_geojson_payload(), load_work_anchor_geometry(), Reference map layers (dgi/oozt/renew/rzd) near the approval survey object., Load dgi / oozt / renew / rzd features within APPROVAL_REFERENCE_BUFFER_METERS (+4 more)

### Community 167 - "Command"
Cohesion: 0.18
Nodes (17): adjacentLayerLabel(), clampNumber(), createSvgMarker(), createTextLabelMarker(), estimateMetersToPixels(), featureTooltip(), getTableStyleDef(), hashColor() (+9 more)

### Community 169 - "clearPopupHighlight"
Cohesion: 0.20
Nodes (6): applyPopupHighlight(), clearPopupHighlight(), getFirstVertexFromDrawer(), setEditMode(), updateEditToolbarVisibility(), updateStartVertexFlag()

### Community 170 - "Запрос"
Cohesion: 0.14
Nodes (14): `approval.approves`, `approval.case_approvals`, `approval.case_message_attachments`, `approval.case_message_reactions`, `approval.case_messages`, `approval.cases`, `approval.geometry`, Из QGIS → БД (ingest) (+6 more)

### Community 175 - "runSaveAndExportFlow"
Cohesion: 0.67
Nodes (3): Enum, FileKind, str

### Community 177 - "work_layer_label"
Cohesion: 0.20
Nodes (5): delete_recap_object(), _get_recap_counts_by_request_ids(), Tests for owned recap list/export/delete API., test_delete_recap_object_success(), test_get_recap_counts_by_request_ids_includes_owner_filter()

### Community 178 - "tickAdjacentHighlightPulse"
Cohesion: 0.16
Nodes (16): adjacentLayerForRoot(), adjacentPulsePhase(), applyAdjacentFeatureStyle(), ensureLayerGroup(), findManagedGroupContaining(), hasAdjacentHighlightedEntries(), isAdjacentRootHighlighted(), lerpHexColor() (+8 more)

### Community 179 - "lookupSvgHotspot"
Cohesion: 0.20
Nodes (11): anchorPixelsFromFractions(), applySvgMarkerSize(), buildSvgIcon(), clampFraction(), enumAnchorToFraction(), hotspotBasenameFromIconUrl(), likeMatch(), lookupSvgHotspot() (+3 more)

### Community 180 - "6. Подключение к БД (сервер МГГТ)"
Cohesion: 0.29
Nodes (7): 6.1. geodb — запись согласования (схема `approval`), 6.2. mggt_asu — витрина съёмки (схема `work`, только чтение), 6.3. Локальная разработка (не МГГТ), 6. Подключение к БД (сервер МГГТ), Подключение QGIS с рабочей станции (рекомендуется), Подключение с самого сервера МГГТ, Права на запись

### Community 181 - "svgIconUrl"
Cohesion: 0.33
Nodes (7): encodeSvgPath(), getSvgIndex(), isUnknownSvgPath(), normalizeSvgLookupKey(), photoFixIconUrl(), resolveSvgRelativePath(), svgIconUrl()

### Community 182 - "_layer_stack_sort_key"
Cohesion: 0.13
Nodes (7): BaseCommand, Command, Remove export files under media/exports older than N days.  Intended for cron at, Command, Command, _to_text(), Command

### Community 184 - "refreshAutoRemoveModalOptions"
Cohesion: 0.40
Nodes (5): countGroupFeatures(), isAutoRemoveSourceDisplayed(), openAutoRemoveModal(), refreshAutoRemoveModalOptions(), resetAutoRemoveCheckboxes()

### Community 186 - "cancelCommentPointMode"
Cohesion: 0.50
Nodes (4): cancelCommentPointMode(), ensureCommentPickCapture(), openCommentPointModal(), setCommentPointMode()

### Community 187 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 189 - "cleanup_orphan_gis_rows.py"
Cohesion: 0.38
Nodes (4): _column_exists(), Command, Delete GIS rows whose request_id is not in ods_request."BrId" and created_at is, _table_exists()

### Community 191 - "Command"
Cohesion: 0.40
Nodes (3): Command, _default_db_failure_hint(), Verify PostGIS connectivity for default (geodb) and qgis (mggt_asu) database ali

### Community 192 - "Command"
Cohesion: 0.16
Nodes (14): add_recap(), _classify_ods_click_scenario(), _enrich_ods_interaction_and_geometry(), _find_gis_geometry_for_ods_short_root(), _get_owned_ods_request_for_recap(), _norm_registry_id(), _parse_ods_request_object_key(), 1 — первичное обследование (add_object), 2 — актуализация (main), 3 — split, 4 — (+6 more)

### Community 193 - "3. Главная страница"
Cohesion: 0.22
Nodes (9): 3.1. Вкладки списков, 3.2. Фильтры, 3.3. Карта на главной, 3.4. Меню «Выберите действие», 3.5. Кнопки внизу страницы, 3.6. Действия по строке паспорта, 3.7. Действия по заявке, 3.8. Заявки ОДС (+1 more)

## Knowledge Gaps
- **550 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+545 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **55 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `toEditableFeatureCollection()` connect `split_object.js` to `add-object.js`, `geojson_dynamic.py`, `checkRelations`, `checkRelations`, `runSaveAndExportFlow`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Why does `repairPolygonFromSaveModal()` connect `runSaveAndExportFlow` to `add_object.js`, `clearMapDisplayedUserDrawings`, `split_object.js`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `ExternalUser` connect `views.py` to `test_approval_events.py`, `Command`, `runSaveAndExportFlow`, `page_config.py`, `AppConfig`, `hood_scope.py`, `work_layer_label`, `refreshAutoRemoveModalOptions`, `urls.py`, `_create_new_object`, `work_layers.py`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 17 inferred relationships involving `ValueError` (e.g. with `resolve_task_owner_legal_person_id()` and `_fetch_table_meta()`) actually correct?**
  _`ValueError` has 17 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _700 weakly-connected nodes found - possible documentation gaps or missing edges._