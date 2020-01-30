global utilityCurProps

struct UtilityTools_Def 
(
	function makeCurProps =
	(
		struct curPropsStr
		(
			node,
			radius,
			falloff,
			subdivs,
	  		extrapolateOn,
	  		nearDistance,
	  		farDistance
	  	)

	  	result = curPropsStr()
	  	return result
	),

	function rollout_setAOprops_Function =
	(
		rollout rollout_setAOprops "AO Settings" width:200 height:110
		(
			groupbox grp1 "AO Settings" pos:[10,5] width:(rollout_setAOprops.width - 20) height:95

			spinner spn_radius 			"Radius"		type:#float range:[0.0,100000,500] offset:[ ( - 5 ) , ( ( grp1.height * -1 ) + 20) ] enabled:false
			spinner spn_falloff 		"Falloff" 		type:#float range:[0.0,1.0,0.3]  offset:[ ( - 5 ) , 0 ] enabled:false
			spinner spn_subdivs		 	"Subdivisions" 	type:#integer range:[1,256,16]	offset:[ ( - 5 ) , 0 ] enabled:false

			on rollout_setAOprops open do 
			(
				re = maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
				existingElements = #()

				for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
				(
					append existingElements ( re.GetRenderElement i )
				)

				utilityCurProps.node = undefined

				for existingElement in existingElements do 
				(
					if VRayExtraTex == ( classof existingElement ) and "_E_AO" == existingElement.elementName
					then ( utilityCurProps.node = existingElement )
				)

				if utilityCurProps.node != undefined
				then 
				(
					utilityCurProps.radius 		= utilityCurProps.node.texture.radius
					utilityCurProps.falloff 	= utilityCurProps.node.texture.falloff
					utilityCurProps.subdivs 	= utilityCurProps.node.texture.subdivs

					spn_radius.enabled  = true
					spn_falloff.enabled = true
					spn_subdivs.enabled = true

					spn_radius.value 	= utilityCurProps.radius
					spn_falloff.value 	= utilityCurProps.falloff
					spn_subdivs.value 	= utilityCurProps.subdivs
				)
			)

			on rollout_setAOprops close do 
			(
				utilityCurProps.node.texture.radius 	= utilityCurProps.radius 
				utilityCurProps.node.texture.falloff 	= utilityCurProps.falloff
				utilityCurProps.node.texture.subdivs 	= utilityCurProps.subdivs
			)

			on spn_radius changed arg 	do ( utilityCurProps.radius 	= arg )
			on spn_falloff changed arg 	do ( utilityCurProps.falloff 	= arg )
			on spn_subdivs changed arg 	do ( utilityCurProps.subdivs 	= arg )
		)

		createDialog rollout_setAOprops lockHeight:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	),

	function rollout_setDepthprops_Function =
	(
		rollout rollout_setDepthprops "Depth Settings" width:200 height:130
		(
			groupbox grp1 "Depth Settings" pos:[10,5] width:(rollout_setDepthprops.width - 20) height:88

			spinner spn_nearDistance 		"Near Distance"	type:#integer range:[0,1000000,0] offset:[ ( - 5 ) , ( ( grp1.height * -1 ) + 20) ] enabled:false
			spinner spn_farDistance		 	"Far Distance" 	type:#integer range:[0,1000000,3600]	offset:[ ( - 5 ) , 0 ] enabled:false
			checkbox chk_extrapolateOn 		"Extrapolate" checked:true enabled:false offset:[67,0]
			button btn_autoSize 			"Auto-set Distance from Camera" offset:[-1,8] width:181 enabled:false

			function getBBoxCorners obj =
			(
				bb = nodeGetBoundingBox obj obj.transform
				xyz = bb[2] - bb[1]
				bBoxCorners = #()
				for x = -.5 to .5 do for y = -.5 to .5 do for z = -.5 to .5 do append bBoxCorners (([ (xyz[1]*x) , (xyz[2]*y) , (xyz[3]*z) ]-(obj.pos-obj.center)) * obj.transform )
				bBoxCorners
			)

			function getDistancesFromCamera = 
			(
				visibleObjects = for obj in objects where obj.ishidden == false and (superClassOf obj) == GeometryClass collect obj

				if selection.count == 1 and ( superclassof selection[1] ) == camera
				then
				(
					curCamera 			= selection[1]
			 		camPos 				= curCamera.pos
					farthestDistance 	= 0 
					closesttDistance 	= 10000 

					for obj in visibleObjects do 
					(
						corners 	= getBBoxCorners obj
						distances 	= for corner in corners collect (distance camPos corner)

						sort distances

						if distances[1] < closesttDistance then closesttDistance = distances[1]
						if distances[distances.count] > farthestDistance then farthestDistance = distances[distances.count]
					)
					return #(closesttDistance,farthestDistance)
				)
				else
				(
					messagebox " Please select the camera you wish to measure depth from."
					return "error"
				)
			)

			on btn_autoSize pressed do 
			(
				result = getDistancesFromCamera()

				if result != "error"
				then 
				(
					utilityCurProps.nearDistance 	= result[1]
					utilityCurProps.farDistance 	= result[2]

					spn_nearDistance.value 	= utilityCurProps.nearDistance
					spn_farDistance.value 	= utilityCurProps.farDistance

					utilityCurProps.node.texture.nearDistance 		= utilityCurProps.nearDistance 
					utilityCurProps.node.texture.farDistance 		= utilityCurProps.farDistance 
				)
			)

			on rollout_setDepthprops open do 
			(
				re = maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
				existingElements = #()

				for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
				(
					append existingElements ( re.GetRenderElement i )
				)

				utilityCurProps.node = undefined

				for existingElement in existingElements do 
				(
					if VRayExtraTex == ( classof existingElement ) and "_E_Depth" == existingElement.elementName
					then (utilityCurProps.node = existingElement )
				)

				if utilityCurProps.node != undefined
				then 
				(
					utilityCurProps.nearDistance 	= utilityCurProps.node.texture.nearDistance
					utilityCurProps.farDistance 	= utilityCurProps.node.texture.farDistance
					utilityCurProps.extrapolateOn 	= utilityCurProps.node.texture.extrapolateOn

					spn_nearDistance.value 		= utilityCurProps.nearDistance
					spn_farDistance.value 		= utilityCurProps.farDistance
					chk_extrapolateOn.checked 	= utilityCurProps.extrapolateOn

					spn_nearDistance.enabled 	= true
					spn_farDistance.enabled 	= true
					chk_extrapolateOn.enabled 	= true
					btn_autoSize.enabled 		= true
				)
			)

			on rollout_setDepthprops close do 
			(
				utilityCurProps.node.texture.nearDistance 	= utilityCurProps.nearDistance 
				utilityCurProps.node.texture.farDistance 	= utilityCurProps.farDistance 
				utilityCurProps.node.texture.extrapolateOn 	= utilityCurProps.extrapolateOn
			)

			on spn_nearDistance changed arg do 		(utilityCurProps.nearDistance 	= arg )
			on spn_farDistance changed arg do 		(utilityCurProps.farDistance 	= arg )
			on chk_extrapolateOn changed state do 	(utilityCurProps.extrapolateOn 	= state )
		)

		createDialog rollout_setDepthprops lockHeight:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	)
)

utilityTools 	= UtilityTools_Def
utilityCurProps = utilityTools.makeCurProps()