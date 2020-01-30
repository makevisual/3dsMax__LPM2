struct SMTDIdiotCheck
(
	-- Ensures there is a camera in your scene
	function noCamerasChk =
	(
		if cameras.count != 0 then()else
		(
			return #("fail", 1, #( "No cameras in your scene!" ) )
		)
		return #("pass")
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

		for i in 1 to cameras.count do
		(
			try(
				if cameras[i].mpassEnabled == true then
				(
					result = ( "\" " + (cameras[i].name) + " \"  has multipass enabled! ")
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

		for i in 1 to objects.count do
		(
			obj = objects[i]
			try(
				if obj.BackBurnerSim == true then
				(
					result = ( "\" " + (objects[i].name) + " \"  is in backburner mode! ") 1
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
	)
)