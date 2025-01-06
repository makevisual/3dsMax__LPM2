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

    -- function for applying metadata to all optionRE render elements in the scene
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

    -- Prep the metadata string
    MAKE3dsMaxMetadata_maxFileName          = ( maxFileName as string )
    MAKE3dsMaxMetadata_maxFilePath          = ( maxFilePath as string )
    MAKE3dsMaxMetadata_localTime            = ( localTime as string )
    MAKE3dsMaxMetadata_fileOutGamma         = ( fileOutGamma as string )
    MAKE3dsMaxMetadata_rendOutputFilename   = ( rendOutputFilename as string )
    MAKE3dsMaxMetadata_submitUsername       = ( sysInfo.username as string )
    MAKE3dsMaxMetadata_submitComputername   = ( sysInfo.computername as string )
    newStr = ( "MAKE3dsMaxMetadata_maxFileName = " + MAKE3dsMaxMetadata_maxFileName + "; MAKE3dsMaxMetadata_maxFilePath = " + MAKE3dsMaxMetadata_localTime + "; MAKE3dsMaxMetadata_fileOutGamma = " + MAKE3dsMaxMetadata_fileOutGamma + "; MAKE3dsMaxMetadata_rendOutputFilename = " + MAKE3dsMaxMetadata_rendOutputFilename + "; MAKE3dsMaxMetadata_submitUsername = " + MAKE3dsMaxMetadata_submitUsername + "; MAKE3dsMaxMetadata_submitComputername = " + MAKE3dsMaxMetadata_submitComputername )

    -- apply the metadata string to all option RE render elements
    applyExrMetadataToAllOptionRes newStr