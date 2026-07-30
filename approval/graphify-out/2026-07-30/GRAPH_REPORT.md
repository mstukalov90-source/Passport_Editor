# Graph Report - GeoDjango/approval  (2026-07-30)

## Corpus Check
- 38 files · ~659,039 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 567 nodes · 1642 edges · 29 communities (19 shown, 10 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 35 edges (avg confidence: 0.58)
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

## God Nodes (most connected - your core abstractions)
1. `Case` - 34 edges
2. `el()` - 31 edges
3. `Approve` - 24 edges
4. `bindUi()` - 21 edges
5. `serialize_case_summary()` - 18 edges
6. `landing()` - 18 edges
7. `mapApi()` - 16 edges
8. `openCase()` - 16 edges
9. `pointToLayer()` - 15 edges
10. `load_manifest()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `_qgis_actor()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/access.py
- `serialize_approve_option()` --calls--> `is_inspector_for_approve()`  [EXTRACTED]
  GeoDjango/approval/events_service.py → GeoDjango/approval/access.py
- `landing()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  GeoDjango/approval/views.py → GeoDjango/approval/access.py
- `api_map_layer()` --calls--> `get_accessible_approve()`  [EXTRACTED]
  GeoDjango/approval/views.py → GeoDjango/approval/access.py

## Import Cycles
- None detected.

## Communities (29 total, 10 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.05
Nodes (100): get_owner_id_for_username(), serialize_approve_option(), build_map_layer_load_order(), Progressive map layer loading for the approval landing page., Ordered specs for sequential client-side loading., Return GeoJSON features for one progressive load chunk., resolve_map_layer_features(), landing_page_config() (+92 more)

### Community 1 - "landing.js"
Cohesion: 0.25
Nodes (8): addGeometryLayer(), clearEventGeometries(), clearSavedGeometries(), eventStyle(), geometryStyle(), messageGeometryItems(), renderEventGeometries(), renderGeometries()

### Community 2 - "qml_style_builder.py"
Cohesion: 0.07
Nodes (72): Any, BaseCommand, Element, Command, Match, build_manifest(), build_svg_index(), _collect_svg_references() (+64 more)

### Community 3 - "events_service.py"
Cohesion: 0.05
Nodes (115): get_accessible_approve(), get_accessible_approves(), get_accessible_cases_queryset(), is_inspector_for_approve(), _normalized_participant_logins(), Access control for approval workflows., user_can_access_case(), _actor_context() (+107 more)

### Community 4 - "events.js"
Cohesion: 0.09
Nodes (76): addPendingMessageGeometry(), applySoftCaseDetail(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks() (+68 more)

### Community 5 - "api_views.py"
Cohesion: 0.67
Nodes (3): qgis_api_host_allowed(), Access rules for the QGIS approval API (internal host only)., request_host_name()

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
- **11 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+6 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `Case` connect `events_service.py` to `work_adjacent.py`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `merge_parsed_qml_tables()` connect `qml_style_builder.py` to `events_service.py`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `bindUi()` (e.g. with `resizeChatInput()` and `showError()`) actually correct?**
  _`bindUi()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `ValueError` (e.g. with `merge_parsed_qml_tables()` and `resolve_task_owner_legal_person_id()`) actually correct?**
  _`ValueError` has 2 INFERRED edges - model-reasoned connections that need verification._