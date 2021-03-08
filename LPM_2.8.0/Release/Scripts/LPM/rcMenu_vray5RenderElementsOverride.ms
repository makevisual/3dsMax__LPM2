rollout vray5RenderElementsPropsRoll "VRay Render Elements Override 1.0" width:370 height:415
(
	local theNode = undefined
	
	checkbox chk_RenderElementsOn "" pos:[12,12]
		groupbox grp_RenderElements "Render Elements" width:325 height:395 slign:#left offset:[21,-25] enabled:true--false
			dotNetControl elementList "system.windows.forms.listView" width:293 height:365 offset:[35, ( ( grp_RenderElements.height * -1 ) + 14 ) ] --pos:[4,248]

	on elementList ItemChecked arg do
	(
		print "click"
-- 		if SceneCheck_UpdateUI == true 					-- Only perform the button update when the UI is enabled
-- 		then
-- 		(
-- 			curTag = arg.item.tag 						-- Get the identifying tag of that list view item

-- 			for report in SceneCheck_FailReports do 	-- Find its pair in the fail reports
-- 			(
-- 				if report.reportID == curTag 			-- And set the fail report item to correspond with the UI value
-- 				then 
-- 				(
-- 						report.enabled = arg.item.Checked
-- 				)
-- 			)

-- 				SceneCheckUI_Struct.doButtonUpdate()
-- 			)
-- 		else()
	)

	function LVsetproperties arg_LV =
	(

		arg_LV.view 			= (dotNetClass "system.windows.forms.view").details
		arg_LV.GridLines 		= false
		arg_LV.FullRowSelect 	= true
		arg_LV.Sorting 			= (dotNetClass "System.Windows.Forms.SortOrder").None
		arg_LV.HideSelection 	= false
		arg_LV.AutoArrange 		= false
		arg_LV.HeaderStyle 		= (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").none
		arg_LV.MultiSelect 		= false													-- Set to single selection mode
		print "----------- 1 "
		--show arg_LV.TopItem
		print "----------- 2 "
		arg_LV.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
 		arg_LV.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 30 30 30
		arg_LV.CheckBoxes 		= true
	)

	-- Sets the width of the list view columns, and their names
	function LVsetColumns arg_LV columnsAr =
	(
		arg_LV.columns.add columnsAr[1] 20
		arg_LV.columns.add columnsAr[2] 200
	)

	function LVpopulate arg_LV arg_RenderElements = 
	(
		-- clear and reset the List View
		try( SceneCheck_MainUI.arg_LV.items.clear() )catch()
		rows 			= #()
	
		-- Loop through the render elements and make their entries
		for arg_RenderElement in arg_RenderElements do 
		(
			li=dotNetObject "System.Windows.Forms.ListViewItem" ""
			li.UseItemStyleForSubItems = false

			li.subitems.add arg_RenderElement.name
			li.checked 	=  arg_RenderElement.enabled -- TODO: change this from reading the current state
 			li.tag 		= arg_RenderElement.animhandle 
			
			-- Add it to the array of items to be added to the list view
			append rows li
		)

		-- add the array of items to the list view
		arg_LV.items.addRange rows
	)

	function collectElements =
	(
		struct elementObjStr
		(
			animhandle = undefined,
			name = "",
			enabled = false
		)

		re 					= maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
		existingElements 	= #()

		for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
		(
			curElement = ( re.GetRenderElement i )
			elementObj = elementObjStr()
			elementObj.animhandle 		= gethandlebyanim curElement
			elementObj.name 			= curElement.elementName
			elementObj.enabled 			= curElement.vrayVFB

			append existingElements elementObj
		)

		print existingElements

		return existingElements
	)

	on vray5RenderElementsPropsRoll open do
	(
		elementList.enabled = false
		LVsetproperties 	elementList
		LVsetColumns 		elementList #("","Elements" )
		--collectElements()

		LVpopulate 	 		elementList ( collectElements() ) -- #(#("A",true),#("B",true),#("C",false),#("D",false))

 		--listView_Fill elementList #("A","B","C")

		--LPM_Fun.InitListView elementList "vray5RenderElements" 223
		--LPM_Fun.FillListView elementList elementArray theNode.activeElement
--		LPM_Fun.FillListView elementList #("A","B","C") theNode.activeElement
--  		LPM_treeview_rollout.tv.enabled=false
--  		local cp=LPM_treeview_rollout.tv.selectedNode.tag.value
--  		theNode=LPM_treeview_rollout.tv.selectedNode

-- 		deadline_ConnectRepo()
-- 		deadline_GetLimits cp
-- 		deadline_GetGroups cp

-- 		chk_priorityOn.checked 					=cp.priorityOn 				
-- 			chk_priorityOffsetOn.checked 		=cp.priorityOffsetOn		
-- 			spn_priorityOffset.value 			=cp.priorityOffset 		
-- 			chk_priorityAbspoluteOn.checked 	=cp.priorityAbsoluteOn	
-- 			spn_priorityAbsolute.value 			=cp.priorityAbsolute 	

-- 		chk_TasksOn.checked 					= cp.taskSizeOn 	
-- 			spn_taskSize.value 					= cp.taskSize 

-- 		chk_GroupOn.checked 					= cp.submitGroupOn 			
-- 		chk_LimitsOn.checked 					= cp.submitLimitsOn
		
-- 		toggleState()

-- 			-- Fixing for override
-- 			chk_priorityOffsetOn.checked 		=cp.priorityOffsetOn		
-- 			spn_priorityOffset.value 			=cp.priorityOffset 		
-- 			chk_priorityAbspoluteOn.checked 	=cp.priorityAbsoluteOn	
-- 			spn_priorityAbsolute.value 			=cp.priorityAbsolute 	
 	)
	
	on vray5RenderElementsPropsRoll close do
	(
		-- setFocus vray5RenderElementsPropsRoll
		-- cp=theNode.tag.value
		
-- 		cp.priorityOn 				= chk_priorityOn.checked
-- 			cp.priorityOffsetOn		= chk_priorityOffsetOn.checked
-- 			cp.priorityOffset 		= spn_priorityOffset.value
-- 			cp.priorityAbsoluteOn	= chk_priorityAbspoluteOn.checked
-- 			cp.priorityAbsolute 	= spn_priorityAbsolute.value
					
		-- theNode.text = LPM_Fun.generateDeadlineName cp
		-- LPM_treeview_rollout.tv.enabled=true
	)
)

rcMenu rc_vray5RenderElementsPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem 	copyProps 	"Copy"
	menuItem   	removeProps "Remove"
	
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on editProps picked do
	(		
		createDialog vray5RenderElementsPropsRoll pos:(LPM_Fun.getRoPos  vrayPropsRoll.width)
	)
	
)
--createDialog vray5RenderElementsPropsRoll pos:(LPM_Fun.getRoPos  vrayPropsRoll.width)