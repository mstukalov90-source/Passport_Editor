<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis simplifyDrawingHints="0" simplifyLocal="1" hasScaleBasedVisibilityFlag="0" labelsEnabled="0" version="3.38.0-Grenoble" simplifyAlgorithm="0" simplifyMaxScale="1" minScale="100000000" symbologyReferenceScale="-1" maxScale="0" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyDrawingTol="1">
  <renderer-v2 enableorderby="0" type="RuleRenderer" forceraster="0" referencescale="-1" symbollevels="0">
    <rules key="{800674d2-9365-428c-9b12-bfc479ad1e47}">
      <rule symbol="0" label="Дерево" key="{1316a32e-8cd5-494e-bede-d96c0d69bcdf}" filter=" &quot;LifeFormType&quot; = 'tree'"/>
      <rule symbol="1" label="Кустарник" key="{001a9600-3707-46fa-9dbd-723edd3a79dc}" filter=" &quot;LifeFormType&quot; = 'bush'"/>
      <rule symbol="2" label="Нет данных" key="{14640302-7792-43c4-b954-515936a03aa9}" filter="ELSE"/>
    </rules>
    <symbols>
      <symbol force_rhr="0" frame_rate="10" type="marker" name="0" clip_to_extent="1" is_animated="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" locked="0" id="{6d1f99a3-088c-4f3d-9b87-fbdbf9cc1476}" pass="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="73,183,0,255,rgb:0.28627450980392155,0.71764705882352942,0,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/Лиственное дерево.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString" name="outline_color"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="1" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="1" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Дерево_Дерево одиночное.svg'" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" frame_rate="10" type="marker" name="1" clip_to_extent="1" is_animated="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SvgMarker" enabled="1" locked="0" id="{6d1f99a3-088c-4f3d-9b87-fbdbf9cc1476}" pass="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="73,183,0,255,rgb:0.28627450980392155,0.71764705882352942,0,1" type="QString" name="color"/>
            <Option value="0" type="QString" name="fixedAspectRatio"/>
            <Option value="1" type="QString" name="horizontal_anchor_point"/>
            <Option value="/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/styles/svg/Кустарник.svg" type="QString" name="name"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1" type="QString" name="outline_color"/>
            <Option value="0" type="QString" name="outline_width"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="outline_width_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="outline_width_unit"/>
            <Option name="parameters"/>
            <Option value="diameter" type="QString" name="scale_method"/>
            <Option value="1" type="QString" name="size"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="size_map_unit_scale"/>
            <Option value="MapUnit" type="QString" name="size_unit"/>
            <Option value="1" type="QString" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option value="" type="QString" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option value="true" type="bool" name="active"/>
                  <Option value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Кустарник_Одиночный.svg'" type="QString" name="expression"/>
                  <Option value="3" type="int" name="type"/>
                </Option>
              </Option>
              <Option value="collection" type="QString" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol force_rhr="0" frame_rate="10" type="marker" name="2" clip_to_extent="1" is_animated="0" alpha="0.3">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" enabled="1" locked="0" id="{c89198e5-1e95-45fc-9bfe-9bfb051afc73}" pass="0">
          <Option type="Map">
            <Option value="0" type="QString" name="angle"/>
            <Option value="square" type="QString" name="cap_style"/>
            <Option value="229,0,4,255,rgb:0.89803921568627454,0,0.01568627450980392,1" type="QString" name="color"/>
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
      <symbol force_rhr="0" frame_rate="10" type="marker" name="" clip_to_extent="1" is_animated="0" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleMarker" enabled="1" locked="0" id="{d44e4cdd-c625-4dd0-98d9-88662b2ed7cb}" pass="0">
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
    <field configurationFlags="NoFlag" name="PlantationType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="___________________________40d6f2a8_2bcb_42e8_aa56_0ad41605b405" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Типы насаждения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantationType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlantType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________f6559441_3948_4c1e_9e38_5dcf3038d8a3" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Виды растений" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="true" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="LifeFormType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_______________________________9112d911_e36f_458c_80ac_a1ce88d10bd7" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Типы жизненных форм" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;LifeFormType&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Age">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Diameter">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="GreenNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Height">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="SectionNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Quantity">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Distance">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="BioGgroupNum">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MillionTrees">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+09" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="0" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="StateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="__________________________c526af74_ea1a_4e26_a693_754f1f59f6ba" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Коды состояний" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;StateGardering&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="DetailedStateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_______________________________a1e8c1a7_55be_4328_9788_450e96d3a33e" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Уточнение состояния" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;DetailedStateGardering&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CharacteristicStateGardening">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="____________________________________266c3f18_8184_4752_8704_4715a2db50da" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Характеристика состояния" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CharacteristicStateGardering&quot;" type="QString" name="LayerSource"/>
            <Option value="4" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="true" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="PlantServiceRecomendations">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowMulti"/>
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="2" type="int" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option value="false" type="bool" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option value="Code" type="QString" name="Key"/>
            <Option value="_________________________________dc0579d2_3e41_4edf_b188_045a087a651f" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Рекомендация по уходу" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;PlantServiceRecomendations&quot;" type="QString" name="LayerSource"/>
            <Option value="2" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="true" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="ValuablePlants">
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
            <Option value="___________________________d0fc3550_8a02_4c67_a779_c3acf89c42a1" type="QString" name="Layer"/>
            <Option value="Справочник (ДТ/ОО) Ценные растения" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ValuablePlants&quot;" type="QString" name="LayerSource"/>
            <Option value="1" type="int" name="NofColumns"/>
            <Option value="true" type="bool" name="OrderByValue"/>
            <Option value="false" type="bool" name="UseCompleter"/>
            <Option value="Name" type="QString" name="Value"/>
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
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
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
    <alias field="PlantationType" index="6" name="Тип насаждения"/>
    <alias field="PlantType" index="7" name="Вид растения"/>
    <alias field="LifeFormType" index="8" name="Жизненная форма"/>
    <alias field="Age" index="9" name="Возраст"/>
    <alias field="Diameter" index="10" name="Диаметр на высоте 1,3 м"/>
    <alias field="GreenNum" index="11" name="№ Растения"/>
    <alias field="Height" index="12" name="Высота"/>
    <alias field="SectionNum" index="13" name="№ Участка"/>
    <alias field="Quantity" index="14" name="Количество"/>
    <alias field="Area" index="15" name="Площадь"/>
    <alias field="Distance" index="16" name="Протяженность"/>
    <alias field="BioGgroupNum" index="17" name="Номер биогруппы"/>
    <alias field="MillionTrees" index="18" name="Акция «Миллион деревьев»"/>
    <alias field="StateGardening" index="19" name="Состояние"/>
    <alias field="DetailedStateGardening" index="20" name="Уточнение состояния"/>
    <alias field="CharacteristicStateGardening" index="21" name="Характеристика состояния"/>
    <alias field="PlantServiceRecomendations" index="22" name="Рекомендации по уходу"/>
    <alias field="ValuablePlants" index="23" name="Особо ценные"/>
    <alias field="FileList" index="24" name=""/>
    <alias field="NoCalc" index="25" name="Не учитывать"/>
    <alias field="IsDiffHeightMark" index="26" name="Разновысотные отметки"/>
    <alias field="ParentOghObjectType" index="27" name=""/>
    <alias field="ParentObjectId" index="28" name=""/>
    <alias field="ParentRootId" index="29" name=""/>
    <alias field="ParentStartDate" index="30" name=""/>
    <alias field="ParentEndDate" index="31" name=""/>
  </aliases>
  <splitPolicies>
    <policy policy="DefaultValue" field="fid"/>
    <policy policy="Duplicate" field="OghObjectType"/>
    <policy policy="Duplicate" field="ObjectId"/>
    <policy policy="DefaultValue" field="RootId"/>
    <policy policy="Duplicate" field="StartDate"/>
    <policy policy="DefaultValue" field="EndDate"/>
    <policy policy="DefaultValue" field="PlantationType"/>
    <policy policy="DefaultValue" field="PlantType"/>
    <policy policy="DefaultValue" field="LifeFormType"/>
    <policy policy="DefaultValue" field="Age"/>
    <policy policy="DefaultValue" field="Diameter"/>
    <policy policy="DefaultValue" field="GreenNum"/>
    <policy policy="DefaultValue" field="Height"/>
    <policy policy="DefaultValue" field="SectionNum"/>
    <policy policy="DefaultValue" field="Quantity"/>
    <policy policy="DefaultValue" field="Area"/>
    <policy policy="DefaultValue" field="Distance"/>
    <policy policy="DefaultValue" field="BioGgroupNum"/>
    <policy policy="DefaultValue" field="MillionTrees"/>
    <policy policy="DefaultValue" field="StateGardening"/>
    <policy policy="DefaultValue" field="DetailedStateGardening"/>
    <policy policy="DefaultValue" field="CharacteristicStateGardening"/>
    <policy policy="DefaultValue" field="PlantServiceRecomendations"/>
    <policy policy="DefaultValue" field="ValuablePlants"/>
    <policy policy="DefaultValue" field="FileList"/>
    <policy policy="DefaultValue" field="NoCalc"/>
    <policy policy="DefaultValue" field="IsDiffHeightMark"/>
    <policy policy="DefaultValue" field="ParentOghObjectType"/>
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
    <policy policy="Duplicate" field="PlantationType"/>
    <policy policy="Duplicate" field="PlantType"/>
    <policy policy="Duplicate" field="LifeFormType"/>
    <policy policy="Duplicate" field="Age"/>
    <policy policy="Duplicate" field="Diameter"/>
    <policy policy="Duplicate" field="GreenNum"/>
    <policy policy="Duplicate" field="Height"/>
    <policy policy="Duplicate" field="SectionNum"/>
    <policy policy="Duplicate" field="Quantity"/>
    <policy policy="Duplicate" field="Area"/>
    <policy policy="Duplicate" field="Distance"/>
    <policy policy="Duplicate" field="BioGgroupNum"/>
    <policy policy="Duplicate" field="MillionTrees"/>
    <policy policy="Duplicate" field="StateGardening"/>
    <policy policy="Duplicate" field="DetailedStateGardening"/>
    <policy policy="Duplicate" field="CharacteristicStateGardening"/>
    <policy policy="Duplicate" field="PlantServiceRecomendations"/>
    <policy policy="Duplicate" field="ValuablePlants"/>
    <policy policy="Duplicate" field="FileList"/>
    <policy policy="Duplicate" field="NoCalc"/>
    <policy policy="Duplicate" field="IsDiffHeightMark"/>
    <policy policy="Duplicate" field="ParentOghObjectType"/>
    <policy policy="Duplicate" field="ParentObjectId"/>
    <policy policy="Duplicate" field="ParentRootId"/>
    <policy policy="Duplicate" field="ParentStartDate"/>
    <policy policy="Duplicate" field="ParentEndDate"/>
  </duplicatePolicies>
  <defaults>
    <default field="fid" expression="" applyOnUpdate="0"/>
    <default field="OghObjectType" expression="" applyOnUpdate="0"/>
    <default field="ObjectId" expression="" applyOnUpdate="0"/>
    <default field="RootId" expression="" applyOnUpdate="0"/>
    <default field="StartDate" expression="" applyOnUpdate="0"/>
    <default field="EndDate" expression="" applyOnUpdate="0"/>
    <default field="PlantationType" expression="" applyOnUpdate="0"/>
    <default field="PlantType" expression="" applyOnUpdate="0"/>
    <default field="LifeFormType" expression="" applyOnUpdate="0"/>
    <default field="Age" expression="" applyOnUpdate="0"/>
    <default field="Diameter" expression="" applyOnUpdate="0"/>
    <default field="GreenNum" expression="" applyOnUpdate="0"/>
    <default field="Height" expression="" applyOnUpdate="0"/>
    <default field="SectionNum" expression="" applyOnUpdate="0"/>
    <default field="Quantity" expression="" applyOnUpdate="0"/>
    <default field="Area" expression="" applyOnUpdate="0"/>
    <default field="Distance" expression="" applyOnUpdate="0"/>
    <default field="BioGgroupNum" expression="" applyOnUpdate="0"/>
    <default field="MillionTrees" expression="" applyOnUpdate="0"/>
    <default field="StateGardening" expression="" applyOnUpdate="0"/>
    <default field="DetailedStateGardening" expression="" applyOnUpdate="0"/>
    <default field="CharacteristicStateGardening" expression="" applyOnUpdate="0"/>
    <default field="PlantServiceRecomendations" expression="" applyOnUpdate="0"/>
    <default field="ValuablePlants" expression="" applyOnUpdate="0"/>
    <default field="FileList" expression="" applyOnUpdate="0"/>
    <default field="NoCalc" expression="" applyOnUpdate="0"/>
    <default field="IsDiffHeightMark" expression="" applyOnUpdate="0"/>
    <default field="ParentOghObjectType" expression="" applyOnUpdate="0"/>
    <default field="ParentObjectId" expression="" applyOnUpdate="0"/>
    <default field="ParentRootId" expression="" applyOnUpdate="0"/>
    <default field="ParentStartDate" expression="" applyOnUpdate="0"/>
    <default field="ParentEndDate" expression="" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint constraints="3" field="fid" exp_strength="0" unique_strength="1" notnull_strength="1"/>
    <constraint constraints="0" field="OghObjectType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ObjectId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="RootId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="StartDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="EndDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="PlantationType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="PlantType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="LifeFormType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Age" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Diameter" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="GreenNum" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Height" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="SectionNum" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Quantity" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Area" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="Distance" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="BioGgroupNum" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="MillionTrees" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="StateGardening" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="DetailedStateGardening" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="CharacteristicStateGardening" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="PlantServiceRecomendations" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ValuablePlants" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="FileList" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="NoCalc" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="IsDiffHeightMark" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentOghObjectType" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentObjectId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentRootId" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentStartDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
    <constraint constraints="0" field="ParentEndDate" exp_strength="0" unique_strength="0" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" field="fid" desc=""/>
    <constraint exp="" field="OghObjectType" desc=""/>
    <constraint exp="" field="ObjectId" desc=""/>
    <constraint exp="" field="RootId" desc=""/>
    <constraint exp="" field="StartDate" desc=""/>
    <constraint exp="" field="EndDate" desc=""/>
    <constraint exp="" field="PlantationType" desc=""/>
    <constraint exp="" field="PlantType" desc=""/>
    <constraint exp="" field="LifeFormType" desc=""/>
    <constraint exp="" field="Age" desc=""/>
    <constraint exp="" field="Diameter" desc=""/>
    <constraint exp="" field="GreenNum" desc=""/>
    <constraint exp="" field="Height" desc=""/>
    <constraint exp="" field="SectionNum" desc=""/>
    <constraint exp="" field="Quantity" desc=""/>
    <constraint exp="" field="Area" desc=""/>
    <constraint exp="" field="Distance" desc=""/>
    <constraint exp="" field="BioGgroupNum" desc=""/>
    <constraint exp="" field="MillionTrees" desc=""/>
    <constraint exp="" field="StateGardening" desc=""/>
    <constraint exp="" field="DetailedStateGardening" desc=""/>
    <constraint exp="" field="CharacteristicStateGardening" desc=""/>
    <constraint exp="" field="PlantServiceRecomendations" desc=""/>
    <constraint exp="" field="ValuablePlants" desc=""/>
    <constraint exp="" field="FileList" desc=""/>
    <constraint exp="" field="NoCalc" desc=""/>
    <constraint exp="" field="IsDiffHeightMark" desc=""/>
    <constraint exp="" field="ParentOghObjectType" desc=""/>
    <constraint exp="" field="ParentObjectId" desc=""/>
    <constraint exp="" field="ParentRootId" desc=""/>
    <constraint exp="" field="ParentStartDate" desc=""/>
    <constraint exp="" field="ParentEndDate" desc=""/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit>openDialog</editforminit>
  <editforminitcodesource>1</editforminitcodesource>
  <editforminitfilepath>/home/ttt/.local/share/QGIS/QGIS3/profiles/default/python/plugins/MggtAsu/init_functions/file_manager.py</editforminitfilepath>
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
    <labelStyle labelColor="" overrideLabelFont="0" overrideLabelColor="0">
      <labelFont italic="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
    </labelStyle>
    <attributeEditorField horizontalStretch="0" verticalStretch="0" index="3" name="RootId" showLabel="1">
      <labelStyle labelColor="" overrideLabelFont="0" overrideLabelColor="0">
        <labelFont italic="0" style="" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" verticalStretch="0" type="GroupBox" collapsedExpression="" name="Назначение" showLabel="1" groupBox="1" columnCount="5" visibilityExpressionEnabled="0" visibilityExpression="">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
        <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="6" name="PlantationType" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="7" name="PlantType" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="8" name="LifeFormType" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="26" name="IsDiffHeightMark" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="25" name="NoCalc" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" verticalStretch="0" type="GroupBox" collapsedExpression="" name="Параметры" showLabel="1" groupBox="1" columnCount="5" visibilityExpressionEnabled="0" visibilityExpression="">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
        <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="9" name="Age" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="10" name="Diameter" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="12" name="Height" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="11" name="GreenNum" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="13" name="SectionNum" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="14" name="Quantity" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="15" name="Area" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="16" name="Distance" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="17" name="BioGgroupNum" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="18" name="MillionTrees" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="19" name="StateGardening" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="20" name="DetailedStateGardening" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="23" name="ValuablePlants" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer horizontalStretch="0" collapsed="0" collapsedExpressionEnabled="0" verticalStretch="0" type="GroupBox" collapsedExpression="" name="Состояние" showLabel="1" groupBox="1" columnCount="2" visibilityExpressionEnabled="0" visibilityExpression="">
      <labelStyle labelColor="" overrideLabelFont="0" overrideLabelColor="0">
        <labelFont italic="0" style="" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="21" name="CharacteristicStateGardening" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" verticalStretch="0" index="22" name="PlantServiceRecomendations" showLabel="1">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelFont="0" overrideLabelColor="0">
          <labelFont italic="0" style="" strikethrough="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement horizontalStretch="0" verticalStretch="0" drawLine="0" name="Spacer Widget" showLabel="0">
      <labelStyle labelColor="" overrideLabelFont="0" overrideLabelColor="0">
        <labelFont italic="0" style="" strikethrough="0" description="Sans,10,-1,5,50,0,0,0,0,0" bold="0" underline="0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="Age" editable="1"/>
    <field name="Area" editable="1"/>
    <field name="BioGgroupNum" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CharacteristicStateGardening" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="DetailedStateGardening" editable="1"/>
    <field name="Diameter" editable="1"/>
    <field name="Distance" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="GreenNum" editable="1"/>
    <field name="Height" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="LifeFormType" editable="1"/>
    <field name="MillionTrees" editable="1"/>
    <field name="NoCalc" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="PlantServiceRecomendations" editable="1"/>
    <field name="PlantType" editable="1"/>
    <field name="PlantationType" editable="1"/>
    <field name="Quantity" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="SectionNum" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="StateGardening" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="ValuablePlants" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="Age"/>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="1" name="BioGgroupNum"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CharacteristicStateGardening"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="1" name="DetailedStateGardening"/>
    <field labelOnTop="1" name="Diameter"/>
    <field labelOnTop="1" name="Distance"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="0" name="FileList"/>
    <field labelOnTop="1" name="GreenNum"/>
    <field labelOnTop="1" name="Height"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="LifeFormType"/>
    <field labelOnTop="1" name="MillionTrees"/>
    <field labelOnTop="1" name="NoCalc"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="PlantServiceRecomendations"/>
    <field labelOnTop="1" name="PlantType"/>
    <field labelOnTop="1" name="PlantationType"/>
    <field labelOnTop="1" name="Quantity"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="1" name="SectionNum"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="1" name="StateGardening"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="ValuablePlants"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="Age"/>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="BioGgroupNum"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CharacteristicStateGardening"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="DetailedStateGardening"/>
    <field reuseLastValue="0" name="Diameter"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FileList"/>
    <field reuseLastValue="0" name="GreenNum"/>
    <field reuseLastValue="0" name="Height"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="LifeFormType"/>
    <field reuseLastValue="0" name="MillionTrees"/>
    <field reuseLastValue="0" name="NoCalc"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="PlantServiceRecomendations"/>
    <field reuseLastValue="0" name="PlantType"/>
    <field reuseLastValue="0" name="PlantationType"/>
    <field reuseLastValue="0" name="Quantity"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="SectionNum"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="StateGardening"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="ValuablePlants"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
