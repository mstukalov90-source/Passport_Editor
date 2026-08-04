# Graph Report - GeoDjango/approval/static/approval  (2026-08-04)

## Corpus Check
- 5 files · ~328,347 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 237 nodes · 668 edges · 18 communities
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- landing.js
- pointToLayer
- events.js
- updateAdjacentLayers
- event_draw.js
- el
- mapApi
- initMap
- startMeasureMode
- bindEventCardClicks
- geometryLayerKey
- clearPendingMessageGeometry
- tickAdjacentHighlightPulse
- lookupSvgHotspot
- adjacentBaseKey
- svgIconUrl
- renderChatMessages
- applySoftCaseDetail

## God Nodes (most connected - your core abstractions)
1. `el()` - 33 edges
2. `bindUi()` - 21 edges
3. `mapApi()` - 18 edges
4. `openCase()` - 18 edges
5. `pointToLayer()` - 15 edges
6. `renderChatMessages()` - 14 edges
7. `fetchJson()` - 13 edges
8. `renderActiveCase()` - 13 edges
9. `initMap()` - 13 edges
10. `escapeHtml()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `bindEventCardClicks()` --indirect_call--> `showError()`  [INFERRED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 9 → community 16_
- `bindUi()` --indirect_call--> `showError()`  [INFERRED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 5 → community 16_
- `applySoftCaseDetail()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 5 → community 17_
- `bindMessageReplyClicks()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 5 → community 2_
- `bindParticipantDialogs()` --calls--> `el()`  [EXTRACTED]
  GeoDjango/approval/static/approval/js/events.js → GeoDjango/approval/static/approval/js/events.js  _Bridges community 5 → community 9_

## Import Cycles
- None detected.

## Communities (18 total, 0 thin omitted)

### Community 0 - "landing.js"
Cohesion: 0.14
Nodes (20): addGeometryLayer(), applyStyleToGeometryLayer(), applyStyleToPendingChild(), attachSignalTapeHatching(), clearEventGeometries(), clearPendingGeometryHighlight(), clearPendingMessageGeometry(), clearSavedGeometries() (+12 more)

### Community 1 - "pointToLayer"
Cohesion: 0.14
Nodes (25): anchorPixelsFromFractions(), applySvgMarkerSize(), applyTextLabelSize(), buildSvgIcon(), buildTextLabelIcon(), clampFraction(), clampNumber(), createSvgMarker() (+17 more)

### Community 2 - "events.js"
Cohesion: 0.21
Nodes (21): attachmentDownloadUrl(), bindMessageReplyClicks(), caseChatFingerprint(), currentUserIsInspectorForSelected(), escapeHtml(), formatParticipants(), isServiceMessage(), messageGeometries() (+13 more)

### Community 3 - "updateAdjacentLayers"
Cohesion: 0.13
Nodes (22): adjacentFeatureDisplayName(), adjacentLayerForRoot(), adjacentLayerKey(), applyAdjacentFeatureStyle(), bindReferenceLayerPopup(), ensureLayerGroup(), escapeHtml(), findManagedGroupContaining() (+14 more)

### Community 4 - "event_draw.js"
Cohesion: 0.33
Nodes (16): bindMapDrawEvents(), clearBrushPreview(), eventToContainerPoint(), eventToLatLng(), finishBrushStroke(), finishGeometry(), getMap(), initToolbar() (+8 more)

### Community 5 - "el"
Cohesion: 0.21
Nodes (17): bindAttachmentClicks(), bindUi(), closeApproveConfirmDialog(), closeImageLightbox(), el(), initActiveInfoDialog(), initEventsListToggle(), initMessageStatsToggle() (+9 more)

### Community 6 - "mapApi"
Cohesion: 0.37
Nodes (16): approveCase(), clearReplyTarget(), deleteCase(), deleteMessage(), fetchJson(), findCase(), loadBootstrap(), mapApi() (+8 more)

### Community 7 - "initMap"
Cohesion: 0.19
Nodes (14): fetchMapLayerFeatures(), fitTaskGuidBounds(), fitVisibleBounds(), getCookie(), getLayerStylesManifest(), hideDbLoadingModal(), initMap(), isReferenceLayerKey() (+6 more)

### Community 8 - "startMeasureMode"
Cohesion: 0.24
Nodes (12): attachMapUtilityControls(), clearMeasureGraphics(), formatMeasureMeters(), isMeasureUiTarget(), onMeasureCaptureClick(), onMeasureKeyDown(), openCurrentViewInYandexMaps(), rebuildMeasureGraphics() (+4 more)

### Community 9 - "bindEventCardClicks"
Cohesion: 0.28
Nodes (9): bindEventCardClicks(), bindParticipantDialogs(), buildEventCardHtml(), openAddParticipantDialog(), renderPrimaryEventCard(), renderSecondaryList(), setDialogError(), submitAddParticipant() (+1 more)

### Community 10 - "geometryLayerKey"
Cohesion: 0.28
Nodes (9): fitCaseGeometry(), fitGeometryLayer(), fitGeometryLayers(), fitMessageGeometry(), geometryLayerKey(), highlightCase(), highlightMessageGeometry(), isMessageLayerActive() (+1 more)

### Community 11 - "clearPendingMessageGeometry"
Cohesion: 0.46
Nodes (8): addPendingMessageGeometry(), clearPendingMessageGeometry(), drawApi(), removePendingMessageGeometryAt(), setPendingMessageGeometries(), startGeometryDrawMode(), syncPendingGeometriesOnMap(), updateGeometryHint()

### Community 12 - "tickAdjacentHighlightPulse"
Cohesion: 0.36
Nodes (8): adjacentPulsePhase(), hasAdjacentHighlightedEntries(), lerpHexColor(), parseHexColor(), startAdjacentHighlightPulse(), stopAdjacentHighlightPulse(), syncAdjacentHighlightPulse(), tickAdjacentHighlightPulse()

### Community 13 - "lookupSvgHotspot"
Cohesion: 0.25
Nodes (8): enumAnchorToFraction(), getSvgHotspots(), hotspotBasenameFromIconUrl(), likeMatch(), lookupSvgHotspot(), matchFilter(), propertyValue(), resolveIconAnchorFractions()

### Community 14 - "adjacentBaseKey"
Cohesion: 0.29
Nodes (7): adjacentBaseKey(), adjacentBaseStyle(), adjacentFeatureKey(), adjacentLayerLabel(), adjacentSourceLabel(), isAdjacentFeature(), registerAdjacentLeafletLayer()

### Community 15 - "svgIconUrl"
Cohesion: 0.33
Nodes (7): encodeSvgPath(), getSvgIndex(), isUnknownSvgPath(), normalizeSvgLookupKey(), photoFixIconUrl(), resolveSvgRelativePath(), svgIconUrl()

### Community 16 - "renderChatMessages"
Cohesion: 0.40
Nodes (6): bindMessageDeleteClicks(), bindMessageGeometryClicks(), bindMessageReactionClicks(), buildMessageThreadGroups(), renderChatMessages(), showError()

### Community 17 - "applySoftCaseDetail"
Cohesion: 0.40
Nodes (5): applySoftCaseDetail(), isChatThreadNearBottom(), softRefreshActiveCase(), startChatPolling(), stopChatPolling()

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `el()` connect `el` to `events.js`, `mapApi`, `bindEventCardClicks`, `clearPendingMessageGeometry`, `renderChatMessages`, `applySoftCaseDetail`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `bindUi()` connect `el` to `events.js`, `mapApi`, `bindEventCardClicks`, `clearPendingMessageGeometry`, `renderChatMessages`, `applySoftCaseDetail`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Why does `mapApi()` connect `mapApi` to `events.js`, `bindEventCardClicks`, `clearPendingMessageGeometry`, `renderChatMessages`, `applySoftCaseDetail`?**
  _High betweenness centrality (0.001) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `bindUi()` (e.g. with `resizeChatInput()` and `showError()`) actually correct?**
  _`bindUi()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `landing.js` be split into smaller, more focused modules?**
  _Cohesion score 0.14333333333333334 - nodes in this community are weakly interconnected._
- **Should `pointToLayer` be split into smaller, more focused modules?**
  _Cohesion score 0.14333333333333334 - nodes in this community are weakly interconnected._
- **Should `updateAdjacentLayers` be split into smaller, more focused modules?**
  _Cohesion score 0.12554112554112554 - nodes in this community are weakly interconnected._