<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.38.0-Grenoble" styleCategories="LayerConfiguration|Symbology|Labeling|Fields|Forms|Rendering" labelsEnabled="0" simplifyDrawingHints="1" minScale="100000000" readOnly="0" symbologyReferenceScale="-1" simplifyDrawingTol="1" simplifyAlgorithm="0" simplifyLocal="1" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyMaxScale="1">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <renderer-v2 referencescale="-1" enableorderby="0" forceraster="0" type="RuleRenderer" symbollevels="0">
    <rules key="{0d6368f3-3d21-4338-83a9-615a09efa28e}">
      <rule label="Укрепленное засевом трав" symbol="0" filter=" &quot;MarginStrengType&quot; = '1'" key="{af2c1070-61ee-4909-a01f-3a6b93d3ed26}"/>
      <rule label="Неукрепленное" symbol="1" filter=" &quot;MarginStrengType&quot; = '2'" key="{992af083-dc0d-4d67-8c92-7c5e770e7988}"/>
      <rule label="Цементобетон" symbol="2" filter=" &quot;MarginStrengType&quot; = '3'" key="{20903eb2-e70d-439f-a632-b8faa52c7f72}"/>
      <rule label="Укрепленное гравием/щебнем" symbol="3" filter=" &quot;MarginStrengType&quot; = '5'" key="{5773c1b7-ac20-4e25-a860-036edb5e1986}"/>
      <rule label="Асфальтобетон, асфальтобетонная крошка" symbol="4" filter=" &quot;MarginStrengType&quot; = '7'" key="{0c8738dd-a35e-4173-af9d-29200c5d6f57}"/>
      <rule label="Укрепленное песчано-гравийной смесью" symbol="5" filter=" &quot;MarginStrengType&quot; = '8'" key="{ea426b42-009d-4a45-ac4f-372c11c62a1d}"/>
      <rule label="Нет данных" symbol="6" filter="ELSE" key="{38e79c72-5b4a-4348-974e-f2ed061054ff}"/>
    </rules>
    <symbols>
      <symbol frame_rate="10" is_animated="0" name="0" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{7f66b357-23f9-46dc-b98e-79f81ff85685}" class="SimpleFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="0,216,79,255,hsv:0.39444444444444443,1,0.84705882352941175,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="1" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{a577ca75-aab7-4783-8ce4-a912d125678e}" class="PointPatternFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="0" name="angle" type="double"/>
            <Option value="shape" name="clip_mode" type="QString"/>
            <Option value="feature" name="coordinate_reference" type="QString"/>
            <Option value="1.2" name="displacement_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_x_unit" type="QString"/>
            <Option value="0" name="displacement_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_y_unit" type="QString"/>
            <Option value="2.4" name="distance_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_x_unit" type="QString"/>
            <Option value="2.4" name="distance_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_y_unit" type="QString"/>
            <Option value="0" name="offset_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_x_unit" type="QString"/>
            <Option value="0" name="offset_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_y_unit" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="0" name="random_deviation_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_x_unit" type="QString"/>
            <Option value="0" name="random_deviation_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_y_unit" type="QString"/>
            <Option value="640430099" name="seed" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
          <symbol frame_rate="10" is_animated="0" name="@1@0" clip_to_extent="1" type="marker" force_rhr="0" alpha="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" name="name" type="QString"/>
                <Option name="properties"/>
                <Option value="collection" name="type" type="QString"/>
              </Option>
            </data_defined_properties>
            <layer pass="0" id="{54bffee4-42c5-4f43-afbb-fe70c27296d6}" class="SimpleMarker" locked="0" enabled="1">
              <Option type="Map">
                <Option value="0" name="angle" type="QString"/>
                <Option value="square" name="cap_style" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="color" type="QString"/>
                <Option value="1" name="horizontal_anchor_point" type="QString"/>
                <Option value="bevel" name="joinstyle" type="QString"/>
                <Option value="circle" name="name" type="QString"/>
                <Option value="0,0" name="offset" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
                <Option value="MM" name="offset_unit" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="outline_color" type="QString"/>
                <Option value="solid" name="outline_style" type="QString"/>
                <Option value="0.2" name="outline_width" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
                <Option value="MM" name="outline_width_unit" type="QString"/>
                <Option value="diameter" name="scale_method" type="QString"/>
                <Option value="0.6" name="size" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
                <Option value="MM" name="size_unit" type="QString"/>
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
        <layer pass="0" id="{55c728b5-5167-405a-86ad-bc9f96ae80fa}" class="SimpleLine" locked="0" enabled="1">
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
            <Option value="0,0,0,255,rgb:0,0,0,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.36" name="line_width" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="2" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{7f66b357-23f9-46dc-b98e-79f81ff85685}" class="SimpleFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="200,200,200,255,hsv:0.07777777777777778,0,0.78431372549019607,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="3" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{30965ccf-9d30-4ced-9e74-d40f4c625309}" class="PointPatternFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="0" name="angle" type="double"/>
            <Option value="shape" name="clip_mode" type="QString"/>
            <Option value="feature" name="coordinate_reference" type="QString"/>
            <Option value="1.2" name="displacement_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_x_unit" type="QString"/>
            <Option value="0" name="displacement_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_y_unit" type="QString"/>
            <Option value="2.4" name="distance_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_x_unit" type="QString"/>
            <Option value="2.4" name="distance_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_y_unit" type="QString"/>
            <Option value="0" name="offset_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_x_unit" type="QString"/>
            <Option value="0" name="offset_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_y_unit" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="0" name="random_deviation_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_x_unit" type="QString"/>
            <Option value="0" name="random_deviation_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_y_unit" type="QString"/>
            <Option value="640430099" name="seed" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
          <symbol frame_rate="10" is_animated="0" name="@3@0" clip_to_extent="1" type="marker" force_rhr="0" alpha="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" name="name" type="QString"/>
                <Option name="properties"/>
                <Option value="collection" name="type" type="QString"/>
              </Option>
            </data_defined_properties>
            <layer pass="0" id="{2b5c6017-4091-4167-8f98-e00e414560fb}" class="SimpleMarker" locked="0" enabled="1">
              <Option type="Map">
                <Option value="0" name="angle" type="QString"/>
                <Option value="square" name="cap_style" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="color" type="QString"/>
                <Option value="1" name="horizontal_anchor_point" type="QString"/>
                <Option value="bevel" name="joinstyle" type="QString"/>
                <Option value="circle" name="name" type="QString"/>
                <Option value="0,0" name="offset" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
                <Option value="MM" name="offset_unit" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="outline_color" type="QString"/>
                <Option value="solid" name="outline_style" type="QString"/>
                <Option value="0.2" name="outline_width" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
                <Option value="MM" name="outline_width_unit" type="QString"/>
                <Option value="diameter" name="scale_method" type="QString"/>
                <Option value="1" name="size" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
                <Option value="MM" name="size_unit" type="QString"/>
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
        <layer pass="0" id="{70e212b7-cd1a-4994-b93f-4c16d159ac14}" class="SimpleLine" locked="0" enabled="1">
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
            <Option value="0,0,0,255,rgb:0,0,0,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.36" name="line_width" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="4" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{7f66b357-23f9-46dc-b98e-79f81ff85685}" class="SimpleFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="124,124,124,255,hsv:0.07777777777777778,0,0.48627450980392156,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="5" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{30965ccf-9d30-4ced-9e74-d40f4c625309}" class="PointPatternFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="0" name="angle" type="double"/>
            <Option value="shape" name="clip_mode" type="QString"/>
            <Option value="feature" name="coordinate_reference" type="QString"/>
            <Option value="1.2" name="displacement_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_x_unit" type="QString"/>
            <Option value="0" name="displacement_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="displacement_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="displacement_y_unit" type="QString"/>
            <Option value="2.4" name="distance_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_x_unit" type="QString"/>
            <Option value="2.4" name="distance_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="distance_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="distance_y_unit" type="QString"/>
            <Option value="0" name="offset_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_x_unit" type="QString"/>
            <Option value="0" name="offset_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_y_unit" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="0" name="random_deviation_x" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_x_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_x_unit" type="QString"/>
            <Option value="0" name="random_deviation_y" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="random_deviation_y_map_unit_scale" type="QString"/>
            <Option value="MM" name="random_deviation_y_unit" type="QString"/>
            <Option value="640430099" name="seed" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties"/>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
          <symbol frame_rate="10" is_animated="0" name="@5@0" clip_to_extent="1" type="marker" force_rhr="0" alpha="1">
            <data_defined_properties>
              <Option type="Map">
                <Option value="" name="name" type="QString"/>
                <Option name="properties"/>
                <Option value="collection" name="type" type="QString"/>
              </Option>
            </data_defined_properties>
            <layer pass="0" id="{2b5c6017-4091-4167-8f98-e00e414560fb}" class="SimpleMarker" locked="0" enabled="1">
              <Option type="Map">
                <Option value="0" name="angle" type="QString"/>
                <Option value="square" name="cap_style" type="QString"/>
                <Option value="204,177,2,255,hsv:0.14444444444444443,0.99215686274509807,0.80000000000000004,1" name="color" type="QString"/>
                <Option value="1" name="horizontal_anchor_point" type="QString"/>
                <Option value="bevel" name="joinstyle" type="QString"/>
                <Option value="circle" name="name" type="QString"/>
                <Option value="0,0" name="offset" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
                <Option value="MM" name="offset_unit" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="outline_color" type="QString"/>
                <Option value="solid" name="outline_style" type="QString"/>
                <Option value="0.2" name="outline_width" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
                <Option value="MM" name="outline_width_unit" type="QString"/>
                <Option value="diameter" name="scale_method" type="QString"/>
                <Option value="1" name="size" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
                <Option value="MM" name="size_unit" type="QString"/>
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
        <layer pass="0" id="{70e212b7-cd1a-4994-b93f-4c16d159ac14}" class="SimpleLine" locked="0" enabled="1">
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
            <Option value="0,0,0,255,rgb:0,0,0,1" name="line_color" type="QString"/>
            <Option value="solid" name="line_style" type="QString"/>
            <Option value="0.36" name="line_width" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="6" clip_to_extent="1" type="fill" force_rhr="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{7f66b357-23f9-46dc-b98e-79f81ff85685}" class="SimpleFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="222,0,0,255,hsv:0,1,0.87058823529411766,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="" clip_to_extent="1" type="fill" force_rhr="0" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" id="{638fe97a-5a4c-414a-bb4e-109559aff833}" class="SimpleFill" locked="0" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option value=" &quot;OghObjectType&quot; = 14" name="FilterExpression" type="QString"/>
            <Option value="OghObjectTypeName" name="Key" type="QString"/>
            <Option value="______________________________c9413591_1d84_4b51_b346_110cfe011632" name="Layer" type="QString"/>
            <Option value="Справочник (ОДХ) Тип проезжей части" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;FlatElementType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="FlatElementType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option name="Description" type="invalid"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option value=" &quot;OghObjectType&quot; = 23" name="FilterExpression" type="QString"/>
            <Option name="Group" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="______________________________08c36b74_0488_48ec_a88b_4eda76224862" name="Layer" type="QString"/>
            <Option value="Справочник (ОДХ) Тип проезжей части" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;FlatElementType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhSide">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option name="Description" type="invalid"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="______________________________________4fe1abc0_0864_4d35_aaf6_5a9bfe4d54fe" name="Layer" type="QString"/>
            <Option value="Справочник (ОДХ) Код стороны проезжей части" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;OdhSide&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhAxis">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="BordBegin">
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
    <field configurationFlags="NoFlag" name="BordEnd">
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
    <field configurationFlags="NoFlag" name="MarginStrengType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option name="Description" type="invalid"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="___________________________________fb943a25_fb75_4637_9f46_875a4c89341e" name="Layer" type="QString"/>
            <Option value="Справочник (ОДХ) Типы укрепления обочины" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MarginStrengType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="false" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingGroup">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="2" name="CompleterMatchFlags" type="int"/>
            <Option name="Description" type="invalid"/>
            <Option value="false" name="DisplayGroupName" type="bool"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="___________________________935709d1_2a82_4f9a_9ca2_810cb45262a5" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Группы покрытий" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CoatingTypeGroup&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
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
    <field configurationFlags="NoFlag" name="WidthBegin">
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
    <field configurationFlags="NoFlag" name="WidthEnd">
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
    <field configurationFlags="NoFlag" name="AutoCleanArea">
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
    <field configurationFlags="NoFlag" name="ManualCleanArea">
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
    <field configurationFlags="NoFlag" name="NoCleanArea">
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
    <field configurationFlags="NoFlag" name="Description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="true" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
  </fieldConfiguration>
  <aliases>
    <alias field="fid" name="" index="0"/>
    <alias field="OghObjectType" name="" index="1"/>
    <alias field="ObjectId" name="" index="2"/>
    <alias field="RootId" name="" index="3"/>
    <alias field="StartDate" name="" index="4"/>
    <alias field="EndDate" name="" index="5"/>
    <alias field="FlatElementType" name="Тип обочины" index="6"/>
    <alias field="OdhSide" name="Сторона оси" index="7"/>
    <alias field="OdhAxis" name="Ось" index="8"/>
    <alias field="BordBegin" name="Начало" index="9"/>
    <alias field="BordEnd" name="Конец" index="10"/>
    <alias field="MarginStrengType" name="Тип укрепления" index="11"/>
    <alias field="CoatingGroup" name="Группа укрепления" index="12"/>
    <alias field="Area" name="Площадь" index="13"/>
    <alias field="Distance" name="Длина" index="14"/>
    <alias field="WidthBegin" name="Ширина в начале" index="15"/>
    <alias field="WidthEnd" name="Ширина в конце" index="16"/>
    <alias field="AutoCleanArea" name="Площадь уборки механизированная" index="17"/>
    <alias field="ManualCleanArea" name="Площадь уборки ручная" index="18"/>
    <alias field="NoCleanArea" name="Площадь без уборки" index="19"/>
    <alias field="Description" name="Примечание" index="20"/>
    <alias field="IsDiffHeightMark" name="Разновысотные отметки" index="21"/>
    <alias field="ParentOghObjectType" name="" index="22"/>
    <alias field="ParentObjectId" name="" index="23"/>
    <alias field="ParentRootId" name="" index="24"/>
    <alias field="ParentStartDate" name="" index="25"/>
    <alias field="ParentEndDate" name="" index="26"/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="Duplicate"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="FlatElementType" policy="Duplicate"/>
    <policy field="OdhSide" policy="Duplicate"/>
    <policy field="OdhAxis" policy="Duplicate"/>
    <policy field="BordBegin" policy="Duplicate"/>
    <policy field="BordEnd" policy="Duplicate"/>
    <policy field="MarginStrengType" policy="Duplicate"/>
    <policy field="CoatingGroup" policy="Duplicate"/>
    <policy field="Area" policy="Duplicate"/>
    <policy field="Distance" policy="Duplicate"/>
    <policy field="WidthBegin" policy="Duplicate"/>
    <policy field="WidthEnd" policy="Duplicate"/>
    <policy field="AutoCleanArea" policy="Duplicate"/>
    <policy field="ManualCleanArea" policy="Duplicate"/>
    <policy field="NoCleanArea" policy="Duplicate"/>
    <policy field="Description" policy="Duplicate"/>
    <policy field="IsDiffHeightMark" policy="Duplicate"/>
    <policy field="ParentOghObjectType" policy="Duplicate"/>
    <policy field="ParentObjectId" policy="Duplicate"/>
    <policy field="ParentRootId" policy="Duplicate"/>
    <policy field="ParentStartDate" policy="Duplicate"/>
    <policy field="ParentEndDate" policy="Duplicate"/>
  </splitPolicies>
  <duplicatePolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="Duplicate"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="FlatElementType" policy="Duplicate"/>
    <policy field="OdhSide" policy="Duplicate"/>
    <policy field="OdhAxis" policy="Duplicate"/>
    <policy field="BordBegin" policy="Duplicate"/>
    <policy field="BordEnd" policy="Duplicate"/>
    <policy field="MarginStrengType" policy="Duplicate"/>
    <policy field="CoatingGroup" policy="Duplicate"/>
    <policy field="Area" policy="Duplicate"/>
    <policy field="Distance" policy="Duplicate"/>
    <policy field="WidthBegin" policy="Duplicate"/>
    <policy field="WidthEnd" policy="Duplicate"/>
    <policy field="AutoCleanArea" policy="Duplicate"/>
    <policy field="ManualCleanArea" policy="Duplicate"/>
    <policy field="NoCleanArea" policy="Duplicate"/>
    <policy field="Description" policy="Duplicate"/>
    <policy field="IsDiffHeightMark" policy="Duplicate"/>
    <policy field="ParentOghObjectType" policy="Duplicate"/>
    <policy field="ParentObjectId" policy="Duplicate"/>
    <policy field="ParentRootId" policy="Duplicate"/>
    <policy field="ParentStartDate" policy="Duplicate"/>
    <policy field="ParentEndDate" policy="Duplicate"/>
  </duplicatePolicies>
  <defaults>
    <default expression="" field="fid" applyOnUpdate="0"/>
    <default expression="" field="OghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ObjectId" applyOnUpdate="0"/>
    <default expression="" field="RootId" applyOnUpdate="0"/>
    <default expression="" field="StartDate" applyOnUpdate="0"/>
    <default expression="" field="EndDate" applyOnUpdate="0"/>
    <default expression="" field="FlatElementType" applyOnUpdate="0"/>
    <default expression="" field="OdhSide" applyOnUpdate="0"/>
    <default expression="" field="OdhAxis" applyOnUpdate="0"/>
    <default expression="" field="BordBegin" applyOnUpdate="0"/>
    <default expression="" field="BordEnd" applyOnUpdate="0"/>
    <default expression="" field="MarginStrengType" applyOnUpdate="0"/>
    <default expression="" field="CoatingGroup" applyOnUpdate="0"/>
    <default expression="" field="Area" applyOnUpdate="0"/>
    <default expression="" field="Distance" applyOnUpdate="0"/>
    <default expression="" field="WidthBegin" applyOnUpdate="0"/>
    <default expression="" field="WidthEnd" applyOnUpdate="0"/>
    <default expression="" field="AutoCleanArea" applyOnUpdate="0"/>
    <default expression="" field="ManualCleanArea" applyOnUpdate="0"/>
    <default expression="" field="NoCleanArea" applyOnUpdate="0"/>
    <default expression="" field="Description" applyOnUpdate="0"/>
    <default expression="" field="IsDiffHeightMark" applyOnUpdate="0"/>
    <default expression="" field="ParentOghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ParentObjectId" applyOnUpdate="0"/>
    <default expression="" field="ParentRootId" applyOnUpdate="0"/>
    <default expression="" field="ParentStartDate" applyOnUpdate="0"/>
    <default expression="" field="ParentEndDate" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint field="fid" unique_strength="1" constraints="3" exp_strength="0" notnull_strength="1"/>
    <constraint field="OghObjectType" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ObjectId" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="RootId" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="StartDate" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="EndDate" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="FlatElementType" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="OdhSide" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="OdhAxis" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="BordBegin" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="BordEnd" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="MarginStrengType" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="CoatingGroup" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="Area" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="Distance" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="WidthBegin" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="WidthEnd" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="AutoCleanArea" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ManualCleanArea" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="NoCleanArea" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="Description" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="IsDiffHeightMark" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ParentOghObjectType" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ParentObjectId" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ParentRootId" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ParentStartDate" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
    <constraint field="ParentEndDate" unique_strength="0" constraints="0" exp_strength="0" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" exp="" desc=""/>
    <constraint field="OghObjectType" exp="" desc=""/>
    <constraint field="ObjectId" exp="" desc=""/>
    <constraint field="RootId" exp="" desc=""/>
    <constraint field="StartDate" exp="" desc=""/>
    <constraint field="EndDate" exp="" desc=""/>
    <constraint field="FlatElementType" exp="" desc=""/>
    <constraint field="OdhSide" exp="" desc=""/>
    <constraint field="OdhAxis" exp="" desc=""/>
    <constraint field="BordBegin" exp="" desc=""/>
    <constraint field="BordEnd" exp="" desc=""/>
    <constraint field="MarginStrengType" exp="" desc=""/>
    <constraint field="CoatingGroup" exp="" desc=""/>
    <constraint field="Area" exp="" desc=""/>
    <constraint field="Distance" exp="" desc=""/>
    <constraint field="WidthBegin" exp="" desc=""/>
    <constraint field="WidthEnd" exp="" desc=""/>
    <constraint field="AutoCleanArea" exp="" desc=""/>
    <constraint field="ManualCleanArea" exp="" desc=""/>
    <constraint field="NoCleanArea" exp="" desc=""/>
    <constraint field="Description" exp="" desc=""/>
    <constraint field="IsDiffHeightMark" exp="" desc=""/>
    <constraint field="ParentOghObjectType" exp="" desc=""/>
    <constraint field="ParentObjectId" exp="" desc=""/>
    <constraint field="ParentRootId" exp="" desc=""/>
    <constraint field="ParentStartDate" exp="" desc=""/>
    <constraint field="ParentEndDate" exp="" desc=""/>
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
      <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField name="RootId" horizontalStretch="0" showLabel="1" verticalStretch="0" index="3">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer visibilityExpressionEnabled="0" collapsed="0" collapsedExpressionEnabled="0" visibilityExpression="" name="Назначение" horizontalStretch="0" showLabel="1" verticalStretch="0" columnCount="4" type="GroupBox" collapsedExpression="" groupBox="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="FlatElementType" horizontalStretch="0" showLabel="1" verticalStretch="0" index="6">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="MarginStrengType" horizontalStretch="0" showLabel="1" verticalStretch="0" index="11">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="CoatingGroup" horizontalStretch="0" showLabel="1" verticalStretch="0" index="12">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsDiffHeightMark" horizontalStretch="0" showLabel="1" verticalStretch="0" index="21">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpressionEnabled="0" collapsed="0" collapsedExpressionEnabled="0" visibilityExpression="" name="Привязка" horizontalStretch="0" showLabel="1" verticalStretch="0" columnCount="4" type="GroupBox" collapsedExpression="" groupBox="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="OdhAxis" horizontalStretch="0" showLabel="1" verticalStretch="0" index="8">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="OdhSide" horizontalStretch="0" showLabel="1" verticalStretch="0" index="7">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="BordBegin" horizontalStretch="0" showLabel="1" verticalStretch="0" index="9">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="BordEnd" horizontalStretch="0" showLabel="1" verticalStretch="0" index="10">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpressionEnabled="0" collapsed="0" collapsedExpressionEnabled="0" visibilityExpression="" name="Линейные параметры" horizontalStretch="0" showLabel="1" verticalStretch="0" columnCount="3" type="GroupBox" collapsedExpression="" groupBox="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="Distance" horizontalStretch="0" showLabel="1" verticalStretch="0" index="14">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="WidthBegin" horizontalStretch="0" showLabel="1" verticalStretch="0" index="15">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="WidthEnd" horizontalStretch="0" showLabel="1" verticalStretch="0" index="16">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpressionEnabled="0" collapsed="0" collapsedExpressionEnabled="0" visibilityExpression="" name="Параметры" horizontalStretch="0" showLabel="1" verticalStretch="0" columnCount="6" type="GroupBox" collapsedExpression="" groupBox="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="Area" horizontalStretch="0" showLabel="1" verticalStretch="0" index="13">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="AutoCleanArea" horizontalStretch="0" showLabel="1" verticalStretch="0" index="17">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="ManualCleanArea" horizontalStretch="0" showLabel="1" verticalStretch="0" index="18">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="NoCleanArea" horizontalStretch="0" showLabel="1" verticalStretch="0" index="19">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpressionEnabled="0" collapsed="0" collapsedExpressionEnabled="0" visibilityExpression="" name="Примечание" horizontalStretch="0" showLabel="1" verticalStretch="0" columnCount="1" type="GroupBox" collapsedExpression="" groupBox="1">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="Description" horizontalStretch="0" showLabel="0" verticalStretch="0" index="20">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement name="SpacerWidget" horizontalStretch="0" drawLine="0" showLabel="0" verticalStretch="0">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" underline="0" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
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
    <field name="FlatElementType" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="ManualCleanArea" editable="1"/>
    <field name="MarginStrengType" editable="1"/>
    <field name="NoCleanArea" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OdhAxis" editable="1"/>
    <field name="OdhSide" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="OotCleanArea" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="UtnArea" editable="1"/>
    <field name="WidthBegin" editable="1"/>
    <field name="WidthEnd" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="Area" labelOnTop="1"/>
    <field name="AutoCleanArea" labelOnTop="1"/>
    <field name="AxisGeometry" labelOnTop="0"/>
    <field name="BordBegin" labelOnTop="1"/>
    <field name="BordEnd" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CoatingGroup" labelOnTop="1"/>
    <field name="CoatingType" labelOnTop="1"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="Description" labelOnTop="1"/>
    <field name="Distance" labelOnTop="1"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FlatElementType" labelOnTop="1"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="ManualCleanArea" labelOnTop="1"/>
    <field name="MarginStrengType" labelOnTop="1"/>
    <field name="NoCleanArea" labelOnTop="1"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="OdhAxis" labelOnTop="1"/>
    <field name="OdhSide" labelOnTop="1"/>
    <field name="OghObjectType" labelOnTop="1"/>
    <field name="OotCleanArea" labelOnTop="1"/>
    <field name="ParentEndDate" labelOnTop="0"/>
    <field name="ParentObjectId" labelOnTop="0"/>
    <field name="ParentOghObjectType" labelOnTop="0"/>
    <field name="ParentRootId" labelOnTop="0"/>
    <field name="ParentStartDate" labelOnTop="0"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="UtnArea" labelOnTop="1"/>
    <field name="WidthBegin" labelOnTop="1"/>
    <field name="WidthEnd" labelOnTop="1"/>
    <field name="fid" labelOnTop="0"/>
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
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
    <field reuseLastValue="0" name="MarginStrengType"/>
    <field reuseLastValue="0" name="NoCleanArea"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OdhAxis"/>
    <field reuseLastValue="0" name="OdhSide"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="OotCleanArea"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="UtnArea"/>
    <field reuseLastValue="0" name="WidthBegin"/>
    <field reuseLastValue="0" name="WidthEnd"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"Description"</previewExpression>
  <layerGeometryType>2</layerGeometryType>
</qgis>
