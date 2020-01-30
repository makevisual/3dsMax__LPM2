		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM__Elements"

 		thePass.isAdjustment = true
  		thePass.AdjustmentFor = adjustmentFor

		newMaterial_Black = standardMaterial()
			newMaterial_Black.name = "Black"
			newMaterial_Black.selfIllumAmount = 100
			newMaterial_Black.diffuse = (color 0 0 0) 

		newMaterial_R = standardMaterial()
			newMaterial_R.name = "Red"
			newMaterial_R.selfIllumAmount = 100
			newMaterial_R.diffuse = (color 255 0 0) 

		newMaterial_G = standardMaterial()
			newMaterial_G.name = "Green"
			newMaterial_G.selfIllumAmount = 100
			newMaterial_G.diffuse = (color 0 255 0) 

		newMaterial_B = standardMaterial()
			newMaterial_B.name = "Blue"
			newMaterial_B.selfIllumAmount = 100
			newMaterial_B.diffuse = (color 0 0 255) 

		newMulti = multimaterial()
			newMulti.name = "RGB_Multi"
			newMulti.numsubs=3
			newMulti[1] = newMaterial_R
			newMulti[2] = newMaterial_G
			newMulti[3] = newMaterial_B

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "RGB_MatId"
		newSet.intp[1] = 1
		newSet.wildCard[1]="*"

		newSet.pMatEnable = true
		newSet.pMaterial = newMulti

 		newSet.parent=thePass

		-- Black Material
		newSet=LPM_Fun.createObjectSet "Black"
		newSet.intp[1] = 2

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial_Black

 		newSet.parent=thePass

		-- Red Material
		newSet=LPM_Fun.createObjectSet "R"
		newSet.intp[1] = 2

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial_R

 		newSet.parent=thePass

		-- Green Material
		newSet=LPM_Fun.createObjectSet "G"
		newSet.intp[1] = 2

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial_G

 		newSet.parent=thePass

		-- Green Material
		newSet=LPM_Fun.createObjectSet "B"
		newSet.intp[1] = 2

		newSet.pMatEnable = true
		newSet.pMaterial = newMaterial_B

 		newSet.parent=thePass

 		-- ENV Override
		envProps=LPM_Fun.createNode "Environment Override" "envProps"
		envProps.initialized = true
		envProps.backgroundOverride = true
		envProps.bgColor = (color 0 0 0)
		envProps.parent=thePass
		envProps.activeElement = #("_E_AO", "_E_Depth")
		envProps.elementOverride = true

 		-- Common Properties
 		commonProps=LPM_Fun.createNode "Common Properties" "commonProps"



		commonProps._rendTimeType=rendTimeType
		commonProps._rendNThFrame=rendNThFrame
		commonProps._rendStart=rendStart
		commonProps._rendEnd=rendEnd
		commonProps._rendFileNumberBase=rendFileNumberBase
		commonProps._renderHeight=renderHeight
		commonProps._renderWidth=renderWidth
		commonProps._RendApertureWidth=getRendApertureWidth()
		commonProps._renderPixelAspect=renderPixelAspect
		commonProps._rendPickupFrames=rendPickupFrames
		commonProps._rendAtmosphere=rendAtmosphere
		commonProps._renderEffects=renderEffects 
		commonProps._renderDisplacements=renderDisplacements
		commonProps._rendColorCheck=rendColorCheck
		commonProps._rendFieldRender=rendFieldRender
		commonProps._rendHidden=rendHidden
		commonProps._rendSimplifyAreaLights=rendSimplifyAreaLights
		commonProps._rendForce2Side=rendForce2Side
		commonProps._rendSuperBlack=rendSuperBlack
		commonProps._useAdvancedLighting=RadiosityPreferences.useAdvancedLighting
		commonProps._computeAdvancedLighting=RadiosityPreferences.computeAdvancedLighting
		commonProps.initialized=true

		commonProps.fileTypeTgl = true
		commonProps._fileType = "exr"
		commonProps.preScript = ""
		commonProps.postScript = ""
 		commonProps.parent=thePass

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