
		rollout SavePresetRollout "Pick Preset Passes" width:242 height:265
		(
			multiListBox mlb_Passes "" pos:[5,8] width:232 height:17
			button btn_Save "Save" pos:[6,238] width:232 height:21
			
			local thePasses=#()
			
			
			on SavePresetRollout open do
			(
				theGroupsPasses = #()
				for itGroup in LPM_Root.children where itGroup.type=="passGroup" do 
				(
					theGroupsPasses +=  for i in itGroup.children where i.type=="pass" collect i
				)
				
				
				
				thePasses = for i in LPM_Root.children where i.type=="pass" collect i
				
				thePasses = theGroupsPasses + thePasses
				
				mlb_Passes.items=for it in thePasses collect LPM_Fun.getname(it.name)
			)
			
			
			on btn_Save pressed do
			(
				Tmp_nodes=#()
				
				for i=1 to thePasses.count where mlb_Passes.selection[i] do
				(
					for it in thePasses[i] do
					(
						append Tmp_nodes it
					)
				)
				
				TmpfilePath=getSaveFileName caption:"Save LPM preset file" fileName:(maxfilepath) types:"Max files(*.lpmpr)|*.lpmpr"
				
				if(TmpfilePath!=undefined) then
				(
					savenodes Tmp_nodes TmpfilePath
					destroyDialog SavePresetRollout
				)
				
			)
		)
		createDialog SavePresetRollout pos:(LPM_Fun.getRoPos  SavePresetRollout.width)
