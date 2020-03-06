
-- Defines and creates default and templated render element passes.
-- Aaron Dablow: theonlyaaron@gmail.com 

struct elementsDefStr
(
	function element_B_Alpha = 
	(
		newElement = VRayAlpha()

		newElement.enabled  		= false
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRayAlpha"

		return newElement
	),

	function element_B_Diffuse = 
	(
		newElement = VRayDiffuseFilter()

		newElement.enabled 			= false
		newElement.filterOn 		= true
		newElement.elementName 		= "VRayDiffuse"
		newElement.vrayVFB 			= true
		newElement.color_mapping 	= true
		newElement.multiplier 		= 1.0

		return newElement
	),
	
	function element_B_Lighting = 
	(
		newElement = VRayLighting()

		newElement.enabled 			= false
		newElement.filterOn 		= true
		newElement.elementName 		= "VRayLighting"
		newElement.vrayVFB 			= true
		newElement.color_mapping 	= true
		newElement.multiplier 		= 1.0

		return newElement
	),
	
	function element_B_Shadows = 
	(
		newElement = VRayShadows()

		newElement.enabled 			= false
		newElement.filterOn 		= true
		newElement.elementName 		= "VRayShadows"
		newElement.vrayVFB 			= true
		newElement.color_mapping 	= true
		newElement.multiplier 		= 1.0

		return newElement
	),
	

	function element_B_GlobalIllumination =
	(
		newElement = VRayGlobalIllumination()

		newElement.enabled 			= false
		newElement.filterOn 		= true
		newElement.elementName 		= "VRayGlobalIllumination" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_B_Reflection =
	(
		newElement = VRayReflection()

		newElement.enabled 			= false
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRayReflection" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_B_Refraction =
	(
		newElement = VRayRefraction()

		newElement.enabled 			= false
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRayRefraction" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_B_SelfIllumination =
	(
		newElement = VRaySelfIllumination()

		newElement.enabled 			= false 
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRaySelfIllumination" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_B_Specular =
	(
		newElement = VRaySpecular()

		newElement.enabled 			= false 
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRaySpecular" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_B_VRaySSS2 =
	(
		newElement = VRaySSS2()

		newElement.enabled 			= false 
		newElement.filterOn 		= true 
		newElement.elementName 		= "VRaySSS2" 
		newElement.vrayVFB 			= true 
		newElement.color_mapping 	= true 
		newElement.multiplier 		= 1.0 

		return newElement 
	),

	function element_E_AO =
	(
		AO_Tex = VRayDirt()

		AO_Tex.radius 							= 36.0   
		AO_Tex.occluded_color 					= (color 0 0 0) 
		AO_Tex.unoccluded_color 				= (color 255 255 255)
		AO_Tex.distribution 					= 1.0 
		AO_Tex.falloff 							= 0.3 
		AO_Tex.subdivs 							= 8  
		AO_Tex.bias 							= [0,0,0] 
		AO_Tex.affect_alpha 					= false   
		AO_Tex.ignore_for_gi 					= true   
		AO_Tex.consider_same_object_only 		= false  
		AO_Tex.invert_normal 					= false  
		AO_Tex.work_with_transparency 			= false  
		AO_Tex.environment_occlusion 			= false  
		AO_Tex.mode 							= 0  
		AO_Tex.reflection_glossiness 			= 1.0 
		AO_Tex.affect_reflection_elements 		= true 

		newElement 								= VRayExtraTex()
		newElement.enabled 						= false
		newElement.filterOn 					= true
		newElement.elementName 					= "VRayAO"
		newElement.vrayVFB 						= true
		newElement.auto_update_name 			= false
		newElement.texture 						= AO_Tex
		newElement.consider_for_antialiasing 	= false
		newElement.affect_matte_objects 		= false

		return newElement
	),

	function element_E_Depth = 
	(
		Falloff_tex = falloff()

	  	Falloff_tex.color1 						= (color 0 0 0)
	  	Falloff_tex.map1Amount 					= 100.0 
	  	Falloff_tex.map1On 				 		= true 
	  	Falloff_tex.color2 			 			= (color 255 255 255) 
	  	Falloff_tex.map2Amount 					= 100.0  
	  	Falloff_tex.map2On 				 		= true 
	  	Falloff_tex.type  						= 4 
	  	Falloff_tex.direction 					= 0 
	  	Falloff_tex.extrapolateOn 				= true 
	  	Falloff_tex.nearDistance  				= 0.0
	  	Falloff_tex.farDistance  				= 500.0

		newElement 								= VRayExtraTex()
		newElement.enabled 						= false
		newElement.filterOn 					= true
		newElement.elementName 					= "VRayDepth"
		newElement.vrayVFB 						= true
		newElement.auto_update_name 			= false
		newElement.texture 						= Falloff_Tex
		newElement.consider_for_antialiasing 	= false
		newElement.affect_matte_objects 		= false

		return newElement 
	),

	function element_E_VRaySampleRate = 
	(
		newElement = VRaySampleRate()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRaySampleRate" 
		newElement.vrayVFB 			= true 

		return newElement 
	)
)

function sortByElementName arg_1 arg_2 = 
(
	stricmp arg_1.elementName arg_2.elementName  
)

function makeRenderElements =
(
	re = maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
	existingElements = #()

	for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
	(
		append existingElements ( re.GetRenderElement i )
	)

	elementsStr = elementsDefStr 							-- Instiantiate the elements definition struct
	elements 	= (getPropNames elementsStr)				-- Get a list of all the members of that struct
	newElements = #()

	for id in elements do 									-- go through the list of members of the struct
	(
		curElementFunction = (getProperty elementsStr id)	-- Retrive the function out of the struct
		curElement = ( curElementFunction() )				-- Execute the function, and assign it to curElement

		append newElements curElement
	)

	qsort newElements sortByElementName 					-- Alphabetize the names 

	for newElement in newElements do  -- Check to see if the element already exists, and if not, add it 
	(
		exists = false

		for existingElement in existingElements do 
		(
			if ( classof newElement ) == ( classof existingElement ) and newElement.elementName == existingElement.elementName
			then ( exists = true )
		)

		if exists == false
		then ( re.addrenderelement newElement )
	)
)

makeRenderElements()