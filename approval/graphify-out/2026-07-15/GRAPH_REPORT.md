# Graph Report - GeoDjango/approval  (2026-07-15)

## Corpus Check
- 36 files · ~631,880 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 472 nodes · 1370 edges · 25 communities (16 shown, 9 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 30 edges (avg confidence: 0.58)
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

## God Nodes (most connected - your core abstractions)
1. `Case` - 33 edges
2. `el()` - 29 edges
3. `Approve` - 22 edges
4. `serialize_case_summary()` - 18 edges
5. `landing()` - 17 edges
6. `bindUi()` - 16 edges
7. `openCase()` - 15 edges
8. `load_manifest()` - 14 edges
9. `_qgis_actor()` - 13 edges
10. `mapApi()` - 13 edges

## Surprising Connections (you probably didn't know these)
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveAlreadyApprovedError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `api_qgis_upsert_approve()` --indirect_call--> `ApproveUserConflictError`  [INFERRED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/events_service.py
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `_qgis_actor()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/qgis_api_views.py → GeoDjango/approval/access.py
- `serialize_approve_option()` --calls--> `is_inspector_for_approve()`  [EXTRACTED]
  GeoDjango/approval/events_service.py → GeoDjango/approval/access.py

## Import Cycles
- None detected.

## Communities (25 total, 9 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.06
Nodes (90): get_accessible_approve(), get_accessible_approves(), get_owner_id_for_username(), _normalized_participant_logins(), Access control for approval workflows., api_bootstrap(), serialize_approve_option(), build_map_layer_load_order() (+82 more)

### Community 1 - "landing.js"
Cohesion: 0.12
Nodes (22): addGeometryLayer(), adjacentBaseStyle(), adjacentFeatureKey(), applyStyleToGeometryLayer(), clampNumber(), clearEventGeometries(), clearPendingMessageGeometry(), clearSavedGeometries() (+14 more)

### Community 2 - "qml_style_builder.py"
Cohesion: 0.11
Nodes (47): Any, BaseCommand, Element, Command, build_manifest(), build_svg_index(), _collect_svg_references(), collect_table_names() (+39 more)

### Community 3 - "events_service.py"
Cohesion: 0.07
Nodes (77): is_inspector_for_approve(), user_can_access_case(), _actor_context(), api_add_case_participant(), api_approve_case(), api_case_detail(), api_change_case_owner(), api_create_case() (+69 more)

### Community 4 - "events.js"
Cohesion: 0.10
Nodes (67): addPendingMessageGeometry(), approveCase(), attachmentDownloadUrl(), bindAttachmentClicks(), bindEventCardClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks(), bindMessageReplyClicks() (+59 more)

### Community 5 - "api_views.py"
Cohesion: 0.14
Nodes (32): get_accessible_cases_queryset(), build_geometries_feature_collection(), _format_dt(), get_cases_queryset(), Short approve payload for QGIS list/detail headers., GeoJSON FeatureCollection for QGIS map layers., serialize_approve_qgis_summary(), qgis_api_host_allowed() (+24 more)

### Community 6 - "event_draw.js"
Cohesion: 0.49
Nodes (10): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), startDrawer(), startDrawMode() (+2 more)

### Community 18 - "updateAdjacentLayers"
Cohesion: 0.16
Nodes (16): adjacentLayerForRoot(), adjacentPulsePhase(), applyAdjacentFeatureStyle(), ensureLayerGroup(), findManagedGroupContaining(), hasAdjacentHighlightedEntries(), isAdjacentRootHighlighted(), lerpHexColor() (+8 more)

### Community 19 - "pointToLayer"
Cohesion: 0.20
Nodes (15): adjacentLayerLabel(), createSvgMarker(), enumAnchorToFraction(), featureTooltip(), getTableStyleDef(), hashColor(), leafletPathStyle(), matchFilter() (+7 more)

### Community 20 - "initMap"
Cohesion: 0.20
Nodes (15): fitTaskGuidBounds(), fitVisibleBounds(), getLayerStylesManifest(), getSvgHotspots(), hideDbLoadingModal(), initLayerPanelControls(), initMap(), loadDeferredMapLayers() (+7 more)

### Community 21 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 22 - "svgIconUrl"
Cohesion: 0.33
Nodes (7): encodeSvgPath(), getSvgIndex(), isUnknownSvgPath(), normalizeSvgLookupKey(), photoFixIconUrl(), resolveSvgRelativePath(), svgIconUrl()

### Community 23 - "lookupSvgHotspot"
Cohesion: 0.40
Nodes (6): anchorPixelsFromFractions(), applySvgMarkerSize(), buildSvgIcon(), clampFraction(), hotspotBasenameFromIconUrl(), lookupSvgHotspot()

## Knowledge Gaps
- **10 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+5 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `resolve_task_owner_legal_person_id()` connect `work_adjacent.py` to `events_service.py`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _44 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `work_adjacent.py` be split into smaller, more focused modules?**
  _Cohesion score 0.055134925257231605 - nodes in this community are weakly interconnected._