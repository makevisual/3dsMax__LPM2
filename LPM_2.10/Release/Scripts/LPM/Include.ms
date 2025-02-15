-- All of the libraries needed for LPM to run, and then call the main thread

global LPM_Dir = trimright (getThisScriptFilename()) "Include.ms"

filein (LPM_Dir+"Globals.ms")
filein (LPM_Dir+"VersionNumber.ms") 	-- Added by Aaron Dabelow
filein (LPM_Dir+"include.mcr")
filein (LPM_Dir+"CA.ms")
filein (LPM_Dir+"functions.ms")
filein (LPM_Dir+"render.ms")
filein (LPM_Dir+"rcMenus.ms")
filein (LPM_Dir+"LPM_SMTDSettings.ms") 	-- Added by Aaron Dabelow
filein (LPM_Dir+"NukeAPI.ms") 			-- Added by Aaron Dabelow
filein (LPM_Dir+"treeView.ms")
filein (LPM_Dir+"operatorsAPI.ms")
filein (LPM_Dir+"MAKE_nukeem.ms") 		-- Added by Aaron Dabelow
filein (LPM_Dir+"OperatorData.ms") 		-- Added by Aaron Dabelow

LPM_Fun.SetIni "LPM Render" "Path"  "$Shot\\$APass$Pass\\$APass$Pass" 		--Set Fileoutput Path Token String to default
LPM_Root.renderType = 3 													-- Force to shots

print ("LPM Version - " + ( LPM_VersionNumber as string ) )		