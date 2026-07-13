<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis minScale="100000000" simplifyAlgorithm="0" autoRefreshTime="0" simplifyDrawingHints="1" version="3.44.1-Solothurn" autoRefreshMode="Disabled" labelsEnabled="0" simplifyMaxScale="1" simplifyDrawingTol="1" symbologyReferenceScale="-1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyLocal="1">
  <renderer-v2 symbollevels="0" type="RuleRenderer" forceraster="0" referencescale="-1" enableorderby="0">
    <rules key="{4f84a641-dd44-4289-9e60-febcb78959ca}">
      <rule symbol="0" filter=" &quot;fid&quot; is not null" key="{ac3549ce-a8ae-4d9b-b4da-809e914f655a}" label="Вершины" checkstate="0"/>
      <rule symbol="1" filter=" &quot;LineType&quot; = 1" key="{212ac227-683c-41f7-9686-a71d0b8ceb3e}" label="Осевая линия проезжей части"/>
      <rule symbol="2" filter=" &quot;LineType&quot; = 2" key="{f75f2210-1f54-441c-ab0d-2143f040d883}" label="Осевая разделительная линия"/>
      <rule symbol="3" filter="ELSE" key="{dbd95dd8-a695-475a-812c-d5722f086370}"/>
    </rules>
    <symbols>
      <symbol type="line" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="MarkerLine" locked="0" enabled="1" pass="1" id="{717060be-beb2-4cd1-bd53-a0638c2ebee2}">
          <Option type="Map">
            <Option type="QString" value="4" name="average_angle_length"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="average_angle_unit"/>
            <Option type="QString" value="0" name="interval"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="interval_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="interval_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="0" name="offset_along_line"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_along_line_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_along_line_unit"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="bool" value="false" name="place_on_every_part"/>
            <Option type="QString" value="LastVertex|FirstVertex|InnerVertices" name="placements"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="0" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="@0@0" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" locked="0" enabled="1" pass="0" id="{786c935c-ae96-4125-a931-059d990007bd}">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="square" name="cap_style"/>
                <Option type="QString" value="255,0,0,0,rgb:1,0,0,0" name="color"/>
                <Option type="QString" value="1" name="horizontal_anchor_point"/>
                <Option type="QString" value="miter" name="joinstyle"/>
                <Option type="QString" value="square" name="name"/>
                <Option type="QString" value="0,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,1,2.5" name="offset_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="offset_unit"/>
                <Option type="QString" value="255,0,0,255,rgb:1,0,0,1" name="outline_color"/>
                <Option type="QString" value="solid" name="outline_style"/>
                <Option type="QString" value="0.035" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,1,2.5" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="outline_width_unit"/>
                <Option type="QString" value="diameter" name="scale_method"/>
                <Option type="QString" value="0.25" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,1,2.5" name="size_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="size_unit"/>
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
        </layer>
      </symbol>
      <symbol type="line" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" enabled="1" pass="0" id="{9eeff563-0f0a-455f-b7ea-88d5d4981a81}">
          <Option type="Map">
            <Option type="QString" value="0" name="align_dash_pattern"/>
            <Option type="QString" value="square" name="capstyle"/>
            <Option type="QString" value="5;2" name="customdash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale"/>
            <Option type="QString" value="MM" name="customdash_unit"/>
            <Option type="QString" value="0" name="dash_pattern_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="dash_pattern_offset_unit"/>
            <Option type="QString" value="0" name="draw_inside_polygon"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="203,0,3,255,rgb:0.7960784,0,0.0117647,1" name="line_color"/>
            <Option type="QString" value="solid" name="line_style"/>
            <Option type="QString" value="0.25" name="line_width"/>
            <Option type="QString" value="MM" name="line_width_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="0" name="trim_distance_end"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_end_unit"/>
            <Option type="QString" value="0" name="trim_distance_start"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_start_unit"/>
            <Option type="QString" value="0" name="tweak_dash_pattern_on_corners"/>
            <Option type="QString" value="0" name="use_custom_dash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="width_map_unit_scale"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer class="LinearReferencing" locked="0" enabled="1" pass="0" id="{131d46c9-d5e8-42fe-8260-d8b242dad347}">
          <Option type="Map">
            <Option type="double" value="4" name="average_angle_length"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale"/>
            <Option type="QString" value="MM" name="average_angle_unit"/>
            <Option type="double" value="10" name="interval"/>
            <Option type="QString" value="0.80000000000000004,0.20000000000000001" name="label_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="label_offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="label_offset_unit"/>
            <Option type="QString" value="&lt;numericFormat id=&quot;basic&quot;>&#xa; &lt;Option type=&quot;Map&quot;>&#xa;  &lt;Option type=&quot;invalid&quot; name=&quot;decimal_separator&quot;/>&#xa;  &lt;Option type=&quot;int&quot; value=&quot;6&quot; name=&quot;decimals&quot;/>&#xa;  &lt;Option type=&quot;int&quot; value=&quot;0&quot; name=&quot;rounding_type&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;false&quot; name=&quot;show_plus&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;true&quot; name=&quot;show_thousand_separator&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;false&quot; name=&quot;show_trailing_zeros&quot;/>&#xa;  &lt;Option type=&quot;invalid&quot; name=&quot;thousand_separator&quot;/>&#xa; &lt;/Option>&#xa;&lt;/numericFormat>&#xa;" name="numeric_format"/>
            <Option type="QString" value="IntervalCartesian2D" name="placement"/>
            <Option type="bool" value="true" name="rotate"/>
            <Option type="bool" value="true" name="show_marker"/>
            <Option type="double" value="100" name="skip_multiples"/>
            <Option type="QString" value="CartesianDistance2D" name="source"/>
            <Option type="QString" value="&lt;text-style textOpacity=&quot;1&quot; tabStopDistanceMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; fontSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; fontWeight=&quot;75&quot; forcedItalic=&quot;0&quot; multilineHeight=&quot;1&quot; tabStopDistanceUnit=&quot;Point&quot; blendMode=&quot;0&quot; capitalization=&quot;0&quot; tabStopDistance=&quot;80&quot; fontSize=&quot;0.69999999999999996&quot; fontUnderline=&quot;0&quot; namedStyle=&quot;Bold&quot; multilineHeightUnit=&quot;Percentage&quot; fontSizeUnit=&quot;MapUnit&quot; fontLetterSpacing=&quot;0&quot; fontFamily=&quot;Liberation Sans&quot; fontWordSpacing=&quot;0&quot; textOrientation=&quot;horizontal&quot; fontStrikeout=&quot;0&quot; stretchFactor=&quot;100&quot; previewBkgrdColor=&quot;255,255,255,255,rgb:1,1,1,1&quot; textColor=&quot;212,11,11,255,hsv:0,0.94628824292362856,0.82973983367666138,1&quot; fontItalic=&quot;0&quot; allowHtml=&quot;0&quot; fontKerning=&quot;1&quot; forcedBold=&quot;0&quot;>&#xa; &lt;families/>&#xa; &lt;text-buffer bufferSizeUnits=&quot;MM&quot; bufferNoFill=&quot;1&quot; bufferDraw=&quot;0&quot; bufferSize=&quot;1&quot; bufferColor=&quot;250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1&quot; bufferJoinStyle=&quot;128&quot; bufferBlendMode=&quot;0&quot; bufferSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; bufferOpacity=&quot;1&quot;/>&#xa; &lt;text-mask maskSizeUnits=&quot;MM&quot; maskEnabled=&quot;0&quot; maskOpacity=&quot;1&quot; maskSize2=&quot;1.5&quot; maskSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; maskType=&quot;0&quot; maskSize=&quot;1.5&quot; maskedSymbolLayers=&quot;&quot; maskJoinStyle=&quot;128&quot;/>&#xa; &lt;background shapeOffsetMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeBorderWidthMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeOpacity=&quot;1&quot; shapeFillColor=&quot;255,255,255,255,rgb:1,1,1,1&quot; shapeBorderWidth=&quot;0&quot; shapeOffsetY=&quot;0&quot; shapeJoinStyle=&quot;64&quot; shapeDraw=&quot;0&quot; shapeRadiiY=&quot;0&quot; shapeBorderColor=&quot;128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1&quot; shapeRadiiMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeSVGFile=&quot;&quot; shapeOffsetX=&quot;0&quot; shapeRotationType=&quot;0&quot; shapeRadiiX=&quot;0&quot; shapeOffsetUnit=&quot;Point&quot; shapeType=&quot;0&quot; shapeSizeType=&quot;0&quot; shapeBorderWidthUnit=&quot;Point&quot; shapeSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeBlendMode=&quot;0&quot; shapeRadiiUnit=&quot;Point&quot; shapeSizeY=&quot;0&quot; shapeSizeUnit=&quot;Point&quot; shapeRotation=&quot;0&quot; shapeSizeX=&quot;0&quot;>&#xa;  &lt;symbol type=&quot;marker&quot; clip_to_extent=&quot;1&quot; is_animated=&quot;0&quot; alpha=&quot;1&quot; frame_rate=&quot;10&quot; name=&quot;markerSymbol&quot; force_rhr=&quot;0&quot;>&#xa;   &lt;data_defined_properties>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;     &lt;Option name=&quot;properties&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;    &lt;/Option>&#xa;   &lt;/data_defined_properties>&#xa;   &lt;layer class=&quot;SimpleMarker&quot; locked=&quot;0&quot; enabled=&quot;1&quot; pass=&quot;0&quot; id=&quot;&quot;>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;angle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;square&quot; name=&quot;cap_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;145,82,45,255,rgb:0.5686275,0.3215686,0.1764706,1&quot; name=&quot;color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;1&quot; name=&quot;horizontal_anchor_point&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;circle&quot; name=&quot;name&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0,0&quot; name=&quot;offset&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1&quot; name=&quot;outline_color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;outline_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;outline_width&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;outline_width_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;outline_width_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;diameter&quot; name=&quot;scale_method&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;2&quot; name=&quot;size&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;size_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;size_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;1&quot; name=&quot;vertical_anchor_point&quot;/>&#xa;    &lt;/Option>&#xa;    &lt;data_defined_properties>&#xa;     &lt;Option type=&quot;Map&quot;>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;      &lt;Option name=&quot;properties&quot;/>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;     &lt;/Option>&#xa;    &lt;/data_defined_properties>&#xa;   &lt;/layer>&#xa;  &lt;/symbol>&#xa;  &lt;symbol type=&quot;fill&quot; clip_to_extent=&quot;1&quot; is_animated=&quot;0&quot; alpha=&quot;1&quot; frame_rate=&quot;10&quot; name=&quot;fillSymbol&quot; force_rhr=&quot;0&quot;>&#xa;   &lt;data_defined_properties>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;     &lt;Option name=&quot;properties&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;    &lt;/Option>&#xa;   &lt;/data_defined_properties>&#xa;   &lt;layer class=&quot;SimpleFill&quot; locked=&quot;0&quot; enabled=&quot;1&quot; pass=&quot;0&quot; id=&quot;&quot;>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;border_width_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;255,255,255,255,rgb:1,1,1,1&quot; name=&quot;color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0,0&quot; name=&quot;offset&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1&quot; name=&quot;outline_color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;no&quot; name=&quot;outline_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;outline_width&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;Point&quot; name=&quot;outline_width_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;style&quot;/>&#xa;    &lt;/Option>&#xa;    &lt;data_defined_properties>&#xa;     &lt;Option type=&quot;Map&quot;>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;      &lt;Option name=&quot;properties&quot;/>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;     &lt;/Option>&#xa;    &lt;/data_defined_properties>&#xa;   &lt;/layer>&#xa;  &lt;/symbol>&#xa; &lt;/background>&#xa; &lt;shadow shadowRadius=&quot;1.5&quot; shadowRadiusAlphaOnly=&quot;0&quot; shadowRadiusUnit=&quot;MM&quot; shadowOpacity=&quot;0.69999999999999996&quot; shadowScale=&quot;100&quot; shadowBlendMode=&quot;6&quot; shadowOffsetGlobal=&quot;1&quot; shadowRadiusMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shadowDraw=&quot;0&quot; shadowOffsetUnit=&quot;MM&quot; shadowColor=&quot;0,0,0,255,rgb:0,0,0,1&quot; shadowOffsetAngle=&quot;135&quot; shadowOffsetMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shadowUnder=&quot;0&quot; shadowOffsetDist=&quot;1&quot;/>&#xa; &lt;dd_properties>&#xa;  &lt;Option type=&quot;Map&quot;>&#xa;   &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;   &lt;Option name=&quot;properties&quot;/>&#xa;   &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;  &lt;/Option>&#xa; &lt;/dd_properties>&#xa;&lt;/text-style>&#xa;" name="text_format"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="@1@1" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" locked="0" enabled="1" pass="0" id="{b0d164df-3e68-4d2c-a88e-c8425aff80d5}">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="square" name="cap_style"/>
                <Option type="QString" value="255,0,0,255,rgb:1,0,0,1" name="color"/>
                <Option type="QString" value="1" name="horizontal_anchor_point"/>
                <Option type="QString" value="bevel" name="joinstyle"/>
                <Option type="QString" value="line" name="name"/>
                <Option type="QString" value="0,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="offset_unit"/>
                <Option type="QString" value="212,11,11,255,hsv:0,0.94628824292362856,0.82973983367666138,1" name="outline_color"/>
                <Option type="QString" value="solid" name="outline_style"/>
                <Option type="QString" value="0.46" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MM" name="outline_width_unit"/>
                <Option type="QString" value="diameter" name="scale_method"/>
                <Option type="QString" value="1" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="size_unit"/>
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
        </layer>
        <layer class="LinearReferencing" locked="0" enabled="1" pass="0" id="{226ea7f4-2018-4498-be69-642ebe6c897a}">
          <Option type="Map">
            <Option type="double" value="4" name="average_angle_length"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale"/>
            <Option type="QString" value="MM" name="average_angle_unit"/>
            <Option type="double" value="100" name="interval"/>
            <Option type="QString" value="3,0.40000000000000002" name="label_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="label_offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="label_offset_unit"/>
            <Option type="QString" value="&lt;numericFormat id=&quot;basic&quot;>&#xa; &lt;Option type=&quot;Map&quot;>&#xa;  &lt;Option type=&quot;invalid&quot; name=&quot;decimal_separator&quot;/>&#xa;  &lt;Option type=&quot;int&quot; value=&quot;0&quot; name=&quot;decimals&quot;/>&#xa;  &lt;Option type=&quot;int&quot; value=&quot;0&quot; name=&quot;rounding_type&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;false&quot; name=&quot;show_plus&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;false&quot; name=&quot;show_thousand_separator&quot;/>&#xa;  &lt;Option type=&quot;bool&quot; value=&quot;false&quot; name=&quot;show_trailing_zeros&quot;/>&#xa;  &lt;Option type=&quot;invalid&quot; name=&quot;thousand_separator&quot;/>&#xa; &lt;/Option>&#xa;&lt;/numericFormat>&#xa;" name="numeric_format"/>
            <Option type="QString" value="IntervalCartesian2D" name="placement"/>
            <Option type="bool" value="true" name="rotate"/>
            <Option type="bool" value="true" name="show_marker"/>
            <Option type="double" value="0" name="skip_multiples"/>
            <Option type="QString" value="CartesianDistance2D" name="source"/>
            <Option type="QString" value="&lt;text-style textOpacity=&quot;1&quot; tabStopDistanceMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; fontSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; fontWeight=&quot;75&quot; forcedItalic=&quot;0&quot; multilineHeight=&quot;1&quot; tabStopDistanceUnit=&quot;Point&quot; blendMode=&quot;0&quot; capitalization=&quot;0&quot; tabStopDistance=&quot;80&quot; fontSize=&quot;1&quot; fontUnderline=&quot;0&quot; namedStyle=&quot;Bold&quot; multilineHeightUnit=&quot;Percentage&quot; fontSizeUnit=&quot;MapUnit&quot; fontLetterSpacing=&quot;0&quot; fontFamily=&quot;Liberation Sans&quot; fontWordSpacing=&quot;0&quot; textOrientation=&quot;horizontal&quot; fontStrikeout=&quot;0&quot; stretchFactor=&quot;100&quot; previewBkgrdColor=&quot;255,255,255,255,rgb:1,1,1,1&quot; textColor=&quot;212,11,11,255,hsv:0,0.94628824292362856,0.82973983367666138,1&quot; fontItalic=&quot;0&quot; allowHtml=&quot;0&quot; fontKerning=&quot;1&quot; forcedBold=&quot;0&quot;>&#xa; &lt;families/>&#xa; &lt;text-buffer bufferSizeUnits=&quot;MM&quot; bufferNoFill=&quot;1&quot; bufferDraw=&quot;0&quot; bufferSize=&quot;1&quot; bufferColor=&quot;250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1&quot; bufferJoinStyle=&quot;128&quot; bufferBlendMode=&quot;0&quot; bufferSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; bufferOpacity=&quot;1&quot;/>&#xa; &lt;text-mask maskSizeUnits=&quot;MM&quot; maskEnabled=&quot;0&quot; maskOpacity=&quot;1&quot; maskSize2=&quot;1.5&quot; maskSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; maskType=&quot;0&quot; maskSize=&quot;1.5&quot; maskedSymbolLayers=&quot;&quot; maskJoinStyle=&quot;128&quot;/>&#xa; &lt;background shapeOffsetMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeBorderWidthMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeOpacity=&quot;1&quot; shapeFillColor=&quot;255,255,255,255,rgb:1,1,1,1&quot; shapeBorderWidth=&quot;0&quot; shapeOffsetY=&quot;0&quot; shapeJoinStyle=&quot;64&quot; shapeDraw=&quot;0&quot; shapeRadiiY=&quot;0&quot; shapeBorderColor=&quot;128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1&quot; shapeRadiiMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeSVGFile=&quot;&quot; shapeOffsetX=&quot;0&quot; shapeRotationType=&quot;0&quot; shapeRadiiX=&quot;0&quot; shapeOffsetUnit=&quot;Point&quot; shapeType=&quot;0&quot; shapeSizeType=&quot;0&quot; shapeBorderWidthUnit=&quot;Point&quot; shapeSizeMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shapeBlendMode=&quot;0&quot; shapeRadiiUnit=&quot;Point&quot; shapeSizeY=&quot;0&quot; shapeSizeUnit=&quot;Point&quot; shapeRotation=&quot;0&quot; shapeSizeX=&quot;0&quot;>&#xa;  &lt;symbol type=&quot;marker&quot; clip_to_extent=&quot;1&quot; is_animated=&quot;0&quot; alpha=&quot;1&quot; frame_rate=&quot;10&quot; name=&quot;markerSymbol&quot; force_rhr=&quot;0&quot;>&#xa;   &lt;data_defined_properties>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;     &lt;Option name=&quot;properties&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;    &lt;/Option>&#xa;   &lt;/data_defined_properties>&#xa;   &lt;layer class=&quot;SimpleMarker&quot; locked=&quot;0&quot; enabled=&quot;1&quot; pass=&quot;0&quot; id=&quot;&quot;>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;angle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;square&quot; name=&quot;cap_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;145,82,45,255,rgb:0.5686275,0.3215686,0.1764706,1&quot; name=&quot;color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;1&quot; name=&quot;horizontal_anchor_point&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;circle&quot; name=&quot;name&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0,0&quot; name=&quot;offset&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1&quot; name=&quot;outline_color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;outline_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;outline_width&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;outline_width_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;outline_width_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;diameter&quot; name=&quot;scale_method&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;2&quot; name=&quot;size&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;size_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;size_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;1&quot; name=&quot;vertical_anchor_point&quot;/>&#xa;    &lt;/Option>&#xa;    &lt;data_defined_properties>&#xa;     &lt;Option type=&quot;Map&quot;>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;      &lt;Option name=&quot;properties&quot;/>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;     &lt;/Option>&#xa;    &lt;/data_defined_properties>&#xa;   &lt;/layer>&#xa;  &lt;/symbol>&#xa;  &lt;symbol type=&quot;fill&quot; clip_to_extent=&quot;1&quot; is_animated=&quot;0&quot; alpha=&quot;1&quot; frame_rate=&quot;10&quot; name=&quot;fillSymbol&quot; force_rhr=&quot;0&quot;>&#xa;   &lt;data_defined_properties>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;     &lt;Option name=&quot;properties&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;    &lt;/Option>&#xa;   &lt;/data_defined_properties>&#xa;   &lt;layer class=&quot;SimpleFill&quot; locked=&quot;0&quot; enabled=&quot;1&quot; pass=&quot;0&quot; id=&quot;&quot;>&#xa;    &lt;Option type=&quot;Map&quot;>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;border_width_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;255,255,255,255,rgb:1,1,1,1&quot; name=&quot;color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0,0&quot; name=&quot;offset&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1&quot; name=&quot;outline_color&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;no&quot; name=&quot;outline_style&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;outline_width&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;Point&quot; name=&quot;outline_width_unit&quot;/>&#xa;     &lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;style&quot;/>&#xa;    &lt;/Option>&#xa;    &lt;data_defined_properties>&#xa;     &lt;Option type=&quot;Map&quot;>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;      &lt;Option name=&quot;properties&quot;/>&#xa;      &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;     &lt;/Option>&#xa;    &lt;/data_defined_properties>&#xa;   &lt;/layer>&#xa;  &lt;/symbol>&#xa; &lt;/background>&#xa; &lt;shadow shadowRadius=&quot;1.5&quot; shadowRadiusAlphaOnly=&quot;0&quot; shadowRadiusUnit=&quot;MM&quot; shadowOpacity=&quot;0.69999999999999996&quot; shadowScale=&quot;100&quot; shadowBlendMode=&quot;6&quot; shadowOffsetGlobal=&quot;1&quot; shadowRadiusMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shadowDraw=&quot;0&quot; shadowOffsetUnit=&quot;MM&quot; shadowColor=&quot;0,0,0,255,rgb:0,0,0,1&quot; shadowOffsetAngle=&quot;135&quot; shadowOffsetMapUnitScale=&quot;3x:0,0,0,0,0,0&quot; shadowUnder=&quot;0&quot; shadowOffsetDist=&quot;1&quot;/>&#xa; &lt;dd_properties>&#xa;  &lt;Option type=&quot;Map&quot;>&#xa;   &lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&#xa;   &lt;Option name=&quot;properties&quot;/>&#xa;   &lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&#xa;  &lt;/Option>&#xa; &lt;/dd_properties>&#xa;&lt;/text-style>&#xa;" name="text_format"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="@1@2" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" locked="0" enabled="1" pass="0" id="{ee840776-6e84-4afb-8845-30c72baf6e5a}">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="square" name="cap_style"/>
                <Option type="QString" value="255,0,0,255,rgb:1,0,0,1" name="color"/>
                <Option type="QString" value="1" name="horizontal_anchor_point"/>
                <Option type="QString" value="bevel" name="joinstyle"/>
                <Option type="QString" value="line" name="name"/>
                <Option type="QString" value="0,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="offset_unit"/>
                <Option type="QString" value="212,11,11,255,hsv:0,0.94628824292362856,0.82973983367666138,1" name="outline_color"/>
                <Option type="QString" value="solid" name="outline_style"/>
                <Option type="QString" value="0.66" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MM" name="outline_width_unit"/>
                <Option type="QString" value="diameter" name="scale_method"/>
                <Option type="QString" value="5" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="size_unit"/>
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
        </layer>
        <layer class="MarkerLine" locked="0" enabled="1" pass="0" id="{76b6e21e-36b6-41c1-9885-9058e2196956}">
          <Option type="Map">
            <Option type="QString" value="4" name="average_angle_length"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale"/>
            <Option type="QString" value="MM" name="average_angle_unit"/>
            <Option type="QString" value="3" name="interval"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="interval_map_unit_scale"/>
            <Option type="QString" value="MM" name="interval_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="0" name="offset_along_line"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_along_line_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_along_line_unit"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="bool" value="true" name="place_on_every_part"/>
            <Option type="QString" value="LastVertex" name="placements"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="1" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="@1@3" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="FontMarker" locked="0" enabled="1" pass="0" id="{936a67e3-c5ce-4c5c-bea6-0b4eab6db1f5}">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="A" name="chr"/>
                <Option type="QString" value="212,11,11,255,rgb:0.8313725,0.0431373,0.0431373,1" name="color"/>
                <Option type="QString" value="Liberation Sans" name="font"/>
                <Option type="QString" value="Bold" name="font_style"/>
                <Option type="QString" value="0" name="horizontal_anchor_point"/>
                <Option type="QString" value="round" name="joinstyle"/>
                <Option type="QString" value="1.5,0" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="offset_unit"/>
                <Option type="QString" value="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1" name="outline_color"/>
                <Option type="QString" value="0" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MM" name="outline_width_unit"/>
                <Option type="QString" value="1" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="size_unit"/>
                <Option type="QString" value="1" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option type="QString" value="" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="char">
                      <Option type="bool" value="true" name="active"/>
                      <Option type="QString" value="round($length, 2)" name="expression"/>
                      <Option type="int" value="3" name="type"/>
                    </Option>
                  </Option>
                  <Option type="QString" value="collection" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
        <layer class="MarkerLine" locked="0" enabled="1" pass="0" id="{36fef4ce-2948-461a-b97a-b595b9159528}">
          <Option type="Map">
            <Option type="QString" value="4" name="average_angle_length"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale"/>
            <Option type="QString" value="MM" name="average_angle_unit"/>
            <Option type="QString" value="200" name="interval"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="interval_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="interval_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="0" name="offset_along_line"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_along_line_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_along_line_unit"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="bool" value="true" name="place_on_every_part"/>
            <Option type="QString" value="Interval" name="placements"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="1" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option name="properties"/>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="@1@4" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="FontMarker" locked="0" enabled="1" pass="0" id="{57623b19-9bad-4abb-b204-bf3adad0723b}">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="A" name="chr"/>
                <Option type="QString" value="186,0,0,255,rgb:0.7294118,0,0,1" name="color"/>
                <Option type="QString" value="Times New Roman" name="font"/>
                <Option type="QString" value="Обычный" name="font_style"/>
                <Option type="QString" value="1" name="horizontal_anchor_point"/>
                <Option type="QString" value="bevel" name="joinstyle"/>
                <Option type="QString" value="1.60000000000000009,-0.69999999999999996" name="offset"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="offset_unit"/>
                <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
                <Option type="QString" value="0" name="outline_width"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
                <Option type="QString" value="MM" name="outline_width_unit"/>
                <Option type="QString" value="1" name="size"/>
                <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
                <Option type="QString" value="MapUnit" name="size_unit"/>
                <Option type="QString" value="1" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option type="QString" value="" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="char">
                      <Option type="bool" value="true" name="active"/>
                      <Option type="QString" value="'Ось ' + &quot;AxisName&quot;" name="expression"/>
                      <Option type="int" value="3" name="type"/>
                    </Option>
                  </Option>
                  <Option type="QString" value="collection" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
      <symbol type="line" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="2" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" enabled="1" pass="0" id="{116b8946-321b-4518-a53f-d19ef360e27c}">
          <Option type="Map">
            <Option type="QString" value="0" name="align_dash_pattern"/>
            <Option type="QString" value="square" name="capstyle"/>
            <Option type="QString" value="5;5" name="customdash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="customdash_unit"/>
            <Option type="QString" value="0" name="dash_pattern_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="dash_pattern_offset_unit"/>
            <Option type="QString" value="0" name="draw_inside_polygon"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="237,237,237,255,hsv:0,0,0.9297474631876097,1" name="line_color"/>
            <Option type="QString" value="solid" name="line_style"/>
            <Option type="QString" value="0.3" name="line_width"/>
            <Option type="QString" value="MapUnit" name="line_width_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="0" name="trim_distance_end"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="trim_distance_end_unit"/>
            <Option type="QString" value="0" name="trim_distance_start"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="trim_distance_start_unit"/>
            <Option type="QString" value="0" name="tweak_dash_pattern_on_corners"/>
            <Option type="QString" value="0" name="use_custom_dash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="width_map_unit_scale"/>
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
      <symbol type="line" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="3" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" enabled="1" pass="0" id="{9eeff563-0f0a-455f-b7ea-88d5d4981a81}">
          <Option type="Map">
            <Option type="QString" value="0" name="align_dash_pattern"/>
            <Option type="QString" value="square" name="capstyle"/>
            <Option type="QString" value="5;2" name="customdash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale"/>
            <Option type="QString" value="MM" name="customdash_unit"/>
            <Option type="QString" value="0" name="dash_pattern_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="dash_pattern_offset_unit"/>
            <Option type="QString" value="0" name="draw_inside_polygon"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="203,203,203,255,rgb:0.7960784,0.7960784,0.7960784,1" name="line_color"/>
            <Option type="QString" value="solid" name="line_style"/>
            <Option type="QString" value="0.66" name="line_width"/>
            <Option type="QString" value="MM" name="line_width_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="0" name="trim_distance_end"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_end_unit"/>
            <Option type="QString" value="0" name="trim_distance_start"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_start_unit"/>
            <Option type="QString" value="0" name="tweak_dash_pattern_on_corners"/>
            <Option type="QString" value="0" name="use_custom_dash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="width_map_unit_scale"/>
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
      <symbol type="line" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" enabled="1" pass="0" id="{b0da3a08-d15d-47e6-87f1-f1a96ca035db}">
          <Option type="Map">
            <Option type="QString" value="0" name="align_dash_pattern"/>
            <Option type="QString" value="square" name="capstyle"/>
            <Option type="QString" value="5;2" name="customdash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale"/>
            <Option type="QString" value="MM" name="customdash_unit"/>
            <Option type="QString" value="0" name="dash_pattern_offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="dash_pattern_offset_unit"/>
            <Option type="QString" value="0" name="draw_inside_polygon"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="line_color"/>
            <Option type="QString" value="solid" name="line_style"/>
            <Option type="QString" value="0.26" name="line_width"/>
            <Option type="QString" value="MM" name="line_width_unit"/>
            <Option type="QString" value="0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="0" name="ring_filter"/>
            <Option type="QString" value="0" name="trim_distance_end"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_end_unit"/>
            <Option type="QString" value="0" name="trim_distance_start"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale"/>
            <Option type="QString" value="MM" name="trim_distance_start_unit"/>
            <Option type="QString" value="0" name="tweak_dash_pattern_on_corners"/>
            <Option type="QString" value="0" name="use_custom_dash"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="width_map_unit_scale"/>
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
      <text-style textOpacity="1" tabStopDistanceMapUnitScale="3x:0,0,0,0,0,0" fontSizeMapUnitScale="3x:0,0,0,0,0,0" fieldName="'Ось ' + &quot;AxisName&quot;" fontWeight="50" forcedItalic="0" multilineHeight="1" tabStopDistanceUnit="Point" blendMode="0" capitalization="0" tabStopDistance="80" fontSize="1" fontUnderline="0" namedStyle="???????" multilineHeightUnit="Percentage" fontSizeUnit="MapUnit" fontLetterSpacing="0" fontFamily="Times New Roman" fontWordSpacing="0" useSubstitutions="0" textOrientation="horizontal" fontStrikeout="0" stretchFactor="100" isExpression="1" previewBkgrdColor="255,255,255,255,rgb:1,1,1,1" legendString="Aa" textColor="186,0,0,255,hsv:0,1,0.73011367971313035,1" fontItalic="0" allowHtml="0" fontKerning="1" forcedBold="0">
        <families/>
        <text-buffer bufferSizeUnits="MM" bufferNoFill="1" bufferDraw="0" bufferSize="1" bufferColor="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1" bufferJoinStyle="128" bufferBlendMode="0" bufferSizeMapUnitScale="3x:0,0,0,0,0,0" bufferOpacity="1"/>
        <text-mask maskSizeUnits="MM" maskEnabled="0" maskOpacity="1" maskSize2="1.5" maskSizeMapUnitScale="3x:0,0,0,0,0,0" maskType="0" maskSize="1.5" maskedSymbolLayers="" maskJoinStyle="128"/>
        <background shapeOffsetMapUnitScale="3x:0,0,0,0,0,0" shapeBorderWidthMapUnitScale="3x:0,0,0,0,0,0" shapeOpacity="1" shapeFillColor="255,255,255,255,rgb:1,1,1,1" shapeBorderWidth="0" shapeOffsetY="0" shapeJoinStyle="64" shapeDraw="0" shapeRadiiY="0" shapeBorderColor="128,128,128,255,rgb:0.5019608,0.5019608,0.5019608,1" shapeRadiiMapUnitScale="3x:0,0,0,0,0,0" shapeSVGFile="" shapeOffsetX="0" shapeRotationType="0" shapeRadiiX="0" shapeOffsetUnit="Point" shapeType="0" shapeSizeType="0" shapeBorderWidthUnit="Point" shapeSizeMapUnitScale="3x:0,0,0,0,0,0" shapeBlendMode="0" shapeRadiiUnit="Point" shapeSizeY="0" shapeSizeUnit="Point" shapeRotation="0" shapeSizeX="0">
          <symbol type="marker" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="markerSymbol" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" locked="0" enabled="1" pass="0" id="">
              <Option type="Map">
                <Option type="QString" value="0" name="angle"/>
                <Option type="QString" value="square" name="cap_style"/>
                <Option type="QString" value="255,158,23,255,rgb:1,0.6196078,0.0901961,1" name="color"/>
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
          <symbol type="fill" clip_to_extent="1" is_animated="0" alpha="1" frame_rate="10" name="fillSymbol" force_rhr="0">
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" value="" name="name"/>
                <Option name="properties"/>
                <Option type="QString" value="collection" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleFill" locked="0" enabled="1" pass="0" id="">
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
        <shadow shadowRadius="1.5" shadowRadiusAlphaOnly="0" shadowRadiusUnit="MM" shadowOpacity="0.69999999999999996" shadowScale="100" shadowBlendMode="6" shadowOffsetGlobal="1" shadowRadiusMapUnitScale="3x:0,0,0,0,0,0" shadowDraw="0" shadowOffsetUnit="MM" shadowColor="0,0,0,255,rgb:0,0,0,1" shadowOffsetAngle="135" shadowOffsetMapUnitScale="3x:0,0,0,0,0,0" shadowUnder="0" shadowOffsetDist="1"/>
        <dd_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </dd_properties>
        <substitutions/>
      </text-style>
      <text-format wrapChar="" reverseDirectionSymbol="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" rightDirectionSymbol=">" useMaxLineLengthForAutoWrap="1" plussign="0" placeDirectionSymbol="0" multilineAlign="0" autoWrapLength="0"/>
      <placement geometryGenerator="collect_geometries( array_foreach( generate_series(0, length($geometry), 100), line_interpolate_point( $geometry, @element)))" yOffset="0" repeatDistanceMapUnitScale="3x:0,0,0,0,0,0" dist="0" maximumDistance="0" distUnits="MM" allowDegraded="0" placement="2" centroidWhole="0" xOffset="0" priority="5" repeatDistanceUnits="MapUnit" maxCurvedCharAngleIn="25" maxCurvedCharAngleOut="-25" lineAnchorClipping="1" overrunDistanceMapUnitScale="3x:0,0,0,0,0,0" prioritization="PreferCloser" placementFlags="10" repeatDistance="180" quadOffset="4" labelOffsetMapUnitScale="3x:0,0,0,0,0,0" lineAnchorType="1" overlapHandling="AllowOverlapAtNoCost" maximumDistanceUnit="MM" overrunDistanceUnit="MM" offsetUnits="MM" rotationUnit="AngleDegrees" overrunDistance="0" offsetType="0" distMapUnitScale="3x:0,0,0,0,0,0" geometryGeneratorEnabled="0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" centroidInside="0" geometryGeneratorType="PointGeometry" lineAnchorPercent="0" layerType="LineGeometry" polygonPlacementFlags="2" fitInPolygonOnly="0" maximumDistanceMapUnitScale="3x:0,0,0,0,0,0" lineAnchorTextPoint="CenterOfText" rotationAngle="0" preserveRotation="0"/>
      <rendering minFeatureSize="0" fontMinPixelSize="3" obstacle="1" scaleMax="0" maxNumLabels="2000" mergeLines="0" fontLimitPixelSize="0" drawLabels="1" limitNumLabels="0" zIndex="0" fontMaxPixelSize="10000" obstacleFactor="1" labelPerPart="0" upsidedownLabels="0" scaleVisibility="0" obstacleType="1" unplacedVisibility="0" scaleMin="0"/>
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
          <Option type="QString" value="&lt;symbol type=&quot;line&quot; clip_to_extent=&quot;1&quot; is_animated=&quot;0&quot; alpha=&quot;1&quot; frame_rate=&quot;10&quot; name=&quot;symbol&quot; force_rhr=&quot;0&quot;>&lt;data_defined_properties>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&lt;Option name=&quot;properties&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&lt;/Option>&lt;/data_defined_properties>&lt;layer class=&quot;SimpleLine&quot; locked=&quot;0&quot; enabled=&quot;1&quot; pass=&quot;0&quot; id=&quot;{f6d317bd-d699-4776-b4d6-5226d4e7c6d2}&quot;>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;align_dash_pattern&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;square&quot; name=&quot;capstyle&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;5;2&quot; name=&quot;customdash&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;customdash_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;customdash_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;dash_pattern_offset&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;dash_pattern_offset_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;dash_pattern_offset_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;draw_inside_polygon&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;bevel&quot; name=&quot;joinstyle&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;60,60,60,255,rgb:0.2352941,0.2352941,0.2352941,1&quot; name=&quot;line_color&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;solid&quot; name=&quot;line_style&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0.3&quot; name=&quot;line_width&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;line_width_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;offset&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;offset_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;offset_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;ring_filter&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;trim_distance_end&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;trim_distance_end_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;trim_distance_end_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;trim_distance_start&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;trim_distance_start_map_unit_scale&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;MM&quot; name=&quot;trim_distance_start_unit&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;tweak_dash_pattern_on_corners&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;0&quot; name=&quot;use_custom_dash&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;3x:0,0,0,0,0,0&quot; name=&quot;width_map_unit_scale&quot;/>&lt;/Option>&lt;data_defined_properties>&lt;Option type=&quot;Map&quot;>&lt;Option type=&quot;QString&quot; value=&quot;&quot; name=&quot;name&quot;/>&lt;Option name=&quot;properties&quot;/>&lt;Option type=&quot;QString&quot; value=&quot;collection&quot; name=&quot;type&quot;/>&lt;/Option>&lt;/data_defined_properties>&lt;/layer>&lt;/symbol>" name="lineSymbol"/>
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
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <fieldConfiguration>
    <field name="fid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="LineType" configurationFlags="NoFlag">
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
            <Option type="QString" value="Id" name="Key"/>
            <Option type="QString" value="_________________________________58888a36_d8b1_480c_b550_c07b156537b8" name="Layer"/>
            <Option type="QString" value="Справочник (ОДХ) Типы осевых линий ОДХ" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;AxialLineTypes&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="AxisName" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="CreateDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="CreateAuthor" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ChangeDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ChangeAuthor" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="TaskGUID" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="IsDiffHeightMark" configurationFlags="NoFlag">
      <editWidget type="CheckBox">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" index="0" name=""/>
    <alias field="LineType" index="1" name="Тип осевой линии"/>
    <alias field="AxisName" index="2" name="Название оси"/>
    <alias field="CreateDate" index="3" name=""/>
    <alias field="CreateAuthor" index="4" name=""/>
    <alias field="ChangeDate" index="5" name=""/>
    <alias field="ChangeAuthor" index="6" name=""/>
    <alias field="TaskGUID" index="7" name=""/>
    <alias field="IsDiffHeightMark" index="8" name=""/>
  </aliases>
  <defaults>
    <default field="fid" applyOnUpdate="0" expression=""/>
    <default field="LineType" applyOnUpdate="0" expression="1"/>
    <default field="AxisName" applyOnUpdate="0" expression="'А'"/>
    <default field="CreateDate" applyOnUpdate="0" expression=""/>
    <default field="CreateAuthor" applyOnUpdate="0" expression=""/>
    <default field="ChangeDate" applyOnUpdate="0" expression=""/>
    <default field="ChangeAuthor" applyOnUpdate="0" expression=""/>
    <default field="TaskGUID" applyOnUpdate="0" expression=""/>
    <default field="IsDiffHeightMark" applyOnUpdate="0" expression=""/>
  </defaults>
  <constraints>
    <constraint field="fid" constraints="3" exp_strength="0" unique_strength="1" notnull_strength="1"/>
    <constraint field="LineType" constraints="1" exp_strength="0" unique_strength="0" notnull_strength="1"/>
    <constraint field="AxisName" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="CreateDate" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="CreateAuthor" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="ChangeDate" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="ChangeAuthor" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="TaskGUID" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint field="IsDiffHeightMark" constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" desc="" exp=""/>
    <constraint field="LineType" desc="" exp=""/>
    <constraint field="AxisName" desc="" exp=""/>
    <constraint field="CreateDate" desc="" exp=""/>
    <constraint field="CreateAuthor" desc="" exp=""/>
    <constraint field="ChangeDate" desc="" exp=""/>
    <constraint field="ChangeAuthor" desc="" exp=""/>
    <constraint field="TaskGUID" desc="" exp=""/>
    <constraint field="IsDiffHeightMark" desc="" exp=""/>
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
  <featformsuppress>2</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
      <labelFont bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" style="" underline="0" strikethrough="0"/>
    </labelStyle>
    <attributeEditorField verticalStretch="0" showLabel="1" horizontalStretch="0" index="1" name="LineType">
      <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
        <labelFont bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" style="" underline="0" strikethrough="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorField verticalStretch="0" showLabel="1" horizontalStretch="0" index="2" name="AxisName">
      <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
        <labelFont bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" style="" underline="0" strikethrough="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorSpacerElement verticalStretch="0" showLabel="0" horizontalStretch="0" name="SpacerWidget" drawLine="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" style="" underline="0" strikethrough="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="AxisName"/>
    <field editable="1" name="ChangeAuthor"/>
    <field editable="1" name="ChangeDate"/>
    <field editable="1" name="CreateAuthor"/>
    <field editable="1" name="CreateDate"/>
    <field editable="1" name="IsDiffHeightMark"/>
    <field editable="1" name="LineType"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="AxisName"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="0" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="LineType"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="AxisName"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="LineType"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
