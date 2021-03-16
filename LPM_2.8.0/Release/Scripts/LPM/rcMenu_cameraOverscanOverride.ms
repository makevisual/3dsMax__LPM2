rollout cameraOverscanPropsRoll "Camera Overscan Override 1.0" width:225 height:130
(
	local theNode = undefined

	groupbox grp_overscanAmmount "Oversan / Underscan Ammount" width:213 height:50 slign:#left offset:[-5,0] enabled:true--false
		spinner spn_overscanAmmount "" range:[0.1,2.0,1.1] offset:[0, ( ( grp_overscanAmmount.height * -1 ) + 14 ) ]

	groupbox grp_resolution "Effect Resolution " width:213 height:65 slign:#left offset:[-5,15] enabled:true--false
		checkbox chk_effectResolution "" range:[1.0,2.0,1.1] offset:[5, ( ( grp_resolution.height * -1 ) + 18 ) ]
		label lab_resolutionCurrent "current: 1920 x 1080" offset:[0,-20] align:#right enabled:false
		label lab_resolutionOverscanned "overscanned: 2112 x 1188" offset:[0,0] align:#right enabled:false

	function updateResolution =
	(
		-- Function updateResolution 
		lab_resolutionCurrent.text = ( "current: " + ( renderWidth as string ) + " x " + ( renderHeight as string ) )
		lab_resolutionOverscanned.text = ( "overscanned: " + ( ( ( renderWidth * spn_overscanAmmount.value ) as integer ) as string ) + " x " + ( ( ( renderHeight * spn_overscanAmmount.value ) as integer ) as string ) )
	)

	on chk_effectResolution changed state do 
	(
		lab_resolutionCurrent.enabled = state
		lab_resolutionOverscanned.enabled = state
	)

	on spn_overscanAmmount changed state do 
	(
		updateResolution()
	)

	-- event for rollout open 
	on cameraOverscanPropsRoll open do
	(

		updateResolution()
		-- elementList.enabled = true 
		-- LVsetproperties 	elementList
		-- LVsetColumns 		elementList #("","Elements" )

		-- Get the scene node for the element operator
		-- cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		-- theNode = cp

		-- ca = custAttributes.get theNode 1
		-- checkedItems = ca.activeElement
		-- filteredElements = #()
		-- filteredElements = collectElements checkedItems 

		-- populate the listview with the filtered elements
		-- LVpopulate elementList filteredElements
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