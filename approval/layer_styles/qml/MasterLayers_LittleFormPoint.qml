<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" styleCategories="Symbology|Labeling|Fields|Forms|Actions|Rendering" labelsEnabled="0" simplifyLocal="1" autoRefreshMode="Disabled" simplifyDrawingTol="1" autoRefreshTime="0" hasScaleBasedVisibilityFlag="0" simplifyMaxScale="1" minScale="100000000" version="3.44.1-Solothurn" simplifyDrawingHints="0" symbologyReferenceScale="-1" simplifyAlgorithm="0">
  <renderer-v2 symbollevels="0" referencescale="-1" forceraster="0" type="RuleRenderer" enableorderby="0">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule symbol="0" filter="MafTypeLevel1 is not null" key="{67dab356-460a-4bcc-b6a3-8c8acbaf0dbd}" label="МАФ"/>
      <rule symbol="1" filter="ELSE" key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}" label="МАФ без типа"/>
    </rules>
    <symbols>
      <symbol frame_rate="10" alpha="0.3" is_animated="0" force_rhr="0" type="marker" name="0" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" locked="0" class="SvgMarker" id="{23c2d428-6912-469e-ba43-da7e391c8a35}">
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
                  <Option type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;ELSE 'HCenter'&#xd;&#xa;END" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('Code', &quot;MafTypeLevel3&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'ParentLevel1Code', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('Code', &quot;MafTypeLevel2&quot;, 'ParentCode', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN @MggtAsuPluginPath + @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'SvgName') + '.svg'&#xa;&#x9;ELSE @MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'&#xa;END" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;ELSE 'Bottom'&#xd;&#xa;END" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer enabled="1" pass="0" locked="0" class="SimpleMarker" id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="255,255,255,255,hsv:0,0,1,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="circle" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="0,0,255,255,rgb:0,0,1,1" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="0.05" name="size"/>
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
                  <Option type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;ELSE 'HCenter'&#xd;&#xa;END" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;ELSE 'Bottom'&#xd;&#xa;END" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol frame_rate="10" alpha="0.3" is_animated="0" force_rhr="0" type="marker" name="1" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" locked="0" class="SvgMarker" id="{23c2d428-6912-469e-ba43-da7e391c8a35}">
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
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer enabled="1" pass="0" locked="0" class="SimpleMarker" id="{ddd6d751-2721-4924-b801-ffea9c7601c8}">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="255,255,255,255,hsv:0,0,1,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="circle" name="name"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="0,0,255,255,rgb:0,0,1,1" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0" name="outline_width"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="diameter" name="scale_method"/>
            <Option type="QString" value="0.05" name="size"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="size_map_unit_scale"/>
            <Option type="QString" value="MapUnit" name="size_unit"/>
            <Option type="QString" value="2" name="vertical_anchor_point"/>
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
      <symbol frame_rate="10" alpha="1" is_animated="0" force_rhr="0" type="marker" name="" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" locked="0" class="SimpleMarker" id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}">
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MafTypeLevel1">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________1_0553c65d_ebeb_4d89_b314_5faed846cb0e" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 1" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel1&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MafTypeLevel2">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="QString" value="&quot;ParentCode&quot; = current_value('MafTypeLevel1')" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________2_c8589e0f_f580_4346_826c_685a1f57270e" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 2" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel2&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MafTypeLevel3">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="QString" value="&quot;ParentCode&quot; = current_value('MafTypeLevel1')" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________3_8766452f_7dff_4f94_870a_806395dfec19" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 3" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel3&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MafQuantityCharacteristics">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Quantity">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1.7976931348623157e+308" name="Max"/>
            <Option type="double" value="-1.7976931348623157e+308" name="Min"/>
            <Option type="int" value="0" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Unit">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_____________________________ecff5a26_bc62_4cb1_a010_5551501622e1" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО/ОДХ) Единицы измерения" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Units&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Material">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_____________________5057f45b_2d28_4e10_a0f9_aa010ffcc2e0" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО/ОДХ) Материалы" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="InstallationDate">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd.MM.yyyy" name="display_format"/>
            <Option type="QString" value="yyyy-MM-dd HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_format_overwrite"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Lifetime">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd.MM.yyyy" name="display_format"/>
            <Option type="QString" value="yyyy-MM-dd HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_format_overwrite"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="GuaranteePeriod">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd.MM.yyyy" name="display_format"/>
            <Option type="QString" value="yyyy-MM-dd HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_format_overwrite"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IdRfid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ZoneOghObjectType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
          <Option/>
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
    <alias index="0" field="fid" name=""/>
    <alias index="1" field="OghObjectType" name=""/>
    <alias index="2" field="ObjectId" name=""/>
    <alias index="3" field="RootId" name="Идентификатор ОГХ (RootId)"/>
    <alias index="4" field="StartDate" name=""/>
    <alias index="5" field="EndDate" name=""/>
    <alias index="6" field="MafTypeLevel1" name="Тип 1"/>
    <alias index="7" field="MafTypeLevel2" name="Тип 2"/>
    <alias index="8" field="MafTypeLevel3" name="Тип 3"/>
    <alias index="9" field="MafQuantityCharacteristics" name=""/>
    <alias index="10" field="Quantity" name="Количество"/>
    <alias index="11" field="Unit" name="Единицы измерения"/>
    <alias index="12" field="Material" name="Материал"/>
    <alias index="13" field="InstallationDate" name="Дата установки"/>
    <alias index="14" field="Lifetime" name="Срок эксплуатации"/>
    <alias index="15" field="GuaranteePeriod" name="Гарантийный срок"/>
    <alias index="16" field="IdRfid" name="RFID"/>
    <alias index="17" field="ZoneOghObjectType" name=""/>
    <alias index="18" field="ZoneOghObjectRootId" name=""/>
    <alias index="19" field="FileList" name=""/>
    <alias index="20" field="NoCalc" name="Не учитывать"/>
    <alias index="21" field="IsDiffHeightMark" name="Разновысотные отметки"/>
    <alias index="22" field="ParentOghObjectType" name=""/>
    <alias index="23" field="ParentObjectId" name=""/>
    <alias index="24" field="ParentRootId" name=""/>
    <alias index="25" field="ParentStartDate" name=""/>
    <alias index="26" field="ParentEndDate" name=""/>
  </aliases>
  <splitPolicies>
    <policy policy="DefaultValue" field="RootId"/>
    <policy policy="DefaultValue" field="MafTypeLevel1"/>
    <policy policy="DefaultValue" field="MafTypeLevel2"/>
    <policy policy="DefaultValue" field="MafTypeLevel3"/>
    <policy policy="DefaultValue" field="Quantity"/>
    <policy policy="DefaultValue" field="Unit"/>
    <policy policy="DefaultValue" field="Material"/>
    <policy policy="DefaultValue" field="InstallationDate"/>
    <policy policy="DefaultValue" field="Lifetime"/>
    <policy policy="DefaultValue" field="GuaranteePeriod"/>
    <policy policy="DefaultValue" field="IdRfid"/>
    <policy policy="DefaultValue" field="NoCalc"/>
    <policy policy="DefaultValue" field="IsDiffHeightMark"/>
  </splitPolicies>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="MafTypeLevel1"/>
    <default expression="" applyOnUpdate="0" field="MafTypeLevel2"/>
    <default expression="" applyOnUpdate="0" field="MafTypeLevel3"/>
    <default expression="" applyOnUpdate="0" field="MafQuantityCharacteristics"/>
    <default expression="" applyOnUpdate="0" field="Quantity"/>
    <default expression="" applyOnUpdate="0" field="Unit"/>
    <default expression="" applyOnUpdate="0" field="Material"/>
    <default expression="" applyOnUpdate="0" field="InstallationDate"/>
    <default expression="" applyOnUpdate="0" field="Lifetime"/>
    <default expression="" applyOnUpdate="0" field="GuaranteePeriod"/>
    <default expression="" applyOnUpdate="0" field="IdRfid"/>
    <default expression="" applyOnUpdate="0" field="ZoneOghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ZoneOghObjectRootId"/>
    <default expression="" applyOnUpdate="0" field="FileList"/>
    <default expression="" applyOnUpdate="0" field="NoCalc"/>
    <default expression="" applyOnUpdate="0" field="IsDiffHeightMark"/>
    <default expression="" applyOnUpdate="0" field="ParentOghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ParentObjectId"/>
    <default expression="" applyOnUpdate="0" field="ParentRootId"/>
    <default expression="" applyOnUpdate="0" field="ParentStartDate"/>
    <default expression="" applyOnUpdate="0" field="ParentEndDate"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" notnull_strength="1" unique_strength="1" field="fid" constraints="3"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="OghObjectType" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ObjectId" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="RootId" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="StartDate" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="EndDate" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="MafTypeLevel1" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="MafTypeLevel2" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="MafTypeLevel3" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="MafQuantityCharacteristics" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="Quantity" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="Unit" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="Material" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="InstallationDate" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="Lifetime" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="GuaranteePeriod" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="IdRfid" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ZoneOghObjectType" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ZoneOghObjectRootId" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="FileList" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="NoCalc" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="IsDiffHeightMark" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ParentOghObjectType" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ParentObjectId" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ParentRootId" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ParentStartDate" constraints="0"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" field="ParentEndDate" constraints="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="fid" exp=""/>
    <constraint desc="" field="OghObjectType" exp=""/>
    <constraint desc="" field="ObjectId" exp=""/>
    <constraint desc="" field="RootId" exp=""/>
    <constraint desc="" field="StartDate" exp=""/>
    <constraint desc="" field="EndDate" exp=""/>
    <constraint desc="" field="MafTypeLevel1" exp=""/>
    <constraint desc="" field="MafTypeLevel2" exp=""/>
    <constraint desc="" field="MafTypeLevel3" exp=""/>
    <constraint desc="" field="MafQuantityCharacteristics" exp=""/>
    <constraint desc="" field="Quantity" exp=""/>
    <constraint desc="" field="Unit" exp=""/>
    <constraint desc="" field="Material" exp=""/>
    <constraint desc="" field="InstallationDate" exp=""/>
    <constraint desc="" field="Lifetime" exp=""/>
    <constraint desc="" field="GuaranteePeriod" exp=""/>
    <constraint desc="" field="IdRfid" exp=""/>
    <constraint desc="" field="ZoneOghObjectType" exp=""/>
    <constraint desc="" field="ZoneOghObjectRootId" exp=""/>
    <constraint desc="" field="FileList" exp=""/>
    <constraint desc="" field="NoCalc" exp=""/>
    <constraint desc="" field="IsDiffHeightMark" exp=""/>
    <constraint desc="" field="ParentOghObjectType" exp=""/>
    <constraint desc="" field="ParentObjectId" exp=""/>
    <constraint desc="" field="ParentRootId" exp=""/>
    <constraint desc="" field="ParentStartDate" exp=""/>
    <constraint desc="" field="ParentEndDate" exp=""/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
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
    <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
      <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField index="3" verticalStretch="0" horizontalStretch="0" showLabel="1" name="RootId">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer visibilityExpression="" groupBox="1" type="GroupBox" collapsed="0" verticalStretch="0" horizontalStretch="0" columnCount="6" collapsedExpressionEnabled="0" showLabel="1" name="Назначение" collapsedExpression="" visibilityExpressionEnabled="0">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField index="6" verticalStretch="0" horizontalStretch="0" showLabel="1" name="MafTypeLevel1">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="7" verticalStretch="0" horizontalStretch="0" showLabel="1" name="MafTypeLevel2">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="8" verticalStretch="0" horizontalStretch="0" showLabel="1" name="MafTypeLevel3">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="12" verticalStretch="0" horizontalStretch="0" showLabel="1" name="Material">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="10" verticalStretch="0" horizontalStretch="0" showLabel="1" name="Quantity">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="11" verticalStretch="0" horizontalStretch="0" showLabel="1" name="Unit">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="1" type="GroupBox" collapsed="0" verticalStretch="0" horizontalStretch="0" columnCount="6" collapsedExpressionEnabled="0" showLabel="1" name="Параметры" collapsedExpression="" visibilityExpressionEnabled="0">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField index="13" verticalStretch="0" horizontalStretch="0" showLabel="1" name="InstallationDate">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="14" verticalStretch="0" horizontalStretch="0" showLabel="1" name="Lifetime">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="15" verticalStretch="0" horizontalStretch="0" showLabel="1" name="GuaranteePeriod">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="16" verticalStretch="0" horizontalStretch="0" showLabel="1" name="IdRfid">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="20" verticalStretch="0" horizontalStretch="0" showLabel="1" name="NoCalc">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField index="21" verticalStretch="0" horizontalStretch="0" showLabel="1" name="IsDiffHeightMark">
        <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
          <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" verticalStretch="0" horizontalStretch="0" showLabel="0" name="SpacerWidget">
      <labelStyle overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0">
        <labelFont underline="0" style="" bold="0" italic="0" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="ChangeAuthor"/>
    <field editable="1" name="ChangeDate"/>
    <field editable="1" name="CreateAuthor"/>
    <field editable="1" name="CreateDate"/>
    <field editable="1" name="EndDate"/>
    <field editable="1" name="FileList"/>
    <field editable="1" name="GuaranteePeriod"/>
    <field editable="1" name="IdRfid"/>
    <field editable="1" name="InstallationDate"/>
    <field editable="1" name="IsDiffHeightMark"/>
    <field editable="1" name="Lifetime"/>
    <field editable="1" name="MafQuantityCharacteristics"/>
    <field editable="1" name="MafTypeLevel1"/>
    <field editable="1" name="MafTypeLevel2"/>
    <field editable="1" name="MafTypeLevel3"/>
    <field editable="1" name="Material"/>
    <field editable="1" name="NoCalc"/>
    <field editable="1" name="ObjectId"/>
    <field editable="1" name="OghObjectType"/>
    <field editable="1" name="ParentEndDate"/>
    <field editable="1" name="ParentObjectId"/>
    <field editable="1" name="ParentOghObjectType"/>
    <field editable="1" name="ParentRootId"/>
    <field editable="1" name="ParentStartDate"/>
    <field editable="1" name="Quantity"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="StartDate"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="Unit"/>
    <field editable="1" name="ZoneOghObjectRootId"/>
    <field editable="1" name="ZoneOghObjectType"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="GuaranteePeriod" labelOnTop="1"/>
    <field name="IdRfid" labelOnTop="1"/>
    <field name="InstallationDate" labelOnTop="1"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="Lifetime" labelOnTop="1"/>
    <field name="MafQuantityCharacteristics" labelOnTop="0"/>
    <field name="MafTypeLevel1" labelOnTop="1"/>
    <field name="MafTypeLevel2" labelOnTop="1"/>
    <field name="MafTypeLevel3" labelOnTop="1"/>
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
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FileList"/>
    <field reuseLastValue="0" name="GuaranteePeriod"/>
    <field reuseLastValue="0" name="IdRfid"/>
    <field reuseLastValue="0" name="InstallationDate"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="Lifetime"/>
    <field reuseLastValue="0" name="MafQuantityCharacteristics"/>
    <field reuseLastValue="0" name="MafTypeLevel1"/>
    <field reuseLastValue="0" name="MafTypeLevel2"/>
    <field reuseLastValue="0" name="MafTypeLevel3"/>
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
  <layerGeometryType>0</layerGeometryType>
</qgis>
