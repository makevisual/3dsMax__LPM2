/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com


    Copyright (C) 2010  Lukas Lepicovsky LPM, 3DS Max Pass Manager

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.




	Modified by grover_gol ( http://gg3dcg.ru/ ) for Altspace  ( http://altspace.com/ )  2015



*/

--RC MENU
--Contains menus and menu functions


filein "rcMenu_vrayOverride.ms"
filein "rcMenu_deadlineOverride.ms" 					-- Dabelow
filein "rcMenu_Utilities.ms" 							-- Dabelow
filein "rcMenu_vray5RenderElementsOverride.ms" 			-- Dabelow vray5
filein "rcMenu_vray5Override.ms" 						-- Dabelow vray5
filein "rcMenu_cameraOverscanOverride.ms"				-- Dabelow cameraOverscan
filein "rcMenu_nukeExport.ms"							-- Dabelow nukeExport
filein "rcMenu_aeExport.ms"								-- Dabelow aeExport

-------------------------------------------------------------------------------------------------------   Rollouts   -------------------------------------------------------------------------------------------------------




-------------------------------------------------------------------------------------------------------   lightSetProps   -------------------------------------------------------------------------------------------------------

 rollout lightSetProps ("Editing: "+ (LPM_Fun.getname LPM_treeview_rollout.tv.selectedNode.tag.value.name)) width:195 height:265
	(
		GroupBox grp3 "Light Control" pos:[5,0] width:184 height:260


		dropdownList pEnable "" pos:[11,16] width:45 height:21 items:#("--", "On", "Off")
		label lbl_Enabled "Enabled" pos:[61,20] width:71 height:15

		checkbox pMultiplierEnable "" pos:[11,46] width:17 height:13
		spinner pMultiplier "Multiplier" pos:[45,45] width:109 height:16 enabled:false

		checkbox pColorEnable "" pos:[11,73] width:17 height:13
		colorPicker pColor "Color " pos:[35,70] width:79 height:19 enabled:false

		dropdownList pCastShadows "" pos:[11,93] width:45 height:21 items:#("--", "On", "Off")
		label lbl_Cast_Shadows "Cast Shadows" pos:[63,97] width:77 height:15

		dropdownList pAffectDiffuse "" pos:[11,115] width:45 height:21 items:#("--", "On", "Off")
		label lbl_pAffectDiffuse "Affect diffuse" pos:[63,119] width:73 height:15

		dropdownList pAffectSpecular "" pos:[11,137] width:45 height:21 items:#("--", "On", "Off")
		label lbl_Affectspecular "Affect specular" pos:[63,141] width:81 height:15

		dropdownList pAffectReflections "" pos:[11,159] width:45 height:21 items:#("--", "On", "Off")
		label lbl_Affectreflections "Affect reflections" pos:[63,163] width:85 height:15

		dropdownList pUseTexture "" pos:[11,181] width:45 height:21 items:#("--", "On", "Off")
		label lbl_Usetexture "Use texture" pos:[63,184] width:85 height:15

		dropdownList pVrayInvisible "" pos:[11,203] width:45 height:21 items:#("--", "On", "Off")
		label lbl_vrayInvisible "VrayLight Invisible" pos:[63,206] width:105 height:15

		checkbox pTextureEnable "" pos:[11,234] width:17 height:13

		mapButton pTexture "None" pos:[29,229] width:106 height:24
		button LightSetSetTexture "<<" pos:[137,229] width:22 height:24
		button LightSetGetTexture ">>" pos:[161,229] width:22 height:24

		on lightSetProps open do
		(
			LPM_treeview_rollout.FreezeWindow()
			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			pEnable.selection=theLightSet.pEnable
			pCastShadows.selection=theLightSet.pCastShadows

			pColorEnable.checked=theLightSet.pColorEnable
			pColor.enabled = pColorEnable.checked
			pColor.color=theLightSet.pColor


			try
			(

				pMultiplierEnable.checked = theLightSet.pMultiplierEnable
				pMultiplier.enabled = pMultiplierEnable.checked
				pMultiplier.value = theLightSet.pMultiplier

				pAffectDiffuse.selection=theLightSet.pAffectDiffuse
				pAffectSpecular.selection=theLightSet.pAffectSpecular
				pAffectReflections.selection=theLightSet.pAffectReflections
				pUseTexture.selection=theLightSet.pUseTexture

				pVrayInvisible.selection=theLightSet.pVrayInvisible

				pTextureEnable.checked = theLightSet.pTextureEnable
				pTexture.map = theLightSet.pTexture

			)
			catch
			(

			)

			if pAffectDiffuse.selection == 0 then
			(
				pAffectDiffuse.selection=pAffectSpecular.selection=pAffectReflections.selection=1
			)

		)


		on lightSetProps close do
		(
			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value


			theLightSet.pEnable=pEnable.selection

			theLightSet.pMultiplierEnable = pMultiplierEnable.checked
			theLightSet.pMultiplier = pMultiplier.value

			theLightSet.pColorEnable=pColorEnable.checked
			theLightSet.pColor=pColor.color

			theLightSet.pCastShadows=pCastShadows.selection
			theLightSet.pAffectDiffuse=pAffectDiffuse.selection
			theLightSet.pAffectSpecular=pAffectSpecular.selection
			theLightSet.pAffectReflections=pAffectReflections.selection
			theLightSet.pUseTexture=pUseTexture.selection

			theLightSet.pVrayInvisible = pVrayInvisible.selection

			theLightSet.pTextureEnable=pTextureEnable.checked
			theLightSet.pTexture=pTexture.map


			LPM_Fun.setIcon LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.UnFreezeWindow()

		)

		on pTexture picked TmpMap do
		(
			LMap = TmpMap
			pTexture.text = LMap.name
			pTextureEnable.checked=true
		)

		on pMultiplierEnable changed theState do
		(
			pMultiplier.enabled = theState
		)

		on pColorEnable changed theState do
		(
			pColor.enabled = theState
		)

		on LightSetSetTexture pressed do
		(
			MapTemp = 0

			if MatEditor.mode == #advanced then
			(
				sme.Open()
				cur_view_Index = sme.activeView
				cur_node = 0
				if cur_view_Index != 0 then
				(
					cur_map = sme.GetMtlInParamEditor()

					if superclassof cur_map == textureMap then
					(
						MapTemp = cur_map
					)
				)

			)
			else
			(
				cur_map = getMeditMaterial activeMeditSlot

				if superclassof cur_map == textureMap then
				(
					MapTemp = cur_map
				)
			)

			if MapTemp != 0 then
			(
				pTexture.Map = MapTemp
				pTexture.text = pTexture.Map.name

				pTextureEnable.checked=true
			)
		)

		on LightSetGetTexture pressed do
		(
			if pTexture.Map!=undefined then
			(
				if MatEditor.mode == #advanced then
				(
					sme.Open()
					LPM_view_Index = sme.GetViewByName "LPM_View"

					if LPM_view_Index == 0 then
					(
						LPM_view_Index = sme.CreateView "LPM_View"
					)

					LPM_view = sme.GetView LPM_view_Index
					sme.activeView = LPM_view_Index
					LPM_view.CreateNode pTexture.Map [0,0]
				)
				else
				(
					MatEditor.Open()

					setMeditMaterial (medit.GetActiveMtlSlot()) pTexture.Map
				)
			)
		)

	)




-------------------------------------------------------------------------------------------------------   objectSetProps   -------------------------------------------------------------------------------------------------------

rollout objectSetProps ("Editing: "+(LPM_Fun.getname LPM_treeview_rollout.tv.selectedNode.tag.value.name))
(

	GroupBox grp5 "Render Control" pos:[3,3] width:190 height:325

	label lbl3 "Visible (inverted Hide)" pos:[59,21] width:120 height:22
	label lbl4 "Cast Shadows" pos:[58,64] width:80 height:22
	label lbl7 "Receive Shadows" pos:[59,87] width:95 height:29
	label lbl9 "Visible to Camera" pos:[60,107] width:109 height:18
	label lbl13 "Visible to Reflectl/Refract" pos:[60,127] width:127 height:18
	label lbl11 "Motion Blur" pos:[59,147] width:70 height:22
	label lbl14 "Apply Atmospherics" pos:[60,166] width:102 height:22
	label lbl15 "Render Occluded Objects" pos:[60,185] width:126 height:22

	label lbl66 "Renderable" pos:[57,43] width:120 height:22


	dropdownList pRenderable "" pos:[8,18] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pRenderableTrue "" pos:[8,40] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pCastShadows "" pos:[8,62] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pReceiveShadows "" pos:[8,83] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pVisibleToCamera "" pos:[8,103] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pVisibleToReflect "" pos:[8,123] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pMotionBlur "" pos:[8,143] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pApplyAtmospherics "" pos:[8,163] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pRenderOccluded "" pos:[8,183] width:45 height:21 items:#("--", "On", "Off")


	colorPicker pColor "" pos:[5,238] width:47 height:19

	checkbox pMatEnable "" pos:[8,210] width:15 height:18
	--checkbutton pMaterialButton "MaterialButton" pos:[25,184] width:165 height:31

	materialButton pMaterialButtonNew "MaterialButton" pos:[25,204] width:125 height:31 toolTip:"Pick material from material browser"
	Button pMaterialGetFromEditor "<<" pos:[150,204] width:20 height:31 toolTip:"Get material from selected Material editor slot (instance)"
	Button pMaterialGoToEditor ">>" pos:[170,204] width:20 height:31 toolTip:"Show material in selected Material editor slot"

	checkbox pOverrideUserProps "" pos:[12,277] width:15 height:15
	label wireLabel "Wirecolor" pos:[61,243] width:66 height:15
	label lbl10 "Override" pos:[31,277] width:125 height:18
	button editVray "Edit Vray" pos:[91,293] width:65 height:21
	button editMax "Edit Max" pos:[24,294] width:65 height:20
	groupBox grp2 "Custom User Properties" pos:[6,261] width:155 height:60

	groupBox grp7 "Viewport Control" pos:[3,333] width:190 height:64
	label lbl2 "Visible" pos:[60,351] width:126 height:22
	dropdownList pVisible "" pos:[8,347] width:45 height:21 items:#("--", "On", "Off")
	label lbl1 "Selectable" pos:[60,373] width:126 height:22
	dropdownList pSelectable "" pos:[8,369] width:45 height:21 items:#("--", "On", "Off")

	local pMaterial


	on pMaterialButtonNew picked mtl do
	(
		pMaterial = mtl
		pMaterialButtonNew.caption = pMaterial.name --+ " ( " +((classof pMaterial) as string) +" )"
		pMatEnable.checked=true
	)

	on pMaterialGetFromEditor pressed do
	(


		MatTemp = 0

		if MatEditor.mode == #advanced then
		(
			sme.Open()
			cur_view_Index = sme.activeView
			cur_node = 0
			if cur_view_Index != 0 then
			(
				cur_mat = sme.GetMtlInParamEditor()

				if superclassof cur_mat == material then
				(
					MatTemp = cur_mat
				)
			)

		)
		else
		(
			if (superclassof (getMeditMaterial activeMeditSlot)) == material then
			(
				MatTemp = getMeditMaterial activeMeditSlot
			)


		)

		if MatTemp != 0 then
		(
			pMaterial = MatTemp
			pMaterialButtonNew.caption = pMaterial.name
			pMatEnable.checked=true
		)


	)

	on pMaterialGoToEditor pressed do
	(
		if (pMaterial!=undefined) then
		(
			if MatEditor.mode == #advanced then
			(
				sme.Open()
				LPM_view_Index = sme.GetViewByName "LPM_View"

				if LPM_view_Index == 0 then
				(
					LPM_view_Index = sme.CreateView "LPM_View"
				)

				LPM_view = sme.GetView LPM_view_Index
				sme.activeView = LPM_view_Index
				LPM_view.CreateNode pMaterial [0,0]
			)
			else
			(
				MatEditor.Open()

				setMeditMaterial (medit.GetActiveMtlSlot()) pMaterial
			)
		)

	)


	on pMaterialButton changed state do
	(
		if(state==true) then
		(
			MatEditor.Open()
			medit.setactivemtlslot 1 true
			 pMatEnable.checked=true
			if(pMaterial==undefined) then
				meditMaterials[1]=standardMaterial()
			else
				meditMaterials[1]=pMaterial
			pMaterialButton.text="Click When Done"

		)
		else
		(
			MatEditor.close()
			if((superclassof meditMaterials[1]) == material) then
			(
				pMaterial=meditMaterials[1]
				pMaterialButton.text=pMaterial.name + " ( " +((classof pMaterial) as string) +" )"
			)
			else
			(
				pMaterialButton.text="Only Materials!!"
			)
		)

	)

	on objectSetProps open do
	(
		LPM_treeview_rollout.FreezeWindow()

		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		pColor.Color=theObjectSet.pColor


		pRenderable.selection=theObjectSet.intP[1]
		try
		(
			pRenderableTrue.selection=theObjectSet.intP[10]
		)
		catch
		(
			pRenderableTrue.selection=theObjectSet.intP[1]
		)

		pCastShadows.selection=theObjectSet.intP[2]
		pReceiveShadows.selection=theObjectSet.intP[3]
		pVisibleToCamera.selection=theObjectSet.intP[4]
		pVisibleToReflect.selection=theObjectSet.intP[5]
		pMotionBlur.selection=theObjectSet.intP[6]
		pApplyAtmospherics.selection=theObjectSet.intP[7]
		pRenderOccluded.selection=theObjectSet.intP[8]
		pMatEnable.checked=theObjectSet.pMatEnable
		pMaterial=theObjectSet.pMaterial

		if (pMaterial!=undefined) then
		(
			--pMaterialButton.text=pMaterial.name + " ( " +((classof pMaterial) as string) +" )"
			pMaterialButtonNew.material = pMaterial
			pMaterialButtonNew.caption = pMaterial.name --+ " ( " +((classof pMaterial) as string) +" )"
		)

		if(theObjectSet.intP[9]==2) then
			pOverrideUserProps.checked=true

		pVisible.selection=theObjectSet.visible
		pSelectable.selection=theObjectSet.selectable
	)
	on editMax pressed do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		setUserPropBuffer theObjectSet  theObjectSet.userProp
		select theObjectSet
		max properties
		theObjectSet.userProp=getUserPropBuffer theObjectSet
		setUserPropBuffer theObjectSet ""
	)
	on editVray pressed do
	(
		if(dovrayobjectproperties==undefined) then
			messagebox "Vray not installed"
		else
		(
			TempLayer = LayerManager.newLayerFromName "VrPropertiesOverrideTempLayer"

			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			theBuffer=theObjectSet.userProp

			newBox=box()
			TempLayer.addnode newBox
			newBox.name=theObjectSet.name + " Properties Override"

			theBuffer=setUserPropBuffer newBox theBuffer
			select newBox

			y=dovrayobjectproperties()
			theObjectSet.userProp=getUserPropBuffer newBox

			delete newBox
			LayerManager.deleteLayerByName "VrPropertiesOverrideTempLayer"
		)
	)

	on objectSetProps close do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.intP=#(pRenderable.selection,pCastShadows.selection,pReceiveShadows.selection,\
			pVisibleToCamera.selection, pVisibleToReflect.selection,pMotionBlur.selection,pApplyAtmospherics.selection,pRenderOccluded.selection)
		if(pOverrideUserProps.checked) then
			theObjectSet.intP[9]=2
		else
			theObjectSet.intP[9]=1
		theObjectSet.pMatEnable=pMatEnable.checked
		theObjectSet.pMaterial=pMaterial

		theObjectSet.intP[10]=pRenderableTrue.selection

		theObjectSet.pColor=pColor.Color
		--LPM_treeview_rollout.tv.selectedNode.ForeColor=(dotNetClass "System.Drawing.Color").fromARGB  theObjectSet.pColor.r theObjectSet.pColor.g theObjectSet.pColor.b
		LPM_Fun.setIcon LPM_treeview_rollout.tv.selectedNode


		theObjectSet.visible=pVisible.selection
		theObjectSet.selectable=pSelectable.selection

		LPM_treeview_rollout.UnFreezeWindow()
	)
)




