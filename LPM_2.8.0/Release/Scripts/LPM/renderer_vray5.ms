-- Sets the rendderer specific outputs for Vray5 and disables the max save file
-- Included the depreciated function for any possible future use


thePath=getFilenamePath rendOutputFilename
theFile=getFilenameFile rendOutputFilename
theType=getFilenameType rendOutputFilename

makeDir thePath

renderers.current.output_on             = true                 -- force vray frame buffer on
--renderers.current.output_rawFileName    = rendOutputFilename   -- steal the name from the 3dsmax render output filename global ( set in render.ms )
renderers.current.output_rawFileName    = (thePath + theFile + ".exr")   -- steal the name from the 3dsmax render output filename global ( set in render.ms )
renderers.current.output_saveRawFile    = true                 -- enable saving the file
renderers.current.output_splitgbuffer   = true                 -- enable render elements to be stored in the output ??????
renderers.current.output_genpreview     = true
rendSaveFile = false


fn setVray filePath thePass=
(
        if(classof renderers.current==vray) then
        (
            if thePass.VRayRaw then
            (
                renderers.current.output_on = true
                renderers.current.output_saveRawFile = true
                renderers.current.output_rawExrUseHalf = not (thePass.VRayRawFull)
                try
                (
                    renderers.current.output_rawExrDeep = thePass.VRayRawDeep
                )
                catch
                (
                )
            )



            if(renderers.current.output_on) then
            (
                thePath=getFilenamePath filePath
                theFile=getFilenameFile filePath
                theType=getFilenameType filePath




                if(renderers.current.output_splitgbuffer) then
                (
                    makeDir thePath
                    --ADD CONDITIONALS CHECK FOR VRMIMG USE AND SPLIT USE< GENERATE WARNING IF VFB BUT NEITHER
                    x=bitmap 10 10 filename:(thePath+thefile+"TMP"+theType)
                    save x
                    renderers.current.output_splitfilename=filePath
                    renderers.current.output_splitbitmap=x
                    deletefile (thePath+thefile+"TMP"+theType)
                )

                if(renderers.current.output_saveRawFile) then
                (
                    if thePass.VRayRaw then
                    (
                        renderers.current.output_rawFileName=thePath+theFile--+".vrImg"
                        renderers.current.output_rawFileName += case thePass.VRayRawFileType of
                        (
                            1:
                            (
                                ".vrimg"
                            )
                            2:
                            (
                                ".exr"
                            )
                            3:
                            (
                                ".vrst"
                            )
                            4:
                            (
                                ".vrsm"
                            )
                        )

                        if (thePass.VRayRawFileType == 1) and (thePass.PostConvert) then
                        (
                            LPM_Root.PostConvertVrimg2exr = LPM_Fun.getIni "Settings" "PostConvertVrimg2exr" string "C:\\Program Files\\Chaos Group\\V-Ray\\3dsmax 2014 for x64\\tools\\vrimg2exr.exe"

                            LPM_Root.PostConvert = thePass.PostConvert
                            LPM_Root.PostConvertCompression = thePass.PostConvertCompression
                            LPM_Root.PostConvertHalfFoat = thePass.PostConvertHalfFoat
                            LPM_Root.PostConvertDatawindow = thePass.PostConvertDatawindow

                        )
                    )
                    else
                    (
                        renderers.current.output_rawFileName=thePath+theFile + ".vrimg"
                    )



                )

                if(not renderers.current.output_saveRawFile) and (not renderers.current.output_splitgbuffer) then
                (
                    try
                    (
                        LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
                        LPM_renderProgress_Ro.warning.color=color 135 6 6
                    )
                    catch
                    (
                    )
                    print "Warning: Vray is set to use VFB, but neither Raw Image or Split Render Channels are active, render data may be lost."
                )
            )
        )
)
