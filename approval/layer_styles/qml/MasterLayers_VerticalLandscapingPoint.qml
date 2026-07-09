<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis simplifyAlgorithm="0" simplifyDrawingHints="0" simplifyMaxScale="1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" symbologyReferenceScale="-1" minScale="100000000" simplifyLocal="1" version="3.38.0-Grenoble" simplifyDrawingTol="1" maxScale="0" labelsEnabled="0" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 referencescale="-1" forceraster="0" enableorderby="0" symbollevels="0" type="RuleRenderer">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule filter=" &quot;VerticalLandscapingRefType&quot; is not NULL" key="{c7bf4fbc-ab54-4f81-bc50-9f3ca60d68a1}" label="Вертикальное озеленение" symbol="0"/>
      <rule filter="ELSE" key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}" label="Вертикальное озеленение без типа" symbol="1"/>
    </rules>
    <symbols>
      <symbol alpha="0.3" force_rhr="0" frame_rate="10" type="marker" name="0" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" enabled="1" pass="0" class="SvgMarker" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="232,113,141,255,rgb:0.90980392156862744,0.44313725490196076,0.55294117647058827,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString" name="outline_color"/>
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
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения', 'Code', &quot;VerticalLandscapingRefType&quot;), 'SvgName') + '.svg'" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" enabled="1" pass="0" class="SimpleMarker" locked="0">
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
              <Option name="properties"/>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="0.3" force_rhr="0" frame_rate="10" type="marker" name="1" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{23c2d428-6912-469e-ba43-da7e391c8a35}" enabled="1" pass="0" class="SvgMarker" locked="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="232,113,141,255,rgb:0.90980392156862744,0.44313725490196076,0.55294117647058827,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString" name="outline_color"/>
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
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer id="{ddd6d751-2721-4924-b801-ffea9c7601c8}" enabled="1" pass="0" class="SimpleMarker" locked="0">
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
              <Option name="properties"/>
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
      <symbol alpha="1" force_rhr="0" frame_rate="10" type="marker" name="" clip_to_extent="1" is_animated="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" enabled="1" pass="0" class="SimpleMarker" locked="0">
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
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString" name="outline_color"/>
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
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
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
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________________________________________67874b53_92c9_4fcd_af2e_d0959da81b96" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) кодов вида элементов вертикального озеленения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;VerticalLandscapingType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
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
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________________________________________9363d45c_7f96_4aeb_a592_239c755225b9" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) кодов типа элементов вертикального озеленения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;VerticalLandscapingRefType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
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
            <Option value="1.7976931348623157e+308" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="0.1" type="double" name="Step"/>
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
            <Option value="1.7976931348623157e+308" type="double" name="Max"/>
            <Option value="-1.7976931348623157e+308" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
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
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="DefaultValue"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
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
    <policy field="VerticalLandscapingType" policy="Duplicate"/>
    <policy field="VerticalLandscapingRefType" policy="Duplicate"/>
    <policy field="VerticalLandscapingClassType" policy="Duplicate"/>
    <policy field="PlacesQuantity" policy="Duplicate"/>
    <policy field="PlacesArea" policy="Duplicate"/>
    <policy field="Unit" policy="Duplicate"/>
    <policy field="Material" policy="Duplicate"/>
    <policy field="Quantity" policy="Duplicate"/>
    <policy field="ZoneOghId" policy="Duplicate"/>
    <policy field="IdRfid" policy="Duplicate"/>
    <policy field="InstallationDate" policy="Duplicate"/>
    <policy field="Lifetime" policy="Duplicate"/>
    <policy field="GuaranteePeriod" policy="Duplicate"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="Duplicate"/>
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
    <default expression="" field="VerticalLandscapingType" applyOnUpdate="0"/>
    <default expression="" field="VerticalLandscapingRefType" applyOnUpdate="0"/>
    <default expression="" field="VerticalLandscapingClassType" applyOnUpdate="0"/>
    <default expression="" field="PlacesQuantity" applyOnUpdate="0"/>
    <default expression="" field="PlacesArea" applyOnUpdate="0"/>
    <default expression="" field="Unit" applyOnUpdate="0"/>
    <default expression="" field="Material" applyOnUpdate="0"/>
    <default expression="" field="Quantity" applyOnUpdate="0"/>
    <default expression="" field="ZoneOghId" applyOnUpdate="0"/>
    <default expression="" field="IdRfid" applyOnUpdate="0"/>
    <default expression="" field="InstallationDate" applyOnUpdate="0"/>
    <default expression="" field="Lifetime" applyOnUpdate="0"/>
    <default expression="" field="GuaranteePeriod" applyOnUpdate="0"/>
    <default expression="" field="FileList" applyOnUpdate="0"/>
    <default expression="" field="NoCalc" applyOnUpdate="0"/>
    <default expression="" field="IsDiffHeightMark" applyOnUpdate="0"/>
    <default expression="" field="ParentOghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ParentObjectId" applyOnUpdate="0"/>
    <default expression="" field="ParentRootId" applyOnUpdate="0"/>
    <default expression="" field="ParentStartDate" applyOnUpdate="0"/>
    <default expression="" field="ParentEndDate" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="fid" exp_strength="0" constraints="3" unique_strength="1"/>
    <constraint notnull_strength="0" field="OghObjectType" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ObjectId" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="RootId" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="StartDate" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="EndDate" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="VerticalLandscapingType" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="VerticalLandscapingRefType" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="VerticalLandscapingClassType" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="PlacesQuantity" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="PlacesArea" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="Unit" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="Material" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="Quantity" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ZoneOghId" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="IdRfid" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="InstallationDate" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="Lifetime" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="GuaranteePeriod" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="FileList" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="NoCalc" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="IsDiffHeightMark" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ParentOghObjectType" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ParentObjectId" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ParentRootId" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ParentStartDate" exp_strength="0" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" field="ParentEndDate" exp_strength="0" constraints="0" unique_strength="0"/>
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
    <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
      <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" horizontalStretch="0" index="3" verticalStretch="0" name="RootId">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer showLabel="1" collapsedExpressionEnabled="0" groupBox="1" collapsedExpression="" horizontalStretch="0" verticalStretch="0" columnCount="4" visibilityExpressionEnabled="0" collapsed="0" name="Назначение" type="GroupBox" visibilityExpression="">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="6" verticalStretch="0" name="VerticalLandscapingType">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="7" verticalStretch="0" name="VerticalLandscapingRefType">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="8" verticalStretch="0" name="VerticalLandscapingClassType">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="9" verticalStretch="0" name="PlacesQuantity">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="10" verticalStretch="0" name="PlacesArea">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="12" verticalStretch="0" name="Material">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="13" verticalStretch="0" name="Quantity">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="11" verticalStretch="0" name="Unit">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" collapsedExpressionEnabled="0" groupBox="1" collapsedExpression="" horizontalStretch="0" verticalStretch="0" columnCount="4" visibilityExpressionEnabled="0" collapsed="0" name="Параметры" type="GroupBox" visibilityExpression="">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="16" verticalStretch="0" name="InstallationDate">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="17" verticalStretch="0" name="Lifetime">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="18" verticalStretch="0" name="GuaranteePeriod">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="14" verticalStretch="0" name="ZoneOghId">
        <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="15" verticalStretch="0" name="IdRfid">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="20" verticalStretch="0" name="NoCalc">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" horizontalStretch="0" index="21" verticalStretch="0" name="IsDiffHeightMark">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont underline="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" drawLine="0" horizontalStretch="0" verticalStretch="0" name="SpacerWidget">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont underline="0" style="" description="Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0" strikethrough="0"/>
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
    <field name="PlacesArea" labelOnTop="1"/>
    <field name="PlacesQuantity" labelOnTop="1"/>
    <field name="Quantity" labelOnTop="1"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="Unit" labelOnTop="1"/>
    <field name="VerticalLandscapingClassType" labelOnTop="1"/>
    <field name="VerticalLandscapingRefType" labelOnTop="1"/>
    <field name="VerticalLandscapingType" labelOnTop="1"/>
    <field name="ZoneOghId" labelOnTop="1"/>
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
    <field reuseLastValue="0" name="PlacesArea"/>
    <field reuseLastValue="0" name="PlacesQuantity"/>
    <field reuseLastValue="0" name="Quantity"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
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
