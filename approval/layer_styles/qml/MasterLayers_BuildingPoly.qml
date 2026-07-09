<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" labelsEnabled="0" symbologyReferenceScale="-1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" simplifyMaxScale="1" simplifyDrawingTol="1" minScale="100000000" version="3.38.0-Grenoble" simplifyDrawingHints="1" simplifyAlgorithm="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions">
  <renderer-v2 symbollevels="0" forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1">
    <rules key="{a87b8445-e92c-434c-a597-50913e8546fd}">
      <rule filter="&quot;BuildingsType&quot; = 'residential'" key="{668b1e58-0eb8-471f-a236-f164025b758f}" label="Жилое" symbol="0"/>
      <rule filter="&quot;BuildingsType&quot; = 'non_residential'" key="{c240ae60-fa00-4c73-b193-2875938ed140}" label="Нежилое" symbol="1"/>
      <rule filter="&quot;BuildingsType&quot; = 'blind_area'" key="{2676c685-72df-4f98-954a-a52e57ee3609}" label="Отмостка" symbol="2"/>
      <rule filter="&quot;BuildingsType&quot; = 'monument'" key="{29e55a08-3c5d-4b89-8041-2588e5b7a448}" label="Объект монументального искусства" symbol="3"/>
      <rule filter="ELSE" key="{dcad9837-5414-4374-a164-545a126f8078}" label="Нет данных" symbol="4"/>
    </rules>
    <symbols>
      <symbol frame_rate="10" is_animated="0" name="0" type="fill" force_rhr="0" alpha="0.3" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{977b3e9f-5e35-4108-9189-cc0ef5f1d604}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="255,255,128,255,rgb:1,1,0.50196078431372548,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="1" type="fill" force_rhr="0" alpha="0.3" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{2b45f8d8-9bcc-49c0-b6a0-4ff65f12ca56}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="255,210,210,255,rgb:1,0.82352941176470584,0.82352941176470584,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="2" type="fill" force_rhr="0" alpha="0.3" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{9758d3b0-16d1-4c7e-a51e-3c21624aff48}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="220,220,220,255,rgb:0.86274509803921573,0.86274509803921573,0.86274509803921573,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="3" type="fill" force_rhr="0" alpha="0.3" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{bc9c7821-49e3-4ea7-8e49-e7c0b247675e}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="0,12,175,255,hsv:0.65555555555555556,1,0.68627450980392157,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
      <symbol frame_rate="10" is_animated="0" name="4" type="fill" force_rhr="0" alpha="0.3" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{115ec2a1-1de5-45cf-8df8-c57070d9d905}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="228,26,28,255,rgb:0.89411764705882357,0.10196078431372549,0.10980392156862745,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="128,14,16,255,rgb:0.50196078431372548,0.05490196078431372,0.06274509803921569,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
          </Option>
          <effect type="effectStack" enabled="0">
            <effect type="dropShadow">
              <Option type="Map">
                <Option value="13" name="blend_mode" type="QString"/>
                <Option value="2.645" name="blur_level" type="QString"/>
                <Option value="MM" name="blur_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="blur_unit_scale" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="color" type="QString"/>
                <Option value="2" name="draw_mode" type="QString"/>
                <Option value="0" name="enabled" type="QString"/>
                <Option value="135" name="offset_angle" type="QString"/>
                <Option value="2" name="offset_distance" type="QString"/>
                <Option value="MM" name="offset_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="offset_unit_scale" type="QString"/>
                <Option value="1" name="opacity" type="QString"/>
              </Option>
            </effect>
            <effect type="outerGlow">
              <Option type="Map">
                <Option value="0" name="blend_mode" type="QString"/>
                <Option value="0.7935" name="blur_level" type="QString"/>
                <Option value="MM" name="blur_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="blur_unit_scale" type="QString"/>
                <Option value="0,0,255,255,rgb:0,0,1,1" name="color1" type="QString"/>
                <Option value="0,255,0,255,rgb:0,1,0,1" name="color2" type="QString"/>
                <Option value="0" name="color_type" type="QString"/>
                <Option value="ccw" name="direction" type="QString"/>
                <Option value="0" name="discrete" type="QString"/>
                <Option value="2" name="draw_mode" type="QString"/>
                <Option value="0" name="enabled" type="QString"/>
                <Option value="0.5" name="opacity" type="QString"/>
                <Option value="gradient" name="rampType" type="QString"/>
                <Option value="255,255,255,255,rgb:1,1,1,1" name="single_color" type="QString"/>
                <Option value="rgb" name="spec" type="QString"/>
                <Option value="2" name="spread" type="QString"/>
                <Option value="MM" name="spread_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="spread_unit_scale" type="QString"/>
              </Option>
            </effect>
            <effect type="blur">
              <Option type="Map">
                <Option value="0" name="blend_mode" type="QString"/>
                <Option value="2.645" name="blur_level" type="QString"/>
                <Option value="0" name="blur_method" type="QString"/>
                <Option value="MM" name="blur_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="blur_unit_scale" type="QString"/>
                <Option value="2" name="draw_mode" type="QString"/>
                <Option value="1" name="enabled" type="QString"/>
                <Option value="1" name="opacity" type="QString"/>
              </Option>
            </effect>
            <effect type="innerShadow">
              <Option type="Map">
                <Option value="13" name="blend_mode" type="QString"/>
                <Option value="2.645" name="blur_level" type="QString"/>
                <Option value="MM" name="blur_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="blur_unit_scale" type="QString"/>
                <Option value="0,0,0,255,rgb:0,0,0,1" name="color" type="QString"/>
                <Option value="2" name="draw_mode" type="QString"/>
                <Option value="0" name="enabled" type="QString"/>
                <Option value="135" name="offset_angle" type="QString"/>
                <Option value="2" name="offset_distance" type="QString"/>
                <Option value="MM" name="offset_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="offset_unit_scale" type="QString"/>
                <Option value="1" name="opacity" type="QString"/>
              </Option>
            </effect>
            <effect type="innerGlow">
              <Option type="Map">
                <Option value="0" name="blend_mode" type="QString"/>
                <Option value="0.7935" name="blur_level" type="QString"/>
                <Option value="MM" name="blur_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="blur_unit_scale" type="QString"/>
                <Option value="0,0,255,255,rgb:0,0,1,1" name="color1" type="QString"/>
                <Option value="0,255,0,255,rgb:0,1,0,1" name="color2" type="QString"/>
                <Option value="0" name="color_type" type="QString"/>
                <Option value="ccw" name="direction" type="QString"/>
                <Option value="0" name="discrete" type="QString"/>
                <Option value="2" name="draw_mode" type="QString"/>
                <Option value="0" name="enabled" type="QString"/>
                <Option value="0.5" name="opacity" type="QString"/>
                <Option value="gradient" name="rampType" type="QString"/>
                <Option value="255,255,255,255,rgb:1,1,1,1" name="single_color" type="QString"/>
                <Option value="rgb" name="spec" type="QString"/>
                <Option value="2" name="spread" type="QString"/>
                <Option value="MM" name="spread_unit" type="QString"/>
                <Option value="3x:0,0,0,0,0,0" name="spread_unit_scale" type="QString"/>
              </Option>
            </effect>
          </effect>
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
      <symbol frame_rate="10" is_animated="0" name="" type="fill" force_rhr="0" alpha="1" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" name="name" type="QString"/>
            <Option name="properties"/>
            <Option value="collection" name="type" type="QString"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleFill" pass="0" locked="0" id="{6c7133ec-bbf7-4dc9-ac81-67d56300c99c}" enabled="1">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale" type="QString"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" name="color" type="QString"/>
            <Option value="bevel" name="joinstyle" type="QString"/>
            <Option value="0,0" name="offset" type="QString"/>
            <Option value="3x:0,0,0,0,0,0" name="offset_map_unit_scale" type="QString"/>
            <Option value="MM" name="offset_unit" type="QString"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" name="outline_color" type="QString"/>
            <Option value="solid" name="outline_style" type="QString"/>
            <Option value="0.26" name="outline_width" type="QString"/>
            <Option value="MM" name="outline_width_unit" type="QString"/>
            <Option value="solid" name="style" type="QString"/>
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
    <checkConfiguration type="Map">
      <Option name="QgsGeometryGapCheck" type="Map">
        <Option value="0" name="allowedGapsBuffer" type="double"/>
        <Option value="false" name="allowedGapsEnabled" type="bool"/>
        <Option value="" name="allowedGapsLayer" type="QString"/>
      </Option>
    </checkConfiguration>
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
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="BuildingsType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="__________________________________________87201f49_f472_45a5_9463_5ceca532118a" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО) Назначение зданий и сооружений" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;BuildingsType&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="false" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="BuildingsTypeSpec" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option name="Description" type="invalid"/>
            <Option value="&quot;BuildingsType&quot; = current_value('BuildingsType')" name="FilterExpression" type="QString"/>
            <Option value="Code" name="Key" type="QString"/>
            <Option value="____________________________________________________a0601b16_78d7_4284_88ef_6eea20538ef8" name="Layer" type="QString"/>
            <Option value="Справочник (ДТ/ОО) Уточнение назначения зданий и сооружений" name="LayerName" type="QString"/>
            <Option value="postgres" name="LayerProviderName" type="QString"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;BuildingsTypeSpec&quot;" name="LayerSource" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="false" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="Name" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Unom" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Unad" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="BuildArea" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="1.7976931348623157e+308" name="Max" type="double"/>
            <Option value="-1.7976931348623157e+308" name="Min" type="double"/>
            <Option value="2" name="Precision" type="int"/>
            <Option value="1" name="Step" type="double"/>
            <Option value="SpinBox" name="Style" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="FloorQty" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Property" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="FileList" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
  </fieldConfiguration>
  <aliases>
    <alias name="" index="0" field="fid"/>
    <alias name="" index="1" field="OghObjectType"/>
    <alias name="" index="2" field="ObjectId"/>
    <alias name="Идентификатор ОГХ (RootId)" index="3" field="RootId"/>
    <alias name="" index="4" field="StartDate"/>
    <alias name="" index="5" field="EndDate"/>
    <alias name="Назначение" index="6" field="BuildingsType"/>
    <alias name="Уточнение назначения" index="7" field="BuildingsTypeSpec"/>
    <alias name="UNOM" index="8" field="Unom"/>
    <alias name="UNAD" index="9" field="Unad"/>
    <alias name="Площадь застройки, кв.м." index="10" field="BuildArea"/>
    <alias name="Этажность" index="11" field="FloorQty"/>
    <alias name="Характеристика" index="12" field="Property"/>
    <alias name="" index="13" field="FileList"/>
    <alias name="Разновысотные отметки" index="14" field="IsDiffHeightMark"/>
    <alias name="" index="15" field="ParentOghObjectType"/>
    <alias name="" index="16" field="ParentObjectId"/>
    <alias name="" index="17" field="ParentRootId"/>
    <alias name="" index="18" field="ParentStartDate"/>
    <alias name="" index="19" field="ParentEndDate"/>
  </aliases>
  <splitPolicies>
    <policy policy="Duplicate" field="fid"/>
    <policy policy="Duplicate" field="OghObjectType"/>
    <policy policy="Duplicate" field="ObjectId"/>
    <policy policy="Duplicate" field="RootId"/>
    <policy policy="Duplicate" field="StartDate"/>
    <policy policy="Duplicate" field="EndDate"/>
    <policy policy="Duplicate" field="BuildingsType"/>
    <policy policy="Duplicate" field="BuildingsTypeSpec"/>
    <policy policy="Duplicate" field="Unom"/>
    <policy policy="Duplicate" field="Unad"/>
    <policy policy="Duplicate" field="BuildArea"/>
    <policy policy="Duplicate" field="FloorQty"/>
    <policy policy="Duplicate" field="Property"/>
    <policy policy="Duplicate" field="FileList"/>
    <policy policy="Duplicate" field="IsDiffHeightMark"/>
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
    <policy policy="Duplicate" field="BuildingsType"/>
    <policy policy="Duplicate" field="BuildingsTypeSpec"/>
    <policy policy="Duplicate" field="Unom"/>
    <policy policy="Duplicate" field="Unad"/>
    <policy policy="Duplicate" field="BuildArea"/>
    <policy policy="Duplicate" field="FloorQty"/>
    <policy policy="Duplicate" field="Property"/>
    <policy policy="Duplicate" field="FileList"/>
    <policy policy="Duplicate" field="IsDiffHeightMark"/>
    <policy policy="Duplicate" field="ParentOghObjectType"/>
    <policy policy="Duplicate" field="ParentObjectId"/>
    <policy policy="Duplicate" field="ParentRootId"/>
    <policy policy="Duplicate" field="ParentStartDate"/>
    <policy policy="Duplicate" field="ParentEndDate"/>
  </duplicatePolicies>
  <defaults>
    <default expression="" field="fid" applyOnUpdate="0"/>
    <default expression="" field="OghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ObjectId" applyOnUpdate="0"/>
    <default expression="" field="RootId" applyOnUpdate="0"/>
    <default expression="" field="StartDate" applyOnUpdate="0"/>
    <default expression="" field="EndDate" applyOnUpdate="0"/>
    <default expression="" field="BuildingsType" applyOnUpdate="0"/>
    <default expression="" field="BuildingsTypeSpec" applyOnUpdate="0"/>
    <default expression="" field="Unom" applyOnUpdate="0"/>
    <default expression="" field="Unad" applyOnUpdate="0"/>
    <default expression="" field="BuildArea" applyOnUpdate="0"/>
    <default expression="" field="FloorQty" applyOnUpdate="0"/>
    <default expression="" field="Property" applyOnUpdate="0"/>
    <default expression="" field="FileList" applyOnUpdate="0"/>
    <default expression="" field="IsDiffHeightMark" applyOnUpdate="0"/>
    <default expression="" field="ParentOghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ParentObjectId" applyOnUpdate="0"/>
    <default expression="" field="ParentRootId" applyOnUpdate="0"/>
    <default expression="" field="ParentStartDate" applyOnUpdate="0"/>
    <default expression="" field="ParentEndDate" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" exp_strength="0" unique_strength="1" constraints="3" field="fid"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="OghObjectType"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ObjectId"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="RootId"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="StartDate"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="EndDate"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="BuildingsType"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="BuildingsTypeSpec"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="Unom"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="Unad"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="BuildArea"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="FloorQty"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="Property"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="FileList"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="IsDiffHeightMark"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ParentOghObjectType"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ParentObjectId"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ParentRootId"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ParentStartDate"/>
    <constraint notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0" field="ParentEndDate"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="fid"/>
    <constraint exp="" desc="" field="OghObjectType"/>
    <constraint exp="" desc="" field="ObjectId"/>
    <constraint exp="" desc="" field="RootId"/>
    <constraint exp="" desc="" field="StartDate"/>
    <constraint exp="" desc="" field="EndDate"/>
    <constraint exp="" desc="" field="BuildingsType"/>
    <constraint exp="" desc="" field="BuildingsTypeSpec"/>
    <constraint exp="" desc="" field="Unom"/>
    <constraint exp="" desc="" field="Unad"/>
    <constraint exp="" desc="" field="BuildArea"/>
    <constraint exp="" desc="" field="FloorQty"/>
    <constraint exp="" desc="" field="Property"/>
    <constraint exp="" desc="" field="FileList"/>
    <constraint exp="" desc="" field="IsDiffHeightMark"/>
    <constraint exp="" desc="" field="ParentOghObjectType"/>
    <constraint exp="" desc="" field="ParentObjectId"/>
    <constraint exp="" desc="" field="ParentRootId"/>
    <constraint exp="" desc="" field="ParentStartDate"/>
    <constraint exp="" desc="" field="ParentEndDate"/>
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
      <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
    </labelStyle>
    <attributeEditorField name="RootId" index="3" showLabel="1" verticalStretch="0" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
        <labelFont description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer collapsed="0" columnCount="3" visibilityExpression="" visibilityExpressionEnabled="0" name="Назначение" groupBox="1" collapsedExpression="" type="GroupBox" showLabel="1" verticalStretch="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
      </labelStyle>
      <attributeEditorField name="BuildingsType" index="6" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="BuildingsTypeSpec" index="7" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Property" index="12" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer collapsed="0" columnCount="5" visibilityExpression="" visibilityExpressionEnabled="0" name="Параметры" groupBox="1" collapsedExpression="" type="GroupBox" showLabel="1" verticalStretch="0" collapsedExpressionEnabled="0" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
      </labelStyle>
      <attributeEditorField name="Unom" index="8" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Unad" index="9" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="FloorQty" index="11" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="BuildArea" index="10" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsDiffHeightMark" index="14" showLabel="1" verticalStretch="0" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont description="Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement name="SpacerWidget" showLabel="0" verticalStretch="0" drawLine="0" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont description="Sans,10,-1,5,50,0,0,0,0,0" style="" italic="0" underline="0" strikethrough="0" bold="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="AddressList" editable="1"/>
    <field name="BuildArea" editable="1"/>
    <field name="BuildingsType" editable="1"/>
    <field name="BuildingsTypeSpec" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="FloorQty" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="Property" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="Unad" editable="1"/>
    <field name="Unom" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="0" name="AddressList"/>
    <field labelOnTop="1" name="BuildArea"/>
    <field labelOnTop="1" name="BuildingsType"/>
    <field labelOnTop="1" name="BuildingsTypeSpec"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="0" name="FileList"/>
    <field labelOnTop="1" name="FloorQty"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="Property"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="Unad"/>
    <field labelOnTop="1" name="Unom"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="AddressList" reuseLastValue="0"/>
    <field name="BuildArea" reuseLastValue="0"/>
    <field name="BuildingsType" reuseLastValue="0"/>
    <field name="BuildingsTypeSpec" reuseLastValue="0"/>
    <field name="ChangeAuthor" reuseLastValue="0"/>
    <field name="ChangeDate" reuseLastValue="0"/>
    <field name="CreateAuthor" reuseLastValue="0"/>
    <field name="CreateDate" reuseLastValue="0"/>
    <field name="EndDate" reuseLastValue="0"/>
    <field name="FileList" reuseLastValue="0"/>
    <field name="FloorQty" reuseLastValue="0"/>
    <field name="IsDiffHeightMark" reuseLastValue="0"/>
    <field name="ObjectId" reuseLastValue="0"/>
    <field name="OghObjectType" reuseLastValue="0"/>
    <field name="ParentEndDate" reuseLastValue="0"/>
    <field name="ParentObjectId" reuseLastValue="0"/>
    <field name="ParentOghObjectType" reuseLastValue="0"/>
    <field name="ParentRootId" reuseLastValue="0"/>
    <field name="ParentStartDate" reuseLastValue="0"/>
    <field name="Property" reuseLastValue="0"/>
    <field name="RootId" reuseLastValue="0"/>
    <field name="StartDate" reuseLastValue="0"/>
    <field name="TaskGUID" reuseLastValue="0"/>
    <field name="Unad" reuseLastValue="0"/>
    <field name="Unom" reuseLastValue="0"/>
    <field name="fid" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
