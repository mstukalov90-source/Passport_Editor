<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" simplifyDrawingHints="0" simplifyAlgorithm="0" autoRefreshTime="0" labelsEnabled="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" autoRefreshMode="Disabled" simplifyLocal="1" symbologyReferenceScale="-1" minScale="100000000" simplifyMaxScale="1" version="3.44.8-Solothurn" simplifyDrawingTol="1" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1" symbollevels="0">
    <rules key="{26f1ae03-d9ab-4449-b30a-1be61ed6b33d}">
      <rule symbol="0" label="Точки привязки" filter="&quot;fid&quot; is not NULL" checkstate="0" key="{36c664b7-24d2-4067-a14f-caf8d3837819}"/>
      <rule symbol="1" label="Бетонный парапет" filter="&quot;EquipmentKind&quot; in ('210', '225')" key="{c4ebd2af-9142-45dc-b38e-5fae5997a732}"/>
      <rule symbol="2" label="Боллард автоматический" filter="&quot;EquipmentKind&quot; in ('213', '228')" key="{027684c8-70b3-4953-be13-966f4159c315}"/>
      <rule symbol="3" label="Буфер безопасности" filter="&quot;EquipmentKind&quot; in ('200', '215')" key="{1b476cad-5d5f-4d7e-b06b-f51e148614dd}"/>
      <rule symbol="4" label="Защитный экран" filter="&quot;EquipmentKind&quot; in ('206', '221')" key="{95152dfc-4792-4e93-b86c-4c271c88df24}"/>
      <rule symbol="5" label="Иное ограждение (не на содержании по ТС)" filter="&quot;EquipmentKind&quot; in ('214', '232')" key="{da20b29f-07f2-4cba-9b18-08a2081b74de}"/>
      <rule symbol="6" label="МБО. Волна" filter="&quot;EquipmentKind&quot; in ('202', '217')" key="{17009dbb-a3e4-4acb-bf61-0bbbc8c1858f}"/>
      <rule symbol="7" label="МБО. Трансбарьер" filter="&quot;EquipmentKind&quot; in ('203', '218')" key="{232559ae-7031-4ede-a75f-0fac435da1ca}"/>
      <rule symbol="8" label="МБО. Труба" filter="&quot;EquipmentKind&quot; in ('201', '216')" key="{10efae9b-c3cf-4386-9cc1-120199e9ff1f}"/>
      <rule symbol="9" label="МБО. Фракассо" filter="&quot;EquipmentKind&quot; in ('205', '220')" key="{1bd88d3f-5a00-4b8e-aba5-cacb56f84ef5}"/>
      <rule symbol="10" label="Металлическое перильное ограждение" filter="&quot;EquipmentKind&quot; in ('212', '227')" key="{7adb08f5-248b-40db-9521-55b83970d199}"/>
      <rule symbol="11" label="Мостовое ограждение типа стенки 'Нью-Джерси'" filter="&quot;EquipmentKind&quot; in ('211', '226')" key="{a237b113-5b89-43b9-b253-67b2d5351dd8}"/>
      <rule symbol="12" label="Пешеходные ограждения ОРУД до 1 м" filter="&quot;EquipmentKind&quot; in ('207', '222')" key="{60403f3c-20f1-479b-b9df-c3b23d68f8a1}"/>
      <rule symbol="13" label="Пешеходное ограждение декоративное" filter="&quot;EquipmentKind&quot; in ('208', '223')" key="{9f3f2faa-880e-4d23-ac5f-69b6b54803c2}"/>
      <rule symbol="14" label="Стенка 'Нью-Джерси'" filter="&quot;EquipmentKind&quot; in ('204', '219')" key="{b8b99174-c45f-4bd3-b7aa-aa8107675818}"/>
      <rule symbol="15" label="Тротуарные столбики" filter="&quot;EquipmentKind&quot; in ('209', '224')" key="{1a5e2f19-3db7-436d-99fe-0e4128bed2e5}"/>
      <rule symbol="16" label="Нет данных" filter="ELSE" key="{fc3feefa-2a27-42d7-a098-248cb975ed08}"/>
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
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="10" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="11" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="12" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="13" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="14" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="15" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{627ba764-4752-437d-93b8-03853bbb46c0}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MapUnit"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MapUnit"/>
            <Option name="parameters"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="18"/>
            <Option name="size_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="size_unit" type="QString" value="MapUnit"/>
            <Option name="vertical_anchor_point" type="QString" value="1"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option name="active" type="bool" value="true"/>
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Антипарковочный столбик.svg'"/>
                  <Option name="type" type="int" value="3"/>
                </Option>
              </Option>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol clip_to_extent="1" name="16" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
        <layer id="{627ba764-4752-437d-93b8-03853bbb46c0}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MapUnit"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MapUnit"/>
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
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Боллард.svg'"/>
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
        <layer id="{627ba764-4752-437d-93b8-03853bbb46c0}" pass="0" class="SvgMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
            <Option name="fixedAspectRatio" type="QString" value="0"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MapUnit"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MapUnit"/>
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
                  <Option name="expression" type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Буфер безопасности 1.svg'"/>
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
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="5" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="6" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="7" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="8" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
      <symbol clip_to_extent="1" name="9" alpha="1" type="marker" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer id="{ee848133-d236-483e-98f8-605fcc24489f}" pass="0" class="SimpleMarker" locked="0" enabled="1">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="229,182,54,255,rgb:0.8980392,0.7137255,0.2117647,1"/>
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
        <layer id="{a2ae7e88-e446-48ea-af93-af00fddb293a}" pass="0" class="SimpleMarker" locked="0" enabled="1">
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
    <field name="EquipmentKind" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="QString" value="Name"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="________________________________04f71f78_4edb_4986_9649_f0967da32890"/>
            <Option name="LayerName" type="QString" value="Справочник (ОДХ) Тип ограждения"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;EquipmentKind&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByDescending" type="bool" value="false"/>
            <Option name="OrderByField" type="bool" value="false"/>
            <Option name="OrderByFieldName" type="invalid"/>
            <Option name="OrderByKey" type="bool" value="false"/>
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
            <Option name="Layer" type="QString" value="______________________________________5f058f67_eee3_4e6f_9756_6f9a64c4fefc"/>
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
            <Option name="Layer" type="QString" value="_____________b47564a4_7633_4b6b_845b_43479f8f677f"/>
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
    <field name="QuantityRm" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+07"/>
            <Option name="Min" type="double" value="0"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="0.1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="QuantityPcs" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+07"/>
            <Option name="Min" type="double" value="0"/>
            <Option name="Precision" type="int" value="0"/>
            <Option name="Step" type="double" value="1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Area" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+07"/>
            <Option name="Min" type="double" value="0"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="0.1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="GuttersLength" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1e+07"/>
            <Option name="Min" type="double" value="0"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="0.1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
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
    <field name="IsTitle" configurationFlags="NoFlag">
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
  </fieldConfiguration>
  <aliases>
    <alias name="" index="0" field="fid"/>
    <alias name="" index="1" field="OghObjectType"/>
    <alias name="" index="2" field="ObjectId"/>
    <alias name="" index="3" field="RootId"/>
    <alias name="" index="4" field="StartDate"/>
    <alias name="" index="5" field="EndDate"/>
    <alias name="" index="6" field="EquipmentKind"/>
    <alias name="" index="7" field="OdhSide"/>
    <alias name="" index="8" field="OdhAxis"/>
    <alias name="" index="9" field="BordBegin"/>
    <alias name="" index="10" field="BordEnd"/>
    <alias name="" index="11" field="QuantityRm"/>
    <alias name="" index="12" field="QuantityPcs"/>
    <alias name="" index="13" field="Area"/>
    <alias name="" index="14" field="GuttersLength"/>
    <alias name="" index="15" field="Description"/>
    <alias name="" index="16" field="ParentOghObjectType"/>
    <alias name="" index="17" field="ParentObjectId"/>
    <alias name="" index="18" field="ParentRootId"/>
    <alias name="" index="19" field="ParentStartDate"/>
    <alias name="" index="20" field="ParentEndDate"/>
    <alias name="" index="21" field="CreateDate"/>
    <alias name="" index="22" field="CreateAuthor"/>
    <alias name="" index="23" field="ChangeDate"/>
    <alias name="" index="24" field="ChangeAuthor"/>
    <alias name="" index="25" field="TaskGUID"/>
    <alias name="" index="26" field="IsDiffHeightMark"/>
    <alias name="Включать в ТС" index="27" field="IsTitle"/>
  </aliases>
  <splitPolicies>
    <policy field="EquipmentKind" policy="DefaultValue"/>
    <policy field="IsTitle" policy="DefaultValue"/>
  </splitPolicies>
  <defaults>
    <default applyOnUpdate="0" expression="" field="fid"/>
    <default applyOnUpdate="0" expression="" field="OghObjectType"/>
    <default applyOnUpdate="0" expression="" field="ObjectId"/>
    <default applyOnUpdate="0" expression="" field="RootId"/>
    <default applyOnUpdate="0" expression="" field="StartDate"/>
    <default applyOnUpdate="0" expression="" field="EndDate"/>
    <default applyOnUpdate="0" expression="" field="EquipmentKind"/>
    <default applyOnUpdate="0" expression="" field="OdhSide"/>
    <default applyOnUpdate="0" expression="" field="OdhAxis"/>
    <default applyOnUpdate="0" expression="" field="BordBegin"/>
    <default applyOnUpdate="0" expression="" field="BordEnd"/>
    <default applyOnUpdate="0" expression="" field="QuantityRm"/>
    <default applyOnUpdate="0" expression="" field="QuantityPcs"/>
    <default applyOnUpdate="0" expression="" field="Area"/>
    <default applyOnUpdate="0" expression="" field="GuttersLength"/>
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
    <default applyOnUpdate="0" expression="" field="IsTitle"/>
  </defaults>
  <constraints>
    <constraint constraints="3" unique_strength="1" exp_strength="0" field="fid" notnull_strength="1"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OghObjectType" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="ObjectId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="RootId" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="StartDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="EndDate" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="EquipmentKind" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OdhSide" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="OdhAxis" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="BordBegin" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="BordEnd" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="QuantityRm" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="QuantityPcs" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="Area" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="GuttersLength" notnull_strength="0"/>
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
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="IsTitle" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="fid" exp=""/>
    <constraint desc="" field="OghObjectType" exp=""/>
    <constraint desc="" field="ObjectId" exp=""/>
    <constraint desc="" field="RootId" exp=""/>
    <constraint desc="" field="StartDate" exp=""/>
    <constraint desc="" field="EndDate" exp=""/>
    <constraint desc="" field="EquipmentKind" exp=""/>
    <constraint desc="" field="OdhSide" exp=""/>
    <constraint desc="" field="OdhAxis" exp=""/>
    <constraint desc="" field="BordBegin" exp=""/>
    <constraint desc="" field="BordEnd" exp=""/>
    <constraint desc="" field="QuantityRm" exp=""/>
    <constraint desc="" field="QuantityPcs" exp=""/>
    <constraint desc="" field="Area" exp=""/>
    <constraint desc="" field="GuttersLength" exp=""/>
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
    <constraint desc="" field="IsTitle" exp=""/>
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
      <attributeEditorField showLabel="1" verticalStretch="0" name="EquipmentKind" index="6" horizontalStretch="0">
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
      <attributeEditorField showLabel="1" verticalStretch="0" name="GuttersLength" index="14" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="QuantityRm" index="11" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="QuantityPcs" index="12" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="Area" index="13" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="Description" index="15" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" italic="0" strikethrough="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" name="IsTitle" index="27" horizontalStretch="0">
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
    <field name="EquipmentKind" editable="1"/>
    <field name="FlatElementType" editable="1"/>
    <field name="GuttersLength" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="IsGutterZone" editable="1"/>
    <field name="IsTitle" editable="1"/>
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
    <field name="BoundStoneMark" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CoatingGroup" labelOnTop="1"/>
    <field name="CoatingType" labelOnTop="1"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="Description" labelOnTop="1"/>
    <field name="Distance" labelOnTop="1"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="EquipmentKind" labelOnTop="1"/>
    <field name="FlatElementType" labelOnTop="1"/>
    <field name="GuttersLength" labelOnTop="1"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="IsGutterZone" labelOnTop="1"/>
    <field name="IsTitle" labelOnTop="1"/>
    <field name="ManualCleanArea" labelOnTop="1"/>
    <field name="Material" labelOnTop="1"/>
    <field name="NearRoadway" labelOnTop="1"/>
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
    <field name="QuantityPcs" labelOnTop="1"/>
    <field name="QuantityRm" labelOnTop="1"/>
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
    <field reuseLastValue="0" name="EquipmentKind"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="GuttersLength"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsGutterZone"/>
    <field reuseLastValue="0" name="IsTitle"/>
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
