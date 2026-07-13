<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyLocal="1" simplifyMaxScale="1" version="3.44.1-Solothurn" hasScaleBasedVisibilityFlag="0" labelsEnabled="0" simplifyDrawingHints="1" symbologyReferenceScale="-1" simplifyAlgorithm="0" autoRefreshTime="0" maxScale="0" minScale="100000000" autoRefreshMode="Disabled" simplifyDrawingTol="1">
  <renderer-v2 referencescale="-1" symbollevels="0" type="RuleRenderer" enableorderby="0" forceraster="0">
    <rules key="{28ff49b8-38d8-4bb3-810e-406e35be8f14}">
      <rule filter=" &quot;fid&quot; is not null" symbol="0" key="{33db6800-216c-4cc8-b495-96aee403b965}" checkstate="0" label="Вершины"/>
      <rule filter=" &quot;ArrangeElementType&quot; in ('gutter_trays', 'gutter_tray')" symbol="1" key="{593041fb-974d-4cac-8dab-440d59c3cf40}" label="Лоток водосточный"/>
      <rule filter=" &quot;ArrangeElementType&quot; = 'road_marking_longitudinal'" symbol="2" key="{d9f0bebb-d488-4711-b5aa-46ac490700f0}" label="Дорожная разметка продольная"/>
      <rule filter=" &quot;ArrangeElementType&quot; in ('artificial_road_roughness', 'speed_dump')" symbol="3" key="{a0a3170e-128e-4b08-9bb8-a63bbcbf9e34}" label="ИДН"/>
      <rule filter=" &quot;ArrangeElementType&quot; = 'road_bumps'" symbol="4" key="{1be7e6c5-08e4-49b0-8c72-93ee96ff0250}" label="ИДН с отр. элементами"/>
      <rule filter=" &quot;ArrangeElementType&quot;  is null" symbol="5" key="{dcddbc48-7364-4fa8-990a-bcd404b1b518}" label="нет данных"/>
    </rules>
    <symbols>
      <symbol type="line" name="0" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="MarkerLine" pass="1" enabled="1" locked="0" id="{717060be-beb2-4cd1-bd53-a0638c2ebee2}">
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
          <symbol type="marker" name="@0@0" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleMarker" pass="0" enabled="1" locked="0" id="{786c935c-ae96-4125-a931-059d990007bd}">
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
      <symbol type="line" name="1" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{908b88c0-1352-4cc3-aba0-51cbb4e1f2f3}">
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
            <Option value="0,176,185,255,hsv:0.5083333333333333,1,0.72549019607843135,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.66" type="QString" name="line_width"/>
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
      <symbol type="line" name="2" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{908b88c0-1352-4cc3-aba0-51cbb4e1f2f3}">
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
            <Option value="255,255,255,255,hsv:0.14736111111111111,0,1,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.66" type="QString" name="line_width"/>
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
      <symbol type="line" name="3" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{bde54a07-9316-43e3-9d74-e67c9f9edd14}">
          <Option type="Map">
            <Option value="0" type="QString" name="align_dash_pattern"/>
            <Option value="round" type="QString" name="capstyle"/>
            <Option value="5;2" type="QString" name="customdash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="customdash_map_unit_scale"/>
            <Option value="MM" type="QString" name="customdash_unit"/>
            <Option value="0" type="QString" name="dash_pattern_offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="dash_pattern_offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="dash_pattern_offset_unit"/>
            <Option value="0" type="QString" name="draw_inside_polygon"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="0,0,0,255,hsv:0,0,0,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.5" type="QString" name="line_width"/>
            <Option value="MapUnit" type="QString" name="line_width_unit"/>
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
        <layer class="HashLine" pass="0" enabled="1" locked="0" id="{8b85a2ed-98d9-4342-a4cf-e37e9f46ddd0}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="0" type="QString" name="hash_angle"/>
            <Option value="0.3" type="QString" name="hash_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="hash_length_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="hash_length_unit"/>
            <Option value="0.5" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0.2" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="Interval" type="QString" name="placements"/>
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
          <symbol type="line" name="@3@1" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{4f26e88a-51a3-455e-9e3f-f14337af9b18}">
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
                <Option value="255,233,64,255,rgb:1,0.9132219,0.2509804,1" type="QString" name="line_color"/>
                <Option value="solid" type="QString" name="line_style"/>
                <Option value="0.05" type="QString" name="line_width"/>
                <Option value="MapUnit" type="QString" name="line_width_unit"/>
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
        </layer>
      </symbol>
      <symbol type="line" name="4" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{bde54a07-9316-43e3-9d74-e67c9f9edd14}">
          <Option type="Map">
            <Option value="0" type="QString" name="align_dash_pattern"/>
            <Option value="round" type="QString" name="capstyle"/>
            <Option value="5;2" type="QString" name="customdash"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="customdash_map_unit_scale"/>
            <Option value="MM" type="QString" name="customdash_unit"/>
            <Option value="0" type="QString" name="dash_pattern_offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="dash_pattern_offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="dash_pattern_offset_unit"/>
            <Option value="0" type="QString" name="draw_inside_polygon"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="0,0,0,255,hsv:0,0,0,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.5" type="QString" name="line_width"/>
            <Option value="MapUnit" type="QString" name="line_width_unit"/>
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
        <layer class="HashLine" pass="0" enabled="1" locked="0" id="{8b85a2ed-98d9-4342-a4cf-e37e9f46ddd0}">
          <Option type="Map">
            <Option value="4" type="QString" name="average_angle_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="average_angle_map_unit_scale"/>
            <Option value="MM" type="QString" name="average_angle_unit"/>
            <Option value="0" type="QString" name="hash_angle"/>
            <Option value="0.3" type="QString" name="hash_length"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="hash_length_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="hash_length_unit"/>
            <Option value="0.5" type="QString" name="interval"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="interval_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="interval_unit"/>
            <Option value="0" type="QString" name="offset"/>
            <Option value="0.2" type="QString" name="offset_along_line"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_along_line_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_along_line_unit"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="true" type="bool" name="place_on_every_part"/>
            <Option value="Interval" type="QString" name="placements"/>
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
          <symbol type="line" name="@4@1" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" type="QString" name="name"/>
                <Option name="properties"/>
                <Option value="collection" type="QString" name="type"/>
              </Option>
            </data_defined_properties>
            <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{4f26e88a-51a3-455e-9e3f-f14337af9b18}">
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
                <Option value="255,255,255,255,hsv:0.14736111111111111,0,1,1" type="QString" name="line_color"/>
                <Option value="solid" type="QString" name="line_style"/>
                <Option value="0.05" type="QString" name="line_width"/>
                <Option value="MapUnit" type="QString" name="line_width_unit"/>
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
        </layer>
      </symbol>
      <symbol type="line" name="5" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{908b88c0-1352-4cc3-aba0-51cbb4e1f2f3}">
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
            <Option value="172,0,3,255,hsv:0.99722222222222223,1,0.67450980392156867,1" type="QString" name="line_color"/>
            <Option value="solid" type="QString" name="line_style"/>
            <Option value="0.66" type="QString" name="line_width"/>
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
      <symbol type="line" name="" clip_to_extent="1" frame_rate="10" alpha="1" force_rhr="0" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" pass="0" enabled="1" locked="0" id="{19ee3523-f82c-44ab-a171-94593491343c}">
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
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
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
    <field configurationFlags="NoFlag" name="ArrangeElementType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option value="" type="QString" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option value="&quot;OghObjectType&quot; = 35 and &quot;AllowedLine&quot; and &#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" type="QString" name="FilterExpression"/>
            <Option value="" type="QString" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="______________________________________________2cf0324a_63ab_4e66_b083_e427b91ac348" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Типы элементов организации" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ArrangeElementType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option value="" type="QString" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Quantity">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1.7976931348623157e+308" type="double" name="Max"/>
            <Option value="-1.7976931348623157e+308" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Unit">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_____________________________dc48829e_8cc0_4936_ad3b_d9d1aed16315" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Единицы измерения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Units&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Material">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option value="array_contains( string_to_array( replace(&quot;TaskTypeId&quot;, array('[', ']'), '')), @MggtAsuTaskType)" type="QString" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_____________________e9b3d002_10fa_48f8_b206_7568db784c13" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Материалы" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ZoneOghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ZoneOghObjectRootId">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="FileList">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="NoCalc">
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
    <field configurationFlags="NoFlag" name="ParentOghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
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
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingGroup">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingFaceType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="FaceArea">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" name="" field="fid"/>
    <alias index="1" name="" field="OghObjectType"/>
    <alias index="2" name="" field="ObjectId"/>
    <alias index="3" name="Идентификатор ОГХ (RootId)" field="RootId"/>
    <alias index="4" name="" field="StartDate"/>
    <alias index="5" name="" field="EndDate"/>
    <alias index="6" name="Тип элемента" field="ArrangeElementType"/>
    <alias index="7" name="Количество" field="Quantity"/>
    <alias index="8" name="Единица измерения" field="Unit"/>
    <alias index="9" name="Материал" field="Material"/>
    <alias index="10" name="" field="ZoneOghObjectType"/>
    <alias index="11" name="" field="ZoneOghObjectRootId"/>
    <alias index="12" name="" field="FileList"/>
    <alias index="13" name="Не учитывать" field="NoCalc"/>
    <alias index="14" name="Разновысотные отметки" field="IsDiffHeightMark"/>
    <alias index="15" name="" field="ParentOghObjectType"/>
    <alias index="16" name="" field="ParentObjectId"/>
    <alias index="17" name="" field="ParentRootId"/>
    <alias index="18" name="" field="ParentStartDate"/>
    <alias index="19" name="" field="ParentEndDate"/>
    <alias index="20" name="" field="CreateDate"/>
    <alias index="21" name="" field="CreateAuthor"/>
    <alias index="22" name="" field="ChangeDate"/>
    <alias index="23" name="" field="ChangeAuthor"/>
    <alias index="24" name="" field="TaskGUID"/>
    <alias index="25" name="" field="CoatingGroup"/>
    <alias index="26" name="" field="CoatingType"/>
    <alias index="27" name="" field="CoatingFaceType"/>
    <alias index="28" name="" field="FaceArea"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" field="fid" expression=""/>
    <default applyOnUpdate="0" field="OghObjectType" expression=""/>
    <default applyOnUpdate="0" field="ObjectId" expression=""/>
    <default applyOnUpdate="0" field="RootId" expression=""/>
    <default applyOnUpdate="0" field="StartDate" expression=""/>
    <default applyOnUpdate="0" field="EndDate" expression=""/>
    <default applyOnUpdate="0" field="ArrangeElementType" expression=""/>
    <default applyOnUpdate="0" field="Quantity" expression=""/>
    <default applyOnUpdate="0" field="Unit" expression=""/>
    <default applyOnUpdate="0" field="Material" expression=""/>
    <default applyOnUpdate="0" field="ZoneOghObjectType" expression=""/>
    <default applyOnUpdate="0" field="ZoneOghObjectRootId" expression=""/>
    <default applyOnUpdate="0" field="FileList" expression=""/>
    <default applyOnUpdate="0" field="NoCalc" expression=""/>
    <default applyOnUpdate="0" field="IsDiffHeightMark" expression=""/>
    <default applyOnUpdate="0" field="ParentOghObjectType" expression=""/>
    <default applyOnUpdate="0" field="ParentObjectId" expression=""/>
    <default applyOnUpdate="0" field="ParentRootId" expression=""/>
    <default applyOnUpdate="0" field="ParentStartDate" expression=""/>
    <default applyOnUpdate="0" field="ParentEndDate" expression=""/>
    <default applyOnUpdate="0" field="CreateDate" expression=""/>
    <default applyOnUpdate="0" field="CreateAuthor" expression=""/>
    <default applyOnUpdate="0" field="ChangeDate" expression=""/>
    <default applyOnUpdate="0" field="ChangeAuthor" expression=""/>
    <default applyOnUpdate="0" field="TaskGUID" expression=""/>
    <default applyOnUpdate="0" field="CoatingGroup" expression=""/>
    <default applyOnUpdate="0" field="CoatingType" expression=""/>
    <default applyOnUpdate="0" field="CoatingFaceType" expression=""/>
    <default applyOnUpdate="0" field="FaceArea" expression=""/>
  </defaults>
  <constraints>
    <constraint unique_strength="1" exp_strength="0" constraints="3" field="fid" notnull_strength="1"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="OghObjectType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ObjectId" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="RootId" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="StartDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="EndDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ArrangeElementType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="Quantity" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="Unit" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="Material" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ZoneOghObjectType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ZoneOghObjectRootId" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="FileList" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="NoCalc" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="IsDiffHeightMark" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ParentOghObjectType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ParentObjectId" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ParentRootId" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ParentStartDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ParentEndDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="CreateDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="CreateAuthor" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ChangeDate" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="ChangeAuthor" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="TaskGUID" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="CoatingGroup" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="CoatingType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="CoatingFaceType" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="FaceArea" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="ArrangeElementType"/>
    <constraint desc="" exp="" field="Quantity"/>
    <constraint desc="" exp="" field="Unit"/>
    <constraint desc="" exp="" field="Material"/>
    <constraint desc="" exp="" field="ZoneOghObjectType"/>
    <constraint desc="" exp="" field="ZoneOghObjectRootId"/>
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
    <constraint desc="" exp="" field="CoatingGroup"/>
    <constraint desc="" exp="" field="CoatingType"/>
    <constraint desc="" exp="" field="CoatingFaceType"/>
    <constraint desc="" exp="" field="FaceArea"/>
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
    <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
      <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField horizontalStretch="0" index="3" verticalStretch="0" name="RootId" showLabel="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
        <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer horizontalStretch="0" visibilityExpression="" verticalStretch="0" collapsedExpressionEnabled="0" name="Назначение" columnCount="4" type="GroupBox" visibilityExpressionEnabled="0" collapsed="0" groupBox="1" showLabel="1" collapsedExpression="">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" index="6" verticalStretch="0" name="ArrangeElementType" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" index="7" verticalStretch="0" name="Quantity" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" index="8" verticalStretch="0" name="Unit" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" index="9" verticalStretch="0" name="Material" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer horizontalStretch="0" visibilityExpression="" verticalStretch="0" collapsedExpressionEnabled="0" name="Параметры" columnCount="2" type="GroupBox" visibilityExpressionEnabled="0" collapsed="0" groupBox="1" showLabel="1" collapsedExpression="">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" index="13" verticalStretch="0" name="NoCalc" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" index="14" verticalStretch="0" name="IsDiffHeightMark" showLabel="1">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement horizontalStretch="0" verticalStretch="0" name="SpacerWidget" drawLine="0" showLabel="0">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
        <labelFont strikethrough="0" bold="0" underline="0" italic="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="ArrangeElementType" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CoatingFaceType" editable="1"/>
    <field name="CoatingGroup" editable="1"/>
    <field name="CoatingType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FaceArea" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="Material" editable="1"/>
    <field name="NoCalc" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="Quantity" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="Unit" editable="1"/>
    <field name="ZoneOghObjectRootId" editable="1"/>
    <field name="ZoneOghObjectType" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="ArrangeElementType" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CoatingFaceType" labelOnTop="0"/>
    <field name="CoatingGroup" labelOnTop="0"/>
    <field name="CoatingType" labelOnTop="0"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FaceArea" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="Material" labelOnTop="1"/>
    <field name="NoCalc" labelOnTop="1"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="OghObjectType" labelOnTop="0"/>
    <field name="ParentEndDate" labelOnTop="0"/>
    <field name="ParentObjectId" labelOnTop="0"/>
    <field name="ParentOghObjectType" labelOnTop="0"/>
    <field name="ParentRootId" labelOnTop="0"/>
    <field name="ParentStartDate" labelOnTop="0"/>
    <field name="Quantity" labelOnTop="1"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="Unit" labelOnTop="1"/>
    <field name="ZoneOghObjectRootId" labelOnTop="0"/>
    <field name="ZoneOghObjectType" labelOnTop="0"/>
    <field name="fid" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="ArrangeElementType"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CoatingFaceType"/>
    <field reuseLastValue="0" name="CoatingGroup"/>
    <field reuseLastValue="0" name="CoatingType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FaceArea"/>
    <field reuseLastValue="0" name="FileList"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="Material"/>
    <field reuseLastValue="0" name="NoCalc"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="Quantity"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="Unit"/>
    <field reuseLastValue="0" name="ZoneOghObjectRootId"/>
    <field reuseLastValue="0" name="ZoneOghObjectType"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
