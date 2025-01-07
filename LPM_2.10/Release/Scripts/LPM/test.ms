    clearListener()

    -- function for getting render element by name
--    function getRenderElementByName arg_name = (
--
--        -- Get the render element manager
--        re                  = maxOps.GetCurRenderElementMgr()   
--        existingElements    = #()
--
--        -- loop through the elemnts looking for the right one
--        for i in 0 to ( re.NumRenderElements() - 1 ) do         
--        (
--            curElement                  = ( re.GetRenderElement i )
--
--            -- return the element if its name matches the arg_name
--            if curElement.elementName   == arg_name then( return curElement )
--        )
--    )

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
    
    -- apply the metadata string to all option RE render elements
    applyExrMetadataToAllOptionRes newStr