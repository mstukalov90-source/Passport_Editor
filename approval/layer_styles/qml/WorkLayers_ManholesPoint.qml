<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis symbologyReferenceScale="-1" maxScale="0" minScale="100000000" simplifyAlgorithm="0" autoRefreshTime="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyDrawingTol="1" simplifyLocal="1" simplifyMaxScale="1" simplifyDrawingHints="0" hasScaleBasedVisibilityFlag="0" autoRefreshMode="Disabled" version="3.44.8-Solothurn" labelsEnabled="0">
  <renderer-v2 forceraster="0" symbollevels="0" referencescale="-1" enableorderby="0" type="RuleRenderer">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule symbol="0" label="Точки привязки" key="{55ba3164-5d8a-4869-879a-8e2f6edb4dd7}" filter="&quot;fid&quot; is not NULL" checkstate="0"/>
      <rule symbol="1" label="Люк подземных коммуникаций" key="{d99032f9-33df-4c2c-b237-403044376c80}" filter=" &quot;Accessory&quot; = 'v'"/>
      <rule symbol="2" label="Люк подземных коммуникаций" key="{243685b5-8ecf-4978-a9cc-db5384667e59}" filter=" &quot;Accessory&quot; ='vd'"/>
      <rule symbol="3" label="Люк подземных коммуникаций" key="{82670cb0-789c-47f9-bb9d-fc92b792956e}" filter=" &quot;Accessory&quot; = 'vk'"/>
      <rule symbol="4" label="Люк подземных коммуникаций" key="{2b72c0e2-4d63-4339-8086-9005feddf83d}" filter=" &quot;Accessory&quot; in  ('vks','g','geoprom','gks', 'gs', 'zbk', 'k', 'kk', 'kover', 'mks', 'mosenergo','me', 'telefon', 'tm', 'tc')"/>
      <rule symbol="5" label="Люк подземных коммуникаций" key="{d507f979-caa2-47a7-bc0b-5d7eb1428083}" filter=" &quot;Accessory&quot; = 'vodostok'"/>
      <rule symbol="6" label="Люк подземных коммуникаций" key="{c3cc0ca4-46de-474e-b9b4-796ac65239b5}" filter=" &quot;Accessory&quot; = 'gv'"/>
      <rule symbol="7" label="Люк подземных коммуникаций" key="{b3efef1f-efa3-4a3f-aa26-d8520784b925}" filter=" &quot;Accessory&quot; = 'gk'"/>
      <rule symbol="8" label="Люк подземных коммуникаций" key="{042c1206-60ff-4ab7-8ad3-27d7e2bc22c3}" filter=" &quot;Accessory&quot; = 'gts'"/>
      <rule symbol="9" label="Люк подземных коммуникаций" key="{b25d9ad4-cd2c-4fc1-8ad9-3e720a93d46c}" filter=" &quot;Accessory&quot; = 'd'"/>
      <rule symbol="10" label="Люк подземных коммуникаций" key="{7f767496-384e-496e-8bed-d84c70916ab5}" filter=" &quot;Accessory&quot; = 'l'"/>
      <rule symbol="11" label="Люк подземных коммуникаций" key="{8bdc600b-545a-47bc-abf6-a28152cf570d}" filter=" &quot;Accessory&quot; = 'mg'"/>
      <rule symbol="12" label="Люк подземных коммуникаций" key="{59989866-2507-4290-96f6-54610e417bb9}" filter=" &quot;Accessory&quot; = 'tsod'"/>
    </rules>
    <symbols>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" enabled="1" pass="1" id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="255,255,255,255,hsv:0,0,1,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="circle" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="255,0,0,255,rgb:1,0,0,1" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0.03" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="0.12" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.47999999999999998,0.03" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="10">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="-0.57999999999999996,0.01" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="11">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="1.1399999999999999,0.05" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="12">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="1.89999999999999991,0.14499999999999999" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="2">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.96999999999999997,0.13" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="3">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.47999999999999998,0.03" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="4">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.53500000000000003,0.03" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="5">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="6">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.88,0.04" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="7">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.94999999999999996,0.03" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="8">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="1.31899999999999995,0.04" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="9">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" pass="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name"/>
            <Option type="QString" value="0.5,0.13" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" name="outline_color"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="18" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_HAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + &quot;Svg&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="&quot;Svg_VAPoint&quot;" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
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
      <symbol is_animated="0" alpha="1" frame_rate="10" clip_to_extent="1" type="marker" force_rhr="0" name="">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" enabled="1" pass="0" id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" locked="0">
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
    <field configurationFlags="NoFlag" name="EngineStructType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value=" &quot;OghObjectType&quot; = '8'" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="______________________________________51089742_7cdc_4f96_9aca_62d100964796" name="Layer"/>
            <Option type="QString" value="Справочник (ОДХ) Тип инженерного сооружения" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;EngineStructType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhSide">
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
            <Option type="QString" value="______________________________________5f058f67_eee3_4e6f_9756_6f9a64c4fefc" name="Layer"/>
            <Option type="QString" value="Справочник (ОДХ) Код стороны проезжей части" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;OdhSide&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhAxis">
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
            <Option type="QString" value="AxisName" name="Key"/>
            <Option type="QString" value="_____________01ab6890_e3c4_4483_a4aa_22f66424d554" name="Layer"/>
            <Option type="QString" value="Осевые линии" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' srid=980077 checkPrimaryKeyUnicity='1' table=&quot;work&quot;.&quot;AxialLines&quot; (Geometry) sql=&quot;TaskGUID&quot; = '16bb1ed7-43c6-4b62-b059-1ce0d5e07eef'" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="AxisName" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Endwise">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1e+06" name="Max"/>
            <Option type="double" value="-1e+06" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="0.1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
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
    <field configurationFlags="NoFlag" name="Accessory">
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
            <Option type="QString" value="______________________________5cce7f1b_e8ac_431d_94b5_bc0b18967cfb" name="Layer"/>
            <Option type="QString" value="Справочник (ОДХ) Код принадлежности" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Accessory&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
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
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsDiffHeightMark">
      <editWidget type="CheckBox">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg_VAPoint">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg_HAPoint">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="fid" name=""/>
    <alias index="1" field="OghObjectType" name=""/>
    <alias index="2" field="ObjectId" name=""/>
    <alias index="3" field="RootId" name="Идентификатор ОГХ"/>
    <alias index="4" field="StartDate" name=""/>
    <alias index="5" field="EndDate" name=""/>
    <alias index="6" field="EngineStructType" name="Тип люка и решетки"/>
    <alias index="7" field="OdhSide" name="Сторона"/>
    <alias index="8" field="OdhAxis" name="Ось"/>
    <alias index="9" field="Endwise" name="По оси"/>
    <alias index="10" field="Placement" name=""/>
    <alias index="11" field="Accessory" name="Принадлежность"/>
    <alias index="12" field="Description" name="Примечание"/>
    <alias index="13" field="ParentOghObjectType" name=""/>
    <alias index="14" field="ParentObjectId" name=""/>
    <alias index="15" field="ParentRootId" name=""/>
    <alias index="16" field="ParentStartDate" name=""/>
    <alias index="17" field="ParentEndDate" name=""/>
    <alias index="18" field="CreateDate" name=""/>
    <alias index="19" field="CreateAuthor" name=""/>
    <alias index="20" field="ChangeDate" name=""/>
    <alias index="21" field="ChangeAuthor" name=""/>
    <alias index="22" field="TaskGUID" name=""/>
    <alias index="23" field="IsDiffHeightMark" name=""/>
    <alias index="24" field="Svg" name=""/>
    <alias index="25" field="Svg_VAPoint" name=""/>
    <alias index="26" field="Svg_HAPoint" name=""/>
  </aliases>
  <splitPolicies>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="EngineStructType" policy="DefaultValue"/>
    <policy field="OdhSide" policy="DefaultValue"/>
    <policy field="OdhAxis" policy="DefaultValue"/>
    <policy field="Endwise" policy="DefaultValue"/>
    <policy field="Accessory" policy="DefaultValue"/>
    <policy field="Description" policy="DefaultValue"/>
    <policy field="Svg" policy="DefaultValue"/>
    <policy field="Svg_VAPoint" policy="DefaultValue"/>
    <policy field="Svg_HAPoint" policy="DefaultValue"/>
  </splitPolicies>
  <defaults>
    <default expression="" field="fid" applyOnUpdate="0"/>
    <default expression="" field="OghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ObjectId" applyOnUpdate="0"/>
    <default expression="" field="RootId" applyOnUpdate="0"/>
    <default expression="" field="StartDate" applyOnUpdate="0"/>
    <default expression="" field="EndDate" applyOnUpdate="0"/>
    <default expression="" field="EngineStructType" applyOnUpdate="0"/>
    <default expression="" field="OdhSide" applyOnUpdate="0"/>
    <default expression="" field="OdhAxis" applyOnUpdate="0"/>
    <default expression="" field="Endwise" applyOnUpdate="0"/>
    <default expression="" field="Placement" applyOnUpdate="0"/>
    <default expression="" field="Accessory" applyOnUpdate="0"/>
    <default expression="" field="Description" applyOnUpdate="0"/>
    <default expression="" field="ParentOghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ParentObjectId" applyOnUpdate="0"/>
    <default expression="" field="ParentRootId" applyOnUpdate="0"/>
    <default expression="" field="ParentStartDate" applyOnUpdate="0"/>
    <default expression="" field="ParentEndDate" applyOnUpdate="0"/>
    <default expression="" field="CreateDate" applyOnUpdate="0"/>
    <default expression="" field="CreateAuthor" applyOnUpdate="0"/>
    <default expression="" field="ChangeDate" applyOnUpdate="0"/>
    <default expression="" field="ChangeAuthor" applyOnUpdate="0"/>
    <default expression="" field="TaskGUID" applyOnUpdate="0"/>
    <default expression="" field="IsDiffHeightMark" applyOnUpdate="0"/>
    <default expression="IF(attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'SvgName') IS NOT NULL, @MggtAsuSvgPath + '/' + attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'SvgName'), @MggtAsuSvgPath + '/Люк подземных коммуникаций (смотровой колодец).svg')" field="Svg" applyOnUpdate="1"/>
    <default expression="IF(&quot;Accessory&quot; IS NOT NULL, attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'AnchorPointV'), 'Bottom')" field="Svg_VAPoint" applyOnUpdate="1"/>
    <default expression="IF(&quot;Accessory&quot; IS NOT NULL, attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'AnchorPointH'), 'HCenter')" field="Svg_HAPoint" applyOnUpdate="1"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" unique_strength="1" field="fid" constraints="3" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="OghObjectType" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ObjectId" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="RootId" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="StartDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="EndDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="EngineStructType" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="OdhSide" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="OdhAxis" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Endwise" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Placement" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Accessory" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Description" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ParentOghObjectType" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ParentObjectId" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ParentRootId" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ParentStartDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ParentEndDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="CreateDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="CreateAuthor" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ChangeDate" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="ChangeAuthor" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="TaskGUID" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="IsDiffHeightMark" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Svg" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Svg_VAPoint" constraints="0" exp_strength="0"/>
    <constraint notnull_strength="0" unique_strength="0" field="Svg_HAPoint" constraints="0" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="fid"/>
    <constraint exp="" desc="" field="OghObjectType"/>
    <constraint exp="" desc="" field="ObjectId"/>
    <constraint exp="" desc="" field="RootId"/>
    <constraint exp="" desc="" field="StartDate"/>
    <constraint exp="" desc="" field="EndDate"/>
    <constraint exp="" desc="" field="EngineStructType"/>
    <constraint exp="" desc="" field="OdhSide"/>
    <constraint exp="" desc="" field="OdhAxis"/>
    <constraint exp="" desc="" field="Endwise"/>
    <constraint exp="" desc="" field="Placement"/>
    <constraint exp="" desc="" field="Accessory"/>
    <constraint exp="" desc="" field="Description"/>
    <constraint exp="" desc="" field="ParentOghObjectType"/>
    <constraint exp="" desc="" field="ParentObjectId"/>
    <constraint exp="" desc="" field="ParentRootId"/>
    <constraint exp="" desc="" field="ParentStartDate"/>
    <constraint exp="" desc="" field="ParentEndDate"/>
    <constraint exp="" desc="" field="CreateDate"/>
    <constraint exp="" desc="" field="CreateAuthor"/>
    <constraint exp="" desc="" field="ChangeDate"/>
    <constraint exp="" desc="" field="ChangeAuthor"/>
    <constraint exp="" desc="" field="TaskGUID"/>
    <constraint exp="" desc="" field="IsDiffHeightMark"/>
    <constraint exp="" desc="" field="Svg"/>
    <constraint exp="" desc="" field="Svg_VAPoint"/>
    <constraint exp="" desc="" field="Svg_HAPoint"/>
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
      <labelFont bold="0" style="" strikethrough="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
    </labelStyle>
    <attributeEditorField verticalStretch="0" horizontalStretch="0" index="3" showLabel="1" name="RootId">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer groupBox="1" collapsed="0" visibilityExpressionEnabled="0" columnCount="4" collapsedExpression="" verticalStretch="0" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" showLabel="1" type="GroupBox" name="Назначение">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
      </labelStyle>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="6" showLabel="1" name="EngineStructType">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="11" showLabel="1" name="Accessory">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="0" collapsed="0" visibilityExpressionEnabled="0" columnCount="4" collapsedExpression="" verticalStretch="0" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" showLabel="1" type="Tab" name="Привязка">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
      </labelStyle>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="8" showLabel="1" name="OdhAxis">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="7" showLabel="1" name="OdhSide">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="9" showLabel="1" name="Endwise">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="1" collapsed="0" visibilityExpressionEnabled="0" columnCount="4" collapsedExpression="" verticalStretch="0" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" showLabel="1" type="GroupBox" name="Параметры">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
      </labelStyle>
      <attributeEditorField verticalStretch="0" horizontalStretch="0" index="12" showLabel="1" name="Description">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" verticalStretch="0" horizontalStretch="0" showLabel="0" name="Spacer Widget">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" italic="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="Accessory" editable="1"/>
    <field name="Area" editable="1"/>
    <field name="AutoCleanArea" editable="1"/>
    <field name="AxisGeometry" editable="1"/>
    <field name="BordBegin" editable="1"/>
    <field name="BordEnd" editable="1"/>
    <field name="BoundStoneMark" editable="1"/>
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
    <field name="EngineStructType" editable="1"/>
    <field name="EquipmentKind" editable="1"/>
    <field name="FlatElementType" editable="1"/>
    <field name="GuttersLength" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="IsGutterZone" editable="1"/>
    <field name="ManualCleanArea" editable="1"/>
    <field name="Material" editable="1"/>
    <field name="NearRoadway" editable="1"/>
    <field name="NoCleanArea" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OdhAxis" editable="1"/>
    <field name="OdhSide" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="Placement" editable="1"/>
    <field name="QuantityPcs" editable="1"/>
    <field name="QuantityRm" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="Svg" editable="1"/>
    <field name="Svg_HAPoint" editable="1"/>
    <field name="Svg_VAPoint" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="WidthBegin" editable="1"/>
    <field name="WidthEnd" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="Accessory"/>
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
    <field labelOnTop="1" name="Endwise"/>
    <field labelOnTop="1" name="EngineStructType"/>
    <field labelOnTop="1" name="EquipmentKind"/>
    <field labelOnTop="1" name="FlatElementType"/>
    <field labelOnTop="1" name="GuttersLength"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="IsGutterZone"/>
    <field labelOnTop="1" name="ManualCleanArea"/>
    <field labelOnTop="1" name="Material"/>
    <field labelOnTop="1" name="NearRoadway"/>
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
    <field labelOnTop="0" name="Placement"/>
    <field labelOnTop="1" name="QuantityPcs"/>
    <field labelOnTop="1" name="QuantityRm"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="Svg"/>
    <field labelOnTop="0" name="Svg_HAPoint"/>
    <field labelOnTop="0" name="Svg_VAPoint"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="WidthBegin"/>
    <field labelOnTop="1" name="WidthEnd"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="Accessory"/>
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
    <field reuseLastValue="0" name="Endwise"/>
    <field reuseLastValue="0" name="EngineStructType"/>
    <field reuseLastValue="0" name="EquipmentKind"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="GuttersLength"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsGutterZone"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
    <field reuseLastValue="0" name="Material"/>
    <field reuseLastValue="0" name="NearRoadway"/>
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
    <field reuseLastValue="0" name="Placement"/>
    <field reuseLastValue="0" name="QuantityPcs"/>
    <field reuseLastValue="0" name="QuantityRm"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="Svg"/>
    <field reuseLastValue="0" name="Svg_HAPoint"/>
    <field reuseLastValue="0" name="Svg_VAPoint"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="WidthBegin"/>
    <field reuseLastValue="0" name="WidthEnd"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
