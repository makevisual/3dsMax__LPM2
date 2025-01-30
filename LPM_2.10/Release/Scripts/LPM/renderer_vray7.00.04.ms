-- Sets the rendderer specific outputs for Vray7 and disables the max save file
-- Included the depreciated function for any possible future use
-- 11/05/2024 Aaron Dabelow theonlyaaron@gmail.com

---------- CLASSES ----------
-- Object to hold all the restore data

struct Vray7_RestoreDataStr
(
    -- Scene specific properties
    matEditor_open          = undefined,

    -- Renderer specific globals
    output_on               = undefined,
    output_rawFileName      = undefined,
    output_saveRawFile      = undefined,
    output_splitgbuffer     = undefined,
    output_genpreview       = undefined,
    rendShowVFB             = undefined,
    rendSaveFile            = undefined,
    output_useram           = undefined,
    rendUseActiveView       = undefined,
    regionDimensions        = undefined,

    -- Vray7 Render Element Override
    vrayVFBElementStates    = undefined,

    -- Vray7 Render Elements Active
    renderElements_active   = undefined,

    -- Vray7 Render Override
    qualityType             = undefined,
    global_switches_check   = undefined,
    displacement            = undefined,
    reflrefr                = undefined,
    anti_aliasing_check     = undefined,
    aaMin                   = undefined,
    aaMax                   = undefined,
    GI_illum_check          = undefined,
    giOn                    = undefined,
    GI_check                = undefined,
    giSkylightOn            = undefined,
    giSkylightMap           = undefined,
    giSkylightCol           = undefined,
    giSkylightMult          = undefined,
    giSkylightMapCheck      = undefined,
    giRefOn                 = undefined,
    giRefCol                = undefined,
    giRefMap                = undefined,
    giRefMult               = undefined,
    giRefMapCheck           = undefined,
    moblur_check            = undefined,
    moblurOn                = undefined,
    moblurSubdivs           = undefined,
    prog_check              = undefined,
    progMaxSubdiv           = undefined,
    progTime                = undefined,
    dmc_check               = undefined,
    dmcThresh               = undefined,
    dmcMult                 = undefined
)

---------- GLOBAL SWITCHES ----------
---------- Prerender Global

