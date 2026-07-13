<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.38.0-Grenoble" simplifyLocal="1" hasScaleBasedVisibilityFlag="0" labelsEnabled="0" minScale="100000000" simplifyMaxScale="1" styleCategories="LayerConfiguration|Symbology|Labeling|Fields|Forms|Rendering" simplifyAlgorithm="0" simplifyDrawingTol="1" symbologyReferenceScale="-1" maxScale="0" simplifyDrawingHints="1" readOnly="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <renderer-v2 forceraster="0" type="singleSymbol" symbollevels="0" enableorderby="0" referencescale="-1">
    <symbols>
      <symbol name="0" type="fill" alpha="0.3" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleFill" id="{5f700432-68ef-4990-a2ec-807af88d9cd6}" locked="0">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="color" type="QString" value="255,128,192,255,rgb:1,0.50196078431372548,0.75294117647058822,1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
    </symbols>
    <rotation/>
    <sizescale/>
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
      <symbol name="" type="fill" alpha="1" clip_to_extent="1" frame_rate="10" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" pass="0" class="SimpleFill" id="{e7e3efc8-8418-4c9f-841d-26c22e7441d9}" locked="0">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="color" type="QString" value="0,0,255,255,rgb:0,0,1,1"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="35,35,35,255,rgb:0.13725490196078433,0.13725490196078433,0.13725490196078433,1"/>
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
    <field name="OghObjectType" configurationFlags="NoFlag">
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
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="false"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="__________________________________________70b257ec_a43b_4c62_8f8f_e49945567691"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО) Назначение зданий и сооружений"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;BuildingsType&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Material" configurationFlags="NoFlag">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="false"/>
            <Option name="CompleterMatchFlags" type="int" value="2"/>
            <Option name="Description" type="invalid"/>
            <Option name="DisplayGroupName" type="bool" value="false"/>
            <Option name="FilterExpression" type="invalid"/>
            <Option name="Group" type="invalid"/>
            <Option name="Key" type="QString" value="Code"/>
            <Option name="Layer" type="QString" value="_____________________0939f4d7_83eb_4271_bbc2_c41b13c21f29"/>
            <Option name="LayerName" type="QString" value="Справочник (ДТ/ОО/ОДХ) Материалы"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;Material&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="Name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="Area" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="AbutmentTypeList" configurationFlags="NoFlag">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
    <alias name="Назначение" field="BuildingsType" index="6"/>
    <alias name="Материал" field="Material" index="7"/>
    <alias name="Площадь" field="Area" index="8"/>
    <alias name="" field="AbutmentTypeList" index="9"/>
    <alias name="UNOM" field="Unom" index="10"/>
    <alias name="UNAD" field="Unad" index="11"/>
    <alias name="" field="FileList" index="12"/>
    <alias name="Не учитывать" field="NoCalc" index="13"/>
    <alias name="Разновысотные отметки" field="IsDiffHeightMark" index="14"/>
    <alias name="" field="ParentOghObjectType" index="15"/>
    <alias name="" field="ParentObjectId" index="16"/>
    <alias name="" field="ParentRootId" index="17"/>
    <alias name="" field="ParentStartDate" index="18"/>
    <alias name="" field="ParentEndDate" index="19"/>
  </aliases>
  <splitPolicies>
    <policy field="fid" policy="Duplicate"/>
    <policy field="OghObjectType" policy="Duplicate"/>
    <policy field="ObjectId" policy="Duplicate"/>
    <policy field="RootId" policy="Duplicate"/>
    <policy field="StartDate" policy="Duplicate"/>
    <policy field="EndDate" policy="Duplicate"/>
    <policy field="BuildingsType" policy="Duplicate"/>
    <policy field="Material" policy="Duplicate"/>
    <policy field="Area" policy="Duplicate"/>
    <policy field="AbutmentTypeList" policy="Duplicate"/>
    <policy field="Unom" policy="Duplicate"/>
    <policy field="Unad" policy="Duplicate"/>
    <policy field="FileList" policy="Duplicate"/>
    <policy field="NoCalc" policy="Duplicate"/>
    <policy field="IsDiffHeightMark" policy="Duplicate"/>
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
    <policy field="BuildingsType" policy="Duplicate"/>
    <policy field="Material" policy="Duplicate"/>
    <policy field="Area" policy="Duplicate"/>
    <policy field="AbutmentTypeList" policy="Duplicate"/>
    <policy field="Unom" policy="Duplicate"/>
    <policy field="Unad" policy="Duplicate"/>
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
    <default field="fid" expression="" applyOnUpdate="0"/>
    <default field="OghObjectType" expression="" applyOnUpdate="0"/>
    <default field="ObjectId" expression="" applyOnUpdate="0"/>
    <default field="RootId" expression="" applyOnUpdate="0"/>
    <default field="StartDate" expression="" applyOnUpdate="0"/>
    <default field="EndDate" expression="" applyOnUpdate="0"/>
    <default field="BuildingsType" expression="" applyOnUpdate="0"/>
    <default field="Material" expression="" applyOnUpdate="0"/>
    <default field="Area" expression="" applyOnUpdate="0"/>
    <default field="AbutmentTypeList" expression="" applyOnUpdate="0"/>
    <default field="Unom" expression="" applyOnUpdate="0"/>
    <default field="Unad" expression="" applyOnUpdate="0"/>
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
    <constraint exp_strength="0" field="fid" notnull_strength="1" constraints="3" unique_strength="1"/>
    <constraint exp_strength="0" field="OghObjectType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ObjectId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="RootId" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="StartDate" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="EndDate" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="BuildingsType" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Material" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Area" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="AbutmentTypeList" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Unom" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Unad" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="FileList" notnull_strength="0" constraints="0" unique_strength="0"/>
    <constraint exp_strength="0" field="NoCalc" notnull_strength="0" constraints="0" unique_strength="0"/>
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
    <constraint field="BuildingsType" exp="" desc=""/>
    <constraint field="Material" exp="" desc=""/>
    <constraint field="Area" exp="" desc=""/>
    <constraint field="AbutmentTypeList" exp="" desc=""/>
    <constraint field="Unom" exp="" desc=""/>
    <constraint field="Unad" exp="" desc=""/>
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
    <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
      <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField name="RootId" showLabel="1" verticalStretch="0" index="3" horizontalStretch="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer name="Назначение" visibilityExpressionEnabled="0" type="GroupBox" showLabel="1" verticalStretch="0" groupBox="1" collapsedExpression="" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" columnCount="2" collapsed="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="BuildingsType" showLabel="1" verticalStretch="0" index="6" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer name="Параметры" visibilityExpressionEnabled="0" type="GroupBox" showLabel="1" verticalStretch="0" groupBox="1" collapsedExpression="" horizontalStretch="0" collapsedExpressionEnabled="0" visibilityExpression="" columnCount="3" collapsed="0">
      <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
        <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField name="Unom" showLabel="1" verticalStretch="0" index="10" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Unad" showLabel="1" verticalStretch="0" index="11" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Material" showLabel="1" verticalStretch="0" index="7" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="Area" showLabel="1" verticalStretch="0" index="8" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="NoCalc" showLabel="1" verticalStretch="0" index="13" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField name="IsDiffHeightMark" showLabel="1" verticalStretch="0" index="14" horizontalStretch="0">
        <labelStyle overrideLabelColor="0" overrideLabelFont="0" labelColor="0,0,0,255,rgb:0,0,0,1">
          <labelFont underline="0" bold="0" italic="0" strikethrough="0" style="" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
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
    <field name="AbutmentTypeList" editable="1"/>
    <field name="AddressList" editable="1"/>
    <field name="Area" editable="1"/>
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
    <field name="Material" editable="1"/>
    <field name="NoCalc" editable="1"/>
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
    <field name="AbutmentTypeList" labelOnTop="0"/>
    <field name="AddressList" labelOnTop="0"/>
    <field name="Area" labelOnTop="1"/>
    <field name="BuildArea" labelOnTop="1"/>
    <field name="BuildingsType" labelOnTop="1"/>
    <field name="BuildingsTypeSpec" labelOnTop="1"/>
    <field name="ChangeAuthor" labelOnTop="0"/>
    <field name="ChangeDate" labelOnTop="0"/>
    <field name="CreateAuthor" labelOnTop="0"/>
    <field name="CreateDate" labelOnTop="0"/>
    <field name="EndDate" labelOnTop="0"/>
    <field name="FileList" labelOnTop="0"/>
    <field name="FloorQty" labelOnTop="1"/>
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
    <field name="Property" labelOnTop="1"/>
    <field name="RootId" labelOnTop="1"/>
    <field name="StartDate" labelOnTop="0"/>
    <field name="TaskGUID" labelOnTop="0"/>
    <field name="Unad" labelOnTop="1"/>
    <field name="Unom" labelOnTop="1"/>
    <field name="fid" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="AbutmentTypeList" reuseLastValue="0"/>
    <field name="AddressList" reuseLastValue="0"/>
    <field name="Area" reuseLastValue="0"/>
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
    <field name="Material" reuseLastValue="0"/>
    <field name="NoCalc" reuseLastValue="0"/>
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
  <previewExpression>"OghObjectType"</previewExpression>
  <layerGeometryType>2</layerGeometryType>
</qgis>
