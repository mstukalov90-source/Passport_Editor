# Graph Report - GeoDjango/approval  (2026-08-04)

## Corpus Check
- 41 files · ~661,361 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 604 nodes · 1789 edges · 32 communities (19 shown, 13 thin omitted)
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
- 0011_case_message_deleted.py
- 0012_case_service_events.py
- 0013_case_service_event_closed_kinds.py

## God Nodes (most connected - your core abstractions)
1. `Case` - 40 edges
2. `el()` - 33 edges
3. `Approve` - 24 edges
4. `serialize_case_summary()` - 22 edges
5. `bindUi()` - 21 edges
6. `_json_error()` - 20 edges
7. `_qgis_actor()` - 20 edges
8. `mapApi()` - 18 edges
9. `openCase()` - 18 edges
10. `landing()` - 18 edges

## Surprising Connections (you probably didn't know these)
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveAlreadyApprovedError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveUserConflictError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_map_layer()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/views.py → GeoDjango/approval/access.py
- `landing()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/views.py → GeoDjango/approval/access.py

## Import Cycles
- None detected.

## Communities (32 total, 13 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.05
Nodes (101): serialize_approve_option(), build_map_layer_load_order(), Progressive map layer loading for the approval landing page., Ordered specs for sequential client-side loading., Return GeoJSON features for one progressive load chunk., resolve_map_layer_features(), landing_page_config(), Page bootstrap config for approval templates (json_script). (+93 more)

### Community 1 - "landing.js"
Cohesion: 0.25
Nodes (8): addGeometryLayer(), clearEventGeometries(), clearSavedGeometries(), eventStyle(), geometryStyle(), messageGeometryItems(), renderEventGeometries(), renderGeometries()

### Community 2 - "qml_style_builder.py"
Cohesion: 0.07
Nodes (72): Any, BaseCommand, Element, Command, Match, build_manifest(), build_svg_index(), _collect_svg_references() (+64 more)

### Community 3 - "events_service.py"
Cohesion: 0.06
Nodes (98): is_inspector_for_approve(), _normalized_participant_logins(), user_can_access_case(), _actor_context(), api_add_case_participant(), api_approve_case(), api_case_detail(), api_change_case_owner() (+90 more)

### Community 4 - "events.js"
Cohesion: 0.09
Nodes (82): addPendingMessageGeometry(), applySoftCaseDetail(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageDeleteClicks(), bindMessageGeometryClicks() (+74 more)

### Community 5 - "api_views.py"
Cohesion: 0.14
Nodes (42): get_accessible_approve(), get_accessible_approves(), get_accessible_cases_queryset(), get_owner_id_for_username(), Access control for approval workflows., api_bootstrap(), get_cases_queryset(), Short approve payload for QGIS list/detail headers. (+34 more)

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

## Knowledge Gaps
- **14 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `merge_parsed_qml_tables()` connect `qml_style_builder.py` to `events_service.py`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `ValueError` (e.g. with `merge_parsed_qml_tables()` and `resolve_task_owner_legal_person_id()`) actually correct?**
  _`ValueError` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _65 weakly-connected nodes found - possible documentation gaps or missing edges._