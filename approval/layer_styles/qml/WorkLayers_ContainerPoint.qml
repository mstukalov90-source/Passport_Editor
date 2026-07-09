<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis autoRefreshMode="Disabled" labelsEnabled="0" simplifyDrawingHints="0" symbologyReferenceScale="-1" maxScale="0" simplifyDrawingTol="1" autoRefreshTime="0" simplifyMaxScale="1" version="3.44.8-Solothurn" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyLocal="1" simplifyAlgorithm="0" minScale="100000000" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" referencescale="-1" symbollevels="0">
    <rules key="{d96c836c-97ea-4eeb-9e21-850cceffd6d8}">
      <rule label="Точки привязки" symbol="0" key="{4f30d3b2-d937-4607-aa92-a5187acf5e56}" checkstate="0" filter="&quot;fid&quot; is not NULL"/>
      <rule label="Бункерная площадка" symbol="1" key="{f4940b5c-6d96-4702-8388-37fa2885ffb5}" filter="&quot;ContainerType&quot; = 'bunker_area'"/>
      <rule label="Контейнерная площадка" symbol="2" key="{b85339a7-68d7-450d-bc75-89905d582cd3}" filter="&quot;ContainerType&quot; = 'container_area'"/>
      <rule label="Стационарный павильон для РСО" symbol="3" key="{79dfc16c-6017-4cfc-9694-6375ecfe46e4}" filter="&quot;ContainerType&quot; = 'pavilion_rso'"/>
      <rule label="Площадка для выкатных контейнеров" symbol="4" key="{bf5e5a6d-5d33-41fd-943b-44b87bef9a2f}" filter="&quot;ContainerType&quot; = 'roll_container_area'"/>
      <rule label="Площадка для выкатных контейнеров (для полезных компонентов)" symbol="5" key="{0de37976-4b90-44e8-997e-fc096a461f9f}" filter="&quot;ContainerType&quot; = 'roll_container_useful_components_area'"/>
      <rule label="Нет данных" symbol="6" key="{edfc28de-d23c-4af5-97ee-f1d552a5f95c}" filter="ELSE"/>
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="1" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="128,64,0,255,rgb:0.5019608,0.2509804,0,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="square" name="name"/>
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="2" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="128,64,0,255,rgb:0.5019608,0.2509804,0,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="square" name="name"/>
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="3" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{949d43d1-bf52-4ebd-b7c5-a832b08b98e8}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="128,64,0,255,rgb:0.5019608,0.2509804,0,1" name="color"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="square" name="name"/>
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
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="4" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{ab020b05-8790-468b-9415-0f28ddeeb109}" locked="0" pass="0" class="SvgMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="128,64,0,255,rgb:0.5019608,0.2509804,0,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="square" name="name"/>
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
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Емкости и павильоны для сбора твердых коммунальных отходов_Площадка для выкатных контейнеров.svg'" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="5" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{ab3c042d-c09a-4391-b352-db1507892037}" locked="0" pass="0" class="SvgMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="128,64,0,255,rgb:0.5019608,0.2509804,0,1" name="color"/>
            <Option type="QString" value="0" name="fixedAspectRatio"/>
            <Option type="QString" value="1" name="horizontal_anchor_point"/>
            <Option type="QString" value="square" name="name"/>
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
            <Option type="QString" value="1" name="vertical_anchor_point"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" value="" name="name"/>
              <Option type="Map" name="properties">
                <Option type="Map" name="name">
                  <Option type="bool" value="true" name="active"/>
                  <Option type="QString" value="@MggtAsuPluginPath + @MggtAsuSvgPath + '/Емкости и павильоны для сбора твердых коммунальных отходов_Площадка для выкатных контейнеров.svg'" name="expression"/>
                  <Option type="int" value="3" name="type"/>
                </Option>
              </Option>
              <Option type="QString" value="collection" name="type"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol frame_rate="10" is_animated="0" force_rhr="0" type="marker" name="6" clip_to_extent="1" alpha="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer id="{3fd23b8e-b037-4726-9f9f-20c750d6e185}" locked="0" pass="0" class="SimpleMarker" enabled="1">
          <Option type="Map">
            <Option type="QString" value="0" name="angle"/>
            <Option type="QString" value="square" name="cap_style"/>
            <Option type="QString" value="255,1,56,255,rgb:1,0.0039216,0.2196078,1" name="color"/>
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
            <Option type="QString" value="3" name="size"/>
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
        <layer id="{bfe50b4e-4652-4444-881e-e777d5e908d3}" locked="0" pass="0" class="SimpleMarker" enabled="1">
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
          <Option/>
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
    <field configurationFlags="NoFlag" name="ContainerType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="____________________________8b50359c_417c_42a0_b0b8_57125d614ce0" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Типы МСО" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ContainerType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="true" name="OrderByKey"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="QString" value="&quot;CoatingGroup&quot; = current_value('CoatingGroup') and &#xa;CASE &#xa;&#x9;WHEN @MggtAsuTaskType=1 THEN &quot;AllowedInDT&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=2 THEN &quot;AllowedInODH&quot; &#xa;&#x9;WHEN @MggtAsuTaskType=3 THEN &quot;AllowedInOO&quot;&#xa;&#x9;WHEN @MggtAsuTaskType=4 THEN &quot;AllowedInTOP&quot; &#xa;&#x9;ELSE False&#xa;END" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_____________________________________f4d82cc5_258a_434e_a76c_d0ee89fdd33c" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО/ОДХ) Виды покрытий" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CoatingType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="true" name="OrderByKey"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="CoatingGroup">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="int" value="2" name="CompleterMatchFlags"/>
            <Option type="invalid" name="Description"/>
            <Option type="bool" value="false" name="DisplayGroupName"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="invalid" name="Group"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_______________________________________67a73554_3d05_42b4_bc4b_413dd73449d2" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО/ОДХ) Группы покрытий" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='postgres' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;CoatingTypeGroup&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByDescending"/>
            <Option type="bool" value="false" name="OrderByField"/>
            <Option type="invalid" name="OrderByFieldName"/>
            <Option type="bool" value="true" name="OrderByKey"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Unom">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Unad">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="double" value="1.7976931348623157e+308" name="Max"/>
            <Option type="double" value="-1.7976931348623157e+308" name="Min"/>
            <Option type="int" value="2" name="Precision"/>
            <Option type="double" value="1" name="Step"/>
            <Option type="QString" value="SpinBox" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="AbutmentType">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="invalid" name="Description"/>
            <Option type="invalid" name="FilterExpression"/>
            <Option type="QString" value="Code" name="Key"/>
            <Option type="QString" value="_______________________________7a494d92_ddeb_4f9a_a84f_44965167d3ce" name="Layer"/>
            <Option type="QString" value="Справочник (ДТ/ОО) Элементы сопряжения" name="LayerName"/>
            <Option type="QString" value="postgres" name="LayerProviderName"/>
            <Option type="QString" value="dbname='mggt_asu' host=192.168.1.34 port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;AbutmentType&quot;" name="LayerSource"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="Name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="AbutmentDistance">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="MafsTypeList">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsSeparateGarbageCollection">
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
    <field configurationFlags="NoFlag" name="InYard">
      <editWidget type="CheckBox">
        <config>
          <Option/>
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
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="M/d/yy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="yyyy-MM-dd HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_format_overwrite"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
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
    <alias index="6" field="ContainerType" name="Тип МСО"/>
    <alias index="7" field="CoatingType" name="Вид покрытия"/>
    <alias index="8" field="CoatingGroup" name="Группа покрытия"/>
    <alias index="9" field="Unom" name="UNOM"/>
    <alias index="10" field="Unad" name="UNAD"/>
    <alias index="11" field="Area" name="Площадь, кв.м."/>
    <alias index="12" field="AbutmentType" name="Элемент сопряжения"/>
    <alias index="13" field="AbutmentDistance" name="Количество, п.м."/>
    <alias index="14" field="MafsTypeList" name=""/>
    <alias index="15" field="IsSeparateGarbageCollection" name="Раздельный сбор мусора"/>
    <alias index="16" field="FileList" name=""/>
    <alias index="17" field="NoCalc" name="Не учитывать"/>
    <alias index="18" field="InYard" name=""/>
    <alias index="19" field="IsDiffHeightMark" name="Разновысотные отметки"/>
    <alias index="20" field="ParentOghObjectType" name=""/>
    <alias index="21" field="ParentObjectId" name=""/>
    <alias index="22" field="ParentRootId" name=""/>
    <alias index="23" field="ParentStartDate" name=""/>
    <alias index="24" field="ParentEndDate" name=""/>
    <alias index="25" field="CreateDate" name=""/>
    <alias index="26" field="CreateAuthor" name=""/>
    <alias index="27" field="ChangeDate" name=""/>
    <alias index="28" field="ChangeAuthor" name=""/>
    <alias index="29" field="TaskGUID" name=""/>
  </aliases>
  <splitPolicies>
    <policy field="RootId" policy="DefaultValue"/>
    <policy field="ContainerType" policy="DefaultValue"/>
    <policy field="CoatingType" policy="DefaultValue"/>
    <policy field="CoatingGroup" policy="DefaultValue"/>
    <policy field="Unom" policy="DefaultValue"/>
    <policy field="Unad" policy="DefaultValue"/>
    <policy field="Area" policy="DefaultValue"/>
    <policy field="AbutmentType" policy="DefaultValue"/>
    <policy field="AbutmentDistance" policy="DefaultValue"/>
    <policy field="IsSeparateGarbageCollection" policy="DefaultValue"/>
    <policy field="NoCalc" policy="DefaultValue"/>
    <policy field="IsDiffHeightMark" policy="DefaultValue"/>
    <policy field="ParentRootId" policy="DefaultValue"/>
  </splitPolicies>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="OghObjectType"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="StartDate"/>
    <default expression="" applyOnUpdate="0" field="EndDate"/>
    <default expression="" applyOnUpdate="0" field="ContainerType"/>
    <default expression="" applyOnUpdate="0" field="CoatingType"/>
    <default expression="" applyOnUpdate="0" field="CoatingGroup"/>
    <default expression="" applyOnUpdate="0" field="Unom"/>
    <default expression="" applyOnUpdate="0" field="Unad"/>
    <default expression="" applyOnUpdate="0" field="Area"/>
    <default expression="" applyOnUpdate="0" field="AbutmentType"/>
    <default expression="" applyOnUpdate="0" field="AbutmentDistance"/>
    <default expression="" applyOnUpdate="0" field="MafsTypeList"/>
    <default expression="" applyOnUpdate="0" field="IsSeparateGarbageCollection"/>
    <default expression="" applyOnUpdate="0" field="FileList"/>
    <default expression="" applyOnUpdate="0" field="NoCalc"/>
    <default expression="" applyOnUpdate="0" field="InYard"/>
    <default expression="" applyOnUpdate="0" field="IsDiffHeightMark"/>
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
  </defaults>
  <constraints>
    <constraint exp_strength="0" notnull_strength="1" unique_strength="1" constraints="3" field="fid"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="OghObjectType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ObjectId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="RootId"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="StartDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="EndDate"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="ContainerType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CoatingType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="CoatingGroup"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Unom"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Unad"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="Area"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="AbutmentType"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="AbutmentDistance"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="MafsTypeList"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="IsSeparateGarbageCollection"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="FileList"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="NoCalc"/>
    <constraint exp_strength="0" notnull_strength="0" unique_strength="0" constraints="0" field="InYard"/>
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
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="fid"/>
    <constraint desc="" exp="" field="OghObjectType"/>
    <constraint desc="" exp="" field="ObjectId"/>
    <constraint desc="" exp="" field="RootId"/>
    <constraint desc="" exp="" field="StartDate"/>
    <constraint desc="" exp="" field="EndDate"/>
    <constraint desc="" exp="" field="ContainerType"/>
    <constraint desc="" exp="" field="CoatingType"/>
    <constraint desc="" exp="" field="CoatingGroup"/>
    <constraint desc="" exp="" field="Unom"/>
    <constraint desc="" exp="" field="Unad"/>
    <constraint desc="" exp="" field="Area"/>
    <constraint desc="" exp="" field="AbutmentType"/>
    <constraint desc="" exp="" field="AbutmentDistance"/>
    <constraint desc="" exp="" field="MafsTypeList"/>
    <constraint desc="" exp="" field="IsSeparateGarbageCollection"/>
    <constraint desc="" exp="" field="FileList"/>
    <constraint desc="" exp="" field="NoCalc"/>
    <constraint desc="" exp="" field="InYard"/>
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
      <labelFont strikethrough="0" style="" underline="0" description="Sans Serif,9,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
    </labelStyle>
    <attributeEditorField showLabel="1" verticalStretch="0" index="3" horizontalStretch="0" name="RootId">
      <labelStyle labelColor="" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="4" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Назначение">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="6" horizontalStretch="0" name="ContainerType">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="8" horizontalStretch="0" name="CoatingGroup">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="7" horizontalStretch="0" name="CoatingType">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="15" horizontalStretch="0" name="IsSeparateGarbageCollection">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer groupBox="1" showLabel="1" columnCount="5" collapsed="0" verticalStretch="0" collapsedExpressionEnabled="0" type="GroupBox" collapsedExpression="" visibilityExpressionEnabled="0" visibilityExpression="" horizontalStretch="0" name="Параметры">
      <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
        <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
      </labelStyle>
      <attributeEditorField showLabel="1" verticalStretch="0" index="9" horizontalStretch="0" name="Unom">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="10" horizontalStretch="0" name="Unad">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="11" horizontalStretch="0" name="Area">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="17" horizontalStretch="0" name="NoCalc">
        <labelStyle labelColor="0,0,0,255,rgb:0,0,0,1" overrideLabelColor="0" overrideLabelFont="0">
          <labelFont strikethrough="0" style="" underline="0" description="Bitstream Vera Sans,10,-1,5,50,0,0,0,0,0" italic="0" bold="0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField showLabel="1" verticalStretch="0" index="19" horizontalStretch="0" name="IsDiffHeightMark">
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
    <field editable="1" name="AbutmentDistance"/>
    <field editable="1" name="AbutmentType"/>
    <field editable="1" name="AbutmentTypeList"/>
    <field editable="1" name="AddressList"/>
    <field editable="1" name="Area"/>
    <field editable="1" name="ChangeAuthor"/>
    <field editable="1" name="ChangeDate"/>
    <field editable="1" name="CoatingGroup"/>
    <field editable="1" name="CoatingType"/>
    <field editable="1" name="ContainerType"/>
    <field editable="1" name="CreateAuthor"/>
    <field editable="1" name="CreateDate"/>
    <field editable="1" name="EndDate"/>
    <field editable="1" name="FileList"/>
    <field editable="1" name="InYard"/>
    <field editable="1" name="IsDiffHeightMark"/>
    <field editable="1" name="IsSeparateGarbageCollection"/>
    <field editable="1" name="MafsTypeList"/>
    <field editable="1" name="NoCalc"/>
    <field editable="1" name="ObjectId"/>
    <field editable="1" name="OghObjectType"/>
    <field editable="1" name="ParentEndDate"/>
    <field editable="1" name="ParentObjectId"/>
    <field editable="1" name="ParentOghObjectType"/>
    <field editable="1" name="ParentRootId"/>
    <field editable="1" name="ParentStartDate"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="StartDate"/>
    <field editable="1" name="TaskGUID"/>
    <field editable="1" name="Unad"/>
    <field editable="1" name="Unom"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="AbutmentDistance"/>
    <field labelOnTop="1" name="AbutmentType"/>
    <field labelOnTop="0" name="AbutmentTypeList"/>
    <field labelOnTop="0" name="AddressList"/>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CoatingGroup"/>
    <field labelOnTop="1" name="CoatingType"/>
    <field labelOnTop="1" name="ContainerType"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="0" name="FileList"/>
    <field labelOnTop="0" name="InYard"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="IsSeparateGarbageCollection"/>
    <field labelOnTop="0" name="MafsTypeList"/>
    <field labelOnTop="1" name="NoCalc"/>
    <field labelOnTop="0" name="ObjectId"/>
    <field labelOnTop="0" name="OghObjectType"/>
    <field labelOnTop="0" name="ParentEndDate"/>
    <field labelOnTop="0" name="ParentObjectId"/>
    <field labelOnTop="0" name="ParentOghObjectType"/>
    <field labelOnTop="0" name="ParentRootId"/>
    <field labelOnTop="0" name="ParentStartDate"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="Unad"/>
    <field labelOnTop="1" name="Unom"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="AbutmentDistance"/>
    <field reuseLastValue="0" name="AbutmentType"/>
    <field reuseLastValue="0" name="AbutmentTypeList"/>
    <field reuseLastValue="0" name="AddressList"/>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CoatingGroup"/>
    <field reuseLastValue="0" name="CoatingType"/>
    <field reuseLastValue="0" name="ContainerType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FileList"/>
    <field reuseLastValue="0" name="InYard"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsSeparateGarbageCollection"/>
    <field reuseLastValue="0" name="MafsTypeList"/>
    <field reuseLastValue="0" name="NoCalc"/>
    <field reuseLastValue="0" name="ObjectId"/>
    <field reuseLastValue="0" name="OghObjectType"/>
    <field reuseLastValue="0" name="ParentEndDate"/>
    <field reuseLastValue="0" name="ParentObjectId"/>
    <field reuseLastValue="0" name="ParentOghObjectType"/>
    <field reuseLastValue="0" name="ParentRootId"/>
    <field reuseLastValue="0" name="ParentStartDate"/>
    <field reuseLastValue="0" name="RootId"/>
    <field reuseLastValue="0" name="StartDate"/>
    <field reuseLastValue="0" name="TaskGUID"/>
    <field reuseLastValue="0" name="Unad"/>
    <field reuseLastValue="0" name="Unom"/>
    <field reuseLastValue="0" name="fid"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