-- For  using vray 7, do these actions
function Vray7_Globals_Override_PreRender =
(
    -- Disable the interactive renderer if it is running.
    vrayStopIPR()

    -- Fetch the global variable and assign the current state to it
    Vray7_RestoreData                      = LPM_RenderDispatchRestoreData
    Vray7_RestoreData.output_on            = renderers.current.output_on

    -- stores the vray vfb output path, if one is not set, then and empty string is stored instead
    if renderers.current.output_rawFileName == undefined
    then ( Vray7_RestoreData.output_rawFileName  = "" )
    else ( Vray7_RestoreData.output_rawFileName  = renderers.current.output_rawFileName )

    -- stores various other output and frame buffer settings
    Vray7_RestoreData.output_saveRawFile        = renderers.current.output_saveRawFile
    Vray7_RestoreData.output_splitgbuffer       = renderers.current.output_splitgbuffer
    Vray7_RestoreData.output_genpreview         = renderers.current.output_genpreview
    Vray7_RestoreData.output_useram             = renderers.current.output_useram
    Vray7_RestoreData.rendShowVFB               = rendShowVFB
    Vray7_RestoreData.rendSaveFile              = rendSaveFile
    Vray7_RestoreData.rendUseActiveView         = rendUseActiveView
    Vray7_RestoreData.regionDimensions          = (vfbControl #getregion )

    -- Active render elements empty for now, they are populated in the render elements prerender function
    Vray7_RestoreData.renderElements_active     = #() -- active render elements

    -- Scene properties 
    Vray7_RestoreData.matEditor_open    = MatEditor.isOpen() 

    -- Fetch, parse and make the output directory
    thePath=getFilenamePath rendOutputFilename
    theFile=getFilenameFile rendOutputFilename
    theType=getFilenameType rendOutputFilename

    -- Makes the output directory
    makeDir thePath

    -- Set the properties to their desired values
    renderers.current.output_on             = true                           -- force vray frame buffer on
    renderers.current.output_rawFileName    = (thePath + theFile + ".exr")   -- ( previously rendOutputFilename ) steal the name from the 3dsmax render output filename global ( set in render.ms )
    renderers.current.output_saveRawFile    = true                           -- enable saving the file
    renderers.current.output_splitgbuffer   = true                           -- enable render elements to be stored in the output ??????
    renderers.current.output_genpreview     = true                           -- Not sure if this needs to be on or not
    rendShowVFB                             = false                          -- Turn off max default frame buffer
    rendSaveFile                            = false                          -- Turn off max default file save option
    rendUseActiveView                       = true                           -- Disables the lock on the camera view, this causes bugs on network renders knowing which camera to use
    vfbControl #setregion 0 0 0 0                                            -- Sets the region render to zero pixels, effectivly disabling the render region function
    MatEditor.Close()                                                        -- Close the material editor ( faster operation )
    vfbControl #setregion "reset"                                            -- Turns off any region renders, before submitting

    -- If the renderer is set to progressive, it turns the memory frame buffer on, which is necessary for it to work
    -- otherwise it turns the memory frame buffer off, which is the preferred method, for memory handling, and performance
    -- however, note that the frame buffer will not be interactive in this mode, and will only clone a small window for the viewer
    if renderers.current.imageSampler_type == 3
    then( renderers.current.output_useram = true )
    else( renderers.current.output_useram = false )

    ---- Auto assign the correct deadline limit if deadline has been initialized ----
    if SMTDSettings.LimitGroupsToUse != undefined 
    then(
        append SMTDSettings.LimitGroupsToUse "v-ray 7"                                  -- adds "v-ray 7" to the list of limits
        SMTDSettings.LimitGroupsToUse = (makeUniqueArray SMTDSettings.LimitGroupsToUse) -- Removes any duplicates from the list
    )else()

    -- print("SHOW Vray7_RestoreData")
    -- show(Vray7_RestoreData)
)

---------- Postrender Global
function Vray7_Globals_Override_PostRender =
(
    -- Get the restore data from global variable
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    -- Restore the previous data
    renderers.current.output_rawFileName    = Vray7_RestoreData.output_rawFileName
    renderers.current.output_saveRawFile    = Vray7_RestoreData.output_saveRawFile
    renderers.current.output_splitgbuffer   = Vray7_RestoreData.output_splitgbuffer
    renderers.current.output_genpreview     = Vray7_RestoreData.output_genpreview
    renderers.current.output_useram         = Vray7_RestoreData.output_useram
    rendShowVFB                             = Vray7_RestoreData.rendShowVFB
    rendSaveFile                            = Vray7_RestoreData.rendSaveFile
    rendUseActiveView                       = Vray7_RestoreData.rendUseActiveView
    vfbControl #setregion Vray7_RestoreData.regionDimensions[1][1] Vray7_RestoreData.regionDimensions[1][2] Vray7_RestoreData.regionDimensions[1][3] Vray7_RestoreData.regionDimensions[1][4]

    -- Open the material editor if it was open
    if Vray7_RestoreData.matEditor_open then (MatEditor.Open())
)

---------- RENDER ELEMENTS OPERATOR ----------
---------- Prerender Render Elements

function Vray7_RE_Override_PreRender =
(
    print "= Vray7 Vray7_RE_Override_PreRender ="

    -- localize this variable
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    -- print("LPM_RenderDispatchThePass")
    -- print("     " + ( LPM_RenderDispatchThePass ) as string )

    -- print("The Render Elements Node")
    -- vray6RenderElementsNode = LPM_Fun.firstChildByType LPM_RenderDispatchThePass "vray6RenderElements"
    -- print("     " + ( vray6RenderElementsNode ) as string )
    -- print("     " + ( vray6RenderElementsNode.activeElement ) as string )







    -- object for holding render element states
    struct elementObjStr
    (
        animhandle = undefined,
        name = "",
        enabled = false
    )

    -- Get the render element manager
    re                  = maxOps.GetCurRenderElementMgr()
    existingElements    = #()

    -- Get the current render elements
    for i in 0 to ( re.NumRenderElements() - 1 ) do
    (
        -- Try Catch added for non v-ray supported render elements, or vrayAlpha render element
        try(
            curElement = ( re.GetRenderElement i )
            elementObj = elementObjStr()

            elementObj.animhandle       = gethandlebyanim curElement
            elementObj.name             = curElement.elementName
            elementObj.enabled          = curElement.vrayVFB

            append existingElements elementObj
        )catch()
    )

    print("EXISTING ELEMENTS")
    print("     "+ existingElements as string)




    -- TODO: Why is this object not accessible?
    -- Store the existing elements and their enable state toe be turned back on later

    print("is Vray7_RestoreData available here?")
    print(Vray7_RestoreData as string)




    -- TODO: Turn These on
    -- vray6RenderElementsNode.activeElement





    -- Store the collected data for later restoration
    LPM_RenderDispatchRestoreData.vrayVFBElementStates = existingElements

    -- get the active pass from the global variable
    thePass = LPM_RenderDispatchThePass

-- TODO:
    -- Elements are beiing stored, but not being applied, keep looking around here


    -- Collect the operators that are "Vray7RenderElements", get their "activeElementList" and enable them
    theVray7RenderElements =for it in thePass.children where ((it.type=="Vray7RenderElements") and (it.active)) collect it
    for theVray7RenderElement in theVray7RenderElements do
    (
        -- get the custom attribute from the current operator ( active elements as string array )
        ca = custAttributes.get theVray7RenderElement 1
        activeElements = ca.activeElement

        -- loop through all of the render elements
        for i in 0 to ( re.NumRenderElements() - 1 ) do
        (
            -- try -- Try Catch for elements that do not have a .vrayVFB property, like vryaAlpha, that cannot render int the frame buffer
            (
                print (curElement)
                -- turn the render element off
                curElement = ( re.GetRenderElement i )
                curElement.vrayVFB = false

                -- turn on the ones that matche the activeElement name
                for activeElement in activeElements do
                (
                    if curElement.elementName == activeElement then (curElement.vrayVFB = true)
                )
            )
            -- catch()
        )
    )
)

---------- Postrender Render Elements
function Vray7_RE_Override_PostRender =
(
    -- print "= Vray7 Vray7_RE_Override_PostRender ="

    -- Get the elements stored earlier and restore them
    curElements = LPM_RenderDispatchRestoreData.vrayVFBElementStates

    for curElement in curElements do
    (
        curNode = getAnimByHandle curElement.animhandle
        curNode.vrayVFB = curElement.enabled
    )
)


---------- UTILITIES ----------
-- Add additional metadata to the .exr files through the option RE render element for vray
function Vray7_OptionRE_CustomMetadata = 
(
    function applyExrMetadataToAllOptionRes arg_string = (

        -- Get the render element manager
        re                  = maxOps.GetCurRenderElementMgr()   
        existingElements    = #()

        -- loop through the elemnts looking for the right one
        for i in 0 to ( re.NumRenderElements() - 1 ) do         
        (
            curElement                  = ( re.GetRenderElement i )

            -- return the element if its name matches the arg_name
            --if curElement.elementName   == arg_name then( return curElement )
            if (classof curElement) == VRayOptionRE 
            then 
            (
                curElement.exr_metadata = arg_string
            )
        )
    )

    newStr = ""

    try( newStr += ( "MAKE3dsMaxMetadata_maxFileName = "                     + ( maxFileName as string ) )                                      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_maxFilePath = "                   + ( maxFilePath as string ) )                                      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_localTime = "                     + ( localTime as string ) )                                        )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_fileOutGamma = "                  + ( fileOutGamma as string ) )                                     )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendOutputFilename = "            + ( rendOutputFilename as string ) )                               )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_submitUsername = "                + ( sysInfo.username as string ) )                                 )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_submitComputername = "            + ( sysInfo.computername as string ) )                             )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendApertureWidth = "             + ( getRendApertureWidth() as string ) )                           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendImageAspect = "               + ( getRendImageAspect() as string ) )                             )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraFocalLenthMM = "            + ( LPM_Root.renderCamera.focal_length_mm as string ) )            )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraShutterLenthFrames = "      + ( LPM_Root.renderCamera.shutter_length_frames as string ) )      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraShutterOffsetFrames = "     + ( LPM_Root.renderCamera.shutter_offset_frames as string ) )      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_imageSampler_shadingRate = "+ ( renderers.current.imageSampler_shadingRate as string ) )       )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_baseSubdivs = "    + ( renderers.current.twoLevel_baseSubdivs as string ) )           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_fineSubdivs = "    + ( renderers.current.twoLevel_fineSubdivs as string ) )           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_threshold = "      + ( renderers.current.twoLevel_threshold as string ) )             )catch()

    -- apply the metadata string to all option RE render elements
    applyExrMetadataToAllOptionRes newStr
)

