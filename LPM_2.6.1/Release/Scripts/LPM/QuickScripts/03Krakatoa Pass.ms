		--create the pass
		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_FX_KRAK"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- Renderable Geo
		newSet=LPM_Fun.createObjectSet "PRT_Loader(s)"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		-- Mattes
		newSet=LPM_Fun.createObjectSet "Mattes ( add to 'KRAK_Mattes' SS also )"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		--All Lights Off
		newSet=LPM_Fun.createLightSet "All Lights"
		newSet.wildCard[1]="*"
		newSet.pEnable = 3
		newSet.parent=thePass

		--Renderable Lights
		newSet=LPM_Fun.createLightSet "Lights"
		newSet.pEnable = 2
		newSet.parent=thePass

		-- Renderer Override
		theProps=LPM_Fun.createNode "Krakatoa ( Enable Matte Objects )" "renderProps"
		theProps.parent=thePass

		renderSceneDialog.close()
		LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
		LPM_oldRenderSettingsNew=LPM_Fun.saveRenderPresetNew() 
		
		renderSceneDialog.close()
		renderers.current = Krakatoa()
		renderSceneDialog.open() 
		renderSceneDialog.close()
	
		try
		(
			TheProps.propsAlternate=LPM_Fun.saveRenderPresetNew()
		)
		catch
		(
			TheProps.props=LPM_Fun.saveRenderPreset()
			Messagebox "Please recreate renderer override"
		)

		TheProps.initialized=true

		try
		(
			LPM_Fun.loadRenderPresetNew LPM_oldRenderSettingsNew
		)
		catch
		(
			LPM_Fun.loadRenderPreset LPM_oldRenderSettings
		)

		-- Deadline Properties
		deadlineProps=LPM_Fun.createNode "Deadline ( Add Krakatoa Limit )" "Deadline"
		deadlineProps.parent=thePass
		deadlineProps.submitLimitsOn = true 
		deadlineProps.submitLimits = #("krakatoa")

		LPM_treeview_rollout.updateTV()