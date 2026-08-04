# Graph Report - GeoDjango/approval  (2026-08-04)

## Corpus Check
- 41 files · ~663,310 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 640 nodes · 1893 edges · 34 communities (21 shown, 13 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 41 edges (avg confidence: 0.57)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- work_adjacent.py
- landing.js
- qml_style_builder.py
- events_service.py
- events.js
- api_views.py
- event_draw.js
- 0001_create_approval_schema.py
- 0002_cases_approved_chat_files.py
- 0003_approves_neighbour_guid.py
- 0004_approves_n_root_v_root_name.py
- 0005_cases_roots_message_geometry.py
- 0006_inspector_and_case_roots.py
- 0007_case_message_reactions.py
- 0008_case_message_parent.py
- updateAdjacentLayers
- pointToLayer
- initMap
- geometryLayerKey
- svgIconUrl
- lookupSvgHotspot
- 0009_case_participant_logins.py
- geometryStyle
- startMeasureMode
- lookupSvgHotspot
- 0010_case_message_reaction_verdict_kinds.py
- map_load.py
- tickAdjacentHighlightPulse
- 0011_case_message_deleted.py
- 0012_case_service_events.py
- 0013_case_service_event_closed_kinds.py

## God Nodes (most connected - your core abstractions)
1. `Case` - 44 edges
2. `el()` - 35 edges
3. `Approve` - 24 edges
4. `serialize_case_summary()` - 22 edges
5. `bindUi()` - 22 edges
6. `_json_error()` - 20 edges
7. `_qgis_actor()` - 20 edges
8. `mapApi()` - 18 edges
9. `openCase()` - 18 edges
10. `landing()` - 18 edges

## Surprising Connections (you probably didn't know these)
- `delete_approve()` --calls--> `delete_approve_for_inspector()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/events_service.py
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveAlreadyApprovedError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveUserConflictError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `_qgis_actor()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/access.py

## Import Cycles
- None detected.

## Communities (34 total, 13 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.14
Nodes (31): _adjacent_layer_for_root(), adjacent_layer_key(), adjacent_poly_tables(), adjacent_primary_schema_name(), _adjacent_property_pairs(), adjacent_root_ids(), adjacent_schema_name(), _adjacent_select_sql() (+23 more)

### Community 1 - "landing.js"
Cohesion: 0.12
Nodes (25): _column_exists(), _is_bottom_polygon_key(), _layer_panel_sort_key(), _layer_stack_sort_key(), lookup_task_survey_fields(), _owner_lookup_table_order(), Registry of mggt_asu.work / topopassport tables usable as approval map layers., Exclude order-boundary lines from topolines map load and counts. (+17 more)

### Community 2 - "qml_style_builder.py"
Cohesion: 0.07
Nodes (72): Any, BaseCommand, Element, Command, Match, build_manifest(), build_svg_index(), _collect_svg_references() (+64 more)

### Community 3 - "events_service.py"
Cohesion: 0.05
Nodes (103): _actor_context(), api_add_case_participant(), api_approve_case(), api_bootstrap(), api_case_detail(), api_change_case_owner(), api_create_adjacent_event(), api_create_case() (+95 more)

### Community 4 - "events.js"
Cohesion: 0.08
Nodes (87): addPendingMessageGeometry(), applySoftCaseDetail(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageDeleteClicks(), bindMessageGeometryClicks() (+79 more)

### Community 5 - "api_views.py"
Cohesion: 0.12
Nodes (46): get_accessible_approve(), get_accessible_approves(), get_accessible_cases_queryset(), is_inspector_for_approve(), _normalized_participant_logins(), Access control for approval workflows., user_can_access_case(), build_geometries_feature_collection() (+38 more)

### Community 6 - "event_draw.js"
Cohesion: 0.33
Nodes (16): bindMapDrawEvents(), clearBrushPreview(), eventToContainerPoint(), eventToLatLng(), finishBrushStroke(), finishGeometry(), getMap(), initToolbar() (+8 more)

### Community 18 - "updateAdjacentLayers"
Cohesion: 0.09
Nodes (33): addGeometryLayer(), adjacentBaseKey(), adjacentBaseStyle(), adjacentFeatureKey(), adjacentLayerForRoot(), adjacentLayerKey(), adjacentLayerLabel(), adjacentSourceLabel() (+25 more)

### Community 19 - "pointToLayer"
Cohesion: 0.12
Nodes (24): adjacentFeatureDisplayName(), bindReferenceLayerPopup(), clampNumber(), createTextLabelMarker(), enumAnchorToFraction(), escapeHtml(), estimateMetersToPixels(), featurePopupHtml() (+16 more)

### Community 20 - "initMap"
Cohesion: 0.11
Nodes (29): ensureLayerGroup(), findManagedGroupContaining(), fitTaskGuidBounds(), fitVisibleBounds(), hideDbLoadingModal(), initLayerPanelControls(), initMap(), isAdjacentLayerKey() (+21 more)

### Community 21 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 22 - "svgIconUrl"
Cohesion: 0.25
Nodes (9): encodeSvgPath(), getSvgHotspots(), getSvgIndex(), isUnknownSvgPath(), normalizeSvgLookupKey(), photoFixIconUrl(), readJsonScript(), resolveSvgRelativePath() (+1 more)

### Community 23 - "lookupSvgHotspot"
Cohesion: 0.25
Nodes (11): anchorPixelsFromFractions(), applySvgMarkerSize(), applyTextLabelSize(), buildSvgIcon(), buildTextLabelIcon(), clampFraction(), createSvgMarker(), hotspotBasenameFromIconUrl() (+3 more)

### Community 25 - "geometryStyle"
Cohesion: 0.20
Nodes (24): load_work_anchor_geometry(), Return survey polygon GeoJSON (dict) for TaskGUID from work YardPoly → OznPoly →, build_schema_feature_collection(), build_topopassport_feature_collection(), build_work_feature_collection(), _feature_select_sql(), Load approval map features from mggt_asu.work / topopassport schemas., Return actual column name matching preferred_name case-insensitively, or None. (+16 more)

### Community 26 - "startMeasureMode"
Cohesion: 0.24
Nodes (12): attachMapUtilityControls(), clearMeasureGraphics(), formatMeasureMeters(), isMeasureUiTarget(), onMeasureCaptureClick(), onMeasureKeyDown(), openCurrentViewInYandexMaps(), rebuildMeasureGraphics() (+4 more)

### Community 27 - "lookupSvgHotspot"
Cohesion: 0.15
Nodes (20): get_owner_id_for_username(), serialize_approve_option(), build_map_layer_load_order(), Ordered specs for sequential client-side loading., landing_page_config(), Page bootstrap config for approval templates (json_script)., load_manifest(), api_map_layer() (+12 more)

### Community 29 - "map_load.py"
Cohesion: 0.22
Nodes (12): Progressive map layer loading for the approval landing page., Return GeoJSON features for one progressive load chunk., resolve_map_layer_features(), _build_dgi_split_features(), build_reference_layer_features(), _features_from_geojson_payload(), Reference map layers (dgi/oozt/renew/rzd) near the approval survey object., Load ДГИ as four ownership×rent buckets; tag each feature with dgiSubKey. (+4 more)

### Community 30 - "tickAdjacentHighlightPulse"
Cohesion: 0.27
Nodes (10): adjacentPulsePhase(), applyAdjacentFeatureStyle(), hasAdjacentHighlightedEntries(), lerpHexColor(), parseHexColor(), setAdjacentHighlightStyle(), startAdjacentHighlightPulse(), stopAdjacentHighlightPulse() (+2 more)

## Knowledge Gaps
- **14 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`, `map_load.py`, `lookupSvgHotspot`, `api_views.py`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **Why does `merge_parsed_qml_tables()` connect `qml_style_builder.py` to `events_service.py`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `ValueError` (e.g. with `merge_parsed_qml_tables()` and `resolve_task_owner_legal_person_id()`) actually correct?**
  _`ValueError` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _75 weakly-connected nodes found - possible documentation gaps or missing edges._