-- Call all the prerender actions
function curPrerenderAction =
(
    print "== Vray7 PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray7_RestoreDataStr()

    -- call each of the prerender functions
    Vray7_Globals_Override_PreRender()  -- For all global actions
    Vray7_RE_Override_PreRender()       -- For all Render Elements Operator
    Vray7_OptionRE_CustomMetadata       -- Add additional metadata to the .exr files through the option RE render element for vray
)

-- Call all the post render actions
function curPostRenderAction =
(
    print "== Vray7 PostRenderAction =="

    --Calls Data from the global to check the restorepoint flag
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    --Only runs the Post render action if Settings were altered in the prerender based on the restorepoint flag
    if LPM_RenderDispatchAction != #PreviewRender then
    (
        try( Vray7_Globals_Override_PostRender() )catch() -- TODO: remove later????
        try( Vray7_Override_PostRender() )catch() -- TODO: remove later????
    )

     Vray7_RE_Override_PostRender()
    -- call each of the postrender functions
)


---------- PROGRAM FLOW ---------- 
-- These are the 3 Different ways that override can becalled, and it sends the correct function.
if LPM_RenderDispatchAction == #preRender then curPrerenderAction()
if LPM_RenderDispatchAction == #PreviewRender then curPrerenderAction()
if LPM_RenderDispatchAction == #postRender then curPostRenderAction()

-- print " Vray 5.1.3 sucsusfully called from RenderDispatch "