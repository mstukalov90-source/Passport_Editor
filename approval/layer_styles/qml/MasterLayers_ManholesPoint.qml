<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis minScale="100000000" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" symbologyReferenceScale="-1" simplifyAlgorithm="0" simplifyLocal="1" maxScale="0" version="3.38.0-Grenoble" simplifyDrawingHints="0" hasScaleBasedVisibilityFlag="0" simplifyMaxScale="1" labelsEnabled="0" simplifyDrawingTol="1">
  <renderer-v2 forceraster="0" type="RuleRenderer" symbollevels="0" referencescale="-1" enableorderby="0">
    <rules key="{56153738-f2b2-4b68-a8bd-b1db52681d41}">
      <rule label="Люк подземных коммуникаций" key="{67dab356-460a-4bcc-b6a3-8c8acbaf0dbd}" symbol="0"/>
    </rules>
    <symbols>
      <symbol clip_to_extent="1" is_animated="0" force_rhr="0" frame_rate="10" type="marker" name="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{23c2d428-6912-469e-ba43-da7e391c8a35}" enabled="1" pass="0" class="SvgMarker">
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
                <Option type="Map" name="hAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="IF(&quot;Accessory&quot; IS NOT NULL, attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'AnchorPointH'), 'HCenter')" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="IF(attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'SvgName') IS NOT NULL, @MggtAsuPluginPath + @MggtAsuSvgPath + '/' + attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'SvgName'), @MggtAsuPluginPath + @MggtAsuSvgPath + '/Люк подземных коммуникаций (смотровой колодец).svg')" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="IF(&quot;Accessory&quot; IS NOT NULL, attribute( get_feature('Справочник (ОДХ) Код принадлежности', 'Code', &quot;Accessory&quot;), 'AnchorPointV'), 'Bottom')" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
        <layer locked="0" id="{7f4d0d34-e4d0-4488-aa71-76e020b63915}" enabled="1" pass="0" class="SimpleMarker">
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
                  <Option value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointH')&#xd;&#xa;&#x9;ELSE 'HCenter'&#xd;&#xa;END" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
                <Option type="Map" name="vAnchor">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="CASE&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel3&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 3', 'Code', &quot;MafTypeLevel3&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel2&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 2', 'Code', &quot;MafTypeLevel2&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;WHEN &quot;MafTypeLevel1&quot; IS NOT NULL THEN attribute( get_feature('Справочник (ДТ/ОО) Типы МАФ уровень 1', 'Code', &quot;MafTypeLevel1&quot;), 'AnchorPointV')&#xd;&#xa;&#x9;ELSE 'Bottom'&#xd;&#xa;END" type="QString" name="expression"/>
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
      <symbol clip_to_extent="1" is_animated="0" force_rhr="0" frame_rate="10" type="marker" name="" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" id="{2b3c0989-e668-4d16-aa6e-1e7860216c56}" enabled="1" pass="0" class="SimpleMarker">
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
          <Option type="Map">
            <Option value="true" type="bool" name="allow_null"/>
            <Option value="true" type="bool" name="calendar_popup"/>
            <Option value="dd.MM.yyyy HH:mm:ss" type="QString" name="display_format"/>
            <Option value="yyyy-MM-dd HH:mm:ss" type="QString" name="field_format"/>
            <Option value="false" type="bool" name="field_format_overwrite"/>
            <Option value="false" type="bool" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="EngineStructType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option value=" &quot;OghObjectType&quot; = '8'" type="QString" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="______________________________________51089742_7cdc_4f96_9aca_62d100964796" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Тип инженерного сооружения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;EngineStructType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhSide">
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
            <Option value="______________________________________5f058f67_eee3_4e6f_9756_6f9a64c4fefc" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Код стороны проезжей части" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;OdhSide&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="OdhAxis">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Endwise">
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
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="______________________________d77b7834_e3b8_466a_92ea_3848db695acc" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Код принадлежности" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Accessory&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
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
    <alias index="0" name="" field="fid"/>
    <alias index="1" name="" field="OghObjectType"/>
    <alias index="2" name="" field="ObjectId"/>
    <alias index="3" name="Идентификатор ОГХ" field="RootId"/>
    <alias index="4" name="" field="StartDate"/>
    <alias index="5" name="" field="EndDate"/>
    <alias index="6" name="Тип люка и решетки" field="EngineStructType"/>
    <alias index="7" name="Сторона" field="OdhSide"/>
    <alias index="8" name="Ось" field="OdhAxis"/>
    <alias index="9" name="По оси" field="Endwise"/>
    <alias index="10" name="" field="Placement"/>
    <alias index="11" name="Принадлежность" field="Accessory"/>
    <alias index="12" name="Примечание" field="Description"/>
    <alias index="13" name="" field="ParentOghObjectType"/>
    <alias index="14" name="" field="ParentObjectId"/>
    <alias index="15" name="" field="ParentRootId"/>
    <alias index="16" name="" field="ParentStartDate"/>
    <alias index="17" name="" field="ParentEndDate"/>
  </aliases>
  <splitPolicies>
    <policy policy="Duplicate" field="fid"/>
    <policy policy="Duplicate" field="OghObjectType"/>
    <policy policy="Duplicate" field="ObjectId"/>
    <policy policy="DefaultValue" field="RootId"/>
    <policy policy="Duplicate" field="StartDate"/>
    <policy policy="Duplicate" field="EndDate"/>
    <policy policy="DefaultValue" field="EngineStructType"/>
    <policy policy="DefaultValue" field="OdhSide"/>
    <policy policy="DefaultValue" field="OdhAxis"/>
    <policy policy="DefaultValue" field="Endwise"/>
    <policy policy="Duplicate" field="Placement"/>
    <policy policy="DefaultValue" field="Accessory"/>
    <policy policy="DefaultValue" field="Description"/>
    <policy policy="Duplicate" field="ParentOghObjectType"/>
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
    <policy policy="Duplicate" field="EngineStructType"/>
    <policy policy="Duplicate" field="OdhSide"/>
    <policy policy="Duplicate" field="OdhAxis"/>
    <policy policy="Duplicate" field="Endwise"/>
    <policy policy="Duplicate" field="Placement"/>
    <policy policy="Duplicate" field="Accessory"/>
    <policy policy="Duplicate" field="Description"/>
    <policy policy="Duplicate" field="ParentOghObjectType"/>
    <policy policy="Duplicate" field="ParentObjectId"/>
    <policy policy="Duplicate" field="ParentRootId"/>
    <policy policy="Duplicate" field="ParentStartDate"/>
    <policy policy="Duplicate" field="ParentEndDate"/>
  </duplicatePolicies>
  <defaults>
    <default applyOnUpdate="0" field="fid" expression=""/>
    <default applyOnUpdate="0" field="OghObjectType" expression=""/>
    <default applyOnUpdate="0" field="ObjectId" expression=""/>
    <default applyOnUpdate="0" field="RootId" expression=""/>
    <default applyOnUpdate="0" field="StartDate" expression=""/>
    <default applyOnUpdate="0" field="EndDate" expression=""/>
    <default applyOnUpdate="0" field="EngineStructType" expression=""/>
    <default applyOnUpdate="0" field="OdhSide" expression=""/>
    <default applyOnUpdate="0" field="OdhAxis" expression=""/>
    <default applyOnUpdate="0" field="Endwise" expression=""/>
    <default applyOnUpdate="0" field="Placement" expression=""/>
    <default applyOnUpdate="0" field="Accessory" expression=""/>
    <default applyOnUpdate="0" field="Description" expression=""/>
    <default applyOnUpdate="0" field="ParentOghObjectType" expression=""/>
    <default applyOnUpdate="0" field="ParentObjectId" expression=""/>
    <default applyOnUpdate="0" field="ParentRootId" expression=""/>
    <default applyOnUpdate="0" field="ParentStartDate" expression=""/>
    <default applyOnUpdate="0" field="ParentEndDate" expression=""/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" constraints="3" unique_strength="1" field="fid" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="OghObjectType" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ObjectId" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="RootId" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="StartDate" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="EndDate" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="EngineStructType" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="OdhSide" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="OdhAxis" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="Endwise" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="Placement" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="Accessory" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="Description" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ParentOghObjectType" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ParentObjectId" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ParentRootId" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ParentStartDate" exp_strength="0"/>
    <constraint notnull_strength="0" constraints="0" unique_strength="0" field="ParentEndDate" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" exp="" desc=""/>
    <constraint field="OghObjectType" exp="" desc=""/>
    <constraint field="ObjectId" exp="" desc=""/>
    <constraint field="RootId" exp="" desc=""/>
    <constraint field="StartDate" exp="" desc=""/>
    <constraint field="EndDate" exp="" desc=""/>
    <constraint field="EngineStructType" exp="" desc=""/>
    <constraint field="OdhSide" exp="" desc=""/>
    <constraint field="OdhAxis" exp="" desc=""/>
    <constraint field="Endwise" exp="" desc=""/>
    <constraint field="Placement" exp="" desc=""/>
    <constraint field="Accessory" exp="" desc=""/>
    <constraint field="Description" exp="" desc=""/>
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
    <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
      <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" index="3" name="RootId" horizontalStretch="0" verticalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer showLabel="1" collapsedExpressionEnabled="0" collapsed="0" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" name="Назначение" horizontalStretch="0" type="GroupBox" groupBox="1" collapsedExpression="" verticalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="6" name="EngineStructType" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="11" name="Accessory" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" collapsedExpressionEnabled="0" collapsed="0" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" name="Привязка" horizontalStretch="0" type="Tab" groupBox="0" collapsedExpression="" verticalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="8" name="OdhAxis" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="7" name="OdhSide" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" index="9" name="Endwise" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" collapsedExpressionEnabled="0" collapsed="0" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" name="Параметры" horizontalStretch="0" type="GroupBox" groupBox="1" collapsedExpression="" verticalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" index="12" name="Description" horizontalStretch="0" verticalStretch="0">
        <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
          <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement showLabel="0" name="Spacer Widget" horizontalStretch="0" drawLine="0" verticalStretch="0">
      <labelStyle overrideLabelFont="0" labelColor="" overrideLabelColor="0">
        <labelFont italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" strikethrough="0" underline="0" bold="0"/>
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
