<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Labeling|Fields|Forms|MapTips|Rendering|GeometryOptions" simplifyDrawingHints="1" hasScaleBasedVisibilityFlag="0" autoRefreshMode="Disabled" simplifyAlgorithm="0" maxScale="0" symbologyReferenceScale="-1" version="3.44.1-Solothurn" simplifyMaxScale="1" minScale="100000000" simplifyDrawingTol="1" simplifyLocal="1" labelsEnabled="0" autoRefreshTime="0">
  <renderer-v2 referencescale="-1" type="RuleRenderer" symbollevels="0" forceraster="0" enableorderby="0">
    <rules key="{6589b49e-0cb9-4a5f-8976-a462a7fea61c}">
      <rule label="Автомат для приема банок" key="{1e01034d-08ba-4e78-b5c4-7b5ab5970ca6}" symbol="0"/>
    </rules>
    <symbols>
      <symbol type="fill" alpha="1" frame_rate="10" name="0" clip_to_extent="1" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" class="SimpleFill" enabled="1" id="{6ea688a6-4fdc-4c02-9869-43b4407e03e3}" pass="0">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" type="QString" name="border_width_map_unit_scale"/>
            <Option value="255,255,0,255,rgb:1,1,0,1" type="QString" name="color"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0.26" type="QString" name="outline_width"/>
            <Option value="MM" type="QString" name="outline_width_unit"/>
            <Option value="solid" type="QString" name="style"/>
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
      <symbol type="fill" alpha="1" frame_rate="10" name="" clip_to_extent="1" is_animated="0" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option value="" type="QString" name="name"/>
            <Option name="properties"/>
            <Option value="collection" type="QString" name="type"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" class="SimpleFill" enabled="1" id="{f890ee3f-9853-4682-b6d7-511e23044de6}" pass="0">
          <Option type="Map">
            <Option value="3x:0,0,0,0,0,0" type="QString" name="border_width_map_unit_scale"/>
            <Option value="0,0,255,255,rgb:0,0,1,1" type="QString" name="color"/>
            <Option value="bevel" type="QString" name="joinstyle"/>
            <Option value="0,0" type="QString" name="offset"/>
            <Option value="3x:0,0,0,0,0,0" type="QString" name="offset_map_unit_scale"/>
            <Option value="MM" type="QString" name="offset_unit"/>
            <Option value="35,35,35,255,rgb:0.1372549,0.1372549,0.1372549,1" type="QString" name="outline_color"/>
            <Option value="solid" type="QString" name="outline_style"/>
            <Option value="0.26" type="QString" name="outline_width"/>
            <Option value="MM" type="QString" name="outline_width_unit"/>
            <Option value="solid" type="QString" name="style"/>
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
    <checkConfiguration type="Map">
      <Option type="Map" name="QgsGeometryGapCheck">
        <Option value="0" type="double" name="allowedGapsBuffer"/>
        <Option value="false" type="bool" name="allowedGapsEnabled"/>
        <Option value="" type="QString" name="allowedGapsLayer"/>
      </Option>
    </checkConfiguration>
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
    <field configurationFlags="NoFlag" name="ConvElementType">
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
            <Option value="____________________________________40a03fbc_4602_4b85_a91b_06c0564cf08c" type="QString" name="Layer"/>
            <Option value="Справочник (ОДХ) Тип элемента обустройста" type="QString" name="LayerName"/>
            <Option value="postgres" type="QString" name="LayerProviderName"/>
            <Option value="dbname='mggt_asu' host=localhost port=5432 user='gisproject' key='fid' checkPrimaryKeyUnicity='1' table=&quot;cls&quot;.&quot;ConvElementType&quot;" type="QString" name="LayerSource"/>
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
            <Option value="______________________________________bfa58402_4130_44f4_b1b3_81a7835c4b3a" type="QString" name="Layer"/>
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
    <field configurationFlags="NoFlag" name="BordBegin">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="-1e+06" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="BordEnd">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="-1e+06" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Property">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="Area">
      <editWidget type="Range">
        <config>
          <Option type="Map">
            <Option value="true" type="bool" name="AllowNull"/>
            <Option value="1e+06" type="double" name="Max"/>
            <Option value="0" type="double" name="Min"/>
            <Option value="2" type="int" name="Precision"/>
            <Option value="1" type="double" name="Step"/>
            <Option value="SpinBox" type="QString" name="Style"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="NoFlag" name="IsObjectArea">
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
    <field configurationFlags="NoFlag" name="Placement">
      <editWidget type="TextEdit">
        <config>
          <Option/>
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
    <field configurationFlags="NoFlag" name="ParentEndDate">
      <editWidget type="DateTime">
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
    <alias index="6" field="ConvElementType" name="Тип МАФ"/>
    <alias index="7" field="OdhSide" name="Сторона"/>
    <alias index="8" field="OdhAxis" name="Ось"/>
    <alias index="9" field="BordBegin" name="Начало"/>
    <alias index="10" field="BordEnd" name="Конец"/>
    <alias index="11" field="Property" name="Краткая характеристика"/>
    <alias index="12" field="Area" name="Площадь"/>
    <alias index="13" field="IsObjectArea" name="Входит в общую площадь ОДХ"/>
    <alias index="14" field="Placement" name=""/>
    <alias index="15" field="IdRfid" name="ID RFID метки"/>
    <alias index="16" field="Description" name="Примечание"/>
    <alias index="17" field="ParentOghObjectType" name=""/>
    <alias index="18" field="ParentObjectId" name=""/>
    <alias index="19" field="ParentRootId" name=""/>
    <alias index="20" field="ParentStartDate" name=""/>
    <alias index="21" field="ParentEndDate" name=""/>
  </aliases>
  <defaults>
    <default expression="" field="fid" applyOnUpdate="0"/>
    <default expression="" field="OghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ObjectId" applyOnUpdate="0"/>
    <default expression="" field="RootId" applyOnUpdate="0"/>
    <default expression="" field="StartDate" applyOnUpdate="0"/>
    <default expression="" field="EndDate" applyOnUpdate="0"/>
    <default expression="" field="ConvElementType" applyOnUpdate="0"/>
    <default expression="" field="OdhSide" applyOnUpdate="0"/>
    <default expression="" field="OdhAxis" applyOnUpdate="0"/>
    <default expression="" field="BordBegin" applyOnUpdate="0"/>
    <default expression="" field="BordEnd" applyOnUpdate="0"/>
    <default expression="" field="Property" applyOnUpdate="0"/>
    <default expression="" field="Area" applyOnUpdate="0"/>
    <default expression="" field="IsObjectArea" applyOnUpdate="0"/>
    <default expression="" field="Placement" applyOnUpdate="0"/>
    <default expression="" field="IdRfid" applyOnUpdate="0"/>
    <default expression="" field="Description" applyOnUpdate="0"/>
    <default expression="" field="ParentOghObjectType" applyOnUpdate="0"/>
    <default expression="" field="ParentObjectId" applyOnUpdate="0"/>
    <default expression="" field="ParentRootId" applyOnUpdate="0"/>
    <default expression="" field="ParentStartDate" applyOnUpdate="0"/>
    <default expression="" field="ParentEndDate" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint unique_strength="1" constraints="3" field="fid" notnull_strength="1" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="OghObjectType" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ObjectId" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="RootId" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="StartDate" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="EndDate" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ConvElementType" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="OdhSide" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="OdhAxis" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="BordBegin" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="BordEnd" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="Property" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="Area" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="IsObjectArea" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="Placement" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="IdRfid" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="Description" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ParentOghObjectType" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ParentObjectId" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ParentRootId" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ParentStartDate" notnull_strength="0" exp_strength="0"/>
    <constraint unique_strength="0" constraints="0" field="ParentEndDate" notnull_strength="0" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="fid" desc="" exp=""/>
    <constraint field="OghObjectType" desc="" exp=""/>
    <constraint field="ObjectId" desc="" exp=""/>
    <constraint field="RootId" desc="" exp=""/>
    <constraint field="StartDate" desc="" exp=""/>
    <constraint field="EndDate" desc="" exp=""/>
    <constraint field="ConvElementType" desc="" exp=""/>
    <constraint field="OdhSide" desc="" exp=""/>
    <constraint field="OdhAxis" desc="" exp=""/>
    <constraint field="BordBegin" desc="" exp=""/>
    <constraint field="BordEnd" desc="" exp=""/>
    <constraint field="Property" desc="" exp=""/>
    <constraint field="Area" desc="" exp=""/>
    <constraint field="IsObjectArea" desc="" exp=""/>
    <constraint field="Placement" desc="" exp=""/>
    <constraint field="IdRfid" desc="" exp=""/>
    <constraint field="Description" desc="" exp=""/>
    <constraint field="ParentOghObjectType" desc="" exp=""/>
    <constraint field="ParentObjectId" desc="" exp=""/>
    <constraint field="ParentRootId" desc="" exp=""/>
    <constraint field="ParentStartDate" desc="" exp=""/>
    <constraint field="ParentEndDate" desc="" exp=""/>
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
      <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
    </labelStyle>
    <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="3" name="RootId">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorField>
    <attributeEditorContainer collapsedExpression="" horizontalStretch="0" showLabel="1" verticalStretch="0" type="GroupBox" groupBox="1" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" collapsed="0" collapsedExpressionEnabled="0" name="Назначение">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="6" name="ConvElementType">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer collapsedExpression="" horizontalStretch="0" showLabel="1" verticalStretch="0" type="Tab" groupBox="0" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" collapsed="0" collapsedExpressionEnabled="0" name="Привязка">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="8" name="OdhAxis">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="7" name="OdhSide">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="9" name="BordBegin">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="10" name="BordEnd">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorContainer collapsedExpression="" horizontalStretch="0" showLabel="1" verticalStretch="0" type="GroupBox" groupBox="1" visibilityExpressionEnabled="0" visibilityExpression="" columnCount="4" collapsed="0" collapsedExpressionEnabled="0" name="Параметры">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="13" name="IsObjectArea">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="12" name="Area">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="15" name="IdRfid">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="11" name="Property">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
      <attributeEditorField horizontalStretch="0" showLabel="1" verticalStretch="0" index="16" name="Description">
        <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
          <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
        </labelStyle>
      </attributeEditorField>
    </attributeEditorContainer>
    <attributeEditorSpacerElement horizontalStretch="0" showLabel="0" verticalStretch="0" name="Spacer Widget" drawLine="0">
      <labelStyle overrideLabelColor="0" labelColor="" overrideLabelFont="0">
        <labelFont italic="0" style="" bold="0" underline="0" strikethrough="0" description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0"/>
      </labelStyle>
    </attributeEditorSpacerElement>
  </attributeEditorForm>
  <editable>
    <field name="Area" editable="1"/>
    <field name="AutoCleanArea" editable="1"/>
    <field name="AxisGeometry" editable="1"/>
    <field name="BordBegin" editable="1"/>
    <field name="BordEnd" editable="1"/>
    <field name="ChangeAuthor" editable="1"/>
    <field name="ChangeDate" editable="1"/>
    <field name="CoatingGroup" editable="1"/>
    <field name="CoatingType" editable="1"/>
    <field name="ConvElementType" editable="1"/>
    <field name="CreateAuthor" editable="1"/>
    <field name="CreateDate" editable="1"/>
    <field name="Description" editable="1"/>
    <field name="Distance" editable="1"/>
    <field name="EndDate" editable="1"/>
    <field name="FlatElementType" editable="1"/>
    <field name="IdRfid" editable="1"/>
    <field name="IsDiffHeightMark" editable="1"/>
    <field name="IsObjectArea" editable="1"/>
    <field name="ManualCleanArea" editable="1"/>
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
    <field name="Property" editable="1"/>
    <field name="RootId" editable="1"/>
    <field name="StartDate" editable="1"/>
    <field name="TaskGUID" editable="1"/>
    <field name="WidthBegin" editable="1"/>
    <field name="WidthEnd" editable="1"/>
    <field name="fid" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="1" name="Area"/>
    <field labelOnTop="1" name="AutoCleanArea"/>
    <field labelOnTop="0" name="AxisGeometry"/>
    <field labelOnTop="1" name="BordBegin"/>
    <field labelOnTop="1" name="BordEnd"/>
    <field labelOnTop="0" name="ChangeAuthor"/>
    <field labelOnTop="0" name="ChangeDate"/>
    <field labelOnTop="1" name="CoatingGroup"/>
    <field labelOnTop="1" name="CoatingType"/>
    <field labelOnTop="1" name="ConvElementType"/>
    <field labelOnTop="0" name="CreateAuthor"/>
    <field labelOnTop="0" name="CreateDate"/>
    <field labelOnTop="1" name="Description"/>
    <field labelOnTop="1" name="Distance"/>
    <field labelOnTop="0" name="EndDate"/>
    <field labelOnTop="1" name="FlatElementType"/>
    <field labelOnTop="1" name="IdRfid"/>
    <field labelOnTop="1" name="IsDiffHeightMark"/>
    <field labelOnTop="1" name="IsObjectArea"/>
    <field labelOnTop="1" name="ManualCleanArea"/>
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
    <field labelOnTop="1" name="Property"/>
    <field labelOnTop="1" name="RootId"/>
    <field labelOnTop="0" name="StartDate"/>
    <field labelOnTop="0" name="TaskGUID"/>
    <field labelOnTop="1" name="WidthBegin"/>
    <field labelOnTop="1" name="WidthEnd"/>
    <field labelOnTop="0" name="fid"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="Area"/>
    <field reuseLastValue="0" name="AutoCleanArea"/>
    <field reuseLastValue="0" name="AxisGeometry"/>
    <field reuseLastValue="0" name="BordBegin"/>
    <field reuseLastValue="0" name="BordEnd"/>
    <field reuseLastValue="0" name="ChangeAuthor"/>
    <field reuseLastValue="0" name="ChangeDate"/>
    <field reuseLastValue="0" name="CoatingGroup"/>
    <field reuseLastValue="0" name="CoatingType"/>
    <field reuseLastValue="0" name="ConvElementType"/>
    <field reuseLastValue="0" name="CreateAuthor"/>
    <field reuseLastValue="0" name="CreateDate"/>
    <field reuseLastValue="0" name="Description"/>
    <field reuseLastValue="0" name="Distance"/>
    <field reuseLastValue="0" name="EndDate"/>
    <field reuseLastValue="0" name="FlatElementType"/>
    <field reuseLastValue="0" name="IdRfid"/>
    <field reuseLastValue="0" name="IsDiffHeightMark"/>
    <field reuseLastValue="0" name="IsObjectArea"/>
    <field reuseLastValue="0" name="ManualCleanArea"/>
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
    <field reuseLastValue="0" name="Property"/>
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
  <layerGeometryType>2</layerGeometryType>
</qgis>
