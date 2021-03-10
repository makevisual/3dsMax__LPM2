-- Sets the rendderer specific outputs for Vray5 and disables the max save file
-- Included the depreciated function for any possible future use

struct Vray5_RestoreDataStr
(
    -- Renderer specific globals 
    output_on               = undefined,
    output_rawFileName      = undefined,
    output_saveRawFile      = undefined,
    output_splitgbuffer     = undefined,
    output_genpreview       = undefined,
    rendShowVFB             = undefined,
    rendSaveFile            = undefined,

    -- Vray5 Render Element Override 
    vrayVFBElementStates    = undefined,

    -- Vray5 Render Override 
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

function vray5_Globals_Override_PreRender =
(
    -- Fetch the global variable and assign the current state to it
    Vray5_RestoreData = LPM_RenderDispatchRestoreData

    Vray5_RestoreData.output_on           = renderers.current.output_on             
    Vray5_RestoreData.output_rawFileName  = renderers.current.output_rawFileName    
    Vray5_RestoreData.output_saveRawFile  = renderers.current.output_saveRawFile    
    Vray5_RestoreData.output_splitgbuffer = renderers.current.output_splitgbuffer   
    Vray5_RestoreData.output_genpreview   = renderers.current.output_genpreview     
    Vray5_RestoreData.rendShowVFB         = rendShowVFB                             
    Vray5_RestoreData.rendSaveFile        = rendSaveFile                            

    -- Fetch, parse and make the output directory
    thePath=getFilenamePath rendOutputFilename
    theFile=getFilenameFile rendOutputFilename
    theType=getFilenameType rendOutputFilename
    
    makeDir thePath
    
    -- Set the properties to their desired values
    renderers.current.output_on             = true                           -- force vray frame buffer on
    renderers.current.output_rawFileName    = (thePath + theFile + ".exr")   -- ( previously rendOutputFilename ) steal the name from the 3dsmax render output filename global ( set in render.ms )
    renderers.current.output_saveRawFile    = true                           -- enable saving the file
    renderers.current.output_splitgbuffer   = true                           -- enable render elements to be stored in the output ??????
    renderers.current.output_genpreview     = true                           -- Not sure if this needs to be on or not
    rendShowVFB                             = false                          -- Turn off max default frame buffer
    rendSaveFile                            = false                          -- Turn off max default file save option 
)

function vray5_Globals_Override_PostRender =
(
    -- Get the restore data from global variable
    Vray5_RestoreData = LPM_RenderDispatchRestoreData 

    -- Restore the previous data          
    renderers.current.output_rawFileName    = Vray5_RestoreData.output_rawFileName    
    renderers.current.output_saveRawFile    = Vray5_RestoreData.output_saveRawFile    
    renderers.current.output_splitgbuffer   = Vray5_RestoreData.output_splitgbuffer   
    renderers.current.output_genpreview     = Vray5_RestoreData.output_genpreview     
    rendShowVFB                             = Vray5_RestoreData.rendShowVFB           
    rendSaveFile                            = Vray5_RestoreData.rendSaveFile     
)

function vray5_RE_Override_PreRender =
(
    print "= Vray5 vray5_RE_Override_PreRender ="

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
            curEnabled = false 
    
            curElement = ( re.GetRenderElement i )
            elementObj = elementObjStr()
    
            elementObj.animhandle       = gethandlebyanim curElement
            elementObj.name             = curElement.elementName
            elementObj.enabled          = curElement.vrayVFB 
    
            append existingElements elementObj
        )catch()
    )

    -- Store the collected data for later restoration
    LPM_RenderDispatchRestoreData.vrayVFBElementStates = existingElements

    -- TODO: ACTUALLY MAKE THE CHANGES BASED OFF OF CA

    -- read this guy to get the pass and apply all the stuff from it
    -- LPM_RenderDispatchThePass
                -- theDeadlineProps=for it in thePass.children where ((it.type=="Deadline") and (it.active)) collect it
                -- if(theDeadlineProps[1] != undefined) then
                -- (
                --     print thePass
                --     LPM_Fun.loadDeadlineSettings theDeadlineProps[1] isPreviewMode
                -- )
)

function vray5_RE_Override_PostRender =
(
    print "= Vray5 vray5_RE_Override_PostRender ="

    -- Get the elements stored earlier and restore them 
    curElements = LPM_RenderDispatchRestoreData.vrayVFBElementStates

    for curElement in curElements do
    (
        curNode = getAnimByHandle curElement.animhandle 
        curNode.vrayVFB = curElement.enabled
    )
)

function vray5_Override_PreRender =
(
)

function vray5_Override_PostRender =
(
)


function curPrerenderAction =
(
    print "== Vray5 PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray5_RestoreDataStr()

    -- call each of the prerender functions
    vray5_Globals_Override_PreRender()
    
    -- TODO: Add tests to see if there is an enabled operator in the stack for each of these
    vray5_RE_Override_PreRender()
    vray5_Override_PreRender()
)

function curPostRenderAction =
(
    print "== Vray5 PostRenderAction =="
    
    -- call each of the postrender functions
    vray5_Globals_Override_PostRender()

    -- TODO: Add tests to see if there is an enabled operator in the stack for each of these
    vray5_RE_Override_PostRender()
    vray5_Override_PostRender()
)

if LPM_RenderDispatchAction == #preRender then curPrerenderAction()
if LPM_RenderDispatchAction == #postRender then curPostRenderAction()