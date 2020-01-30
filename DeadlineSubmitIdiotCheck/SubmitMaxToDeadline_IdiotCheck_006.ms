struct SMTDIdiotCheck
(
	function getCameras =
	(

		(for obj in objects where (iskindof obj camera) collect obj)
	),

	function fileSizeChk = 
	(
		return #("pass")
		
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking FileSize" 3)catch()
		curSize = ( getFileSize ( maxFilePath + maxFileName ) ) as integer 
		
		if curSize > 100000000 then
		(
			if curSize > 500000000 then ( return #("fail", 1, #( "Filesize over 500MB, reference or cache scene elements externally." ) )	)
			else ( return #("fail", 1, #( "Filesize over 100MB, reference or cache scene elements externally." ) )	)
		)
		else( return #("pass") )
	),
	
	-- Ensures there is a camera in your scene
	function noCamerasChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking for cameras" 3)catch()
		if (SMTDIdiotCheck.getCameras()).count != 0 then()else
		(
			return #("fail", 1, #( "No cameras in your scene!" ) )
		)
		return #("pass")
	),
	
	-- checks for render type to match view
	function renderViewChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking render view type" 3)catch()
		renderType = getRenderType()
		if renderType == #view then()else
		(
			return #("fail", 3, #( "Render type not set to View!" ) )
		)
		return #("pass")
	),

	-- Checks for a framerange
	function rendTimeTypeChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking render time type" 3)catch()
		renderType = getRenderType()
		if rendTimeType == 3 then()else
		(
			return #("fail", 4, #( "Render time not set to Range!" ) )
		)
		return #("pass")
	),

	-- checks to see if any cameras have a multipass camera effect enabled
	function cameraMultiPassChk =
	(
		results = #()

		for cam in SMTDIdiotCheck.getCameras() do
		(			
			try(LPM_DeadlineSubmitRo.log_append ( "IC: Checking '" + ( cam.name as string ) + "' for enabled multipass camera effects" ) 3)catch()
			try
			(
				if cam.mpassEnabled == true then
				(
					result = ( "\" " + (cam.name) + " \"  has multipass enabled! ")
					join results #( result )
				)else()
			)catch()			
		)

		if results.count >= 1
		then
		(
			return #("fail", 2, results )
		)
		else
		(
			return #("pass")
		)
	),

	-- checks to see if any fumeFX containers are set to backburner mode
	function fumeFXbackburnerModeChk = 
	(
 		try(LPM_DeadlineSubmitRo.log_append "IC: Checking for any fumefx containers set to backburner simulation mode enabled" 3)catch()
		results = #()
		
		objs = objects as array

		for obj in objs do
		(			
			if classof obj == fumefx then
			(			

				try(LPM_DeadlineSubmitRo.log_append ( "IC: Checking '" + ( obj.name as string ) + "' for  backburner simulation mode enabled" ) 3)catch()

				if obj.BackBurnerSim == true then
				(
					result = ( "\" " + (obj.name) + " \"  is in backburner mode! ") 1
					join results #( result )
				)else()			
			)			
		)

		if results.count >= 1
		then
		(
			return #("fail", 2, results )
		)
		else
		(
			return #("pass")
		)
	),

	-- checks to see if the frame rate is set to 24 fps
	function frameRateChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking frame rate" 3)catch()

		if framerate != 24
		then
		(
			return #("fail", 4, #( "Framerate not set to 24fps!"  ) )
		)
		else
		(
			return #("pass")
		)
	),

	-- checks to see if the file is saved into an autoback folder
	function MTautobackChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking to make sure scene file not saved in the MT_Autobak Folder" 3)catch()

		fileString = maxFilePath 

		if fileString == ""
		then
		(
			return #("fail", 1, #( "File not saved!"  ) )
		)
		else()
		
		try( fileStringEnd = substring fileString (filestring.count - 11) 999 )catch()

		if fileStringEnd == @"MT_autoback\" 
		then
		(
			return #("fail", 1, #( "Move your scene out of the Autobak folder to be able to submit!!!"  ) )
		)
		else
		(
			return #("pass")
		)
	),

	-- Warns the user if they are submitting a job as suspended
	function SubmitSuspendedChk =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking if sending job as suspended" 3)catch()
		if SMTDSettings != undefined and SMTDSettings.SubmitAsSuspended
		then ( return #( "fail", 4, #( "ATTN: Submitting as suspended." ) ) )
		else ( return #("pass") )
	),

	-- Cheks if there are any effects overrides enabled, but there are no render elements in the scene
	function RenderElementsMissing =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking render elements for proper enable/disable settings" 3)catch()

		function elementCompare arg_thePass arg_theElements =
		(
			ep=LPM_Fun.firstChildByType arg_thePass "envProps" 				-- Get the ENV PROPS node
			if ep == undefined then( return #pass ) 		

			if ep.elementOverride == true and arg_theElements.count == 0
			then ( return #fail )
			else( return #pass )
		)

		renderCollect = LPM_Fun.getWhoToRender()
		results = 0

		for i=1 to renderCollect.count do
			(
				thePass=renderCollect[i][1]

				re = maxOps.GetCurRenderElementMgr() 						-- Get the render elements manager
				numElements = re.NumRenderElements() 						-- Get the number of render elements
				
				theElements = #()											-- Collect the render elements
				for i in 1 to numElements do
				(
					theEle=re.GetRenderElement (i-1)
					append theElements theEle.elementName
				)
				
				result = elementCompare thePass theElements					-- Compare the pass and its selected elements
				if result == #fail then results += 1

				try
				(
				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					thePass = thePass.AdjustmentFor
					result =  elementCompare thePass theElements			-- Compare the pass and its selected elements
					if result == #fail then results += 1
				))catch()
			)

		message = ( "Render Elements missing for " + ( results as string ) + " operators!" )

		if results > 0
		then ( return #( "fail", 2, #( message ) ) )
		else ( return #("pass") )
	),

	-- Examines if there are any render elements set to active, and warns user against it. All elements shold be handled by an LPM elements operator
	function RenderElementsEnabled = 
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking to make sure render elements are enabled" 3)catch()

		re = maxOps.GetCurRenderElementMgr() 						-- Get the render elements manager
		numElements = re.NumRenderElements() 						-- Get the number of render elements

		theElements = #()
		for i in 1 to numElements do
		(
			theEle=re.GetRenderElement (i-1)
			append theElements theEle
		)

		errors = 0
		for element in theElements do ( if element.enabled then errors += 1 )

		message = ( "There are " +  ( errors as string ) + " render elements active, they should be disabled and handled through and Elements and effects override.")

		if errors > 0
		then ( return #( "fail", 4, #( message ) ) )
		else ( return #("pass") )
	),

	-- Looks for any active hairfarm render effects, which probably shouldnt be on if you are rendering with Vray
	function activeHairFarmEffects =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking to make sure render elements are enabled" 3)catch()

		collectedEffects = for num in 1 to numEffects collect (getEffect num)

		for collectedEffect in collectedEffects do 
		(
		 	if ( ( classof collectedEffect ) == Hair_Farm_RendererrenderEffect ) and ( IsActive collectedEffect ) 
			then ( return #( "fail", 4, #( "ATTN: '"+ (collectedEffect as string) +"' is enabled, not advised if rendering using vray hair." ) ) )
		)

		return #("pass")
	),

	function phoenixFD_atmosphericGeometry =
	(	
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking to make sure PhoenixFD containers use Atmospheric Geometry instead of Atmosphere render modes." 3)catch()

		phoenixContainers = getclassinstances FireSmokeSim

		for phoenixContainer in phoenixContainers do 
		(
		 	if ( phoenixContainer.rendMode == 0 and phoenixContainer.geommode == 0 )
			then ( return #( "fail", 4, #( "ATTN: '"+ (phoenixContainer as string) +"' rendering mode is set to 'Volumetric' and should be set to 'Volumetric Geometry' to render with a depth channel." ) ) )
		)
		return #("pass")
	),

	-- Warns if the Vray VFB is enabled on submission
	function RenderVrayVFBEnabled =
	(

		return #("pass") 
	),

	-- Warns if Vray IPR mode snabled
	function RenderVrayRegion =
	( 
		
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking if VRay set to region renderer" 3)catch()
		/*
		if vrayVFBGetRegionEnabled()
		then ( return #( "fail", 4, #( "ATTN: Submitting as region renderer." ) ) )
		else ( return #("pass") )
		*/
		return #("pass") 
	),

	-- Warns if vray progressive renderer is enabled
	function RenderVrayProgressiveEnabled =
	(
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking if VRay set to progressive renderer" 3)catch()
		--if renderers.current.imageSampler_type != 1
		--then ( return #( "fail", 4, #( "ATTN: Submitting as progressive renderer." ) ) )
		--else ( return #("pass") )
		return #("pass") 
	),

	function getMissingPluginsChk =
	(
		results = #()
		try(LPM_DeadlineSubmitRo.log_append "IC: Checking for Missing Plugins" 3)catch()

		missingInstances = LPM_deadlineInfo.plugins_missingInstances

		for missingClassInstances in missingInstances do 
		(
			result = (  " '" + missingClassInstances[1] + "'  has " + ( ( missingClassInstances.count - 1 ) as string ) + " missing instances "  ) --( "\" " + (cam.name) + " \"  has multipass enabled! ")
			join results #( result )
		)

		if results.count >= 1
		then
		(
			return #("fail", 2, results )
		)
		else
		(
			return #("pass")
		)
	),

	function checkAssetsAreInProject =
	(
		curFile = pathConfig.convertPathToUnc maxFilePath -- From Asset Switch - Finds Project Directory and Converts to UNC path
		curFileParts = (filterString curFile @"\")
		str = ""

		-- Get the project folder
		for i in 1 to curFileParts.count do
		(
			if curFileParts[i] == "Projects" or curFileParts[i] == "Pitches" then
			(
				for j in 1 to i do
				(
					str = str + curFileParts[j] + @"\"
				)
			
				str = ( str + curFileParts[ ( i + 1 ) ] )
				exit
			)
			else ( str = "" )

			str = "\\\\" + str
		)

		pFDArray = #()

		pFDArray = (for o in geometry where classOf o == FireSmokeSim or classOf o == LiquidSim  collect o)

		ATSOps.CheckNetworkPaths = true -- Turns on status checking for network filepaths 

		atsops.Refresh() -- Updates Asset Tracker

		ATSOps.getFiles &pList -- Gets list of asset paths

		if pFDArray.count > 0 then(for i = 1 to pFDArray.count do(if pFDArray[i].rendinput != "$(same_as_output)" then (append pList pFDArray[i].rendinput)))

		outList = #() 
		totalPathErrorCount = 0

		for i = 1 to pList.count do -- Runs through  
		(
			pPath = trimRight str "\\" -- Trims off trailing slash if there is one for any strange reason

			inPathFlag = false -- Resets flag

			timeout = 0 -- Resets Timeout Counter

			checkTemp = pathConfig.convertPathToUnc pList[i] -- Converts to UNC path


			while checkTemp != "" do -- Chops off end of file path and moves up folder by folder
			(
			
				checkTemp = trimRight checkTemp " *`~1234567890-=!@#$%^&*()_+qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM,./<>?;':[]{}|" -- Trims all characters up to slash
			
				checkTemp = trimRight checkTemp "\\" -- Trims slash
			
				if pathConfig.pathsResolveEquivalent checkTemp str == true then -- Checks if path is a match with project directory
				(
					inPathFlag = true
				) 

				if timeout == 100 then -- exits while loop in event the trim function encounters an unknown character
				(
					checkTemp = ""
					-- print "ERROR: Unkown character in path string or file path too long"
				)

				timeout = timeout + 1 -- timeout tick up
			)

			if inPathFlag == False then -- Adds files that are not in the directory to the output list
			(
				--append outList #(pathConfig.stripPathToLeaf pList[i], pList[i])
				append outList (pathConfig.stripPathToLeaf pList[i] + " Not In Project")
			)
		)

		-- print outList

		if outList.count > 0 then
		(
			return #("fail", 5, #(outList.count as string + " Files not in Project"))
		)
		if outList.count == 0 then
		(
			return #("pass")
		)
	)

)

-- SMTDIdiotCheckObj = SMTDIdiotCheck()
-- SMTDIdiotCheckObj.getMissingPluginsChk()