-------------------------------------------------------------------------------------------------------   wildCardRO   -------------------------------------------------------------------------------------------------------

rollout wildCardRO "Wildcard" width:217 height:57
(
	edittext WildText "$" pos:[2,7] width:202 height:17
	button test "Try It!" pos:[12,29] width:46 height:21
	button help "Help!" pos:[171,30] width:33 height:21

	label lbl1 "" pos:[60,32] width:106 height:18 style_sunkenedge:true

	on wildCardRO open do
	(
		LPM_treeview_rollout.FreezeWindow()
		treenode=LPM_treeview_rollout.tv.selectedNode
		WildText.text=treenode.Parent.tag.value.wildCard[treenode.tag.value.index]
	)
	on wildCardRO close do
	(
		treenode=LPM_treeview_rollout.tv.selectedNode
		treenode.Parent.tag.value.wildCard[treenode.tag.value.index]=WildText.text
		LPM_treeview_rollout.UnFreezeWindow()
		LPM_treeview_rollout.tv.selectedNode.text=WildText.text
	)
	on test pressed do
	(
		sel=undefined
		try(sel=(execute ("$"+WildText.text)))catch(messagebox (getcurrentexception()))
		if(sel!=undefined) then
		(	select sel
			lbl1.text=sel.count as string + " Objects Selected"
		)
		else
			lbl1.text="0 Objects Selected"
	)
	on help pressed do
	(
		shellLaunch "http://www.kxcad.net/autodesk/Autodesk_MAXScript_Reference_9/pathname_literals.htm" ""
	)
)




-------------------------------------------------------------------------------------------------------   LPM_scriptRO   -------------------------------------------------------------------------------------------------------

 LPM_scriptRO2 = ""
 LPM_scriptRO3 = ""
 LPM_scriptRO4 = ""


rollout LPM_scriptRO1 "Main options" --width:500 height:434
(
	local scriptObj

	checkbox PreRender "Pre Render           or" pos:[14,10] width:114 height:17
	checkbox PostRender "Post Render         or" pos:[14,28] width:114 height:17

	checkbox PreLPM "Pre LPM Evaluation" pos:[140,10] width:114 height:17
	checkbox PostLPM "Post LPM Evaluation" pos:[140,28] width:114 height:17
	checkbox PostRenderFrame "PostRenderFrameScript" pos:[300,28] width:154 height:17 tooltip:"Evaluates every time after Frame render ends. It will work on all render nodes of your render farm if you put LPM_node_startup.ms in nodes 3Ds MAX startup folder."



	on PreRender changed TmpState do
	(
		if TmpState then
		(
			PreLPM.state = false
		)
	)

	on PostRender changed TmpState do
	(
		if TmpState then
		(
			PostLPM.state = false
		)
	)

	on PreLPM changed TmpState do
	(
		if TmpState then
		(
			PreRender.state = false
		)
	)

	on PostLPM changed TmpState do
	(
		if TmpState then
		(
			PostRender.state = false
		)
	)



	on LPM_scriptRO1 open do
	(
		LPM_treeview_rollout.FreezeWindow()
		scriptObj=LPM_treeview_rollout.tv.selectedNode.tag.value

		PreRender.checked=scriptObj.preRender
		PostRender.checked=scriptObj.postRender
		PreLPM.checked=scriptObj.PreLPM
		PostLPM.checked=scriptObj.PostLPM
		PostRenderFrame.checked = scriptObj.PostRenderFrameScript

		LPM_scriptRO2.scriptText.text=scriptObj.script
		LPM_scriptRO3.scriptText.text=scriptObj.script2
		LPM_scriptRO4.scriptText.text=scriptObj.PostRenderFrameScriptText
	)

	on LPM_scriptRO1 close do
	(

		scriptObj.preRender=PreRender.checked
		scriptObj.postRender=PostRender.checked
		scriptObj.PreLPM=PreLPM.checked
		scriptObj.PostLPM=PostLPM.checked
		scriptObj.PostRenderFrameScript = PostRenderFrame.checked

		ScriptObj.script=LPM_scriptRO2.scriptText.text
		ScriptObj.script2=LPM_scriptRO3.scriptText.text
		scriptObj.PostRenderFrameScriptText = LPM_scriptRO4.scriptText.text

		LPM_treeview_rollout.UnFreezeWindow()
	)

)


rollout LPM_scriptRO2 "Pre Script" --width:500 height:434
(
	local scriptObj
	label tryLbl "Try( Execute" pos:[13,5] width:60 height:13
	edittext ScriptText "" pos:[5,20] width:575 height:320
	label catchLbl ")Catch(Messagebox (GetcurrentException() as string))" pos:[13,345] width:351 height:13

	button tryIt "Test the Script" pos:[455,345] width:125 height:30


	on LPM_scriptRO2 open do
	(
		scriptText.text=LPM_scriptRO1.scriptObj.script
	)

	on tryIt pressed do
	(
		try(Execute ScriptText.text)Catch(Messagebox (GetcurrentException() as string))
	)


)

rollout LPM_scriptRO3 "Post Script" --width:500 height:434
(
	local scriptObj
	label tryLbl "Try( Execute" pos:[13,5] width:60 height:13
	edittext ScriptText "" pos:[5,20] width:575 height:320
	label catchLbl ")Catch(Messagebox (GetcurrentException() as string))" pos:[13,345] width:351 height:13

	button tryIt "Test the Script" pos:[455,345] width:125 height:30


	on LPM_scriptRO3 open do
	(
		scriptText.text=LPM_scriptRO1.scriptObj.script2
	)

	on tryIt pressed do
	(
		try(Execute ScriptText.text)Catch(Messagebox (GetcurrentException() as string))
	)


)

rollout LPM_scriptRO4 "PostRenderFrameScript" --width:500 height:434
(
	local scriptObj
	label tryLbl "Try( Execute" pos:[13,5] width:60 height:13
	edittext ScriptText "" pos:[5,20] width:575 height:320
	label catchLbl ")Catch(Messagebox (GetcurrentException() as string))" pos:[13,345] width:351 height:13

	button tryIt "Test the Script" pos:[455,345] width:125 height:30


	on LPM_scriptRO4 open do
	(
		scriptText.text=LPM_scriptRO1.scriptObj.PostRenderFrameScriptText
	)

	on tryIt pressed do
	(
		try(Execute ScriptText.text)Catch(Messagebox (GetcurrentException() as string))
	)


)




-------------------------------------------------------------------------------------------------------   ModifierOverRollout   -------------------------------------------------------------------------------------------------------

rollout ModifierOverRollout "Modifiers Override" width:217 height:361
(
	local theNode
	local activeModifiersArray=#()
	local activeNode = 0


	pickbutton pbActiveNode "Select Object" pos:[6,6] width:166 height:26

	GroupBox grp8 "Select Modifiers" pos:[3,39] width:210 height:287
	--button btnClear "Clear" pos:[178,25] width:35 height:16
	--multiListBox LBModifierOver "" pos:[6,56] width:203 height:20
	dotNetControl LBModifierOver "system.windows.forms.listView" pos:[6,56] width:203 height:265
	label lblDisMod22 "Warning! Modifiers names should differ." pos:[15,335] width:224 height:13

	fn fnUpdateUI=
	(
		--print this.disabledModifiers
		if(isvalidnode activeNode==false) then
		(
			pbActiveNode.text="Pick the Object To Modify"
		)
		else
		(
			pbActiveNode.text = activeNode.name

			--LBModifierOver.items=for modi in activeNode.modifiers collect modi.name

			TmpItems=for modi in activeNode.modifiers collect modi.name
			/*
			sel=#{}
			for i=1 to LBModifierOver.items.count do
			(
				if(finditem activeModifiersArray LBModifierOver.items[i] !=0) then
					sel[i]=true
			)

			LBModifierOver.selection=sel
			 */

			LPM_Fun.InitListView LBModifierOver "Modifiers" 203

			LPM_Fun.FillListView LBModifierOver TmpItems activeModifiersArray
		)
	)

	on btnClear pressed do
	(
		--LBModifierOver.selection = #()
	)

	on LBModifierOver selectionEnd do
	(
		--activeModifiersArray=for i=1 to LBModifierOver.items.count where LBModifierOver.selection[i] collect LBModifierOver.items[i]

	)

	on pbActiveNode picked obj do
	(
		activeNode = obj
		fnUpdateUI()
	)

	on ModifierOverRollout open do
	(
		LPM_treeview_rollout.FreezeWindow()

		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value

		activeNode = theNode.activeNode
		activeModifiersArray = theNode.activeModifiers

		fnUpdateUI()
	)

	on ModifierOverRollout close do
	(
		LPM_treeview_rollout.UnFreezeWindow()

		if activeNode != 0 then
		(
			theNode.activeNode = activeNode
		)

		theNode.activeModifiers = #()

		activeModifiersArray = LPM_Fun.SaveListView LBModifierOver
		for i=1 to activeModifiersArray.count do
		(

			append theNode.activeModifiers activeModifiersArray[i]

		)

	)
)




-------------------------------------------------------------------------------------------------------   V-Ray Global Illumination Rollout   -------------------------------------------------------------------------------------------------------


rollout LPMVrayGI "V-Ray Global Illumination" width:245 height:245
(
	checkbutton ckbWrite "Write" pos:[5,5] width:50 height:25 checked:true
	checkbutton ckbRead "Read" pos:[55,5] width:50 height:25

	button btnHelp " ?" pos:[215,4] width:26 height:25 tooltip:"How it works?"

	GroupBox grpWrite "GI Write" pos:[5,34] width:235 height:205
	GroupBox grpRead "GI Read" pos:[5,34] width:235 height:205 visible:false

	checkbox chkIrmap "Irradiance map" pos:[10,70] width:96 height:17
	label lbl1 "Mode:" pos:[10,95] width:33 height:19
	dropdownList ddlIrmapMode "" pos:[45,93] width:185 height:21 enabled:false items:#("Single frame", "Multiframe incremental", "Animation: prerass")
	checkbox chkIrmapUseCamera "Use Camera Path" pos:[45,115] width:106 height:18 enabled:false

	edittext edtFoundIrmap "" pos:[10,95] width:185 height:30 readOnly:true visible:false text:"Irradiance map NOT FOUND!"


	checkbox chkLightCache "Light cache" pos:[10,142] width:96 height:17
	label lbl2 "Mode:" pos:[10,162] width:33 height:19
	dropdownList ddlLightCacheMode "" pos:[45,165] width:185 height:21 enabled:false items:#("Single frame", "Fly-through")
	checkbox chkLightCacheUseCamera "Use Camera Path" pos:[45,187] width:106 height:18 enabled:false

	edittext edtFoundLightCache "" pos:[10,162] width:185 height:30 readOnly:true visible:false text:"Light Cache NOT FOUND!"


	checkbox chkDontRenderFinal "Don't render final image" pos:[10,209] width:134 height:17 checked:true

	label lblOutput "Output:" pos:[10,49] width:45 height:14
	edittext edtOutput "" pos:[50,49] width:165 height:16 readOnly:true
	button btnOutputExplore "..." pos:[217,50] width:18 height:16 tooltip:"Explore Output folder if it exists."

	label lblInput "Input Pass:" pos:[10,49] width:85 height:19 visible:false
	dropdownList ddlInputPass "" pos:[70,48] width:165 height:21 items:#("NONE") visible:false tooltip:"Select Pass with V-Ray GI override\n wich works in WRITE mode."


	local VRayGIobj
	local passArray
	local theNode

	fn UpdateInputPass =
	(
		if ddlInputPass.selection > 1 then
		(
			VRayGIobj.InputPass = passArray[ddlInputPass.selection-1]
		)
		else
		(
			VRayGIobj.InputPass = undefined
		)
	)

	fn UpdateLPMVrayGIFiles =
	(
		UpdateInputPass()

		TmpExistFiles = LPM_Fun.CheckVRayGIExist VRayGIobj

		if TmpExistFiles[1] then
		(
			edtFoundIrmap.text = "Irradiance map FOUND."
		)
		else
		(
			edtFoundIrmap.text = "Irradiance map NOT FOUND!"
		)

		if TmpExistFiles[2] then
		(
			edtFoundLightCache.text = "Light Cache FOUND."
		)
		else
		(
			edtFoundLightCache.text = "Light Cache NOT FOUND!"
		)
	)

	fn UpdateLPMVrayGIMode state =
	(
		ckbWrite.state = btnOutputExplore.visible = edtOutput.visible = grpWrite.visible = lblOutput.visible = chkDontRenderFinal.visible = lbl1.visible = lbl2.visible = ddlIrmapMode.visible = ddlLightCacheMode.visible = chkIrmapUseCamera.visible = chkLightCacheUseCamera.visible =  state
		grpRead.visible = ckbRead.state = lblInput.visible = ddlInputPass.visible = edtFoundIrmap.visible = edtFoundLightCache.visible = not state

		VRayGIobj.WriteMode = state
		edtOutput.text = LPM_Fun.GetVRayGIPath VRayGIobj

		UpdateLPMVrayGIFiles()
	)

	on ddlInputPass selected sel do
	(
		UpdateLPMVrayGIFiles()

	)

	on btnOutputExplore pressed do
	(
		shellLaunch edtOutput.text ""
	)

	on ckbWrite changed state do
	(
		UpdateLPMVrayGIMode state
	)

	on ckbRead changed state do
	(
		UpdateLPMVrayGIMode (not state)
	)

	on chkIrmap changed state do
	(
		ddlIrmapMode.enabled = chkIrmapUseCamera.enabled = state
	)

	on chkLightCache changed state do
	(
		ddlLightCacheMode.enabled = chkLightCacheUseCamera.enabled = state
	)

	on LPMVrayGI open do
	(
		LPM_treeview_rollout.FreezeWindow()

		VRayGIobj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode=LPM_treeview_rollout.tv.selectedNode
		TmpthePass=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

		passArray = for it in (LPM_FUn.getallchildren LPM_Root) where ((it.type=="pass")and(it != TmpthePass)) collect it
		namesArray = for it in passArray collect (LPM_Fun.generatePassName it)
		ddlInputPass.items = join #("NONE") namesArray

		if VRayGIobj.InputPass != undefined then
		(
			tmpPassNumb = findItem passArray VRayGIobj.InputPass
			if(tmpPassNumb>0) then
			(
				ddlInputPass.selection = tmpPassNumb +1
			)
		)

		UpdateLPMVrayGIMode VRayGIobj.WriteMode

		chkIrmap.state = ddlIrmapMode.enabled = chkIrmapUseCamera.enabled = VRayGIobj.IrMapOn
		ddlIrmapMode.selection = VRayGIobj.IrmapMode
		chkIrmapUseCamera.state = VRayGIobj.IrmapUseCamera

		chkLightCache.state = ddlLightCacheMode.enabled = chkLightCacheUseCamera.enabled = VRayGIobj.LightCacheOn
		ddlLightCacheMode.selection = VRayGIobj.LightCacheMode
		chkLightCacheUseCamera.state = VRayGIobj.LightCacheUseCamera

		chkDontRenderFinal.state = VRayGIobj.DontRenderFinal


	)

	on LPMVrayGI close do
	(
		VRayGIobj.WriteMode = ckbWrite.state
		VRayGIobj.IrMapOn = chkIrmap.state
		VRayGIobj.IrmapMode = ddlIrmapMode.selection
		VRayGIobj.IrmapUseCamera = chkIrmapUseCamera.state

		VRayGIobj.LightCacheOn = chkLightCache.state
		VRayGIobj.LightCacheMode = ddlLightCacheMode.selection
		VRayGIobj.LightCacheUseCamera = chkLightCacheUseCamera.state

		VRayGIobj.DontRenderFinal = chkDontRenderFinal.state

		UpdateInputPass()

		theNode.text=LPM_Fun.generateVRayGIName VRayGIobj

		LPM_treeview_rollout.UnFreezeWindow()
	)
)



-------------------------------------------------------------------------------------------------------   AutoMask Rollout   -------------------------------------------------------------------------------------------------------



