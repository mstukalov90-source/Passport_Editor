<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.44.1-Solothurn" minScale="100000000" simplifyDrawingHints="1" symbologyReferenceScale="-1" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyLocal="1" simplifyAlgorithm="0" simplifyMaxScale="1" autoRefreshMode="Disabled" simplifyDrawingTol="1" labelsEnabled="0" autoRefreshTime="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions">
  <renderer-v2 referencescale="-1" symbollevels="0" forceraster="0" enableorderby="0" type="RuleRenderer">
    <rules key="{4fced174-511b-4f3b-a078-f86924e0844a}">
      <rule symbol="0" filter=" &quot;fid&quot; is not null" label="Вершины" key="{32cb5a03-e1fe-4b7c-9b1b-5ba5f4a4a4af}" checkstate="0"/>
      <rule symbol="1" filter=" &quot;AbutmentType&quot; = 'fence_beton_stone'" label="Бортовой камень из бетона" key="{d4b1b9c6-9aa8-479a-b892-10ed6611ed1c}"/>
      <rule symbol="2" filter=" &quot;AbutmentType&quot; = 'fence_granite_stone'" label="Бортовой камень из гранита" key="{4da8576e-70d8-4326-8826-715d4e1a991c}"/>
      <rule symbol="3" filter=" &quot;AbutmentType&quot; = 'fence_decor_stone'" label="Декоративный бортовой камень" key="{9a442f1e-9ad3-4e56-8faf-f590b2e895a4}"/>
      <rule symbol="4" filter=" &quot;AbutmentType&quot; = 'fence_road_stone'" label="Дорожный бортовой камень" key="{ef01fbd4-0b58-40db-b39c-318f36132ab5}"/>
      <rule symbol="5" filter=" &quot;AbutmentType&quot; = 'fence_garden_stone'" label="Садовый бортовой камень" key="{f8b779d3-d2f4-48f6-8242-adc7d2e127e4}"/>
      <rule symbol="6" filter=" &quot;AbutmentType&quot; is null" label="Нет данных" key="{b849ab31-e4fe-4d47-9315-eaa5a23536be}"/>
    </rules>
    <symbols>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{717060be-beb2-4cd1-bd53-a0638c2ebee2}" class="MarkerLine" locked="0" pass="1">
          <Option type="Map">
            <Option value="4" name="average_angle_length" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="average_angle_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="average_angle_unit" type="QString"/>
            <Option value="0" name="interval" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="interval_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="interval_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="0" name="offset_along_line" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_along_line_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_along_line_unit" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="false" name="place_on_every_part" type="bool"/>
            <Option value="LastVertex|FirstVertex|InnerVertices" name="placements" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="rotate" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
          <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="@0@0" type="marker">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" name="name" type="QString"/>
                <Option name="properties"/>
                <Option value="collection" name="type" type="QString"/>
              </Option>
            </data_defined_properties>
            <layer enabled="1" id="{786c935c-ae96-4125-a931-059d990007bd}" class="SimpleMarker" locked="0" pass="0">
              <Option type="Map">
                <Option value="0" name="angle" type="QString"/>
                <Option value="square" name="cap_style" type="QString"/>
                <Option value="255,0,0,0,rgb:1,0,0,0" name="color" type="QString"/>
                <Option value="1" name="horizontal_anchor_point" type="QString"/>
                <Option value="miter" name="joinstyle" type="QString"/>
                <Option value="square" name="name" type="QString"/>
                <Option value="0,0" name="offset" type="QString"/>
                <Option value="3x:0,0,0,0,1,2.5" name="offset_map_unit_scale" type="QString"/>
                <Option value="MapUnit" name="offset_unit" type="QString"/>
                <Option value="255,0,0,255,rgb:1,0,0,1" name="outline_color" type="QString"/>
                <Option value="solid" name="outline_style" type="QString"/>
                <Option value="0.035" name="outline_width" type="QString"/>
                <Option value="3x:0,0,0,0,1,2.5" name="outline_width_map_unit_scale" type="QString"/>
                <Option value="MapUnit" name="outline_width_unit" type="QString"/>
                <Option value="diameter" name="scale_method" type="QString"/>
                <Option value="0.25" name="size" type="QString"/>
                <Option value="3x:0,0,0,0,1,2.5" name="size_map_unit_scale" type="QString"/>
                <Option value="MapUnit" name="size_unit" type="QString"/>
                <Option value="1" name="vertical_anchor_point" type="QString"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option value="" name="name" type="QString"/>
                  <Option name="properties"/>
                  <Option value="collection" name="type" type="QString"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="1" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{87d44703-0966-4a09-abdd-1f3b95e8e1bb}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="round" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="round" name="joinstyle" type="QString"/>
            <Option value="0,0,0,255,hsv:0,0,0,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.08" name="line_width" type="QString"/>
            <Option value="MapUnit" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="2" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{87d44703-0966-4a09-abdd-1f3b95e8e1bb}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="round" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="round" name="joinstyle" type="QString"/>
            <Option value="175,166,161,255,hsv:0.05555555555555555,0.07759212634470131,0.68627450980392157,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.08" name="line_width" type="QString"/>
            <Option value="MapUnit" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="3" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{f9301c44-6e52-4c93-954a-fdef2696a4ff}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="round" name="capstyle" type="QString"/>
            <Option value="0.66;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MM" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="round" name="joinstyle" type="QString"/>
            <Option value="84,176,74,255,rgb:0.3294118,0.6901961,0.2901961,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.66" name="line_width" type="QString"/>
            <Option value="MM" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="1" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="4" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{87d44703-0966-4a09-abdd-1f3b95e8e1bb}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="round" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="round" name="joinstyle" type="QString"/>
            <Option value="24,158,23,255,rgb:0.0950484,0.6196078,0.0901961,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.08" name="line_width" type="QString"/>
            <Option value="MapUnit" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="5" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{87d44703-0966-4a09-abdd-1f3b95e8e1bb}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="round" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="round" name="joinstyle" type="QString"/>
            <Option value="0,0,0,255,hsv:0,0,0,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.05" name="line_width" type="QString"/>
            <Option value="MapUnit" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="6" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{87d44703-0966-4a09-abdd-1f3b95e8e1bb}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="square" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MM" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="255,0,4,255,hsv:0.99722222222222223,1,1,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.26" name="line_width" type="QString"/>
            <Option value="MM" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <data-defined-properties>
      <Option type="Map">
        <Option value="" name="name" type="QString"/>
        <Option name="properties"/>
        <Option value="collection" name="type" type="QString"/>
      </Option>
    </data-defined-properties>
  </renderer-v2>
  <selection mode="Default">
    <selectionColor invalid="1"/>
    <selectionSymbol>
      <symbol clip_to_extent="1" is_animated="0" alpha="1" force_rhr="0" frame_rate="10" name="" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{e26e1cea-cf39-4a76-aafd-c9f342fb06ae}" class="SimpleLine" locked="0" pass="0">
          <Option type="Map">
            <Option value="0" name="align_dash_pattern" type="QString"/>
            <Option value="square" name="capstyle" type="QString"/>
            <Option value="5;2" name="customdash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="customdash_map_unit_scale" type="QString"/>
            <Option value="MM" name="customdash_unit" type="QString"/>
            <Option value="0" name="dash_pattern_offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="dash_pattern_offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="dash_pattern_offset_unit" type="QString"/>
            <Option value="0" name="draw_inside_polygon" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.26" name="line_width" type="QString"/>
            <Option value="MM" name="line_width_unit" type="QString"/>
            <Option value="0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="0" name="ring_filter" type="QString"/>
            <Option value="0" name="trim_distance_end" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_end_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_end_unit" type="QString"/>
            <Option value="0" name="trim_distance_start" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="trim_distance_start_map_unit_scale" type="QString"/>
            <Option value="MM" name="trim_distance_start_unit" type="QString"/>
            <Option value="0" name="tweak_dash_pattern_on_corners" type="QString"/>
            <Option value="0" name="use_custom_dash" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="width_map_unit_scale" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
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
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
            <Option value="true" name="allow_null" type="bool"/>
            <Option value="true" name="calendar_popup" type="bool"/>
            <Option value="dd.MM.yyyy HH:mm:ss" name="display_format" type="QString"/>
            <Option value="yyyy-MM-dd HH:mm:ss" name="field_format" type="QString"/>
            <Option value="false" name="field_format_overwrite" type="bool"/>
            <Option value="false" name="field_iso_format" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="AbutmentType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option name="Description" type="invalid"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option value="CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression" type="QString"/>
            <Option name="Group" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="_______________________________ca745bc7_08bb_484e_9b6b_08e3c6c38da7" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО) Элементы сопряжения" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;AbutmentType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Material">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="false" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option value="" name="Description" type="QString"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option value="array_contains( string_to_array( replace(&quot;TaskTypeId&quot;, array('[', ']'), '')), @MggtAsuTaskType)" name="FilterExpression" type="QString"/>
            <Option value="" name="Group" type="QString"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="_________________________________07543f06_b2d5_4861_a672_ebf8ff740d1e" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Материалы" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="false" name="OrderByDescending" type="bool"/>
            <Option value="false" name="OrderByField" type="bool"/>
            <Option value="" name="OrderByFieldName" type="QString"/>
            <Option value="true" name="OrderByKey" type="bool"/>
            <Option value="false" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Distance">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="1e+06" name="Max" type="double"/>
            <Option value="0" name="Min" type="double"/>
            <Option value="2" name="Precision" type="int"/>
            <Option value="1" name="Step" type="double"/>
            <Option value="SpinBox" name="Style" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="NoCalc">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowNullState" type="bool"/>
            <Option name="CheckedState" type="invalid"/>
            <Option value="0" name="TextDisplayMethod" type="int"/>
            <Option name="UncheckedState" type="invalid"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsDiffHeightMark">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowNullState" type="bool"/>
            <Option name="CheckedState" type="invalid"/>
            <Option value="0" name="TextDisplayMethod" type="int"/>
            <Option name="UncheckedState" type="invalid"/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" name="" index="0"/>
    <alias field="OghObjectType" name="" index="1"/>
    <alias field="ObjectId" name="" index="2"/>
    <alias field="RootId" name="" index="3"/>
    <alias field="StartDate" name="" index="4"/>
    <alias field="EndDate" name="" index="5"/>
    <alias field="AbutmentType" name="Тип элемента сопряжения" index="6"/>
    <alias field="Material" name="" index="7"/>
    <alias field="Distance" name="" index="8"/>
    <alias field="NoCalc" name="Не учитывать" index="9"/>
    <alias field="IsDiffHeightMark" name="Разновысотные отметки" index="10"/>
    <alias field="ParentOghObjectType" name="" index="11"/>
    <alias field="ParentObjectId" name="" index="12"/>
    <alias field="ParentRootId" name="" index="13"/>
    <alias field="ParentStartDate" name="" index="14"/>
    <alias field="ParentEndDate" name="" index="15"/>
    <alias field="CreateDate" name="" index="16"/>
    <alias field="CreateAuthor" name="" index="17"/>
    <alias field="ChangeDate" name="" index="18"/>
    <alias field="ChangeAuthor" name="" index="19"/>
    <alias field="TaskGUID" name="" index="20"/>
  </aliases>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="AbutmentType"/>
    <default expression="'concrete'" applyOnUpdate="0" field="Material"/>
    <default expression="" applyOnUpdate="0" field="Distance"/>
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
  </defaults>
  <constraints>
    <constraint notnull_strength="1" unique_strength="1" constraints="3" field="fid" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="OghObjectType" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ObjectId" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="RootId" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="StartDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="EndDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="AbutmentType" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="Material" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="Distance" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="NoCalc" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="IsDiffHeightMark" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ParentOghObjectType" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ParentObjectId" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ParentRootId" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ParentStartDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ParentEndDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="CreateDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="CreateAuthor" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ChangeDate" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="ChangeAuthor" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" constraints="0" field="TaskGUID" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="AbutmentType"/>
    <constraint desc="" exp="" field="Material"/>
    <constraint desc="" exp="" field="Distance"/>
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
    <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
      <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
    </labelStyle>
    <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="RootId" index="3">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer horizontalStretch="0" verticalStretch="0" collapsedExpression="" showLabel="1" collapsedExpressionEnabled="0" columnCount="4" name="Назначение" visibilityExpressionEnabled="0" collapsed="0" visibilityExpression="" groupBox="1" type="GroupBox">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="AbutmentType" index="6">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="Material" index="7">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer horizontalStretch="0" verticalStretch="0" collapsedExpression="" showLabel="1" collapsedExpressionEnabled="0" columnCount="4" name="Параметры" visibilityExpressionEnabled="0" collapsed="0" visibilityExpression="" groupBox="1" type="GroupBox">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="Distance" index="8">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="NoCalc" index="9">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" showLabel="1" name="IsDiffHeightMark" index="10">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement horizontalStretch="0" verticalStretch="0" showLabel="0" drawLine="0" name="Spacer Widget">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" strikethrough="0" bold="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" underline="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="AbutmentType"/>
    <field editable="1" name="Area"/>
    <field editable="1" name="AutoCleanArea"/>
    <field editable="1" name="AxisGeometry"/>
    <field editable="1" name="BordBegin"/>
    <field editable="1" name="BordEnd"/>
    <field editable="1" name="BoundStoneMark"/>
    <field editable="1" name="ChangeAuthor"/>
    <field editable="1" name="ChangeDate"/>
    <field editable="1" name="CoatingGroup"/>
    <field editable="1" name="CoatingType"/>
    <field editable="1" name="CreateAuthor"/>
    <field editable="1" name="CreateDate"/>
    <field editable="1" name="Description"/>
    <field editable="1" name="Distance"/>
    <field editable="1" name="EndDate"/>
    <field editable="1" name="FlatElementType"/>
    <field editable="1" name="IsDiffHeightMark"/>
    <field editable="1" name="IsGutterZone"/>
    <field editable="1" name="ManualCleanArea"/>
    <field editable="1" name="Material"/>
    <field editable="1" name="NearRoadway"/>
    <field editable="1" name="NoCalc"/>
    <field editable="1" name="NoCleanArea"/>
    <field editable="1" name="ObjectId"/>
    <field editable="1" name="OdhAxis"/>
    <field editable="1" name="OdhSide"/>
    <field editable="1" name="OghObjectType"/>
    <field editable="1" name="ParentEndDate"/>
    <field editable="1" name="ParentObjectId"/>
    <field editable="1" name="ParentOghObjectType"/>
    <field editable="1" name="ParentRootId"/>
    <field editable="1" name="ParentStartDate"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="StartDate"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="WidthBegin"/>
    <field editable="1" name="WidthEnd"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="AbutmentType"/>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="1" name="AutoCleanArea"/>
    <field labelOnTop="0" name="AxisGeometry"/>
    <field labelOnTop="1" name="BordBegin"/>
    <field labelOnTop="1" name="BordEnd"/>
    <field labelOnTop="1" name="BoundStoneMark"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CoatingGroup"/>
    <field labelOnTop="1" name="CoatingType"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="1" name="Description"/>
    <field labelOnTop="1" name="Distance"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="1" name="FlatElementType"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="IsGutterZone"/>
    <field labelOnTop="1" name="ManualCleanArea"/>
    <field labelOnTop="1" name="Material"/>
    <field labelOnTop="1" name="NearRoadway"/>
    <field labelOnTop="1" name="NoCalc"/>
    <field labelOnTop="1" name="NoCleanArea"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="1" name="OdhAxis"/>
    <field labelOnTop="1" name="OdhSide"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="WidthBegin"/>
    <field labelOnTop="1" name="WidthEnd"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="AbutmentType"/>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="AutoCleanArea"/>
    <field reuseLastValue="0" name="AxisGeometry"/>
    <field reuseLastValue="0" name="BordBegin"/>
    <field reuseLastValue="0" name="BordEnd"/>
    <field reuseLastValue="0" name="BoundStoneMark"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CoatingGroup"/>
    <field reuseLastValue="0" name="CoatingType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="Description"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsGutterZone"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
    <field reuseLastValue="0" name="Material"/>
    <field reuseLastValue="0" name="NearRoadway"/>
    <field reuseLastValue="0" name="NoCalc"/>
    <field reuseLastValue="0" name="NoCleanArea"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OdhAxis"/>
    <field reuseLastValue="0" name="OdhSide"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="WidthBegin"/>
    <field reuseLastValue="0" name="WidthEnd"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
