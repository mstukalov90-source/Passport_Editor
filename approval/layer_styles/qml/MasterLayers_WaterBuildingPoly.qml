<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" simplifyLocal="1" version="3.38.0-Grenoble" hasScaleBasedVisibilityFlag="0" labelsEnabled="0" simplifyAlgorithm="0" minScale="100000000" simplifyDrawingHints="0" simplifyDrawingTol="1" simplifyMaxScale="1" symbologyReferenceScale="-1" readOnly="0" styleCategories="LayerConfiguration|Symbology|Labeling|Fields|Forms|Rendering">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <renderer-v2 enableorderby="0" forceraster="0" symbollevels="0" type="RuleRenderer" referencescale="-1">
    <rules key="{f498c0ff-ccd4-435c-99d6-b9cf1c39715c}">
      <rule filter=" &quot;WaterType&quot; = 'Pond'" symbol="0" key="{edf4782a-b32e-403d-bd3b-40e30a7d8ae9}" label="Пруд"/>
      <rule filter=" &quot;WaterType&quot; = 'Swamp'" symbol="1" key="{5173698c-1336-4aed-b049-2773bccd7ef1}" label="Болото"/>
      <rule filter=" &quot;WaterType&quot; = 'Lake'" symbol="2" key="{2852bbe4-8bc9-49e6-8525-850038868470}" label="Озеро"/>
      <rule filter=" &quot;WaterType&quot; = 'River'" symbol="3" key="{a0a774ab-a72b-4ec8-87b2-4a14a889d041}" label="Река"/>
      <rule filter=" &quot;WaterType&quot; = 'Stream'" symbol="4" key="{7dd9304b-db3b-4eb4-818f-323e52f7ef5c}" label="Ручей"/>
      <rule filter=" &quot;WaterType&quot; = 'Fountain'" symbol="5" key="{00fe9620-a63a-4f87-bb91-3e9c6367cd4f}" label="Фонтан"/>
      <rule filter="ELSE" symbol="6" key="{5c80955d-56e9-4d18-86b0-5c8b73158dfc}" label="Нет данных"/>
    </rules>
    <symbols>
      <symbol force_rhr="0" name="0" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{a7013c1a-9d4e-430c-aa38-40225f3544ed}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="165,191,221,255,rgb:0.6470588235294118,0.74901960784313726,0.8666666666666667,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="100,152,210,255,rgb:0.39215686274509803,0.59607843137254901,0.82352941176470584,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="1" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{ddafbccc-3b6f-4fab-8014-8d36ca24e225}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="163,205,185,255,rgb:0.63921568627450975,0.80392156862745101,0.72549019607843135,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="114,133,132,255,rgb:0.44705882352941179,0.52156862745098043,0.51764705882352946,1" type="QString"/>
            <Option name="outline_style" value="no" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer locked="0" id="{4fa7ae2a-8a42-4154-9dc8-88ad78d90550}" pass="0" class="PointPatternFill" enabled="1">
          <Option type="Map">
            <Option name="angle" value="0" type="double"/>
            <Option name="clip_mode" value="shape" type="QString"/>
            <Option name="coordinate_reference" value="feature" type="QString"/>
            <Option name="displacement_x" value="5" type="QString"/>
            <Option name="displacement_x_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="displacement_x_unit" value="MM" type="QString"/>
            <Option name="displacement_y" value="1.6" type="QString"/>
            <Option name="displacement_y_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="displacement_y_unit" value="MM" type="QString"/>
            <Option name="distance_x" value="11.4" type="QString"/>
            <Option name="distance_x_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="distance_x_unit" value="MM" type="QString"/>
            <Option name="distance_y" value="6.6" type="QString"/>
            <Option name="distance_y_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="distance_y_unit" value="MM" type="QString"/>
            <Option name="offset_x" value="0" type="QString"/>
            <Option name="offset_x_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_x_unit" value="MM" type="QString"/>
            <Option name="offset_y" value="0" type="QString"/>
            <Option name="offset_y_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_y_unit" value="MM" type="QString"/>
            <Option name="outline_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="random_deviation_x" value="0" type="QString"/>
            <Option name="random_deviation_x_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="random_deviation_x_unit" value="MM" type="QString"/>
            <Option name="random_deviation_y" value="0" type="QString"/>
            <Option name="random_deviation_y_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="random_deviation_y_unit" value="MM" type="QString"/>
            <Option name="seed" value="697258570" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
          <symbol force_rhr="0" name="@1@1" frame_rate="10" type="marker" alpha="1" clip_to_extent="1" is_animated="0">
            <data_defined_properties>
              <Option type="Map">
                <Option name="name" value="" type="QString"/>
                <Option name="properties"/>
                <Option name="type" value="collection" type="QString"/>
              </Option>
            </data_defined_properties>
            <layer locked="0" id="{17dae5b6-9d58-4052-bde3-ba5134631a78}" pass="0" class="SimpleMarker" enabled="1">
              <Option type="Map">
                <Option name="angle" value="90" type="QString"/>
                <Option name="cap_style" value="square" type="QString"/>
                <Option name="color" value="255,0,0,255,rgb:1,0,0,1" type="QString"/>
                <Option name="horizontal_anchor_point" value="1" type="QString"/>
                <Option name="joinstyle" value="bevel" type="QString"/>
                <Option name="name" value="line" type="QString"/>
                <Option name="offset" value="0.80000000000000004,1.39999999999999991" type="QString"/>
                <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="offset_unit" value="MM" type="QString"/>
                <Option name="outline_color" value="111,155,204,255,rgb:0.43529411764705883,0.60784313725490191,0.80000000000000004,1" type="QString"/>
                <Option name="outline_style" value="solid" type="QString"/>
                <Option name="outline_width" value="0.4" type="QString"/>
                <Option name="outline_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="outline_width_unit" value="MM" type="QString"/>
                <Option name="scale_method" value="diameter" type="QString"/>
                <Option name="size" value="2.2" type="QString"/>
                <Option name="size_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="size_unit" value="MM" type="QString"/>
                <Option name="vertical_anchor_point" value="1" type="QString"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option name="name" value="" type="QString"/>
                  <Option name="properties"/>
                  <Option name="type" value="collection" type="QString"/>
                </Option>
              </data_defined_properties>
            </layer>
            <layer locked="0" id="{861d3622-7d62-479d-9e79-b8c8b28802cc}" pass="0" class="SimpleMarker" enabled="1">
              <Option type="Map">
                <Option name="angle" value="90" type="QString"/>
                <Option name="cap_style" value="square" type="QString"/>
                <Option name="color" value="255,0,0,255,rgb:1,0,0,1" type="QString"/>
                <Option name="horizontal_anchor_point" value="1" type="QString"/>
                <Option name="joinstyle" value="bevel" type="QString"/>
                <Option name="name" value="line" type="QString"/>
                <Option name="offset" value="0,0" type="QString"/>
                <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="offset_unit" value="MM" type="QString"/>
                <Option name="outline_color" value="111,155,204,255,rgb:0.43529411764705883,0.60784313725490191,0.80000000000000004,1" type="QString"/>
                <Option name="outline_style" value="solid" type="QString"/>
                <Option name="outline_width" value="0.4" type="QString"/>
                <Option name="outline_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="outline_width_unit" value="MM" type="QString"/>
                <Option name="scale_method" value="diameter" type="QString"/>
                <Option name="size" value="3.8" type="QString"/>
                <Option name="size_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="size_unit" value="MM" type="QString"/>
                <Option name="vertical_anchor_point" value="1" type="QString"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option name="name" value="" type="QString"/>
                  <Option name="properties"/>
                  <Option name="type" value="collection" type="QString"/>
                </Option>
              </data_defined_properties>
            </layer>
            <layer locked="0" id="{9705dc31-bdee-4977-bd03-84a068adb55e}" pass="0" class="SimpleMarker" enabled="1">
              <Option type="Map">
                <Option name="angle" value="90" type="QString"/>
                <Option name="cap_style" value="square" type="QString"/>
                <Option name="color" value="255,0,0,255,rgb:1,0,0,1" type="QString"/>
                <Option name="horizontal_anchor_point" value="1" type="QString"/>
                <Option name="joinstyle" value="bevel" type="QString"/>
                <Option name="name" value="line" type="QString"/>
                <Option name="offset" value="-0.80000000000000004,1.79999999999999982" type="QString"/>
                <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="offset_unit" value="MM" type="QString"/>
                <Option name="outline_color" value="111,155,204,255,rgb:0.43529411764705883,0.60784313725490191,0.80000000000000004,1" type="QString"/>
                <Option name="outline_style" value="solid" type="QString"/>
                <Option name="outline_width" value="0.4" type="QString"/>
                <Option name="outline_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="outline_width_unit" value="MM" type="QString"/>
                <Option name="scale_method" value="diameter" type="QString"/>
                <Option name="size" value="3.8" type="QString"/>
                <Option name="size_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
                <Option name="size_unit" value="MM" type="QString"/>
                <Option name="vertical_anchor_point" value="1" type="QString"/>
              </Option>
              <data_defined_properties>
                <Option type="Map">
                  <Option name="name" value="" type="QString"/>
                  <Option name="properties"/>
                  <Option name="type" value="collection" type="QString"/>
                </Option>
              </data_defined_properties>
            </layer>
          </symbol>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="2" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{a7013c1a-9d4e-430c-aa38-40225f3544ed}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="165,191,221,255,rgb:0.6470588235294118,0.74901960784313726,0.8666666666666667,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="100,152,210,255,rgb:0.39215686274509803,0.59607843137254901,0.82352941176470584,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="3" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{a7013c1a-9d4e-430c-aa38-40225f3544ed}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="165,191,221,255,rgb:0.6470588235294118,0.74901960784313726,0.8666666666666667,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="100,152,210,255,rgb:0.39215686274509803,0.59607843137254901,0.82352941176470584,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="4" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{a7013c1a-9d4e-430c-aa38-40225f3544ed}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="165,191,221,255,rgb:0.6470588235294118,0.74901960784313726,0.8666666666666667,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="100,152,210,255,rgb:0.39215686274509803,0.59607843137254901,0.82352941176470584,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="5" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{a7013c1a-9d4e-430c-aa38-40225f3544ed}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="165,191,221,255,rgb:0.6470588235294118,0.74901960784313726,0.8666666666666667,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="100,152,210,255,rgb:0.39215686274509803,0.59607843137254901,0.82352941176470584,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" name="6" frame_rate="10" type="fill" alpha="0.3" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{7b5e5663-9790-47cf-8da0-182fc12f7571}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="207,0,41,255,rgb:0.81176470588235294,0,0.16078431372549021,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <data-defined-properties>
      <Option type="Map">
        <Option name="name" value="" type="QString"/>
        <Option name="properties"/>
        <Option name="type" value="collection" type="QString"/>
      </Option>
    </data-defined-properties>
  </renderer-v2>
  <selection mode="Default">
    <selectionColor invalid="1"/>
    <selectionSymbol>
      <symbol force_rhr="0" name="" frame_rate="10" type="fill" alpha="1" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" value="" type="QString"/>
            <Option name="properties"/>
            <Option name="type" value="collection" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{6d1bb7bd-53c4-4308-8910-130da2d46dbb}" pass="0" class="SimpleFill" enabled="1">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="color" value="0,0,255,255,rgb:0,0,1,1" type="QString"/>
            <Option name="joinstyle" value="bevel" type="QString"/>
            <Option name="offset" value="0,0" type="QString"/>
            <Option name="offset_map_unit_scale" value="3x:0,0,0,0,0,0" type="QString"/>
            <Option name="offset_unit" value="MM" type="QString"/>
            <Option name="outline_color" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString"/>
            <Option name="outline_style" value="solid" type="QString"/>
            <Option name="outline_width" value="0.26" type="QString"/>
            <Option name="outline_width_unit" value="MM" type="QString"/>
            <Option name="style" value="solid" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" value="" type="QString"/>
              <Option name="properties"/>
              <Option name="type" value="collection" type="QString"/>
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
    <field name="fid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="OghObjectType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ObjectId" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="RootId" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="StartDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="EndDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd.MM.yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="yyyy-MM-dd HH:mm:ss" type="QString"/>
            <Option name="field_format_overwrite" value="false" type="bool"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="WaterType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Key" value="Code" type="QString"/>
            <Option name="Layer" value="_______________________________0f3de5e8_adb0_4e87_ad69_413371e237f5" type="QString"/>
            <Option name="LayerName" value="Справочник (ДТ/ОО) Тип водных объектов" type="QString"/>
            <Option name="LayerProviderName" value="postgres" type="QString"/>
            <Option name="LayerSource" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;WaterType&quot;" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="true" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="Name" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Area" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="Max" value="1.7976931348623157e+308" type="double"/>
            <Option name="Min" value="-1.7976931348623157e+308" type="double"/>
            <Option name="Precision" value="2" type="int"/>
            <Option name="Step" value="1" type="double"/>
            <Option name="Style" value="SpinBox" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="NoCalc" configurationFlags="NoFlag">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option name="AllowNullState" value="false" type="bool"/>
            <Option name="CheckedState" type="invalid"/>
            <Option name="TextDisplayMethod" value="0" type="int"/>
            <Option name="UncheckedState" type="invalid"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="IsDiffHeightMark" configurationFlags="NoFlag">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option name="AllowNullState" value="false" type="bool"/>
            <Option name="CheckedState" type="invalid"/>
            <Option name="TextDisplayMethod" value="0" type="int"/>
            <Option name="UncheckedState" type="invalid"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ParentOghObjectType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ParentObjectId" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ParentRootId" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ParentStartDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ParentEndDate" configurationFlags="NoFlag">
      <editWidget type="DateTime">
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
    <alias index="6" name="Тип объекта" field="WaterType"/>
    <alias index="7" name="Площадь" field="Area"/>
    <alias index="8" name="Не учитывать" field="NoCalc"/>
    <alias index="9" name="Разновысотные отметки" field="IsDiffHeightMark"/>
    <alias index="10" name="" field="ParentOghObjectType"/>
    <alias index="11" name="" field="ParentObjectId"/>
    <alias index="12" name="" field="ParentRootId"/>
    <alias index="13" name="" field="ParentStartDate"/>
    <alias index="14" name="" field="ParentEndDate"/>
  </aliases>
  <splitPolicies>
    <policy policy="DefaultValue" field="fid"/>
    <policy policy="Duplicate" field="OghObjectType"/>
    <policy policy="Duplicate" field="ObjectId"/>
    <policy policy="Duplicate" field="RootId"/>
    <policy policy="Duplicate" field="StartDate"/>
    <policy policy="DefaultValue" field="EndDate"/>
    <policy policy="Duplicate" field="WaterType"/>
    <policy policy="DefaultValue" field="Area"/>
    <policy policy="DefaultValue" field="NoCalc"/>
    <policy policy="DefaultValue" field="IsDiffHeightMark"/>
    <policy policy="DefaultValue" field="ParentOghObjectType"/>
    <policy policy="Duplicate" field="ParentObjectId"/>
    <policy policy="Duplicate" field="ParentRootId"/>
    <policy policy="Duplicate" field="ParentStartDate"/>
    <policy policy="Duplicate" field="ParentEndDate"/>
  </splitPolicies>
  <duplicatePolicies>
    <policy policy="Duplicate" field="fid"/>
    <policy policy="Duplicate" field="OghObjectType"/>
    <policy policy="Duplicate" field="ObjectId"/>
    <policy policy="Duplicate" field="RootId"/>
    <policy policy="Duplicate" field="StartDate"/>
    <policy policy="Duplicate" field="EndDate"/>
    <policy policy="Duplicate" field="WaterType"/>
    <policy policy="Duplicate" field="Area"/>
    <policy policy="Duplicate" field="NoCalc"/>
    <policy policy="Duplicate" field="IsDiffHeightMark"/>
    <policy policy="Duplicate" field="ParentOghObjectType"/>
    <policy policy="Duplicate" field="ParentObjectId"/>
    <policy policy="Duplicate" field="ParentRootId"/>
    <policy policy="Duplicate" field="ParentStartDate"/>
    <policy policy="Duplicate" field="ParentEndDate"/>
  </duplicatePolicies>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="WaterType"/>
    <default expression="" applyOnUpdate="0" field="Area"/>
    <default expression="" applyOnUpdate="0" field="NoCalc"/>
    <default expression="" applyOnUpdate="0" field="IsDiffHeightMark"/>
    <default expression="" applyOnUpdate="0" field="ParentOghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ParentObjectId"/>
    <default expression="" applyOnUpdate="0" field="ParentRootId"/>
    <default expression="" applyOnUpdate="0" field="ParentStartDate"/>
    <default expression="" applyOnUpdate="0" field="ParentEndDate"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" constraints="3" unique_strength="1" notnull_strength="1" field="fid"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="OghObjectType"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ObjectId"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="RootId"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="StartDate"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="EndDate"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="WaterType"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="Area"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="NoCalc"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="IsDiffHeightMark"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ParentOghObjectType"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ParentObjectId"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ParentRootId"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ParentStartDate"/>
    <constraint exp_strength="0" constraints="0" unique_strength="0" notnull_strength="0" field="ParentEndDate"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="WaterType"/>
    <constraint desc="" exp="" field="Area"/>
    <constraint desc="" exp="" field="NoCalc"/>
    <constraint desc="" exp="" field="IsDiffHeightMark"/>
    <constraint desc="" exp="" field="ParentOghObjectType"/>
    <constraint desc="" exp="" field="ParentObjectId"/>
    <constraint desc="" exp="" field="ParentRootId"/>
    <constraint desc="" exp="" field="ParentStartDate"/>
    <constraint desc="" exp="" field="ParentEndDate"/>
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
    <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
      <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" index="3" name="RootId" horizontalStretch="0" verticalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer showLabel="1" name="Параметры" horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" columnCount="4" visibilityExpression="" groupBox="1" type="GroupBox" visibilityExpressionEnabled="0" verticalStretch="0" collapsedExpression="">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="6" name="WaterType" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="7" name="Area" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="8" name="NoCalc" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="9" name="IsDiffHeightMark" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" name="Spacer Widget" horizontalStretch="0" drawLine="0" verticalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" strikethrough="0" style="" italic="0" bold="0" underline="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="Age" editable="1"/>
    <field name="Area" editable="1"/>
    <field name="BioGgroupNum" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CharacteristicStateGardening" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="DetailedStateGardening" editable="1"/>
    <field name="Diameter" editable="1"/>
    <field name="Distance" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="GreenNum" editable="1"/>
    <field name="Height" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="LifeFormType" editable="1"/>
    <field name="MillionTrees" editable="1"/>
    <field name="NoCalc" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="PlantServiceRecomendations" editable="1"/>
    <field name="PlantType" editable="1"/>
    <field name="PlantationType" editable="1"/>
    <field name="Quantity" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="SectionNum" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="StateGardening" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="ValuablePlants" editable="1"/>
    <field name="WaterType" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="Age" labelOnTop="1"/>
    <field name="Area" labelOnTop="1"/>
    <field name="BioGgroupNum" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CharacteristicStateGardening" labelOnTop="1"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="DetailedStateGardening" labelOnTop="1"/>
    <field name="Diameter" labelOnTop="1"/>
    <field name="Distance" labelOnTop="1"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="GreenNum" labelOnTop="1"/>
    <field name="Height" labelOnTop="1"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="LifeFormType" labelOnTop="1"/>
    <field name="MillionTrees" labelOnTop="1"/>
    <field name="NoCalc" labelOnTop="1"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="OghObjectType" labelOnTop="0"/>
    <field name="ParentEndDate" labelOnTop="0"/>
    <field name="ParentObjectId" labelOnTop="0"/>
    <field name="ParentOghObjectType" labelOnTop="0"/>
    <field name="ParentRootId" labelOnTop="0"/>
    <field name="ParentStartDate" labelOnTop="0"/>
    <field name="PlantServiceRecomendations" labelOnTop="1"/>
    <field name="PlantType" labelOnTop="1"/>
    <field name="PlantationType" labelOnTop="1"/>
    <field name="Quantity" labelOnTop="1"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="SectionNum" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="StateGardening" labelOnTop="1"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="ValuablePlants" labelOnTop="1"/>
    <field name="WaterType" labelOnTop="1"/>
    <field name="fid" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="Age" reuseLastValue="0"/>
    <field name="Area" reuseLastValue="0"/>
    <field name="BioGgroupNum" reuseLastValue="0"/>
    <field name="ChangeAuthor" reuseLastValue="0"/>
    <field name="ChangeDate" reuseLastValue="0"/>
    <field name="CharacteristicStateGardening" reuseLastValue="0"/>
    <field name="CreateAuthor" reuseLastValue="0"/>
    <field name="CreateDate" reuseLastValue="0"/>
    <field name="DetailedStateGardening" reuseLastValue="0"/>
    <field name="Diameter" reuseLastValue="0"/>
    <field name="Distance" reuseLastValue="0"/>
    <field name="EndDate" reuseLastValue="0"/>
    <field name="FileList" reuseLastValue="0"/>
    <field name="GreenNum" reuseLastValue="0"/>
    <field name="Height" reuseLastValue="0"/>
    <field name="IsDiffHeightMark" reuseLastValue="0"/>
    <field name="LifeFormType" reuseLastValue="0"/>
    <field name="MillionTrees" reuseLastValue="0"/>
    <field name="NoCalc" reuseLastValue="0"/>
    <field name="ObjectId" reuseLastValue="0"/>
    <field name="OghObjectType" reuseLastValue="0"/>
    <field name="ParentEndDate" reuseLastValue="0"/>
    <field name="ParentObjectId" reuseLastValue="0"/>
    <field name="ParentOghObjectType" reuseLastValue="0"/>
    <field name="ParentRootId" reuseLastValue="0"/>
    <field name="ParentStartDate" reuseLastValue="0"/>
    <field name="PlantServiceRecomendations" reuseLastValue="0"/>
    <field name="PlantType" reuseLastValue="0"/>
    <field name="PlantationType" reuseLastValue="0"/>
    <field name="Quantity" reuseLastValue="0"/>
    <field name="RootId" reuseLastValue="0"/>
    <field name="SectionNum" reuseLastValue="0"/>
    <field name="StartDate" reuseLastValue="0"/>
    <field name="StateGardening" reuseLastValue="0"/>
    <field name="TaskGUID" reuseLastValue="0"/>
    <field name="ValuablePlants" reuseLastValue="0"/>
    <field name="WaterType" reuseLastValue="0"/>
    <field name="fid" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"OghObjectType"</previewExpression>
  <layerGeometryType>2</layerGeometryType>
</qgis>