rollout AutoMaskRoll "AutoMask" width:250 height:495
(
	GroupBox grpLayers "                                                                       " pos:[5,5] width:240 height:200
	checkbox chkLayers "Scene Layers Output" pos:[15,5] width:125 height:15
	checkbox chkLayersRGB "RGB" pos:[185,5] width:40 height:15 tooltip:"If checked creates RGB masks (several masks in one file)\nIf not checked creates Black&White masks"
	--multiListBox lbxLayers "" pos:[10,25] width:230 height:13 enabled:false

	dotNetControl lbxLayers "system.windows.forms.listView" pos:[10,25] width:230 height:176-- enabled:false

	GroupBox grpObjectIDs "                                                                       " pos:[5,210] width:240 height:45
	checkbox chkObjectIDs "Separated Object ID Output" pos:[15,210] width:160 height:15
	checkbox chkObjectIDsRGB "RGB" pos:[185,210] width:40 height:15 tooltip:"If checked creates RGB masks (several masks in one file)\nIf not checked creates Black&White masks"
	edittext edtObjectIDs "Object IDs: " pos:[10,226] width:230 height:16 enabled:false text:"1,3,5-10"

	GroupBox grpMaterialIDs "                                                                       " pos:[5,257] width:240 height:45
	checkbox chkMaterialIDs "Separated Material ID Output" pos:[15,258] width:165 height:15
	checkbox chkMaterialIDsRGB "RGB" pos:[185,258] width:40 height:15 tooltip:"If checked creates RGB masks (several masks in one file)\nIf not checked creates Black&White masks"
	edittext edtMaterialIDs "Material IDs: " pos:[10,276] width:230 height:16 enabled:false text:"1,3,5-10"

	GroupBox grpObjects "                                                                       " pos:[5,306] width:240 height:185
	checkbox chkObjects "Separated Objects Output" pos:[15,306] width:160 height:15
	checkbox chkObjectsRGB "RGB" pos:[185,306] width:40 height:15 tooltip:"If checked creates RGB masks (several masks in one file)\nIf not checked creates Black&White masks"

	multiListBox lbxObjects "" pos:[10,349] width:230 height:10 enabled:false
	button btnAddSelected "Add Selected" pos:[10,325] width:80 height:20 enabled:false
	button btnAddObjects "Add Objects" pos:[92,325] width:80 height:20 enabled:false
	button btnDelete "Delete" pos:[174,325] width:65 height:20 enabled:false

	local AutoMaskObj
	local theNode
	local NodesArr = #()

	fn ElementsEnableUpdate =
	(
		lbxLayers.enabled = chkLayersRGB.enabled = chkLayers.checked
		edtObjectIDs.enabled = chkObjectIDsRGB.enabled = chkObjectIDs.checked
		edtMaterialIDs.enabled = chkMaterialIDsRGB.enabled = chkMaterialIDs.checked
		lbxObjects.enabled = btnAddSelected.enabled = btnAddObjects.enabled = btnDelete.enabled = chkObjectsRGB.enabled = chkObjects.checked

	)

	fn compareFN v1 v2 = if((LPM_Fun.uppercase v1) < (LPM_Fun.uppercase v2)) then return -1 else return 1

	fn compareFN2 v1 v2 =
	(
		try
		(
			if((LPM_Fun.uppercase v1.name) < (LPM_Fun.uppercase v2.name)) then return -1 else return 1
		)
		catch
		(
			return 1
		)
	)

	fn Lights_filt obj = (not (isKindOf obj light))

	on btnAddObjects pressed do
	(
		tmpSelection = selectByName title:"Add objects" filter:Lights_filt single:false

		if tmpSelection != #() and tmpSelection != undefined then
		(
			for obj in tmpSelection do
			(
				appendIfUnique NodesArr obj
			)

			qsort NodesArr compareFN2



			TmpNamesArr = #()

			for i = 1 to NodesArr.count do
			(
				try
				(
					append TmpNamesArr NodesArr[i].name
				)
				catch
				(
					append TmpNamesArr "Deleted Node"
				)
			)


			lbxObjects.items = TmpNamesArr
		)
	)

	on btnDelete pressed do
	(

		for i=1 to lbxObjects.items.count do
		(
			j = lbxObjects.items.count-i+1

			if lbxObjects.selection[j] then
			(
				deleteItem NodesArr j
			)
		)

		qsort NodesArr compareFN2

		TmpNamesArr = #()

		for i = 1 to NodesArr.count do
		(
			try
			(
				append TmpNamesArr NodesArr[i].name
			)
			catch
			(
				append TmpNamesArr "Deleted Node"
			)
		)

		lbxObjects.items = TmpNamesArr
	)

	on btnAddSelected pressed do
	(
		if selection[1] != undefined then
		(

			for obj in selection do
			(
				appendIfUnique NodesArr obj
			)

			qsort NodesArr compareFN2

			TmpNamesArr = #()

			for i = 1 to NodesArr.count do
			(
				try
				(
					append TmpNamesArr NodesArr[i].name
				)
				catch
				(
					append TmpNamesArr "Deleted Node"
				)
			)

			lbxObjects.items = TmpNamesArr
		)

	)

	on AutoMaskRoll open do
	(
		LPM_treeview_rollout.FreezeWindow()

		AutoMaskObj = LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = LPM_treeview_rollout.tv.selectedNode

		items=#()
		for i=1 to LayerManager.count do
		(
			layerName = ((LayerManager.getLayer (i-1)).name)
			if (layerName != "zz-LPM") do append items layerName
		)
		qsort items compareFN
		--lbxLayers.items=items

		LPM_Fun.InitListView lbxLayers "Layers" 230
		LPM_Fun.FillListView lbxLayers items AutoMaskObj.layers

		chkLayers.checked = AutoMaskObj.layersOn
		chkObjectIDs.checked = AutoMaskObj.ObjectIDsOn
		chkMaterialIDs.checked = AutoMaskObj.MaterialIDsOn
		chkObjects.checked = AutoMaskObj.nodesOn

		chkLayersRGB.checked = AutoMaskObj.layersRGB
		chkObjectIDsRGB.checked = AutoMaskObj.ObjectIDsRGB
		chkMaterialIDsRGB.checked = AutoMaskObj.MaterialIDsRGB
		chkObjectsRGB.checked = AutoMaskObj.nodesRGB

		edtObjectIDs.text = AutoMaskObj.ObjectIDs
		edtMaterialIDs.text = AutoMaskObj.MaterialIDs

		--lbxLayers.selection=(for i=1 to lbxLayers.items.count where (findItem AutoMaskObj.layers lbxLayers.items[i])!=0  collect i)

		if AutoMaskObj.nodes.count > 0 then
		(

			TmpNamesArr = #()

			for i = 1 to AutoMaskObj.nodes.count do
			(
				try
				(
					append TmpNamesArr AutoMaskObj.nodes[i].name
				)
				catch
				(
					append TmpNamesArr "Deleted Node"
				)
			)

			lbxObjects.items = TmpNamesArr
		)

		NodesArr =  (AutoMaskObj.nodes as Array)

		ElementsEnableUpdate()
	)

	on AutoMaskRoll close do
	(
		AutoMaskObj.layersOn = chkLayers.checked
		AutoMaskObj.ObjectIDsOn = chkObjectIDs.checked
		AutoMaskObj.MaterialIDsOn = chkMaterialIDs.checked
		AutoMaskObj.nodesOn = chkObjects.checked

		AutoMaskObj.layersRGB = chkLayersRGB.checked
		AutoMaskObj.ObjectIDsRGB = chkObjectIDsRGB.checked
		AutoMaskObj.MaterialIDsRGB = chkMaterialIDsRGB.checked
		AutoMaskObj.nodesRGB = chkObjectsRGB.checked

		AutoMaskObj.ObjectIDs = edtObjectIDs.text
		AutoMaskObj.MaterialIDs = edtMaterialIDs.text

		--AutoMaskObj.layers=(for i=1 to lbxLayers.items.count where lbxLayers.selection[i] collect lbxLayers.items[i])
		AutoMaskObj.layers=LPM_Fun.SaveListView lbxLayers

		AutoMaskObj.nodes = NodesArr

		LPM_treeview_rollout.UnFreezeWindow()
	)

	on chkLayers changed theState do
	(
		ElementsEnableUpdate()
	)

	on chkObjectIDs changed theState do
	(
		ElementsEnableUpdate()
	)

	on chkMaterialIDs changed theState do
	(
		ElementsEnableUpdate()
	)

	on chkObjects changed theState do
	(
		ElementsEnableUpdate()
	)
)





-------------------------------------------------------------------------------------------------------   XrefSceneRollout   -------------------------------------------------------------------------------------------------------

rollout XrefSceneRollout "Xref Scene Override" width:400 height:300
(

	local activeXrefSceneArray=#()
	local theNode

	GroupBox grp8xrs "Select Xref Scenes" pos:[5,5] width:390 height:287
	--button btnClear "Clear" pos:[360,4] width:35 height:16
	--multiListBox LBXrefSceneOver "" pos:[10,35] width:380 height:20
	dotNetControl LBXrefSceneOver "system.windows.forms.listView" pos:[10,22] width:380 height:265

	fn fnUpdateUI =
	(
		xrefSceneProps = theNode
		xrefFileCount = xrefs.getXrefFileCount()
		/*
		sel=#{}

		LBXrefSceneOver.items = for i=1 to xrefFileCount collect
		(
			theFile=(xrefs.getXrefFile i).fileName
		)


		for i=1 to LBXrefSceneOver.items.count do
		(
			if(finditem activeXrefSceneArray LBXrefSceneOver.items[i] !=0) then
				sel[i]=true
		)

		LBXrefSceneOver.selection=sel
		 */

		TmpItems = for i=1 to xrefFileCount collect
		(
			theFile=(xrefs.getXrefFile i).fileName
		)

		LPM_Fun.InitListView LBXrefSceneOver "Xref Scenes" 380
		LPM_Fun.FillListView LBXrefSceneOver TmpItems activeXrefSceneArray

	)
	/*
	on btnClear pressed do
	(
		LBXrefSceneOver.selection = #()
	)

	on LBXrefSceneOver selectionEnd do
	(
		activeXrefSceneArray=for i=1 to LBXrefSceneOver.items.count where LBXrefSceneOver.selection[i] collect LBXrefSceneOver.items[i]
	)
	 */
	on XrefSceneRollout open do
	(
		LPM_treeview_rollout.FreezeWindow()

		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value


		activeXrefSceneArray = theNode.fileNames

		fnUpdateUI ()
	)

	on XrefSceneRollout close do
	(
		LPM_treeview_rollout.UnFreezeWindow()

		theNode.fileNames = #()

		activeXrefSceneArray=LPM_Fun.SaveListView LBXrefSceneOver

		for i=1 to activeXrefSceneArray.count do
		(
			append theNode.fileNames activeXrefSceneArray[i]
		)

	)

	on XrefSceneRollout resized theSize do
	(
		if theSize[1] < 400 then
		(
			XrefSceneRollout.width = 400
		)
		if theSize[2] < 300 then
		(
			XrefSceneRollout.height = 300
		)

		grp8xrs.width=XrefSceneRollout.width-10
		grp8xrs.height=XrefSceneRollout.height-10

		LBXrefSceneOver.width=XrefSceneRollout.width-20
		LBXrefSceneOver.height=XrefSceneRollout.height-32

		--btnClear.pos = [XrefSceneRollout.width-40, 4]
	)
)


-------------------------------------------------------------------------------------------------------   XrefSceneRollout   -------------------------------------------------------------------------------------------------------

rollout XrefObjRollout "Xref Object Override" width:400 height:300
(

	local activeXrefObjArray=#()
	local theNode

	GroupBox grp8xro "Select Xref Objects" pos:[5,5] width:590 height:287
	--button btnClear "Clear" pos:[360,4] width:35 height:16
	--multiListBox LBXrefObjOver "" pos:[10,35] width:380 height:20
	dotNetControl LBXrefObjOver "system.windows.forms.listView" pos:[10,22] width:580 height:265

	fn fnUpdateUI =
	(
		xrefObjProps = theNode
		xrefObjCount = objXRefMgr.recordCount
		/*
		sel=#{}


		LBXrefObjOver.items = for i=1 to xrefObjCount collect
		(
			theFile=(objXRefMgr.GetRecord i).srcFileName
		)



		for i=1 to LBXrefObjOver.items.count do
		(
			if(finditem activeXrefObjArray LBXrefObjOver.items[i] !=0) then
				sel[i]=true
		)

		LBXrefObjOver.selection=sel
		 */

		TmpItems = for i=1 to xrefObjCount collect
		(
			theFile=(objXRefMgr.GetRecord i).srcFileName
		)

		LPM_Fun.InitListView LBXrefObjOver "Xref Objects" 580
		LPM_Fun.FillListView LBXrefObjOver TmpItems activeXrefObjArray
	)
	/*
	on btnClear pressed do
	(
		LBXrefObjOver.selection = #()
	)

	on LBXrefObjOver selectionEnd do
	(
		activeXrefObjArray=for i=1 to LBXrefObjOver.items.count where LBXrefObjOver.selection[i] collect LBXrefObjOver.items[i]
	)
	 */
	on XrefObjRollout open do
	(
		LPM_treeview_rollout.FreezeWindow()

		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value


		activeXrefObjArray = theNode.fileNames

		fnUpdateUI ()
	)

	on XrefObjRollout close do
	(
		LPM_treeview_rollout.UnFreezeWindow()

		theNode.fileNames = #()

		activeXrefObjArray=LPM_Fun.SaveListView LBXrefObjOver

		for i=1 to activeXrefObjArray.count do
		(
			append theNode.fileNames activeXrefObjArray[i]
		)

	)

	on XrefObjRollout resized theSize do
	(
		if theSize[1] < 400 then
		(
			XrefObjRollout.width = 400
		)
		if theSize[2] < 300 then
		(
			XrefObjRollout.height = 300
		)

		grp8xro.width=XrefObjRollout.width-10
		grp8xro.height=XrefObjRollout.height-10

		LBXrefObjOver.width=XrefObjRollout.width-20
		LBXrefObjOver.height=XrefObjRollout.height-32

		--btnClear.pos = [XrefObjRollout.width-40, 4]
	)
)


-------------------------------------------------------------------------------------------------------   atmRollout   -------------------------------------------------------------------------------------------------------

