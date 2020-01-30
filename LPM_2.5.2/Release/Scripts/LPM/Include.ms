-- RELEASE MODE --
LPM_Dir = @"U:/Make_Tools/LPM2/LPM_2.5.2/Release/Scripts/LPM/"
-- DEBUG/DEVELOP MODE --
-- LPM_Dir = @"U:/3dsMax2017/3dsmax2017_x64_plugins/LPM2/LPM_2.5.1/Release/Scripts/LPM/"

filein (LPM_Dir+"Globals.ms")
filein (LPM_Dir+"VersionNumber.ms")
filein (LPM_Dir+"include.mcr")
filein (LPM_Dir+"CA.ms")
filein (LPM_Dir+"AltSpaceCheck.ms")
filein (LPM_Dir+"functions.ms")
filein (LPM_Dir+"render.ms")
filein (LPM_Dir+"rcMenus.ms")
filein (LPM_Dir+"LPM_SMTDSettings.ms") -- Dabelow
filein (LPM_Dir+"treeView.ms")
LPM_PluginFiles=getfiles(LPM_Dir+"plugins/*")
for f in LPM_PluginFiles do filein f
filein (LPM_Dir+"operatorsAPI.ms")
--Load network submission plugins