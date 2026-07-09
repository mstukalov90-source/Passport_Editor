<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" labelsEnabled="0" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" symbologyReferenceScale="-1" simplifyAlgorithm="0" simplifyDrawingHints="0" simplifyMaxScale="1" minScale="100000000" simplifyDrawingTol="1" version="3.38.0-Grenoble">
  <renderer-v2 type="RuleRenderer" forceraster="0" enableorderby="0" symbollevels="0" referencescale="-1">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule symbol="0" label="СФО" key="{2a571072-de42-48d0-b7dd-e0b781efe966}" filter="ArrangeElementType is not null"/>
      <rule symbol="1" label="СФО без типа" key="{f2eea064-adcb-437e-a0ac-91b3e909dc1f}" filter="ELSE"/>
    </rules>
    <symbols>
      <symbol name="0" is_animated="0" frame_rate="10" clip_to_extent="1" force_rhr="0" type="marker" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0" class="SvgMarker" pass="0">
          <Option type="Map">
            <Option value="0" name="angle" type="QString"/>
            <Option value="232,113,141,255,rgb:0.90980392156862744,0.44313725490196076,0.55294117647058827,1" name="color" type="QString"/>
            <Option value="0" name="fixedAspectRatio" type="QString"/>
            <Option value="1" name="horizontal_anchor_point" type="QString"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="0" name="outline_width" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="outline_width_unit" type="QString"/>
            <Option name="parameters"/>
            <Option value="diameter" name="scale_method" type="QString"/>
            <Option value="18" name="size" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="size_unit" type="QString"/>
            <Option value="2" name="vertical_anchor_point" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties" type="Map">
                <Option name="hAnchor" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="attribute( get_feature('Справочник (ДТ/ОО) Типы элементов организации', 'Code', &quot;ArrangeElementType&quot;), 'AnchorPointH')" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
                <Option name="name" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/' +   attribute( get_feature('Справочник (ДТ/ОО) Типы элементов организации', 'Code', &quot;ArrangeElementType&quot;), 'SvgName') + '.svg'" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
                <Option name="vAnchor" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="attribute( get_feature('Справочник (ДТ/ОО) Типы элементов организации', 'Code', &quot;ArrangeElementType&quot;), 'AnchorPointV')" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
              </Option>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer enabled="1" id="{c361bcee-116d-43f4-a948-b01861deb21b}" locked="0" class="SimpleMarker" pass="0">
          <Option type="Map">
            <Option value="0" name="angle" type="QString"/>
            <Option value="square" name="cap_style" type="QString"/>
            <Option value="255,255,255,255,rgb:1,1,1,1" name="color" type="QString"/>
            <Option value="1" name="horizontal_anchor_point" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="circle" name="name" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0" name="outline_width" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="diameter" name="scale_method" type="QString"/>
            <Option value="0.05" name="size" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="size_unit" type="QString"/>
            <Option value="2" name="vertical_anchor_point" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties" type="Map">
                <Option name="hAnchor" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="attribute( get_feature('Справочник (ДТ/ОО) Типы элементов организации', 'Code', &quot;ArrangeElementType&quot;), 'AnchorPointH')" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
                <Option name="vAnchor" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="attribute( get_feature('Справочник (ДТ/ОО) Типы элементов организации', 'Code', &quot;ArrangeElementType&quot;), 'AnchorPointV')" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
              </Option>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol name="1" is_animated="0" frame_rate="10" clip_to_extent="1" force_rhr="0" type="marker" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" locked="0" class="SvgMarker" pass="0">
          <Option type="Map">
            <Option value="0" name="angle" type="QString"/>
            <Option value="232,113,141,255,rgb:0.90980392156862744,0.44313725490196076,0.55294117647058827,1" name="color" type="QString"/>
            <Option value="0" name="fixedAspectRatio" type="QString"/>
            <Option value="1" name="horizontal_anchor_point" type="QString"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/test.svg" name="name" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="0" name="outline_width" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="outline_width_unit" type="QString"/>
            <Option name="parameters"/>
            <Option value="diameter" name="scale_method" type="QString"/>
            <Option value="18" name="size" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="size_unit" type="QString"/>
            <Option value="2" name="vertical_anchor_point" type="QString"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" name="name" type="QString"/>
              <Option name="properties" type="Map">
                <Option name="name" type="Map">
                  <Option value="true" name="active" type="bool"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Неизвестный.svg'" name="expression" type="QString"/>
                  <Option value="3" name="type" type="int"/>
                </Option>
              </Option>
              <Option value="collection" name="type" type="QString"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer enabled="1" id="{5729ae24-3497-4efc-8708-111ceb424109}" locked="0" class="SimpleMarker" pass="0">
          <Option type="Map">
            <Option value="0" name="angle" type="QString"/>
            <Option value="square" name="cap_style" type="QString"/>
            <Option value="255,255,255,255,rgb:1,1,1,1" name="color" type="QString"/>
            <Option value="1" name="horizontal_anchor_point" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="circle" name="name" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0" name="outline_width" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="diameter" name="scale_method" type="QString"/>
            <Option value="0.05" name="size" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="size_map_unit_scale" type="QString"/>
            <Option value="MapUnit" name="size_unit" type="QString"/>
            <Option value="2" name="vertical_anchor_point" type="QString"/>
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
      <symbol name="" is_animated="0" frame_rate="10" clip_to_extent="1" force_rhr="0" type="marker" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" locked="0" class="SimpleMarker" pass="0">
          <Option type="Map">
            <Option value="0" name="angle" type="QString"/>
            <Option value="square" name="cap_style" type="QString"/>
            <Option value="255,0,0,255,rgb:1,0,0,1" name="color" type="QString"/>
            <Option value="1" name="horizontal_anchor_point" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="circle" name="name" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0" name="outline_width" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="outline_width_map_unit_scale" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="diameter" name="scale_method" type="QString"/>
            <Option value="2" name="size" type="QString"/>
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
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
            <Option value="true" name="allow_null" type="bool"/>
            <Option value="true" name="calendar_popup" type="bool"/>
            <Option value="dd.MM.yyyy HH:mm:ss" name="display_format" type="QString"/>
            <Option value="yyyy-MM-dd HH:mm:ss" name="field_format" type="QString"/>
            <Option value="false" name="field_format_overwrite" type="bool"/>
            <Option value="false" name="field_iso_format" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ArrangeElementType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option value=" &quot;OghObjectType&quot; = 35" name="FilterExpression" type="QString"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="______________________________________e66b9953_e3d3_44fe_a6b1_13143d72246d" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО) Типы элементов организации" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ArrangeElementType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Quantity" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="1.7976931348623157e+308" name="Max" type="double"/>
            <Option value="-1.7976931348623157e+308" name="Min" type="double"/>
            <Option value="0" name="Precision" type="int"/>
            <Option value="1" name="Step" type="double"/>
            <Option value="SpinBox" name="Style" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Unit" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="_____________________________dc48829e_8cc0_4936_ad3b_d9d1aed16315" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Единицы измерения" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Units&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="false" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Material" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="_____________________032be6ac_dcea_4e69_9da3_9a8134063c31" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО/ОДХ) Материалы" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ZoneOghObjectType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ZoneOghObjectRootId" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="FileList" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="NoCalc" configurationFlags="NoFlag">
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
    <field name="IsDiffHeightMark" configurationFlags="NoFlag">
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
    <field name="ParentOghObjectType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
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
    <field name="FaceArea" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="CoatingFaceType" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="" field="fid" index="0"/>
    <alias name="" field="OghObjectType" index="1"/>
    <alias name="" field="ObjectId" index="2"/>
    <alias name="Идентификатор ОГХ (RootId)" field="RootId" index="3"/>
    <alias name="" field="StartDate" index="4"/>
    <alias name="" field="EndDate" index="5"/>
    <alias name="Тип элемента" field="ArrangeElementType" index="6"/>
    <alias name="Количество" field="Quantity" index="7"/>
    <alias name="Единицы измерения" field="Unit" index="8"/>
    <alias name="Материал" field="Material" index="9"/>
    <alias name="" field="ZoneOghObjectType" index="10"/>
    <alias name="" field="ZoneOghObjectRootId" index="11"/>
    <alias name="" field="FileList" index="12"/>
    <alias name="Не учитывать" field="NoCalc" index="13"/>
    <alias name="Разновысотные отметки" field="IsDiffHeightMark" index="14"/>
    <alias name="" field="ParentOghObjectType" index="15"/>
    <alias name="" field="ParentObjectId" index="16"/>
    <alias name="" field="ParentRootId" index="17"/>
    <alias name="" field="ParentStartDate" index="18"/>
    <alias name="" field="ParentEndDate" index="19"/>
    <alias name="" field="FaceArea" index="20"/>
    <alias name="" field="CoatingFaceType" index="21"/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="ArrangeElementType" policy="DefaultValue"/>
    <policy field="Quantity" policy="DefaultValue"/>
    <policy field="Unit" policy="DefaultValue"/>
    <policy field="Material" policy="DefaultValue"/>
    <policy field="ZoneOghObjectType" policy="Duplicate"/>
    <policy field="ZoneOghObjectRootId" policy="Duplicate"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="IsDiffHeightMark" policy="DefaultValue"/>
    <policy field="ParentOghObjectType" policy="Duplicate"/>
    <policy field="ParentObjectId" policy="Duplicate"/>
    <policy field="ParentRootId" policy="Duplicate"/>
    <policy field="ParentStartDate" policy="Duplicate"/>
    <policy field="ParentEndDate" policy="Duplicate"/>
    <policy field="FaceArea" policy="Duplicate"/>
    <policy field="CoatingFaceType" policy="Duplicate"/>
  </splitPolicies>
  <duplicatePolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="Duplicate"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="ArrangeElementType" policy="Duplicate"/>
    <policy field="Quantity" policy="Duplicate"/>
    <policy field="Unit" policy="Duplicate"/>
    <policy field="Material" policy="Duplicate"/>
    <policy field="ZoneOghObjectType" policy="Duplicate"/>
    <policy field="ZoneOghObjectRootId" policy="Duplicate"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="Duplicate"/>
    <policy field="IsDiffHeightMark" policy="Duplicate"/>
    <policy field="ParentOghObjectType" policy="Duplicate"/>
    <policy field="ParentObjectId" policy="Duplicate"/>
    <policy field="ParentRootId" policy="Duplicate"/>
    <policy field="ParentStartDate" policy="Duplicate"/>
    <policy field="ParentEndDate" policy="Duplicate"/>
    <policy field="FaceArea" policy="Duplicate"/>
    <policy field="CoatingFaceType" policy="Duplicate"/>
  </duplicatePolicies>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="ArrangeElementType"/>
    <default expression="" applyOnUpdate="0" field="Quantity"/>
    <default expression="" applyOnUpdate="0" field="Unit"/>
    <default expression="" applyOnUpdate="0" field="Material"/>
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
    <default expression="" applyOnUpdate="0" field="FaceArea"/>
    <default expression="" applyOnUpdate="0" field="CoatingFaceType"/>
  </defaults>
  <constraints>
    <constraint constraints="3" field="fid" exp_strength="0" unique_strength="1" notnull_strength="1"/>
    <constraint constraints="0" field="OghObjectType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ObjectId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="RootId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="StartDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="EndDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ArrangeElementType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Quantity" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Unit" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Material" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ZoneOghObjectType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ZoneOghObjectRootId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="FileList" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="NoCalc" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="IsDiffHeightMark" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentOghObjectType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentObjectId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentRootId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentStartDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentEndDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="FaceArea" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="CoatingFaceType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="fid"/>
    <constraint exp="" desc="" field="OghObjectType"/>
    <constraint exp="" desc="" field="ObjectId"/>
    <constraint exp="" desc="" field="RootId"/>
    <constraint exp="" desc="" field="StartDate"/>
    <constraint exp="" desc="" field="EndDate"/>
    <constraint exp="" desc="" field="ArrangeElementType"/>
    <constraint exp="" desc="" field="Quantity"/>
    <constraint exp="" desc="" field="Unit"/>
    <constraint exp="" desc="" field="Material"/>
    <constraint exp="" desc="" field="ZoneOghObjectType"/>
    <constraint exp="" desc="" field="ZoneOghObjectRootId"/>
    <constraint exp="" desc="" field="FileList"/>
    <constraint exp="" desc="" field="NoCalc"/>
    <constraint exp="" desc="" field="IsDiffHeightMark"/>
    <constraint exp="" desc="" field="ParentOghObjectType"/>
    <constraint exp="" desc="" field="ParentObjectId"/>
    <constraint exp="" desc="" field="ParentRootId"/>
    <constraint exp="" desc="" field="ParentStartDate"/>
    <constraint exp="" desc="" field="ParentEndDate"/>
    <constraint exp="" desc="" field="FaceArea"/>
    <constraint exp="" desc="" field="CoatingFaceType"/>
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
      <labelFont bold="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
    </labelStyle>
    <attributeEditorField name="RootId" horizontalStretch="0" showLabel="1" verticalStretch="0" index="3">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
        <labelFont bold="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer visibilityExpressionEnabled="0" name="Назначение" horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" columnCount="4" showLabel="1" verticalStretch="0" type="GroupBox" collapsedExpression="" visibilityExpression="" groupBox="1">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
      </labelStyle>
      <attributeEditorField name="ArrangeElementType" horizontalStretch="0" showLabel="1" verticalStretch="0" index="6">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Quantity" horizontalStretch="0" showLabel="1" verticalStretch="0" index="7">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Unit" horizontalStretch="0" showLabel="1" verticalStretch="0" index="8">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Material" horizontalStretch="0" showLabel="1" verticalStretch="0" index="9">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpressionEnabled="0" name="Параметры" horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" columnCount="2" showLabel="1" verticalStretch="0" type="GroupBox" collapsedExpression="" visibilityExpression="" groupBox="1">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont bold="0" style="" description="Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
      </labelStyle>
      <attributeEditorField name="NoCalc" horizontalStretch="0" showLabel="1" verticalStretch="0" index="13">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsDiffHeightMark" horizontalStretch="0" showLabel="1" verticalStretch="0" index="14">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont bold="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" name="SpacerWidget" horizontalStretch="0" showLabel="0" verticalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont bold="0" style="" description="Sans,10,-1,5,50,0,0,0,0,0" underline="0" strikethrough="0" italic="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="ArrangeElementType" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CoatingFaceType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FaceArea" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="Material" editable="1"/>
    <field name="NoCalc" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="Quantity" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="Unit" editable="1"/>
    <field name="ZoneOghObjectRootId" editable="1"/>
    <field name="ZoneOghObjectType" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="ArrangeElementType" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CoatingFaceType" labelOnTop="0"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FaceArea" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
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
    <field name="ArrangeElementType" reuseLastValue="0"/>
    <field name="ChangeAuthor" reuseLastValue="0"/>
    <field name="ChangeDate" reuseLastValue="0"/>
    <field name="CoatingFaceType" reuseLastValue="0"/>
    <field name="CreateAuthor" reuseLastValue="0"/>
    <field name="CreateDate" reuseLastValue="0"/>
    <field name="EndDate" reuseLastValue="0"/>
    <field name="FaceArea" reuseLastValue="0"/>
    <field name="FileList" reuseLastValue="0"/>
    <field name="IsDiffHeightMark" reuseLastValue="0"/>
    <field name="Material" reuseLastValue="0"/>
    <field name="NoCalc" reuseLastValue="0"/>
    <field name="ObjectId" reuseLastValue="0"/>
    <field name="OghObjectType" reuseLastValue="0"/>
    <field name="ParentEndDate" reuseLastValue="0"/>
    <field name="ParentObjectId" reuseLastValue="0"/>
    <field name="ParentOghObjectType" reuseLastValue="0"/>
    <field name="ParentRootId" reuseLastValue="0"/>
    <field name="ParentStartDate" reuseLastValue="0"/>
    <field name="Quantity" reuseLastValue="0"/>
    <field name="RootId" reuseLastValue="0"/>
    <field name="StartDate" reuseLastValue="0"/>
    <field name="TaskGUID" reuseLastValue="0"/>
    <field name="Unit" reuseLastValue="0"/>
    <field name="ZoneOghObjectRootId" reuseLastValue="0"/>
    <field name="ZoneOghObjectType" reuseLastValue="0"/>
    <field name="fid" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