rollout atmRollout "Env, Effects, Elements, Atmosphere" width:235 height:745
(
	local elementArray=#()
	local atmArray=#()
	local effectArray=#()
	local envMap

	checkbox backgroundOverride "Override" pos:[3,3] width:72 height:13
	GroupBox grp1 "Background" pos:[2,17] width:227 height:68 enabled:false

	label lbl1 "Color:" pos:[7,40] width:47 height:12 enabled:false
	label lbl2 "Environment Map:" pos:[66,37] width:89 height:17 enabled:false
	checkbox useEnvMap "Use Map" pos:[162,36] width:63 height:16 enabled:false
	colorPicker bgcolor "" pos:[3,55] width:52 height:19 enabled:false default:(color 0 0 0)
	checkbutton envMapButton "None" pos:[71,55] width:151 height:19 enabled:false visible:false
	mapbutton envMapButtonNew "None" pos:[61,55] width:121 height:19 enabled:false tooltip:"Select map"
	button envMapButtonNewSet "<<" pos:[182,55] width:20 height:19 enabled:false tooltip:"Get map from selected Material editor slot"
	button envMapButtonNewGet ">>" pos:[202,55] width:20 height:19 enabled:false tooltip:"Show map in selected Material editor slot"


	GroupBox grp2 "Global Lighting" pos:[2,87] width:227 height:69 enabled:false

	label lbl3 "Tint:" pos:[6,107] width:49 height:17 enabled:false
	label lbl4 "Level:" pos:[61,110] width:53 height:15 enabled:false
	label lbl5 "Ambient:" pos:[164,110] width:49 height:15 enabled:false
	colorPicker tint "" pos:[5,128] width:53 height:20 enabled:false default:(color 255 255 255)
	spinner level "" pos:[64,131] width:50 height:16 enabled:false range:[0,9999,1]
	colorPicker Ambient "" pos:[160,128] width:58 height:18 enabled:false default:(color 0 0 0)


	checkbox exposureOverride "Override" pos:[2,158] width:94 height:14
	groupBox grp18 "Exposure Control" pos:[2,172] width:227 height:40
	dropDownList exposureddl "" pos:[13,188] width:200 height:21 items:#("<No Exposure Control>", "Automatic Exposure Control", "Linear Exposure Control", "Logarithmic Exposure Control", "mr Photographic Exposure Control", "Pseudo Color Exposure Control") enabled:false



	GroupBox grp8 "Select Render Elements" pos:[1,233] width:230 height:285
	checkbox elementOverride "Override" pos:[2,215] width:62 height:17
	--button clearElement "Clear" pos:[194,222] width:35 height:16 enabled:false
	--multiListBox elementList "" pos:[4,248] width:223 height:20 enabled:false
	dotNetControl elementList "system.windows.forms.listView" pos:[4,248] width:223 height:265


	GroupBox grp5 "Select Atmospheres" pos:[3,540] width:227 height:90 enabled:false
	checkbox atmOverride "Override" pos:[2,522] width:60 height:15
	--button clearAtm "Clear" pos:[194,526] width:35 height:16 enabled:false
	--multiListBox atmList "" pos:[5,554] width:223 height:5 enabled:false
	dotNetControl atmList "system.windows.forms.listView" pos:[5,554] width:223 height:66


	GroupBox grp7 "Select Effects" pos:[3,653] width:229 height:90 enabled:false
	checkbox effectOverride "Override" pos:[2,637] width:71 height:17
	--button clearEffect "Clear" pos:[194,641] width:35 height:16 enabled:false
	--multiListBox effectList "" pos:[5,668] width:224 height:5 enabled:false
	dotNetControl effectList "system.windows.forms.listView" pos:[5,668] width:224 height:66


	local theNode

	on atmRollout open do
	(
		LPM_treeview_rollout.FreezeWindow()

		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value

		re = maxOps.GetCurRenderElementMgr()
		for i=1 to re.NumRenderElements() do
		(
			theEle=re.GetRenderElement (i-1)
			elementArray[i]=theEle.elementName
		)

		--elementList.items= elementArray
		elementList.enabled = false
		LPM_Fun.InitListView elementList "elements" 223
		LPM_Fun.FillListView elementList elementArray theNode.activeElement


		for i=1 to numAtmospherics do
		(
			theAtm=getAtmospheric i
			atmArray[i]=theAtm.name
		)
		--atmList.items=atmArray
		atmList.enabled = false
		LPM_Fun.InitListView atmList "atm" 223
		LPM_Fun.FillListView atmList atmArray theNode.activeAtm


		for i=1 to numEffects do
		(
			theEffect=getEffect i
			effectArray[i]=theEffect.name
		)
		--effectList.items=effectArray
		effectList.enabled = false
		LPM_Fun.InitListView effectList "eff" 223
		LPM_Fun.FillListView effectList effectArray theNode.activeEffect

		if(theNode.initialized==true) then
		(
			--elements load
			elementOverride.checked=theNode.elementOverride
			elementList.enabled=theNode.elementOverride
			grp8.enabled=theNode.elementOverride
			--clearElement.enabled=theNode.elementOverride
			/*
			sel=#()

			for i=1 to theNode.activeElement.count do
			(
				theItem=findItem elementArray theNode.activeElement[i]
				if  theItem!=0 then
					append sel theItem
			)
			elementList.selection=sel
			 */


			--atmosphere load
			atmOverride.checked=theNode.atmOverride
			atmList.enabled=theNode.atmOverride
			grp5.enabled=theNode.atmOverride
			--clearAtm.enabled=theNode.atmOverride
			/*
			sel=#()

			for i=1 to theNode.activeAtm.count do
			(
				theItem=findItem atmArray theNode.activeAtm[i]
				if  theItem!=0 then
					append sel theItem
			)
			atmList.selection=sel
			 */

			--effects load
			effectOverride.checked=theNode.effectOverride
			effectList.enabled=theNode.effectOverride
			grp7.enabled=theNode.effectOverride
			--clearEffect.enabled=theNode.effectOverride
			/*
			sel=#()

			for i=1 to theNode.activeEffect.count do
			(
				theItem=findItem effectArray theNode.activeEffect[i]
				if  theItem!=0 then
					append sel theItem
			)
			effectList.selection=sel
			 */

			--bg load
			backGroundOverride.checked=theNode.backGroundOverride
			bgColor.color=theNode.bgColor
			envMap=theNode.envMap
			if(envMap!=undefined) then
			(
				envMapButton.text=envMap.name+"("+((classof envMap) as string)+")"
				envMapButtonNew.text = envMap.name
			)
			else
			(
				envMapButton.text ="none"
				envMapButtonNew.text = "none"
			)
			useEnvMap.checked=theNode.useEnvMap
			tint.color=theNode.tint
			level.value=theNode.level
			ambient.color=theNode.ambient
			grp1.enabled=theNode.backGroundOverride
			lbl1.enabled=theNode.backGroundOverride
			lbl2.enabled=theNode.backGroundOverride
			lbl3.enabled=theNode.backGroundOverride
			lbl4.enabled=theNode.backGroundOverride
			lbl5.enabled=theNode.backGroundOverride
			bgColor.enabled=theNode.backGroundOverride
			envMapButton.enabled=theNode.backGroundOverride
			envMapButtonNew.enabled=theNode.backGroundOverride
			envMapButtonNewGet.enabled=theNode.backGroundOverride
			envMapButtonNewSet.enabled=theNode.backGroundOverride
			useEnvMap.enabled=theNode.backGroundOverride
			grp2.enabled=theNode.backGroundOverride
			tint.enabled=theNode.backGroundOverride
			level.enabled=theNode.backGroundOverride
			ambient.enabled=theNode.backGroundOverride
			--exposure control
			exposureddl.enabled=theNode.exposureOverride
			exposureOverride.checked=theNode.exposureOverride
			if(theNode.exposureInt==0)then
				theNode.exposureInt=1
			exposureDDL.selection=theNode.exposureInt
		)
		else
		(
			bgColor.color=backgroundColor
			useEnvMap.checked=useEnvironmentMap
			envMap=undefined
			tint.color=lightTintColor
			level.value=lightLevel
			ambient.color=ambientColor
		)
	)
	on envMapButton changed state do
	(

		if(state==true) then
		(
			MatEditor.Open()
			medit.setactivemtlslot 1 true
			if(envMap==undefined) then
				meditMaterials[1]=bitmaptexture()
			else
				meditMaterials[1]=envMap
			envMapButton.text="Click When Done"

		)
		else
		(
			MatEditor.close()
			if((superclassof meditMaterials[1]) == textureMap) then
			(
				envMap=meditMaterials[1]
				envMapButton.text=envMap.name + " ( " +((classof envMap) as string) +" )"
			)
			else
			(
				envMapButton.text="Only Maps!!"

			)
		)
	)

	on envMapButtonNew picked TmpMap do
	(
		envMap = TmpMap
		envMapButtonNew.text = envMap.name
		useEnvMap.checked=true
	)

	on envMapButtonNewSet pressed do
	(
		MapTemp = 0

		if MatEditor.mode == #advanced then
		(
			sme.Open()
			cur_view_Index = sme.activeView
			cur_node = 0
			if cur_view_Index != 0 then
			(
				cur_map = sme.GetMtlInParamEditor()

				if superclassof cur_map == textureMap then
				(
					MapTemp = cur_map
				)
			)

		)
		else
		(
			cur_map = getMeditMaterial activeMeditSlot

			if superclassof cur_map == textureMap then
			(
				MapTemp = cur_map
			)
		)

		if MapTemp != 0 then
		(
			envMap = MapTemp
			envMapButtonNew.text = envMap.name

			useEnvMap.checked=true
		)
	)

	on envMapButtonNewGet pressed do
	(
		if envMap!=undefined then
		(
			if MatEditor.mode == #advanced then
			(
				sme.Open()
				LPM_view_Index = sme.GetViewByName "LPM_View"

				if LPM_view_Index == 0 then
				(
					LPM_view_Index = sme.CreateView "LPM_View"
				)

				LPM_view = sme.GetView LPM_view_Index
				sme.activeView = LPM_view_Index
				LPM_view.CreateNode envMap [0,0]
			)
			else
			(
				MatEditor.Open()

				setMeditMaterial (medit.GetActiveMtlSlot()) envMap
			)
		)

	)

	on exposureOverride changed state do
	(
		exposureddl.enabled=state
	)
	on backGroundOverride changed state do
	(
		grp1.enabled=state
		lbl1.enabled=state
		lbl2.enabled=state
		lbl3.enabled=state
		lbl4.enabled=state
		lbl5.enabled=state
		bgColor.enabled=state
		envMapButton.enabled=state
		envMapButtonNew.enabled=state
		envMapButtonNewGet.enabled=state
		envMapButtonNewSet.enabled=state
		useEnvMap.enabled=state
		grp2.enabled=state
		tint.enabled=state
		level.enabled=state
		ambient.enabled=state
	)
	on elementOverride changed state do
	(
		elementList.enabled=state
		grp8.enabled=state
		--clearElement.enabled=state
	)
	/*
	on clearElement pressed do
	(
		elementList.selection=#{}
	)
	 */
	on effectOverride changed state do
	(
		effectList.enabled=state
		grp7.enabled=state
		--clearEffect.enabled=state
	)
	/*
	on clearEffect pressed do
	(
		effectList.selection=#{}
	)
	 */
	on atmOverride changed state do
	(
		atmList.enabled=state
		grp5.enabled=state
		--clearAtm.enabled=state
	)
	/*
	on clearAtm pressed do
	(
		atmList.selection=#{}
	)
	 */

	on atmRollout close do
	(
		--element
		theNode.elementOverride=elementOverride.checked
		/*
		theNode.activeElement=#()
		for i=1 to elementArray.count do
		(

			if(elementList.selection[i]) then
			(
				append theNode.activeElement elementList.items[i]
			)
		)
		 */

		theNode.activeElement = LPM_Fun.SaveListView elementList


		--atm
		theNode.atmOverride=atmOverride.checked
		/*
		theNode.activeAtm=#()
		for i=1 to atmArray.count do
		(
			if(atmList.selection[i]) then
				append theNode.activeAtm atmList.items[i]
		)
		 */
		theNode.activeAtm = LPM_Fun.SaveListView atmList

		--effects
		theNode.effectOverride=effectOverride.checked
		/*
		theNode.activeEffect=#()
		for i=1 to effectArray.count do
		(
			if(effectList.selection[i]) then
				append theNode.activeEffect effectList.items[i]
		)
		 */
		theNode.activeEffect = LPM_Fun.SaveListView effectList

		--background
		theNode.backGroundOverride=backGroundOverride.checked
		theNode.bgColor=bgColor.color
		theNode.envMap=envMap
		theNode.useEnvMap=useEnvMap.checked
		theNode.tint=tint.color
		theNode.level=level.value
		theNode.ambient=ambient.color

		--exposure control
		theNode.exposureOverride=exposureOverride.checked
		theNode.exposureInt=exposureDDL.selection
		theNode.initialized=true
		LPM_treeview_rollout.UnFreezeWindow()

	)
)




-------------------------------------------------------------------------------------------------------   commonRollout   -------------------------------------------------------------------------------------------------------

