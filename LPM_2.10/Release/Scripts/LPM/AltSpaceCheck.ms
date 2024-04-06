
	/* 
	
	
	
	Created by grover_gol ( http://gg3dcg.ru/ ) for Altspace  ( http://altspace.com/ )  2015
	
	
	
	 */
	 /* 
	 
	 
	 
	 
	 This is internal Altspace function. So in public version it's empty. But you can create your own checks.
	 
	 
	 
	 
	  */
	 
	 
	 

fn CheckProjRenderPath =
(

	errorText = "Altspace check OFF"
	NoErrorsFlag = true
	
	
	#(NoErrorsFlag,errorText)
)


fn getProjRenderPath =
(
	
	FinalOutPath = LPM_Root.rootDir
	
	FinalOutPath
)


fn RenderElementsUpdatePaths =
		(
			try
			(
				outputFilename = rendOutputFilename
				-- only update RE paths if the output filename isn't empty
				if (outputFilename != undefined and outputFilename != "") then
				(
					local reManager = maxOps.GetCurRenderElementMgr()
					if reManager.GetElementsActive() then 
					(
						local reCount = reManager.NumRenderElements()
						for i = 0 to reCount - 1 do
						(
							local reFilename = reManager.GetRenderElementFilename i
							local theElement = reManager.GetRenderElement i
							local theElementFolder = theElement.elementName 
							theElementFolder += "_" +  (classof theElement) as string 
							
							local newPath = (getFileNamePath outputFilename + theElementFolder) 
							
							if true then
							(
								local theNewFileName = (newPath +"\\" + getFileNameFile outputFilename + "_" + ((classof theElement) as string) + getFileNameType reFilename)
								reManager.SetRenderElementFilename i theNewFileName
							)
							else
							(
								local theNewFileName = if reFilename != undefined and reFilename != "" then
									(newPath +"\\" + getFileNameFile reFilename + getFileNameType reFilename)
								else
									 (newPath +"\\" + theElementFolder + getFileNameType outputFilename)
								reManager.SetRenderElementFilename i theNewFileName
							)
						)
					)
				)
			)
			catch
			(
				--print "Render Elements Update Paths Error."
			)
			
		)

