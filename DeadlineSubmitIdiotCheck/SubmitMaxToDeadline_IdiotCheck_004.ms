struct SMTDIdiotCheck
(
	-- Ensures there is a camera in your scene
	
	function getCameras =
	(
		(for obj in objects where (iskindof obj camera) collect obj)
	),
	
	function noCamerasChk =
	(
		if (SMTDIdiotCheck.getCameras()).count != 0 then()else
		(
			#("fail", 1, #( "No cameras in your scene!" ) )
		)
		#("pass")
	),
	
	-- checks for render type to match view
	function renderViewChk =
	(
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
		results = #()
		
		objs = objects as array

		for obj in objs do
		(			
			if classof obj == fumefx then
			(			
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
			return #("fail", 1, #( "Framerate not set to 24fps!"  ) )
		)
		else
		(
			return #("pass")
		)
	),

	-- Warns the user if they are submitting a job as suspended
	function SubmitSuspendedChk =
	(
		if SMTDSettings != undefined and SMTDSettings.SubmitAsSuspended
		then ( return #( "fail", 4, #( "ATTN: Submitting as suspended." ) ) )
		else ( return #("pass") )
	),

	-- Cheks if there are any effects overrides enabled, but there are no render elements in the scene
	function RenderElementsMissing =
	(
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

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					thePass = thePass.AdjustmentFor
					result =  elementCompare thePass theElements			-- Compare the pass and its selected elements
					if result == #fail then results += 1
				)
			)

		message = ( "Render Elements missing for " + ( results as string ) + " operators!" )

		if results > 0
		then ( return #( "fail", 2, #( message ) ) )
		else ( return #("pass") )
	),

	-- Examines if there are any render elements set to active, and warns user against it. All elements shold be handled by an LPM elements operator
	function RenderElementsEnabled = 
	(
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
	)
)