rollout commonRollout "Common Properties" width:370 height:640
(
	GroupBox grp1 "Time Output" pos:[24,4] width:335 height:111 enabled:false
	GroupBox grp2 "Output Size" pos:[24,112] width:336 height:88 enabled:false
	GroupBox grp3 "Options" pos:[24,241] width:335 height:105 enabled:false
	GroupBox grp4 "Advanced Lighting" pos:[24,347] width:335 height:54 enabled:false
	GroupBox grp5 "File Type" pos:[24,401] width:154 height:43 enabled:false
	GroupBox grp7 "Camera" pos:[23,452] width:336 height:42 enabled:false

	checkbox timeOutputTgl "" pos:[4,9] width:15 height:16
	checkbox outputSizeTgl "" pos:[4,120] width:15 height:16
	checkbox optionsTgl "" pos:[4,246] width:15 height:16
	checkbox advancedLightingTgl "" pos:[4,352] width:15 height:16
	checkbox fileTypeTgl "" pos:[4,406] width:15 height:16
	checkbox cameraTgl "" pos:[4,457] width:15 height:16

	radiobuttons _rendTimeType "" pos:[34,21] width:124 height:64 enabled:false labels:#("Single", "Active Time Segment", "Range", "Frames") columns:1
	spinner _rendNThFrame "Every Nth Frame" pos:[232,20] width:117 height:16 enabled:false range:[1,99999,1] type:#integer
	spinner _rendStart "" pos:[112,52] width:69 height:16 enabled:false range:[-1e+007,1e+007,0] type:#integer
	spinner _rendEnd "" pos:[212,52] width:69 height:16 enabled:false range:[-1e+007,1e+007,0] type:#integer
	spinner _rendFileNumberBase "File Number Base: " pos:[198,90] width:150 height:16 enabled:false range:[-99999,99999,0] type:#integer
	spinner _renderWidth "" pos:[70,131] width:62 height:16 enabled:false range:[1,32768,1] type:#integer
	spinner _renderHeight "" pos:[70,151] width:62 height:16 enabled:false range:[1,32768,1] type:#integer
	checkbutton lockAspect "L" pos:[135,130] width:14 height:38 enabled:false checked:true
	spinner aspect "" pos:[70,175] width:62 height:16 enabled:false
	label aspectLabel "Aspect:" pos:[31,176] width:35 height:14 enabled:false
	dropDownList presetDDL "" pos:[164,174] width:152 height:21 enabled:false tooltip:"Select a preset to load it"
	button addPreset "+" pos:[317,176] width:16 height:16 enabled:false tooltip:"Add a preset"
	button removePreset "-" pos:[336,176] width:16 height:16 enabled:false tooltip:"Delete the selected preset"

	spinner _RendApertureWidth "" pos:[251,133] width:64 height:16 enabled:false range:[0.001,1000,1]
	spinner _renderPixelAspect "" pos:[251,153] width:64 height:16 enabled:false range:[0.001,1000,1]
	edittext _rendPickupFrames "" pos:[109,70] width:240 height:17 enabled:false
	checkbox _rendAtmosphere "Atmospherics" pos:[31,254] width:95 height:19 enabled:false
	checkbox _renderEffects "Effects" pos:[31,271] width:95 height:19 enabled:false
	checkbox _renderDisplacements "Displacement" pos:[31,288] width:95 height:19 enabled:false
	checkbox _rendColorCheck "Video Color Check" pos:[31,304] width:145 height:19 enabled:false
	checkbox _rendFieldRender "Render To Fields" pos:[31,322] width:145 height:19 enabled:false
	checkbox _rendHidden "Render Hidden Geometry" pos:[173,253] width:145 height:19 enabled:false
	checkbox _rendSimplifyAreaLights "Area Lights/Shadows as Points" pos:[173,270] width:172 height:19 enabled:false
	checkbox _rendForce2Side "Force 2-Sided" pos:[173,287] width:106 height:19 enabled:false
	checkbox _rendSuperBlack "Super Black" pos:[173,304] width:96 height:19 enabled:false
	checkbox _useAdvancedLighting "Use Advanced Lighting" pos:[33,362] width:143 height:15 enabled:false
	checkbox _computeAdvancedLighting "Compute Advanced Lighting" pos:[33,377] width:143 height:15 enabled:false

	dropdownList _CameraDdl "" pos:[31,467] width:270 height:21 enabled:false items:#("--") --120 width
	checkbutton _CameraExport "Export" pos:[305,467] enabled:false check:true

	edittext _fileType "" pos:[91,418] width:53 height:19 readOnly:true
	button pickTypeButton "Pick" pos:[39,419] width:47 height:16 enabled:false

	checkbox gammaTgl "" pos:[182,405] width:15 height:16
	GroupBox grp13 "Gamma" pos:[201,402] width:157 height:43 enabled:false
	spinner _fileOutGamma "File Out Gamma" pos:[260,421] width:95 height:16 enabled:false range:[0.01,5,1]

	label lbl1 "To" pos:[187,52] width:19 height:18 enabled:false
	label lbl4 "Width:" pos:[33,132] width:35 height:14 enabled:false
	label lbl5 "Height:" pos:[33,151] width:35 height:14 enabled:false
	label lbl6 "Aperture Width(mm):" pos:[152,133] width:99 height:15 enabled:false
	label lbl7 "Pixel Aspect:" pos:[186,153] width:61 height:15 enabled:false range:[0.01,100,.01]


	GroupBox grp8 "Pre Render Script" pos:[24,496] width:336 height:57
	checkbox usePreScript "" pos:[5,505] width:18 height:15
	button pickPreScript "Pick" pos:[37,510] width:47 height:17
	checkbox usePostScript "" pos:[5,561] width:14 height:15
	button pickPostScript "Pick" pos:[33,570] width:47 height:17
	button EditPreScript "Edit..." pos:[85,510] width:42 height:17
	button EditPostScript "Edit..." pos:[82,570] width:42 height:17
	button newPreScript "New" pos:[183,510] width:42 height:17
	button newPostScript "New" pos:[181,570] width:42 height:17
	GroupBox grp16 "Post Render Script" pos:[24,554] width:336 height:60
	edittext preScript "" pos:[33,531] width:320 height:18
	edittext postScript "" pos:[27,590] width:326 height:18
	button execPreScript "Execute" pos:[129,510] width:55 height:17
	button execPostScript "Execute" pos:[126,570] width:55 height:17

	checkbox autoUpdateName "Auto Update Name" pos:[8,620] width:115 height:15
	checkbox disableFinalOutput "Disable Final Image Output" pos:[150, 620] width:170 height:15
	GroupBox RenderTypeGroup "Render Type" pos:[24,202] width:335 height:37
	checkbox renderTypeTgl "" pos:[4,209] width:15 height:16
	dropdownList renderTypeDDL "" pos:[34,216] width:116 height:21 items:#("view", "region", "crop", "blowup")

	local presetData=#()
	local presetNames=#()
	local cameraList=#()
	local theNode

	fn toggleState=
	(
			state=timeOutputTgl.checked
			grp1.enabled=state
			_rendTimeType.enabled=state
			_rendNThFrame.enabled=state
			_rendStart.enabled=state
			_rendEnd.enabled=state
			_rendFileNumberBase.enabled=state
			_rendPickupFrames.enabled=state
			lbl1.enabled=state

			state=outputSizeTgl.checked
			grp2.enabled=state
			_renderHeight.enabled=state
			_renderWidth.enabled=state
			_RendApertureWidth.enabled=state
			_renderPixelAspect.enabled=state
			lockAspect.enabled=state
			aspect.enabled=state
			aspectLabel.enabled=state
			presetDDL.enabled=state
			addPreset.enabled=state
			removePreset.enabled=state



			lbl4.enabled=state
			lbl5.enabled=state
			lbl6.enabled=state
			lbl7.enabled=state

			state=optionsTgl.checked
			grp3.enabled=state
			_rendAtmosphere.enabled=state
			_renderEffects.enabled=state
			_renderDisplacements.enabled=state
			_rendColorCheck.enabled=state
			_rendFieldRender.enabled=state
			_rendHidden.enabled=state
			_rendSimplifyAreaLights.enabled=state
			_rendForce2Side.enabled=state
			_rendSuperBlack.enabled=state

			state=advancedLightingTgl.checked
			grp4.enabled=state
			_useAdvancedLighting.enabled=state
			_computeAdvancedLighting.enabled=state

			state=fileTypeTgl.checked
			grp5.enabled=state
			--_fileType.enabled=state
			pickTypeButton.enabled=state


			state=cameraTgl.checked
			grp7.enabled=state
			_CameraDDl.enabled=state

			_CameraExport.enabled=state


			state=renderTypeTgl.checked
			renderTypeDDL.enabled=state
			RenderTypeGroup.enabled=state

			state=gammaTgl.state
			grp13.enabled=state
			_fileOutGamma.enabled=state

	)
	on timeOutputTgl changed state do
	(
		toggleState()

	)
	on outputSizeTgl changed state do
	(
		toggleState()


	)
	on optionsTgl changed state do
	(
		toggleState()
	)
	on advancedLightingTgl changed state do
	(
		toggleState()
	)
	on fileTypeTgl changed state do
	(
		toggleState()
	)
	on filePathTgl changed state do
	(
		toggleState()

	)
	on cameraTgl changed state do
	(
		toggleState()

	)
	on renderTypeTgl changed state do
	(
		toggleState()
	)
	on gammaTgl changed state do
	(
		toggleState()
	)
	on editPreScript pressed do
	(
		try(edit preScript.text)catch()
	)
	on editPostScript pressed do
	(
		try(edit postScript.text)catch()
	)
	on pickPreScript pressed do
	(
		thePath=getOpenFileName()
		if(thePath!=undefined) then
		prescript.text=thePath
		usePreScript.checked=true
	)
	on pickPostScript pressed do
	(
		thePath=getOpenFileName()
		if(thePath!=undefined) then
		postscript.text=thePath
		usePostScript.checked=true
	)
	on newPreScript pressed do
	(
		thePath=getSaveFileName types:"maxscript(*.ms)|*.ms"
		if(thePath!=undefined) then
		(
			close (createFile thePath)
			edit thePath
			preScript.text=thePath
			usePreScript.checked=true
		)
	)

	on newPostScript pressed do
	(
		thePath=getSaveFileName types:"maxscript(*.ms)|*.ms"


		if(thePath!=undefined) then
		(
			close (createFile thePath)
			edit thePath
			postScript.text=thePath
			usePostScript.checked=true
		)
	)

	on execPreScript pressed do
	(
		try(fileIn preScript.text) catch (messagebox (getCurrentException()))
	)
	on execPostScript pressed do
	(
		try(fileIn postScript.text) catch (messagebox (getCurrentException()))
	)


	on pickTypeButton pressed do
	(
		if(LPM_Root.fileType==undefined) then
			LPM_Root.fileType="exr"
		thePath=getBitmapSaveFileName caption:"Enter the File Type" filename:("XXX."+LPM_Root.fileType)
		if(thePath!=undefined) then
		(
			theType=getFilenameType thePath
			if(theType!="") then
			(
				theType=substring theType 2 -1
				_fileType.text=theType
			)
		)
	)
	on _rendStart changed val do
	(
		 _rendTimeType.state=3

	)
	on _rendEnd changed valt  do
	(
		_rendTimeType.state=3

	)


	fn updateAspect=
	(
		aspect.value=(_renderWidth.value) as float /(_renderHeight.value) as float

	)

	on _renderWidth changed val do
	(
		if(lockAspect.state) then
		(
			_renderHeight.value=(_renderWidth.value as float)/ (aspect.value as float)

		)
		else
			updateAspect()
	)
	on aspect changed val do
	(
		_renderWidth.value=(_renderHeight.value as float)* (aspect.value as float)
	)

	on _renderHeight changed val do
	(
		if(lockAspect.state) then
		(
			_renderWidth.value=(_renderHeight.value as float)* (aspect.value as float)

		)
		else
			updateAspect()
	)
	fn loadPresets=
	(
		--load preset data
		it=LPM_Fun.getIni "Presets" "CommonPresets" string "#(#(640,480,1.0,36.0),#(1024,768,1.0,36.0))"
		presetData=execute it
		presetDDL.items=for it in presetData collect (it[1] as string)+"x"+(it[2] as string)+" "+(it[3] as string)+"px "+(it[4] as string)+"mm"

	)
	fn savePresets=
	(
		fn compareFN x y=
		(
			case of
			(
			(x[1]<y[1]): -1
			(x[1]>y[1]): 1
			default:0
			)
		)

		qsort presetData compareFN
		theData=presetData as string
		LPM_Fun.setini "Presets" "CommonPresets" presetData
	)

	on addpreset pressed do
	(

		presetData+=#(#(_renderWidth.value,_renderHeight.value,_renderPixelAspect.value,_RendApertureWidth.value))
		savePresets()
		loadPresets()
		presetDDL.selection=presetDDL.items.count

	)
	on removepreset pressed do
	(
		theItem=presetDDL.selection
		if(theItem!=0) then
		(
			presetData=for i=1 to presetData.count where (i!= theItem )collect presetData[i]
		)
		savePresets()
		loadPresets()
		if(presetDDL.selection>presetDDL.items.count or presetDDL.selection==0) then
			presetDDL.selection=presetDDL.items.count
	)
	on presetDDL selected item do
	(
		if(item!=0) then
		(
			_renderWidth.value=presetData[item][1]
			_renderHeight.value=presetData[item][2]
			_renderPixelAspect.value=presetData[item][3]
			_RendApertureWidth.value=presetData[item][4]
			updateAspect()
		)

	)


	on commonRollout open do
	(
		LPM_treeview_rollout.FreezeWindow()
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode=LPM_treeview_rollout.tv.selectedNode


		loadPresets()

		cameraList=for i in $cameras where (superclassof i==camera) collect i
		cameraNameList=for it in cameraList collect it.name
		_cameraDDl.items=cameraNameList

		_rendTimeType.state=cp._rendTimeType
		_rendNThFrame.value=cp._rendNThFrame
		_rendStart.value=cp._rendStart
		_rendEnd.value=cp._rendEnd
		_rendFileNumberBase.value=cp._rendFileNumberBase
		_renderHeight.value=cp._renderHeight
		_renderWidth.value=cp._renderWidth
		updateAspect()

		_RendApertureWidth.value=cp._RendApertureWidth
		_renderPixelAspect.value=cp._renderPixelAspect
		_rendPickupFrames.text=cp._rendPickupFrames
		_rendAtmosphere.checked=cp._rendAtmosphere
		_renderEffects.checked=cp._renderEffects
		_renderDisplacements.checked=cp._renderDisplacements
		_rendColorCheck.checked=cp._rendColorCheck
		_rendFieldRender.checked=cp._rendFieldRender
		_rendHidden.checked=cp._rendHidden
		_rendSimplifyAreaLights.checked=cp._rendSimplifyAreaLights
		_rendForce2Side.checked=cp._rendForce2Side
		_rendSuperBlack.checked=cp._rendSuperBlack
		_useAdvancedLighting.checked=cp._useAdvancedLighting
		_computeAdvancedLighting.checked=cp._computeAdvancedLighting
		timeOutputTgl.checked=cp.timeOutputTgl
		outputSizeTgl.checked=cp.outputSizeTgl
		optionsTgl.checked=cp.optionsTgl
		advancedLightingTgl.checked=cp.advancedLightingTgl
		fileTypeTgl.checked=cp.fileTypeTgl
		_fileType.text=cp._fileType
		gammaTgl.checked=cp.gammaTgl
		_fileOutGamma.value=cp._fileOutGamma
		renderTypeTgl.checked=cp.renderTypeTgl

		_CameraExport.checked=cp._CameraExport

		for i=1 to renderTypeDDL.items.count where renderTypeDDL.items[i]==cp.renderType do
			renderTypeDDL.selection=i

		cameraTgl.checked=cp.cameraTgl
		if(isvalidNode cp._camera) then
		(
			x=(findItem  _cameraDDl.items cp._camera.name)
			if (x!=0) then
				_cameraDDl.selection=x
		)


		usePreScript.checked=cp.usePreScript
		preScript.text=cp.preScript
		usePostScript.checked=cp.usePostScript
		postScript.text=cp.postScript

		autoUpdateName.checked=cp.autoUpdateName
		disableFinalOutput.checked=cp.disableFinalOutput
		toggleState()

	)
	on commonRollout close do
	(
		try(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value

		cp.initialized=true
		cp._rendTimeType=_rendTimeType.state
		cp._rendNThFrame=_rendNThFrame.value
		cp._rendStart=_rendStart.value
		cp._rendEnd=_rendEnd.value
		cp._rendFileNumberBase=_rendFileNumberBase.value
		cp._renderHeight=_renderHeight.value
		cp._renderWidth=_renderWidth.value
		cp._RendApertureWidth=_RendApertureWidth.value
		cp._renderPixelAspect=_renderPixelAspect.value
		cp._rendPickupFrames=_rendPickupFrames.text
		cp._rendAtmosphere=_rendAtmosphere.checked
		cp._renderEffects=_renderEffects.checked
		cp._renderDisplacements=_renderDisplacements.checked
		cp._rendColorCheck=_rendColorCheck.checked
		cp._rendFieldRender=_rendFieldRender.checked
		cp._rendHidden=_rendHidden.checked
		cp._rendSimplifyAreaLights=_rendSimplifyAreaLights.checked
		cp._rendForce2Side=_rendForce2Side.checked
		cp._rendSuperBlack=_rendSuperBlack.checked
		cp._useAdvancedLighting=_useAdvancedLighting.checked
		cp._computeAdvancedLighting=_computeAdvancedLighting.checked
		cp.timeOutputTgl=timeOutputTgl.checked
		cp.outputSizeTgl=outputSizeTgl.checked
		cp.optionsTgl=optionsTgl.checked
		cp.advancedLightingTgl=advancedLightingTgl.checked
		cp.fileTypeTgl=fileTypeTgl.checked
		cp._fileType=_fileType.text
		cp.renderTypeTgl=renderTypeTgl.checked
		cp.renderType=renderTypeDDL.selected
		cp.gammaTgl=gammaTgl.state
		cp._fileOutGamma=_fileOutGamma.value
		cp.usePreScript=usePreScript.state
		cp.preScript=preScript.text
		cp.usePostScript=usePostScript.state
		cp.postScript=postScript.text
		cp.autoUpdateName=autoUpdateName.checked
		cp.disableFinalOutput=disableFinalOutput.checked
		cp.cameraTgl=cameraTgl.checked

		cp._CameraExport=_CameraExport.checked

		if(cameraTgl.checked) then
		(
				if(_cameraDDL.selection>0) then
				(
					theCam=cameraList[_cameraDDL.selection]
					if (isvalidnode theCam) then
						cp._Camera=theCam

				)
		)
		theNode.text=LPM_Fun.generateCommonPropName cp
		LPM_treeview_rollout.UnFreezeWindow()
	)
	catch( messagebox "LPM failed to save common properties" title:"LPM Error")

	)
)




-------------------------------------------------------------------------------------------------------   setPickerRollout   -------------------------------------------------------------------------------------------------------

rollout setPicker "Pick the Set"
(
	dropDownList theSets

	on setPicker open do
	(

		LPM_treeview_rollout.FreezeWindow()
		if(getNumNamedSelSets()==0) then
			theSets.items=#("")
		theSets.items=(for i=1 to getNumNamedSelSets() collect getNamedSelSetName i)
	)
	on setPicker close do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.namedSet[theObjectSet.namedSet.count+1]=theSets.selected
		LPM_treeview_rollout.UnFreezeWindow()

		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode

		LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
		LPM_treeview_rollout.updateTV()
	)
)




-------------------------------------------------------------------------------------------------------   matPickerRollout   -------------------------------------------------------------------------------------------------------

rollout matPicker "Pick the Material"
(
	dropDownList theSets


	on matPicker open do
	(
		LPM_treeview_rollout.FreezeWindow()
		theSets.items=(for it in scenematerials collect it.name)
	)

	on matPicker close do
	(
		if(theSets.selection>0) then
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			append theObjectSet.mats theSets.selected
		)
		LPM_treeview_rollout.UnFreezeWindow()
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode

		LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
		LPM_treeview_rollout.updateTV()
	)
)




-------------------------------------------------------------------------------------------------------   layerPickerRollout   -------------------------------------------------------------------------------------------------------

