<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis autoRefreshMode="Disabled" simplifyDrawingTol="1" hasScaleBasedVisibilityFlag="0" version="3.44.1-Solothurn" minScale="100000000" labelsEnabled="0" simplifyLocal="1" maxScale="0" autoRefreshTime="0" simplifyMaxScale="1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" symbologyReferenceScale="-1" simplifyDrawingHints="0" simplifyAlgorithm="0">
  <renderer-v2 enableorderby="0" type="RuleRenderer" symbollevels="0" forceraster="0" referencescale="-1">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule label="Точки привязки" symbol="0" filter="&quot;fid&quot; is not NULL" key="{76bce201-04d7-4b3a-9039-c1a689f969ec}" checkstate="0"/>
      <rule label="МАФ" symbol="1" filter="MafTypeLevel1 is not null" key="{67dab356-460a-4bcc-b6a3-8c8acbaf0dbd}"/>
      <rule label="МАФ без типа" symbol="2" filter="ELSE" key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}"/>
    </rules>
    <symbols>
      <symbol alpha="1" force_rhr="0" frame_rate="10" type="marker" clip_to_extent="1" is_animated="0" name="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" enabled="1" locked="0" pass="1">
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
      <symbol alpha="1" force_rhr="0" frame_rate="10" type="marker" clip_to_extent="1" is_animated="0" name="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" enabled="1" locked="0" pass="0">
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
            <Option type="QString" value="14" name="size"/>
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
        <layer class="SimpleMarker" id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" enabled="1" locked="0" pass="0">
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
                  <Option type="QString" value="Svg_HAPoint" name="expression"/>
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
      <symbol alpha="1" force_rhr="0" frame_rate="10" type="marker" clip_to_extent="1" is_animated="0" name="2">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" enabled="1" locked="0" pass="0">
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
            <Option type="QString" value="14" name="size"/>
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
        <layer class="SimpleMarker" id="{ddd6d751-2721-4924-b801-ffea9c7601c8}" enabled="1" locked="0" pass="0">
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
      <symbol alpha="1" force_rhr="0" frame_rate="10" type="marker" clip_to_extent="1" is_animated="0" name="">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" enabled="1" locked="0" pass="0">
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
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
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
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;AllowedPoint&quot; and &#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________1_a140e87d_1810_4fb2_864a_2741df5a73f7" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 1" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel1&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="false" name="OrderByKey"/>
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
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;AllowedPoint&quot; and &quot;ParentCode&quot; = current_value('MafTypeLevel1') and &#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________2_40eadad6_e726_47b4_9012_2e3463669209" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 2" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel2&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="false" name="OrderByKey"/>
            <Option type="bool" value="true" name="OrderByValue"/>
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
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;AllowedPoint&quot; and &quot;ParentLevel1Code&quot; = current_value('MafTypeLevel1') and &#xa;&quot;ParentLevel2Code&quot; = current_value('MafTypeLevel2') and &#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________3_6ca3c1f7_9d3f_43b3_9a9a_1844f93ff1d2" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МАФ уровень 3" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;MafTypeLevel3&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="false" name="OrderByKey"/>
            <Option type="bool" value="true" name="OrderByValue"/>
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
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="array_contains( string_to_array( replace(&quot;TaskTypeId&quot;, array('[', ']'), '')), @MggtAsuTaskType)" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_____________________e9b3d002_10fa_48f8_b206_7568db784c13" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО/ОДХ) Материалы" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;" name="LayerSource"/>
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
    <alias index="27" field="CreateDate" name=""/>
    <alias index="28" field="CreateAuthor" name=""/>
    <alias index="29" field="ChangeDate" name=""/>
    <alias index="30" field="ChangeAuthor" name=""/>
    <alias index="31" field="TaskGUID" name=""/>
    <alias index="32" field="Svg" name="Иконка SVG"/>
    <alias index="33" field="Svg_VAPoint" name="Вертикальная точка привязки"/>
    <alias index="34" field="Svg_HAPoint" name="Горизонтальная точка привязки"/>
  </aliases>
  <splitPolicies>
    <policy policy="DefaultValue" field="fid"/>
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
    <policy policy="DefaultValue" field="TaskGUID"/>
    <policy policy="DefaultValue" field="Svg"/>
    <policy policy="DefaultValue" field="Svg_VAPoint"/>
    <policy policy="DefaultValue" field="Svg_HAPoint"/>
  </splitPolicies>
  <defaults>
    <default applyOnUpdate="0" expression="" field="fid"/>
    <default applyOnUpdate="0" expression="" field="OghObjectType"/>
    <default applyOnUpdate="0" expression="" field="ObjectId"/>
    <default applyOnUpdate="0" expression="" field="RootId"/>
    <default applyOnUpdate="0" expression="" field="StartDate"/>
    <default applyOnUpdate="0" expression="" field="EndDate"/>
    <default applyOnUpdate="0" expression="" field="MafTypeLevel1"/>
    <default applyOnUpdate="0" expression="" field="MafTypeLevel2"/>
    <default applyOnUpdate="0" expression="" field="MafTypeLevel3"/>
    <default applyOnUpdate="0" expression="" field="MafQuantityCharacteristics"/>
    <default applyOnUpdate="0" expression="1" field="Quantity"/>
    <default applyOnUpdate="0" expression="'things'" field="Unit"/>
    <default applyOnUpdate="0" expression="NULL" field="Material"/>
    <default applyOnUpdate="0" expression="" field="InstallationDate"/>
    <default applyOnUpdate="0" expression="" field="Lifetime"/>
    <default applyOnUpdate="0" expression="" field="GuaranteePeriod"/>
    <default applyOnUpdate="0" expression="" field="IdRfid"/>
    <default applyOnUpdate="0" expression="" field="ZoneOghObjectType"/>
    <default applyOnUpdate="0" expression="" field="ZoneOghObjectRootId"/>
    <default applyOnUpdate="0" expression="" field="FileList"/>
    <default applyOnUpdate="0" expression="FALSE" field="NoCalc"/>
    <default applyOnUpdate="0" expression="FALSE" field="IsDiffHeightMark"/>
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
    <default applyOnUpdate="1" expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('Code', &quot;MafTypeLevel3&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'ParentLevel1Code', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('Code', &quot;MafTypeLevel2&quot;, 'ParentCode', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'SvgName') + '.svg'&#xa;&#x9;ELSE @MggtAsuSvgPath + '/Неизвестный.svg'&#xa;END" field="Svg"/>
    <default applyOnUpdate="1" expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('ParentLevel1Code', &quot;MafTypeLevel1&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'Code', &quot;MafTypeLevel3&quot;)), 'AnchorPointV')&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('ParentCode', &quot;MafTypeLevel1&quot;, 'Code', &quot;MafTypeLevel2&quot;)), 'AnchorPointV')&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xa;&#x9;ELSE 'Bottom'&#xa;END" field="Svg_VAPoint"/>
    <default applyOnUpdate="1" expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('ParentLevel1Code', &quot;MafTypeLevel1&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'Code', &quot;MafTypeLevel3&quot;)), 'AnchorPointH')&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('ParentCode', &quot;MafTypeLevel1&quot;, 'Code', &quot;MafTypeLevel2&quot;)), 'AnchorPointH')&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xa;&#x9;ELSE 'HCenter'&#xa;END" field="Svg_HAPoint"/>
  </defaults>
  <constraints>
    <constraint unique_strength="1" exp_strength="0" constraints="3" notnull_strength="1" field="fid"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="OghObjectType"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ObjectId"/>
    <constraint unique_strength="0" exp_strength="0" constraints="1" notnull_strength="2" field="RootId"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="StartDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="EndDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="MafTypeLevel1"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="MafTypeLevel2"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="MafTypeLevel3"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="MafQuantityCharacteristics"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Quantity"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Unit"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Material"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="InstallationDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Lifetime"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="GuaranteePeriod"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="IdRfid"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ZoneOghObjectType"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ZoneOghObjectRootId"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="FileList"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="NoCalc"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="IsDiffHeightMark"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ParentOghObjectType"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ParentObjectId"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ParentRootId"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ParentStartDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ParentEndDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="CreateDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="CreateAuthor"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ChangeDate"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="ChangeAuthor"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="TaskGUID"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Svg"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Svg_VAPoint"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" notnull_strength="0" field="Svg_HAPoint"/>
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
    <constraint desc="" field="CreateDate" exp=""/>
    <constraint desc="" field="CreateAuthor" exp=""/>
    <constraint desc="" field="ChangeDate" exp=""/>
    <constraint desc="" field="ChangeAuthor" exp=""/>
    <constraint desc="" field="TaskGUID" exp=""/>
    <constraint desc="" field="Svg" exp=""/>
    <constraint desc="" field="Svg_VAPoint" exp=""/>
    <constraint desc="" field="Svg_HAPoint" exp=""/>
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
      <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
    </labelStyle>
    <attributeEditorField horizontalStretch="0" verticalStretch="0" index="3" showLabel="1" name="RootId">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer visibilityExpression="" horizontalStretch="0" visibilityExpressionEnabled="0" type="GroupBox" groupBox="1" collapsedExpressionEnabled="0" collapsedExpression="" verticalStretch="0" collapsed="0" showLabel="1" columnCount="6" name="Назначение">
      <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
        <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="6" showLabel="1" name="MafTypeLevel1">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="7" showLabel="1" name="MafTypeLevel2">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="8" showLabel="1" name="MafTypeLevel3">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="12" showLabel="1" name="Material">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="10" showLabel="1" name="Quantity">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="11" showLabel="1" name="Unit">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" horizontalStretch="0" visibilityExpressionEnabled="0" type="GroupBox" groupBox="1" collapsedExpressionEnabled="0" collapsedExpression="" verticalStretch="0" collapsed="0" showLabel="1" columnCount="6" name="Параметры">
      <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
        <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="13" showLabel="1" name="InstallationDate">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="14" showLabel="1" name="Lifetime">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="15" showLabel="1" name="GuaranteePeriod">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="16" showLabel="1" name="IdRfid">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="20" showLabel="1" name="NoCalc">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="21" showLabel="1" name="IsDiffHeightMark">
        <labelStyle overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" horizontalStretch="0" visibilityExpressionEnabled="0" type="Tab" groupBox="0" collapsedExpressionEnabled="0" collapsedExpression="" verticalStretch="0" collapsed="0" showLabel="1" columnCount="3" name="Параметры SVG">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="32" showLabel="1" name="Svg">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="33" showLabel="1" name="Svg_VAPoint">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="34" showLabel="1" name="Svg_HAPoint">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" horizontalStretch="0" verticalStretch="0" showLabel="0" name="SpacerWidget">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont bold="0" underline="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0"/>
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
    <field editable="0" name="Svg"/>
    <field editable="0" name="Svg_HAPoint"/>
    <field editable="0" name="Svg_VAPoint"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="Unit"/>
    <field editable="1" name="ZoneOghObjectRootId"/>
    <field editable="1" name="ZoneOghObjectType"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="0" name="FileList"/>
    <field labelOnTop="1" name="GuaranteePeriod"/>
    <field labelOnTop="1" name="IdRfid"/>
    <field labelOnTop="1" name="InstallationDate"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="Lifetime"/>
    <field labelOnTop="0" name="MafQuantityCharacteristics"/>
    <field labelOnTop="1" name="MafTypeLevel1"/>
    <field labelOnTop="1" name="MafTypeLevel2"/>
    <field labelOnTop="1" name="MafTypeLevel3"/>
    <field labelOnTop="1" name="Material"/>
    <field labelOnTop="1" name="NoCalc"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="Quantity"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="1" name="Svg"/>
    <field labelOnTop="1" name="Svg_HAPoint"/>
    <field labelOnTop="1" name="Svg_VAPoint"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="Unit"/>
    <field labelOnTop="0" name="ZoneOghObjectRootId"/>
    <field labelOnTop="0" name="ZoneOghObjectType"/>
    <field labelOnTop="0" name="fid"/>
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
    <field reuseLastValue="0" name="Svg"/>
    <field reuseLastValue="0" name="Svg_HAPoint"/>
    <field reuseLastValue="0" name="Svg_VAPoint"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="Unit"/>
    <field reuseLastValue="0" name="ZoneOghObjectRootId"/>
    <field reuseLastValue="0" name="ZoneOghObjectType"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
