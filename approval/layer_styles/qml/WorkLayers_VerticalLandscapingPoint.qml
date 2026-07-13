<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" maxScale="0" autoRefreshTime="0" simplifyDrawingHints="0" minScale="100000000" autoRefreshMode="Disabled" simplifyAlgorithm="0" simplifyDrawingTol="1" symbologyReferenceScale="-1" simplifyLocal="1" version="3.44.1-Solothurn" hasScaleBasedVisibilityFlag="0" simplifyMaxScale="1" labelsEnabled="0">
  <renderer-v2 referencescale="-1" symbollevels="0" forceraster="0" type="RuleRenderer" enableorderby="0">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule key="{c9a7822b-6b7b-4b00-bfb3-c578217326b1}" filter="&quot;fid&quot; is not NULL" symbol="0" checkstate="0" label="Точки привязки"/>
      <rule key="{c7bf4fbc-ab54-4f81-bc50-9f3ca60d68a1}" filter=" &quot;VerticalLandscapingRefType&quot; is not NULL" symbol="1" label="Вертикальное озеленение"/>
      <rule key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}" filter="ELSE" symbol="2" label="Вертикальное озеленение без типа"/>
    </rules>
    <symbols>
      <symbol is_animated="0" alpha="1" force_rhr="0" type="marker" frame_rate="10" clip_to_extent="1" name="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" class="SimpleMarker" enabled="1" pass="1" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="square" type="QString" name="cap_style"/>
            <Option value="255,255,255,255,hsv:0,0,1,1" type="QString" name="color"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="circle" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="255,0,0,255,rgb:1,0,0,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0.03" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="outline_width_unit"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="0.12" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="1" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_HAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_VAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" force_rhr="0" type="marker" frame_rate="10" clip_to_extent="1" name="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" class="SvgMarker" enabled="1" pass="0" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="10" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="2" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_HAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + &quot;Svg&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_VAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" class="SimpleMarker" enabled="1" pass="0" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="square" type="QString" name="cap_style"/>
            <Option value="255,255,255,255,hsv:0,0,1,1" type="QString" name="color"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="circle" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MM" type="QString" name="outline_width_unit"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="0.05" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="1" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_HAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_VAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol is_animated="0" alpha="1" force_rhr="0" type="marker" frame_rate="10" clip_to_extent="1" name="2">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" class="SvgMarker" enabled="1" pass="0" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="18" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="2" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_HAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_VAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer id="{ddd6d751-2721-4924-b801-ffea9c7601c8}" class="SimpleMarker" enabled="1" pass="0" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="square" type="QString" name="cap_style"/>
            <Option value="255,255,255,255,hsv:0,0,1,1" type="QString" name="color"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="circle" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MM" type="QString" name="outline_width_unit"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="0.05" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="2" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_HAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="&quot;Svg_VAPoint&quot;" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
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
      <symbol is_animated="0" alpha="1" force_rhr="0" type="marker" frame_rate="10" clip_to_extent="1" name="">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" class="SimpleMarker" enabled="1" pass="0" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="square" type="QString" name="cap_style"/>
            <Option value="255,0,0,255,rgb:1,0,0,1" type="QString" name="color"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="circle" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MM" type="QString" name="outline_width_unit"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="2" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MM" type="QString" name="size_unit"/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="VerticalLandscapingType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option value="" type="QString" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option value="CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" type="QString" name="FilterExpression"/>
            <Option value="" type="QString" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________________________________________________9c119ae9_8d2a_4b8c_abc3_107b00a52120" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) кодов вида элементов вертикального озеленения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='mggt_editor' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;VerticalLandscapingType&quot;" type="QString" name="LayerSource"/>
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
    <field configurationFlags="NoFlag" name="VerticalLandscapingRefType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option value="IF(array_contains(from_json(&quot;VerticalLandscapingTypeCode&quot;), current_value('VerticalLandscapingType')), TRUE, FALSE)" type="QString" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________________________________________f1e1c8e2_f356_4a3c_815c_1843bfa4dace" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;VerticalLandscapingRefType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="false" type="bool" name="OrderByDescending"/>
            <Option value="false" type="bool" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option value="false" type="bool" name="OrderByKey"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="VerticalLandscapingClassType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="________________________________________________________________4ddffb55_a6a1_4ffc_99d6_528aa32a2b63" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) кодов детализации элементов вертикального озеленения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;VerticalLandscapingClassType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlacesQuantity">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1.7976931348623157e+308" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlacesArea">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="0.5" type="double" name="Step"/>
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
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_____________________________9c589de3_af9c_4474_b3f6_8380450c9226" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Единицы измерения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Units&quot;" type="QString" name="LayerSource"/>
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
            <Option value="false" type="bool" name="OrderByValue"/>
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
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="0.1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ZoneOghId">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IdRfid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="InstallationDate">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="allow_null"/>
            <Option value="true" type="bool" name="calendar_popup"/>
            <Option value="dd.MM.yyyy" type="QString" name="display_format"/>
            <Option value="yyyy-MM-dd HH:mm:ss" type="QString" name="field_format"/>
            <Option value="false" type="bool" name="field_format_overwrite"/>
            <Option value="false" type="bool" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Lifetime">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="allow_null"/>
            <Option value="true" type="bool" name="calendar_popup"/>
            <Option value="dd.MM.yyyy" type="QString" name="display_format"/>
            <Option value="yyyy-MM-dd HH:mm:ss" type="QString" name="field_format"/>
            <Option value="false" type="bool" name="field_format_overwrite"/>
            <Option value="false" type="bool" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="GuaranteePeriod">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="allow_null"/>
            <Option value="true" type="bool" name="calendar_popup"/>
            <Option value="dd.MM.yyyy" type="QString" name="display_format"/>
            <Option value="yyyy-MM-dd HH:mm:ss" type="QString" name="field_format"/>
            <Option value="false" type="bool" name="field_format_overwrite"/>
            <Option value="false" type="bool" name="field_iso_format"/>
          </Option>
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
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg_VAPoint">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Svg_HAPoint">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" index="0" name=""/>
    <alias field="OghObjectType" index="1" name=""/>
    <alias field="ObjectId" index="2" name=""/>
    <alias field="RootId" index="3" name="Идентификатор ОГХ (RootId)"/>
    <alias field="StartDate" index="4" name=""/>
    <alias field="EndDate" index="5" name=""/>
    <alias field="VerticalLandscapingType" index="6" name="Код вида"/>
    <alias field="VerticalLandscapingRefType" index="7" name="Код типа"/>
    <alias field="VerticalLandscapingClassType" index="8" name="Код детализации"/>
    <alias field="PlacesQuantity" index="9" name="Кол-во посадочных мест"/>
    <alias field="PlacesArea" index="10" name="Площадь посадочных мест"/>
    <alias field="Unit" index="11" name="Единицы измерения"/>
    <alias field="Material" index="12" name="Материал"/>
    <alias field="Quantity" index="13" name="Количество"/>
    <alias field="ZoneOghId" index="14" name="Принадлежность к зоне"/>
    <alias field="IdRfid" index="15" name="RFID"/>
    <alias field="InstallationDate" index="16" name="Дата установки"/>
    <alias field="Lifetime" index="17" name="Срок эксплуатации"/>
    <alias field="GuaranteePeriod" index="18" name="Гарантийный срок"/>
    <alias field="FileList" index="19" name=""/>
    <alias field="NoCalc" index="20" name="Не учитывать"/>
    <alias field="IsDiffHeightMark" index="21" name="Разновысотные отметки"/>
    <alias field="ParentOghObjectType" index="22" name=""/>
    <alias field="ParentObjectId" index="23" name=""/>
    <alias field="ParentRootId" index="24" name=""/>
    <alias field="ParentStartDate" index="25" name=""/>
    <alias field="ParentEndDate" index="26" name=""/>
    <alias field="CreateDate" index="27" name=""/>
    <alias field="CreateAuthor" index="28" name=""/>
    <alias field="ChangeDate" index="29" name=""/>
    <alias field="ChangeAuthor" index="30" name=""/>
    <alias field="TaskGUID" index="31" name=""/>
    <alias field="Svg" index="32" name=""/>
    <alias field="Svg_VAPoint" index="33" name=""/>
    <alias field="Svg_HAPoint" index="34" name=""/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="DefaultValue"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="VerticalLandscapingType" policy="DefaultValue"/>
    <policy field="VerticalLandscapingRefType" policy="DefaultValue"/>
    <policy field="VerticalLandscapingClassType" policy="DefaultValue"/>
    <policy field="PlacesQuantity" policy="DefaultValue"/>
    <policy field="PlacesArea" policy="DefaultValue"/>
    <policy field="Unit" policy="DefaultValue"/>
    <policy field="Material" policy="DefaultValue"/>
    <policy field="Quantity" policy="DefaultValue"/>
    <policy field="ZoneOghId" policy="DefaultValue"/>
    <policy field="IdRfid" policy="DefaultValue"/>
    <policy field="InstallationDate" policy="DefaultValue"/>
    <policy field="Lifetime" policy="DefaultValue"/>
    <policy field="GuaranteePeriod" policy="DefaultValue"/>
    <policy field="FileList" policy="DefaultValue"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="IsDiffHeightMark" policy="DefaultValue"/>
    <policy field="TaskGUID" policy="DefaultValue"/>
    <policy field="Svg" policy="DefaultValue"/>
    <policy field="Svg_VAPoint" policy="DefaultValue"/>
    <policy field="Svg_HAPoint" policy="DefaultValue"/>
  </splitPolicies>
  <defaults>
    <default field="fid" applyOnUpdate="0" expression=""/>
    <default field="OghObjectType" applyOnUpdate="0" expression=""/>
    <default field="ObjectId" applyOnUpdate="0" expression=""/>
    <default field="RootId" applyOnUpdate="0" expression=""/>
    <default field="StartDate" applyOnUpdate="0" expression=""/>
    <default field="EndDate" applyOnUpdate="0" expression=""/>
    <default field="VerticalLandscapingType" applyOnUpdate="0" expression=""/>
    <default field="VerticalLandscapingRefType" applyOnUpdate="0" expression=""/>
    <default field="VerticalLandscapingClassType" applyOnUpdate="0" expression=""/>
    <default field="PlacesQuantity" applyOnUpdate="0" expression=""/>
    <default field="PlacesArea" applyOnUpdate="0" expression=""/>
    <default field="Unit" applyOnUpdate="0" expression=""/>
    <default field="Material" applyOnUpdate="0" expression=""/>
    <default field="Quantity" applyOnUpdate="0" expression=""/>
    <default field="ZoneOghId" applyOnUpdate="0" expression=""/>
    <default field="IdRfid" applyOnUpdate="0" expression=""/>
    <default field="InstallationDate" applyOnUpdate="0" expression=""/>
    <default field="Lifetime" applyOnUpdate="0" expression=""/>
    <default field="GuaranteePeriod" applyOnUpdate="0" expression=""/>
    <default field="FileList" applyOnUpdate="0" expression=""/>
    <default field="NoCalc" applyOnUpdate="0" expression=""/>
    <default field="IsDiffHeightMark" applyOnUpdate="0" expression=""/>
    <default field="ParentOghObjectType" applyOnUpdate="0" expression=""/>
    <default field="ParentObjectId" applyOnUpdate="0" expression=""/>
    <default field="ParentRootId" applyOnUpdate="0" expression=""/>
    <default field="ParentStartDate" applyOnUpdate="0" expression=""/>
    <default field="ParentEndDate" applyOnUpdate="0" expression=""/>
    <default field="CreateDate" applyOnUpdate="0" expression=""/>
    <default field="CreateAuthor" applyOnUpdate="0" expression=""/>
    <default field="ChangeDate" applyOnUpdate="0" expression=""/>
    <default field="ChangeAuthor" applyOnUpdate="0" expression=""/>
    <default field="TaskGUID" applyOnUpdate="0" expression=""/>
    <default field="Svg" applyOnUpdate="1" expression="@MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения', 'Code', &quot;VerticalLandscapingRefType&quot;), 'SvgName') + '.svg'"/>
    <default field="Svg_VAPoint" applyOnUpdate="1" expression="attribute( get_feature('Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения', 'Code', &quot;VerticalLandscapingRefType&quot;), 'AnchorPointV')"/>
    <default field="Svg_HAPoint" applyOnUpdate="1" expression="attribute( get_feature('Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения', 'Code', &quot;VerticalLandscapingRefType&quot;), 'AnchorPointH')"/>
  </defaults>
  <constraints>
    <constraint field="fid" notnull_strength="1" unique_strength="1" constraints="3" exp_strength="0"/>
    <constraint field="OghObjectType" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ObjectId" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="RootId" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="StartDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="EndDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="VerticalLandscapingType" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="VerticalLandscapingRefType" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="VerticalLandscapingClassType" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="PlacesQuantity" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="PlacesArea" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Unit" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Material" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Quantity" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ZoneOghId" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="IdRfid" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="InstallationDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Lifetime" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="GuaranteePeriod" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="FileList" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="NoCalc" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="IsDiffHeightMark" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ParentOghObjectType" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ParentObjectId" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ParentRootId" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ParentStartDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ParentEndDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="CreateDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="CreateAuthor" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ChangeDate" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="ChangeAuthor" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="TaskGUID" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Svg" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Svg_VAPoint" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
    <constraint field="Svg_HAPoint" notnull_strength="0" unique_strength="0" constraints="0" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" exp="" desc=""/>
    <constraint field="OghObjectType" exp="" desc=""/>
    <constraint field="ObjectId" exp="" desc=""/>
    <constraint field="RootId" exp="" desc=""/>
    <constraint field="StartDate" exp="" desc=""/>
    <constraint field="EndDate" exp="" desc=""/>
    <constraint field="VerticalLandscapingType" exp="" desc=""/>
    <constraint field="VerticalLandscapingRefType" exp="" desc=""/>
    <constraint field="VerticalLandscapingClassType" exp="" desc=""/>
    <constraint field="PlacesQuantity" exp="" desc=""/>
    <constraint field="PlacesArea" exp="" desc=""/>
    <constraint field="Unit" exp="" desc=""/>
    <constraint field="Material" exp="" desc=""/>
    <constraint field="Quantity" exp="" desc=""/>
    <constraint field="ZoneOghId" exp="" desc=""/>
    <constraint field="IdRfid" exp="" desc=""/>
    <constraint field="InstallationDate" exp="" desc=""/>
    <constraint field="Lifetime" exp="" desc=""/>
    <constraint field="GuaranteePeriod" exp="" desc=""/>
    <constraint field="FileList" exp="" desc=""/>
    <constraint field="NoCalc" exp="" desc=""/>
    <constraint field="IsDiffHeightMark" exp="" desc=""/>
    <constraint field="ParentOghObjectType" exp="" desc=""/>
    <constraint field="ParentObjectId" exp="" desc=""/>
    <constraint field="ParentRootId" exp="" desc=""/>
    <constraint field="ParentStartDate" exp="" desc=""/>
    <constraint field="ParentEndDate" exp="" desc=""/>
    <constraint field="CreateDate" exp="" desc=""/>
    <constraint field="CreateAuthor" exp="" desc=""/>
    <constraint field="ChangeDate" exp="" desc=""/>
    <constraint field="ChangeAuthor" exp="" desc=""/>
    <constraint field="TaskGUID" exp="" desc=""/>
    <constraint field="Svg" exp="" desc=""/>
    <constraint field="Svg_VAPoint" exp="" desc=""/>
    <constraint field="Svg_HAPoint" exp="" desc=""/>
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
      <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
    </labelStyle>
    <attributeEditorField verticalStretch="0" showLabel="1" index="3" name="RootId" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
        <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer verticalStretch="0" columnCount="4" groupBox="1" visibilityExpressionEnabled="0" showLabel="1" collapsedExpressionEnabled="0" type="GroupBox" collapsed="0" name="Назначение" horizontalStretch="0" collapsedExpression="" visibilityExpression="">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
      </labelStyle>
      <attributeEditorField verticalStretch="0" showLabel="1" index="6" name="VerticalLandscapingType" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="7" name="VerticalLandscapingRefType" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="8" name="VerticalLandscapingClassType" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="9" name="PlacesQuantity" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="10" name="PlacesArea" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="12" name="Material" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="13" name="Quantity" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="11" name="Unit" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer verticalStretch="0" columnCount="4" groupBox="1" visibilityExpressionEnabled="0" showLabel="1" collapsedExpressionEnabled="0" type="GroupBox" collapsed="0" name="Параметры" horizontalStretch="0" collapsedExpression="" visibilityExpression="">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
      </labelStyle>
      <attributeEditorField verticalStretch="0" showLabel="1" index="16" name="InstallationDate" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="17" name="Lifetime" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="18" name="GuaranteePeriod" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="14" name="ZoneOghId" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="15" name="IdRfid" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="20" name="NoCalc" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField verticalStretch="0" showLabel="1" index="21" name="IsDiffHeightMark" horizontalStretch="0">
        <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont style="" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement verticalStretch="0" showLabel="0" drawLine="0" name="SpacerWidget" horizontalStretch="0">
      <labelStyle overrideLabelFont="0" overrideLabelColor="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont style="" italic="0" description="Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0" strikethrough="0"/>
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
    <field editable="1" name="PlacesArea"/>
    <field editable="1" name="PlacesQuantity"/>
    <field editable="1" name="Quantity"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="StartDate"/>
    <field editable="1" name="Svg"/>
    <field editable="1" name="Svg_HAPoint"/>
    <field editable="1" name="Svg_VAPoint"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="Unit"/>
    <field editable="1" name="VerticalLandscapingClassType"/>
    <field editable="1" name="VerticalLandscapingRefType"/>
    <field editable="1" name="VerticalLandscapingType"/>
    <field editable="1" name="ZoneOghId"/>
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
    <field labelOnTop="1" name="PlacesArea"/>
    <field labelOnTop="1" name="PlacesQuantity"/>
    <field labelOnTop="1" name="Quantity"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="Svg"/>
    <field labelOnTop="0" name="Svg_HAPoint"/>
    <field labelOnTop="0" name="Svg_VAPoint"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="Unit"/>
    <field labelOnTop="1" name="VerticalLandscapingClassType"/>
    <field labelOnTop="1" name="VerticalLandscapingRefType"/>
    <field labelOnTop="1" name="VerticalLandscapingType"/>
    <field labelOnTop="1" name="ZoneOghId"/>
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
    <field reuseLastValue="0" name="PlacesArea"/>
    <field reuseLastValue="0" name="PlacesQuantity"/>
    <field reuseLastValue="0" name="Quantity"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="Svg"/>
    <field reuseLastValue="0" name="Svg_HAPoint"/>
    <field reuseLastValue="0" name="Svg_VAPoint"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="Unit"/>
    <field reuseLastValue="0" name="VerticalLandscapingClassType"/>
    <field reuseLastValue="0" name="VerticalLandscapingRefType"/>
    <field reuseLastValue="0" name="VerticalLandscapingType"/>
    <field reuseLastValue="0" name="ZoneOghId"/>
    <field reuseLastValue="0" name="ZoneOghObjectRootId"/>
    <field reuseLastValue="0" name="ZoneOghObjectType"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
