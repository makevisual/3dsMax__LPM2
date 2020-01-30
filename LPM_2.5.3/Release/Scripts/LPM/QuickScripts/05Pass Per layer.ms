
		lMan=layerManager
		
		for i=0 to (lMan.count-1) do
		(
			theLayer=lMan.getLayer i
			if(theLayer.name!="zz-LPM") then
			(
				--create the pass
				thePass=LPM_Fun.createPass LPM_Root
				thePass.name="LPM_"+theLayer.name
				
				
				--create the objectSet
				theSet=LPM_Fun.createObjectSet theLayer.name
				theSet.parent=thePass
				theSet.layers[1]=theLayer.name
				theSet.intp[1]=2
			)
			
		)
		LPM_treeview_rollout.updateTV()	
	
	
	
