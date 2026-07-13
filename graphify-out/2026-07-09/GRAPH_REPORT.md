# Graph Report - GeoDjango  (2026-07-09)

## Corpus Check
- 147 files · ~369,961 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2036 nodes · 3864 edges · 165 communities (118 shown, 47 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 61 edges (avg confidence: 0.55)
- Token cost: 0 input · 0 output

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
- import_ozn_geojson.py
- refreshAutoRemoveModalOptions
- refreshAutoRemoveModalOptions
- applyHomeWorkflowOdsSyncNotifications
- renderRelationLayers
- ci_resolve_gdal_paths.sh
- conftest.py
- test_add_recap_js_smoke.py
- Command
- clearPopupHighlight
- clearDrawSnapPreview
- renderOwnedRecapsList
- Быстрый старт
- AppConfig
- landing.js
- forms.py
- Обычное обновление (только код, БД не трогаем)
- Git на MGGT и токен развёртывания (hub.mos.ru)
- Command
- dgi-export-gate.js
- refreshAutoRemoveModalOptions
- geometry-ops.js
- _simplify_geojson_for_editing
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

## God Nodes (most connected - your core abstractions)
1. `_quote_ident()` - 40 edges
2. `_get_map_layers()` - 27 edges
3. `_resolve_column_name()` - 25 edges
4. `_normalize_source_label()` - 24 edges
5. `_column_exists()` - 22 edges
6. `_get_new_object_relations()` - 22 edges
7. `_get_reference_layer_geojson()` - 21 edges
8. `_get_signal_tape_layer_geojson()` - 20 edges
9. `home()` - 19 edges
10. `_sql_geojson_param_as_valid_geom2d()` - 18 edges

## Surprising Connections (you probably didn't know these)
- `test_get_accessible_approves_filters_by_owner()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  GeoDjango/tests/test_approval_map_data.py → GeoDjango/approval/access.py
- `ApprovalConfig` --uses--> `Case`  [INFERRED]
  GeoDjango/approval/apps.py → GeoDjango/approval/models.py
- `test_count_features_by_table()` --calls--> `count_features_by_table()`  [EXTRACTED]
  GeoDjango/tests/test_approval_map_data.py → GeoDjango/approval/work_layers.py
- `autoRemoveIntersections()` --indirect_call--> `toEditableFeatureCollection()`  [INFERRED]
  GeoDjango/pass_viewer/static/pass_viewer/js/_extracted/add_object.js → GeoDjango/pass_viewer/static/pass_viewer/js/_extracted/split_object.js
- `repairPolygonFromSaveModal()` --indirect_call--> `toEditableFeatureCollection()`  [INFERRED]
  GeoDjango/pass_viewer/static/pass_viewer/js/_extracted/add_object.js → GeoDjango/pass_viewer/static/pass_viewer/js/_extracted/split_object.js

## Import Cycles
- None detected.

## Communities (165 total, 47 thin omitted)

### Community 0 - "main.js"
Cohesion: 0.02
Nodes (101): addCommentPointButton, addPolygonButton, adjacentDtPassportsGroup, applyPopupHighlight(), autoRemoveDgiMoscowCheckbox, autoRemoveDgiPrivateCheckbox, autoRemoveDtCheckbox, autoRemoveIntersectionsButton (+93 more)

### Community 1 - "home.js"
Cohesion: 0.02
Nodes (84): addObjectEntryBtn, confirmPendingForm, confirmPendingHidden, entryGeometryDetailFieldset, entryGeometryDetailFull, entryGeometryDetailSimplified, entryRecapCancelBtn, entryRecapCloseBtn (+76 more)

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
Nodes (49): applyHomeWorkflowOdsSyncNotifications(), applyOwnedFilters(), buildOdsSyncChangeMessages(), buildOwnedMapKey(), clearHomeOghSpecialModes(), clearPassportConfirmState(), closeEntryRecapModal(), closeEntryRequestModal() (+41 more)

### Community 8 - "json_loaders.py"
Cohesion: 0.09
Nodes (34): Enum, Helpers for loading seed / reference data from JSON and GeoJSON files.  Expected, import_id_names(), import_ods_request(), import_users(), _load_json_array(), _load_ods_request_rows(), _ods_row_tuple() (+26 more)

### Community 9 - "views.py"
Cohesion: 0.09
Nodes (54): add_object(), _append_auto_remove_mask_parts(), _append_intersection_mask_union_part(), auto_remove_intersections(), _auto_remove_mask_context(), _auto_remove_source_tokens(), _auto_remove_square_table_name(), cancel_pending_entry() (+46 more)

### Community 10 - "geojson_dynamic.py"
Cohesion: 0.09
Nodes (34): as_text(), as_ts_string(), _join_value(), pick_property(), Any, Stream GeoJSON FeatureCollections and batch-UPDATE date / type columns on GIS ta, Returns (features_seen, rows_batched, skipped_no_join_key)., _row_from_feature() (+26 more)

### Community 11 - "test_adjacent_relations.py"
Cohesion: 0.09
Nodes (38): map_deferred_layer_specs(), _adjacent_layers_for_json_response(), _build_map_adjacent_dt_combined_sql(), _build_map_request_layer_branch(), _build_map_requests_sql(), _build_map_requests_sql_for_source(), _build_new_object_request_layer_branch(), _defer_map_context_layers() (+30 more)

### Community 12 - "_quote_ident"
Cohesion: 0.14
Nodes (30): EntryPointForm, get_hood_intersects_sql_suffix(), Returns (sql_suffix, [params]) to AND into a WHERE clause, e.g.       AND ST_Int, _append_merge_table_select_parts(), _build_owned_passports_geojson(), _column_exists(), delete_owned_object(), delete_recap_object() (+22 more)

### Community 13 - "test_owned_recaps.py"
Cohesion: 0.09
Nodes (9): BaseBackend, DockerUsersTableBackend, Create or update the E2E test user in the users table (idempotent)., ExternalUser, Meta, Smoke tests for approval (Согласование) landing., Tests for owned recap list/export/delete API., test_delete_recap_object_success() (+1 more)

### Community 14 - "main.js"
Cohesion: 0.11
Nodes (21): applyPopupHighlight(), bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), clearPopupHighlight(), closeCommentPointModal(), deleteCommentPointById(), detachPromptSnapHandlers() (+13 more)

### Community 15 - "_get_map_layers"
Cohesion: 0.13
Nodes (24): _build_merge_allowed_sets(), _build_merge_matched_body_sql(), _build_where_clause(), _dedupe_merge_items(), _get_map_layers(), _get_source_table(), _gis_municipal_table_specs(), _hood_strip_with_keyword() (+16 more)

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
Cohesion: 0.17
Nodes (18): _as_text(), DgiXlsxSyncStats, _fetch_table_meta(), _flush_batches(), _insert_sql(), _normalize_header(), Any, _quote_ident() (+10 more)

### Community 22 - "urls.py"
Cohesion: 0.17
Nodes (25): get_hood_cte_prefix_sql(), get_hood_intersects_ha_sql(), Leading ``WITH ha AS (...), `` fragment (comma included) and its params., ``AND ST_Intersects((SELECT g FROM ha), ...)`` when scope active/empty; empty st, _adjacent_nearby_meters(), _build_id_name_lookup_expr(), _build_new_object_request_objects_sql(), _get_id_names_lookup_context() (+17 more)

### Community 23 - "finishDossierPolygon"
Cohesion: 0.14
Nodes (20): applyGeometryToDossierGroup(), bindDossierPolygonPopup(), buildEditableDeletePopupHtml(), buildExportGeometry(), clearPendingRepairedGeometry(), clearStartVertexFlag(), closeDeletePolygonModal(), closeSaveModal() (+12 more)

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
Cohesion: 0.22
Nodes (10): _annotate_and_filter_ods_registry_against_gis(), _classify_ods_click_scenario(), _enrich_ods_interaction_and_geometry(), _find_gis_geometry_for_ods_short_root(), _norm_registry_id(), _ods_brid_within_validation_window(), True, если с created_at прошло меньше hours часов (окно валидации BrId в АСУ ОДС, 1 — первичное обследование (add_object), 2 — актуализация (main), 3 — split, 4 — (+2 more)

### Community 28 - "build_page_js.py"
Cohesion: 0.24
Nodes (14): apply_forward_replacements(), apply_reverse_replacements(), build_all_pages(), build_page(), build_page_content(), check_all_pages(), main(), Path (+6 more)

### Community 29 - "_create_new_object"
Cohesion: 0.15
Nodes (17): finalize_dgi_aprove_record(), Apply server-side username and timestamp defaults before DB write., geometry_intersects_allowed_hood(), geometry_norm: GeoJSON geometry dict (not Feature/FC)., _check_recap_uniqueness(), _create_new_object(), _create_recap_object(), _dgi_aprove_column_exists() (+9 more)

### Community 30 - "basemap.js"
Cohesion: 0.25
Nodes (12): applyPopupHighlight(), bindButtonListeners(), buildBasemapButtonsHtml(), buttonScope(), clearPopupHighlight(), findControlContainer(), getCachedMggtAvailability(), probeMggtAvailability() (+4 more)

### Community 31 - "applyOwnedFilters"
Cohesion: 0.21
Nodes (14): applyOwnedFilters(), buildOwnedMapKey(), getActiveOwnedListTab(), getSelectedRequestStatusSet(), getSelectedSourceSet(), initOwnedMap(), initRequestStatusFilter(), normalizeOwnedSourceLabel() (+6 more)

### Community 32 - "Руководство пользователя сервисом отрисовки границ ОГХ"
Cohesion: 0.14
Nodes (14): 10. Ограничения по районам, 11. Ручной поиск объекта, 12. Рекомендации по работе, 13. Типичные сообщения, 14. Словарь терминов, 15. Поддержка, 1. Назначение системы, 2. Вход в систему (+6 more)

### Community 33 - "Деплой Passport Editor (MGGT / Docker)"
Cohesion: 0.15
Nodes (13): Безопасность, Ветки — зачем так, Деплой Passport Editor (MGGT / Docker), Ежедневное обновление `ods_request` (12:00 МСК), Известные нюансы, История миграции (2026-05), Ночная уборка (04:20 МСК), Обновление Docker-образа (+5 more)

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
Cohesion: 0.19
Nodes (13): buildCurrentGeometryFromSelected(), buildExportGeometry(), clearPendingRepairedGeometry(), clearSaveModalMessages(), closeSaveModal(), exportObjectFiles(), getEditableGeometryForSave(), hideSaveModalFixUi() (+5 more)

### Community 38 - "views.py"
Cohesion: 0.18
Nodes (12): get_owner_id_for_username(), landing_page_config(), Page bootstrap config for approval templates (json_script)., landing(), build_layer_groups(), Tests for approval map data loading., test_build_layer_groups_empty(), test_build_layer_groups_skips_zero_counts() (+4 more)

### Community 39 - "CI на корпоративном GitLab (hub.mos.ru)"
Cohesion: 0.17
Nodes (8): CI на корпоративном GitLab (hub.mos.ru), MosHub / старый GitLab, Если Docker Hub заблокирован, Отличия от GitHub, Первый запуск, Синхронизация с GitHub, Типичные проблемы, Что нужно на стороне GitLab

### Community 40 - "renderRelationLayers"
Cohesion: 0.20
Nodes (12): addSignalTapeLayer(), bindPdfExportLink(), clearRelationLayers(), fetchPdfExportData(), filterOutSelectedRootid(), formatDgiShortSobstvRr(), renderRecapsLayer(), renderReferenceSignalLayers() (+4 more)

### Community 41 - "BaseCommand"
Cohesion: 0.20
Nodes (5): BaseCommand, Command, Command, _to_text(), Command

### Community 42 - "page_config.py"
Cohesion: 0.30
Nodes (11): add_object_page_config(), add_recap_page_config(), _adjacent_nearby_meters_for_page(), build_page_config(), _defer_map_context_layers_for_page(), _editor_api_urls(), home_page_config(), main_page_config() (+3 more)

### Community 43 - "updateDossierToolbarState"
Cohesion: 0.25
Nodes (11): autoRemoveIntersections(), buildCurrentGeometry(), checkDgiIntersections(), checkRelations(), closeAutoRemoveModal(), getAutoRemoveSources(), hideDbLoadingModal(), showCheckDgiModal() (+3 more)

### Community 44 - "refreshObjectLayersControl"
Cohesion: 0.20
Nodes (11): bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), closeCommentPointModal(), deleteCommentPointById(), ensureCommentPickCapture(), loadCommentPointsForMap(), openCommentPointModal() (+3 more)

### Community 45 - "map-controller.js"
Cohesion: 0.42
Nodes (10): cancelCutMode(), cancelSelectionPolygonMode(), clearSplitDrawFinishFlag(), getFirstVertexFromPolygonDrawer(), getLastVertexFromPolylineDrawer(), refreshToolbar(), setEditMode(), startCutMode() (+2 more)

### Community 46 - "models.py"
Cohesion: 0.13
Nodes (20): attachment_allowed_extensions(), attachment_max_bytes(), _case_preview(), _case_status_class(), create_case_with_geometry(), _format_dt(), _geometry_to_geojson(), parse_geometry_payload() (+12 more)

### Community 47 - "bindCommentPointLayer"
Cohesion: 0.20
Nodes (10): bindCommentPointLayer(), buildCommentPointPopupHtml(), cancelCommentPointMode(), closeCommentPointModal(), deleteCommentPointById(), ensureCommentPickCapture(), loadCommentPointsForMap(), openCommentPointModal() (+2 more)

### Community 48 - "buildNewGeometryBeyondSelected"
Cohesion: 0.22
Nodes (10): bindPdfExportLink(), buildNewGeometryBeyondSelected(), captureMapCanvasForPdf(), countPolygonLikeGeometriesInCollection(), extractPolygonGeometriesFromCollection(), fetchPdfExportData(), hasNewPolygonBeyondSelected(), runPdfExportDownload() (+2 more)

### Community 49 - "_load_rows_from_xlsx"
Cohesion: 0.31
Nodes (8): _insert_batch_rows(), _load_rows_from_xlsx(), Path, Returns (unique rows by descr, skipped_empty_descr, duplicate_descr_count)., Unit tests for dgi.xlsx parsing (no database)., test_insert_batch_rows_order(), test_load_rows_from_xlsx_dedupes_by_descr(), _write_sample_xlsx()

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
Cohesion: 0.22
Nodes (9): CI, Page JS (`home.js`, `main.js`, …), Passport Editor (GeoDjango), pre-commit, Основные команды, Первый прогон CI на GitHub, Проверки качества, Структура тестов (+1 more)

### Community 56 - "test_smoke.py"
Cohesion: 0.25
Nodes (4): _dismiss_home_workflow_modal_if_open(), Browser smoke tests (Playwright)., home.js opens #home-workflow-modal after scripts run; close it to unblock clicks, test_user_guide_modal_opens()

### Community 57 - "3. Главная страница"
Cohesion: 0.22
Nodes (9): 3.1. Вкладки списков, 3.2. Фильтры, 3.3. Карта на главной, 3.4. Меню «Выберите действие», 3.5. Кнопки внизу страницы, 3.6. Действия по строке паспорта, 3.7. Действия по заявке, 3.8. Заявки ОДС (+1 more)

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

### Community 64 - "cleanup_orphan_gis_rows.py"
Cohesion: 0.38
Nodes (4): _column_exists(), Command, Delete GIS rows whose request_id is not in ods_request."BrId" and created_at is, _table_exists()

### Community 65 - "import_ozn_geojson.py"
Cohesion: 0.43
Nodes (4): Command, _detect_source_srid(), _pick_prop(), _text_or_none()

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

### Community 73 - "Command"
Cohesion: 0.40
Nodes (3): Command, _default_db_failure_hint(), Verify PostGIS connectivity for default (geodb) and qgis (mggt_asu) database ali

### Community 74 - "clearPopupHighlight"
Cohesion: 0.20
Nodes (6): applyPopupHighlight(), clearPopupHighlight(), getFirstVertexFromDrawer(), setEditMode(), updateEditToolbarVisibility(), updateStartVertexFlag()

### Community 75 - "clearDrawSnapPreview"
Cohesion: 0.33
Nodes (6): clearDrawSnapPreview(), findNearestCandidate(), findNearestSnapTarget(), nearestPointOnSegment(), snapLastDrawVertexIfNeeded(), updateDrawSnapPreview()

### Community 76 - "renderOwnedRecapsList"
Cohesion: 0.47
Nodes (6): deleteOwnedRecap(), downloadOwnedRecap(), openOwnedRecapsModal(), ownedRecapsEscapeHtml(), renderOwnedRecapsList(), updateOwnedRecapsBadge()

### Community 77 - "Быстрый старт"
Cohesion: 0.33
Nodes (6): QGIS-витрина (alias `qgis`), Быстрый старт, Локальная geodb (Docker), Опционально: прод geodb через SSH, Проверка подключений, Сид данных (опционально)

### Community 78 - "AppConfig"
Cohesion: 0.28
Nodes (5): AppConfig, ApprovalConfig, serialize_approve_option(), Approve, PassViewerConfig

### Community 79 - "landing.js"
Cohesion: 0.19
Nodes (16): clearEventGeometries(), ensureLayerGroup(), eventStyle(), featureTooltip(), fitVisibleBounds(), hashColor(), highlightCase(), initLayerPanelControls() (+8 more)

### Community 80 - "forms.py"
Cohesion: 0.50
Nodes (3): AuthenticationForm, URL configuration for pass_map project.  The `urlpatterns` list routes URLs to v, RussianAuthenticationForm

### Community 81 - "Обычное обновление (только код, БД не трогаем)"
Cohesion: 0.40
Nodes (5): 1. Локально (из репозитория GeoDjango), 2. На сервере (обновление кода), 3. Проверка, 4. Вернуться к разработке, Обычное обновление (только код, БД не трогаем)

### Community 82 - "Git на MGGT и токен развёртывания (hub.mos.ru)"
Cohesion: 0.40
Nodes (5): Git на MGGT и токен развёртывания (hub.mos.ru), RED OS: Docker Hub недоступен, Первичная привязка каталога (если git ещё не инициализирован), Переменные `.env` на проде, Создать новый токен (если истёк или заменяете)

### Community 85 - "refreshAutoRemoveModalOptions"
Cohesion: 0.40
Nodes (5): countGroupFeatures(), isAutoRemoveSourceDisplayed(), openAutoRemoveModal(), refreshAutoRemoveModalOptions(), resetAutoRemoveCheckboxes()

### Community 87 - "_simplify_geojson_for_editing"
Cohesion: 0.50
Nodes (4): _simplify_geojson_for_editing(), Contract tests for geometry shape passed to the map editor (main page)., main embeds this via selected_geometry_for_editing; utils.js must wrap it as FC., test_simplify_single_polygon_returns_bare_polygon_geometry()

### Community 88 - "conftest.py"
Cohesion: 0.40
Nodes (3): _ensure_e2e_user_per_test(), E2E fixtures (Playwright + live_server)., Recreate E2E user inside each test transaction (visible to live_server).

### Community 89 - "test_approval_smoke.py"
Cohesion: 0.30
Nodes (22): approveCase(), bindUi(), createCase(), drawApi(), el(), escapeHtml(), fetchJson(), findCase() (+14 more)

### Community 90 - "firewalld (RED OS / MGGT)"
Cohesion: 0.50
Nodes (4): firewalld (RED OS / MGGT), Обязательное правило для Docker, Проверка после включения firewalld, Что должно быть открыто / закрыто

### Community 91 - "closeEntryRequestModal"
Cohesion: 0.50
Nodes (4): closeEntryRequestModal(), getEntryGeometryDetailMode(), handleEntryRequestCancel(), submitEntryRequestModal()

### Community 92 - "cancelCommentPointMode"
Cohesion: 0.50
Nodes (4): cancelCommentPointMode(), ensureCommentPickCapture(), openCommentPointModal(), setCommentPointMode()

### Community 94 - "test_geometry_multipolygon_export.py"
Cohesion: 0.67
Nodes (3): Unit tests for polygon normalization helpers in geometry-multipolygon-save.js., _run_js_tests(), test_geometry_multipolygon_export_helpers()

### Community 96 - "4. Карта редактирования объекта"
Cohesion: 0.50
Nodes (4): 4.1. Панель инструментов, 4.2. Панель управления слоями, 4.3. Типовой порядок редактирования, 4. Карта редактирования объекта

### Community 100 - "clearHomeOghSpecialModes"
Cohesion: 0.67
Nodes (3): clearHomeOghSpecialModes(), setHomeOghBoundariesEditMode(), setHomeOghSplitPassportMode()

### Community 139 - "__init__.py"
Cohesion: 0.27
Nodes (17): get_accessible_approve(), get_accessible_approves(), Access control for approval workflows., user_can_access_case(), api_approve_case(), api_bootstrap(), api_case_detail(), api_create_case() (+9 more)

### Community 159 - "work_layers.py"
Cohesion: 0.36
Nodes (11): build_work_feature_collection(), _feature_select_sql(), _max_features(), Load approval map features from mggt_asu.work schema., count_features_by_table(), list_work_layer_tables(), _quote_ident(), Registry of mggt_asu.work tables usable as approval map layers. (+3 more)

### Community 160 - "test_approval_events.py"
Cohesion: 0.26
Nodes (10): _login(), _primary_case(), Tests for approval events, chats, and unanimous approval., test_bootstrap_returns_primary_case(), test_closed_case_rejects_new_message(), test_create_case_with_geometry(), test_foreign_owner_cannot_access_case(), test_landing_page_has_events_shell() (+2 more)

### Community 161 - "test_ods_recap.py"
Cohesion: 0.26
Nodes (8): add_recap(), _get_owned_ods_request_for_recap(), _parse_ods_request_object_key(), Tests for ODS request recap entry (add_recap from ods_request rows)., test_get_owned_ods_request_for_recap_no_geometry(), test_get_owned_ods_request_for_recap_success(), test_get_owned_ods_request_for_recap_wrong_owner(), test_parse_ods_request_object_key()

### Community 162 - "event_draw.js"
Cohesion: 0.49
Nodes (10): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), startCreateMode(), startDrawer() (+2 more)

## Knowledge Gaps
- **461 isolated node(s):** `Migration`, `Migration`, `Migration`, `Meta`, `Migration` (+456 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **47 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `toEditableFeatureCollection()` connect `split_object.js` to `add-object.js`, `runSaveAndExportFlow`, `checkRelations`, `checkRelations`, `runSaveAndExportFlow`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Why does `ExternalUser` connect `test_owned_recaps.py` to `test_approval_events.py`, `test_ods_recap.py`, `views.py`, `json_loaders.py`, `views.py`, `__init__.py`, `hood_scope.py`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Command` connect `BaseCommand` to `test_owned_recaps.py`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _569 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `main.js` be split into smaller, more focused modules?**
  _Cohesion score 0.01886465905157494 - nodes in this community are weakly interconnected._
- **Should `home.js` be split into smaller, more focused modules?**
  _Cohesion score 0.02040816326530612 - nodes in this community are weakly interconnected._
- **Should `add_object.js` be split into smaller, more focused modules?**
  _Cohesion score 0.021505376344086023 - nodes in this community are weakly interconnected._