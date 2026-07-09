<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.38.0-Grenoble" simplifyLocal="1" hasScaleBasedVisibilityFlag="0" labelsEnabled="0" minScale="100000000" simplifyMaxScale="1" styleCategories="LayerConfiguration|Symbology|Labeling|Fields|Forms|Rendering" simplifyAlgorithm="0" simplifyDrawingTol="1" symbologyReferenceScale="-1" maxScale="0" simplifyDrawingHints="0" readOnly="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <renderer-v2 forceraster="0" type="RuleRenderer" symbollevels="0" enableorderby="0" referencescale="-1">
    <rules key="{d96c836c-97ea-4eeb-9e21-850cceffd6d8}">
      <rule key="{d76ec9d8-34a1-403f-8a11-fb439233fdf8}" symbol="0" filter="&quot;ContainerType&quot; = 'bunker_area'" label="Бункерная площадка"/>
      <rule key="{6f2c6ba3-3fbf-4514-a899-73da4122740e}" symbol="1" filter="&quot;ContainerType&quot; = 'container_area'" label="Контейнерная площадка"/>
      <rule key="{cc6100e6-8e33-4264-86cb-97680b3228fe}" symbol="2" filter="&quot;ContainerType&quot; = 'pavilion_rso'" label="Стационарный павильон для РСО"/>
      <rule key="{a529a093-8278-468e-a076-6c373aa1af8d}" symbol="3" filter="&quot;ContainerType&quot; = 'roll_container_area'" label="Контейнер для РСО"/>
      <rule key="{397c16bb-5fe2-462a-90e9-d3bab3eef1a2}" symbol="4" filter="&quot;ContainerType&quot; = 'roll_container_useful_components_area'" label="Контейнер для компонентов РСО"/>
      <rule key="{60114a5c-0894-477a-8ddb-be02c83d22f1}" symbol="5" filter="ELSE" label="Нет данных"/>
    </rules>
    <symbols>
      <symbol name="0" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="128,64,0,255,rgb:0.50196078431372548,0.25098039215686274,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="square"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
      <symbol name="1" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="128,64,0,255,rgb:0.50196078431372548,0.25098039215686274,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="square"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
      <symbol name="2" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="128,64,0,255,rgb:0.50196078431372548,0.25098039215686274,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="square"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
      <symbol name="3" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="128,64,0,255,rgb:0.50196078431372548,0.25098039215686274,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="square"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
      <symbol name="4" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="128,64,0,255,rgb:0.50196078431372548,0.25098039215686274,0,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="square"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
      <symbol name="5" type="marker" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{3fd23b8e-b037-4726-9f9f-20c750d6e185}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="0"/>
            <Option name="cap_style" type="QString" value="square"/>
            <Option name="color" type="QString" value="255,1,56,255,rgb:1,0.00392156862745098,0.2196078431372549,1"/>
            <Option name="horizontal_anchor_point" type="QString" value="1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="name" type="QString" value="circle"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="scale_method" type="QString" value="diameter"/>
            <Option name="size" type="QString" value="3"/>
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
      <symbol name="" type="marker" alpha="1" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleMarker" id="{bfe50b4e-4652-4444-881e-e777d5e908d3}" locked="0">
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
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
  <fieldConfiguration>
    <field name="fid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ContainerType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="____________________931b1ccf_16e1_4379_a35d_34028ce39716"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО) Типы МСО"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ContainerType&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="CoatingType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="QString" value="&quot;CoatingGroup&quot; = current_value('CoatingGroup')"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="_________________________bd1ecea0_b551_46bf_8247_bc0d6a345e54"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО/ОДХ) Виды покрытий"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CoatingType&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="CoatingGroup" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="___________________________753c1f0c_29ea_4fb2_862c_4d2bd3e179df"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО/ОДХ) Группы покрытий"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CoatingTypeGroup&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Unom" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Unad" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Area" configurationFlags="NoFlag">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Max" type="double" value="1.7976931348623157e+308"/>
            <Option name="Min" type="double" value="-1.7976931348623157e+308"/>
            <Option name="Precision" type="int" value="2"/>
            <Option name="Step" type="double" value="1"/>
            <Option name="Style" type="QString" value="SpinBox"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="AbutmentType" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="invalid"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="_______________________________7a494d92_ddeb_4f9a_a84f_44965167d3ce"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО) Элементы сопряжения"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;AbutmentType&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="AbutmentDistance" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="MafsTypeList" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="IsSeparateGarbageCollection" configurationFlags="NoFlag">
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
    <field name="FileList" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="NoCalc" configurationFlags="NoFlag">
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
    <field name="InYard" configurationFlags="NoFlag">
      <editWidget type="CheckBox">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="IsDiffHeightMark" configurationFlags="NoFlag">
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
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="M/d/yy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="yyyy-MM-dd HH:mm:ss"/>
            <Option name="field_format_overwrite" type="bool" value="false"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
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
    <alias name="Тип МСО" field="ContainerType" index="6"/>
    <alias name="Вид покрытия" field="CoatingType" index="7"/>
    <alias name="Группа покрытия" field="CoatingGroup" index="8"/>
    <alias name="UNOM" field="Unom" index="9"/>
    <alias name="UNAD" field="Unad" index="10"/>
    <alias name="Площадь, кв.м." field="Area" index="11"/>
    <alias name="Элемент сопряжения" field="AbutmentType" index="12"/>
    <alias name="Количество, п.м." field="AbutmentDistance" index="13"/>
    <alias name="" field="MafsTypeList" index="14"/>
    <alias name="Раздельный сбор мусора" field="IsSeparateGarbageCollection" index="15"/>
    <alias name="" field="FileList" index="16"/>
    <alias name="Не учитывать" field="NoCalc" index="17"/>
    <alias name="" field="InYard" index="18"/>
    <alias name="Разновысотные отметки" field="IsDiffHeightMark" index="19"/>
    <alias name="" field="ParentOghObjectType" index="20"/>
    <alias name="" field="ParentObjectId" index="21"/>
    <alias name="" field="ParentRootId" index="22"/>
    <alias name="" field="ParentStartDate" index="23"/>
    <alias name="" field="ParentEndDate" index="24"/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="ContainerType" policy="DefaultValue"/>
    <policy field="CoatingType" policy="DefaultValue"/>
    <policy field="CoatingGroup" policy="DefaultValue"/>
    <policy field="Unom" policy="DefaultValue"/>
    <policy field="Unad" policy="DefaultValue"/>
    <policy field="Area" policy="DefaultValue"/>
    <policy field="AbutmentType" policy="DefaultValue"/>
    <policy field="AbutmentDistance" policy="DefaultValue"/>
    <policy field="MafsTypeList" policy="Duplicate"/>
    <policy field="IsSeparateGarbageCollection" policy="DefaultValue"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="InYard" policy="Duplicate"/>
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
    <policy field="ContainerType" policy="Duplicate"/>
    <policy field="CoatingType" policy="Duplicate"/>
    <policy field="CoatingGroup" policy="Duplicate"/>
    <policy field="Unom" policy="Duplicate"/>
    <policy field="Unad" policy="Duplicate"/>
    <policy field="Area" policy="Duplicate"/>
    <policy field="AbutmentType" policy="Duplicate"/>
    <policy field="AbutmentDistance" policy="Duplicate"/>
    <policy field="MafsTypeList" policy="Duplicate"/>
    <policy field="IsSeparateGarbageCollection" policy="Duplicate"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="Duplicate"/>
    <policy field="InYard" policy="Duplicate"/>
    <policy field="IsDiffHeightMark" policy="Duplicate"/>
    <policy field="ParentOghObjectType" policy="Duplicate"/>
    <policy field="ParentObjectId" policy="Duplicate"/>
    <policy field="ParentRootId" policy="Duplicate"/>
    <policy field="ParentStartDate" policy="Duplicate"/>
    <policy field="ParentEndDate" policy="Duplicate"/>
  </duplicatePolicies>
  <defaults>
    <default field="fid" expression="" applyOnUpdate="0"/>
    <default field="OghObjectType" expression="" applyOnUpdate="0"/>
    <default field="ObjectId" expression="" applyOnUpdate="0"/>
    <default field="RootId" expression="" applyOnUpdate="0"/>
    <default field="StartDate" expression="" applyOnUpdate="0"/>
    <default field="EndDate" expression="" applyOnUpdate="0"/>
    <default field="ContainerType" expression="" applyOnUpdate="0"/>
    <default field="CoatingType" expression="" applyOnUpdate="0"/>
    <default field="CoatingGroup" expression="" applyOnUpdate="0"/>
    <default field="Unom" expression="" applyOnUpdate="0"/>
    <default field="Unad" expression="" applyOnUpdate="0"/>
    <default field="Area" expression="" applyOnUpdate="0"/>
    <default field="AbutmentType" expression="" applyOnUpdate="0"/>
    <default field="AbutmentDistance" expression="" applyOnUpdate="0"/>
    <default field="MafsTypeList" expression="" applyOnUpdate="0"/>
    <default field="IsSeparateGarbageCollection" expression="" applyOnUpdate="0"/>
    <default field="FileList" expression="" applyOnUpdate="0"/>
    <default field="NoCalc" expression="" applyOnUpdate="0"/>
    <default field="InYard" expression="" applyOnUpdate="0"/>
    <default field="IsDiffHeightMark" expression="" applyOnUpdate="0"/>
    <default field="ParentOghObjectType" expression="" applyOnUpdate="0"/>
    <default field="ParentObjectId" expression="" applyOnUpdate="0"/>
    <default field="ParentRootId" expression="" applyOnUpdate="0"/>
    <default field="ParentStartDate" expression="" applyOnUpdate="0"/>
    <default field="ParentEndDate" expression="" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" field="fid" notnull_strength="1" constraints="3" unique_strength="1"/>
    <constraint exp_strength="0" field="OghObjectType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ObjectId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="RootId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="StartDate" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="EndDate" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ContainerType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="CoatingType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="CoatingGroup" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Unom" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Unad" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Area" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="AbutmentType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="AbutmentDistance" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="MafsTypeList" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="IsSeparateGarbageCollection" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="FileList" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="NoCalc" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="InYard" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="IsDiffHeightMark" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ParentOghObjectType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ParentObjectId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ParentRootId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ParentStartDate" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ParentEndDate" notnull_strength="0" constraints="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" exp="" desc=""/>
    <constraint field="OghObjectType" exp="" desc=""/>
    <constraint field="ObjectId" exp="" desc=""/>
    <constraint field="RootId" exp="" desc=""/>
    <constraint field="StartDate" exp="" desc=""/>
    <constraint field="EndDate" exp="" desc=""/>
    <constraint field="ContainerType" exp="" desc=""/>
    <constraint field="CoatingType" exp="" desc=""/>
    <constraint field="CoatingGroup" exp="" desc=""/>
    <constraint field="Unom" exp="" desc=""/>
    <constraint field="Unad" exp="" desc=""/>
    <constraint field="Area" exp="" desc=""/>
    <constraint field="AbutmentType" exp="" desc=""/>
    <constraint field="AbutmentDistance" exp="" desc=""/>
    <constraint field="MafsTypeList" exp="" desc=""/>
    <constraint field="IsSeparateGarbageCollection" exp="" desc=""/>
    <constraint field="FileList" exp="" desc=""/>
    <constraint field="NoCalc" exp="" desc=""/>
    <constraint field="InYard" exp="" desc=""/>
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
    <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
      <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField name="RootId" showLabel="1" verticalStretch="0" index="3" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer name="Назначение" visibilityExpressionEnabled="0" type="GroupBox" showLabel="1" verticalStretch="0" groupBox="1" collapsedExpression="" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" columnCount="4" collapsed="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="ContainerType" showLabel="1" verticalStretch="0" index="6" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="CoatingGroup" showLabel="1" verticalStretch="0" index="8" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="CoatingType" showLabel="1" verticalStretch="0" index="7" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsSeparateGarbageCollection" showLabel="1" verticalStretch="0" index="15" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer name="Параметры" visibilityExpressionEnabled="0" type="GroupBox" showLabel="1" verticalStretch="0" groupBox="1" collapsedExpression="" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" columnCount="5" collapsed="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="Unom" showLabel="1" verticalStretch="0" index="9" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Unad" showLabel="1" verticalStretch="0" index="10" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Area" showLabel="1" verticalStretch="0" index="11" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="NoCalc" showLabel="1" verticalStretch="0" index="17" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsDiffHeightMark" showLabel="1" verticalStretch="0" index="19" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement drawLine="0" name="SpacerWidget" showLabel="0" verticalStretch="0" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="Sans,10,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="AbutmentDistance" editable="1"/>
    <field name="AbutmentType" editable="1"/>
    <field name="AbutmentTypeList" editable="1"/>
    <field name="AddressList" editable="1"/>
    <field name="Area" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CoatingGroup" editable="1"/>
    <field name="CoatingType" editable="1"/>
    <field name="ContainerType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FileList" editable="1"/>
    <field name="InYard" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="IsSeparateGarbageCollection" editable="1"/>
    <field name="MafsTypeList" editable="1"/>
    <field name="NoCalc" editable="1"/>
    <field name="ObjectId" editable="1"/>
    <field name="OghObjectType" editable="1"/>
    <field name="ParentEndDate" editable="1"/>
    <field name="ParentObjectId" editable="1"/>
    <field name="ParentOghObjectType" editable="1"/>
    <field name="ParentRootId" editable="1"/>
    <field name="ParentStartDate" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="Unad" editable="1"/>
    <field name="Unom" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="AbutmentDistance" labelOnTop="1"/>
    <field name="AbutmentType" labelOnTop="1"/>
    <field name="AbutmentTypeList" labelOnTop="0"/>
    <field name="AddressList" labelOnTop="0"/>
    <field name="Area" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CoatingGroup" labelOnTop="1"/>
    <field name="CoatingType" labelOnTop="1"/>
    <field name="ContainerType" labelOnTop="1"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="InYard" labelOnTop="0"/>
    <field name="IsDiffHeightMark" labelOnTop="1"/>
    <field name="IsSeparateGarbageCollection" labelOnTop="1"/>
    <field name="MafsTypeList" labelOnTop="0"/>
    <field name="NoCalc" labelOnTop="1"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="OghObjectType" labelOnTop="0"/>
    <field name="ParentEndDate" labelOnTop="0"/>
    <field name="ParentObjectId" labelOnTop="0"/>
    <field name="ParentOghObjectType" labelOnTop="0"/>
    <field name="ParentRootId" labelOnTop="0"/>
    <field name="ParentStartDate" labelOnTop="0"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="Unad" labelOnTop="1"/>
    <field name="Unom" labelOnTop="1"/>
    <field name="fid" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="AbutmentDistance" reuseLastValue="0"/>
    <field name="AbutmentType" reuseLastValue="0"/>
    <field name="AbutmentTypeList" reuseLastValue="0"/>
    <field name="AddressList" reuseLastValue="0"/>
    <field name="Area" reuseLastValue="0"/>
    <field name="ChangeAuthor" reuseLastValue="0"/>
    <field name="ChangeDate" reuseLastValue="0"/>
    <field name="CoatingGroup" reuseLastValue="0"/>
    <field name="CoatingType" reuseLastValue="0"/>
    <field name="ContainerType" reuseLastValue="0"/>
    <field name="CreateAuthor" reuseLastValue="0"/>
    <field name="CreateDate" reuseLastValue="0"/>
    <field name="EndDate" reuseLastValue="0"/>
    <field name="FileList" reuseLastValue="0"/>
    <field name="InYard" reuseLastValue="0"/>
    <field name="IsDiffHeightMark" reuseLastValue="0"/>
    <field name="IsSeparateGarbageCollection" reuseLastValue="0"/>
    <field name="MafsTypeList" reuseLastValue="0"/>
    <field name="NoCalc" reuseLastValue="0"/>
    <field name="ObjectId" reuseLastValue="0"/>
    <field name="OghObjectType" reuseLastValue="0"/>
    <field name="ParentEndDate" reuseLastValue="0"/>
    <field name="ParentObjectId" reuseLastValue="0"/>
    <field name="ParentOghObjectType" reuseLastValue="0"/>
    <field name="ParentRootId" reuseLastValue="0"/>
    <field name="ParentStartDate" reuseLastValue="0"/>
    <field name="RootId" reuseLastValue="0"/>
    <field name="StartDate" reuseLastValue="0"/>
    <field name="TaskGUID" reuseLastValue="0"/>
    <field name="Unad" reuseLastValue="0"/>
    <field name="Unom" reuseLastValue="0"/>
    <field name="fid" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"OghObjectType"</previewExpression>
  <layerGeometryType>0</layerGeometryType>
</qgis>
