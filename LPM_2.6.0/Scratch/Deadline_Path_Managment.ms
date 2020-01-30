
fn checkBitmaps =
(

	--ATSOps.Visible = true

	pFDArray = #()

	pFDArray = (for o in geometry where classOf o == FireSmokeSim or classOf o == LiquidSim  collect o)

	ATSOps.CheckNetworkPaths = true -- Turns on status checking for network filepaths 

	atsops.Refresh() -- Updates Asset Tracker

	ATSOps.GetFilesByFileSystemStatus #Missing &nullList -- Builds list of assets with "Missing" Status in Asset Tracker

	if nullList.count > 0 do
	(	

		mList = #()
	
		for i = 1 to nullList.count do
		(
			append mList #(pathConfig.stripPathToLeaf nullList[i], nullList[i]) -- Builds sub array and appends to output array
		)
	)
	
	for i = 1 to pFDArray.count do
		(
	
			if pFDArray[i].rendinput != "$(same_as_output)" then
			(
	
				tempFCheck = 979
				existFlag = false
	
				for x = 0 to 20 do
				(
	
					tempPath = trimRight pFDArray[i].rendinput ".aur#1234567890"
	
					tempPath = tempPath + tempFCheck as string + ".aur"
	
					print tempPath
	
					existFlag = doesFileExist tempPath
	
					print existFlag
	
					if existFlag == True then
					(
						exit
					)
	
					tempFCheck = tempFCheck + 7
					x = x + 1
	
				)
	
				if existFlag == False then
				(
					append mList #(pFDArray[i].name, pFDArray[i].rendinput)
	
				)
				
			)
	
		)



	return(mList)
)

fn removeAssetsLinks = 
(
	actionMan.executeAction -841213575 "23"  -- Asset Tracking System: Remove Missing Assets
)

clearlistener()
checkBitmaps()


--removeAssetsLinks()


