
		AllLights=for it in $lights where (superclassof it==light) collect it
		
		for i=1 to AllLights.count do
		(
			TmpLight=AllLights[i]
			if(isvalidnode TmpLight) then
			(
				--create the pass
				thePass=LPM_Fun.createPass LPM_Root
				thePass.name="LPM_"+TmpLight.name
				
				--create the on lightSet
				theSet=LPM_Fun.createLightSet TmpLight.name
				theSet.parent=thePass
				theSet.pEnable=2
				theSet.nodes[1]=TmpLight
			
			)
		)
		
		
		LPM_treeview_rollout.updateTV()
		