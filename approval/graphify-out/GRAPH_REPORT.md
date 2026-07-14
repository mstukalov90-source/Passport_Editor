# Graph Report - GeoDjango/approval  (2026-07-14)

## Corpus Check
- 32 files · ~626,469 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 378 nodes · 1018 edges · 18 communities (9 shown, 9 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 21 edges (avg confidence: 0.57)
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

## God Nodes (most connected - your core abstractions)
1. `Case` - 28 edges
2. `el()` - 19 edges
3. `Approve` - 16 edges
4. `initMap()` - 16 edges
5. `landing()` - 16 edges
6. `serialize_case_summary()` - 14 edges
7. `load_manifest()` - 14 edges
8. `bindUi()` - 14 edges
9. `openCase()` - 13 edges
10. `_parse_svg_marker()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_bootstrap()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_bootstrap()` --calls--> `get_accessible_approve()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_bootstrap()` --calls--> `serialize_approve_option()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/events_service.py
- `ApprovalConfig` --uses--> `Approve`  [INFERRED]
  GeoDjango/approval/apps.py → GeoDjango/approval/models.py

## Import Cycles
- None detected.

## Communities (18 total, 9 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.09
Nodes (53): get_accessible_approve(), get_accessible_approves(), get_owner_id_for_username(), is_inspector_for_approve(), Access control for approval workflows., serialize_approve_option(), landing_page_config(), Page bootstrap config for approval templates (json_script). (+45 more)

### Community 1 - "landing.js"
Cohesion: 0.05
Nodes (84): addGeometryLayer(), adjacentBaseStyle(), adjacentFeatureKey(), adjacentLayerForRoot(), adjacentLayerLabel(), adjacentPulsePhase(), anchorPixelsFromFractions(), applyAdjacentFeatureStyle() (+76 more)

### Community 2 - "qml_style_builder.py"
Cohesion: 0.10
Nodes (51): Any, Element, build_manifest(), build_svg_index(), _collect_svg_references(), collect_table_names(), copy_referenced_svgs(), default_swatch_style() (+43 more)

### Community 3 - "events_service.py"
Cohesion: 0.07
Nodes (73): get_accessible_cases_queryset(), user_can_access_case(), _actor_context(), api_approve_case(), api_bootstrap(), api_case_detail(), api_create_case(), api_download_attachment() (+65 more)

### Community 4 - "events.js"
Cohesion: 0.13
Nodes (51): addPendingMessageGeometry(), approveCase(), bindEventCardClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks(), bindMessageReplyClicks(), bindUi(), buildEventCardHtml() (+43 more)

### Community 6 - "event_draw.js"
Cohesion: 0.49
Nodes (10): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), startDrawer(), startDrawMode() (+2 more)

## Knowledge Gaps
- **9 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+4 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `load_manifest()` connect `work_adjacent.py` to `qml_style_builder.py`, `api_views.py`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `initMap()` (e.g. with `pointToLayer()` and `styleFeature()`) actually correct?**
  _`initMap()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _28 weakly-connected nodes found - possible documentation gaps or missing edges._