-- Sets the rendderer specific outputs for Vray7 and disables the max save file
-- Included the depreciated function for any possible future use
-- 04/24/2025 Aaron Dabelow theonlyaaron@gmail.com


---------- CLASSES ----------

-- Object to hold all the restore data
struct scanline_RestoreDataStr
(
    matEditor_open          = undefined,
    fullFileOutputPath 		= undefined,
    saveFileOption  		= undefined,
    caboose                 = undefined
)


---------- GLOBAL SWITCHES ----------

---- Prerender Globals
-- When rendering Production, these settings are applied
function preRenderAction_ProductionGlobals =
(
    -- Fetch the global variable and assign the current state to it
    scanline_RestoreData                      	= LPM_RenderDispatchRestoreData

    scanline_RestoreData.matEditor_open       	= MatEditor.isOpen() 
    scanline_RestoreData.fullFileOutputPath 	= rendOutputFilename	
    scanline_RestoreData.saveFileOption  		= rendSaveFile 	

    -- Fetch, parse and make the output directory
    thePath=getFilenamePath rendOutputFilename
    theFile=getFilenameFile rendOutputFilename
    theType=getFilenameType rendOutputFilename

    -- Makes the output directory
    makeDir thePath

    -- Set the properties to their desired values
    rendSaveFile          	= true                
    --print( "-- rendOutputFilename -- " + rendOutputFilename   )
)

---- Postrender Globals
-- When rendering Production, these settings will be restored
function postRenderAction_ProductionGlobals =
(
    -- Get the restore data from global variable
    scanline_RestoreData = LPM_RenderDispatchRestoreData

    -- Restore the previous data
    if scanline_RestoreData.matEditor_open then (MatEditor.Open())
    rendOutputFilename 	= scanline_RestoreData.fullFileOutputPath
    rendSaveFile 		= scanline_RestoreData.saveFileOption 
)


---------- PROGRAM FLOW ---------- 

---- Pre-Render Action for Production
function preRenderAction_Production =
(
    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = scanline_RestoreDataStr()

    -- call each of the prerender functions
    preRenderAction_ProductionGlobals()             -- For all global actions
)

---- Pre-Render Action for Preview
function preRenderAction_Preview =
(
    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = scanline_RestoreDataStr()
)

---- Post-Render Action for Production
function postRenderAction_Production =
(
    --Calls Data from the global to check the restorepoint flag
    scanline_RestoreData = LPM_RenderDispatchRestoreData

    postRenderAction_ProductionGlobals()
)

function localRenderAction =
(
    clearListener()

    print( "-- rendOutputFilename -- " + rendOutputFilename   )

    theShot = LPM_RenderDispatchTheShot

    SetQuietMode LPM_Root.quietMode
    cp=LPM_Fun.firstChildByType theShot "commonProps"

    -- TODO: Add extra "." to the filename before the index when finishing up this part

--    setting_outputfile  = @"U:\users\AD\Software_Testing\3dsMax2024\VRay_7.00.04\LPM2_VRay7\Scenes\Layout\Shot_v005\Beauty\Beauty.exr"
    
    

    setting_outputfile  = LPM_Root.fullOutputPath
    setting_camera      = cp._camera -- Will need some handling around scenes with no camera eventually.
    setting_frameBuffer = true 

    print("setting_outputfile  - " + (setting_outputfile ) as string )
    print("setting_camera      - " + (setting_camera     ) as string )
    print("setting_frameBuffer - " + (setting_frameBuffer) as string )


    if cp._rendTimeType == 1 then
    (
        -- print("Single")
        render fromframe:currentTime toframe:currentTime outputfile:setting_outputfile vfb:setting_frameBuffer camera:setting_camera
    )

    if cp._rendTimeType == 2 then
    (
        -- print("Active Timeline")
        render fromframe:animationRange.start toframe:animationRange.end outputfile:setting_outputfile vfb:setting_frameBuffer camera:setting_camera
    )
    
    if cp._rendTimeType == 3 then
    (
        -- print("Range")
        render fromframe:( cp._rendStart) toframe:( cp._rendEnd ) outputfile:setting_outputfile vfb:setting_frameBuffer camera:setting_camera
    )
    
    if cp._rendTimeType == 4 then
    (
        -- print("Frame List")

        frames = #()
        parts = filterString cp._rendPickupFrames "," -- split on commas
        
        for part in parts do
        (
            if findString part "-" != undefined then
            (
                rangeParts = filterString part "-"
                if rangeParts.count == 2 then
                (
                    startVal    = rangeParts[1] as integer
                    endVal      = rangeParts[2] as integer
                    for i       = startVal to endVal do append frames i
                )
            )
            else ( append frames (part as integer) )
        )
        
        -- Render each of the frames from the built list
        for frame in frames do ( render fromframe:(frame) toframe:(frame) outputfile:setting_outputfile vfb:setting_frameBuffer camera:setting_camera )
    )

    -- print(cp._rendTimeType)
    -- print(cp._rendStart)
    -- print(cp._rendEnd)
    -- print(cp._rendPickupFrames)
)

---------- API HOOKS ---------- 

-- Cases for each of the methods a dispatch can be called.
if LPM_RenderDispatchAction == #preRender then preRenderAction_Production()
if LPM_RenderDispatchAction == #PreviewRender then  preRenderAction_Preview()
if LPM_RenderDispatchAction == #LocalRender     then localRenderAction()
if LPM_RenderDispatchAction == #postRender then postRenderAction_Production()