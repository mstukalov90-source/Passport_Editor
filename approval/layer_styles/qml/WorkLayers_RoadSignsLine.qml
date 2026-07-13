<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.44.1-Solothurn" simplifyDrawingHints="1" simplifyAlgorithm="0" autoRefreshTime="0" autoRefreshMode="Disabled" hasScaleBasedVisibilityFlag="0" minScale="100000000" labelsEnabled="0" simplifyDrawingTol="1" simplifyMaxScale="1" symbologyReferenceScale="-1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" maxScale="0" simplifyLocal="1">
  <renderer-v2 referencescale="-1" enableorderby="0" symbollevels="1" type="RuleRenderer" forceraster="0">
    <rules key="{54b3236b-2956-4ff8-ba16-4f3accca34e5}">
      <rule key="{5e120ec3-3d39-443f-b6c0-854d11913fc2}" filter=" &quot;fid&quot; is not null" symbol="0" label="Вершины"/>
      <rule key="{53b5b151-25dc-48d9-860a-5f5b73b86fa0}" filter="length(&quot;SignText&quot;) = 0 or length(&quot;SignText&quot;) is NULL or &quot;TrafficSignsCode&quot; not in ('3.11','3.12','3.13','3.14','3.15','3.16','3.24','3.25','4.6','4.7','5.23.1','5.24.1','6.2','6.11','6.12','6.13','6.14.1','6.14.2','8.1.1','8.1.2','8.1.3','8.1.4','8.2.1','8.2.2','8.2.3','8.2.4','8.2.5','8.2.6','8.5.3','8.5.4','8.5.5','8.5.6','8.5.7','8.11','6.10.1','6.10.2') or &quot;TrafficSignsCode&quot; is NULL" symbol="1" label="Знаки, указатели и информационные щиты"/>
      <rule key="{9d459d6d-6fe0-4fc9-8c7a-9b483c36cf75}" filter="length(&quot;SignText&quot;) > 0 and &quot;TrafficSignsCode&quot; in ('3.11','3.12','3.13','3.14','3.15','3.16','3.24','3.25','4.6','4.7','5.23.1','5.24.1','6.2','6.11','6.12','6.13','6.14.1','6.14.2','8.1.1','8.1.2','8.1.3','8.1.4','8.2.1','8.2.2','8.2.3','8.2.4','8.2.5','8.2.6','8.5.3','8.5.4','8.5.5','8.5.6','8.5.7','8.11','6.10.1','6.10.2')" symbol="2" label="Знаки, указатели и информационные щиты с изменяемым значением"/>
    </rules>
    <symbols>
      <symbol is_animated="0" frame_rate="10" force_rhr="0" type="line" name="0" alpha="1" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="MarkerLine" locked="0" pass="1" enabled="1" id="{717060be-beb2-4cd1-bd53-a0638c2ebee2}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="average_angle_unit"/>
            <Option value="0" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="false" type="bool" name="place_on_every_part"/>
            <Option value="LastVertex|FirstVertex|InnerVertices" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@0@0" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" locked="0" pass="0" enabled="1" id="{786c935c-ae96-4125-a931-059d990007bd}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="square" type="QString" name="cap_style"/>
                <Option value="255,0,0,0,rgb:1,0,0,0" type="QString" name="color"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="miter" type="QString" name="joinstyle"/>
                <Option value="square" type="QString" name="name"/>
                <Option value="0,0" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,1,2.5" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="255,0,0,255,rgb:1,0,0,1" type="QString" name="outline_color"/>
                <Option value="solid" type="QString" name="outline_style"/>
                <Option value="0.035" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,1,2.5" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="outline_width_unit"/>
                <Option value="diameter" type="QString" name="scale_method"/>
                <Option value="0.25" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,1,2.5" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="1" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option name="properties"/>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
      <symbol is_animated="0" frame_rate="10" force_rhr="0" type="line" name="1" alpha="0.94" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" pass="0" enabled="1" id="{6cfdb52c-d7e6-4c06-aa92-51cb80f61a58}">
          <Option type="Map">
            <Option value="0" type="QString" name="align_dash_pattern"/>
            <Option value="square" type="QString" name="capstyle"/>
            <Option value="5;2" type="QString" name="customdash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="customdash_map_unit_scale"/>
            <Option value="MM" type="QString" name="customdash_unit"/>
            <Option value="0" type="QString" name="dash_pattern_offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="dash_pattern_offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="dash_pattern_offset_unit"/>
            <Option value="0" type="QString" name="draw_inside_polygon"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="152,152,152,153,hsv:0,0,0.59607843137254901,0.60003051804379337" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.26" type="QString" name="line_width"/>
            <Option value="MM" type="QString" name="line_width_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="trim_distance_end"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_end_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_end_unit"/>
            <Option value="0" type="QString" name="trim_distance_start"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_start_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_start_unit"/>
            <Option value="0" type="QString" name="tweak_dash_pattern_on_corners"/>
            <Option value="0" type="QString" name="use_custom_dash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="width_map_unit_scale"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer class="MarkerLine" locked="0" pass="1" enabled="1" id="{1269358d-6362-4e17-becf-73ae3b07f30a}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="LastVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="1" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@1@1" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SvgMarker" locked="0" pass="0" enabled="1" id="{b4543b52-284e-44fe-876d-76b2f10a23ac}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="152,152,152,153,hsv:0,0,0.59607843137254901,0.60003051804379337" type="QString" name="color"/>
                <Option value="0" type="QString" name="fixedAspectRatio"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="" type="QString" name="name"/>
                <Option value="0,0" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="outline_width_unit"/>
                <Option name="parameters"/>
                <Option value="diameter" type="QString" name="scale_method"/>
                <Option value="4" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="1" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="SvgMarkerAngle" type="QString" name="field"/>
                      <Option value="2" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="name">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Дорожные знаки ОДХ/' +  &quot;SvgMarkerPath&quot;" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
        <layer class="MarkerLine" locked="0" pass="0" enabled="1" id="{0ab6cfda-254b-47df-881e-c02d4d4fe783}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="FirstVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@1@2" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SvgMarker" locked="0" pass="0" enabled="1" id="{907bd874-690f-4dbe-8541-2d0ef73c53fb}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="152,152,152,153,hsv:0,0,0.59607843137254901,0.60003051804379337" type="QString" name="color"/>
                <Option value="0" type="QString" name="fixedAspectRatio"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="" type="QString" name="name"/>
                <Option value="0,0" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="outline_width_unit"/>
                <Option name="parameters"/>
                <Option value="diameter" type="QString" name="scale_method"/>
                <Option value="1" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="2" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('159', '160', '161', '162', '163', '164', '165', '166', '167', '169', '170', '171', '172', '173', '174') THEN 0&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; = '175' THEN - 180&#xd;&#xa;&#x9;ELSE 0&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="name">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '157' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Ворота.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '158' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Забор.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '159' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Консольная опора.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '163' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на 2-х стойках.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '164' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на 3-х стойках.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '160' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “Г”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '161' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “П”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '162' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “Т”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '165' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/На пролетном строении путепровода.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '166' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/На пролетном строении эстакады.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '167' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Ограждение.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '168' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Опора.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '169' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Опора освещения.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '170' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Павильон ООТ.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '171' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Портал тоннеля.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '172' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Пролетное строение.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '173' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Растяжка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '174' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Светофор.svg'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; = '175' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Стойка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '152' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Колонка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '153' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Здание.svg'&#xd;&#xa;&#x9;ELSE @MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="vAnchor">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('170', '173') THEN 'Vertical Center'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('169', '174') THEN 'Bottom'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('175') THEN 'Top'&#xd;&#xa;&#x9;ELSE 'Vertical Center'&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
      <symbol is_animated="0" frame_rate="10" force_rhr="0" type="line" name="2" alpha="0.96" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" pass="0" enabled="1" id="{6cfdb52c-d7e6-4c06-aa92-51cb80f61a58}">
          <Option type="Map">
            <Option value="0" type="QString" name="align_dash_pattern"/>
            <Option value="square" type="QString" name="capstyle"/>
            <Option value="5;2" type="QString" name="customdash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="customdash_map_unit_scale"/>
            <Option value="MM" type="QString" name="customdash_unit"/>
            <Option value="0" type="QString" name="dash_pattern_offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="dash_pattern_offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="dash_pattern_offset_unit"/>
            <Option value="0" type="QString" name="draw_inside_polygon"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="152,152,152,204,hsv:0,0,0.59607843137254901,0.80001525902189674" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.26" type="QString" name="line_width"/>
            <Option value="MM" type="QString" name="line_width_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="trim_distance_end"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_end_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_end_unit"/>
            <Option value="0" type="QString" name="trim_distance_start"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_start_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_start_unit"/>
            <Option value="0" type="QString" name="tweak_dash_pattern_on_corners"/>
            <Option value="0" type="QString" name="use_custom_dash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="width_map_unit_scale"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer class="MarkerLine" locked="0" pass="0" enabled="1" id="{1269358d-6362-4e17-becf-73ae3b07f30a}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="LastVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="1" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@2@1" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SvgMarker" locked="0" pass="0" enabled="1" id="{b4543b52-284e-44fe-876d-76b2f10a23ac}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="152,152,152,204,hsv:0,0,0.59607843137254901,0.80001525902189674" type="QString" name="color"/>
                <Option value="0" type="QString" name="fixedAspectRatio"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="" type="QString" name="name"/>
                <Option value="0,0" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="outline_width_unit"/>
                <Option name="parameters"/>
                <Option value="diameter" type="QString" name="scale_method"/>
                <Option value="4" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="1" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="SvgMarkerAngle" type="QString" name="field"/>
                      <Option value="2" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="name">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Дорожные знаки ОДХ clear/' +  replace(&quot;SvgMarkerPath&quot;, '.svg', '_clear.svg')" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
        <layer class="MarkerLine" locked="0" pass="1" enabled="1" id="{0ab6cfda-254b-47df-881e-c02d4d4fe783}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="FirstVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@2@2" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SvgMarker" locked="0" pass="0" enabled="1" id="{907bd874-690f-4dbe-8541-2d0ef73c53fb}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="152,152,152,204,hsv:0,0,0.59607843137254901,0.80001525902189674" type="QString" name="color"/>
                <Option value="0" type="QString" name="fixedAspectRatio"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="" type="QString" name="name"/>
                <Option value="0,0" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="outline_width_unit"/>
                <Option name="parameters"/>
                <Option value="diameter" type="QString" name="scale_method"/>
                <Option value="1" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="2" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('159', '160', '161', '162', '163', '164', '165', '166', '167', '169', '170', '171', '172', '173', '174') THEN 0&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; = '175' THEN - 180&#xd;&#xa;&#x9;ELSE 0&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="name">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '157' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Ворота.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '158' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Забор.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '159' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Консольная опора.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '163' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на 2-х стойках.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '164' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на 3-х стойках.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '160' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “Г”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '161' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “П”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '162' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/на “Т”-образной опоре.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '165' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/На пролетном строении путепровода.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '166' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/На пролетном строении эстакады.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '167' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Ограждение.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '168' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Опора.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '169' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Опора освещения.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '170' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Павильон ООТ.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '171' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Портал тоннеля.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '172' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Пролетное строение.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '173' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Растяжка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '174' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Светофор.svg'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; = '175' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Стойка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '152' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Колонка.svg'&#xd;&#xa;&#x9;WHEN &quot;MountingMode&quot; = '153' THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/Здание.svg'&#xd;&#xa;&#x9;ELSE @MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="vAnchor">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="CASE &#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('170', '173') THEN 'Vertical Center'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('169', '174') THEN 'Bottom'&#xd;&#xa;&#x9;WHEN  &quot;MountingMode&quot; in ('175') THEN 'Top'&#xd;&#xa;&#x9;ELSE 'Vertical Center'&#xd;&#xa;END" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
        <layer class="MarkerLine" locked="0" pass="1" enabled="1" id="{261ee0f6-0094-482b-8df8-2548d1f9dbc4}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="LastVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="1" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@2@3" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="FontMarker" locked="0" pass="0" enabled="1" id="{062300e1-2483-4af6-8d32-2c41b6616cd0}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="A" type="QString" name="chr"/>
                <Option value="0,0,0,255,hsv:0,1,0,1" type="QString" name="color"/>
                <Option value="Arial" type="QString" name="font"/>
                <Option value="Обычный" type="QString" name="font_style"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="bevel" type="QString" name="joinstyle"/>
                <Option value="0,-0.5" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MM" type="QString" name="outline_width_unit"/>
                <Option value="2" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="1" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="&quot;SvgMarkerAngle&quot;" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="char">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')), &#xd;&#xa;with_variable('rows', map_get(from_json(&quot;SignText&quot;), 'rows'), &#xd;&#xa;CASE&#xd;&#xa;&#x9;WHEN @svg = '8.5.3' THEN array_first(@rows)&#xd;&#xa;&#x9;ELSE &quot;SignText&quot;&#xd;&#xa;END&#xd;&#xa;))" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="fillColor">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')),&#xd;&#xa;&#x9;CASE&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.25') THEN '#80000000'&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('4.6', '4.7', '6.11_2', '6.11_3', '6.13', '6.14.1', '6.14.1_1', '6.14.1_2', '6.14.1_3', '6.14.1_4', '6.14.2', '6.14.2_1', '6.14.2_2', '6.14.2_3') THEN '#FFFFFFFF'&#xd;&#xa;&#x9;&#x9;ELSE '#FF000000'&#xd;&#xa;&#x9;END&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="offset">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')), &#xd;&#xa;&#x9;CASE&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.12', '3.13') THEN array(0, -1)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.14', '8.5.3') THEN array(0, -0.75)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.16') THEN array(0, -1.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('5.23.1', '5.24.1', '6.11_1', '6.11_2', '6.11') THEN array(0, -0.35)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.11_3') THEN array(0, -0.2)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.13') THEN array(0, -0.6)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.1', '6.14.1_1') THEN array(0, -1)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2', '6.14.2_1') THEN array(0.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2_2') THEN array(-1.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2_3') THEN array(0.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.2') THEN array(0, 0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.3', '8.2.5') THEN array(-0.7, -0.5)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.4', '8.2.6') THEN array(0.7, -0.5)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.2.2') THEN array(0, 0.2)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.5.5', '8.5.6') THEN array(0, 0.15)&#xd;&#xa;&#x9;&#x9;ELSE array(0, -0.5)&#xd;&#xa;&#x9;END&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="size">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')),&#xd;&#xa;&#x9;with_variable('text_len', length(&quot;SignText&quot;), &#xd;&#xa;&#x9;&#x9;CASE&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.11', '3.11', '3.11') THEN 2.0&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.24', '3.25', '6.14.1', '6.14.1_1') THEN 1.8&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.13', '3.14') THEN 1.5&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.13') THEN 1.2&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.16', '8.1.3', '8.2.1', '8.2.5', '8.1.4', '8.2.6') THEN 0.9&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.14.1_2', '6.14.1_3', '6.14.1_4', '8.1.1', '8.1.2') THEN 1.3&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.14.2', '6.14.2_1', '6.14.2_2', '6.14.2_3') THEN 0.8&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('8.5.4', '8.5.5', '8.5.6') THEN 0.7&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('8.5.3') THEN 0.6&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('5.23.1', '5.24.1', '6.11', '6.11_1', '6.11_2', '6.11_3') THEN&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;CASE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len &lt; 5 THEN 1.1&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 5 and 7 THEN 0.75&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 8 and 10 THEN 0.55&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 11 and 12 THEN 0.45&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 13 and 14 THEN 0.4&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 15 and 16 THEN 0.35&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE 0.3&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;ELSE 1.6&#xd;&#xa;&#x9;&#x9;END&#xd;&#xa;&#x9;)&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
        <layer class="MarkerLine" locked="0" pass="0" enabled="1" id="{59ae52a2-48d6-455d-94d1-2274e05e2bfe}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="3" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MM" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="LastVertex" type="QString" name="placements"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="1" type="QString" name="rotate"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="enabled">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')), &#xd;&#xa;CASE&#xd;&#xa;&#x9;WHEN @svg in ('8.5.3') THEN TRUE&#xd;&#xa;&#x9;ELSE FALSE&#xd;&#xa;END&#xd;&#xa;)" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
          <symbol is_animated="0" frame_rate="10" force_rhr="0" type="marker" name="@2@4" alpha="1" clip_to_extent="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="FontMarker" locked="0" pass="0" enabled="1" id="{594a797f-e9c0-42d5-a51c-504afccde70a}">
              <Option type="Map">
                <Option value="0" type="QString" name="angle"/>
                <Option value="A" type="QString" name="chr"/>
                <Option value="0,0,0,255,hsv:0,1,0,1" type="QString" name="color"/>
                <Option value="Arial" type="QString" name="font"/>
                <Option value="Обычный" type="QString" name="font_style"/>
                <Option value="1" type="QString" name="horizontal_anchor_point"/>
                <Option value="bevel" type="QString" name="joinstyle"/>
                <Option value="0,-0.5" type="QString" name="offset"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="offset_unit"/>
                <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
                <Option value="0" type="QString" name="outline_width"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
                <Option value="MM" type="QString" name="outline_width_unit"/>
                <Option value="2" type="QString" name="size"/>
                <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
                <Option value="MapUnit" type="QString" name="size_unit"/>
                <Option value="1" type="QString" name="vertical_anchor_point"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" type="QString" name="name"/>
                  <Option type="Map" name="properties">
                    <Option type="Map" name="angle">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="&quot;SvgMarkerAngle&quot;" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="char">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')), &#xd;&#xa;with_variable('rows', map_get(from_json(&quot;SignText&quot;), 'rows'), &#xd;&#xa;CASE&#xd;&#xa;&#x9;WHEN @svg = '8.5.3' THEN array_last(@rows)&#xd;&#xa;&#x9;ELSE &quot;SignText&quot;&#xd;&#xa;END&#xd;&#xa;))" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="fillColor">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')),&#xd;&#xa;&#x9;CASE&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.25') THEN '#80000000'&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('4.6', '4.7', '6.11_2', '6.11_3', '6.13', '6.14.1', '6.14.1_1', '6.14.1_2', '6.14.1_3', '6.14.1_4', '6.14.2', '6.14.2_1', '6.14.2_2', '6.14.2_3') THEN '#FFFFFFFF'&#xd;&#xa;&#x9;&#x9;ELSE '#FF000000'&#xd;&#xa;&#x9;END&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="offset">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')), &#xd;&#xa;&#x9;CASE&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.12', '3.13') THEN array(0, -1)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.14') THEN array(0, -0.75)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('3.16') THEN array(0, -1.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('5.23.1', '5.24.1', '6.11_1', '6.11_2', '6.11') THEN array(0, -0.35)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.11_3', '8.5.3') THEN array(0, -0.2)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.13') THEN array(0, -0.6)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.1', '6.14.1_1') THEN array(0, -1)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2', '6.14.2_1') THEN array(0.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2_2') THEN array(-1.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('6.14.2_3') THEN array(0.7, -0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.2') THEN array(0, 0.3)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.3', '8.2.5') THEN array(-0.7, -0.5)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.1.4', '8.2.6') THEN array(0.7, -0.5)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.2.2') THEN array(0, 0.2)&#xd;&#xa;&#x9;&#x9;WHEN @svg in ('8.5.5', '8.5.6') THEN array(0, 0.15)&#xd;&#xa;&#x9;&#x9;ELSE array(0, -0.5)&#xd;&#xa;&#x9;END&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                    <Option type="Map" name="size">
                      <Option value="true" type="bool" name="active"/>
                      <Option value="with_variable('svg', array_first(string_to_array(array_last(string_to_array(&quot;SvgMarkerPath&quot;, '/')), '.svg')),&#xd;&#xa;&#x9;with_variable('text_len', length(&quot;SignText&quot;), &#xd;&#xa;&#x9;&#x9;CASE&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.11', '3.11', '3.11') THEN 2.0&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.24', '3.25', '6.14.1', '6.14.1_1') THEN 1.8&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.13', '3.14') THEN 1.5&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.13') THEN 1.2&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('3.16', '8.1.3', '8.2.1', '8.2.5', '8.1.4', '8.2.6') THEN 0.9&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.14.1_2', '6.14.1_3', '6.14.1_4', '8.1.1', '8.1.2') THEN 1.3&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('6.14.2', '6.14.2_1', '6.14.2_2', '6.14.2_3') THEN 0.8&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('8.5.4', '8.5.5', '8.5.6') THEN 0.7&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('8.5.3') THEN 0.6&#xd;&#xa;&#x9;&#x9;&#x9;WHEN @svg in ('5.23.1', '5.24.1', '6.11', '6.11_1', '6.11_2', '6.11_3') THEN&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;CASE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len &lt; 5 THEN 1.1&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 5 and 7 THEN 0.75&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 8 and 10 THEN 0.55&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 11 and 12 THEN 0.45&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 13 and 14 THEN 0.4&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;WHEN @text_len BETWEEN 15 and 16 THEN 0.35&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE 0.3&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;ELSE 1.6&#xd;&#xa;&#x9;&#x9;END&#xd;&#xa;&#x9;)&#xd;&#xa;)" type="QString" name="expression"/>
                      <Option value="3" type="int" name="type"/>
                    </Option>
                  </Option>
                  <Option value="collection" type="QString" name="type"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
    </symbols>
    <data-defined-properties>
      <Option type="Map">
        <Option value="" type="QString" name="name"/>
        <Option name="properties"/>
        <Option value="collection" type="QString" name="type"/>
      </Option>
    </data-defined-properties>
  </renderer-v2>
  <selection mode="Default">
    <selectionColor invalid="1"/>
    <selectionSymbol>
      <symbol is_animated="0" frame_rate="10" force_rhr="0" type="line" name="" alpha="1" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" pass="0" enabled="1" id="{6b7eb2d0-7586-4fed-a23d-6ceecdf32068}">
          <Option type="Map">
            <Option value="0" type="QString" name="align_dash_pattern"/>
            <Option value="square" type="QString" name="capstyle"/>
            <Option value="5;2" type="QString" name="customdash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="customdash_map_unit_scale"/>
            <Option value="MM" type="QString" name="customdash_unit"/>
            <Option value="0" type="QString" name="dash_pattern_offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="dash_pattern_offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="dash_pattern_offset_unit"/>
            <Option value="0" type="QString" name="draw_inside_polygon"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.26" type="QString" name="line_width"/>
            <Option value="MM" type="QString" name="line_width_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="0" type="QString" name="ring_filter"/>
            <Option value="0" type="QString" name="trim_distance_end"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_end_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_end_unit"/>
            <Option value="0" type="QString" name="trim_distance_start"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="trim_distance_start_map_unit_scale"/>
            <Option value="MM" type="QString" name="trim_distance_start_unit"/>
            <Option value="0" type="QString" name="tweak_dash_pattern_on_corners"/>
            <Option value="0" type="QString" name="use_custom_dash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="width_map_unit_scale"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </selectionSymbol>
  </selection>
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
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OghObjectType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option value=" &quot;OghObjectType&quot; = 14" type="QString" name="FilterExpression"/>
            <Option value="OghObjectTypeName" type="QString" name="Key"/>
            <Option value="______________________________c9413591_1d84_4b51_b346_110cfe011632" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Тип проезжей части" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;FlatElementType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
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
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="EquipmentType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_____________________36f4ea33_2218_4604_b969_704fa7e0023f" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Тип знака" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;EquipmentType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhSide">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="____________________________________________82f277dd_0bf4_4a8a_86a8_6799c4a9b098" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Код стороны проезжей части" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;OdhSide&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhAxis">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="AxisName" type="QString" name="Key"/>
            <Option value="_____________309d7d40_d51a_4460_b185_882917da60ed" type="QString" name="Layer"/>
            <Option value="Осевые линии" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' srid=980077 checkPrimaryKeyUnicity='1' table=&quot;work&quot;.&quot;AxialLines&quot; (Geometry) sql=&quot;TaskGUID&quot; = '275a8b17-742a-4029-80ff-1b8207fb4dae'" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="AxisName" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Endwise">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="-1e+06" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="0" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MountingMode">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________13964f18_a872_43df_b106_8daa013454f7" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Тип установки знака" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MountingMode&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="TrafficSignsCode">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="___________________________________c1e8aeff_871b_4fe0_8b11_b52fad3eaf2e" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Код знака по ГОСТ" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='mggt_editor' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;TrafficSigns&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="true" type="bool" name="UseCompleter"/>
            <Option value="NameGOST" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="TrafficSignsName">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Name" type="QString" name="Key"/>
            <Option value="___________________________________c1e8aeff_871b_4fe0_8b11_b52fad3eaf2e" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Код знака по ГОСТ" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='mggt_editor' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;TrafficSigns&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="NameGOST" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Height">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="1" type="int" name="Precision"/>
            <Option value="0.1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Placement">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ParentOghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
          <Option type="Map">
            <Option value="true" type="bool" name="allow_null"/>
            <Option value="true" type="bool" name="calendar_popup"/>
            <Option value="dd.MM.yyyy HH:mm:ss" type="QString" name="display_format"/>
            <Option value="yyyy-MM-dd HH:mm:ss" type="QString" name="field_format"/>
            <Option value="false" type="bool" name="field_format_overwrite"/>
            <Option value="false" type="bool" name="field_iso_format"/>
          </Option>
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
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="SvgMarkerAngle">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="SvgMarkerPath">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsDiffHeightMark">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowNullState"/>
            <Option type="invalid" name="CheckedState"/>
            <Option value="0" type="int" name="TextDisplayMethod"/>
            <Option type="invalid" name="UncheckedState"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="SignText">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OnYellowBack">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowNullState"/>
            <Option type="invalid" name="CheckedState"/>
            <Option value="0" type="int" name="TextDisplayMethod"/>
            <Option type="invalid" name="UncheckedState"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" index="0" name=""/>
    <alias field="OghObjectType" index="1" name=""/>
    <alias field="ObjectId" index="2" name=""/>
    <alias field="RootId" index="3" name="Идентификатор ОГХ (RootId)"/>
    <alias field="StartDate" index="4" name=""/>
    <alias field="EndDate" index="5" name=""/>
    <alias field="EquipmentType" index="6" name="Тип знака"/>
    <alias field="OdhSide" index="7" name=""/>
    <alias field="OdhAxis" index="8" name=""/>
    <alias field="Endwise" index="9" name="По оси"/>
    <alias field="MountingMode" index="10" name="Тип установки"/>
    <alias field="TrafficSignsCode" index="11" name="Код по ГОСТ"/>
    <alias field="TrafficSignsName" index="12" name="Название по ГОСТ"/>
    <alias field="Area" index="13" name=""/>
    <alias field="Height" index="14" name="Высота расположения по низу"/>
    <alias field="Placement" index="15" name=""/>
    <alias field="Description" index="16" name="Примечание"/>
    <alias field="ParentOghObjectType" index="17" name=""/>
    <alias field="ParentObjectId" index="18" name=""/>
    <alias field="ParentRootId" index="19" name=""/>
    <alias field="ParentStartDate" index="20" name=""/>
    <alias field="ParentEndDate" index="21" name=""/>
    <alias field="CreateDate" index="22" name=""/>
    <alias field="CreateAuthor" index="23" name=""/>
    <alias field="ChangeDate" index="24" name=""/>
    <alias field="ChangeAuthor" index="25" name=""/>
    <alias field="TaskGUID" index="26" name=""/>
    <alias field="SvgMarkerAngle" index="27" name="Угол поворота SVG маркера знака"/>
    <alias field="SvgMarkerPath" index="28" name="Относительный путь к SVG знака"/>
    <alias field="IsDiffHeightMark" index="29" name="Разновысотные отметки"/>
    <alias field="SignText" index="30" name="Текст на знаке"/>
    <alias field="OnYellowBack" index="31" name="На желтом фоне"/>
  </aliases>
  <defaults>
    <default field="fid" applyOnUpdate="0" expression=""/>
    <default field="OghObjectType" applyOnUpdate="0" expression=""/>
    <default field="ObjectId" applyOnUpdate="0" expression=""/>
    <default field="RootId" applyOnUpdate="0" expression=""/>
    <default field="StartDate" applyOnUpdate="0" expression=""/>
    <default field="EndDate" applyOnUpdate="0" expression=""/>
    <default field="EquipmentType" applyOnUpdate="0" expression="'19'"/>
    <default field="OdhSide" applyOnUpdate="0" expression=""/>
    <default field="OdhAxis" applyOnUpdate="0" expression=""/>
    <default field="Endwise" applyOnUpdate="0" expression=""/>
    <default field="MountingMode" applyOnUpdate="0" expression="'175'"/>
    <default field="TrafficSignsCode" applyOnUpdate="0" expression="'8.5.3'"/>
    <default field="TrafficSignsName" applyOnUpdate="0" expression="'Дни недели'"/>
    <default field="Area" applyOnUpdate="0" expression="0.25"/>
    <default field="Height" applyOnUpdate="0" expression="distance(point_n($geometry, -1), point_n($geometry, -2))"/>
    <default field="Placement" applyOnUpdate="0" expression=""/>
    <default field="Description" applyOnUpdate="0" expression="''"/>
    <default field="ParentOghObjectType" applyOnUpdate="0" expression=""/>
    <default field="ParentObjectId" applyOnUpdate="0" expression=""/>
    <default field="ParentRootId" applyOnUpdate="0" expression=""/>
    <default field="ParentStartDate" applyOnUpdate="0" expression=""/>
    <default field="ParentEndDate" applyOnUpdate="0" expression=""/>
    <default field="CreateDate" applyOnUpdate="0" expression=""/>
    <default field="CreateAuthor" applyOnUpdate="0" expression=""/>
    <default field="ChangeDate" applyOnUpdate="0" expression=""/>
    <default field="ChangeAuthor" applyOnUpdate="0" expression=""/>
    <default field="TaskGUID" applyOnUpdate="0" expression=""/>
    <default field="SvgMarkerAngle" applyOnUpdate="0" expression="90"/>
    <default field="SvgMarkerPath" applyOnUpdate="0" expression="'8. Знаки дополнительной информации (таблички)/8.5.3.svg'"/>
    <default field="IsDiffHeightMark" applyOnUpdate="0" expression=""/>
    <default field="SignText" applyOnUpdate="0" expression=""/>
    <default field="OnYellowBack" applyOnUpdate="0" expression=""/>
  </defaults>
  <constraints>
    <constraint field="fid" constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint field="OghObjectType" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ObjectId" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="RootId" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="StartDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="EndDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="EquipmentType" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="OdhSide" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="OdhAxis" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="Endwise" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="MountingMode" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="TrafficSignsCode" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="TrafficSignsName" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="Area" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="Height" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="Placement" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="Description" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ParentOghObjectType" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ParentObjectId" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ParentRootId" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ParentStartDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ParentEndDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="CreateDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="CreateAuthor" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ChangeDate" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="ChangeAuthor" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="TaskGUID" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="SvgMarkerAngle" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="SvgMarkerPath" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="IsDiffHeightMark" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="SignText" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="OnYellowBack" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" desc="" exp=""/>
    <constraint field="OghObjectType" desc="" exp=""/>
    <constraint field="ObjectId" desc="" exp=""/>
    <constraint field="RootId" desc="" exp=""/>
    <constraint field="StartDate" desc="" exp=""/>
    <constraint field="EndDate" desc="" exp=""/>
    <constraint field="EquipmentType" desc="" exp=""/>
    <constraint field="OdhSide" desc="" exp=""/>
    <constraint field="OdhAxis" desc="" exp=""/>
    <constraint field="Endwise" desc="" exp=""/>
    <constraint field="MountingMode" desc="" exp=""/>
    <constraint field="TrafficSignsCode" desc="" exp=""/>
    <constraint field="TrafficSignsName" desc="" exp=""/>
    <constraint field="Area" desc="" exp=""/>
    <constraint field="Height" desc="" exp=""/>
    <constraint field="Placement" desc="" exp=""/>
    <constraint field="Description" desc="" exp=""/>
    <constraint field="ParentOghObjectType" desc="" exp=""/>
    <constraint field="ParentObjectId" desc="" exp=""/>
    <constraint field="ParentRootId" desc="" exp=""/>
    <constraint field="ParentStartDate" desc="" exp=""/>
    <constraint field="ParentEndDate" desc="" exp=""/>
    <constraint field="CreateDate" desc="" exp=""/>
    <constraint field="CreateAuthor" desc="" exp=""/>
    <constraint field="ChangeDate" desc="" exp=""/>
    <constraint field="ChangeAuthor" desc="" exp=""/>
    <constraint field="TaskGUID" desc="" exp=""/>
    <constraint field="SvgMarkerAngle" desc="" exp=""/>
    <constraint field="SvgMarkerPath" desc="" exp=""/>
    <constraint field="IsDiffHeightMark" desc="" exp=""/>
    <constraint field="SignText" desc="" exp=""/>
    <constraint field="OnYellowBack" desc="" exp=""/>
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
    <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
      <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" index="3" name="RootId" verticalStretch="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer visibilityExpression="" groupBox="1" columnCount="4" type="GroupBox" showLabel="1" visibilityExpressionEnabled="0" collapsedExpression="" name="Назначение" verticalStretch="0" collapsed="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="6" name="EquipmentType" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="10" name="MountingMode" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="11" name="TrafficSignsCode" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorSpacerElement drawLine="0" showLabel="0" name="Spacer Widget" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorSpacerElement>
      <attributeEditorField showLabel="1" index="16" name="Description" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="30" name="SignText" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="29" name="IsDiffHeightMark" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="31" name="OnYellowBack" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="1" columnCount="4" type="GroupBox" showLabel="1" visibilityExpressionEnabled="0" collapsedExpression="" name="Привязка" verticalStretch="0" collapsed="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont description="Sans,10,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="8" name="OdhAxis" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="7" name="OdhSide" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="9" name="Endwise" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="1" columnCount="6" type="GroupBox" showLabel="1" visibilityExpressionEnabled="0" collapsedExpression="" name="Параметры" verticalStretch="0" collapsed="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="13" name="Area" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="14" name="Height" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" columnCount="4" type="Tab" showLabel="1" visibilityExpressionEnabled="0" collapsedExpression="" name="Параметры SVG" verticalStretch="0" collapsed="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="27" name="SvgMarkerAngle" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="28" name="SvgMarkerPath" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" showLabel="0" name="SpacerWidget" verticalStretch="0" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" bold="0" underline="0" style="" italic="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="Area" editable="1"/>
    <field name="AutoCleanArea" editable="1"/>
    <field name="AxisGeometry" editable="1"/>
    <field name="BordBegin" editable="1"/>
    <field name="BordEnd" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CoatingGroup" editable="1"/>
    <field name="CoatingType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="Description" editable="1"/>
    <field name="Distance" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="Endwise" editable="1"/>
    <field name="EquipmentType" editable="1"/>
    <field name="FlatElementType" editable="1"/>
    <field name="Height" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="ManualCleanArea" editable="1"/>
    <field name="MountingMode" editable="1"/>
    <field name="NoCleanArea" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OdhAxis" editable="1"/>
    <field name="OdhSide" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="OnYellowBack" editable="1"/>
    <field name="OotCleanArea" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="Placement" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="SignText" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="SvgMarkerAngle" editable="1"/>
    <field name="SvgMarkerPath" editable="0"/>
    <field name="TaskGUID" editable="1"/>
    <field name="TrafficSignsCode" editable="1"/>
    <field name="TrafficSignsName" editable="1"/>
    <field name="UtnArea" editable="1"/>
    <field name="WidthBegin" editable="1"/>
    <field name="WidthEnd" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="1" name="AutoCleanArea"/>
    <field labelOnTop="0" name="AxisGeometry"/>
    <field labelOnTop="1" name="BordBegin"/>
    <field labelOnTop="1" name="BordEnd"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CoatingGroup"/>
    <field labelOnTop="1" name="CoatingType"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="1" name="Description"/>
    <field labelOnTop="1" name="Distance"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="1" name="Endwise"/>
    <field labelOnTop="1" name="EquipmentType"/>
    <field labelOnTop="1" name="FlatElementType"/>
    <field labelOnTop="1" name="Height"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="ManualCleanArea"/>
    <field labelOnTop="1" name="MountingMode"/>
    <field labelOnTop="1" name="NoCleanArea"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="1" name="OdhAxis"/>
    <field labelOnTop="1" name="OdhSide"/>
    <field labelOnTop="1" name="OghObjectType"/>
    <field labelOnTop="1" name="OnYellowBack"/>
    <field labelOnTop="1" name="OotCleanArea"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="0" name="Placement"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="1" name="SignText"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="1" name="SvgMarkerAngle"/>
    <field labelOnTop="1" name="SvgMarkerPath"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="TrafficSignsCode"/>
    <field labelOnTop="1" name="TrafficSignsName"/>
    <field labelOnTop="1" name="UtnArea"/>
    <field labelOnTop="1" name="WidthBegin"/>
    <field labelOnTop="1" name="WidthEnd"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="AutoCleanArea"/>
    <field reuseLastValue="0" name="AxisGeometry"/>
    <field reuseLastValue="0" name="BordBegin"/>
    <field reuseLastValue="0" name="BordEnd"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CoatingGroup"/>
    <field reuseLastValue="0" name="CoatingType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="Description"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="Endwise"/>
    <field reuseLastValue="0" name="EquipmentType"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="Height"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
    <field reuseLastValue="0" name="MountingMode"/>
    <field reuseLastValue="0" name="NoCleanArea"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OdhAxis"/>
    <field reuseLastValue="0" name="OdhSide"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="OnYellowBack"/>
    <field reuseLastValue="0" name="OotCleanArea"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="Placement"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="SignText"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="SvgMarkerAngle"/>
    <field reuseLastValue="0" name="SvgMarkerPath"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="TrafficSignsCode"/>
    <field reuseLastValue="0" name="TrafficSignsName"/>
    <field reuseLastValue="0" name="UtnArea"/>
    <field reuseLastValue="0" name="WidthBegin"/>
    <field reuseLastValue="0" name="WidthEnd"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
