-- RELEASE MODE --
--global LPM_Dir = @"U:/Make_Tools/LPM2/LPM_2.6.4/Release/Scripts/LPM/"
-- DEBUG/DEVELOP MODE --
 LPM_Dir = trimright (getThisScriptFilename()) "Include.ms"
-- getFilenamePath( getThisScriptFilename() )

filein (LPM_Dir+"Globals.ms")
filein (LPM_Dir+"VersionNumber.ms")
filein (LPM_Dir+"include.mcr")
filein (LPM_Dir+"CA.ms")
filein (LPM_Dir+"AltSpaceCheck.ms")
filein (LPM_Dir+"functions.ms")
filein (LPM_Dir+"render.ms")
filein (LPM_Dir+"rcMenus.ms")
filein (LPM_Dir+"LPM_SMTDSettings.ms") -- Dabelow
--filein (LPM_Dir+"makeRenderElements.ms")
filein (LPM_Dir+"treeView.ms")
LPM_PluginFiles=getfiles(LPM_Dir+"plugins/*")
for f in LPM_PluginFiles do filein f
filein (LPM_Dir+"operatorsAPI.ms")
filein (LPM_Dir+"MAKE_nukeem.ms")
--Load network submission plugins



--Load network submission plugins


--Set Fileoutput Path Token String to default
LPM_Fun.SetIni "LPM Render" "Path"  "$Shot\\$APass$Pass\\$APass$Pass"