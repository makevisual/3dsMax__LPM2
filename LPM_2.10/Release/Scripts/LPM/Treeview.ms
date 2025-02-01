
callbacks.removeScripts id:#closeLPM

LPM_Callback="LPM_Fun.destroyAllDialogs()"

callbacks.addScript #filePostOpen LPM_Callback id:#closeLPM
callbacks.addScript #systemPostNew LPM_Callback id:#closeLPM
callbacks.addScript #systemPostReset LPM_Callback id:#closeLPM
try(destroyDialog LPM_treeview_rollout)catch()

LPM_Root = $LPM_Root

try
(
	if LPM_Root.LastActivePass != "" then
	(
		passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it

		for i = 1 to passArray.count do
		(
			if (LPM_Fun.generatePassName passArray[i]) == LPM_Root.LastActivePass then
			(
				LPM_activePass = passArray[i]
			)
		)
	)
)catch()

LPM_ShowSkipButton = false
LPM_RendButttonSize = 30

if (LPM_Fun.getIni "Settings" "ShowSkipButton" booleanClass false) then
(
	LPM_ShowSkipButton = true

	LPM_RendButttonSize = 20
)

ilTv = dotNetObject "System.Windows.Forms.ImageList"
ilTv.imageSize = dotNetObject "System.Drawing.Size" 16 15

LPM_BackColor = undefined
LPM_FontColor = undefined

fn CheckUIColor =
(
	CurUIColor = "Light"
	CurUIColorCol = colorMan.getColor #timeSliderBg
	if CurUIColorCol[1] < 0.6 then
	(
		CurUIColor = "Dark"
	)
	CurUIColor
)

fn getIconFromBitmap iconFileName =
(
	theFileName = LPM_iconPath + iconFileName +".bmp"
	img = dotNetClass "System.Drawing.Image" --create an image
	ilTv.images.add (img.fromFile theFileName) --add to the list
)

fn dotNetColor clr =
(
	(dotNetClass "System.Drawing.Color").fromARGB clr.r clr.g clr.b
)

fn InitColorUI =
(
	LPM_BackColor = dotNetColor (color 85 85 85)
	LPM_FontColor = dotNetColor (color 200 200 200)
	--LPM_iconPath += "IconsDark/"
)

InitColorUI()

try
(
	if rendOutputFilename == "" then
	(
		rendOutputFilename = "D:\\tmp.exr"
	)
)
catch()

