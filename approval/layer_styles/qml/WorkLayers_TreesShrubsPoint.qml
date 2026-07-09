<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis autoRefreshMode="Disabled" labelsEnabled="1" simplifyDrawingHints="0" symbologyReferenceScale="-1" maxScale="0" simplifyDrawingTol="1" autoRefreshTime="0" simplifyMaxScale="1" version="3.44.8-Solothurn" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyLocal="1" simplifyAlgorithm="0" minScale="100000000" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1" symbollevels="0">
    <rules key="{800674d2-9365-428c-9b12-bfc479ad1e47}">
      <rule label="Дерево" symbol="0" key="{1316a32e-8cd5-494e-bede-d96c0d69bcdf}" filter=" &quot;LifeFormType&quot; = 'tree'"/>
      <rule label="Кустарник" symbol="1" key="{001a9600-3707-46fa-9dbd-723edd3a79dc}" filter=" &quot;LifeFormType&quot; = 'bush'"/>
      <rule label="Нет данных" symbol="2" key="{14640302-7792-43c4-b954-515936a03aa9}" filter="ELSE"/>
    </rules>
    <symbols>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="0" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{6d1f99a3-088c-4f3d-9b87-fbdbf9cc1476}" locked="0" pass="0" class="SvgMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="73,183,0,255,rgb:0.2862745,0.7176471,0,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/Лиственное дерево.svg" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="1" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Дерево_Дерево одиночное.svg'" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="1" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{6d1f99a3-088c-4f3d-9b87-fbdbf9cc1476}" locked="0" pass="0" class="SvgMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="73,183,0,255,rgb:0.2862745,0.7176471,0,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/Кустарник.svg" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="1" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Кустарник_Одиночный.svg'" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="2" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{c89198e5-1e95-45fc-9bfe-9bfb051afc73}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="229,0,4,255,rgb:0.8980392,0,0.0156863,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="circle" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="2" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MM" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <data-defined-properties>
      <Option type="Map">
        <Option type="QString" value="" name="name"/>
        <Option name="properties"/>
        <Option type="QString" value="collection" name="type"/>
      </Option>
    </data-defined-properties>
  </renderer-v2>
  <selection mode="Default">
    <selectionColor invalid="1"/>
    <selectionSymbol>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{d44e4cdd-c625-4dd0-98d9-88662b2ed7cb}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="255,0,0,255,rgb:1,0,0,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="circle" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="2" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MM" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </selectionSymbol>
  </selection>
  <labeling type="simple">
    <settings calloutType="simple">
      <text-style fontUnderline="0" textColor="50,50,50,255,rgb:0.1960784,0.1960784,0.1960784,1" multilineHeight="1" forcedBold="0" fontSize="1.3999999999999999" forcedItalic="0" tabStopDistanceMapUnitScale="3x:0,0,0,0,0,0" fieldName="GreenNum" stretchFactor="100" blendMode="0" textOpacity="1" fontLetterSpacing="0" capitalization="0" fontWeight="50" fontSizeMapUnitScale="3x:0,0,0,0,0,0" tabStopDistanceUnit="Point" fontSizeUnit="MapUnit" isExpression="0" legendString="Aa" fontKerning="1" allowHtml="0" fontFamily="Sans Serif" previewBkgrdColor="255,255,255,255,rgb:1,1,1,1" textOrientation="horizontal" multilineHeightUnit="Percentage" fontItalic="0" fontWordSpacing="0" tabStopDistance="80" fontStrikeout="0" useSubstitutions="0" namedStyle="Обычный">
        <families/>
        <text-buffer bufferSizeUnits="MapUnit" bufferSize="0.10000000000000001" bufferColor="255,255,255,255,rgb:1,1,1,1" bufferSizeMapUnitScale="3x:0,0,0,0,0,0" bufferDraw="1" bufferOpacity="1" bufferNoFill="1" bufferJoinStyle="128" bufferBlendMode="0"/>
        <text-mask maskSizeUnits="MM" maskJoinStyle="128" maskEnabled="0" maskOpacity="1" maskSize2="1.5" maskSize="1.5" maskSizeMapUnitScale="3x:0,0,0,0,0,0" maskedSymbolLayers="" maskType="0"/>
        <background shapeFillColor="255,255,255,255,rgb:1,1,1,1" shapeType="0" shapeOffsetY="0" shapeOffsetUnit="Point" shapeBorderColor="128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1" shapeSizeX="0" shapeDraw="0" shapeBorderWidth="0" shapeOpacity="1" shapeRadiiY="0" shapeRotation="0" shapeBorderWidthMapUnitScale="3x:0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiUnit="Point" shapeRotationType="0" shapeBlendMode="0" shapeSizeY="0" shapeRadiiMapUnitScale="3x:0,0,0,0,0,0" shapeJoinStyle="64" shapeSVGFile="" shapeSizeUnit="Point" shapeOffsetX="0" shapeSizeType="0" shapeOffsetMapUnitScale="3x:0,0,0,0,0,0" shapeSizeMapUnitScale="3x:0,0,0,0,0,0" shapeBorderWidthUnit="Point">
          <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="markerSymbol" clip_to_extent="1" alpha="1">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer id="" locked="0" pass="0" class="SimpleMarker" enabled="1">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="square" name="cap_style"/>
                <Option type="QString" value="196,60,57,255,rgb:0.7686275,0.2352941,0.2235294,1" name="color"/>
                <Option type="QString" value="1" name="horizontal_anchor_point"/>
                <Option type="QString" value="bevel" name="joinstyle"/>
                <Option type="QString" value="circle" name="name"/>
                <Option type="QString" value="0,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MM" name="offset_unit"/>
                <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
                <Option type="QString" value="solid" name="outline_style"/>
                <Option type="QString" value="0" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MM" name="outline_width_unit"/>
                <Option type="QString" value="diameter" name="scale_method"/>
                <Option type="QString" value="2" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
                <Option type="QString" value="MM" name="size_unit"/>
                <Option type="QString" value="1" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option type="QString" value="" name="name"/>
                  <Option name="properties"/>
                  <Option type="QString" value="collection" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
          <symbol frame_rate="10" is_animated="0" force_rhr="0" type="fill" name="fillSymbol" clip_to_extent="1" alpha="1">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer id="" locked="0" pass="0" class="SimpleFill" enabled="1">
              <Option type="Map">
                <Option type="QString" value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale"/>
                <Option type="QString" value="255,255,255,255,rgb:1,1,1,1" name="color"/>
                <Option type="QString" value="bevel" name="joinstyle"/>
                <Option type="QString" value="0,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MM" name="offset_unit"/>
                <Option type="QString" value="128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1" name="outline_color"/>
                <Option type="QString" value="no" name="outline_style"/>
                <Option type="QString" value="0" name="outline_width"/>
                <Option type="QString" value="Point" name="outline_width_unit"/>
                <Option type="QString" value="solid" name="style"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option type="QString" value="" name="name"/>
                  <Option name="properties"/>
                  <Option type="QString" value="collection" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </background>
        <shadow shadowBlendMode="6" shadowRadius="1.5" shadowOffsetDist="1" shadowOffsetAngle="135" shadowOffsetMapUnitScale="3x:0,0,0,0,0,0" shadowRadiusUnit="MM" shadowUnder="0" shadowOpacity="0.69999999999999996" shadowScale="100" shadowDraw="0" shadowColor="0,0,0,255,rgb:0,0,0,1" shadowOffsetUnit="MM" shadowOffsetGlobal="1" shadowRadiusMapUnitScale="3x:0,0,0,0,0,0" shadowRadiusAlphaOnly="0"/>
        <dd_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </dd_properties>
        <substitutions/>
      </text-style>
      <text-format rightDirectionSymbol=">" addDirectionSymbol="0" formatNumbers="0" leftDirectionSymbol="&lt;" reverseDirectionSymbol="0" placeDirectionSymbol="0" autoWrapLength="0" useMaxLineLengthForAutoWrap="1" wrapChar="" multilineAlign="3" decimals="3" plussign="0"/>
      <placement dist="0" allowDegraded="0" repeatDistanceUnits="MM" lineAnchorTextPoint="FollowPlacement" rotationUnit="AngleDegrees" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" lineAnchorType="0" quadOffset="5" overrunDistanceUnit="MM" repeatDistance="0" priority="5" fitInPolygonOnly="0" layerType="PointGeometry" lineAnchorClipping="0" placement="1" maximumDistanceUnit="MM" overrunDistanceMapUnitScale="3x:0,0,0,0,0,0" maxCurvedCharAngleOut="-25" maxCurvedCharAngleIn="25" distMapUnitScale="3x:0,0,0,0,0,0" offsetUnits="MapUnit" overlapHandling="AllowOverlapAtNoCost" repeatDistanceMapUnitScale="3x:0,0,0,0,0,0" maximumDistanceMapUnitScale="3x:0,0,0,0,0,0" overrunDistance="0" preserveRotation="1" offsetType="1" xOffset="0.69999999999999996" centroidWhole="0" yOffset="0" polygonPlacementFlags="2" centroidInside="0" maximumDistance="0" lineAnchorPercent="0.5" geometryGenerator="" rotationAngle="0" geometryGeneratorEnabled="0" geometryGeneratorType="PointGeometry" placementFlags="10" distUnits="MM" prioritization="PreferCloser" labelOffsetMapUnitScale="3x:0,0,0,0,0,0"/>
      <rendering scaleVisibility="1" drawLabels="1" fontMinPixelSize="3" minFeatureSize="0" upsidedownLabels="0" fontMaxPixelSize="10000" fontLimitPixelSize="0" obstacleType="1" obstacle="1" unplacedVisibility="0" mergeLines="0" obstacleFactor="1" zIndex="0" maxNumLabels="2000" scaleMax="1000" limitNumLabels="0" scaleMin="0" labelPerPart="0"/>
      <dd_properties>
        <Option type="Map">
          <Option type="QString" value="" name="name"/>
          <Option name="properties"/>
          <Option type="QString" value="collection" name="type"/>
        </Option>
      </dd_properties>
      <callout type="simple">
        <Option type="Map">
          <Option type="QString" value="pole_of_inaccessibility" name="anchorPoint"/>
          <Option type="int" value="0" name="blendMode"/>
          <Option type="Map" name="ddProperties">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
          <Option type="bool" value="false" name="drawToAllParts"/>
          <Option type="QString" value="0" name="enabled"/>
          <Option type="QString" value="point_on_exterior" name="labelAnchorPoint"/>
          <Option type="QString" value="&lt;symbol frame_rate=&quot;10&quot; is_animated=&quot;0&quot; force_rhr=&quot;0&quot; type=&quot;line&quot; name=&quot;symbol&quot; clip_to_extent=&quot;1&quot; alpha=&quot;1&quot;>&lt;data_defined_properties>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&lt;Option name=&quot;properties&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&lt;/Option>&lt;/data_defined_properties>&lt;layer id=&quot;{a3be696f-4820-4130-b76e-6d9d83c2ed76}&quot; locked=&quot;0&quot; pass=&quot;0&quot; class=&quot;SimpleLine&quot; enabled=&quot;1&quot;>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;align_dash_pattern&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;square&quot; name=&quot;capstyle&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;5;2&quot; name=&quot;customdash&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;customdash_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;customdash_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;dash_pattern_offset&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;dash_pattern_offset_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;dash_pattern_offset_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;draw_inside_polygon&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;60,60,60,255,rgb:0.2352941,0.2352941,0.2352941,1&quot; name=&quot;line_color&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;line_style&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0.3&quot; name=&quot;line_width&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;line_width_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;offset&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;ring_filter&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;trim_distance_end&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;trim_distance_end_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;trim_distance_end_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;trim_distance_start&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;trim_distance_start_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;trim_distance_start_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;tweak_dash_pattern_on_corners&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;use_custom_dash&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;width_map_unit_scale&quot;/>&lt;/Option>&lt;data_defined_properties>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&lt;Option name=&quot;properties&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&lt;/Option>&lt;/data_defined_properties>&lt;/layer>&lt;/symbol>" name="lineSymbol"/>
          <Option type="double" value="0" name="minLength"/>
          <Option type="QString" value="3x:0,0,0,0,0,0" name="minLengthMapUnitScale"/>
          <Option type="QString" value="MM" name="minLengthUnit"/>
          <Option type="double" value="0" name="offsetFromAnchor"/>
          <Option type="QString" value="3x:0,0,0,0,0,0" name="offsetFromAnchorMapUnitScale"/>
          <Option type="QString" value="MM" name="offsetFromAnchorUnit"/>
          <Option type="double" value="0" name="offsetFromLabel"/>
          <Option type="QString" value="3x:0,0,0,0,0,0" name="offsetFromLabelMapUnitScale"/>
          <Option type="QString" value="MM" name="offsetFromLabelUnit"/>
        </Option>
      </callout>
    </settings>
  </labeling>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <fieldConfiguration>
    <field configurationFlags="NoFlag" name="fid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ObjectId">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="RootId">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="StartDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="EndDate">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd.MM.yyyy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="yyyy-MM-dd HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_format_overwrite"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlantationType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;LifeFormTypeCode&quot;  = current_value('LifeFormType') and&#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="___________________________53f2c09d_443c_4b54_837a_e41e5b09fc8c" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы насаждения" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantationType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlantType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;LifeFormTypeCode&quot;  = current_value('LifeFormType')" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_________________________1bc0b5de_c5ec_457e_9565_06bf640eec2b" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Виды растений" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="true" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="LifeFormType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_______________________________da7215fa_3c8b_4662_bd1f_429a97bbcf54" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы жизненных форм" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;LifeFormType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Age">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Diameter">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="GreenNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Height">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="SectionNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Quantity">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Distance">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="BioGgroupNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+09" name="Max"/>
            <Option type="double" value="0" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MillionTrees">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowNullState"/>
            <Option type="invalid" name="CheckedState"/>
            <Option type="int" value="0" name="TextDisplayMethod"/>
            <Option type="invalid" name="UncheckedState"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="StateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="__________________________c526af74_ea1a_4e26_a693_754f1f59f6ba" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Коды состояний" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;StateGardering&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="DetailedStateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_______________________________a1e8c1a7_55be_4328_9788_450e96d3a33e" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Уточнение состояния" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;DetailedStateGardering&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CharacteristicStateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________________266c3f18_8184_4752_8704_4715a2db50da" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Характеристика состояния" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CharacteristicStateGardering&quot;" name="LayerSource"/>
            <Option type="int" value="4" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="true" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlantServiceRecomendations">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_________________________________dc0579d2_3e41_4edf_b188_045a087a651f" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Рекомендация по уходу" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantServiceRecomendations&quot;" name="LayerSource"/>
            <Option type="int" value="2" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="true" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ValuablePlants">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="___________________________d0fc3550_8a02_4c67_a779_c3acf89c42a1" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Ценные растения" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ValuablePlants&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="FileList">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="NoCalc">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowNullState"/>
            <Option type="invalid" name="CheckedState"/>
            <Option type="int" value="0" name="TextDisplayMethod"/>
            <Option type="invalid" name="UncheckedState"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsDiffHeightMark">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowNullState"/>
            <Option type="invalid" name="CheckedState"/>
            <Option type="int" value="0" name="TextDisplayMethod"/>
            <Option type="invalid" name="UncheckedState"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentOghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentObjectId">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentRootId">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentStartDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentEndDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CreateDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CreateAuthor">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ChangeDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ChangeAuthor">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="TaskGUID">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="WoodType">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" value="deciduous" name="лиственное"/>
              </Option>
              <Option type="Map">
                <Option type="QString" value="conifer" name="хвойное"/>
              </Option>
              <Option type="Map">
                <Option type="QString" value="bush" name="кустарник"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="fid" name=""/>
    <alias index="1" field="OghObjectType" name=""/>
    <alias index="2" field="ObjectId" name=""/>
    <alias index="3" field="RootId" name="Идентификатор ОГХ (RootId)"/>
    <alias index="4" field="StartDate" name=""/>
    <alias index="5" field="EndDate" name=""/>
    <alias index="6" field="PlantationType" name="Тип насаждения"/>
    <alias index="7" field="PlantType" name="Вид растения"/>
    <alias index="8" field="LifeFormType" name="Жизненная форма"/>
    <alias index="9" field="Age" name="Возраст"/>
    <alias index="10" field="Diameter" name="Диаметр на высоте 1,3 м"/>
    <alias index="11" field="GreenNum" name="№ Растения"/>
    <alias index="12" field="Height" name="Высота"/>
    <alias index="13" field="SectionNum" name="№ Участка"/>
    <alias index="14" field="Quantity" name="Количество"/>
    <alias index="15" field="Area" name="Площадь"/>
    <alias index="16" field="Distance" name="Протяженность"/>
    <alias index="17" field="BioGgroupNum" name="Номер биогруппы"/>
    <alias index="18" field="MillionTrees" name="Акция «Миллион деревьев»"/>
    <alias index="19" field="StateGardening" name="Состояние"/>
    <alias index="20" field="DetailedStateGardening" name="Уточнение состояния"/>
    <alias index="21" field="CharacteristicStateGardening" name="Характеристика состояния"/>
    <alias index="22" field="PlantServiceRecomendations" name="Рекомендации по уходу"/>
    <alias index="23" field="ValuablePlants" name="Особо ценные"/>
    <alias index="24" field="FileList" name=""/>
    <alias index="25" field="NoCalc" name="Не учитывать"/>
    <alias index="26" field="IsDiffHeightMark" name="Разновысотные отметки"/>
    <alias index="27" field="ParentOghObjectType" name=""/>
    <alias index="28" field="ParentObjectId" name=""/>
    <alias index="29" field="ParentRootId" name=""/>
    <alias index="30" field="ParentStartDate" name=""/>
    <alias index="31" field="ParentEndDate" name=""/>
    <alias index="32" field="CreateDate" name=""/>
    <alias index="33" field="CreateAuthor" name=""/>
    <alias index="34" field="ChangeDate" name=""/>
    <alias index="35" field="ChangeAuthor" name=""/>
    <alias index="36" field="TaskGUID" name=""/>
    <alias index="37" field="WoodType" name="Порода МГГТ"/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="DefaultValue"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="EndDate" policy="DefaultValue"/>
    <policy field="PlantationType" policy="DefaultValue"/>
    <policy field="PlantType" policy="DefaultValue"/>
    <policy field="LifeFormType" policy="DefaultValue"/>
    <policy field="Age" policy="DefaultValue"/>
    <policy field="Diameter" policy="DefaultValue"/>
    <policy field="GreenNum" policy="DefaultValue"/>
    <policy field="Height" policy="DefaultValue"/>
    <policy field="SectionNum" policy="DefaultValue"/>
    <policy field="Quantity" policy="DefaultValue"/>
    <policy field="Area" policy="DefaultValue"/>
    <policy field="Distance" policy="DefaultValue"/>
    <policy field="BioGgroupNum" policy="DefaultValue"/>
    <policy field="MillionTrees" policy="DefaultValue"/>
    <policy field="StateGardening" policy="DefaultValue"/>
    <policy field="DetailedStateGardening" policy="DefaultValue"/>
    <policy field="CharacteristicStateGardening" policy="DefaultValue"/>
    <policy field="PlantServiceRecomendations" policy="DefaultValue"/>
    <policy field="ValuablePlants" policy="DefaultValue"/>
    <policy field="FileList" policy="DefaultValue"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="IsDiffHeightMark" policy="DefaultValue"/>
    <policy field="ParentOghObjectType" policy="DefaultValue"/>
    <policy field="TaskGUID" policy="DefaultValue"/>
    <policy field="WoodType" policy="DefaultValue"/>
  </splitPolicies>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="PlantationType"/>
    <default expression="" applyOnUpdate="0" field="PlantType"/>
    <default expression="" applyOnUpdate="0" field="LifeFormType"/>
    <default expression="" applyOnUpdate="0" field="Age"/>
    <default expression="" applyOnUpdate="0" field="Diameter"/>
    <default expression="" applyOnUpdate="0" field="GreenNum"/>
    <default expression="" applyOnUpdate="0" field="Height"/>
    <default expression="" applyOnUpdate="0" field="SectionNum"/>
    <default expression="" applyOnUpdate="0" field="Quantity"/>
    <default expression="" applyOnUpdate="0" field="Area"/>
    <default expression="" applyOnUpdate="0" field="Distance"/>
    <default expression="" applyOnUpdate="0" field="BioGgroupNum"/>
    <default expression="" applyOnUpdate="0" field="MillionTrees"/>
    <default expression="" applyOnUpdate="0" field="StateGardening"/>
    <default expression="" applyOnUpdate="0" field="DetailedStateGardening"/>
    <default expression="" applyOnUpdate="0" field="CharacteristicStateGardening"/>
    <default expression="" applyOnUpdate="0" field="PlantServiceRecomendations"/>
    <default expression="" applyOnUpdate="0" field="ValuablePlants"/>
    <default expression="" applyOnUpdate="0" field="FileList"/>
    <default expression="" applyOnUpdate="0" field="NoCalc"/>
    <default expression="" applyOnUpdate="0" field="IsDiffHeightMark"/>
    <default expression="" applyOnUpdate="0" field="ParentOghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ParentObjectId"/>
    <default expression="" applyOnUpdate="0" field="ParentRootId"/>
    <default expression="" applyOnUpdate="0" field="ParentStartDate"/>
    <default expression="" applyOnUpdate="0" field="ParentEndDate"/>
    <default expression="" applyOnUpdate="0" field="CreateDate"/>
    <default expression="" applyOnUpdate="0" field="CreateAuthor"/>
    <default expression="" applyOnUpdate="0" field="ChangeDate"/>
    <default expression="" applyOnUpdate="0" field="ChangeAuthor"/>
    <default expression="" applyOnUpdate="0" field="TaskGUID"/>
    <default expression="" applyOnUpdate="0" field="WoodType"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" notnull_strength="1" unique_strength="1" constraints="3" field="fid"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="OghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ObjectId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="RootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="StartDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="EndDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="PlantationType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="PlantType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="LifeFormType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Age"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Diameter"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="GreenNum"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Height"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="SectionNum"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Quantity"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Area"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Distance"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="BioGgroupNum"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MillionTrees"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="StateGardening"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="DetailedStateGardening"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CharacteristicStateGardening"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="PlantServiceRecomendations"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ValuablePlants"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="FileList"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="NoCalc"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="IsDiffHeightMark"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentOghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentObjectId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentRootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentStartDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentEndDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CreateDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CreateAuthor"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ChangeDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ChangeAuthor"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="TaskGUID"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="WoodType"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="PlantationType"/>
    <constraint desc="" exp="" field="PlantType"/>
    <constraint desc="" exp="" field="LifeFormType"/>
    <constraint desc="" exp="" field="Age"/>
    <constraint desc="" exp="" field="Diameter"/>
    <constraint desc="" exp="" field="GreenNum"/>
    <constraint desc="" exp="" field="Height"/>
    <constraint desc="" exp="" field="SectionNum"/>
    <constraint desc="" exp="" field="Quantity"/>
    <constraint desc="" exp="" field="Area"/>
    <constraint desc="" exp="" field="Distance"/>
    <constraint desc="" exp="" field="BioGgroupNum"/>
    <constraint desc="" exp="" field="MillionTrees"/>
    <constraint desc="" exp="" field="StateGardening"/>
    <constraint desc="" exp="" field="DetailedStateGardening"/>
    <constraint desc="" exp="" field="CharacteristicStateGardening"/>
    <constraint desc="" exp="" field="PlantServiceRecomendations"/>
    <constraint desc="" exp="" field="ValuablePlants"/>
    <constraint desc="" exp="" field="FileList"/>
    <constraint desc="" exp="" field="NoCalc"/>
    <constraint desc="" exp="" field="IsDiffHeightMark"/>
    <constraint desc="" exp="" field="ParentOghObjectType"/>
    <constraint desc="" exp="" field="ParentObjectId"/>
    <constraint desc="" exp="" field="ParentRootId"/>
    <constraint desc="" exp="" field="ParentStartDate"/>
    <constraint desc="" exp="" field="ParentEndDate"/>
    <constraint desc="" exp="" field="CreateDate"/>
    <constraint desc="" exp="" field="CreateAuthor"/>
    <constraint desc="" exp="" field="ChangeDate"/>
    <constraint desc="" exp="" field="ChangeAuthor"/>
    <constraint desc="" exp="" field="TaskGUID"/>
    <constraint desc="" exp="" field="WoodType"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
    geom = feature.geometry()
    control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
      <labelFont strikethrough="0" style="" underline="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" verticalStretch="0" index="3" horizontalStretch="0" name="RootId">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="5" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Назначение">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="8" horizontalStretch="0" name="LifeFormType">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="6" horizontalStretch="0" name="PlantationType">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="7" horizontalStretch="0" name="PlantType">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="26" horizontalStretch="0" name="IsDiffHeightMark">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="25" horizontalStretch="0" name="NoCalc">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="5" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Параметры">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="37" horizontalStretch="0" name="WoodType">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="10" horizontalStretch="0" name="Diameter">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="9" horizontalStretch="0" name="Age">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="12" horizontalStretch="0" name="Height">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="11" horizontalStretch="0" name="GreenNum">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="13" horizontalStretch="0" name="SectionNum">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="14" horizontalStretch="0" name="Quantity">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="15" horizontalStretch="0" name="Area">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="16" horizontalStretch="0" name="Distance">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="17" horizontalStretch="0" name="BioGgroupNum">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="18" horizontalStretch="0" name="MillionTrees">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="19" horizontalStretch="0" name="StateGardening">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="20" horizontalStretch="0" name="DetailedStateGardening">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="23" horizontalStretch="0" name="ValuablePlants">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="2" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Состояние">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="21" horizontalStretch="0" name="CharacteristicStateGardening">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="22" horizontalStretch="0" name="PlantServiceRecomendations">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" verticalStretch="0" drawLine="0" horizontalStretch="0" name="Spacer Widget">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="Age"/>
    <field editable="1" name="Area"/>
    <field editable="1" name="BioGgroupNum"/>
    <field editable="1" name="ChangeAuthor"/>
    <field editable="1" name="ChangeDate"/>
    <field editable="1" name="CharacteristicStateGardening"/>
    <field editable="1" name="CreateAuthor"/>
    <field editable="1" name="CreateDate"/>
    <field editable="1" name="DetailedStateGardening"/>
    <field editable="1" name="Diameter"/>
    <field editable="1" name="Distance"/>
    <field editable="1" name="EndDate"/>
    <field editable="1" name="FileList"/>
    <field editable="1" name="GreenNum"/>
    <field editable="1" name="Height"/>
    <field editable="1" name="IsDiffHeightMark"/>
    <field editable="1" name="LifeFormType"/>
    <field editable="1" name="MillionTrees"/>
    <field editable="1" name="NoCalc"/>
    <field editable="1" name="ObjectId"/>
    <field editable="1" name="OghObjectType"/>
    <field editable="1" name="ParentEndDate"/>
    <field editable="1" name="ParentObjectId"/>
    <field editable="1" name="ParentOghObjectType"/>
    <field editable="1" name="ParentRootId"/>
    <field editable="1" name="ParentStartDate"/>
    <field editable="1" name="PlantServiceRecomendations"/>
    <field editable="1" name="PlantType"/>
    <field editable="1" name="PlantationType"/>
    <field editable="1" name="Quantity"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="SectionNum"/>
    <field editable="1" name="StartDate"/>
    <field editable="1" name="StateGardening"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="ValuablePlants"/>
    <field editable="1" name="WoodType"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="Age"/>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="1" name="BioGgroupNum"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CharacteristicStateGardening"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="1" name="DetailedStateGardening"/>
    <field labelOnTop="1" name="Diameter"/>
    <field labelOnTop="1" name="Distance"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="0" name="FileList"/>
    <field labelOnTop="1" name="GreenNum"/>
    <field labelOnTop="1" name="Height"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="LifeFormType"/>
    <field labelOnTop="1" name="MillionTrees"/>
    <field labelOnTop="1" name="NoCalc"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="PlantServiceRecomendations"/>
    <field labelOnTop="1" name="PlantType"/>
    <field labelOnTop="1" name="PlantationType"/>
    <field labelOnTop="1" name="Quantity"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="1" name="SectionNum"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="1" name="StateGardening"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="ValuablePlants"/>
    <field labelOnTop="1" name="WoodType"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="Age"/>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="BioGgroupNum"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CharacteristicStateGardening"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="DetailedStateGardening"/>
    <field reuseLastValue="0" name="Diameter"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FileList"/>
    <field reuseLastValue="0" name="GreenNum"/>
    <field reuseLastValue="0" name="Height"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="LifeFormType"/>
    <field reuseLastValue="0" name="MillionTrees"/>
    <field reuseLastValue="0" name="NoCalc"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="PlantServiceRecomendations"/>
    <field reuseLastValue="0" name="PlantType"/>
    <field reuseLastValue="0" name="PlantationType"/>
    <field reuseLastValue="0" name="Quantity"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="SectionNum"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="StateGardening"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="ValuablePlants"/>
    <field reuseLastValue="0" name="WoodType"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
