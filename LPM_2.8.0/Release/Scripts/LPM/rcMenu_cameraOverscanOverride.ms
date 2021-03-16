rollout cameraOverscanPropsRoll "Camera Overscan Override 1.0" width:325 height:390
(
	local theNode = undefined

	groupbox grp_overscanAmmount "Oversan Ammount" width:313 height:378 slign:#left offset:[-5,0] enabled:true--false
		spn_overscanAmmount "" offset[0,0] 
	-- dotNetControl elementList "system.windows.forms.listView" width:293 height:350 offset:[5, ( ( grp_RenderElements.height * -1 ) + 14 ) ] --pos:[4,248]

	-- event for rollout open 
	on cameraOverscanPropsRoll open do
	(
		elementList.enabled = true 
		LVsetproperties 	elementList
		LVsetColumns 		elementList #("","Elements" )

		-- Get the scene node for the element operator
		cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1
		checkedItems = ca.activeElement

		filteredElements = #()
		filteredElements = collectElements checkedItems 

		-- populate the listview with the filtered elements
		LVpopulate elementList filteredElements
 	)
	
	on cameraOverscanPropsRoll close do
	(
		-- ca properties are set in the ItemChecked event, so every check operation updates the data
	)
)

rcMenu rc_CameraOverscanPropsPropsMenu
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
		createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  cameraOverscanPropsRoll.width)
	)
	
)
createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  cameraOverscanPropsRoll.width)