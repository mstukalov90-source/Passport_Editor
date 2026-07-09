<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" simplifyDrawingHints="0" simplifyAlgorithm="0" autoRefreshTime="0" labelsEnabled="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" autoRefreshMode="Disabled" simplifyLocal="1" symbologyReferenceScale="-1" minScale="100000000" simplifyMaxScale="1" version="3.44.8-Solothurn" simplifyDrawingTol="1" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1" symbollevels="0">
    <rules key="{75da7202-6d23-4248-85db-3bfb92948dae}">
      <rule symbol="0" label="Точки привязки" filter="&quot;fid&quot; is not NULL" checkstate="0" key="{08d8e72a-cedd-4a48-b633-d72a282772e3}"/>
      <rule symbol="1" label="Информационный стенд" filter="&quot;ConvElementType&quot; in ('763', '764')" key="{85511b9e-63e7-476b-9e59-023074c4ec81}"/>
      <rule symbol="2" label="Скамья" filter="&quot;ConvElementType&quot; in ('783', '784')" key="{c9a547d8-9ed3-4fcb-9519-4d695a9066e3}"/>
      <rule symbol="3" label="Скульптура" filter="&quot;ConvElementType&quot; in ('785', '786')" key="{b03f8001-7857-40c4-af9d-5546e9ef1728}"/>
      <rule symbol="4" label="Урна" filter="&quot;ConvElementType&quot; in ('797', '798')" key="{e208b197-0491-4a57-a352-b0c8aab44d48}"/>
      <rule symbol="5" label="Флагшток" filter="&quot;ConvElementType&quot; in ('801', '802')" key="{724390a5-d74c-4efe-9b6e-0a3435f8cae6}"/>
      <rule symbol="6" label="Велопарковка" filter="&quot;ConvElementType&quot; in ('751', '752')" key="{b879b20b-cba0-4815-b984-5f7171d159c9}"/>
      <rule symbol="7" label="Рекламная конструкция" filter="&quot;ConvElementType&quot; in ('779', '780')" key="{5aa5cdaa-498b-48cc-a352-84d7749a92a1}"/>
      <rule symbol="8" label="Бетонная полусфера (и др. формы)" filter="&quot;ConvElementType&quot; in ('743', '744')" key="{606fc272-300d-4c49-8b5f-02f5d586c59c}"/>
      <rule symbol="9" label="Дорожное зеркало" filter="&quot;ConvElementType&quot; in ('757', '758')" key="{7b51609c-e05e-468f-8d90-e977c54ee2d6}"/>
      <rule symbol="10" label="Устройство связи" filter="&quot;ConvElementType&quot; in ('799', '800')" key="{b8c5af86-4e0a-4cd0-9131-a1227e2eaa12}"/>
      <rule symbol="11" label="Шлагбаум" filter="&quot;ConvElementType&quot; in ('805', '806')" key="{c8ff87a1-356b-4ef3-899e-306e768e1359}"/>
      <rule symbol="12" label="МАФ ОДХ" filter="ELSE" key="{f0801346-df7a-4352-80ac-46e74c622c42}"/>
    </rules>
    <symbols>
      <symbol clip_to_extent="1" name="0" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" pass="1" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="255,255,255,255,hsv:0,0,1,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MapUnit"/>
            <Option name="outline_color" type="QString" value="255,0,0,255,rgb:1,0,0,1"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0.03"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MapUnit"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="0.12"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="1"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="hAnchor" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;ELSE 'HCenter'&#xd;&#xa;END"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
                <Option name="vAnchor" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;ELSE 'Bottom'&#xd;&#xa;END"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="1" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Информационный стенд.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="10" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Вышка связи многофункциональная.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="11" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Шлагбаум.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="12" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{af3981b9-023d-4e83-b001-b5ce28c46a8b}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="2"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MM"/>
            <Option name="vertical_anchor_point" type="QString" value="1"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="2" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Скамья.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="3" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Скульптура.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="4" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Урна.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="5" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Флагшток.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="6" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Стойка для велопарковки.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="7" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Рекламная конструкция.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="8" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Полусфера антипарковочная.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="9" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{4cbc4e73-47a1-481d-9686-1b26d207a897}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="2"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Дорожное зеркало.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <data-defined-properties>
      <Option type="Map">
        <Option name="name" type="QString" value=""/>
        <Option name="properties"/>
        <Option name="type" type="QString" value="collection"/>
      </Option>
    </data-defined-properties>
  </renderer-v2>
  <selection mode="Default">
    <selectionColor invalid="1"/>
    <selectionSymbol>
      <symbol clip_to_extent="1" name="" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{bded99f2-e115-4ce9-931f-1086cc2b86e5}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="255,0,0,255,rgb:1,0,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="2"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MM"/>
            <Option name="vertical_anchor_point" type="QString" value="1"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
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
    <field name="fid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
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
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
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
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd.MM.yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="yyyy-MM-dd HH:mm:ss"/>
            <Option name="field_format_overwrite" type="bool" value="false"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ConvElementType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="____________________________________40a03fbc_4602_4b85_a91b_06c0564cf08c"/>
            <Option name="LayerName" type="QString" value="Справочник (ОДХ) Тип элемента обустройста"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ConvElementType&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="OdhSide" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="______________________________________bfa58402_4130_44f4_b1b3_81a7835c4b3a"/>
            <Option name="LayerName" type="QString" value="Справочник (ОДХ) Код стороны проезжей части"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;OdhSide&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="OdhAxis" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option name="Key" type="QString" value="AxisName"/>
            <Option name="Layer" type="QString" value="_____________27151001_1a2a_41c6_9d7f_33708f2fc682"/>
            <Option name="LayerName" type="QString" value="Осевые линии"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' srid=980077 checkPrimaryKeyUnicity='1' table=&quot;work&quot;.&quot;AxialLines&quot; (Geometry) sql=&quot;TaskGUID&quot; = '7bb01a1f-d65f-40bf-a38b-0d0c1f56fe52'"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="AxisName"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="BordBegin" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+06"/>
            <Option name="Min" type="double" value="-1e+06"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="BordEnd" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+06"/>
            <Option name="Min" type="double" value="-1e+06"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Property" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Area" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+06"/>
            <Option name="Min" type="double" value="0"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="IsObjectArea" configurationFlags="NoFlag">
      <editWidget type="CheckBox">
        <config>
          <Option type="Map">
            <Option name="AllowNullState" type="bool" value="false"/>
            <Option name="CheckedState" type="invalid"/>
            <Option name="TextDisplayMethod" type="int" value="0"/>
            <Option name="UncheckedState" type="invalid"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Placement" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="IdRfid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Description" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ParentOghObjectType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd.MM.yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="yyyy-MM-dd HH:mm:ss"/>
            <Option name="field_format_overwrite" type="bool" value="false"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
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
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
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
    <alias name="" index="0" field="fid"/>
    <alias name="" index="1" field="OghObjectType"/>
    <alias name="" index="2" field="ObjectId"/>
    <alias name="" index="3" field="RootId"/>
    <alias name="" index="4" field="StartDate"/>
    <alias name="" index="5" field="EndDate"/>
    <alias name="" index="6" field="ConvElementType"/>
    <alias name="" index="7" field="OdhSide"/>
    <alias name="" index="8" field="OdhAxis"/>
    <alias name="" index="9" field="BordBegin"/>
    <alias name="" index="10" field="BordEnd"/>
    <alias name="" index="11" field="Property"/>
    <alias name="" index="12" field="Area"/>
    <alias name="" index="13" field="IsObjectArea"/>
    <alias name="" index="14" field="Placement"/>
    <alias name="" index="15" field="IdRfid"/>
    <alias name="" index="16" field="Description"/>
    <alias name="" index="17" field="ParentOghObjectType"/>
    <alias name="" index="18" field="ParentObjectId"/>
    <alias name="" index="19" field="ParentRootId"/>
    <alias name="" index="20" field="ParentStartDate"/>
    <alias name="" index="21" field="ParentEndDate"/>
    <alias name="" index="22" field="CreateDate"/>
    <alias name="" index="23" field="CreateAuthor"/>
    <alias name="" index="24" field="ChangeDate"/>
    <alias name="" index="25" field="ChangeAuthor"/>
    <alias name="" index="26" field="TaskGUID"/>
    <alias name="" index="27" field="IsDiffHeightMark"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" expression="" field="fid"/>
    <default applyOnUpdate="0" expression="" field="OghObjectType"/>
    <default applyOnUpdate="0" expression="" field="ObjectId"/>
    <default applyOnUpdate="0" expression="" field="RootId"/>
    <default applyOnUpdate="0" expression="" field="StartDate"/>
    <default applyOnUpdate="0" expression="" field="EndDate"/>
    <default applyOnUpdate="0" expression="" field="ConvElementType"/>
    <default applyOnUpdate="0" expression="" field="OdhSide"/>
    <default applyOnUpdate="0" expression="" field="OdhAxis"/>
    <default applyOnUpdate="0" expression="" field="BordBegin"/>
    <default applyOnUpdate="0" expression="" field="BordEnd"/>
    <default applyOnUpdate="0" expression="" field="Property"/>
    <default applyOnUpdate="0" expression="" field="Area"/>
    <default applyOnUpdate="0" expression="" field="IsObjectArea"/>
    <default applyOnUpdate="0" expression="" field="Placement"/>
    <default applyOnUpdate="0" expression="" field="IdRfid"/>
    <default applyOnUpdate="0" expression="" field="Description"/>
    <default applyOnUpdate="0" expression="" field="ParentOghObjectType"/>
    <default applyOnUpdate="0" expression="" field="ParentObjectId"/>
    <default applyOnUpdate="0" expression="" field="ParentRootId"/>
    <default applyOnUpdate="0" expression="" field="ParentStartDate"/>
    <default applyOnUpdate="0" expression="" field="ParentEndDate"/>
    <default applyOnUpdate="0" expression="" field="CreateDate"/>
    <default applyOnUpdate="0" expression="" field="CreateAuthor"/>
    <default applyOnUpdate="0" expression="" field="ChangeDate"/>
    <default applyOnUpdate="0" expression="" field="ChangeAuthor"/>
    <default applyOnUpdate="0" expression="" field="TaskGUID"/>
    <default applyOnUpdate="0" expression="" field="IsDiffHeightMark"/>
  </defaults>
  <constraints>
    <constraint constraints="3" unique_strength="1" exp_strength="0" field="fid" notnull_strength="1"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OghObjectType" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ObjectId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="RootId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="StartDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="EndDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ConvElementType" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OdhSide" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OdhAxis" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="BordBegin" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="BordEnd" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="Property" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="Area" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="IsObjectArea" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="Placement" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="IdRfid" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="Description" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ParentOghObjectType" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ParentObjectId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ParentRootId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ParentStartDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ParentEndDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="CreateDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="CreateAuthor" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ChangeDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ChangeAuthor" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="TaskGUID" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="IsDiffHeightMark" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="fid" exp=""/>
    <constraint desc="" field="OghObjectType" exp=""/>
    <constraint desc="" field="ObjectId" exp=""/>
    <constraint desc="" field="RootId" exp=""/>
    <constraint desc="" field="StartDate" exp=""/>
    <constraint desc="" field="EndDate" exp=""/>
    <constraint desc="" field="ConvElementType" exp=""/>
    <constraint desc="" field="OdhSide" exp=""/>
    <constraint desc="" field="OdhAxis" exp=""/>
    <constraint desc="" field="BordBegin" exp=""/>
    <constraint desc="" field="BordEnd" exp=""/>
    <constraint desc="" field="Property" exp=""/>
    <constraint desc="" field="Area" exp=""/>
    <constraint desc="" field="IsObjectArea" exp=""/>
    <constraint desc="" field="Placement" exp=""/>
    <constraint desc="" field="IdRfid" exp=""/>
    <constraint desc="" field="Description" exp=""/>
    <constraint desc="" field="ParentOghObjectType" exp=""/>
    <constraint desc="" field="ParentObjectId" exp=""/>
    <constraint desc="" field="ParentRootId" exp=""/>
    <constraint desc="" field="ParentStartDate" exp=""/>
    <constraint desc="" field="ParentEndDate" exp=""/>
    <constraint desc="" field="CreateDate" exp=""/>
    <constraint desc="" field="CreateAuthor" exp=""/>
    <constraint desc="" field="ChangeDate" exp=""/>
    <constraint desc="" field="ChangeAuthor" exp=""/>
    <constraint desc="" field="TaskGUID" exp=""/>
    <constraint desc="" field="IsDiffHeightMark" exp=""/>
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
      <labelFont style="" description="Sans Serif,9,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" verticalStretch="0" name="RootId" index="3" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer showLabel="1" verticalStretch="0" collapsed="0" name="Назначение" columnCount="4" collapsedExpressionEnabled="0" type="GroupBox" horizontalStretch="0" visibilityExpression="" groupBox="1" collapsedExpression="" visibilityExpressionEnabled="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" name="ConvElementType" index="6" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" verticalStretch="0" collapsed="0" name="Привязка" columnCount="4" collapsedExpressionEnabled="0" type="Tab" horizontalStretch="0" visibilityExpression="" groupBox="0" collapsedExpression="" visibilityExpressionEnabled="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" name="OdhAxis" index="8" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="OdhSide" index="7" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="BordBegin" index="9" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="BordEnd" index="10" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" verticalStretch="0" collapsed="0" name="Параметры" columnCount="4" collapsedExpressionEnabled="0" type="GroupBox" horizontalStretch="0" visibilityExpression="" groupBox="1" collapsedExpression="" visibilityExpressionEnabled="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" name="IsObjectArea" index="13" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="Area" index="12" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="IdRfid" index="15" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="Property" index="11" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="Description" index="16" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" verticalStretch="0" drawLine="0" name="Spacer Widget" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
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
    <field name="ConvElementType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="Description" editable="1"/>
    <field name="Distance" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FlatElementType" editable="1"/>
    <field name="IdRfid" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="IsObjectArea" editable="1"/>
    <field name="ManualCleanArea" editable="1"/>
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
    <field name="Property" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
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
    <field name="ConvElementType" labelOnTop="1"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="Description" labelOnTop="1"/>
    <field name="Distance" labelOnTop="1"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FlatElementType" labelOnTop="1"/>
    <field name="IdRfid" labelOnTop="1"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="IsObjectArea" labelOnTop="1"/>
    <field name="ManualCleanArea" labelOnTop="1"/>
    <field name="NoCleanArea" labelOnTop="1"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="OdhAxis" labelOnTop="1"/>
    <field name="OdhSide" labelOnTop="1"/>
    <field name="OghObjectType" labelOnTop="0"/>
    <field name="ParentEndDate" labelOnTop="0"/>
    <field name="ParentObjectId" labelOnTop="0"/>
    <field name="ParentOghObjectType" labelOnTop="0"/>
    <field name="ParentRootId" labelOnTop="0"/>
    <field name="ParentStartDate" labelOnTop="0"/>
    <field name="Placement" labelOnTop="0"/>
    <field name="Property" labelOnTop="1"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
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
    <field reuseLastValue="0" name="ConvElementType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="Description"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="IdRfid"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsObjectArea"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
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
    <field reuseLastValue="0" name="Property"/>
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
  <layerGeometryType>0</layerGeometryType>
</qgis>
