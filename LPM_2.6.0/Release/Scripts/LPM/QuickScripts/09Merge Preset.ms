
		
		oldCount=$objects.count
		
		filePath=getOpenFileName caption:"Pick the max file containing the preset" fileName:maxfilepath types:"Max files(*.lpmpr)|*.lpmpr"
		
		
		if(filePath!=undefined) then
		(
			newNodes=#()
			mergeMAXFile filePath #mergedups #renameMtlDups 
			
			
			for i=oldCount+1 to $objects.count do
			(
				append newNodes objects[i]
			)
			
			for it in newNodes do
			(
				if(isProperty it #type) then
				(
					if(it.type=="pass") then 
 						it.parent=LPM_Root
					else if(it.type=="root") then 
						delete it
				)
				else
					delete it
			)
		)
		
		
		filein (LPM_Dir + "CA.ms") --RELOAD THE CA!!
		
		
		LPM_treeview_rollout.updateTV()
	