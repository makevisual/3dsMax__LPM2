		
		
		
		rollout LPM_RenderRo "Render Dialog" width:500 height:220
		(
			
			------
			GroupBox grp4 "Naming Parameters" pos:[5,5] width:490 height:135
			
			label lbl1 "Dir" pos:[10,25] width:16 height:22
			edittext rootText "" pos:[22,23] width:410 height:20 readOnly:true
			button pickRootBtn "..." pos:[437,24] width:20 height:19
			button openRootBtn "open" pos:[458,24] width:30 height:19
			
			label lbl2 "Filetype" pos:[12,48] width:40 height:20
			edittext typeText "" pos:[51,46] width:48 height:20 enabled:true readOnly:true	
	
	
			button pickFileTypeButton "Pick" pos:[101,47] width:40 height:20
			label lbl3 "Path" pos:[13,71] width:40 height:20
			edittext customPath "" pos:[51,69] width:380 height:16
			label lbl10 "####.ext" pos:[432,71] width:55 height:16
			
			dropdownList symbolDDL "" pos:[55,89] width:218 height:21 items:#("Symbols", "\ = Directory", "$Cam = Camera", "$Max = Max Filename", "$Pass = Pass Name", "$APass = Adjustment Pass Name", "$Shot = Shot Name", "$Element=Element Name", "$Ver = File version (ex: box_v01.max)", "$Date = Current date", "$RDate = YYYY.MM.DD")
			button resetName "Reset" pos:[277,89] width:70 height:21
			--button setAsDefault "Set as Default" pos:[350,89] width:80 height:21 --Disabled by Neil
		
		
			dropdownList previewDDL "" pos:[8,113] width:483 height:21 items:#("File Path Preview")
			
			
			------
			GroupBox grp5 "Render" pos:[5,140] width:490 height:75
			
			label lbl11 "Camera" pos:[12,160] width:43 height:19
			dropdownList cameraDDL "" pos:[55,158] width:170 height:21
			checkbox quietChk "Suppress Warnings" pos:[242,160] width:114 height:20
			
			label lbl1111 "Mode" pos:[12,187] width:43 height:19
			dropdownList renderType "" pos:[55,185] width:170 height:21 items:#("Passes", "Pass Hardware Preview", "Shots", "Shots Hardware Preview")
			button localBtn "Local" pos:[339,185] width:70 height:21
			button netBtn "Network" pos:[412,185] width:77 height:21
			
			
			fn updatePathPreview=
			(
				LPM_Root.pathString=customPath.text
				theNames=#("File Path Preview","======Pass Mode========")
				
				for thePassGroup in LPM_Root.children where thePassGroup.type=="passGroup" do
				(
					for thePass in thePassGroup.children where thePass.type=="pass" do
					(
						append theNames (LPM_Fun.getPassPath LPM_Root thePass previewmode:true RendPreviewMode:true elementName:"ElementName")
					)
				)
				
				for thePass in LPM_Root.children where thePass.type=="pass" do
					append theNames (LPM_Fun.getPassPath LPM_Root thePass previewmode:true elementName:"ElementName")
				
				
				theNames[theNames.count+1]="======Shot Mode========"
				shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
				for theShot in shotRoot.children where theShot.type=="shot" do
					
					if(theShot.allPasses==true) then
						for thePass in LPM_Root.children where thePass.type=="pass" do
							append theNames (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot previewmode:true RendPreviewMode:true elementName:"ElementName") 
					else
						for thePass in theShot.passes where (isValidNode thePass) do
							append theNames (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot previewmode:true RendPreviewMode:true elementName:"ElementName") 
				previewDDL.items=theNames
			)

			fn setPathDefault=
			(

				LPM_Root.pathString=customPath.text="$Shot\\$APass$Pass$Element\\$APass$Pass$Element"
				
				updatePathPreview()
				
				LPM_Fun.SetIni "LPM Render" "Path"  customPath.text

			)
			
			on customPath entered text do
			(
				updatePathPreview()
			)
			
			on openRootBtn pressed do
			(
				shellLaunch LPM_Root.rootDir ""
			)
			
			on renderType selected i do
			(
				LPM_Root.renderType=i
				
				if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
				(
					netBtn.enabled=false
				)
				else
				(
					netBtn.enabled=true
				)
			)
			
			on resetName pressed do
			(
-- 				LPM_Root.pathString=customPath.text="$APass$Pass\\$Element\\$Max_$APass$Pass_$Element"	
				setPathDefault()
			)
			
			on symbolDDL selected i do
			(
				case i of 
				(
					2: customPath.text+="\\"
					3: customPath.text+="$Cam"	
					4: customPath.text+="$Max"
					5: customPath.text+="$Pass"
					6: customPath.text+="$APass"
					7: customPath.text+="$Shot"
					8: customPath.text+="$Element"
					9: customPath.text+="$Ver"
					10: customPath.text+="$Date"
					11: customPath.text+="$RDate"
				)
				symbolDDL.selection=1
				updatePathPreview()
			)
			
			on LPM_RenderRo open do
			(
				if maxfilepath != "" then
				(
					ProjRenderPath = getProjRenderPath()
					if ProjRenderPath != "" then
					(
						LPM_Root.rootdir = ProjRenderPath
					)
					
				)
				
				rootText.text=LPM_Root.rootdir
				typeText.text=LPM_Root.fileType
				quietChk.checked=LPM_Root.quietMode
				customPath.text=LPM_Root.pathString
				updatePathPreview()
				renderType.selection=LPM_root.renderType
				
				if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
				(
					netBtn.enabled=false
				)
				else
				(
					netBtn.enabled=true
				)
				
				cameraList=#(("Active Viewport:"+(substring (viewport.getType() as string) 6 -1)))
					
				for i in $cameras where (classof i!=Targetobject) do append cameraList i.name
				cameraDDl.items=cameraList
				if(isvalidNode LPM_Root.renderCamera) then
				(
					x=(findItem  cameraDDl.items LPM_Root.renderCamera.name) 
					if (x!=0) then
					cameraDDl.selection=x
				)
			)


			on pickRootBtn pressed do
			(
				rootText.text= LPM_Fun.pickOutputRoot()
			)

			on cameraDDL selected it do
			(
				if(selected==1) then
					LPM_Root.renderCamera=undefined
				else
					LPM_Root.renderCamera=getNodeByName cameraDDL.items[it]
				updatePathPreview()
			)
			
			on localBtn pressed do
			(
				LPM_Fun.setWhoToRenderByRenderType()
				LPM_Fun.localRenderSubmit()
			)
			
			on netBtn pressed do
			(
				LPM_Fun.setWhoToRenderByRenderType()
				LPM_Fun.launchNetworkRender()
			)
			

			on pickFileTypeButton pressed do
			(
				thePath=getBitmapSaveFileName caption:"Enter the File Type" filename:("XXX."+LPM_Root.fileType)
				if(thePath!=undefined) then
				(
					theType=getFilenameType thePath
					if(theType!="") then
					(
						theType=substring theType 2 -1
						LPM_Root.fileType=theType
						typeText.text=theType
					)
				)
			)
			on openCommonDialog pressed do
			(
				renderSceneDialog.open()
			)
			
			on setAsDefault pressed do
			(
				setPathDefault()
				LPM_Fun.SetIni "LPM Render" "Path"  customPath.text
				messageBox ("Default Path String set to "+customPath.text)
				
			)

			on quietChk changed state do
			(
				LPM_Root.quietmode=state
			)

		)

		createDialog LPM_RenderRo pos:(LPM_Fun.getRoPos LPM_RenderRo.width)
	