rollout LPM_treeview_rollout ( "LPM v" + LPM_VersionNumber )
(
	local copyNode
	local colorBackup
	local displayColorWire
	local displayColorShaded
	local tvRoot
	local shotRoot
	local shotRootTV
	local prevSelection

	local proMode=false
	local stopper
	local LPM_doubleClick=false
	local rNode=undefined
	local DragNode, DropNode
	local m=dotNetClass "System.Windows.Forms.DragDropEffects" -- Drag and drop effects
	local sTime=timeStamp()
	local oldHitNode=undefined
	local lastMouseDown = timeStamp()
	local preventExpand = false
	local TmpSelNode = undefined

	struct leafType (type, leaf, index, active)

	edittext 		passDDL pos:[-3,2] width:50 height:30 readonly:true
	checkbutton 	chkbtn_HideRFW "" height:10 width:15 pos:[120,22] tooltip:"Hide Rendered Frame Window" visible:LPM_ShowSkipButton  images:#(LPM_iconPath+"HideFrameWindow_btn.bmp",undefined,1,1,1,1,1,true)
	checkbutton 	chkbtn_SkipExistingImages "" height:10 width:15 pos:[135,22] tooltip:"Skip Existing Images" visible:LPM_ShowSkipButton  images:#(LPM_iconPath+"Skip_existing_btn.bmp",undefined,1,1,1,1,1,true)
	button 			colorButton "tgl" pos:[100,2] images:#(LPM_iconPath+"colorOn.bmp",undefined,1,1,1,1,1) tooltip:"Click to color pass, shift click to restore" visible:false----------------------------------------- INVISIBLE
	checkbutton 	hideButton "rdr" pos:[180,2] images:#(LPM_iconPath+"eyeOpen.bmp",undefined,1,1,1,1,1) tooltip:"Hide by category floater." visible:false----------------------------------------------------
	button 			quickScriptsButton "QS" pos:[180,25] tooltip:"Quick Scripts" height:30 width:30 images:#(LPM_iconPath+"Quick_Scripts.bmp",undefined,1,1,1,1,1,true)
 	dropDownList 	previewSizeDDL "" pos:[160,32] items:#("10","25","50","75","100","150","200") width:45 -- visible:false-----------------------------------------------------------------------------------------------
	dropDownList 	previewTypeDDL pos:[120,32] width:60 items:#("View", "Selected", "Region", "Crop", "BlowUp") -- visible:false--------------------------------------------------------------------------------------
 	dropDownList 	cameraDDL "" pos:[0,32] width:100 items:#("-----------------------") -- visible:false----------------------------------------------------------------------------------------------------------------
	button 			tyPreviewButton "TyPreview" pos:[40,200] height:22 width:60 enabled:false tooltip:"TODO:"
	button 			nukeRenderButton "NukeFile" pos:[40,200] height:22 width:55 enabled:false tooltip:"TODO:"
	button 			maxFileRenderButton "Bake Files" pos:[40,200] height:22 width:55 enabled:true tooltip:"TODO:"
	button 			localRenderButton "Local" pos:[40,200] height:22 width:55 enabled:false tooltip:"Submits all passes/shots to this computer.  Depends on 'Only Active Passes / Shots' in the render dialog and on the Render Mode."
	button 			networkRenderButton "Deadline" pos:[95,200] height:22 width:70 tooltip:"Submits all passes/shots to the network.  Depends on 'Only Active Passes / Shots' in the render dialog and on the Render Mode."
	checkbutton 	skipIdiotChecks "Skip IC" pos:[165,200] height:22 width:40 tooltip:"When enabled, Idiot checks will be skipped with a time penalty"
	button 			setRenderDirButton "Set" pos:[185,200] height:21 width:20 tooltip:"Sets the render directory"
	button 			openRenderDirButton "..." pos:[202,200] height:21 width:17 tooltip:"Opens the render directory"

	dotNetControl tv "TreeView"  pos:[0,54] align:#left
	dotNetControl editBox "TextBox"  pos:[0,70] height:20 width:120
	dotNetControl OutputPathDDL "TextBox"  pos:[0,60] align:#left

	fn FreezeWindow =
	(
		tv.enabled = false
		chkbtn_HideRFW.enabled = false
		chkbtn_SkipExistingImages.enabled = false
		quickScriptsButton.enabled = false
		openRenderDirButton.enabled = false

		-- TODO: Turn these back on when functionality added
		-- tyPreviewButton.enabled = false
		-- nukeRenderButton.enabled = false 
		maxFileRenderButton.enabled = false 
		-- localRenderButton.enabled = false
		networkRenderButton.enabled = false
	)

	fn UnFreezeWindow =
	(
		tv.enabled = true
		chkbtn_HideRFW.enabled = true
		chkbtn_SkipExistingImages.enabled = true
		quickScriptsButton.enabled = true
		openRenderDirButton.enabled = true
		
		-- TODO: Turn these back on when functionality added
		-- tyPreviewButton.enabled = true 
		-- nukeRenderButton.enabled = true
		maxFileRenderButton.enabled = true
		-- localRenderButton.enabled = true
		networkRenderButton.enabled = true

		case LPM_Root.renderType of
		(
			1: networkRenderButton.enabled=true
			2: networkRenderButton.enabled=false
			3: networkRenderButton.enabled=true
			4: networkRenderButton.enabled=false
		)
	)

	fn initTreeView tv=
	(
		-- In the tv init function
		tmpcol = ((colorMan.getColor #timeSliderBg)*255) as color
		OutputPathDDL.BackColor = dotNetColor tmpcol
		OutputPathDDL.ForeColor = LPM_FontColor
		OutputPathDDL.ReadOnly = true
		editBox.BackColor = dotNetColor (color 245 245 245)
		tv.BackColor = LPM_BackColor
		tv.AllowDrop = true -- allow DragandDrop for the Treeview

		getIconFromBitmap "Root"
		getIconFromBitmap "Pass"
		getIconFromBitmap "objectSet"
		getIconFromBitmap "lightSet"
		getIconFromBitmap "Layers"
		getIconFromBitmap "NamedSet"
		getIconFromBitmap "Wildcard"
		getIconFromBitmap "Node"
		getIconFromBitmap "Render"
		getIconFromBitmap "Enviroment"
		getIconFromBitmap "Common"
		getIconFromBitmap "Disabled"
		getIconFromBitmap "objectSetOn"
		getIconFromBitmap "objectSetOff"
		getIconFromBitmap "lightSetOn"
		getIconFromBitmap "lightSetOff"
		getIconFromBitmap "Shot"
		getIconFromBitmap "ShotOff"
		getIconFromBitmap "ShotRoot"
		getIconFromBitmap "xrefProps"
		getIconFromBitmap "xrefOn"
		getIconFromBitmap "xrefOff"
		getIconFromBitmap "CommonOff"
		getIconFromBitmap "EnviromentOff"
		getIconFromBitmap "RenderOff"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "passGroupOn"
		getIconFromBitmap "passGroupOff"
		getIconFromBitmap "scriptOn"
		getIconFromBitmap "scriptOff"
		getIconFromBitmap "RootOff"
		getIconFromBitmap "ModifyObject"
		getIconFromBitmap "ModifyObjectOff"
		getIconFromBitmap "Node_group"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "xrefObjProps"
		getIconFromBitmap "xrefObjPropsOff"
		getIconFromBitmap "xrefPropsOff"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "vray"
		getIconFromBitmap "vrayOff"
		getIconFromBitmap "Deadline"
		getIconFromBitmap "DeadlineOff"

		-- NOTE -- All additional icons should be added to the end of the list, because icons are called by index
		-- Addition of new items will offset following icons
		-- If you want to remove an icon, replace it with "missing" because icons are integer
		-- based and if the index changes, the icons will be incorrect

		getIconFromBitmap "missing" 						--Dabelow vray5
		getIconFromBitmap "missing" 						--Dabelow vray5
		getIconFromBitmap "missing" 						--Dabelow vray5
		getIconFromBitmap "missing" 						--Dabelow vray5

		getIconFromBitmap "CameraOverscan" 					--Dabelow cameraOverscan
		getIconFromBitmap "CameraOverscanOff" 				--Dabelow cameraOverscan
		getIconFromBitmap "NukeExportOperator" 				--Dabelow nukeExport
		getIconFromBitmap "NukeExportOperatorOff" 			--Dabelow nukeExport
		getIconFromBitmap "AfterEffectsExportOperator" 		--Dabelow aeExport
		getIconFromBitmap "AfterEffectsExportOperatorOff" 	--Dabelow aeExport

		getIconFromBitmap "missing" 			 			--Dabelow vray6
		getIconFromBitmap "missing" 						--Dabelow vray6
		getIconFromBitmap "missing" 						--Dabelow vray6
		getIconFromBitmap "missing" 						--Dabelow vray6

		getIconFromBitmap "vrayRenderElements" 				--Dabelow vrayRebderElements
		getIconFromBitmap "vrayRenderElementsOff" 			--Dabelow vrayRebderElements

		tv.imageList = ilTv
	)

	fn updatePassDDL =
	(
		if isvalidnode(LPM_ActivePass) then
		(
			passDDL.text = LPM_Fun.generatePassName LPM_ActivePass
			try(LPM_Root.LastActivePass = LPM_Fun.generatePassName LPM_ActivePass)catch()
		)
		else
			passDDL.text="No Pass Active"

		if maxfilepath != "" then
		(
			ProjRenderPath = LPM_Root.rootDir
			--if ProjRenderPath != "" then(OutputPathDDL.text=LPM_Root.rootDir=getProjRenderPath())

			if ProjRenderPath != "" then(OutputPathDDL.text=LPM_Root.rootDir)
			else(OutputPathDDL.text=LPM_Root.rootDir)
		)
		else
		(
			OutputPathDDL.text=LPM_Root.rootDir
		)

		openRenderDirButton.tooltip = "Open render dir: " + OutputPathDDL.text
	)

	fn deleteSelectedPass tv =
	(
		theNode=tv.selectedNode
		for jt in (LPM_Fun.getAllChildren theNode.tag.value) do delete jt
		theNode.Remove()
	)

	fn offsetSelectedShot tv arg_mode =
	(
		-- Get the node
		theNode=tv.selectedNode

		-- offset the version string - Passing the #increment or #decrement modes
		newString = LPM_Fun.offsetVersionString theNode.tag.value.name arg_mode

		-- Have to put this prefix on, LPM is expecting it and will trim the name.
		newString = ("LPM_"+newString) 

		-- Assign the new name and update the tree view		
		theNode.tag.value.name = newString
		LPM_treeview_rollout.updateTV()
	)

	fn duplicateSelectedShot tv =
	(
		theNode=tv.selectedNode

		-- add each of the nodes to a list to clone
		curNodes = #()
		for jt in (LPM_Fun.getAllChildren theNode.tag.value) do (append curNodes jt)
		-- Clone the nodes
		maxOps.cloneNodes curNodes cloneType:#copy newNodes:&nnl #nodialog
	)

	fn makeItalic theNode=
	(
		try(
			obj=theNode.tag.value
			if(isValidNode obj) then
		(
			if(InstanceMgr.GetInstances obj #() >1) then
			(
				theNode.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").italic
			)
		)
		
		)catch() --TODO:
	)

	fn createTVnode nodeRoot theNode nodeType:"LPM_node" =
	(
		nodeName = ""
		case nodeType of
		(
			"leaf": nodeName = theNode.leaf
			"leafObject": nodeName = theNode.leaf.name
			"leafXref": nodeName = ((getFilenameFile theNode.leaf[1])+(getFilenameType theNode.leaf[1]))
			"commonProps": nodeName = (LPM_Fun.generateCommonPropName theNode)
			"vrayProps": nodeName = (LPM_Fun.generateVrayPropName theNode)
			"passRoot": nodeName = (	if(proMode==false) then "Passes (Maximum of 3)" else "Passes" )
			"shotRoot": nodeName = (	if(proMode==false) then "Shots (Maximum of 2)" else "Shots" )

			"Deadline": 			nodeName = (LPM_Fun.generateDeadlineName theNode) 				-- Dabelow
			"vray6RenderElements": 	nodeName = (LPM_Fun.generateVray6RenderElementsName theNode) 	-- Dabelow Vray6
			"vray6": 				nodeName = (LPM_Fun.generateVray6PropName theNode) 				-- Dabelow Vray6
			"vrayRenderElements": 	nodeName = (LPM_Fun.generateVrayRenderElementsName theNode) 	-- Dabelow VrayRenderElements
			"cameraOverscan": 		nodeName = (LPM_Fun.generateCameraOverscanName theNode) 		-- Dabelow cameraOverscan
			"nukeExport": 			nodeName = (LPM_Fun.generateNukeExportName theNode) 			-- Dabelow nukeExport
			"aeExport": 			nodeName = (LPM_Fun.generateAeExportName theNode) 				-- Dabelow aeExport

			default: nodeName = (LPM_Fun.getName theNode.name)
		)

		newNode = nodeRoot.Nodes.Add nodeName
		newNode.tag=dotNetMXSValue theNode
 		newNode.BackColor = LPM_BackColor
 		newNode.ForeColor = FrontColor

		LPM_Fun.setIcon newNode
		newNode
	)

	fn createPassTv objPass nodeParent =
	(
		newPass = createTVnode nodeParent objPass

		newPass.ForeColor = LPM_FontColor
		newPass.BackColor = LPM_BackColor
		newPass.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		thePass = newPass.tag.value
		newPass.text =  LPM_Fun.generatePassName thePass

		newPass
	)

	fn createPassGroupTv pg=
	(
		tmp_PassGroupTv = createTVnode tvRoot pg

		tmp_PassGroupTv.ForeColor = LPM_FontColor
		tmp_PassGroupTv.BackColor = LPM_BackColor
		tmp_PassGroupTv
	)

	fn addPassTv newPass=
	(
		newPass.nodes.clear()
		pmPass=newPass.tag.value

		allObjSet=for obj in pmPass.children where obj.type=="objectSet" collect obj

		for i=1 to allObjSet.count do
		(
			obj=allObjSet[1+allObjSet.count-i]
			newObj = createTVnode newPass obj
			makeItalic newObj
			newObj.ForeColor = LPM_FontColor
			newObj.BackColor = LPM_BackColor
			for i=1 to obj.wildCard.count do
			(
				newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i=1 to obj.namedSet.count do
			(
				newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.layers do
			(
				newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.mats do
			(
				newNode = createTVnode newObj (leafType "mat" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)

			for i in obj.nodes do
			(
				if(isvalidnode i) then
				(
					newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"

					newNode.ForeColor = LPM_FontColor
					newNode.BackColor = LPM_BackColor
				)
			)
			if(obj.expanded) then
				newObj.expand()
		)

		allLightSets=for obj in pmPass.children where obj.type=="lightSet" collect obj

		for i=1 to allLightSets.count do
		(
			obj=allLightSets[1+allLightSets.count-i]
			newObj = createTVnode newPass obj

			newObj.ForeColor = LPM_FontColor
			newObj.BackColor = LPM_BackColor

			makeItalic newObj

			for i=1 to obj.wildCard.count do
			(
				newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i=1 to obj.namedSet.count do
			(
				newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.layers do
			(
				newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.nodes do
			(
				if(isvalidnode i) then
				(
					newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"

					newNode.ForeColor = LPM_FontColor
					newNode.BackColor = LPM_BackColor
				)
			)
			if(obj.expanded) then
				newObj.expand()
		)

		commonProps=LPM_Fun.firstChildByType pmPass "commonProps"
		if(commonProps!=undefined) then
		(
			newCP = createTVnode newPass commonProps nodeType:"commonProps"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		allRenderProps=for obj in pmPass.children where obj.type=="renderProps" collect obj
		for renderProps in allRenderProps do
		(
			newRP = createTVnode newPass renderProps

			newRP.ForeColor = LPM_FontColor
			newRP.BackColor = LPM_BackColor
			makeItalic newRP
		)

		allVrayProps=for obj in pmPass.children where obj.type=="vrayProps" collect obj
		for vrayProps in allVrayProps do
		(
			newVP = createTVnode newPass vrayProps nodeType:"vrayProps"

			newVP.ForeColor = LPM_FontColor
			newVP.BackColor = LPM_BackColor

			makeItalic newVP
		)

		envProps=LPM_Fun.firstChildByType pmPass "envProps"
		if(envProps!=undefined) then
		(
			newEnv = createTVnode newPass envProps

			newEnv.ForeColor = LPM_FontColor
			newEnv.BackColor = LPM_BackColor
			makeItalic newEnv
		)

		xrefObjProps=LPM_Fun.firstChildByType pmPass "xrefObj"
		if(xrefObjProps!=undefined) then
		(
			newXR = createTVnode newPass xrefObjProps

			newXR.ForeColor = LPM_FontColor
			newXR.BackColor = LPM_BackColor
			makeItalic newXR
		)

		xrefSceneProps=LPM_Fun.firstChildByType pmPass "xrefScene"
		if(xrefSceneProps!=undefined) then
		(
			newXR = createTVnode newPass xrefSceneProps

			newXR.ForeColor = LPM_FontColor
			newXR.BackColor = LPM_BackColor

			makeItalic newXR
		)

		for script in pmPass.children where script.type=="script" do
		(
			nScript = createTVnode newPass script

			nScript.ForeColor = LPM_FontColor
			nScript.BackColor = LPM_BackColor
			makeItalic nScript
		)

		for op in pmPass.children where op.type=="generic" do
		(
			opTVNode=createTVnode newPass op

			opTVNode.ForeColor = LPM_FontColor
			opTVNode.BackColor = LPM_BackColor
			--makeItalic opTVNode
		)

		for Modif in pmPass.children where Modif.type=="ModifierOver" do
		(
			newModifierOver=createTVnode newPass Modif

			newModifierOver.ForeColor = LPM_FontColor
			newModifierOver.BackColor = LPM_BackColor
			makeItalic newModifierOver
		)

 		-- Dabelow
		for Deadline in pmPass.children where Deadline.type=="Deadline" do
		(
			newDeadline=createTVnode newPass Deadline nodeType:"Deadline"

			newDeadline.ForeColor = LPM_FontColor
			newDeadline.BackColor = LPM_BackColor
			makeItalic newDeadline
		)

 		-- Dabelow vray6
		for vray6RenderElements in pmPass.children where vray6RenderElements.type=="vray6RenderElements" do
		(
			newVray6RenderElements=createTVnode newPass vray6RenderElements nodeType:"vray6RenderElements"

			newVray6RenderElements.ForeColor = LPM_FontColor
			newVray6RenderElements.BackColor = LPM_BackColor
			makeItalic newVray6RenderElements
		)

 		-- Dabelow vrayRenderElements
		for vrayRenderElements in pmPass.children where vrayRenderElements.type=="vrayRenderElements" do
		(
			newVrayRenderElements=createTVnode newPass vrayRenderElements nodeType:"vrayRenderElements"

			newVrayRenderElements.ForeColor = LPM_FontColor
			newVrayRenderElements.BackColor = LPM_BackColor
			makeItalic newVrayRenderElements
		)

 		-- Dabelow vray6
		for vray6 in pmPass.children where vray6.type=="vray6" do
		(
			newVray6=createTVnode newPass vray6 nodeType:"vray6"
			newVray6.ForeColor = LPM_FontColor
			newVray6.BackColor = LPM_BackColor
			makeItalic newVray6
		)

		if(pmPass.expanded) then
		(
			newPass.Expand()
		)
	)

	fn createShotTv shotNode=
	(
		newShot = createTVnode shotRootTV shotNode

		newShot.ForeColor = LPM_FontColor
		newShot.BackColor = LPM_BackColor
		newShot.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		newShot
	)

	fn addShotTv newShot=
	(
		newShot.nodes.clear()
		pmShot=newShot.tag.value

		commonProps=LPM_Fun.firstChildByType pmShot "commonProps"
		if(commonProps!=undefined) then
		(
			newCP = createTVnode newShot commonProps nodeType:"commonProps"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		-- dabelow cameraOverscan
		cameraOverscan=LPM_Fun.firstChildByType pmShot "cameraOverscan"
		if(cameraOverscan!=undefined) then
		(
			newCP = createTVnode newShot cameraOverscan nodeType:"cameraOverscan"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		-- dabelow nukeExport
		nukeExport=LPM_Fun.firstChildByType pmShot "nukeExport"
		if(nukeExport!=undefined) then
		(
			newCP = createTVnode newShot nukeExport nodeType:"nukeExport"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		-- dabelow aeExport
		aeExport=LPM_Fun.firstChildByType pmShot "aeExport"
		if(aeExport!=undefined) then
		(
			newCP = createTVnode newShot aeExport nodeType:"aeExport"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		if(pmShot.allPasses==false) then
		(
			--get rid of invalid passes
			np=#()
			ni=#()
			for i=1 to pmShot.passes.count where isvalidNode pmShot.passes[i] do
			(
				append np pmShot.passes[i]
				if(pmShot.passesOn[i]==true) then
					append ni true
				else
					append ni false
				newNode = createTVnode newShot (leafType "ShotPass" (pmShot.passes[i]) i ni[i]) nodeType:"leafObject"

				newNode.text = LPM_Fun.generatePassName pmShot.passes[i]
				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			pmShot.passes=np
			pmShot.passesOn=ni
		)
		else
		(
			pmAllpasses = createTVnode newShot (leafType "ShotPassAll" "All Active Passes") nodeType:"leaf"

			pmAllpasses.ForeColor = LPM_FontColor
			pmAllpasses.BackColor = LPM_BackColor
		)

		if(pmShot.expanded) then
		(	newShot.Expand()
		)
	)

	fn fillInTreeView tv =
	(
		--Add the Root
		tv.beginUpdate()

		tvRoot = createTVnode tv LPM_Root nodeType:"passRoot"
		tvRoot.ForeColor = LPM_FontColor
		tvRoot.BackColor = LPM_BackColor

		--add the passes
		count=0
		for pg in LPM_Root.children where pg.type=="passGroup" do
		(
			newPG = createPassGroupTv pg


			for pmPass in pg.children where pmPass.type=="pass" do
			(
				count+=1
				if(count < 4) or (proMode) then
				(
					newPass=createPassTv pmPass newPG
					addPassTv newPass
				)
			)
			if(pg.expanded) then
				newPG.expand()
		)

		for pmPass in LPM_Root.children where pmPass.type=="pass" do
		(
			count+=1
			if(count < 4) or (proMode) then
			(
				newPass = createPassTv pmPass tvRoot

				newPass.ForeColor = LPM_FontColor
				newPass.BackColor = LPM_BackColor
				addPassTv newPass
			)
		)

		shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")

		shotRootTV = createTVnode tv (LPM_Fun.firstChildByType LPM_Root "shotRoot") nodeType:"shotRoot"

		shotRootTV.ForeColor = LPM_FontColor
		shotRootTV.BackColor = LPM_BackColor

		--add the shots

		count=0
		for pmShot in shotRoot.children where pmShot.type=="shot" do
		(

			count+=1
			if(count < 3) or (proMode) then
			(
				newShot=createShotTv pmShot
				addShotTv newShot
			)
		)

		tvRoot.Expand()
		if(shotRoot.expanded) then
			shotRootTv.expand()
		updatePassDDL()

		tv.endUpdate()
	)

	fn updateRenderButtonsState=
	(

		case LPM_Root.renderType of
		(
			1: networkRenderButton.enabled=true
			2: networkRenderButton.enabled=false
			3: networkRenderButton.enabled=true
			4: networkRenderButton.enabled=false
		)
	)

	fn updateRFWandSkip =
	(
		try
		(
			chkbtn_HideRFW.state = LPM_Fun.getIni "Settings" "HideRFW" booleanClass false
			chkbtn_SkipExistingImages.state = LPM_Fun.getIni "Settings" "SkipExistingImages" booleanClass false
		)
		catch()

	)

	fn hideByPass thePass=
	(
		with redraw off
		(

			if(isvalidnode thePass) then
			(
				lMan=layerManager
				if (thePass.hideMode >1) then
				(

					for i=0 to (lMan.count-1) do
					(
						theLayer=lMan.getLayer i
						if(theLayer.name!="zz-LPM")then
						(
							theLayer.isHidden=false
						)
					)

					val=true
					if(thePass.hideMode==3) then val=false

					for it in objects where ((superclassof it)!=light)and(classof it != Targetobject ) and (superclassof it !=camera) do
					(
						it.ishidden = val
					)
					for it in lights where ((superclassof it)==light) do
					(
						it.ishidden = val

						try(it.enabled=(not val))catch()
						try(it.on=(not val))catch()
					)
				)

				--collect object nodes array
				objNodes=#()
				objSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "objectSet" &objNodes &objSetArray

				for k=1 to objNodes.count do
				(
					for theNode in objNodes[k] where  (classof theNode != Targetobject ) and (superclassof thenode !=camera) do
					(

						if(objSetArray[k].visible==2) then
						(
							unHide theNode
						)
						else if (objSetArray[k].visible==3) then
						(
							hide theNode
						)
						else if(objSetArray[k].intp[1]==3) then
						(
							hide theNode
						)
						else if(objSetArray[k].intp[1]==2) then
						(
							unHide theNode
						)

						if(objSetArray[k].selectable==2) then
							unfreeze theNode
						else if(objSetArray[k].selectable==3) then
							freeze theNode
					)
				)

				lightNodes=#()
				lightSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "lightSet" &lightNodes &lightSetArray

				for k=1 to lightNodes.count do
				(
					for theNode in lightNodes[k] do
					(
						if(lightSetArray[k].pEnable==3)  then
						(
							hide theNode
							try
							(
								theNode.on = false
							)
							catch()
							try
							(
								theNode.enabled = false
							)
							catch()
						)
						if(lightSetArray[k].pEnable==2)  then
						(
							unhide theNode
							try
							(
								theNode.on = true
							)
							catch()
							try
							(
								theNode.enabled = true
							)
							catch()
						)
					)
				)

				xrefSceneProps=LPM_Fun.firstChildByType thePass "xrefScene"
				if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
				(
					--set the scenes
					for i=1 to xrefs.getXRefFileCount() do
					(
						theXref=(xrefs.getXRefFile i)
						if((findItem xrefSceneProps.fileNames theXref.fileName)!=0) then
							theXref.disabled=false
						else
							theXref.disabled=true
					)
				)

				xrefObjProps=LPM_Fun.firstChildByType thePass "xrefObj"
				if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
				(
					--set the scenes
					for i=1 to objXRefMgr.recordCount do
					(
						theXref=(objXRefMgr.GetRecord i)
						if((findItem xrefObjProps.fileNames theXref.srcFileName)!=0) then
							theXref.enabled =true
						else
							theXref.enabled=false
					)
				)

				ModifMiddleSetting = LPM_Fun.getIni "Settings" "ModifMiddleSetting" booleanClass false

				if ModifMiddleSetting then
				(
					ModifierOverNodes=for child in thePass.children where child.type=="ModifierOver" and(child.active) do
					(
						myObject = child.activeNode

						if(isvalidnode myObject) then
						(
							for modi in myObject.modifiers do
							(
								if (findItem child.activeModifiers modi.name !=0) then
									modi.enabled=true
								else
									modi.enabled=false
							)
						)
					)
				)

				RendMiddleSetting = LPM_Fun.getIni "Settings" "RendMiddleSetting" booleanClass false

				if RendMiddleSetting then
				(
					theRenderProps=for it in thePass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it
					if( theRenderProps[1]!=undefined) then
					(
						if (queryBox "Apply renderer settings override?" title:"Warning!") then
						(
							try
							(
								LPM_Fun.loadRenderPresetNew theRenderProps[1].propsAlternate
							)
							catch
							(
								LPM_Fun.loadRenderPreset theRenderProps[1].props
							)
						)
					)
				)

				commonPropsMiddle = LPM_Fun.getIni "Settings" "TimeMiddleSetting" booleanClass true

				if commonPropsMiddle then
				(
					cp=LPM_Fun.firstChildByType thePass "commonProps"
					if(cp!=undefined)and(cp.active) then
					(
						if(cp.cameraTgl==true) then
						(
							try(
									hide cameras

									theViewport=viewport.activeViewport
									case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
									(
										"Viewport 1": theViewport=1
										"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
										"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
										"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
									)
									viewport.activeViewport=theViewport
									viewport.setCamera cp._Camera
									--select cp._Camera
									unhide cp._Camera

									if(isvalidnode cp._Camera.target) then
										unhide cp._Camera.target

								)catch()
						)

						if(cp.timeOutputTgl==true) then
						(
							try
							(
								case cp._rendTimeType of
								(
									3:
									(
										sliderTime = cp._rendStart
									)
									4:
									(
										tmparr = filterString cp._rendPickupFrames ", -"

										if tmparr.count != 0 then
										(
											sliderTime = tmparr[1] as time
										)
									)
									default:()
								)
							)
							catch()

						)

						if(cp.outputSizeTgl==true) then
						(
							renderWidth = cp._renderWidth
							renderHeight = cp._renderHeight
						)
					)
				)
			)
		)
	)

	fn hideByActivePass =
	(
		if(isvalidnode LPM_activePass) then(hideByPass  LPM_activePass)
	)

	fn updateCameraDDL =
	(
		--camera
		cameraList=#(("Active Viewport:"+(substring (viewport.getType() as string) 6 -1)))
		curCameras = cameras as array
		for i in curCameras where (classof i!=Targetobject) do append cameraList i.name
		cameraDDl.items=cameraList

		if(isvalidNode LPM_Root.renderCamera) then
		(
			x=(findItem  cameraDDl.items LPM_Root.renderCamera.name)
			if (x!=0) then
			cameraDDl.selection=x
		)
	)

	fn LPM_Resize theSize=
	(
		ySize=((theSize.y - 104) as integer)
		if(ySize<0) then
			ysize=0
		dotNetSize=dotNetObject "System.Drawing.Size" theSize.x ySize

		tv.size=dotNetSize
		xSize=((theSize.x))
		yPos=((theSize.y - 48) as integer)

		tyPreviewButton.pos=[xSize-340,yPos+25]
		nukeRenderButton.pos=[xSize-280,yPos+25]
		maxFileRenderButton.pos=[xSize-225,yPos+25]
		localRenderButton.pos=[xSize-170,yPos+25]
		networkRenderButton.pos=[xSize-110,yPos+25]
		skipIdiotChecks.pos=[xSize-40,yPos+25]

		openRenderDirButton.pos=[xSize-17,yPos+1]
		setRenderDirButton.pos=[xSize-38,yPos+1]
		OutputPathDDL.width=xSize-40
		OutputPathDDL.pos = [0,yPos]

		passDDL.width=xSize-32
		hideButton.pos=[xSize-22, hideButton.pos[2]]
		previewSizeDDL.pos=[xSize-45, previewSizeDDL.pos[2]]
		previewTypeDDL.pos=[xSize-104, previewSizeDDL.pos[2]]

		colorButton.pos=[xSize-102, colorButton.pos[2]]
		chkbtn_HideRFW.pos=[xSize-120, chkbtn_HideRFW.pos[2]]
		chkbtn_SkipExistingImages.pos=[xSize-105, chkbtn_SkipExistingImages.pos[2]]

		cameraDDL.width=amax #(20, (xSize-103))
		quickScriptsButton.pos.x=(passDDL.width+2)
		quickScriptsButton.pos.y=2
	)

	fn collapseAlltree =
	(
		tv.CollapseAll()
	)

	fn updateTV=
	(
		tv.nodes.clear()
		fillInTreeView tv
	)

	fn AddScriptOverride =
	(
		tmpScrPos = LPM_Fun.getRoPos 610

		ScriptFloater = newRolloutFloater "Script" 600 530 tmpScrPos.x tmpScrPos.y

		addRollout LPM_scriptRO1 ScriptFloater
		addRollout LPM_scriptRO2 ScriptFloater
		addRollout LPM_scriptRO3 ScriptFloater rolledUp:true
		addRollout LPM_scriptRO4 ScriptFloater rolledUp:true
	)

	fn AddModifierOverride =
	(
		createdialog ModifierOverRollout pos:(LPM_Fun.getRoPos  ModifierOverRollout.width)
	)

	--Dabelow
	fn EditDeadline =
	(
		createDialog LPMDeadline pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow Vray6RenderElements
	fn EditVray6RenderElements =
	(
		createDialog vray6RenderElementsPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow VrayRenderElements
	fn EditVrayRenderElements =
	(
		createDialog vrayRenderElementsPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow Vray6
	fn EditVray6 =
	(
		createDialog vray6PropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow cameraOverscan
	fn EditCameraOverscan =
	(
		createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow nukeExport
	fn EditNukeExport =
	(
		createDialog nukeExportPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	--Dabelow aeExport
	fn EditAeExport =
	(
		createDialog aeExportPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)

	fn AddXrefSceneOverride =
	(
		createdialog XrefSceneRollout pos:(LPM_Fun.getRoPos  XrefSceneRollout.width) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	)

	fn AddXrefObjOverride =
	(
		createdialog XrefObjRollout pos:(LPM_Fun.getRoPos  XrefObjRollout.width) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	)

	fn addSelectedObjects=
	(
		theObjectSet=tv.selectedNode.tag.value

		for i=1 to selection.count do
		(
			if not isGroupHead(selection[i]) then
				theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
		)
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addSelectedGroups=
	(
		theObjectSet=tv.selectedNode.tag.value
		for i=1 to selection.count do
		(
			if isGroupHead(selection[i]) then
				theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
		)
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addWildcard=
	(
		theObjectSet=tv.selectedNode.tag.value
		theObjectSet.wildCard[theObjectSet.wildCard.count+1]="*"
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addVisibleLayers=
	(
		createDialog layerPicker lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos  (LPM_Fun.getIni "Layer Picker" "X_Size" integer 185))
	)

	fn addNamedSet=
	(
		createDialog setPicker pos:(LPM_Fun.getRoPos setPicker.width)
	)

	fn addMats=
	(
		createDialog matPicker pos:(LPM_Fun.getRoPos matPicker.width)
	)

	fn hideEditBox=
	(
		editBox.visible = false
		tv.enabled = true
		tv.refresh()
		tv.focus()
	)

	fn showEditBox=
	(
		if(rNode==undefined) then
			return false
		tv.enabled = false
		editBox.pos = [tv.pos.x+rNode.bounds.x,tv.pos.y+rNode.bounds.y]
		if rNode.tag.value.type == "pass" then
		(
			editBox.text = LPM_Fun.getName rNode.tag.value.name
		)
		else
		(
			editBox.text = rNode.text
		)

		editBox.visible = true
		editBox.focus()
	)

	fn renameNode iNode=
	(
		rNode=iNode
		showEditBox()
	)

	fn hideBySet theSet=
	(
		with redraw off
		(
			--collect object nodes array
			objNodes=#()
			objSetArray=#()

			LPM_Fun.getObjectSetArrays LPM_activePass theSet.type &objNodes &objSetArray

			if(not keyboard.controlpressed) then
				for theNode in objects where  (classof theNode != Targetobject ) and (superclassof thenode !=camera)  do
					hide theNode

			for k=1 to objNodes.count do
			(
				if(objSetArray[k]==theSet) then
				for theNode in objNodes[k] do
				(
					unhide theNode
				)
			)
		)
	)


	fn LPM_ReadLicense=
	(
		true
	)

 --reparents the nodes of the selected type
	 fn tvReparent tvParent nodeType=
	(
		 nodes=tvParent.nodes
		 for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=undefined

		 if(nodeType=="objectSet") or (nodeType =="lightSet") then--backward for objectSets and lightSets
			for i=0 to (nodes.count-1) where nodes.item[(nodes.count-1)-i].tag.value.type==nodeType do nodes.item[(nodes.count-1)-i].tag.value.parent=tvParent.tag.value
		 else
			for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=tvParent.tag.value
	)

	fn CopySetProps =
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet") then
		(
			LPM_ObjSetPropsBuff = LPM_ObjSetProps()

			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			LPM_ObjSetPropsBuff.intP = #()
			for i = 1 to theObjectSet.intP.count do
			(
				LPM_ObjSetPropsBuff.intP[i] = theObjectSet.intP[i]
			)

			LPM_ObjSetPropsBuff.pMatEnable = theObjectSet.pMatEnable
			LPM_ObjSetPropsBuff.pMaterial = theObjectSet.pMaterial
			LPM_ObjSetPropsBuff.expanded = theObjectSet.expanded
			LPM_ObjSetPropsBuff.pColor = theObjectSet.pColor
			LPM_ObjSetPropsBuff.visible = theObjectSet.visible
			LPM_ObjSetPropsBuff.selectable = theObjectSet.selectable
			LPM_ObjSetPropsBuff.userProp = theObjectSet.userProp
		)
		else
		(
			LPM_LightSetPropsBuff = LPM_LightSetProps()

			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			LPM_LightSetPropsBuff.pEnable = theLightSet.pEnable
			LPM_LightSetPropsBuff.pMultiplierEnable = theLightSet.pMultiplierEnable
			LPM_LightSetPropsBuff.pMultiplier = theLightSet.pMultiplier
			LPM_LightSetPropsBuff.pColorEnable = theLightSet.pColorEnable
			LPM_LightSetPropsBuff.pColor = theLightSet.pColor
			LPM_LightSetPropsBuff.pCastShadows = theLightSet.pCastShadows
			LPM_LightSetPropsBuff.pAffectDiffuse = theLightSet.pAffectDiffuse
			LPM_LightSetPropsBuff.pAffectSpecular = theLightSet.pAffectSpecular
			LPM_LightSetPropsBuff.pAffectReflections = theLightSet.pAffectReflections
			LPM_LightSetPropsBuff.pTextureEnable = theLightSet.pTextureEnable
			LPM_LightSetPropsBuff.pTexture = theLightSet.pTexture
			LPM_LightSetPropsBuff.expanded = theLightSet.expanded
		)

		LPM_treeview_rollout.updateTV()
	)

	fn PasteSetProps =
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet")and(LPM_ObjSetPropsBuff.intp!=undefined) then
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.intP = LPM_ObjSetPropsBuff.intP
			theObjectSet.pMatEnable = LPM_ObjSetPropsBuff.pMatEnable
			theObjectSet.pMaterial = LPM_ObjSetPropsBuff.pMaterial
			theObjectSet.expanded = LPM_ObjSetPropsBuff.expanded
			theObjectSet.pColor = LPM_ObjSetPropsBuff.pColor
			theObjectSet.visible = LPM_ObjSetPropsBuff.visible
			theObjectSet.selectable = LPM_ObjSetPropsBuff.selectable
			theObjectSet.userProp = LPM_ObjSetPropsBuff.userProp
		)

		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="lightSet")and(LPM_LightSetPropsBuff.pEnable!=undefined) then
		(
			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theLightSet.pEnable = LPM_LightSetPropsBuff.pEnable
			theLightSet.pMultiplierEnable = LPM_LightSetPropsBuff.pMultiplierEnable
			theLightSet.pMultiplier = LPM_LightSetPropsBuff.pMultiplier
			theLightSet.pColorEnable = LPM_LightSetPropsBuff.pColorEnable
			theLightSet.pColor = LPM_LightSetPropsBuff.pColor
			theLightSet.pCastShadows = LPM_LightSetPropsBuff.pCastShadows
			theLightSet.pAffectDiffuse = LPM_LightSetPropsBuff.pAffectDiffuse
			theLightSet.pAffectSpecular = LPM_LightSetPropsBuff.pAffectSpecular
			theLightSet.pAffectReflections = LPM_LightSetPropsBuff.pAffectReflections
			theLightSet.pTextureEnable = LPM_LightSetPropsBuff.pTextureEnable
			theLightSet.pTexture = LPM_LightSetPropsBuff.pTexture
			theLightSet.expanded = LPM_LightSetPropsBuff.expanded
		)

		LPM_treeview_rollout.updateTV()
	)

	on quickScriptsButton pressed do
	(
		LPM_Fun.QuickScripts();
	)

	on localRenderButton pressed do
	(
		LPM_Fun.setWhoToRenderByRenderType()
		LPM_Fun.localRenderSubmit()
	)

	on setRenderDirButton pressed do
	(
		result = LPM_fun.pickOutputRoot()
		if result != undefined
		then (OutputPathDDL.text = result)
		else()
	)

	on openRenderDirButton pressed do
	(
		shellLaunch LPM_Root.rootDir ""
	)

	on networkRenderButton pressed do
	(
		LPM_Fun.setWhoToRenderByRenderType()
		filein (LPM_Dir+@"plugins\Deadline10.0.ms")
	)

	on maxFileRenderButton pressed do
	(
		LPM_Fun.setWhoToRenderByRenderType()
		filein (LPM_Dir+@"plugins\maxFileSubmit.ms")
	)

	on chkbtn_HideRFW changed state do
	(
		LPM_Fun.setIni "Settings" "HideRFW" ( state)
	)

	on chkbtn_SkipExistingImages changed state do
	(
		LPM_Fun.setIni "Settings" "SkipExistingImages" ( state)
	)

	on previewTypeDDL selected item do
	(
		setRenderType (previewTypeDDL.selected as name)
		type=previewTypeDDL.selected
		if( type== "Region")or(type=="Crop") or(type=="BlowUp") then
			(
				try(EditRenderRegion.EditRegion())catch()
			)
	)

	on previewSizeDDL selected item do
	(
		LPM_Root.previewSize=PreviewSizeDDL.selected as integer
	)

	--hides and colors the nodes
	on colorButton pressed do
	(
		--restore
		if (keyboard.shiftPressed) then
		(
			if(colorBackup!=undefined) then
			(
				for item in colorBackup do try(item[1].wirecolor=item[2])catch()
				displayColor.wireframe=displayColorWire
				displayColor.shaded=displayColorShaded
			)
		)
		else
		(

			if(isvalidnode LPM_activePass) then
			(
				if (colorBackup==undefined) then
				(	colorBackup=(for it in $objects collect #(it, it.wireColor))
					displayColorWire=displayColor.wireframe
					displayColorShaded=displayColor.shaded
				)
				displayColor.wireframe=#object
				displayColor.shaded=#object


				for it in objects where ((superclassof it)==geometryClass) do it.wireColor=white

				--collect object nodes array
				objNodes=#()
				objSetArray=#()
				LPM_Fun.getObjectSetArrays LPM_activePass "objectSet" &objNodes &objSetArray

				for i=1 to objNodes.count do
				(

					theColor=objSetArray[i].pColor

					for theNode in objNodes[i] do
					(
						theNode.wireColor=theColor
					)
				)
			)
		)
	)

	on hideButton changed state do
	(
		rollout displayRollout "Display"
		(
			group "Hide by Category"
			(
				checkbox GeometryChk "Geometry" align:#left
				checkbox ShapesChk "Shapes" align:#left
				checkbox LightsChk "Lights" align:#left
				checkbox CamerasChk "Cameras" align:#left
				checkbox HelpersChk "Helpers" align:#left
				checkbox spacewarpsChk "Space Warps" align:#left
				checkbox particlesChk "Particle Systems" align:#left
				checkbox bonesChk "Bone Objects" align:#left
				button allBut "Hide All" align:#left
				button noneBut "Hide None" align:#left
				button invertBut "Invert" align:#left

			)

			on GeometryChk changed state do
				hideByCategory.geometry=state
			on shapesChk changed state do
				hideByCategory.shapes=state
			on lightsChk changed state do
				hideByCategory.lights=state
			on camerasChk changed state do
				hideByCategory.cameras=state
			on helpersChk changed state do
				hideByCategory.helpers=state
			on spacewarpsChk changed state do
				hideByCategory.spacewarps=state
			on particlesChk changed state do
				hideByCategory.particles=state
			on bonesChk changed state do
				hideByCategory.bones=state
			on allBut pressed do
			(
				hideByCategory.all()
				GeometryChk.state=true
				ShapesChk.state=true
				LightsChk.state=true
				CamerasChk.state=true
				HelpersChk.state=true
				spacewarpsChk.state=true
				particlesChk.state=true
				bonesChk.state=true
			)
			on noneBut pressed do
			(
				hideByCategory.none()
				GeometryChk.state=false
				ShapesChk.state=false
				LightsChk.state=false
				CamerasChk.state=false
				HelpersChk.state=false
				spacewarpsChk.state=false
				particlesChk.state=false
				bonesChk.state=false
			)
			on invertBut pressed do
			(

				GeometryChk.state=hideByCategory.geometry=not GeometryChk.state
				ShapesChk.state=hideByCategory.Shapes=not ShapesChk.state
				LightsChk.state=hideByCategory.Lights=not LightsChk.state
				CamerasChk.state=hideByCategory.Cameras=not CamerasChk.state
				HelpersChk.state=hideByCategory.Helpers=not HelpersChk.state
				spacewarpsChk.state=hideByCategory.spacewarps=not spacewarpsChk.state
				particlesChk.state=hideByCategory.particles=not particlesChk.state
				bonesChk.state=hideByCategory.bones=not bonesChk.state
			)
			on displayRollout open do
			(
				GeometryChk.state=hideByCategory.geometry
				ShapesChk.state=hideByCategory.Shapes
				LightsChk.state=hideByCategory.Lights
				CamerasChk.state=hideByCategory.Cameras
				HelpersChk.state=hideByCategory.Helpers
				spacewarpsChk.state=hideByCategory.spacewarps
				particlesChk.state=hideByCategory.particles
				bonesChk.state=hideByCategory.bones
			)
			on displayRollout close do
			(
				hideButton.checked=false
			)

		)

		if(state) then
			createDialog displayRollout pos:(LPM_Fun.getRoPos displayRollout.width)
		else
			try (destroyDialog displayRollout)catch()
	)

	on tv drawNode arg do
	(
		img = dotNetClass "System.Drawing.Image"--create an image
		img2=img.fromFile (LPM_iconPath + "Root.Bmp")

		theColor=(dotNetClass "System.Drawing.Brushes").Blue
		theFont=dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		arg.Graphics.DrawString Arg.Node.text theFont theColor Arg.bounds.Left Arg.bounds.top
		arg.Graphics.drawImage img2 Arg.bounds.Left Arg.bounds.top
	)

	on tv textChanged arg do()

	on editBox lostFocus e do
	(
		hideEditBox()
	)

	on editBox MouseWheel e do
	(
		hideEditBox()
	)

	on editBox keyUp e do
	(
		case e.keycode.tostring() of
		(
			"Return":
			(
				theNode=rNode
				type = theNode.tag.value.type
				word=editBox.text
				if(type=="shot" or type=="pass") then word=LPM_Fun.removeBadChars word

				theNode.text = word
				case type of
				(
					"wildcard": (	theNode.Parent.tag.value.wildCard[theNode.tag.value.index]=word)
					"shot":
					(
						pos=findstring word "[["
						if(pos!=undefined) then
							theNode.tag.value.name="LPM_"+(substring word 1 pos)
						else
							theNode.tag.value.name="LPM_"+word
						theNode.text=LPM_Fun.getShotName theNode.tag.value
					)
					"pass":
					(
						theNode.tag.value.name="LPM_"+word
						theNode.text = LPM_Fun.generatePassName theNode.tag.value
						updatePassDDL()
					)
					default:	(try(theNode.tag.value.name="LPM_"+word)catch())

				)
				hideEditBox()

				LPM_treeview_rollout.updateTV()
			)
			"Escape":
			(
				hideEditBox()
			)
		)
	)

	on tv keyDown e do
	(
		if (keyboard.controlpressed)and ((e.keycode.tostring())=="Z") then
		(
			max undo
			LPM_treeview_rollout.updateTV()
		)


	)

	on tv keyUp e do
	(
		-- For printing the keycodes out
		-- print (e.keycode.tostring())

		theNode=tv.selectedNode

		TheNodeType = undefined
		try(TheNodeType = LPM_activeElement.tag.value.type)
		catch()

		case e.keycode.tostring() of
		(
			"Add":
			(
				LPM_treeview_rollout.offsetSelectedShot LPM_treeview_rollout.tv #increment
			)
			"Subtract":
			(
				LPM_treeview_rollout.offsetSelectedShot LPM_treeview_rollout.tv #decrement
			)
			"F2":
			(
				if theNode.level >0 then renameNode (tv.selectedNode)
			)
			"Return":
			(
				if theNode.level >0 then renameNode (tv.selectedNode)
			)
			"F5":
			(
				LPM_ProSequencerUpdate()
				LPM_treeview_rollout.updateTV()
			)
			"Delete":
			(
				undo "LPM delete" on
				(
					case TheNodeType of
					(
						"passGroup":
						(
							if(querybox "Are you sure you want to delete the group and all its passes?") then
							(
								grp=LPM_treeview_rollout.tv.selectedNode.tag.value
								chld=LPM_Fun.getAllChildren grp
								delete chld
							)
						)
						"pass":
						(
							deleteSelectedPass tv
							LPM_activePass = undefined
						)
						"objectSet":
						(
							theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
							theObjectSet=theObjectSetNode.tag.value
							delete theObjectSet
							theObjectSetNode.remove()
						)
						"lightSet":
						(
							theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
							theObjectSet=theObjectSetNode.tag.value
							delete theObjectSet
							theObjectSetNode.remove()
						)

						"vrayProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"renderProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"envProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"commonProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"script":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"generic":
						(

						)
						"xrefObj":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"xrefScene":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"ModifierOver":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow
						"Deadline":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow VRay6
						"vray6RenderElements":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow VRay
						"vrayRenderElements":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow VRay6
						"vray6":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow CameraOverscan
						"cameraOverscan":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow nukeExport
						"nukeExport":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						-- Dabelow aeExport
						"aeExport":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"shot":
						(
							deleteSelectedPass tv
							LPM_activePass = undefined
						)
						"ShotPass":
						(
							theShot=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							index=LPM_treeview_rollout.tv.selectedNode.tag.value.index
							deleteItem theShot.passes index
							deleteItem theSHot.passesOn index
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"object":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							LPM_Fun.pruneArray theParent.nodes theObj.leaf

							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"light":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							LPM_Fun.pruneArray theParent.nodes theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"layer":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							LPM_Fun.pruneArray theParent.layers theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"wildCard":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							theParent.wildcard=(for i=1 to theParent.wildCard.count where i!=theObj.index collect theParent.wildCard[i])
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"namedSet":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							theParent.namedSet=(for i=1 to theParent.namedSet.count where i!=theObj.index collect theParent.namedSet[i])
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"mat":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value

							LPM_Fun.pruneArray theParent.mats theObj.leaf

							LPM_treeview_rollout.tv.selectedNode.remove()
						)
					)
					LPM_treeview_rollout.updateTV()
					LPM_activeElement = LPM_treeview_rollout.tv.selectedNode
				)
			)
		)
	)

	on tv BeforeExpand Arg do
	(
		if preventExpand then
		(
			arg.Cancel = true
			preventExpand = false
		)
		else
		(
			arg.node.tag.value.expanded=true
		)

	)

	on tv BeforeCollapse Arg do
	(
		if preventExpand then
		(
			arg.Cancel = true
			preventExpand = false
		)
		else
		(
			arg.node.tag.value.expanded=false
		)
	)

	on tv MouseDown arg do
	(
		tmpDelta = (timestamp()) - lastMouseDown

		lastMouseDown = timestamp()

		if (tmpDelta<500)and(TmpSelNode == tv.GetNodeAt arg.location) then
		(
			hitNode = tv.GetNodeAt arg.location
			if hitNode != undefined then
			(
				local level = hitNode.level
				if ((15+level*20) < (arg.x)) then
				(
					preventExpand = true
				)
			)
			else
			(
				preventExpand = false
			)
		)

		else
		(
			preventExpand = false
		)

		TmpSelNode = tv.GetNodeAt arg.location
	)

	on tv MouseUp arg do
	(
		nTime=timestamp()
		delta=nTime - sTime
		sTime=0 --Assume its an invalid click, if its valid we will the timestamp later
		local button = arg.button.ToString()

		hitNode = tv.GetNodeAt arg.location
		LPM_activeElement = hitNode
		newActive=LPM_Fun.passByNode hitNode
		if(isvalidnode newActive) then
		(
			LPM_activePass=newActive
		)

		updatePassDDL()

		if hitNode==undefined then
		(
			if(button=="Middle") then
			(
				max unhide all
			)
		)

		if hitNode != undefined then
		(
			if(button=="Left" or button=="Middle") then
			(
				local level = hitNode.level
				if(arg.x>(38+level*20) and (button=="Left") and (preventExpand==false)) then
				(
					sTime=nTime
					if (delta > 600) and (delta < 1100) and (oldHitNode==hitNode)  then
					(
						renameNode hitNode
					)
				)

				if((15+level*20) < (arg.x)) and ((arg.x) < (37+level*20)) then

				case hitNode.tag.value.type of
				(
					"pass":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"objectSet":
					(
						hitNode.tag.value.intp[1]= (mod (hitNode.tag.value.intp[1])  3) + 1
						LPM_Fun.setIcon hitNode
					)
					"lightSet":
					(
						hitNode.tag.value.pEnable= (mod (hitNode.tag.value.pEnable)  3) + 1
						LPM_Fun.setIcon hitNode
					)
					"shot":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"vrayProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"renderProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"envProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"commonProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					-- Dabelow cameraOverscan
					"cameraOverscan":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					-- Dabelow nukeExport
					"nukeExport":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					-- Dabelow aeExport
					"aeExport":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"script":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"generic":
					(
						hitNode.tag.value.Active= not hitNode.tag.value.Active
						LPM_Fun.setIcon hitNode
					)
					"passGroup":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"ShotPass":
					(
						hitNode.parent.tag.value.passesOn[hitNode.tag.value.index]=hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"xrefLeaf":
					(
						theFile= hitNode.tag.value.leaf[1]
						it=not hitNode.tag.value.leaf[2]
						hitNode.tag.value.leaf[2]= it
						LPM_Fun.setIcon hitNode
						xrefSceneProps=hitNode.parent.tag.value
						if(it==false) then
							LPM_Fun.pruneArray xrefSceneProps.fileNames theFile
						else
							append xrefSceneProps.fileNames theFile
					)
					"ModifierOver":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					-- Dabelow
					"Deadline":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					-- Dabelow Vray6
					"vray6RenderElements":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					-- Dabelow VrayRenderElements
					"vrayRenderElements":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					-- Dabelow Vray6
					"vray6":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"xrefScene":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"xrefObj":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

				)

				if(button=="Middle") then
				(
					undo "LPM middle click" on
					(
						theMode=getCommandPanelTaskMode()

						if(theMode==#display) then
							setCommandPanelTaskMode #create

						case hitNode.tag.value.type of
						(
							"pass":
							(
								hideByActivePass()
								for child in hitNode.tag.value.children where child.type=="generic" do
								(
									op=LPM_Operators.fngetByNode child
									if(op!=0) then
										op.fnPerformAction #middleClick
								)
							)
							"shot":
							(
								if(isvalidnode hitNode.tag.value.displayPass) then
								(
									LPM_ActivePass=hitNode.tag.value.displayPass
									updatePassDDL()
									hideByActivePass()
								)
								cp=LPM_Fun.firstChildByType (hitNode.tag.value) "commonProps"
								if(cp!=undefined) then
								(
									if(cp.cameraTgl==true) then
									(
										try(
												hide cameras

												theViewport=viewport.activeViewport
												case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
												(
													"Viewport 1": theViewport=1
													"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
													"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
													"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
												)

												viewport.activeViewport=theViewport
												viewport.setCamera cp._Camera
												select cp._Camera
												unhide cp._Camera

												case cp._rendTimeType of
												(
													3:
													(
														sliderTime = cp._rendStart
													)
													4:
													(
														tmparr = filterString cp._rendPickupFrames ", -"

														if tmparr.count != 0 then
														(
															sliderTime = tmparr[1] as time
														)
													)
													default:()
												)

												if(isvalidnode cp._Camera.target) then
													unhide cp._Camera.target

											)catch()
									)

									format "before node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
									if(cp.timeOutputTgl) then
									(
										case cp._rendTimeType of
										(
											3:(
												if(cp._rendStart < cp._rendEnd ) then
												(
													animationRange = interval cp._rendStart cp._rendEnd
												)
											)
										)
									)

									format "after node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
								)
							)

							"layer":
							(
								theLayerName=hitNode.tag.value.leaf
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects

								theLayer=layermanager.getlayerfromname theLayerName
								if(theLayer!=undefined) then
								(
									theArray=#()
									theLayer.nodes &theArray
									theLayer.ishidden=false
									unhide theArray
								)

							)
							"objectSet":
							(
								hideBySet hitNode.tag.value
							)
							"lightSet":
							(
								hideBySet hitNode.tag.value
							)
							"object":
							(
								ctrl= not (keyboard.controlpressed)
								(
									if(ctrl) then
										hide objects
									theNode=hitNode.tag.value.leaf

									if(isGroupHead theNode) then
										(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
									unhide hitNode.tag.value.leaf
								)
							)
							"light":
							(
								ctrl= not (keyboard.controlpressed)
								(
									if(ctrl) then
										hide lights
									theNode=hitNode.tag.value.leaf

									if(isGroupHead theNode) then
										(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
									unhide hitNode.tag.value.leaf
								)
							)
							"wildCard":
							(

								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects
								try(
									unhide (execute ("$"+hitNode.tag.value.leaf))
								)
								catch (messageBox ("wildCard Error"+getcurrentException()))

							)
							"namedSet":
							(
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects

								(for item in selectionSets[hitnode.tag.value.leaf] do unhide item)

							)
							"mat":
							(
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects
								local foundMat
								for mat in scenematerials do if(mat.name==hitNode.tag.value.leaf) then foundMat=mat
								if(foundMat!=undefined) then
									for it in objects where it.material==foundMat do unhide it
							)
							"generic":
							(
								op=LPM_Operators.fngetByNode hitNode.tag.value
								if(op!=0) then
									op.fnPerformAction #middleClick
							)
						)
						if(theMode==#display) then
							setCommandPanelTaskMode theMode
					)
				)
			)

			if(button=="Right") then
			(
				preventExpand = false

				case hitNode.tag.value.type of
				(
					"root":popUpMenu rc_RootMenu
					"pass":popUpMenu rc_PassMenu
					"renderProps":popUpMenu  rc_RenderPropsMenu
					"vrayProps":popUpMenu  rc_vrayPropsMenu
					"objectSet":popUpMenu rc_objectSetMenu
					"lightSet":popUpMenu rc_objectSetMenu
					"object":popUpMenu rc_objectMenu
					"light":popUpMenu rc_objectMenu
					"layer":popUpMenu rc_layerMenu
					"envProps":popUpMenu rc_atmPropsMenu
					"commonProps":popUpMenu rc_CommonPropsMenu
					"wildCard":popUpMenu rc_wildCardMenu
					"namedSet":popUpMenu rc_namedSetMenu
					"shotRoot":popUpMenu rc_shotRootMenu
					"shot":popUpMenu rc_shotMenu
					"xrefObj":popUpMenu rc_xrefObj
					"xrefScene":popUpMenu rc_xrefScene
					"ShotPass":popUpMenu rc_shotPassMenu
					"script":popUpMenu rc_scriptMenu
					"passGroup":popUpMenu rc_PassGroup
					"mat":popUpMenu rc_matMenu
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #rightClick
					)
					"ModifierOver":popUpMenu rc_ModifierOverMenu
					"Deadline":popUpMenu rc_deadlinePropsMenu 							-- Dabelow
					"vray6":popUpMenu rc_vray6PropsMenu 								-- Dabelow Vray6
					"vray6RenderElements":popUpMenu rc_vray6RenderElementsPropsMenu 	-- Dabelow Vray6RenderElements
					"vrayRenderElements":popUpMenu rc_vrayRenderElementsPropsMenu 		-- Dabelow VrayRenderElements
					"cameraOverscan":popUpMenu rc_cameraOverscanPropsMenu 				-- Dabelow cameraOverscan
					"nukeExport":popUpMenu rc_nukeExportPropsMenu 						-- Dabelow nukeExport
					"aeExport":popUpMenu rc_aeExportPropsMenu 							-- Dabelow aeExport
				)
			)
			tv.selectedNode=hitNode
		)
		else if (button=="Right")  then
			popUpMenu rc_RootMenu

		oldHitNode = hitNode
	)

	on tv NodeMouseDoubleClick arg do
	(
		LPM_doubleClick = true
	)

	on tv MouseDoubleClick arg do
	(
		LPM_doubleClick = true
		hitNode = tv.GetNodeAt arg.Location
		if (hitNode != undefined) then
		(
			if((37 + hitNode.level*20) < arg.x) then
			(
				case hitNode.tag.value.type of
				(
					"root":popUpMenu rc_RootMenu
					"pass":
					(
						LPM_doubleClick = true

						filein (LPM_Dir + "passSettingsRO.ms")
					)
					"renderProps":--popUpMenu  rc_RenderPropsMenu
					(
						filein (LPM_Dir + "renderPropsEdit.ms")
					)

					"vrayProps":popUpMenu  rc_vrayPropsMenu
					"objectSet": (createDialog LPM_objectSetProps 194 403 pos:(LPM_Fun.getRoPos 194))
					"lightSet": (createDialog lightSetProps pos:(LPM_Fun.getRoPos 194))
					"object":popUpMenu rc_objectMenu
					"light":popUpMenu rc_objectMenu
					"layer":popUpMenu rc_layerMenu
					"envProps": createdialog LPM_atmRollout pos:(LPM_Fun.getRoPos  LPM_atmRollout.width)
					"commonProps": createDialog LPM_commonRollout pos:(LPM_Fun.getRoPos  LPM_commonRollout.width)
					"wildCard":(createDialog wildCardRO pos:(LPM_Fun.getRoPos  wildCardRO.width))
					"namedSet":popUpMenu rc_namedSetMenu
					"shotRoot":popUpMenu rc_shotRootMenu
					"shot":(filein (LPM_Dir + "IncludePassesRO.ms"))
					"xrefObj":(AddXrefObjOverride())
					"xrefScene":(AddXrefSceneOverride())
					"ShotPass":popUpMenu rc_shotPassMenu
					"script":(LPM_treeview_rollout.AddScriptOverride())
					"passGroup":popUpMenu rc_PassGroup
					"mat":popUpMenu rc_matMenu
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #edit
					)
					"ModifierOver":(AddModifierOverride())
					"Deadline":(EditDeadline()) 							-- Dabelow
					"vray6RenderElements":(EditVray6RenderElements()) 		-- Dabelow Vray6
					"vray6":(EditVray6()) 									-- Dabelow Vray6
					"vrayRenderElements":(EditVrayRenderElements()) 		-- Dabelow VrayRenderElements
					"cameraOverscan":(EditCameraOverscan())					-- Dabelow cameraOverscan
					"nukeExport":(EditNukeExport())							-- Dabelow nukeExport
					"aeExport":(EditAeExport())								-- Dabelow aeExport
				)
			)
		)

		LPM_doubleClick = true
	)

	-- DRAG AND DROP
	 on tv ItemDrag arg do
	 (
		 dragnode=arg.item

		 -- Dabelow cameraOverscan / nukeExport / aeExport / Vray6 / VrayRenderElements
		it=arg.item.tag.value.type
		if(it=="pass") or (it=="shot") or (it=="objectSet") or (it=="lightSet") or (it=="renderProps") or (it=="vrayProps")or (it=="envProps") or (it=="commonProps") or (it=="xrefObj") or (it=="xrefScene") or (it=="passGroup") or (it=="ModifierOver") or (it=="script") or (it=="Deadline") or (it=="vray6RenderElements") or (it=="vray6") or (it=="vrayRenderElements") or (it=="cameraOverscan") or (it=="nukeExport") or (it=="aeExport")then
		tv.doDragDrop arg.item m.Move -- this actually starts the drag and drop process
	 )

	 -- INSIDE Drag and Drop
	 on tv DragOver arg do
	 (
		 pos=tv.PointToClient tv.MousePosition -- this gave me a hard time to find out !
		 TestNode= tv.GetNodeAt pos

		 okToDrop=false

		if (testNode != undefined) and (dragNode!=undefined) then -- OK to Drop
		(
			testType=testNode.tag.value.type
			dragType=dragNode.tag.value.type
			if(testType==dragType) and \
			((testType=="objectSet") or (testType=="lightSet") or (testType=="pass") or (testType=="shot") or (testType=="renderProps")or (testType=="passGroup"))	then
				okToDrop=true
			else if(testType=="pass") and (dragType!="shot") and (dragType!="passGroup") then
				okToDrop=true
			else if((testType=="passGroup") or (testType=="root"))and (dragType=="pass") then
				okToDrop=true
			else if(testType=="shot") and (dragType =="commonProps") then
				okToDrop=true
			else if(testType=="shot") and (dragType =="pass") then
				okToDrop=true
		)

		 if(okToDrop) then
			 arg.Effect=arg.AllowedEffect
		 else
			 arg.Effect=m.none
	 )
	 -- END Drag and Drop (drop the item)

	 on tv DragDrop arg do
	(
		 pos=tv.PointToClient tv.MousePosition
		 DropNode=tv.GetNodeAt pos
		 if(dragNode!= dropNode) then
		 (
			if(dragNode.tag.value.type==dropNode.tag.value.type) then--drag pass to pass or set to set\ --drag pass to pass or set to set or shot to a shot
			(
				if dragNode.tag.value.type != "pass" then
				(
					dragTvParent=dragNode.Parent
					dropTvParent=dropNode.Parent
					if(dragNode.index>dropNode.index) then
					(
						dragNode.remove() -- need to remove the node from the tree
						dropNode.parent.Nodes.insert dropNode.index dragNode  -- add it to the dropNode children
					)
					 else
					(
						dragNode.remove() -- need to remove the node from the tree
						dropNode.parent.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
					)
					 dragNode.text=dragNode.text--fix for annoying text cutoff

					 --LPM Data
					tvReparent dragTvParent dragNode.tag.value.type
					if(dragTvParent!=dropTvParent) then
					(
						 tvReparent dropTvParent dragNode.tag.value.type
					)
				)
				else
				(
					if (keyboard.shiftpressed) then
					(
						thePass=dropNode.tag.value
						LPM_treeview_rollout.updateTV()
					)
					else
					(
						dragTvParent=dragNode.Parent
						dropTvParent=dropNode.Parent
						if(dragNode.index>dropNode.index) then
						(
							dragNode.remove() -- need to remove the node from the tree
							dropNode.parent.Nodes.insert dropNode.index dragNode  -- add it to the dropNode children
						)
						 else
						(
							dragNode.remove() -- need to remove the node from the tree
							dropNode.parent.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
						)
						 dragNode.text=dragNode.text--fix for annoying text cutoff

						 --LPM Data
						tvReparent dragTvParent dragNode.tag.value.type
						if(dragTvParent!=dropTvParent) then
						(
							 tvReparent dropTvParent dragNode.tag.value.type
						)
					)
				)
			)

			else if(dropNode.tag.value.type=="shot") and (dragNode.tag.value.type=="pass") then --dragging pass into a shot
			(
				theShot=dropNode.tag.value
				thePass=dragNode.tag.value
				theShot.allPasses=false
				if(findItem theShot.passes thePass ==0) then
				(
					append theShot.passes thePass
				)
				addShotTv dropNode
			)

			else if(dropNode.tag.value.type=="passGroup" or dropNode.tag.value.type=="root") then--drop a pass onto passGroup
			(
				dragNode.remove() -- need to remove the node from the tree
				dragNode.tag.value.parent=dropNode.tag.value
				dropNode.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
			)

			else if(dropNode.tag.value.type=="pass") or (dropNode.tag.value.type=="shot") then--drop onto a pass or shot
			(
				if(dragNode.tag.value.parent != dropNode.tag.value) then -- dont need to do anything if its just dropping onto itself
				(
					thePass=dropNode.tag.value
					theNode=dragNode.tag.value
					theType=dragNode.tag.value.type

					-- Dabelow / cameraOverscan / nukeExport / aeExport / Dabelow vray6
					if (theType=="envProps") or (theType=="commonProps") or (theType=="xrefObj") or (theType=="xrefScene") or (theType=="Deadline") or (theType=="vray6RenderElements") or (theType=="vrayRenderElements") or (theType=="vray6") or (theType=="cameraOverscan") or (theType=="nukeExport") or (theType=="aeExport") then
					(
						for it in thePass.children where it.type==theType do --delete the previous nodes of the above types
							delete it
					)
					if(keyboard.controlpressed) then --copying
					(
						newNode=copy theNode
						newNode.name = theNode.name
						LPM_Fun.addToLPMLayer newNode
						newNode.parent=thePass
					)
					else if (keyboard.shiftpressed) then--instancing
					(
						newNode=instance theNode
						newNode.name=theNode.name
						LPM_Fun.addToLPMLayer newNode
						newNode.parent=thePass
					)
					else --moving
					(
						theNode.parent=thePass
					)
					updateTv()
				)
			)
		)
	)

	on cameraDDL selected it do
	(
		if(selected==1) then
			LPM_Root.renderCamera=undefined
		else
			LPM_Root.renderCamera=getNodeByName cameraDDL.items[it]
		updateCameraDDL()
	)

	on LPM_treeview_rollout resized theSize do
	(
		if theSize[1] < 345 then
		(
			LPM_treeview_rollout.width = 345
		)
		if theSize[2] < 240 then
		(
			LPM_treeview_rollout.height = 240
		)
		LPM_Resize [LPM_treeview_rollout.width,LPM_treeview_rollout.height]
	)

	on LPM_treeview_rollout open do
	(
		lpm_fun.preFileOpenCallback_Add()

		editBox.visible = false
		editBox.borderStyle = (dotNetClass "BorderStyle").FixedSingle

		proMode=LPM_ReadLicense()

		if(proMode) then LPM_Treeview_Rollout.title+=""
		else
		(
			LPM_Treeview_Rollout.title+=" DEMO"
			if(LPM_AdPopUp==undefined) then
			(
				purchase()
				global LPM_AdPopUp=false
			)
		)

		initTreeView tv
		fillInTreeView tv
		for i=1 to previewSizeDDL.items.count do
			if((LPM_root.previewSize as string)==previewSizeDDL.items[i]) do
				previewSizeDDL.selection=i
		updateCameraDDL()
		renderType=getRenderType()
		for i=1 to previewTypeDDL.items.count do
		(
			if (renderType==(previewTypeDDL.items[i] as name)) then
			(
				previewTypeDDL.selection=i
			)
		)

		updateRenderButtonsState()
		updateRFWandSkip()
		LPM_Resize (getDialogSize LPM_Treeview_Rollout)
	)

	on LPM_treeview_rollout close do
	(
		lpm_fun.preFileOpenCallback_Remove()

		if(colorBackup!=undefined) then
		(
			for item in colorBackup do try(item[1].wirecolor=item[2])catch()
			displayColor.wireframe=displayColorWire
			displayColor.shaded=displayColorShaded
		)

		--Store the position/size
		LPM_Fun.setIni "LPM Window" "X_Position" ((GetDialogPos LPM_treeview_rollout)[1] as string)
		LPM_Fun.setIni  "LPM Window" "Y_Position" ((GetDialogPos LPM_treeview_rollout)[2] as string)
		LPM_Fun.setIni "LPM Window" "X_Size" (LPM_treeview_rollout.width as string)
		LPM_Fun.setIni "LPM Window" "Y_Size" (LPM_treeview_rollout.height as string)
		LPM_Fun.destroyAllDialogs()
	)

	on OutputPathDDL MouseDoubleClick arg do
	(
		if OutputPathDDL.readonly then
		(
			OutputPathDDL.readonly = false
			OutputPathDDL.BackColor = LPM_BackColor
		)
	)


	on OutputPathDDL keyUp e do
	(
		case e.keycode.tostring() of
		(
			"Escape":
			(
				OutputPathDDL.readonly = true
				tmpcol = ((colorMan.getColor #timeSliderBg)*255) as color
				OutputPathDDL.BackColor = dotNetColor tmpcol
				OutputPathDDL.text = LPM_Root.rootDir
			)
			"Return":
			(
				if OutputPathDDL.readonly then
				(
					OutputPathDDL.readonly = false
					OutputPathDDL.BackColor = LPM_BackColor
				)
				else
				(
					OutputPathDDL.readonly = true
					tmpcol = ((colorMan.getColor #timeSliderBg)*255) as color
					OutputPathDDL.BackColor = dotNetColor tmpcol

					pathString = OutputPathDDL.text
					isUNC=false
					if(pathString[1]=="\\" and pathString[2]=="\\") then
						isUNC=true

					theArray=filterString pathString "\\"
					pathString=""
					for i=1 to (theArray.count - 1) do
						pathString+=theArray[i]+"\\"

					pathString+=theArray[theArray.count]
					if(isUNC) then pathString="\\\\"+pathString

					pathString+="\\"

					if doesFileExist pathString then
					(
						LPM_Root.rootDir = OutputPathDDL.text = pathString
					)
					else
					(
						if (makeDir pathString) then
						(
							LPM_Root.rootDir = OutputPathDDL.text = pathString
						)
						else
						(
							OutputPathDDL.text = LPM_Root.rootDir
						)
					)
				)
			)
		)
	)
)

freshOpen = undefined

if(not (isvalidNode LPM_Root)) then
(
	( freshOpen = true )

	LPM_Root=LPM_Fun.createNode "Root" "root"
	if(maxfilePath!="") then
	(
		LPM_Root.rootdir = LPM_Fun.autoSetRenderOutput()
	)
	else

	LPM_Root.rootdir=(getDir #renderoutput )+"\\"
	LPM_Root.fileType=LPM_Fun.getIni "Settings" "Default Format" string "exr"

	filein (LPM_Dir+@"makeRenderElements.ms")
)
else ( freshOpen = false )

if(LPM_Root.pathString==undefined) then
	LPM_Root.pathString=LPM_Fun.getIni "LPM Render" "Path" string "$Shot\\$APass$Pass\\$APass$Pass"

if(	(LPM_Fun.FirstChildByType LPM_Root "shotRoot")==undefined) then
(
	shotRoot=LPM_Fun.createNode "shotRoot" "shotRoot"
	shotRoot.parent=LPM_Root
)

if ((getProperty LPM_Root #version)<2) then
(
	x=queryBox "Unfortunately versions below 0.86 Beta and below are not compatible with versions 0.90 Beta and above.  Fortunately such code breaks such code breaks should not occur in the future.  Delete old LPM Data Yes/No?"
	if(x)==true then
	(
		delete $LPM_Root...*
		messageBox "Old Data Cleared, please relaunch LPM, thank you!"
	)
)
else
(
	--check/set the name format of all the nodes
	if( not LPM_Root.namesUpdated) then
	(
		theNodes=LPM_Fun.getAllChildren LPM_Root
		for it in theNodes do
		(
			if((substring it.name 1 4)!="LPM_") then
				it.name="LPM_"+it.name
		)
		LPM_Root.namesUpdated=true
	)
	--update user props from version 0099
	if(LPM_Root.id <= 0099) then
	(
		theNodes=LPM_Fun.getAllChildren LPM_Root
		for it in theNodes where it.type=="objectSet" do
		(
			if(it.userProp=="") then it.userProp=getUserPropBuffer it
		)
	)

	xPos=LPM_Fun.getIni "LPM Window" "X_Position" integer 0
	yPos=LPM_Fun.getIni "LPM Window" "Y_Position" integer 0
	sizeX=LPM_Fun.getIni "LPM Window" "X_Size"  integer 200
	sizeY=LPM_Fun.getIni "LPM Window" "Y_Size"  integer 430

	if(sizeX==0) then sizeX=200
	if(sizeY==0) then sizeY=430

	createDialog LPM_treeview_rollout pos:[xPos,yPos] height:SizeY width:sizeX menu:rc_MainMenu    style:#(#style_toolwindow, #style_sysmenu,#style_resizing) lockHeight:false lockWidth:false -- 	  style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)

	-- Only run if this is the first time LPM was launched in this scene
	if freshOpen then
	(
		-- Create Default Pass
		filein (LPM_Dir+@"QuickScripts\01Beauty Pass.ms")

		-- Create Default Shot
		theShot=LPM_Fun.createShot LPM_Root
		theShot.name = "LPM_Shot_v001"
		shotNode=LPM_treeview_rollout.createShotTv theShot
		LPM_treeview_rollout.addShotTv shotNode
	)
)