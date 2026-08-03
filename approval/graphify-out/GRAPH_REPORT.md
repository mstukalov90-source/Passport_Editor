# Graph Report - GeoDjango/approval  (2026-08-03)

## Corpus Check
- 41 files · ~661,083 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 602 nodes · 1769 edges · 36 communities (23 shown, 13 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 40 edges (avg confidence: 0.57)
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
- work_layers.py
- views.py
- map_load.py
- work_geojson.py
- 0011_case_message_deleted.py
- 0012_case_service_events.py
- 0013_case_service_event_closed_kinds.py

## God Nodes (most connected - your core abstractions)
1. `Case` - 39 edges
2. `el()` - 33 edges
3. `Approve` - 24 edges
4. `serialize_case_summary()` - 22 edges
5. `bindUi()` - 21 edges
6. `_qgis_actor()` - 20 edges
7. `_json_error()` - 19 edges
8. `landing()` - 18 edges
9. `mapApi()` - 17 edges
10. `openCase()` - 17 edges

## Surprising Connections (you probably didn't know these)
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveAlreadyApprovedError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveUserConflictError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `build_topopassport_feature_collection()` --indirect_call--> `topo_layer_key()`  [INFERRED]
  GeoDjango/approval/work_geojson.py → GeoDjango/approval/work_layers.py
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `_qgis_actor()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/access.py

## Import Cycles
- None detected.

## Communities (36 total, 13 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.16
Nodes (27): _adjacent_layer_for_root(), adjacent_layer_key(), adjacent_poly_tables(), adjacent_primary_schema_name(), _adjacent_property_pairs(), adjacent_root_ids(), adjacent_schema_name(), _adjacent_select_sql() (+19 more)

### Community 1 - "landing.js"
Cohesion: 0.25
Nodes (8): addGeometryLayer(), clearEventGeometries(), clearSavedGeometries(), eventStyle(), geometryStyle(), messageGeometryItems(), renderEventGeometries(), renderGeometries()

### Community 2 - "qml_style_builder.py"
Cohesion: 0.07
Nodes (71): Any, BaseCommand, Element, Command, Match, build_manifest(), build_svg_index(), _collect_svg_references() (+63 more)

### Community 3 - "events_service.py"
Cohesion: 0.06
Nodes (98): is_inspector_for_approve(), user_can_access_case(), _actor_context(), api_add_case_participant(), api_approve_case(), api_case_detail(), api_change_case_owner(), api_create_adjacent_event() (+90 more)

### Community 4 - "events.js"
Cohesion: 0.09
Nodes (81): addPendingMessageGeometry(), applySoftCaseDetail(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageDeleteClicks(), bindMessageGeometryClicks() (+73 more)

### Community 5 - "api_views.py"
Cohesion: 0.16
Nodes (35): get_accessible_cases_queryset(), get_cases_queryset(), qgis_api_host_allowed(), Access rules for the QGIS approval API (internal host only)., request_host_name(), api_qgis_add_case_participant(), api_qgis_approve_by_guid(), api_qgis_approve_case() (+27 more)

### Community 6 - "event_draw.js"
Cohesion: 0.33
Nodes (16): bindMapDrawEvents(), clearBrushPreview(), eventToContainerPoint(), eventToLatLng(), finishBrushStroke(), finishGeometry(), getMap(), initToolbar() (+8 more)

### Community 18 - "updateAdjacentLayers"
Cohesion: 0.11
Nodes (29): adjacentBaseKey(), adjacentBaseStyle(), adjacentFeatureKey(), adjacentLayerForRoot(), adjacentLayerKey(), adjacentLayerLabel(), adjacentPulsePhase(), adjacentSourceLabel() (+21 more)

### Community 19 - "pointToLayer"
Cohesion: 0.18
Nodes (17): buildTextLabelIcon(), clampNumber(), createTextLabelMarker(), escapeHtml(), estimateMetersToPixels(), featurePopupHtml(), getTableStyleDef(), hashColor() (+9 more)

### Community 20 - "initMap"
Cohesion: 0.16
Nodes (17): fetchMapLayerFeatures(), fitTaskGuidBounds(), fitVisibleBounds(), getCookie(), getLayerStylesManifest(), hideDbLoadingModal(), initLayerPanelControls(), initMap() (+9 more)

### Community 21 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 22 - "svgIconUrl"
Cohesion: 0.33
Nodes (7): encodeSvgPath(), getSvgIndex(), isUnknownSvgPath(), normalizeSvgLookupKey(), photoFixIconUrl(), resolveSvgRelativePath(), svgIconUrl()

### Community 23 - "lookupSvgHotspot"
Cohesion: 0.39
Nodes (9): anchorPixelsFromFractions(), applySvgMarkerSize(), applyTextLabelSize(), buildSvgIcon(), clampFraction(), createSvgMarker(), isMapUnitVisible(), refreshMapUnitMarkers() (+1 more)

### Community 25 - "geometryStyle"
Cohesion: 0.22
Nodes (10): applyStyleToGeometryLayer(), applyStyleToPendingChild(), clearPendingGeometryHighlight(), clearPendingMessageGeometry(), highlightPendingGeometry(), pendingGeometryHighlightStyle(), pendingGeometryStyle(), removePendingGeometryLayer() (+2 more)

### Community 26 - "startMeasureMode"
Cohesion: 0.24
Nodes (12): attachMapUtilityControls(), clearMeasureGraphics(), formatMeasureMeters(), isMeasureUiTarget(), onMeasureCaptureClick(), onMeasureKeyDown(), openCurrentViewInYandexMaps(), rebuildMeasureGraphics() (+4 more)

### Community 27 - "lookupSvgHotspot"
Cohesion: 0.25
Nodes (8): enumAnchorToFraction(), getSvgHotspots(), hotspotBasenameFromIconUrl(), likeMatch(), lookupSvgHotspot(), matchFilter(), propertyValue(), resolveIconAnchorFractions()

### Community 29 - "work_layers.py"
Cohesion: 0.13
Nodes (25): work_layer_label(), build_layer_groups(), build_topopassport_layer_groups(), _column_exists(), format_survey_page_title(), _is_bottom_polygon_key(), _layer_panel_sort_key(), _layer_stack_sort_key() (+17 more)

### Community 30 - "views.py"
Cohesion: 0.13
Nodes (23): get_accessible_approve(), get_accessible_approves(), get_owner_id_for_username(), _normalized_participant_logins(), Access control for approval workflows., api_bootstrap(), serialize_approve_option(), build_map_layer_load_order() (+15 more)

### Community 31 - "map_load.py"
Cohesion: 0.27
Nodes (10): build_reference_layer_features(), _features_from_geojson_payload(), load_work_anchor_geometry(), Reference map layers (dgi/oozt/renew/rzd) near the approval survey object., Load dgi / oozt / renew / rzd features within APPROVAL_REFERENCE_BUFFER_METERS, Return survey polygon GeoJSON (dict) for TaskGUID from work YardPoly → OznPoly →, reference_buffer_meters(), geom_to_wgs84_sql() (+2 more)

### Community 32 - "work_geojson.py"
Cohesion: 0.19
Nodes (23): load_manifest(), build_schema_feature_collection(), build_topopassport_feature_collection(), build_work_feature_collection(), _feature_select_sql(), _max_features(), Load approval map features from mggt_asu.work / topopassport schemas., Return actual column name matching preferred_name case-insensitively, or None. (+15 more)

## Knowledge Gaps
- **14 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`, `api_views.py`, `views.py`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`, `api_views.py`, `views.py`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `load_manifest()` connect `work_geojson.py` to `work_adjacent.py`, `qml_style_builder.py`, `work_layers.py`, `views.py`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `ValueError` (e.g. with `merge_parsed_qml_tables()` and `resolve_task_owner_legal_person_id()`) actually correct?**
  _`ValueError` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _65 weakly-connected nodes found - possible documentation gaps or missing edges._