rollout layerPicker "Pick Layers" height:420 width:200
(
	Label HintLabel "[Ctrl-Click] To pick multiple layers"
	--multiListBox theLayers height:30 width:190 pos:[5,20]

	dotNetControl theLayers "system.windows.forms.listView" height:400 width:190 pos:[5,20]

	on layerPicker open do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_treeview_rollout.FreezeWindow()
		fn compareFN v1 v2 = if((LPM_Fun.uppercase v1) < (LPM_Fun.uppercase v2)) then return -1 else return 1

		items=#()
		for i=1 to LayerManager.count do
		(
			layerName = ((LayerManager.getLayer (i-1)).name)
			if (layerName != "zz-LPM") do append items layerName
		)
		qsort items compareFN
		--theLayers.items=items
		--now select
		--theLayers.selection=(for i=1 to theLayers.items.count where (findItem theObjectSet.layers theLayers.items[i])!=0  collect i)



		x=LPM_Fun.getIni "Layer Picker" "X_Size" integer 185
		y=LPM_Fun.getIni "Layer Picker" "Y_Size" integer 260

		layerPicker.height=y
		layerPicker.width=x
		theLayers.width=x-10



		LPM_Fun.InitListView theLayers "Layers" theLayers.width
		LPM_Fun.FillListView theLayers items theObjectSet.layers
	)

	on layerPicker close do
	(
		LPM_Fun.setIni "Layer Picker" "X_Size" (layerPicker.width as string)
		LPM_Fun.setIni "Layer Picker" "Y_Size" (layerPicker.height as string)

		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		--theObjectSet.layers=(for i=1 to theLayers.items.count where theLayers.selection[i] collect theLayers.items[i])
		theObjectSet.layers = LPM_Fun.SaveListView theLayers
		LPM_treeview_rollout.UnFreezeWindow()
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode

		LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
		LPM_treeview_rollout.updateTV()
	)

	on layerPicker resized theSize do
	(
		if theSize[1] < 200 then
		(
			layerPicker.width = 200
		)
		if theSize[2] < 250 then
		(
			layerPicker.height = 250
		)


		theLayers.width=layerPicker.width-10
		theLayers.height=layerPicker.height-25
	)


)




-------------------------------------------------------------------------------------------------------   AboutRO   -------------------------------------------------------------------------------------------------------

rollout AboutRO "About LPM 1.09" width:265 height:180
(
	button bmp1 "" pos:[6,8] width:250 height:100 images:#(iconPath  + "lpm.jpg", undefined, 1, 1, 1, 1, 1)
	HyperLink lbl1 "www.Lukashi.com" address:"http://www.lukashi.com" pos:[73,145] width:113 height:15
	label lbl2 "Lukashi@Gmail.com" pos:[74,161] width:113 height:15
	label lbl3 "L Pass Manager by Lukas Lepicovsky" pos:[37,112] width:186 height:15
	label lbl4 "Copyright 2008, All rights reserved." pos:[46,129] width:186 height:16
	--hyperLink lbl5 "Modified by grover_gol. 2014" pos:[56,190] width:186 height:15 address: "http://gg3dcg.ru/"
	--hyperLink lbl6 "for Altspace" pos:[100,210] width:186 height:15 address: "http://altspace.com/"
	--label lbl6 "http://gg3dcg.ru/" pos:[56,210] width:186 height:15
	on bmp1 pressed do
	(
		shellLaunch "http://www.lukashi.com/LPM.php" ""
	)
)

rollout AboutNewRO "About LPM 2.0" width:313 height:250
(
	button bmp1 "" pos:[6,8] width:300 height:100 images:#(iconPath  + "lpm_2.0.jpg", undefined, 1, 1, 1, 1, 1)

	HyperLink lbl5 "in Altspace. 2015" pos:[160,113] width:186 height:15 address:"http://altspace.com/"
	HyperLink lbl6 "Made by grover_gol" pos:[60,113] width:186 height:15 address:"http://grovergol.com/"
	label lbl6fd "Great thanks for ideas, testing and other help:" pos:[50,170] width:256 height:15

	editText edt1 "" pos:[6,191] width:300 height:51 editable:false text:"Tiufyakov Kirill, Muzalev Vladimir, Ilya Rutkovsky,\nEvgeny Kashin, gzibon, weaponer, ertaro,\nDmitry Grigorev, Filipp Gorbachev"


	on bmp1 pressed do
	(
		shellLaunch "http://www.grovergol.com/?page_id=338" ""
	)
)




















-------------------------------------------------------------------------------------------------------   Right Click Menues   ----------------------------------------------------------------------------------------------------------------------------------------------------------------












-------------------------------------------------------------------------------------------------------   MainMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_MainMenu
(
	local scenePath=(getdir #maxroot)+"Scenes\\LPM\\"

	menuItem	renderDialog	"Render..."
	menuItem settingsMenu "Settings..."
	subMenu "Utilities"
	(
		menuItem nukeSceneGenerate "Build scene from Nuke Script"
		seperator s1
		menuitem elementGenerate "Generate Default Elements"
		--menuItem elementDepthSet "Set Depth Element Distance"
		menuItem elementAOSet "Set AO Element Size"
-- 		seperator s1
	)

	subMenu		"Help"
	(
		subMenu		"LPM 1.09 Help"
		(
			menuItem	helpMenu	"LPM 1.09 Help"
			menuItem	AboutMenu	"About LPM 1.09..."
		)

		menuItem hotkeyMenu "Hotkeys..."
		menuItem	HelpMenuNew	"LPM 2.0 Help..."

		menuItem	AboutMenuNew	"About LPM 2.0..."
	)

	on elementGenerate picked do
	(
		filein "makeRenderElements.ms" -- Dabelow
	)

	on nukeSceneGenerate picked do
	(

		nukeScriptDir = getOpenFileName \
		types:"Nuke Scripts(*.nk)"
		print nukeScriptDir
		if nukeScriptDir != undefined then
		(
			try
			(
				LPM_NukeAPI.ImportNuke nukeScriptDir
			)
			catch
			(
				print "Error with file selection"
			)
		)
	)

-- 	on elementDepthSet picked do
-- 	(
-- 		utilityTools.rollout_setDepthprops_Function()
-- 		messagebox "DEPTH"
-- 	)

	on elementAOSet picked do
	(
		utilityTools.rollout_setAOprops_Function()
-- 		messagebox "AO"
	)

	on quickScripts picked do
	(
		LPM_Fun.quickScripts()
	)


	on helpMenuNew picked do
	(
		shellLaunch "http://www.grovergol.com/?page_id=9" ""
	)

	on helpMenu picked do
	(
		shellLaunch "http://www.lukashi.com/LPM.php" ""
	)

	on aboutMenu picked do
	(
		createDialog AboutRo pos:(LPM_Fun.getRoPos AboutRo.width)
	)

	on aboutMenuNew picked do
	(
		createDialog AboutNewRo pos:(LPM_Fun.getRoPos AboutRo.width)
	)

	on renderDialog picked do
	(
		filein (LPM_Dir + "RenderRO.ms")

	)

	on settingsMenu Picked do
	(

		filein (LPM_Dir + "SettingsRO.ms")


	)


	on hotkeyMenu picked do
	(
		rollout helpRollout "Hotkeys" width:249 height:545
		(
			GroupBox grp1 "Hotkeys" pos:[4,7] width:240 height:533
			label lbl6 "MMB +" pos:[15,29] width:59 height:18
			label lbl7 "Pass    Object Set    LightSet  Node          Layer       Group           Wildcard     Named Set" pos:[82,31] width:59 height:107
			label lbl8 "= Hide all except         picked item." pos:[140,29] width:92 height:41
			label lbl9 "Ctrl + MMB +" pos:[15,148] width:66 height:18
			label lbl10 "Object Set    LightSet  Node          Layer       Group           Wildcard     Named Set" pos:[84,148] width:59 height:107
			label lbl11 "= Unhide picked        item." pos:[141,148] width:92 height:41
			GroupBox grp3 "" pos:[11,20] width:224 height:120
			GroupBox grp4 "" pos:[11,138] width:225 height:105
			GroupBox grp5 "" pos:[11,240] width:226 height:102
			label lbl12 "MMB +            Shot" pos:[15,250] width:128 height:18
			label lbl13 "- Set viewport to shot camera.           - Set time range to shot time range.     - Select  shot camera." pos:[143,247] width:92 height:89
			label lbl14 "=" pos:[129,250] width:9 height:14
			GroupBox grp6 "" pos:[10,343] width:226 height:30
			label lbl15 "MMB +            Empty Space     =    Unhide All" pos:[14,353] width:217 height:18
			GroupBox grp8 "" pos:[9,375] width:226 height:30
			label lbl16 "F2, Enter =   Rename Picked Item" pos:[13,385] width:217 height:18
			GroupBox grp7 "" pos:[10,411] width:226 height:30
			label lbl12et "F5 =   Update TreeView" pos:[13,421] width:217 height:18
			label lbl13vd "Drad n Drop + Shift" pos:[13,451] width:99 height:18
			GroupBox grp8vdfv "" pos:[10,442] width:226 height:93
			label lbl14fsrdf "Pass =" pos:[118,451] width:37 height:18
			label lbl15efe "Make Adjustment" pos:[146,465] width:87 height:18
			label lbl16sdf "Other =" pos:[118,479] width:41 height:18
			label lbl17zsdg "Instance" pos:[146,493] width:87 height:18
			label lbl18zsf "Drad n Drop + Ctrl = Copy" pos:[13,510] width:213 height:18
		)
		createDialog helpRollout pos:(LPM_Fun.getROPos helpRollout.width)
	)



)




-------------------------------------------------------------------------------------------------------   RootMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_RootMenu
(
	menuItem   addPass "New Pass"
	menuItem passGroupAdd "New Group"
	seperator s1
	menuItem sortPasses "Sort Passes and Groups"
	menuItem collAlltree "Collapse All"
	seperator s69
	menuItem EnableAllPasses "Enable All Passes"
	menuItem DisableAllPasses "Disable All Passes"
	seperator s69ghw
	menuItem miPreviewAll "Preview All Passes"
	menuItem miPreviewAll50 "Preview All Passes Half"
	seperator s69g
	menuItem deleteAllPasses "Delete All Passes and Groups"

	on EnableAllPasses picked do
	(

		for itGroup in LPM_Root.children where itGroup.type=="passGroup" do
		(
			for it in itGroup.children where it.type=="pass" do
			(
				it.active = true
			)
		)


		for it in LPM_Root.children where it.type=="pass" do
		(
			it.active = true
		)
		LPM_treeview_rollout.updateTV()

	)

	on DisableAllPasses picked do
	(

		for itGroup in LPM_Root.children where itGroup.type=="passGroup" do
		(
			for it in itGroup.children where it.type=="pass" do
			(
				it.active = false
			)
		)


		for it in LPM_Root.children where it.type=="pass" do
		(
			it.active = false
		)
		LPM_treeview_rollout.updateTV()

	)

	on miPreviewAll picked do
	(
		LPM_Fun.whoToRender=LPM_Fun.collectPasses()
		LPM_Fun.renderSubmit #preview
	)

	on miPreviewAll50 picked do
	(
		LPM_Fun.whoToRender=LPM_Fun.collectPasses()
		LPM_Fun.renderSubmit #previewHalf
	)

	on collAlltree picked do
	(
		LPM_Treeview_Rollout.collapseAlltree()
	)

	on passGroupAdd picked do
	(
		theProps=LPM_Fun.createPassGroup "Group"
		theProps.parent=LPM_Root
		newPg=LPM_treeview_rollout.createPassGroupTv theProps
	)

	on addPass picked do
	(
		LPM_Fun.createDefaultPass()
	)

	on sortPasses picked do
	(
		passArray=for it in LPM_Root.children where it.type=="pass" collect it
		qsort passArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
		for it in passArray do
		(	it.parent=undefined
			it.parent=LPM_Root
		)

		passArray=#()

		passArray=for it in LPM_Root.children where it.type=="passGroup" collect it
		qsort passArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
		for it in passArray do
		(	it.parent=undefined
			it.parent=LPM_Root
		)

		passArray=#()

		for itGroup in LPM_Root.children where itGroup.type=="passGroup" do
		(
			passArray=for it in itGroup.children where it.type=="pass" collect it
			qsort passArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
			for it in passArray do
			(	it.parent=undefined
				it.parent=itGroup
			)
		)

		LPM_treeview_rollout.updateTV()

	)
	on deleteAllPasses picked do
	(
		undo "LPM delete" on
		(
			ans=queryBox "Are you sure you want to delete all passes?"
			if(ans) then
			(
				for it in LPM_Root.children where it.type=="pass" do
				(
					for jt in (LPM_Fun.getAllChildren it) do delete jt
				)

				for itGroup in LPM_Root.children where itGroup.type=="passGroup" do
				(
					for it in itGroup.children where it.type=="pass" do
					(
						for jt in (LPM_Fun.getAllChildren it) do delete jt
					)
				)

				for it in LPM_Root.children where it.type=="passGroup" do
				(
					for jt in (LPM_Fun.getAllChildren it) do delete jt
				)

				LPM_treeview_rollout.updateTV()
			)
		)
	)
)




-------------------------------------------------------------------------------------------------------   shotRootMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_shotRootMenu
(
	menuItem    newShot "New Shot"
	seperator s1
	menuItem sortShots "Sort Shots"
	menuItem deleteAllShots "Delete All Shots"

	on newShot picked do
	(
		theShot=LPM_Fun.createShot LPM_Root
		shotNode=LPM_treeview_rollout.createShotTv theShot
		LPM_treeview_rollout.addShotTv shotNode
		LPM_Treeview_Rollout.renameNode shotNode
		--shotNode.beginEdit()
	)
	on sortShots picked do
	(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"
		shotArray=for it in shotRoot.children where it.type=="shot" collect it
		qsort shotArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
		for it in shotArray do
		(	it.parent=undefined
			it.parent=shotRoot
		)
		LPM_treeview_rollout.updateTV()
	)
	on deleteAllShots picked do
	(
		undo "LPM delete" on
		(
			shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"
			ans=queryBox "Are you sure you want to delete all shots?"
			if(ans) then
			(
				for it in shotRoot.children where it.type=="shot" do
				(
					for jt in (LPM_Fun.getAllChildren it) do delete jt
				)
				LPM_treeview_rollout.updateTV()
			)
		)
	)
)




-------------------------------------------------------------------------------------------------------   PassGroupMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_PassGroup
(
	menuItem previewGroup "Render Preview Group 100%"
	menuItem previewGroupHalf "Render Preview Group 50%"
	seperator s2
	menuItem submitLocal "Submit Group Local"
	menuItem submitNetwork "Submit Group Network"
	seperator s1
	menuItem deleteGroup "Delete Group, Keep Passes"
	menuItem deleteGroupChildren "Delete Group, Delete Passes"

	on deleteGroup picked do
	(
		undo "LPM delete" on
		(
			grp=LPM_treeview_rollout.tv.selectedNode.tag.value
			for child in grp.children do
			(
				child.parent=LPM_Root
			)
			delete grp
			LPM_treeview_rollout.updateTV()
		)
	)
	on deleteGroupChildren picked do
	(
		undo "LPM delete" on
		(
			if(querybox "Are you sure you want to delete the group and all its passes?") then
			(
				grp=LPM_treeview_rollout.tv.selectedNode.tag.value
				chld=LPM_Fun.getAllChildren grp
				delete chld
				LPM_treeview_rollout.updateTV()
			)
		)
	)
	fn submitPG RenderType=
	(
		pg=LPM_treeview_rollout.tv.selectedNode.tag.value
		whoToRender=#()

		whoToRender=for pass in pg.children where  (isvalidnode pass) and (pass.type=="pass") and (pass.active)  collect #(pass)
		LPM_Fun.whoToRender=whoToRender
		if(RenderType==#network) then
			LPM_Fun.launchNetworkRender()
		else
			LPM_Fun.renderSubmit RenderType


	)

	on submitLocal picked do
	(
		submitPG #local
	)
	on submitNetwork picked do
	(
		submitPG #network
	)
	on previewGroup picked do
	(
		submitPG #preview
	)
	on previewGroupHalf picked do
	(
		submitPG #previewHalf
	)
)




-------------------------------------------------------------------------------------------------------   shotMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_shotMenu
(
	menuItem SelectPasses "Include Passes..."

	seperator s2
	menuItem revealInExplorerShot "Reveal in Explorer"

	seperator s1
	menuItem    AddCommon "Add Common Properties"
	menuItem    AddCameraOverscan "Add Camera Overscan Override" 	-- Dabelow cameraOverscan
	menuItem    AddNukeExport "Add Nuke Export" 					-- Dabelow nukeExport
	menuItem    AddAeExport "Add After Effect Export" 				-- Dabelow aeExport

	seperator s4
	menuItem renderShot "Submit Local"
	menuItem renderShotNetwork "Submit Network"

	seperator sepr4
	menuItem deleteShot "Delete Shot"


	on AddCommon picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		if((LPM_Fun.firstChildByType thePass "commonProps")==undefined) then
		(
			theProps=LPM_Fun.createCommonProps "commonProps"
			theProps.parent=thePass
			LPM_treeview_rollout.addShotTv LPM_treeview_rollout.tv.selectedNode
		)
	)

	on AddCameraOverscan picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		if((LPM_Fun.firstChildByType thePass "cameraOverscan")==undefined) then
		(
			theProps=LPM_Fun.createCameraOverscanProps "cameraOverscan"
			theProps.parent=thePass
			LPM_treeview_rollout.addShotTv LPM_treeview_rollout.tv.selectedNode
		)
	)

	on AddNukeExport picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		if((LPM_Fun.firstChildByType thePass "nukeExport")==undefined) then
		(
			theProps=LPM_Fun.createNukeExportProps "nukeExport"
			theProps.parent=thePass
			LPM_treeview_rollout.addShotTv LPM_treeview_rollout.tv.selectedNode
		)
	)

	on AddAeExport picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		if((LPM_Fun.firstChildByType thePass "aeExport")==undefined) then
		(
			theProps=LPM_Fun.createAeExportProps "aeExport"
			theProps.parent=thePass
			LPM_treeview_rollout.addShotTv LPM_treeview_rollout.tv.selectedNode
		)
	)

	on revealInExplorerShot picked do
	(
		theShot = LPM_treeview_rollout.tv.selectedNode.tag.value
		curPath = ( LPM_Root.rootDir + (LPM_Fun.getName theShot.name) + @"\" )
		shellLaunch curPath ""
	)

	on viewRamPlayer picked do
	(
		rollout LPM_shotPicker "Ram Player"
		(
			local passArray=#()
			local theShot

			label shotLabel align:#left
			dropdownlist passDDL

			on LPM_shotPicker open do
			(
				theShot=LPM_treeview_rollout.tv.selectedNode.tag.value
				shotLabel.text="Shot: "+(LPM_Fun.getName theShot.name)
				passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
				passDDL.items=for it in passArray collect
				(

					thePath=LPM_Fun.getPassPath LPM_Root it theShot:theShot elementName:"Beauty"

					fileList= getfiles ((getFilenamePath thePath) + (getFileNameFile thePath) + "*" + (getFileNametype thePath))

					if(fileList.count==0) then
						(LPM_Fun.getname it.name) + " (Missing)"
					else
						(LPM_Fun.getname it.name)

				)

			)
			on passDDL selected item do
			(
				thePath=LPM_Fun.getPassPath LPM_Root passArray[item] theShot:theShot elementName:"Beauty"
				LPM_Fun.viewRamplayer thePath

			)
		)
		createDialog LPM_shotPicker pos:(LPM_Fun.getRoPos LPM_shotPicker.width)

	)

	on selectPasses picked do
	(
		filein (LPM_Dir + "IncludePassesRO.ms")
	)

	on deleteShot picked do
	(
		undo "LPM delete" on
		(
			LPM_treeview_rollout.deleteSelectedPass LPM_treeview_rollout.tv
		)
	)

	on renderShot picked do
	(
		theShot=LPM_treeview_rollout.tv.selectedNode.tag.value

		whoToRender=#()
		if(theShot.allpasses) then
			whoToRender=LPM_Fun.collectPasses activeOnly:true theShot:theSHot
		else
			whoToRender=for i=1 to theShot.passes.count where  (isvalidnode theShot.passes[i]) and (theShot.passes[i].type=="pass") and (theShot.passesOn[i]) and (theShot.passes[i].active) collect #(theShot.passes[i], theShot)
		LPM_Fun.whoToRender=whoToRender

		if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
		(
			LPM_Fun.renderSubmit #hwPreview
		)
		else
		(
			LPM_Fun.renderSubmit #local
		)


	)
	on renderShotNetwork picked do
	(
		theShot=LPM_treeview_rollout.tv.selectedNode.tag.value

		whoToRender=#()
		if(theShot.allpasses) then
			whoToRender=LPM_Fun.collectPasses activeOnly:true theShot:theSHot
		else
			whoToRender=for i=1 to theShot.passes.count where  (isvalidnode theShot.passes[i]) and (theShot.passes[i].type=="pass") and (theShot.passesOn[i]) and (theShot.passes[i].active) collect #(theShot.passes[i], theShot)
		LPM_Fun.whoToRender=whoToRender
		LPM_Fun.launchNetworkRender()

	)

)




