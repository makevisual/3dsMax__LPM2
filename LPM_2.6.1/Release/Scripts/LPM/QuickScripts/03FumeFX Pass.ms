		--create the pass
		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_FX_Fume"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- Renderable Geo
		newSet=LPM_Fun.createObjectSet "Fume Container(s)"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		-- Mattes
		newSet=LPM_Fun.createObjectSet "Mattes"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		newSet.userProp="
		VRay_Matte_Enable = True
		VRay_Secondary_Matte_Enable = True
		VRay_Matte_Alpha = -1.000000
		"
		newSet.intP[9]=2

		--All Lights Off
		newSet=LPM_Fun.createLightSet "All Lights"
		newSet.wildCard[1]="*"
		newSet.pEnable = 3
		newSet.parent=thePass

		--Renderable Lights
		newSet=LPM_Fun.createLightSet "L ( Add lights to your Fume container also )"
		newSet.pEnable = 2
		newSet.parent=thePass

		-- Env Override 
		envProps=LPM_Fun.createNode "ENV ( Enable Fusionworks Renderer )" "envProps"
		envProps.initialized = true
		envProps.parent=thePass

		LPM_treeview_rollout.updateTV()