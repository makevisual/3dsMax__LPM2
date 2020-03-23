fn vInProjectPath = 
(

	curFile = pathConfig.convertPathToUnc maxFilePath -- From Asset Switch - Finds Project Directory and Converts to UNC path
	curFileParts = (filterString curFile @"\")
	str = ""

	-- Get the project folder
	for i in 1 to curFileParts.count do
	(
		if curFileParts[i] == "Projects" or curFileParts[i] == "Pitches"
		then
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
			
			if pathConfig.pathsResolveEquivalent checkTemp str == true do -- Checks if path is a match with project directory
			(
				inPathFlag = true
			) 

			if timeout == 100 do -- exits while loop in event the trim function encounters an unknown character
			(
				checkTemp = ""
				print "ERROR: Unkown character in path string or file path too long"
			)

			timeout = timeout + 1 -- timeout tick up
		)


		if inPathFlag == False do -- Adds files that are not in the directory to the output list
		(
			append outList #(pathConfig.stripPathToLeaf pList[i], pList[i])

		)

	)

	return (outList)
)

clearListener()

vInProjectPath()