-------------------------------------------------------------------------------------------------------   shotPassMenu   -------------------------------------------------------------------------------------------------------

rcmenu rc_shotPassMenu
(
	menuItem remove "Delete"
	on remove picked do
	(
		undo "LPM delete" on
		(
			theShot=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
			index=LPM_treeview_rollout.tv.selectedNode.tag.value.index
			deleteItem theShot.passes index
			deleteItem theSHot.passesOn index
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.fillInTreeView LPM_treeview_rollout.tv -- DABELOW
		)
	)


)




-------------------------------------------------------------------------------------------------------   PassMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_PassMenu
(
	menuItem    previewThisPass "Render Preview 100%"
	menuItem    preview50ThisPass "Render Preview"
	menuItem    renderThisPass "Submit Local"
	menuItem	renderThisPassNetwork "Submit Network"
	seperator set2
	menuItem editPassSettings "Edit..."
	--seperator set4
	subMenu "Add"
	(
		menuItem objectSetAdd "Object Set"
		menuItem lightSetAdd "Light Set"
		seperator set8
		menuItem commonPropsAdd "Common Properties Override"
		menuItem effectsPropsAdd "Element, Environment and Effects Override"
		menuItem renderPropsAdd "Renderer Override"
		menuItem deadlineAdd "Deadline Override" 								-- Dabelow
		--menuItem vrayPropsAdd "Vray Override"
		--menuItem VrayGIAdd "V-Ray GI"
		--menuItem ModifierOverAdd "Modifier Override"
		--menuItem AutoMaskAdd "AutoMask"
		menuItem xrefObjAdd "Xref Object Override"
		menuItem xrefSceneAdd "Xref Scene Override"
		menuItem scriptAdd "Script"
		seperator set5
		menuItem vray5PropsAdd "Vray5 Override" 								-- Dabelow vray5
		menuItem vray5RenderElementsPropsAdd "Vray5 RenderElement Override" 	-- Dabelow vray5
	)
	seperator set10
	menuItem    duplicatePass "Duplicate Pass"
	menuItem duplicateInstPass "Duplicate Pass with instances"
	menuItem paste "Paste"
	menuItem pasteInstanced "Paste Instanced"
	-- seperator set12
	-- menuItem	viewPass "View Bitmap"
	-- menuItem viewPassRam "View Ram Player"
	seperator set11
	menuItem    deletePass "Delete Pass"





	on rc_PassMenu open do
		preview50ThisPass.text="Render Preview "+(LPM_root.previewSize as string) + "%"

	on editPassSettings picked do
	(
		filein (LPM_Dir + "passSettingsRO.ms")
	)
	on deletePass picked do
	(
		undo "LPM delete" on
		(
			LPM_treeview_rollout.deleteSelectedPass LPM_treeview_rollout.tv

			LPM_activePass = undefined

			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on previewThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_renderPass thePass #preview
	)
	on preview50ThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_renderPass thePass #previewHalf
	)
	on renderThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value

		if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
		(
			LPM_hardwareRender thePass
		)
		else
		(
			LPM_renderPass thePass #local
		)

	)
	on renderThisPassNetwork picked do
	(
		if not((LPM_Root.renderType==2) or (LPM_Root.renderType==4)) then
		(
			LPM_Fun.whoToRender=#(#(LPM_treeview_rollout.tv.selectedNode.tag.value))
			LPM_Fun.launchNetworkRender()
		)
		else
		(
			messageBox "Turn Hardware Preview render mode off." title:"Warning."
		)
	)
	on viewPass picked do
	(
		gc light:true delayed:false
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		fname= LPM_Fun.getPreviewFile thePass
		print fName
		theBM=undefined
		if((getfiles fname).count != 0) then
		(
			theBM=(openBitMap fname)
			display theBM
		)

		theBM=undefined
	)
	on viewPassRam picked do
	(
		thePath=(LPM_Fun.getPassPath LPM_Root (LPM_treeview_rollout.tv.selectedNode.tag.value)  elementName:"Beauty")
		LPM_Fun.viewRamplayer thePath
	)

	on commonPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "commonProps")==undefined) then
		(
			theProps=LPM_Fun.createCommonProps "Common Props"
			theProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
			--edit: Jake Jeziorski with auto-name option it's just annoying to rename
			--LPM_fun.editLabelByNode theProps LPM_treeview_rollout.tvroot
		)
	)
	on newOperator picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		LPM_Operators.fnNewOperator thePass
		LPM_treeview_rollout.addPassTV thePassNode
	)
	on scriptAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		theScript=LPM_Fun.createScript "Script"
		theScript.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theScript LPM_treeview_rollout.tvroot

	)



	on xrefObjAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "xrefObj")==undefined) then
		(
			theProps=LPM_Fun.createNode "Xref Object" "xrefObj"
			theProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)

	on xrefSceneAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "xrefScene")==undefined) then
		(
			theProps=LPM_Fun.createNode "Xref Scene" "xrefScene"
			theProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)

	on renderPropsAdd picked do
	(
		filein (LPM_Dir + "renderPropsAdd.ms")
	)

	on VrayGIAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "VRayGI")==undefined) then
		(
			VrayGIOver = LPM_Fun.createNode "V-Ray GI" "VRayGI"
			VrayGIOver.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)

	on AutoMaskAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "AutoMask")==undefined) then
		(
			VrayGIOver = LPM_Fun.createNode "AutoMask" "AutoMask"
			VrayGIOver.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)

	-- Dabelow
	on deadlineAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createDeadlineProps "Deadline"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode

	)

		-- Dabelow vray5
	on vray5RenderElementsPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createVray5RenderElementsProps "vray5RenderElements"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode

	)

	-- Dabelow vray5
	on vray5PropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createVray5Props "vray5"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode

	)

	on vrayPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createVrayProps "Vray Override"

		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode

	)

	on effectsPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		if((LPM_Fun.firstChildByType thePass "envProps")==undefined) then
		(
			envProps=LPM_Fun.createNode "Environment Override" "envProps"
			envProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
			--LPM_fun.editLabelByNode envProps LPM_treeview_rollout.tvroot
		)
	)

	on ModifierOverAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		theModifierOver = LPM_Fun.createNode "Modifier Override" "ModifierOver"
		theModifierOver.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theModifierOver LPM_treeview_rollout.tvroot

	)


	on photoStudioAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		global LPM_Photostudio_Skip_Warning
		if((LPM_Fun.firstChildByType thePass "photoStudio")==undefined) then
		(
			if (not (iskindof SceneExposureControl.exposureControl Logarithmic_Exposure_Control)) and (LPM_Photostudio_Skip_Warning!=true) then
			(
				rollout LPM_PS_Warning "Logarithmic Exposure Control" width:412 height:152
				(
					label lbl1 "You are creating a PhotoStudio Override" pos:[11,9] width:282 height:18
					label lbl2 "It is recommended that you use a Logarithmic Exposure Control with Brightness=65.0, Exterior daylight=true" pos:[11,33] width:324 height:32
					label lbl3 "Would you like to set this up now?  Futher changes can be made in the Environment and Effects Dialog" pos:[11,66] width:321 height:32
					button YesButton "Yes" pos:[10,103] width:86 height:24
					button NoButton "No" pos:[106,103] width:86 height:24
					checkbox warnAgain "Don't Warn Me Again (For this Session)" pos:[10,130] width:204 height:19

					on warnAgain changed value do LPM_Photostudio_Skip_Warning=value
					on yesButton pressed do
					(
						SceneExposureControl.exposureControl=Logarithmic_Exposure_Control()
						SceneExposureControl.exposureControl.brightness = 65
						SceneExposureControl.exposureControl.physicalScale = 80000
						SceneExposureControl.exposureControl.exteriordaylight = on
						destroyDialog LPM_PS_Warning
					)
					on noButton pressed do
					(
						destroyDialog LPM_PS_Warning
					)

				)

				createDialog LPM_PS_Warning

			)

			psProps=LPM_Fun.createPhotoStudio "Photo Studio"
			psProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
			LPM_fun.editLabelByNode envProps LPM_treeview_rollout.tvroot
		)
	)

	on objectSetAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		theSet=LPM_Fun.createObjectSet "New Set"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theSet LPM_treeview_rollout.tvroot
	)
	on lightSetAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		thePass.expanded = true
		theSet=LPM_Fun.createLightSet "New Set"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theSet LPM_treeview_rollout.tvroot
	)
	on duplicatePass picked do
	(
		oldNode=LPM_treeview_rollout.tv.selectedNode
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		theCopy=copy thePass
		thePass.layer.addnode theCopy

		for it in thePass.children do
		(
			newProp=copy it
			newProp.name=it.name
			newProp.parent=theCopy
			thePass.layer.addnode newProp
		)
		newNode=LPM_Treeview_rollout.createPassTv theCopy oldNode.parent
		LPM_treeview_rollout.addPassTV newNode

		LPM_treeview_rollout.updateTV()
		--newNode.beginEdit()
	)

	on duplicateInstPass picked do
	(
		oldNode=LPM_treeview_rollout.tv.selectedNode
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		theCopy=copy thePass
		thePass.layer.addnode theCopy

		chkDoesHaveInst = false

		for it in thePass.children do
		(
			if(InstanceMgr.GetInstances it #() >1) then
			(
				chkDoesHaveInst = true
			)
		)

		if chkDoesHaveInst then
		(
			for it in thePass.children do
			(
				newProp=""
				if(InstanceMgr.GetInstances it #() >1) then
				(
					newProp=instance it
				)
				else
				(
					newProp=copy it
				)
				newProp.name=it.name
				newProp.parent=theCopy
				thePass.layer.addnode newProp
			)
		)
		else
		(
			for it in thePass.children do
			(

				newProp=instance it

				newProp.name=it.name
				newProp.parent=theCopy
				thePass.layer.addnode newProp
			)
		)
		newNode=LPM_Treeview_rollout.createPassTv theCopy oldNode.parent
		LPM_treeview_rollout.addPassTV newNode

		LPM_treeview_rollout.updateTV()
		--newNode.beginEdit()
	)

	on paste picked do
	(
		if(isvalidnode LPM_treeview_rollout.copyNode) then
		(
			newNode=copy LPM_treeview_rollout.copyNode
			newNode.name=LPM_treeview_rollout.copyNode.name
			newNode.parent=undefined
			LPM_Fun.addToLPMLayer newNode

			thePassNode=LPM_treeview_rollout.tv.selectedNode
			thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
			thePass.expanded = true
			case LPM_treeview_rollout.copyNode.type of
			(
				"commonProps":for it in thePass.children where it.type=="commonProps" do (delete it)
				"envProps":for it in thePass.children where it.type=="envProps" do (delete it)
			)

			newNode.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on pasteInstanced picked do
	(
		if(isvalidnode LPM_treeview_rollout.copyNode) then
		(
			newNode=instance LPM_treeview_rollout.copyNode
			newNode.name=LPM_treeview_rollout.copyNode.name
			newNode.parent=undefined
			LPM_Fun.addToLPMLayer newNode

			thePassNode=LPM_treeview_rollout.tv.selectedNode
			thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
			thePass.expanded = true
			case LPM_treeview_rollout.copyNode.type of
			(
				"commonProps":for it in thePass.children where it.type=="commonProps" do (delete it)
				"envProps":for it in thePass.children where it.type=="envProps" do (delete it)
			)

			newNode.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode

			LPM_treeview_rollout.updateTV()
		)
	)
)




-------------------------------------------------------------------------------------------------------   commonPropsMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_commonPropsMenu
(
	menuItem	editProps	"Edit..."
	menuItem copyProps "Copy"

	seperator sp1
	menuItem grabTime "Grab Active Time"
	menuItem grabCamera "Grab Active Camera"
	seperator sp2
	menuItem selectCamera "Select Camera"
	seperator sp68
	menuItem   removeProps "Delete"
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on removeProps picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on editProps picked do
	(
		createDialog commonRollout pos:(LPM_Fun.getRoPos  commonRollout.width)
	)
	on grabtime picked do
	(

		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		cp.timeOutputTgl=true
		cp._rendTimeType=3
		cp._rendStart=animationRange.start
		cp._rendEnd=animationRange.end
		LPM_treeview_rollout.tv.selectedNode.text=LPM_Fun.generateCommonPropName cp
	)
	on grabCamera picked do
	(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(getActiveCamera()!=undefined) then
		(
			cp.cameraTgl=true
			cp._Camera=getActiveCamera()
			LPM_treeview_rollout.tv.selectedNode.text=LPM_Fun.generateCommonPropName cp
		)
		else
			messagebox "The active node is not a camera"
	)
	on selectCamera picked do
	(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(isvalidnode cp._Camera) then
			select cp._Camera
	)

)


rcMenu rc_LPMVrayGIMenu
(
	menuItem	EditVrayGI "Edit..."
	menuItem    copyVrayGI "Copy"
	seperator sp664g
	menuItem    ExploreVrayGI "Explore VrayGI folder"
	seperator sp66re
	menuItem    removeVrayGI "Delete"

	on ExploreVrayGI picked do
	(
		try
		(
			VRayGIobj=LPM_treeview_rollout.tv.selectedNode.tag.value
			shellLaunch (LPM_Fun.GetVRayGIPath VRayGIobj) ""
		)
		catch
		(

		)
	)

	on copyVrayGI picked do
	(
		LPM_treeview_rollout.copyNode = LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on removeVrayGI picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)

	on EditVrayGI picked do
	(
		LPM_treeview_rollout.EditVrayGI()
	)
)


rcMenu rc_AutoMaskMenu
(
	menuItem	EditAutoMask "Edit..."
	menuItem    copyAutoMask "Copy"

	seperator sp66re
	menuItem    removeAutoMask "Delete"



	on copyAutoMask picked do
	(
		LPM_treeview_rollout.copyNode = LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on removeAutoMask picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)

	on EditAutoMask picked do
	(
		LPM_treeview_rollout.EditAutoMask()
	)
)



-------------------------------------------------------------------------------------------------------   ObjectSetMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_ObjectSetMenu
(

	menuItem   editSet "Edit..."
	menuItem   editVraySet "Edit Vray..."
	menuItem	copySet	"Copy"
	separator sep2krw
	menuItem	copySetProps	"Copy properties"
	menuItem	PasteSetProps	"Paste properties"
	separator sep2krwef
	submenu "Add"
	(

		menuItem   addObjects "Add Selected Objects"
		menuItem	addLayers	"Add Layers"
		menuItem   addWildCard "Add by Wildcard"
		menuItem   addNamedSet "Add Selection Set"
		menuItem 	AddMats "Add by Material Name"
		menuItem   addGroups "Add Selected Groups"

	)
	submenu "Clear"
	(

		menuitem clearObjects "Clear Objects"
		menuItem clearLayers "Clear Layers"
		menuItem clearWild "Clear Wildcards"
		menuItem clearNamed "Clear Selection Sets"
		menuItem clearAll "Clear All"

	)

	separator sep2
	menuItem selectObjects "Select Objects"
	separator sep22
	menuItem   deleteSet "Delete"

	on editVraySet  picked do
	(
		if(dovrayobjectproperties==undefined) then
			messagebox "Vray not installed"
		else
		(
			if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet") then
			(
				TempLayer = LayerManager.newLayerFromName "VrPropertiesOverrideTempLayer"

				if TempLayer == undefined then
				(
					TempLayer = LayerManager.getLayerFromName "VrPropertiesOverrideTempLayer"

				)

				theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value

				theBuffer=theObjectSet.userProp

				newBox=box()
				TempLayer.addnode newBox
				newBox.name=theObjectSet.name + " Properties Override"

				theBuffer=setUserPropBuffer newBox theBuffer
				select newBox

				y=dovrayobjectproperties()
				theObjectSet.userProp=getUserPropBuffer newBox

				delete newBox
				LayerManager.deleteLayerByName "VrPropertiesOverrideTempLayer"


				theObjectSet.intP[9]=2
			)
		)

	)

	on copySetProps picked do
	(
		LPM_treeview_rollout.CopySetProps()
	)

	on PasteSetProps picked do
	(
		LPM_treeview_rollout.PasteSetProps()
	)

	on clearAll picked do
	(
		undo "LPM clear" on
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.namedSet=#()
			theObjectSet.layers=#()
			theObjectSet.wildcard=#()
			theObjectSet.nodes=#()
			theObjectSet.mats=#()

			thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
			LPM_treeview_rollout.addPassTv thePassNode

			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.updateTV()
		)
	)
	on clearLayers picked do
	(
		undo "LPM clear" on
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.layers=#()

			thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
			LPM_treeview_rollout.addPassTv thePassNode

			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.updateTV()
		)
	)
	on clearNamed picked do
	(
		undo "LPM clear" on
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.namedSet=#()

			thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
			LPM_treeview_rollout.addPassTv thePassNode

			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.updateTV()
		)
	)
	on clearWild picked do
	(
		undo "LPM clear" on
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.wildcard=#()

			thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
			LPM_treeview_rollout.addPassTv thePassNode

			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.updateTV()
		)
	)
	on clearObjects picked do
	(
		undo "LPM clear" on
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.nodes=#()

			thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
			LPM_treeview_rollout.addPassTv thePassNode

			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_treeview_rollout.updateTV()
		)
	)

	on rc_ObjectSetMenu open do
	(
		addNamedSet.enabled=getNumNamedSelSets()>0
	)

	on addLayers picked do
	(
		LPM_treeview_rollout.addVisibleLayers()
	)
	on addMats picked do
	(
		LPM_treeview_rollout.addMats()
	)

	on addWildCard picked do
	(
		LPM_treeview_rollout.addWildCard()
	)
	on addNamedSet picked do
	(
		LPM_treeview_rollout.addNamedSet()
	)

	on addObjects picked do
	(
		LPM_treeview_rollout.addSelectedObjects()
	)
	on copySet picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on addGroups picked do
	(
		LPM_treeview_rollout.addSelectedGroups()
	)

	on deleteSet picked do
	(
		undo "LPM delete" on
		(
			theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
			theObjectSet=theObjectSetNode.tag.value
			delete theObjectSet
			theObjectSetNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)

	on selectObjects picked do
	(
		objSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		tmpCollection=#()
		--named sets
		for it in objSet.namedSet do
		(
			join tmpCollection (for item in selectionSets[it] collect item)
		)
		--wildcard
		for j=1 to objSet.wildCard.count do
		(
			if(objSet.wildCard[j]!="") then
				join tmpCollection (execute ("$"+objSet.wildCard[j]))
		)
		--layers
		LMan=LayerManager
		for j=1 to objSet.layers.count do
		(
			theLayerNodes=#()
			theLayer=LMan.getLayerfromName objSet.layers[j]
			if(theLayer != undefined) then
				theLayer.nodes &theLayerNodes
			join tmpCollection theLayerNodes
		)

		join tmpCollection objSet.nodes

		if(objSet.type=="objectSet") then
			theSelection=for it in tmpCollection where ((((superClassof it) ==geometryClass) or ((superClassof it) ==shape)) and (not (iskindof it particleGroup)))  collect it
		else
			theSelection=for it in tmpCollection where (((superClassof it) ==light) and(not(iskindof it target)))collect it


		try (select theSelection) catch()
	)

	on editSet picked do
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet")then
			createDialog objectSetProps 194 403 pos:(LPM_Fun.getRoPos  194)
		else
			createDialog lightSetProps  pos:(LPM_Fun.getRoPos  194)

	)
)




