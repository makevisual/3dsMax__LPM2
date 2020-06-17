		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM__Falloff"

 		thePass.isAdjustment = true
  		thePass.AdjustmentFor = adjustmentFor

		-- Falloff Material
		newSet=LPM_Fun.createObjectSet "Falloff"
		newSet.intp[1] = 1
		newSet.wildCard[1]="*"

		newMaterial = standardMaterial()
		newMaterial.name = "Falloff"
		newMaterial.selfIllumAmount = 100
		newMap = falloff()
		newMaterial.diffusemap = newMap
		
		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial

 		newSet.parent=thePass

 		-- White material
		newSet=LPM_Fun.createObjectSet "Black"
		newSet.intp[1] = 1

		newMaterial = standardMaterial()
			newMaterial.name = "Black"
			newMaterial.selfIllumAmount = 100
			newMaterial.diffuse = (color 0 0 0) 

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial

 		newSet.parent=thePass

 		-- ENV Override
		envProps=LPM_Fun.createNode "Environment Override" "envProps"
		envProps.initialized = true
		envProps.backgroundOverride = true
		envProps.bgColor = (color 0 0 0 )
		envProps.parent=thePass

		-- Deadline Properties
		deadlineProps=LPM_Fun.createNode "Deadline Override" "Deadline"
		deadlineProps.taskSizeOn = true
		deadlineProps.taskSize = 3
		deadlineProps.parent=thePass

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