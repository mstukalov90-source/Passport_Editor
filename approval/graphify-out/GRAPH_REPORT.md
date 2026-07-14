# Graph Report - GeoDjango/approval  (2026-07-14)

## Corpus Check
- 31 files · ~623,081 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 326 nodes · 896 edges · 17 communities (10 shown, 7 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 20 edges (avg confidence: 0.57)
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

## God Nodes (most connected - your core abstractions)
1. `Case` - 28 edges
2. `Approve` - 16 edges
3. `el()` - 16 edges
4. `landing()` - 15 edges
5. `serialize_case_summary()` - 14 edges
6. `bindUi()` - 14 edges
7. `initMap()` - 14 edges
8. `load_manifest()` - 13 edges
9. `openCase()` - 13 edges
10. `renderChatMessages()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `ApproveAlreadyApprovedError` --uses--> `CaseMessage`  [INFERRED]
  GeoDjango/approval/events_service.py → GeoDjango/approval/models.py
- `_actor_context()` --calls--> `get_owner_id_for_username()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_bootstrap()` --calls--> `get_accessible_approves()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_bootstrap()` --calls--> `get_accessible_approve()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/access.py
- `api_qgis_upsert_approve()` --calls--> `upsert_approve_from_qgis()`  [EXTRACTED]
  GeoDjango/approval/api_views.py → GeoDjango/approval/events_service.py

## Import Cycles
- None detected.

## Communities (17 total, 7 thin omitted)

### Community 0 - "work_adjacent.py"
Cohesion: 0.09
Nodes (51): get_accessible_approve(), get_accessible_approves(), get_owner_id_for_username(), is_inspector_for_approve(), Access control for approval workflows., serialize_approve_option(), landing_page_config(), Page bootstrap config for approval templates (json_script). (+43 more)

### Community 1 - "landing.js"
Cohesion: 0.07
Nodes (54): addGeometryLayer(), adjacentFeatureKey(), adjacentLayerForRoot(), adjacentLayerLabel(), applyStyleToGeometryLayer(), clearEventGeometries(), clearPendingMessageGeometry(), clearSavedGeometries() (+46 more)

### Community 2 - "qml_style_builder.py"
Cohesion: 0.11
Nodes (46): Any, BaseCommand, Element, Command, build_manifest(), build_svg_index(), _collect_svg_references(), collect_table_names() (+38 more)

### Community 3 - "events_service.py"
Cohesion: 0.11
Nodes (42): AppConfig, ApprovalConfig, aggregate_approve_owners(), _approvals_progress(), ApproveAlreadyApprovedError, attachment_allowed_extensions(), attachment_max_bytes(), _case_is_fully_approved() (+34 more)

### Community 4 - "events.js"
Cohesion: 0.18
Nodes (40): approveCase(), bindEventCardClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks(), bindUi(), buildEventCardHtml(), clearPendingMessageGeometry(), closeApproveConfirmDialog() (+32 more)

### Community 5 - "api_views.py"
Cohesion: 0.14
Nodes (31): get_accessible_cases_queryset(), user_can_access_case(), _actor_context(), api_approve_case(), api_bootstrap(), api_case_detail(), api_create_case(), api_download_attachment() (+23 more)

### Community 6 - "event_draw.js"
Cohesion: 0.49
Nodes (10): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), startDrawer(), startDrawMode() (+2 more)

## Knowledge Gaps
- **8 isolated node(s):** `Migration`, `Migration`, `Migration`, `Migration`, `Migration` (+3 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Case` connect `events_service.py` to `work_adjacent.py`, `api_views.py`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `Approve` connect `events_service.py` to `work_adjacent.py`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `resolve_task_owner_legal_person_id()` connect `work_adjacent.py` to `events_service.py`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Case` (e.g. with `ApprovalConfig` and `ApproveAlreadyApprovedError`) actually correct?**
  _`Case` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Approve` (e.g. with `ApprovalConfig` and `.ready()`) actually correct?**
  _`Approve` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Access control for approval workflows.`, `JSON API for approval events and chats.`, `Serialization and business logic for approval events/chats.` to the rest of the system?**
  _23 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `work_adjacent.py` be split into smaller, more focused modules?**
  _Cohesion score 0.08983050847457627 - nodes in this community are weakly interconnected._