-------------------------------------------------------------------------------------------------------   matMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_matMenu
(
	menuItem	selectObj	"Select"
	menuItem	removeObj	"Delete"

	on selectObj picked do
	(
		theMat=LPM_treeview_rollout.tv.selectedNode.tag.value.leaf
		max select none
			for sceneMat in scenematerials where (sceneMat.name==theMat) do
				for it in objects where it.material==sceneMat do select it
	)
	on removeObj picked do
	(
		undo "LPM delete" on
		(
			theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
			theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

			LPM_Fun.pruneArray theParent.mats theObj.leaf

			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
)




-------------------------------------------------------------------------------------------------------   objectMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_objectMenu
(
	menuItem	selectObj	"Select"
	menuItem	removeObj	"Delete"

	on selectObj picked do
	(
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		try(select theObj.leaf)catch()
	)

	on removeObj picked do
	(
		undo "LPM delete" on
		(
			theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
			theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

			LPM_Fun.pruneArray theParent.nodes theObj.leaf

			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
)




-------------------------------------------------------------------------------------------------------   layerMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_layerMenu
(

	menuItem addSelectedToLayer "Add Selected Objects"
	menuItem selectObjectsOnLayer "Select Objects"
	menuItem makeActiveLayer "Make Active Layer"
	seperator sp1
	menuItem	removeLayer	"Delete"

	on removeLayer picked do
	(
		undo "LPM delete" on
		(
			theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
			theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

			LPM_Fun.pruneArray theParent.layers theObj.leaf
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on addSelectedToLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName

		theSelection=getCurrentSelection()
		for it in theSelection do
		(
			theLayer.addNode it
		)
	)
	on makeActiveLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName
		theLayer.current=true
	)

	on selectObjectsOnLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName
		theLayer.select on
		--print (refs.dependents theLayer)
		--select



	)
)




-------------------------------------------------------------------------------------------------------   wildCardMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_wildCardMenu
(
	menuItem edit "Edit..."
	menuItem	removeLayer	"Delete"

	on edit picked do
	(
		createDialog wildCardRO pos:(LPM_Fun.getRoPos  wildCardRO.width)
	)

	on removeLayer picked do
	(
		undo "LPM delete" on
		(
			theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
			theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

			theParent.wildcard=(for i=1 to theParent.wildCard.count where i!=theObj.index collect theParent.wildCard[i])
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
)




-------------------------------------------------------------------------------------------------------   namedSetMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_namedSetMenu
(
	menuItem	removeLayer	"Delete"
	on removeLayer picked do
	(
		undo "LPM delete" on
		(
			theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
			theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

			theParent.namedSet=(for i=1 to theParent.namedSet.count where i!=theObj.index collect theParent.namedSet[i])
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
)


-------------------------------------------------------------------------------------------------------   xrefObjMenu   -------------------------------------------------------------------------------------------------------


rcMenu rc_xrefObj
(
	menuItem refresh "Edit..."
	menuItem CopyXrefObj "Copy"
	seperator s1xro
	menuItem openXrefDialog "Open Xref Objects Dialog"
	seperator s1
	menuItem remove "Delete"
	on refresh picked do
	(
		LPM_treeview_rollout.AddXrefObjOverride()
	)
	on CopyXrefObj picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on openXrefDialog picked do
	(
		try(actionMan.executeAction 0 "40876")catch()  -- File: XRef Scenes

	)

)

-------------------------------------------------------------------------------------------------------   xrefSceneMenu   -------------------------------------------------------------------------------------------------------


rcMenu rc_xrefScene
(
	menuItem refresh "Edit..."
	menuItem CopyXrefScene "Copy"
	seperator s1XrefS
	menuItem openXrefDialog "Open Xref Scenes Dialog..."
	seperator s1
	menuItem remove "Delete"
	on refresh picked do
	(
		LPM_treeview_rollout.AddXrefSceneOverride()
	)
	on CopyXrefScene picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on openXrefDialog picked do
	(
		try(actionMan.executeAction 0 "40368")catch()  -- File: XRef Scenes
	)

)




-------------------------------------------------------------------------------------------------------   photoStudioMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_photoStudioMenu
(
	menuItem	editItem "Edit..."
	menuItem    copyAtm "Copy"
	menuItem    remove "Delete"

	on copyAtm picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode
		)
	)
	on editItem picked do
	(
		global active_PS_Prop=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(doesfileexist "$MAX/macroscripts/LPM/PhotoStudio_Ro_Pro.ms") then
			filein "$MAX/macroscripts/LPM/PhotoStudio_Ro_Pro.ms"
		else if(doesfileexist "$MAX/macroscripts/LPM/PhotoStudio_Ro_Demo.ms") then
			filein "$MAX/macroscripts/LPM/PhotoStudio_Ro_Demo.ms"
		else
			messagebox "Photostudio Addon Not Installed" error:"Error"
	)
)




-------------------------------------------------------------------------------------------------------   scriptMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_scriptMenu
(
	menuItem	editItem "Edit..."
	menuItem    copyAtm "Copy"
	menuItem    remove "Delete"
	on copyAtm picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on editItem picked do
	(
		LPM_treeview_rollout.AddScriptOverride()
	)

)




-------------------------------------------------------------------------------------------------------   ModifierOverMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_ModifierOverMenu
(
	menuItem	EditModifierOver "Edit..."
	menuItem    copyModifierOver "Copy"
	seperator sp66
	menuItem    SelModifierOverObj "Select object"
	seperator sp66re
	menuItem    remove "Delete"

	on SelModifierOverObj picked do
	(
		try
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value

			if theNode.activeNode != undefined then
			(
				select theNode.activeNode
			)
		)
		catch
		(

		)
	)

	on copyModifierOver picked do
	(
		LPM_treeview_rollout.copyNode = LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)

	on EditModifierOver picked do
	(
		LPM_treeview_rollout.AddModifierOverride()
	)

)




-------------------------------------------------------------------------------------------------------   atmPropsMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_atmPropsMenu
(
	menuItem	addByName "Edit..."
	menuItem    copyAtm "Copy"
	menuItem    openEnvDialog "Open Environment Dialog"
	seperator sp66
	menuItem    remove "Delete"

	on copyAtm picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on remove picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)

	on addByName picked do
	(
		createdialog atmRollout pos:(LPM_Fun.getRoPos  atmRollout.width)
	)

	on openEnvDialog picked do
	(
		actionMan.executeAction 0 "40029"
	)
)




-------------------------------------------------------------------------------------------------------   RenderPropsMenu   -------------------------------------------------------------------------------------------------------

rcMenu rc_RenderPropsMenu
(
	menuItem	editProps	"Edit..."
	menuItem copyProps "Copy"
	seperator sp1
	menuItem loadDefault "Current Renderer -> Override"
	menuItem setAsDefault "Override -> Current Renderer"
	seperator sp67
	menuItem   removeProps "Delete"

	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)

	on editProps picked do
	(
		filein (LPM_Dir + "renderPropsEdit.ms")
	)

	on removeProps picked do
	(
		undo "LPM delete" on
		(
			theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
			delete theNode
			LPM_treeview_rollout.tv.selectedNode.remove()
			LPM_treeview_rollout.UpdateButtons LPM_treeview_rollout.tv.selectedNode
			LPM_activeElement = LPM_treeview_rollout.tv.selectedNode

			LPM_treeview_rollout.updateTV()
		)
	)
	on loadDefault picked do
	(
		theProp=LPM_treeview_rollout.tv.selectedNode.tag.value
		try
		(
			theProp.propsAlternate=LPM_Fun.saveRenderPresetNew()
		)
		catch
		(
			theProp.props=LPM_Fun.saveRenderPreset()
		)

		theProp.initialized=true
	)
	on setAsDefault picked do
	(
		theProp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(theProp.initialized) then
		(
			try
			(
				LPM_Fun.loadRenderPresetNew theProp.propsAlternate
			)
			catch
			(
				LPM_Fun.loadRenderPreset theProp.props
			)

		)
		else
		(
			messagebox "The selected prop has no render settings stored."
		)

	)
)


