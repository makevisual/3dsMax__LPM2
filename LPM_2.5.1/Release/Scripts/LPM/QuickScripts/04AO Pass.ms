		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_AO"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- AO Material
		newSet=LPM_Fun.createObjectSet "AO"
		newSet.intp[1] = 2

		newMaterial = standardMaterial()
		newMaterial.name = "AO"
		newMaterial.selfIllumAmount = 100
		newMap = VRayDirt()
			newMap.falloff = .3
			newmap.subdivs = 16
		newMaterial.diffusemap = newMap
		
		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial

 		newSet.parent=thePass

 		-- White material
		newSet=LPM_Fun.createObjectSet "White"
		newSet.intp[1] = 2

		newMaterial = standardMaterial()
			newMaterial.name = "White"
			newMaterial.selfIllumAmount = 100
			newMaterial.diffuse = (color 255 255 255) 

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial

 		newSet.parent=thePass

 		-- ENV Override
		envProps=LPM_Fun.createNode "Environment Override" "envProps"
		envProps.initialized = true
		envProps.backgroundOverride = true
		envProps.bgColor = (color 255 255 255)
		envProps.parent=thePass

		-- Vray Override Properties
		vrayProps=LPM_Fun.createNode "Vray Override" "vrayProps"
		vrayProps.qualityType = 1
		vrayProps.GI_illum_check = true
		vrayProps.giOn = false
		vrayProps.initialized = true
		vrayProps.parent=thePass

		--All Lights Off
		newSet=LPM_Fun.createLightSet "All Lights"
		newSet.wildCard[1]="*"
		newSet.pEnable = 3
		newSet.parent=thePass

		LPM_treeview_rollout.updateTV()