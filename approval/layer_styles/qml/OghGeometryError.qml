<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis autoRefreshMode="Disabled" autoRefreshTime="0" simplifyDrawingTol="1" minScale="100000000" simplifyAlgorithm="0" symbologyReferenceScale="-1" version="3.44.1-Solothurn" simplifyLocal="1" simplifyMaxScale="1" maxScale="0" labelsEnabled="0" simplifyDrawingHints="1" styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" hasScaleBasedVisibilityFlag="0">
  <renderer-v2 forceraster="0" enableorderby="0" type="RuleRenderer" symbollevels="0" referencescale="-1">
    <rules key="{4714b20f-3ee9-47e7-afea-a50a2bc79b7e}">
      <rule label="Пересекается со смежным ОГХ" filter="&quot;ERRORS&quot; LIKE '%Пересекается%'" symbol="0" key="{5f2c2edd-a079-4471-98a5-0f1a0141e3dd}"/>
      <rule label="Щель со смежным ОГХ" filter="&quot;ERRORS&quot; LIKE '%Щель%'" symbol="1" key="{9cabfce5-113b-4900-84d7-bdb79a9824e1}"/>
      <rule label="Отличие текущей геометрии ОГХ от данных в рабочих реестрах" filter="&quot;ERRORS&quot; LIKE '%Отличие текущей геометрии ОГХ%'" symbol="2" key="{b20885d9-8318-4c15-ae5e-c2efcee8f918}"/>
    </rules>
    <symbols>
      <symbol name="0" force_rhr="0" alpha="1" type="fill" clip_to_extent="1" is_animated="0" frame_rate="10">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="LinePatternFill" id="{ebc680e0-b83f-4c15-8f87-7fcf04976d35}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="45"/>
            <Option name="clip_mode" type="QString" value="during_render"/>
            <Option name="color" type="QString" value="55,126,184,255,rgb:0.2156863,0.4941176,0.7215686,1"/>
            <Option name="coordinate_reference" type="QString" value="feature"/>
            <Option name="distance" type="QString" value="2"/>
            <Option name="distance_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="distance_unit" type="QString" value="MM"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
          <symbol name="@0@0" force_rhr="0" alpha="1" type="line" clip_to_extent="1" is_animated="0" frame_rate="10">
            <data_defined_properties>
              <Option type="Map">
                <Option name="name" type="QString" value=""/>
                <Option name="properties"/>
                <Option name="type" type="QString" value="collection"/>
              </Option>
            </data_defined_properties>
            <layer enabled="1" pass="0" class="SimpleLine" id="{278b042c-16ed-474a-9551-787d7ec9343c}" locked="0">
              <Option type="Map">
                <Option name="align_dash_pattern" type="QString" value="0"/>
                <Option name="capstyle" type="QString" value="square"/>
                <Option name="customdash" type="QString" value="5;2"/>
                <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="customdash_unit" type="QString" value="MM"/>
                <Option name="dash_pattern_offset" type="QString" value="0"/>
                <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
                <Option name="draw_inside_polygon" type="QString" value="0"/>
                <Option name="joinstyle" type="QString" value="bevel"/>
                <Option name="line_color" type="QString" value="228,26,28,255,rgb:0.8941176,0.1019608,0.1098039,1"/>
                <Option name="line_style" type="QString" value="solid"/>
                <Option name="line_width" type="QString" value="0.3"/>
                <Option name="line_width_unit" type="QString" value="MM"/>
                <Option name="offset" type="QString" value="0"/>
                <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="offset_unit" type="QString" value="MM"/>
                <Option name="ring_filter" type="QString" value="0"/>
                <Option name="trim_distance_end" type="QString" value="0"/>
                <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="trim_distance_end_unit" type="QString" value="MM"/>
                <Option name="trim_distance_start" type="QString" value="0"/>
                <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="trim_distance_start_unit" type="QString" value="MM"/>
                <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
                <Option name="use_custom_dash" type="QString" value="0"/>
                <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
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
        </layer>
        <layer enabled="1" pass="0" class="SimpleLine" id="{870c3007-07e3-4a07-b812-f5bd0238ad50}" locked="0">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="228,26,28,255,rgb:0.8941176,0.1019608,0.1098039,1"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.46"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
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
      <symbol name="1" force_rhr="0" alpha="1" type="fill" clip_to_extent="1" is_animated="0" frame_rate="10">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="LinePatternFill" id="{0caed56b-a8b0-4e33-9e40-a63935d838be}" locked="0">
          <Option type="Map">
            <Option name="angle" type="QString" value="45"/>
            <Option name="clip_mode" type="QString" value="during_render"/>
            <Option name="color" type="QString" value="55,126,184,255,rgb:0.2156863,0.4941176,0.7215686,1"/>
            <Option name="coordinate_reference" type="QString" value="feature"/>
            <Option name="distance" type="QString" value="2"/>
            <Option name="distance_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="distance_unit" type="QString" value="MM"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
          </Option>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
          <symbol name="@1@0" force_rhr="0" alpha="1" type="line" clip_to_extent="1" is_animated="0" frame_rate="10">
            <data_defined_properties>
              <Option type="Map">
                <Option name="name" type="QString" value=""/>
                <Option name="properties"/>
                <Option name="type" type="QString" value="collection"/>
              </Option>
            </data_defined_properties>
            <layer enabled="1" pass="0" class="SimpleLine" id="{db03b35f-f5ad-42b7-959b-624a67744277}" locked="0">
              <Option type="Map">
                <Option name="align_dash_pattern" type="QString" value="0"/>
                <Option name="capstyle" type="QString" value="square"/>
                <Option name="customdash" type="QString" value="5;2"/>
                <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="customdash_unit" type="QString" value="MM"/>
                <Option name="dash_pattern_offset" type="QString" value="0"/>
                <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
                <Option name="draw_inside_polygon" type="QString" value="0"/>
                <Option name="joinstyle" type="QString" value="bevel"/>
                <Option name="line_color" type="QString" value="74,95,175,255,rgb:0.2901961,0.372549,0.6862745,1"/>
                <Option name="line_style" type="QString" value="solid"/>
                <Option name="line_width" type="QString" value="0.3"/>
                <Option name="line_width_unit" type="QString" value="MM"/>
                <Option name="offset" type="QString" value="0"/>
                <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="offset_unit" type="QString" value="MM"/>
                <Option name="ring_filter" type="QString" value="0"/>
                <Option name="trim_distance_end" type="QString" value="0"/>
                <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="trim_distance_end_unit" type="QString" value="MM"/>
                <Option name="trim_distance_start" type="QString" value="0"/>
                <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
                <Option name="trim_distance_start_unit" type="QString" value="MM"/>
                <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
                <Option name="use_custom_dash" type="QString" value="0"/>
                <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
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
        </layer>
        <layer enabled="1" pass="0" class="SimpleLine" id="{186dd8ab-5f26-444f-993a-44bdf31221f2}" locked="0">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="74,95,175,255,rgb:0.2901961,0.372549,0.6862745,1"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.46"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
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
      <symbol name="2" force_rhr="0" alpha="1" type="fill" clip_to_extent="1" is_animated="0" frame_rate="10">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleLine" id="{55807b6a-bb10-4598-be1b-9802cedb0564}" locked="0">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="10"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MapUnit"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="0,46,255,255,rgb:0,0.1803922,1,1"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.1"/>
            <Option name="line_width_unit" type="QString" value="MapUnit"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
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
      <symbol name="" force_rhr="0" alpha="1" type="fill" clip_to_extent="1" is_animated="0" frame_rate="10">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleFill" id="{0d1d55b4-5686-4952-88bf-147493cece57}" locked="0">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="color" type="QString" value="0,0,255,255,rgb:0,0,1,1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0.26"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="style" type="QString" value="solid"/>
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
  <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
    <activeChecks/>
    <checkConfiguration type="Map">
      <Option name="QgsGeometryGapCheck" type="Map">
        <Option name="allowedGapsBuffer" type="double" value="0"/>
        <Option name="allowedGapsEnabled" type="bool" value="false"/>
        <Option name="allowedGapsLayer" type="QString" value=""/>
      </Option>
    </checkConfiguration>
  </geometryOptions>
  <fieldConfiguration>
    <field name="fid" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
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
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="ERRORS" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="true"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="NODE" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="" index="0" field="fid"/>
    <alias name="" index="1" field="ObjectId"/>
    <alias name="Идентификатор ОГХ (RootId)" index="2" field="RootId"/>
    <alias name="" index="3" field="ERRORS"/>
    <alias name="" index="4" field="NODE"/>
  </aliases>
  <defaults>
    <default expression="" applyOnUpdate="0" field="fid"/>
    <default expression="" applyOnUpdate="0" field="ObjectId"/>
    <default expression="" applyOnUpdate="0" field="RootId"/>
    <default expression="" applyOnUpdate="0" field="ERRORS"/>
    <default expression="" applyOnUpdate="0" field="NODE"/>
  </defaults>
  <constraints>
    <constraint constraints="3" exp_strength="0" unique_strength="1" notnull_strength="1" field="fid"/>
    <constraint constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0" field="ObjectId"/>
    <constraint constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0" field="RootId"/>
    <constraint constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0" field="ERRORS"/>
    <constraint constraints="0" exp_strength="0" unique_strength="0" notnull_strength="0" field="NODE"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" exp="" desc=""/>
    <constraint field="ObjectId" exp="" desc=""/>
    <constraint field="RootId" exp="" desc=""/>
    <constraint field="ERRORS" exp="" desc=""/>
    <constraint field="NODE" exp="" desc=""/>
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
    <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
      <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
    </labelStyle>
    <attributeEditorAction name="{dce15d30-ca5f-4957-a48a-b73e718dfb23}" showLabel="1" horizontalStretch="0" ActionUUID="{dce15d30-ca5f-4957-a48a-b73e718dfb23}" verticalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      </labelStyle>
    </attributeEditorAction>
    <attributeEditorField name="fid" showLabel="1" horizontalStretch="0" index="0" verticalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorField name="RootId" showLabel="1" horizontalStretch="0" index="2" verticalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorField name="ObjectId" showLabel="1" horizontalStretch="0" index="1" verticalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorField name="ERRORS" showLabel="1" horizontalStretch="0" index="3" verticalStretch="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont strikethrough="0" underline="0" bold="0" italic="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      </labelStyle>
    </attributeEditorField>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="ERRORS"/>
    <field editable="1" name="NODE"/>
    <field editable="1" name="ObjectId"/>
    <field editable="1" name="RootId"/>
    <field editable="1" name="fid"/>
  </editable>
  <labelOnTop>
    <field name="ERRORS" labelOnTop="0"/>
    <field name="NODE" labelOnTop="0"/>
    <field name="ObjectId" labelOnTop="0"/>
    <field name="RootId" labelOnTop="0"/>
    <field name="fid" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="ERRORS" reuseLastValue="0"/>
    <field name="NODE" reuseLastValue="0"/>
    <field name="ObjectId" reuseLastValue="0"/>
    <field name="RootId" reuseLastValue="0"/>
    <field name="fid" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <mapTip enabled="1"></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
