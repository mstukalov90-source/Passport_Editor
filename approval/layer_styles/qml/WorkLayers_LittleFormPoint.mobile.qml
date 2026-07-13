<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis autoRefreshMode="Disabled" labelsEnabled="0" simplifyDrawingHints="0" symbologyReferenceScale="-1" maxScale="0" simplifyDrawingTol="1" autoRefreshTime="0" simplifyMaxScale="1" version="3.44.8-Solothurn" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyLocal="1" simplifyAlgorithm="0" minScale="100000000" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1" symbollevels="0">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule label="Точки привязки" symbol="0" key="{76bce201-04d7-4b3a-9039-c1a689f969ec}" checkstate="0" filter="&quot;fid&quot; is not NULL"/>
      <rule label="МАФ" symbol="1" key="{67dab356-460a-4bcc-b6a3-8c8acbaf0dbd}" filter="MafTypeLevel1 is not null"/>
      <rule label="МАФ без типа" symbol="2" key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}" filter="ELSE"/>
    </rules>
    <symbols>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="0" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" locked="0" pass="1" class="SimpleMarker" enabled="1">
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="1" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0" pass="0" class="SvgMarker" enabled="1">
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
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" locked="0" pass="0" class="SimpleMarker" enabled="1">
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="2" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0" pass="0" class="SvgMarker" enabled="1">
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
        <layer id="{ddd6d751-2721-4924-b801-ffea9c7601c8}" locked="0" pass="0" class="SimpleMarker" enabled="1">
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" locked="0" pass="0" class="SimpleMarker" enabled="1">
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
    <alias index="32" field="Svg" name=""/>
    <alias index="33" field="Svg_VAPoint" name=""/>
    <alias index="34" field="Svg_HAPoint" name=""/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="DefaultValue"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="MafTypeLevel1" policy="DefaultValue"/>
    <policy field="MafTypeLevel2" policy="DefaultValue"/>
    <policy field="MafTypeLevel3" policy="DefaultValue"/>
    <policy field="Quantity" policy="DefaultValue"/>
    <policy field="Unit" policy="DefaultValue"/>
    <policy field="Material" policy="DefaultValue"/>
    <policy field="InstallationDate" policy="DefaultValue"/>
    <policy field="Lifetime" policy="DefaultValue"/>
    <policy field="GuaranteePeriod" policy="DefaultValue"/>
    <policy field="IdRfid" policy="DefaultValue"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="IsDiffHeightMark" policy="DefaultValue"/>
    <policy field="TaskGUID" policy="DefaultValue"/>
    <policy field="Svg" policy="DefaultValue"/>
    <policy field="Svg_VAPoint" policy="DefaultValue"/>
    <policy field="Svg_HAPoint" policy="DefaultValue"/>
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
    <default expression="1" applyOnUpdate="0" field="Quantity"/>
    <default expression="'things'" applyOnUpdate="0" field="Unit"/>
    <default expression="NULL" applyOnUpdate="0" field="Material"/>
    <default expression="" applyOnUpdate="0" field="InstallationDate"/>
    <default expression="" applyOnUpdate="0" field="Lifetime"/>
    <default expression="" applyOnUpdate="0" field="GuaranteePeriod"/>
    <default expression="" applyOnUpdate="0" field="IdRfid"/>
    <default expression="" applyOnUpdate="0" field="ZoneOghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ZoneOghObjectRootId"/>
    <default expression="" applyOnUpdate="0" field="FileList"/>
    <default expression="FALSE" applyOnUpdate="0" field="NoCalc"/>
    <default expression="FALSE" applyOnUpdate="0" field="IsDiffHeightMark"/>
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
    <default expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('Code', &quot;MafTypeLevel3&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'ParentLevel1Code', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('Code', &quot;MafTypeLevel2&quot;, 'ParentCode', &quot;MafTypeLevel1&quot;)), 'SvgName') + '.svg'&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'SvgName') + '.svg'&#xa;&#x9;ELSE @MggtAsuSvgPath + '/Неизвестный.svg'&#xa;END" applyOnUpdate="1" field="Svg"/>
    <default expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('ParentLevel1Code', &quot;MafTypeLevel1&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'Code', &quot;MafTypeLevel3&quot;)), 'AnchorPointV')&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('ParentCode', &quot;MafTypeLevel1&quot;, 'Code', &quot;MafTypeLevel2&quot;)), 'AnchorPointV')&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xa;&#x9;ELSE 'Bottom'&#xa;END" applyOnUpdate="1" field="Svg_VAPoint"/>
    <default expression="CASE&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', map('ParentLevel1Code', &quot;MafTypeLevel1&quot;, 'ParentLevel2Code', &quot;MafTypeLevel2&quot;, 'Code', &quot;MafTypeLevel3&quot;)), 'AnchorPointH')&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', map('ParentCode', &quot;MafTypeLevel1&quot;, 'Code', &quot;MafTypeLevel2&quot;)), 'AnchorPointH')&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xa;&#x9;ELSE 'HCenter'&#xa;END" applyOnUpdate="1" field="Svg_HAPoint"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" notnull_strength="1" unique_strength="1" constraints="3" field="fid"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="OghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ObjectId"/>
    <constraint exp_strength="0" notnull_strength="2" unique_strength="0" constraints="1" field="RootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="StartDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="EndDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MafTypeLevel1"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MafTypeLevel2"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MafTypeLevel3"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MafQuantityCharacteristics"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Quantity"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Unit"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Material"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="InstallationDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Lifetime"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="GuaranteePeriod"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="IdRfid"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ZoneOghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ZoneOghObjectRootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="FileList"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="NoCalc"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="IsDiffHeightMark"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentOghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentObjectId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentRootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentStartDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ParentEndDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CreateDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CreateAuthor"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ChangeDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ChangeAuthor"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="TaskGUID"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Svg"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Svg_VAPoint"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Svg_HAPoint"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="MafTypeLevel1"/>
    <constraint desc="" exp="" field="MafTypeLevel2"/>
    <constraint desc="" exp="" field="MafTypeLevel3"/>
    <constraint desc="" exp="" field="MafQuantityCharacteristics"/>
    <constraint desc="" exp="" field="Quantity"/>
    <constraint desc="" exp="" field="Unit"/>
    <constraint desc="" exp="" field="Material"/>
    <constraint desc="" exp="" field="InstallationDate"/>
    <constraint desc="" exp="" field="Lifetime"/>
    <constraint desc="" exp="" field="GuaranteePeriod"/>
    <constraint desc="" exp="" field="IdRfid"/>
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
    <constraint desc="" exp="" field="Svg"/>
    <constraint desc="" exp="" field="Svg_VAPoint"/>
    <constraint desc="" exp="" field="Svg_HAPoint"/>
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
    <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
      <labelFont strikethrough="0" style="" underline="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" verticalStretch="0" index="3" horizontalStretch="0" name="RootId">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="6" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Назначение">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="6" horizontalStretch="0" name="MafTypeLevel1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="7" horizontalStretch="0" name="MafTypeLevel2">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="8" horizontalStretch="0" name="MafTypeLevel3">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="12" horizontalStretch="0" name="Material">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="10" horizontalStretch="0" name="Quantity">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="11" horizontalStretch="0" name="Unit">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="6" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Параметры">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="13" horizontalStretch="0" name="InstallationDate">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="14" horizontalStretch="0" name="Lifetime">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="15" horizontalStretch="0" name="GuaranteePeriod">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="16" horizontalStretch="0" name="IdRfid">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="20" horizontalStretch="0" name="NoCalc">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="21" horizontalStretch="0" name="IsDiffHeightMark">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" verticalStretch="0" drawLine="0" horizontalStretch="0" name="SpacerWidget">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
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
    <field editable="1" name="Svg"/>
    <field editable="1" name="Svg_HAPoint"/>
    <field editable="1" name="Svg_VAPoint"/>
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
    <field labelOnTop="0" name="Svg"/>
    <field labelOnTop="0" name="Svg_HAPoint"/>
    <field labelOnTop="0" name="Svg_VAPoint"/>
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
