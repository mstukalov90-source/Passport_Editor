# Graph Report - GeoDjango/approval/static/approval/js  (2026-07-17)

## Corpus Check
- 3 files · ~11,674 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 191 nodes · 521 edges · 17 communities
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 5 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- landing.js
- el
- openCase
- svgIconUrl
- initMap
- updateAdjacentLayers
- pointToLayer
- event_draw.js
- events.js
- renderGeometries
- escapeHtml
- geometryLayerKey
- bindUi
- applyStyleToGeometryLayer
- applySoftCaseDetail
- renderEventNav
- createSvgMarker

## God Nodes (most connected - your core abstractions)
1. `el()` - 27 edges
2. `bindUi()` - 19 edges
3. `openCase()` - 16 edges
4. `mapApi()` - 15 edges
5. `pointToLayer()` - 14 edges
6. `renderChatMessages()` - 13 edges
7. `renderActiveCase()` - 12 edges
8. `fetchJson()` - 11 edges
9. `initMap()` - 11 edges
10. `applySoftCaseDetail()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `bindUi()` --indirect_call--> `resizeChatInput()`  [INFERRED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 1 → community 12_
- `applySoftCaseDetail()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 1 → community 14_
- `renderActiveCase()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 1 → community 2_
- `renderPrimaryEventCard()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 1 → community 15_
- `updateGeometryHint()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 1 → community 8_

## Import Cycles
- None detected.

## Communities (17 total, 0 thin omitted)

### Community 0 - "landing.js"
Cohesion: 0.13
Nodes (18): adjacentBaseStyle(), adjacentFeatureKey(), applyTextLabelSize(), attachSignalTapeHatching(), bindReferenceLayerPopup(), buildTextLabelIcon(), clampNumber(), createTextLabelMarker() (+10 more)

### Community 1 - "el"
Cohesion: 0.17
Nodes (19): bindAttachmentClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks(), bindMessageReplyClicks(), bindParticipantDialogs(), buildMessageThreadGroups(), closeImageLightbox(), el() (+11 more)

### Community 2 - "openCase"
Cohesion: 0.32
Nodes (14): caseChatFingerprint(), clearReplyTarget(), fetchJson(), loadBootstrap(), mapApi(), openCase(), openCreateEventFromAdjacent(), renderActiveCase() (+6 more)

### Community 3 - "svgIconUrl"
Cohesion: 0.16
Nodes (14): encodeSvgPath(), enumAnchorToFraction(), getSvgHotspots(), getSvgIndex(), hotspotBasenameFromIconUrl(), isUnknownSvgPath(), lookupSvgHotspot(), normalizeSvgLookupKey() (+6 more)

### Community 4 - "initMap"
Cohesion: 0.21
Nodes (14): fetchMapLayerFeatures(), fitTaskGuidBounds(), fitVisibleBounds(), getCookie(), hideDbLoadingModal(), initLayerPanelControls(), initMap(), loadDeferredMapLayers() (+6 more)

### Community 5 - "updateAdjacentLayers"
Cohesion: 0.21
Nodes (13): adjacentLayerForRoot(), adjacentPulsePhase(), applyAdjacentFeatureStyle(), hasAdjacentHighlightedEntries(), isAdjacentRootHighlighted(), lerpHexColor(), parseHexColor(), setAdjacentHighlightStroke() (+5 more)

### Community 6 - "pointToLayer"
Cohesion: 0.22
Nodes (13): adjacentLayerLabel(), featureTooltip(), getLayerStylesManifest(), getTableStyleDef(), invisiblePointMarker(), likeMatch(), matchFilter(), pointToLayer() (+5 more)

### Community 7 - "event_draw.js"
Cohesion: 0.45
Nodes (11): bindMapDrawEvents(), clearBrushPreview(), finishGeometry(), getMap(), initToolbar(), layerToGeoJSON(), removeBrushPreviewLayer(), startDrawer() (+3 more)

### Community 8 - "events.js"
Cohesion: 0.49
Nodes (9): addPendingMessageGeometry(), clearPendingMessageGeometry(), currentUserIsInspectorForSelected(), drawApi(), removePendingMessageGeometryAt(), setPendingMessageGeometries(), startGeometryDrawMode(), syncPendingGeometriesOnMap() (+1 more)

### Community 9 - "renderGeometries"
Cohesion: 0.20
Nodes (10): addGeometryLayer(), clearEventGeometries(), clearSavedGeometries(), eventStyle(), geometryStyle(), hashColor(), leafletPathStyle(), messageGeometryItems() (+2 more)

### Community 10 - "escapeHtml"
Cohesion: 0.36
Nodes (9): attachmentDownloadUrl(), escapeHtml(), messageGeometries(), messageHasReplyTarget(), renderAttachments(), renderMessageArticle(), renderReactionActions(), renderReactionBadges() (+1 more)

### Community 11 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 12 - "bindUi"
Cohesion: 0.54
Nodes (8): approveCase(), bindUi(), closeApproveConfirmDialog(), findCase(), openApproveConfirmDialog(), revokeCase(), setApproveConfirmMode(), userHasApproved()

### Community 13 - "applyStyleToGeometryLayer"
Cohesion: 0.40
Nodes (6): applyStyleToGeometryLayer(), clearPendingMessageGeometry(), pendingGeometryStyle(), removePendingGeometryLayer(), setPendingMessageGeometries(), setPendingMessageGeometry()

### Community 14 - "applySoftCaseDetail"
Cohesion: 0.40
Nodes (5): applySoftCaseDetail(), formatParticipants(), isChatThreadNearBottom(), renderParticipants(), updateComposerState()

### Community 15 - "renderEventNav"
Cohesion: 0.60
Nodes (5): bindEventCardClicks(), buildEventCardHtml(), renderEventNav(), renderPrimaryEventCard(), renderSecondaryList()

### Community 16 - "createSvgMarker"
Cohesion: 0.60
Nodes (5): anchorPixelsFromFractions(), applySvgMarkerSize(), buildSvgIcon(), clampFraction(), createSvgMarker()

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `el()` connect `el` to `openCase`, `events.js`, `bindUi`, `applySoftCaseDetail`, `renderEventNav`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `bindUi()` connect `bindUi` to `events.js`, `el`, `openCase`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Why does `pointToLayer()` connect `pointToLayer` to `landing.js`, `createSvgMarker`, `svgIconUrl`, `renderGeometries`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `bindUi()` (e.g. with `resizeChatInput()` and `showError()`) actually correct?**
  _`bindUi()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `landing.js` be split into smaller, more focused modules?**
  _Cohesion score 0.12666666666666668 - nodes in this community are weakly interconnected._