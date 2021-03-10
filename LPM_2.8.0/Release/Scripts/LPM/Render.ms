/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com


    Copyright (C) 2010  Lukas Lepicovsky LPM, 3DS Max Pass Manager

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.




	Modified by grover_gol ( http://gg3dcg.ru/ ) for Altspace  ( http://altspace.com/ )  2015da




*/

struct LPM_RenderAPI
(

	--The only two functions to be called from outside the API is
	--fnPreRenderAction thePass theShot (Store and set render settings before a pass)
	--fnPostRenderAction thePass theShot (Restore render settings after a pass)

	------------------------------------------------------------------------
	--Utility Functions
	------------------------------------------------------------------------
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
	),
	fn setWarning=
	(
		try(
			LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
			LPM_renderProgress_Ro.warning.color=(color 135 6 6)
		)catch()
	),
	fn saveBG=
	(
		bk=#()
		bk[1]=backgroundColor
		bk[2]=useEnvironmentMap
		bk[3]=environmentMap
		bk[4]=lightTintColor
		bk[5]=lightLevel
		bk[6]=ambientColor
		bk
	),

	fn setProp it property value=
	(
		if(value==2) then
			setProperty it property on
		if(value==3) then
			setProperty it property off
	),

	fn setPropInv it property value=
	(
		if(value==3) then
			setProperty it property on
		if(value==2) then
			setProperty it property off
	),

	fn setCommonProps item=
	(
		cp=LPM_Fun.firstChildByType item "commonProps"
		if(cp!=undefined) and (cp.initialized) and (cp.active) then
		(
			if(cp.timeOutputTgl) then
			(
				rendTimeType=cp._rendTimeType
				rendNThFrame=cp._rendNThFrame
				rendStart=cp._rendStart
				rendEnd=cp._rendEnd
				rendFileNumberBase=cp._rendFileNumberBase
				rendPickupFrames=cp._rendPickupFrames
			)
			if(cp.outputSizeTgl) then
			(
				renderHeight=cp._renderHeight
				renderWidth=cp._renderWidth
				setRendApertureWidth cp._RendApertureWidth
				renderPixelAspect=cp._renderPixelAspect
			)
			if(cp.optionsTgl) then
			(
				rendAtmosphere=cp._rendAtmosphere
				renderEffects =cp._renderEffects
				renderDisplacements=cp._renderDisplacements
				rendColorCheck=cp._rendColorCheck
				rendFieldRender=cp._rendFieldRender
				rendHidden=cp._rendHidden
				rendSimplifyAreaLights=cp._rendSimplifyAreaLights
				rendForce2Side=cp._rendForce2Side
				rendSuperBlack=cp._rendSuperBlack
			)
			if(cp.advancedLightingTgl ) then
			(
				RadiosityPreferences.useAdvancedLighting=cp._useAdvancedLighting
				RadiosityPreferences.computeAdvancedLighting	=cp._computeAdvancedLighting
			)
			if(cp.cameraTgl) then
			(
				try(viewport.setCamera cp._Camera)catch()
			)
			if(cp.renderTypeTgl) then
			(
				try(setRenderType (cp.renderType as name))catch()
			)
			if(cp.gammaTgl) then
			(
				fileOutGamma=cp._fileOutGamma
				displayGamma=cp._fileOutGamma
			)
			rendSaveFile=not cp.disableFinalOutput
		)
		return cp
	),
	fn getTimeDifference startTime endTime =
	(
		fn getDayOfYear date =
		(
			local d = 0
			-- days from beginnig of year for each month
			local months = #( 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)
			d = months[date[2]] + date[4]
			-- adjust leap year
			if ((mod date[1] 4 == 0 ) and (d>59) ) do d+=1
			return d
		)
		local timeDiff = #()

		-- let's face it - calculations shouldn't take this long
		timeDiff[1] = timeDiff[2] = timeDiff[3] = 0
		timeDiff[4] = (getDayOfYear endTime) - (getDayOfYear startTime)
		if (timeDiff[4] < 0) do timeDiff[4]+=365
		timeDiff[5] = endTime[5] - startTime[5]
		if (timeDiff[5] < 0) do timeDiff[5]+=24
		timeDiff[6] = endTime[6] - startTime[6]
		if (timeDiff[6] < 0) do timeDiff[6]+=60
		timeDiff[7] = endTime[7] - startTime[7]
		if (timeDiff[7] < 0) do timeDiff[7]+=60
		timeDiff[8] = endTime[8] - startTime[8]
		if (timeDiff[8] < 0) do timeDiff[8]+=1000
		return timeDiff
	),
	fn execScriptNodes thePass moment=
	(
		for scriptNode in thePass.children where ((scriptNode.type=="script")and(scriptNode.active)) do
		(
			if (moment==#preLPM and scriptNode.preLPM) or (moment==#preRender and scriptNode.preRender) then
			(
				try
				(
					execute scriptNode.script
				)
				catch
				(
					err="Pass"+thePass.name+"\n"
					err+="Script node "+scriptNode.name+"\n"
					err+="Failed to execute\n"
					err+=(getcurrentException() as string)
					messagebox err  title:"Warning. Pre script error."
				)
			)

			if (moment==#postLPM and scriptNode.postLPM) or (moment==#postRender and scriptNode.postRender)  then
			(
				try
				(

					if (isProperty scriptNode #script2) then
					(
						execute scriptNode.script2
					)
					else
					(
						execute scriptNode.script
					)

				)
				catch
				(
					err="Pass"+thePass.name+"\n"
					err+="Script node "+scriptNode.name+"\n"
					err+="Failed to execute\n"
					err+=(getcurrentException() as string)
					messagebox err title:"Warning. Post script error."
				)
			)

			if (moment==#preRender and scriptNode.PostRenderFrameScript) then
			(
				LPM_Root.PostRenderFrameScript = true
				LPM_Root.PostRenderFrameScriptText = scriptNode.PostRenderFrameScriptText
			)


		)
	),
	fn LightSetsApply lightNodes hitNodes lightSetArray =
	(
		for k=1 to lightNodes.count do
		(
			i=lightNodes.count+1-k
			--hide
			for it in lightNodes[i] where ((finditem hitNodes it)==0) do
			(
				append hitNodes it
				--hide

				--try
				--	(
				--		setProp it #enabled lightSetArray[i].pEnable
				--		setPropInv it #ishidden lightSetArray[i].pEnable
				--	)
				--	catch()

				try
				(
					case lightSetArray[i].pEnable of
					(
						2:
						(
							it.on = true
							it.ishidden = false
						)
						3:
						(
							it.on = false
							it.ishidden = true
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pEnable of
					(
						2:
						(
							it.enabled = true
							it.ishidden = false
						)
						3:
						(
							it.enabled = false
							it.ishidden = true
						)
					)
				)
				catch()


				---------    vray part



				try
				(
					if (lightSetArray[i].pMultiplierEnable) then
					(
						it.baseObject.multiplier = lightSetArray[i].pMultiplier
					)
				)
				catch()

				try
				(
					if lightSetArray[i].pColorEnable then
					(
						it.color=lightSetArray[i].pColor
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pCastShadows of
					(
						2:
						(
							it.baseObject.castShadows = true
						)
						3:
						(
							it.baseObject.castShadows = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectDiffuse of
					(
						2:
						(
							it.baseObject.affect_diffuse = true
						)
						3:
						(
							it.baseObject.affect_diffuse = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectSpecular of
					(
						2:
						(
							it.baseObject.affect_specualr = true
						)
						3:
						(
							it.baseObject.affect_specualr = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectReflections of
					(
						2:
						(
							it.baseObject.affect_reflections = true
						)
						3:
						(
							it.baseObject.affect_reflections = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pUseTexture of
					(
						2:
						(
							it.baseObject.texmap_on = true
						)
						3:
						(
							it.baseObject.texmap_on = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pVrayInvisible of
					(
						2:
						(
							it.baseObject.invisible = true
						)
						3:
						(
							it.baseObject.invisible = false
						)
					)
				)
				catch()

				try
				(
					if lightSetArray[i].pTextureEnable then
					(
						it.baseObject.texmap=lightSetArray[i].pTexture
					)
				)
				catch()



				---------    corona part

				try
				(
					if (lightSetArray[i].pMultiplierEnable) then
					(
						it.baseObject.intensity = lightSetArray[i].pMultiplier
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pCastShadows of
					(
						2:
						(
							it.baseObject.castsShadows = true
						)
						3:
						(
							it.baseObject.castsShadows = false
						)
					)
				)
				catch()

				try
				(
					if lightSetArray[i].pColorEnable then
					(
						it.color=lightSetArray[i].pColor
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectDiffuse of
					(
						2:
						(
							it.baseObject.visibleDirectly = true
						)
						3:
						(
							it.baseObject.visibleDirectly = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectReflections of
					(
						2:
						(
							it.baseObject.visibleRefl = true
						)
						3:
						(
							it.baseObject.visibleRefl = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pUseTexture of
					(
						2:
						(
							it.baseObject.colorMode = 2
						)
						3:
						(
							it.baseObject.colorMode = 0
						)
					)
				)
				catch()

				try
				(
					if lightSetArray[i].pTextureEnable then
					(
						it.baseObject.texmap=lightSetArray[i].pTexture
					)
				)
				catch()

				---------    default part

				try
				(
					case lightSetArray[i].pAffectDiffuse of
					(
						2:
						(
							it.baseObject.affectDiffuse = true
						)
						3:
						(
							it.baseObject.affectDiffuse = false
						)
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pAffectSpecular of
					(
						2:
						(
							it.baseObject.affectSpecular = true
						)
						3:
						(
							it.baseObject.affectSpecular = false
						)
					)
				)
				catch()



				try
				(
					if lightSetArray[i].pTextureEnable then
					(
						tmpProjector = it.baseObject.projector

						it.baseObject.projectorMap=lightSetArray[i].pTexture

						it.baseObject.projector = tmpProjector
					)
				)
				catch()

				try
				(
					case lightSetArray[i].pUseTexture of
					(
						2:
						(
							it.baseObject.projector = true
						)
						3:
						(
							it.baseObject.projector = false
						)
					)
				)
				catch()


			)
		)
	),
	fn SetVrayGI VRayGIobj =
	(
		TmpGetVRayGIFilesPath = LPM_Fun.GetVRayGIFilesPath VRayGIobj

		vr=renderers.current

		if TmpGetVRayGIFilesPath[1] != "" then
		(
			if VRayGIobj.WriteMode then
			(
				makeDir (getFilenamePath TmpGetVRayGIFilesPath[1]) all:true

				if VRayGIobj.IrMapOn then
				(
					vr.gi_on = true

					vr.adv_irradmap_mode = case VRayGIobj.IrmapMode of
					(
						1: 0
						2: 1
						3: 6
					)

					vr.adv_irradmap_saveFileName = vr.adv_irradmap_autoSaveFileName = TmpGetVRayGIFilesPath[1]
					vr.adv_irradmap_autoSave = true
					vr.gi_irradmap_multipleViews = VRayGIobj.IrmapUseCamera
				)

				if VRayGIobj.LightCacheOn then
				(
					vr.gi_on = true

					vr.lightcache_mode = case VRayGIobj.LightCacheMode of
					(
						1: 0
						2: 1
					)

					vr.lightcache_autoSave = true
					vr.lightcache_saveFileName = vr.lightcache_autosaveFileName = TmpGetVRayGIFilesPath[2]
					vr.lightcache_multipleViews = VRayGIobj.LightCacheUseCamera
				)

				vr.options_dontRenderImage = VRayGIobj.DontRenderFinal

			)
			else
			(

				TmpCheckVRayGIExist = LPM_Fun.CheckVRayGIExist VRayGIobj

				InputPassVRayGIObj = LPM_Fun.firstChildByType VRayGIobj.InputPass "VRayGI"

				if (InputPassVRayGIObj != undefined) then
				(
					if VRayGIobj.IrMapOn then
					(
						if TmpCheckVRayGIExist[1] then
						(
							vr.gi_on = true

							vr.adv_irradmap_mode = case InputPassVRayGIObj.IrmapMode of
							(
								1: 2
								2: 2
								3: 7
							)
							vr.adv_irradmap_autoSave = false
							vr.adv_irradmap_loadFileName = TmpGetVRayGIFilesPath[1]
							vr.gi_irradmap_multipleViews = VRayGIobj.IrmapUseCamera
						)
						else
						(
							try
							(
								LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
								LPM_renderProgress_Ro.warning.color=color 135 6 6
							)
							catch
							(
							)
							print "Warning: V-Ray Global Illumination Irradiance map files NOT FOUND!!!"
						)
					)

					if VRayGIobj.LightCacheOn then
					(
						if TmpCheckVRayGIExist[2] then
						(
							vr.gi_on = true

							vr.lightcache_mode = 2

							vr.lightcache_autoSave = false
							vr.lightcache_loadFileName =  TmpGetVRayGIFilesPath[2]
							vr.lightcache_multipleViews = VRayGIobj.LightCacheUseCamera
						)
						else
						(
							try
							(
								LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
								LPM_renderProgress_Ro.warning.color=color 135 6 6
							)
							catch
							(
							)
							print "Warning: V-Ray Global Illumination Light cache files NOT FOUND!!!"
						)
					)
				)
				else
				(
					try
					(
						LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
						LPM_renderProgress_Ro.warning.color=color 135 6 6
					)
					catch
					(
					)
					print "Warning: V-Ray Global Illumination files NOT FOUND!!!"
				)
			)
		)
		else
		(
			try
			(
				LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
				LPM_renderProgress_Ro.warning.color=color 135 6 6
			)
			catch
			(
			)
			print "Warning: V-Ray Global Illumination files NOT FOUND!!!"
		)
	),

	fn SetAutomask AutoMaskobj =
	(
		if AutoMaskobj.layersOn then
		(

			LMan=LayerManager

			TmpAutoMasObjLayers = AutoMaskobj.layers as Array
			TmpAutoMaskLayers = #()

			for i = 1 to TmpAutoMasObjLayers.count do
			(
				TmpLayer=LMan.getLayerfromName TmpAutoMasObjLayers[i]

				if(TmpLayer != undefined) then
				(
					append TmpAutoMaskLayers TmpAutoMasObjLayers[i]
				)
			)


			if AutoMaskobj.layersRGB then
			(
				TmpLoopsCount = TmpAutoMaskLayers.count/3
				TmpLoopsCountFloat = (TmpAutoMaskLayers.count/3.)

				if (TmpLoopsCountFloat- TmpLoopsCount)>0  then
				(
					TmpLoopsCount += 1
				)


				for j=1 to (TmpLoopsCount) do
				(
					TmpLayerNodes=#()
					TmpLayerNodes2=#()
					TmpLayerNodes3=#()

					theLayer = undefined
					theLayer2 = undefined
					theLayer3 = undefined

					try
					(
						theLayer=LMan.getLayerfromName TmpAutoMaskLayers[(j-1)*3 + 1]
					)
					catch
					(
					)
					try
					(
						theLayer2=LMan.getLayerfromName TmpAutoMaskLayers[(j-1)*3 + 2]
					)
					catch
					(
					)
					try
					(
						theLayer3=LMan.getLayerfromName TmpAutoMaskLayers[(j-1)*3 + 3]
					)
					catch
					(
					)

					if(theLayer != undefined) then
					(
						theLayer.nodes &TmpLayerNodes
					)

					if(theLayer2 != undefined) then
					(
						theLayer2.nodes &TmpLayerNodes2
					)

					if(theLayer3 != undefined) then
					(
						theLayer3.nodes &TmpLayerNodes3
					)

					TmpMaskName = "am_" + (substring theLayer.name 1 10)

					try
					(
						TmpMaskName += "_" + (substring theLayer2.name 1 10)
					)
					catch()

					try
					(
						TmpMaskName += "_" + (substring theLayer3.name 1 10)
					)
					catch()


					LPM_Fun.CreateRGBmask (TmpLayerNodes as Array) (TmpLayerNodes2 as Array) (TmpLayerNodes3 as Array) TmpMaskName

				)
			)
			else
			(
				for j=1 to TmpAutoMaskLayers.count do
				(
					TmpLayerNodes=#()

					theLayer=LMan.getLayerfromName TmpAutoMaskLayers[j]

					if(theLayer != undefined) then
					(
						theLayer.nodes &TmpLayerNodes
					)

					if TmpLayerNodes.count != 0 then
					(

						LPM_Fun.CreateBWmask (TmpLayerNodes as Array) ("am_" + theLayer.name)

					)
				)
			)
		)

		if AutoMaskobj.ObjectIDsOn then
		(
			if AutoMaskobj.ObjectIDsRGB then
			(
				LPM_Fun.CreateIDRGBmask (LPM_Fun.NumbersFromString AutoMaskobj.ObjectIDs)
			)
			else
			(
				LPM_Fun.CreateIDBWmask (LPM_Fun.NumbersFromString AutoMaskobj.ObjectIDs)
			)

		)

		if AutoMaskobj.MaterialIDsOn then
		(
			if AutoMaskobj.MaterialIDsRGB then
			(
				LPM_Fun.CreateIDRGBmask (LPM_Fun.NumbersFromString AutoMaskobj.MaterialIDs) isMatID:true
			)
			else
			(
				LPM_Fun.CreateIDBWmask (LPM_Fun.NumbersFromString AutoMaskobj.MaterialIDs) isMatID:true
			)
		)

		if AutoMaskobj.nodesOn then
		(

			TmpAutoMaskObjNodes = AutoMaskobj.nodes as Array
			TmpAutoMaskNodes = #()

			for i = 1 to TmpAutoMaskObjNodes.count do
			(
				if(isvalidnode TmpAutoMaskObjNodes[i]) then
				(
					append TmpAutoMaskNodes TmpAutoMaskObjNodes[i]
				)
			)

			if AutoMaskobj.nodesRGB then
			(
				TmpLoopsCount = TmpAutoMaskNodes.count/3
				TmpLoopsCountFloat = TmpAutoMaskNodes.count/3.

				if (TmpLoopsCountFloat - TmpLoopsCount) >0  then
				(
					TmpLoopsCount += 1
				)


				for j=1 to (TmpLoopsCount) do
				(
					TmpAutoMaskNode1 = #()
					TmpAutoMaskNode2 = #()
					TmpAutoMaskNode3 = #()

					TmpMaskName = "am_"

					if(isvalidnode TmpAutoMaskNodes[(j-1)*3 + 1]) then
					(
						TmpAutoMaskNode1 = #(TmpAutoMaskNodes[(j-1)*3 + 1])
					)

					if(isvalidnode TmpAutoMaskNodes[(j-1)*3 + 2]) then
					(
						TmpAutoMaskNode2 = #(TmpAutoMaskNodes[(j-1)*3 + 2])
					)

					if(isvalidnode TmpAutoMaskNodes[(j-1)*3 + 3]) then
					(
						TmpAutoMaskNode3 = #(TmpAutoMaskNodes[(j-1)*3 + 3])
					)

					if (TmpAutoMaskNode1 != #()) or (TmpAutoMaskNode2 != #()) or (TmpAutoMaskNode3 != #()) then
					(
						try
						(
							TmpMaskName += (substring (TmpAutoMaskNode1[1].name) 1 10)
						)
						catch()
						try
						(
							TmpMaskName += "_" + (substring (TmpAutoMaskNode2[1].name) 1 10)
						)
						catch()

						try
						(
							TmpMaskName += "_" + (substring (TmpAutoMaskNode3[1].name) 1 10)
						)
						catch()

						LPM_Fun.CreateRGBmask TmpAutoMaskNode1 TmpAutoMaskNode2 TmpAutoMaskNode3 TmpMaskName
					)

				)
			)
			else
			(
				for j=1 to TmpAutoMaskNodes.count do
				(

					if(isvalidnode TmpAutoMaskNodes[j]) then
					(
						LPM_Fun.CreateBWmask #(TmpAutoMaskNodes[j]) ("am_" + TmpAutoMaskNodes[j].name)
					)

				)
			)
		)
	),



	-----------------------------------------------------------------------------------------------------------------------------------------------
	--BACKUP INFORMATION
	-----------------------------------------------------------------------------------------------------------------------------------------------

	commonSettings,
	objBackup,
	lightBackup,
	applyAtmosphericsBackup,
	elementBackup,
	elementVrayBackup,
	effectBackup,
	atmBackup,
	envBackup,
	AdjeffectBackup,
	AdjatmBackup,
	AdjenvBackup,
	exposureBackup,
	xrefBackArray,
	xrefObjBackArray,
	preRenderSettings,
	preRenderSettingsNew,
	AdjpreRenderSettings,
	AdjpreRenderSettingsNew,
	viewportCamBack,
	viewportTypeBack,
	vrfrbufBackup,
	DistributedRenderBack,
	HideRFWBack,
	SkipExistingImagesBack,
	ModifierBack,
	AdjModifierBack,
	VRayGIBack,
	AdjVRayGIBack,


	fn fnPreRenderAction thePass theShot isPreviewMode:false=
	(
		--clear all backup variables
		commonSettings=objBackup=lightBackup=applyAtmosphericsBackup=elementBackup=elementVrayBackup=effectBackup=atmBackup=envBackup=AdjeffectBackup=AdjatmBackup=AdjenvBackup=xrefObjBackArray=xrefBackArray=preRenderSettings=preRenderSettingsNew=viewportCamBack=viewportTypeBack=undefined
		with redraw off
		(
			with animate off
			(




				----------------------------------------------------------------------------------------------   Pre LPM scripts   ----------------------------------------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					LPM_Render.execScriptNodes theAdjustmentPass #preLPM

				)

				LPM_Render.execScriptNodes thePass #preLPM
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



				preProcTime=timeStamp()


				------------------------------------------------------------------------------------------------      Save current common properties     ------------------------------------------------------------------------------------------------
				commonSettings=#()
				commonSettings[1]=rendTimeType
				commonSettings[2]=rendNThFrame
				commonSettings[3]=rendStart
				commonSettings[4]=rendEnd
				commonSettings[5]=rendFileNumberBase
				commonSettings[6]=rendPickupFrames
				commonSettings[7]=renderHeight
				commonSettings[8]=renderWidth
				commonSettings[9]=getRendApertureWidth()
				commonSettings[10]=renderPixelAspect
				commonSettings[11]=rendAtmosphere
				commonSettings[12]=renderEffects
				commonSettings[13]=renderDisplacements
				commonSettings[14]=rendColorCheck
				commonSettings[15]=rendFieldRender
				commonSettings[16]=rendHidden
				commonSettings[17]=rendSimplifyAreaLights
				commonSettings[18]=rendForce2Side
				commonSettings[19]=rendSuperBlack
				commonSettings[20]=RadiosityPreferences.useAdvancedLighting
				commonSettings[21]=RadiosityPreferences.computeAdvancedLighting
				commonSettings[22]=rendSaveFile
				commonSettings[23]=rendOutputFileName
				commonSettings[24]=skipRenderedFrames
				commonSettings[25]=rendUseNet

				if(getRenderType!=undefined) then
					commonSettings[26]=getRenderType()
				commonSettings[27]=fileOutGamma
				commonSettings[28]=displayGamma

				commonSettings[29]=usePreRendScript
				commonSettings[30]=preRendScript
				commonSettings[31]=usePostRendScript
				commonSettings[32]=postRendScript

				--backup active viewport
				viewportTypeBack=viewport.getType()
				viewportCamBack=viewport.getcamera()

				--set camera
				if(isvalidNode LPM_Root.renderCamera) then
					viewport.setCamera LPM_Root.renderCamera



				---------------------------------------------------------------------------------------------------   common properties Adjustment pass -----------------------------------------------------------------


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					cp = (setCommonProps theAdjustmentPass)


				)




				------------------------------------------------------------------------------------------------   Set common properties  ------------------------------------------------------------------------------------------------

				rendSaveFile=true
				cp = (setCommonProps thePass)

				if(theShot!=undefined) then
				(
					cp = (setCommonProps theShot)
				)



				if not (isPreviewMode) then
				(
					try
					(
						if maxOps.rendUseIterative then
						(
							macros.run "Render" "RenderButtonMenu_Switch_To_Production_Mode"
							messagebox "Renderer switched to production mode." title:"Warning!"
						)
					)
					catch
					(
					)
				)





				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------------------     rendOutputFilename   ----------------------------------------------------------------------




				rendOutputFilename=LPM_Fun.getPassPath LPM_Root thePass theShot:theShot previewMode:false RendPreviewMode:isPreviewMode elementName:""




				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------









				---------------------------------------------------------------------------------------------------  RenderSettings Adjustment pass -----------------------------------------------------------------

				--Save current renderer settings
				-------------------------------------------------------------------------------------------------
				AdjpreRenderSettings=undefined
				AdjpreRenderSettingsNew=undefined


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					theMainRenderProps=for it in thePass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it


					theRenderProps=for it in theAdjustmentPass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it


					if( theRenderProps[1]!=undefined) and ( theMainRenderProps[1] == undefined) then
					(
						if theRenderProps[1].propsAlternate != "" then
						(
							AdjpreRenderSettingsNew=LPM_Fun.saveRenderPresetNew()
							AdjpreRenderSettings = 0
						)
						else
						(
							AdjpreRenderSettings=LPM_Fun.saveRenderPreset()
						)


						--preRenderSettings=renderers.current
						try
						(
							LPM_Fun.loadRenderPresetNew theRenderProps[1].propsAlternate
						)
						catch
						(
							LPM_Fun.loadRenderPreset theRenderProps[1].props
						)

					)

					theRenderProps = undefined

				)




				---------------------------------------------------------------------------------------------------   RenderSettings -----------------------------------------------------------------

				--Save current renderer settings
				-------------------------------------------------------------------------------------------------
				preRenderSettings=undefined
				preRenderSettingsNew=undefined
				preRenderSettings=LPM_Fun.saveRenderPreset() --ALWAYS save preset beforehand, to account for vrayRenderProps and such -tyson
				--TODO: look at what tyson did? -aaron


				--Load current renderer settings
				-------------------------------------------------------------------------------------------------
				theRenderProps=for it in thePass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it
				if( theRenderProps[1]!=undefined) then
				(
					if theRenderProps[1].propsAlternate != "" then
					(
						preRenderSettingsNew=LPM_Fun.saveRenderPresetNew()
						preRenderSettings = 0
					)
					else
					(
						preRenderSettings=LPM_Fun.saveRenderPreset()
					)


					--preRenderSettings=renderers.current
					try
					(
						LPM_Fun.loadRenderPresetNew theRenderProps[1].propsAlternate
					)
					catch
					(
						LPM_Fun.loadRenderPreset theRenderProps[1].props
					)

				)

				if findstring ((classof renderers.current) as string) "V_RAY" != undefined then
				(
					theVrayProps=for it in thePass.children where ((it.type=="vrayProps") and (it.initialized) and (it.active)) collect it
					if(theVrayProps[1] != undefined) then
					(
						LPM_Fun.loadVraySettings theVrayProps[1] isPreviewMode
					)

				)

				--Load Deadline Props -- Dabelow
				-------------------------------------------------------------------------------------------------
				filein (LPM_Dir+"LPM_SMTDSettings.ms") -- resets LPM_SMTDSettings

				theDeadlineProps=for it in thePass.children where ((it.type=="Deadline") and (it.active)) collect it
				if(theDeadlineProps[1] != undefined) then
				(
					print thePass
					LPM_Fun.loadDeadlineSettings theDeadlineProps[1] isPreviewMode
				)

				--Load Vray5 Props -- Dabelow vray5
				-------------------------------------------------------------------------------------------------

				--Load Vray5 Render elements Props -- Dabelow vray5
				-------------------------------------------------------------------------------------------------


				--Load photoStudio Props
				-------------------------------------------------------------------------------------------------
				photoStudioProps=LPM_Fun.firstChildByType thePass "photoStudio"
				if(photoStudioProps != undefined) and (photoStudioProps.active) then
				(
					if classof renderers.current == mental_ray_renderer then
					(
						--if render settings are not backed up, then back them up

						if(preRenderSettingsNew)==undefined then
						(
							preRenderSettingsNew=LPM_Fun.saveRenderPresetNew()
						)

						if(preRenderSettings)==undefined then
						(
							preRenderSettings=LPM_Fun.saveRenderPreset()
						)

						renderers.current.Camera_Lens_Shader=photoStudioProps.ps
						--gamma
						renderers.current.Camera_Lens_Shader.gamma=fileOutGamma
						--Physical Scale
						renderers.current.Camera_Lens_Shader.cm2_factor=80000.0/pi
						try(renderers.current.Camera_Lens_Shader.cm2_factor=SceneExposureControl.exposureControl.physical_scale/pi)
						catch
						(
							print "**Warning** PhotoStudio Exposure: Exposure Control not found, defaulting to Physical Scale of 80000.0, consider using Logarithmic Exposure Control."
							setWarning()
						)

						renderers.current.MotionBlurEnable = photoStudioProps.mb_aktiv
						renderers.current.MotionBlurAllObjects = photoStudioProps.blur_all
						renderers.current.Shutter =  photoStudioProps.duration
						renderers.current.MotionBlurOffset = photoStudioProps.offset
						renderers.current.Segments= photoStudioProps.motion_segments
						renderers.current.TimeSamples = photoStudioProps.time_samples
						renderers.current.RapidMotionResample = photoStudioProps.rapid_samples

					)
					else
					(
						setWarning()
						print "**Warning** PhotoStudio Exposure requires Mental Ray"
					)
				)


				----------------------------------------------------------------------------------------------   xrefObjects Backup  ----------------------------------------------------------------------------------------------

				xrefObjBackArray=#()

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					xrefObjProps=LPM_Fun.firstChildByType thePass.AdjustmentFor "xrefObj"

					if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
					(
						--backup the settings
						for i=1 to objXRefMgr.recordCount do
						(xrefObjBackArray[i] = (objXRefMgr.GetRecord i).enabled)
					)
				)
				else
				(
					xrefObjProps=LPM_Fun.firstChildByType thePass "xrefObj"

					if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
					(
						--backup the settings
						for i=1 to objXRefMgr.recordCount do
						(xrefObjBackArray[i] = (objXRefMgr.GetRecord i).enabled)
					)
				)

				---------------------------------------------------------------------------------------------------   Adjustment pass xrefObjects -----------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					xrefObjProps=LPM_Fun.firstChildByType thePass.AdjustmentFor "xrefObj"
					if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
					(

						--set the obj
						for i=1 to objXRefMgr.recordCount do
						(
							theXref=(objXRefMgr.GetRecord i)
							if((findItem xrefObjProps.fileNames theXref.srcFileName)!=0) then
								theXref.enabled=true
							else
								theXref.enabled=false
						)
					)
				)

				----------------------------------------------------------------------------------------------   xrefObjects   ----------------------------------------------------------------------------------------------


				xrefObjProps=LPM_Fun.firstChildByType thePass "xrefObj"
				if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
				(

					--set the obj
					for i=1 to objXRefMgr.recordCount do
					(
						theXref=(objXRefMgr.GetRecord i)
						if((findItem xrefObjProps.fileNames theXref.srcFileName)!=0) then
							theXref.enabled=true
						else
							theXref.enabled=false
					)
				)





				------------------------------------------------------------------------------------------------backup object set properties


				objBackup=for it in objects where ((superclassof it)!=light) collect
				(
					#(it,it.renderable,it.castshadows,it.receiveshadows,it.primaryVisibility,it.secondaryVisibility,it.motionBlurOn,it.renderOccluded,it.material,it.ishidden,(getuserPropBuffer it))
				)





				------------------------------------------------------------------------------------------------backup lightset properties


				lightBackup=for it in objects where ((superclassof it)==light) collect
				(
					tmp=#(it)
					try(tmp[2]=it.on)catch()
					try(tmp[3]=it.baseObject.multiplier)catch()
					try(tmp[4]=it.color)catch()
					try(tmp[5]=it.baseObject.castShadows)catch()
					try(tmp[6]=it.baseObject.affect_diffuse)catch()
					try(tmp[7]=it.baseObject.affect_specualr)catch()
					try(tmp[8]=it.baseObject.affect_reflections)catch()
					try(tmp[9]=it.baseObject.texmap)catch()


					try(tmp[10]=it.baseObject.intensity)catch()
					try(tmp[11]=it.baseObject.visibleDirectly)catch()
					try(tmp[12]=it.baseObject.visibleRefl)catch()
					try(tmp[13]=it.baseObject.castsShadows)catch()

					try(tmp[14]=it.baseObject.affectDiffuse)catch()
					try(tmp[15]=it.baseObject.affectSpecular)catch()
					try(tmp[16]=it.baseObject.projectorMap)catch()

					try(tmp[17]=it.baseObject.projector)catch()
					try(tmp[18]=it.baseObject.texmap_on)catch()
					try(tmp[19]=it.baseObject.colorMode)catch()
					try(tmp[20]=it.isHidden)catch()

					try(tmp[21]=it.enabled)catch()

					--try(tmp[5]=it.enabled)catch()
					tmp
				)








				---------------------------------------------------------------------------------------------------   All objects and lights  Adjustment pass -----------------------------------------------------------------


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(


					theAdjustmentPass = thePass.AdjustmentFor

					---------------------------------------------------------------------------------   Adjustment All   ---------------------------------------------------------------------------------

					if(theAdjustmentPass.hideMode>1) then
					(
						val=true
						if(theAdjustmentPass.hideMode==3) then val=false

						for it in objects where ((superclassof it)!=light) do
						(
							it.ishidden = val
						)
						for it in lights where ((superclassof it)==light) do
						(
							try
							(
								it.enabled=(not val)
								it.ishidden = val
							)
							catch()
							try
							(
								it.on=(not val)
								it.ishidden = val
							)
							catch()
						)
					)

					---------------------------------------------------------------------------------   Adjustment objects   ---------------------------------------------------------------------------------

					objNodes=#()
					objSetArray=#()
					LPM_Fun.getObjectSetArrays theAdjustmentPass "objectSet" &objNodes &objSetArray

					hitNodes=#()
					for k=1 to objNodes.count do
					(
						i=objNodes.count+1-k
						for it in objNodes[i] where ((finditem hitNodes it)  ==0) do
						(
							append hitNodes it
							setPropInv it #ishidden objSetArray[i].intP[1]
							setProp it #castshadows objSetArray[i].intP[2]
							setProp it #receiveshadows objSetArray[i].intP[3]
							setProp it #primaryVisibility objSetArray[i].intP[4]
							setProp it #secondaryVisibility objSetArray[i].intP[5]
							setProp it #motionBlurOn  objSetArray[i].intP[6]
							setProp it #applyAtmospherics objSetArray[i].intP[7]
							setProp it #renderOccluded objSetArray[i].intP[8]

							try
							(
								setProp it #renderable objSetArray[i].intP[10]
							)
							catch
							(
								setProp it #renderable objSetArray[i].intP[1]
							)
							--user props
							if(objSetArray[i].intP[9]==2) then
							(
								setUserPropBuffer it (objSetArray[i].userProp)
							)
							if objSetArray[i].pMatEnable then
							(
								it.material=objSetArray[i].pMaterial
							)
						)
					)

					---------------------------------------------------------------------------------   Adjustment lights   ---------------------------------------------------------------------------------

					lightNodes=#()
					lightSetArray=#()
					LPM_Fun.getObjectSetArrays theAdjustmentPass "lightSet" &lightNodes &lightSetArray

					hitNodes=#()

					LightSetsApply lightNodes hitNodes lightSetArray

				)




				---------------------------------------------------------------------------------------------------   All objects and lights   -----------------------------------------------------------------

				--               change to the default mode of the pass,
				if(thePass.hideMode>1) and (not thePass.isAdjustment) then
				(
					val=true
					if(thePass.hideMode==3) then val=false

					for it in objects where ((superclassof it)!=light) do
					(
						it.ishidden = val
					)
					for it in lights where ((superclassof it)==light) do
					(
						try
						(
							it.enabled=(not val)
							it.ishidden = val
						)
						catch()
						try
						(
							it.on=(not val)
							it.ishidden = val
						)
						catch()
					)
				)







				---------------------------------------------------------------------------------------------------   object sets   -----------------------------------------------------------------


				objNodes=#()
				objSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "objectSet" &objNodes &objSetArray



				-----------------------------------------------------------------------------------------------------   Backup Apply Atmospherics   -----------------------------------------------------------------------------------------------------
				----------------------------------------------    Apply atmospherics are only backed up when needed, this is due to the fact that then take 1000x longer than anything else to backup....

				applyAtmosphericsFlag=false
				for it in objSetArray do
				(
					if (it.intP[7]!= 1) then
						applyAtmosphericsFlag=true
				)

				applyAtmosphericsBackup=#()
				if(applyAtmosphericsFlag) then
				(
					applyAtmosphericsBackup=for it in $objects collect #(it, it.applyAtmospherics)
				)
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




				hitNodes=#()

				for k=1 to objNodes.count do
				(
					i=objNodes.count+1-k
					for it in objNodes[i] where ((finditem hitNodes it)  ==0) do
					(
						append hitNodes it
						setPropInv it #ishidden objSetArray[i].intP[1]
						setProp it #castshadows objSetArray[i].intP[2]
						setProp it #receiveshadows objSetArray[i].intP[3]
						setProp it #primaryVisibility objSetArray[i].intP[4]
						setProp it #secondaryVisibility objSetArray[i].intP[5]
						setProp it #motionBlurOn  objSetArray[i].intP[6]
						setProp it #applyAtmospherics objSetArray[i].intP[7]
						setProp it #renderOccluded objSetArray[i].intP[8]

						try
						(
							setProp it #renderable objSetArray[i].intP[10]
						)
						catch
						(
							setProp it #renderable objSetArray[i].intP[1]
						)
						--user props
						if(objSetArray[i].intP[9]==2) then
						(
							setUserPropBuffer it (objSetArray[i].userProp)
						)
						if objSetArray[i].pMatEnable then
						(
							it.material=objSetArray[i].pMaterial
						)
					)
				)

				---------------------------------------------------------------------------------------------------   object sets END   -----------------------------------------------------------------




				----------------------------------------------------------------------------------    Lights sets       ----------------------------------------------------------------------------------

				lightNodes=#()
				lightSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "lightSet" &lightNodes &lightSetArray

				hitNodes=#()

				LightSetsApply lightNodes hitNodes lightSetArray

				----------------------------------------------------------------------------------    Lights sets END      ----------------------------------------------------------------------------------






				----------------------------------------------------------------------------------    Render Switcher          ----------------------------------------------------------------------------------
				--First check if we want to use render switcher
				--Then switch the materials
				useRenderSwitcher=false
				for mat in scenematerials where (iskindof mat LPM_RenderSwitcher) do useRenderSwitcher=true;

				if(useRenderSwitcher) then
				(
					--remove render switcher from the ui
					for it in objects where (iskindof it.material LPM_RenderSwitcher) do
					(

						theRenderer=(classof renderers.current) as string
						useMat=it.material.fallBackInt

						if (findString theRenderer "V_Ray" !=undefined) then
							useMat=1
						if(findstring theRenderer "Corona"!=undefined) then
							useMat=2
						if(findstring theRenderer "Scanline"!=undefined) then
							useMat=3
						if (findstring theRenderer "Mental"!=undefined) then
							useMat=4

						case useMat of
						(
							1: it.material=it.material.vrayMat
							2: it.material=it.material.coronaMat
							3: it.material=it.material.scanlineMat
							4: it.material=it.material.mentalRayMat
							default: it.material=it.material.scanlineMat

						)
					)
					--for i=1 to 24 where (iskindof meditmaterials[i] LPM_RenderSwitcher) do meditmaterials[i]=standardmaterial();
				)
				----------------------------------------------------------------------------------    Render Switcher END      ----------------------------------------------------------------------------------



				--Generic Nodes


				genericNodes=for child in thePass.children where child.type=="generic" and(child.active==true) do
				(
					op=LPM_Operators.fngetByNode child
					if(op!=0) then
					(
						op.fnPerformAction #preRender
					)
				)





				-------------------------------------------------------------------------------------------------------------------------  Modifiers Override Adjustment pass -----------------------------------------------------------------------
				AdjModifierBack = #()

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					ModifierOverNodes=for child in theAdjustmentPass.children where child.type=="ModifierOver" and(child.active==true) do
					(
						myObject = child.activeNode

						if(isvalidnode myObject) then
						(
							tmp_ModArr = #()
							for modi in myObject.modifiers do
							(
								append tmp_ModArr modi.enabled

							)
							append AdjModifierBack tmp_ModArr


							for modi in myObject.modifiers do
							(

								if (findItem child.activeModifiers modi.name !=0) then
									modi.enabled=true
								else
									modi.enabled=false
							)

						)

					)

				)





				-------------------------------------------------------------------------------------------------------------------------  Modifiers Override -----------------------------------------------------------------------
				ModifierBack = #()


				ModifierOverNodes=for child in thePass.children where child.type=="ModifierOver" and(child.active==true) do
				(


					myObject = child.activeNode

					if(isvalidnode myObject) then
					(
						tmp_ModArr = #()
						for modi in myObject.modifiers do
						(
							append tmp_ModArr modi.enabled

						)
						append ModifierBack tmp_ModArr


						for modi in myObject.modifiers do
						(

							if (findItem child.activeModifiers modi.name !=0) then
								modi.enabled=true
							else
								modi.enabled=false
						)


					)



				)




				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







				--Backup/Set Elements effects atmospherics enviroments
				-------------------------------------------------------------------------------------------------
				elementBackup=#()
				elementVrayBackup=#()
				effectBackup=#()
				atmBackup=#()
				envBackup=#()

				AdjeffectBackup=#()
				AdjatmBackup=#()
				AdjenvBackup=#()

				exposureBackup=SceneExposureControl.exposureControl


				vrfrbufBackup = 0
				DistributedRenderBack = 0

				--element backup
				-------------------------------------------------------------------------------------------------
				--Elements must always be backed up because using exposure control changes the number of elements
				RenderElementsUpdatePaths()
				re = maxOps.GetCurRenderElementMgr()

				try
				(
					if not (isPreviewMode) then
					(
						theRenderer=(classof renderers.current) as string
						vr = renderers.current

						if (findString theRenderer "V_Ray" !=undefined) then
						(
							vrfrbufBackup = vr.output_on

							if (LPM_Fun.getIni "Settings" "VFBoffSetting" booleanClass true) then
							(
								vr.output_on = false
							)
						)

					)
				)
				catch
				(

				)



				---------------------------------------------------------------------------------------------------     DistributedRender   -----------------------------------------------------------------

				try
				(
					if LPM_Root.DistributedRender then
					(
						vr=renderers.current
						LocalDistributedRender = LPM_Fun.getIni "Settings" "UseDistributedRendering" booleanClass true


						theRenderer=(classof vr) as string
						useRend=0

						if (findString theRenderer "V_Ray" !=undefined) then
							useRend=1
						if(findstring theRenderer "Corona"!=undefined) then
							useRend=2

						case useRend of
						(
							1:
							(
								if  (isPreviewMode) then
								(

									DistributedRenderBack = vr.system_distributedRender
									vr.system_distributedRender = LPM_Root.DistributedRender
								)
								else
								(
									if not LocalDistributedRender then
									(
										DistributedRenderBack = vr.system_distributedRender
										vr.system_distributedRender = LPM_Root.DistributedRender
									)

								)
							)
							2:
							(
								if  (isPreviewMode) then
								(
									DistributedRenderBack = vr.dr_enable
									vr.dr_enable = LPM_Root.DistributedRender
								)
								else
								(
									if not LocalDistributedRender then
									(
										DistributedRenderBack = vr.dr_enable
										vr.dr_enable = LPM_Root.DistributedRender
									)

								)
							)
						)
					)


				)
				catch
				(

				)



				---------------------------------------------------------------------------------------------------     V-Ray Global Illumination Adjustment pass  -----------------------------------------------------------------

				AdjVRayGIBack = #()

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					VRayGIObj=LPM_Fun.firstChildByType thePass "VRayGI"
					AbjVRayGIObj=LPM_Fun.firstChildByType theAdjustmentPass "VRayGI"

					if(isvalidnode AbjVRayGIObj)and(AbjVRayGIObj.active) then
					(
						vr=renderers.current
						theRenderer=(classof vr) as string



						if (findString theRenderer "V_Ray" !=undefined) then
						(
							TmpApplyAdj = true

							if(isvalidnode VRayGIObj)and(VRayGIObj.active) then
							(
								if VRayGIObj.WriteMode and (not AbjVRayGIObj.WriteMode)
								then
								(
									TmpApplyAdj = false
								)
							)

							if TmpApplyAdj then
							(
								AdjVRayGIBack[1] = vr.gi_on
								AdjVRayGIBack[2] = vr.adv_irradmap_mode
								AdjVRayGIBack[3] = vr.adv_irradmap_loadFileName
								AdjVRayGIBack[4] = vr.adv_irradmap_saveFileName
								AdjVRayGIBack[5] = vr.adv_irradmap_autoSave
								AdjVRayGIBack[6] = vr.adv_irradmap_autoSaveFileName
								AdjVRayGIBack[7] = vr.gi_irradmap_multipleViews

								AdjVRayGIBack[8] = vr.lightcache_mode
								AdjVRayGIBack[9] = vr.lightcache_loadFileName
								AdjVRayGIBack[10] = vr.lightcache_saveFileName
								AdjVRayGIBack[14] = vr.lightcache_autosaveFileName
								AdjVRayGIBack[11] = vr.lightcache_autoSave
								AdjVRayGIBack[12] = vr.lightcache_multipleViews

								AdjVRayGIBack[13] = vr.options_dontRenderImage

								SetVrayGI AbjVRayGIObj
							)
						)
					)
				)






				---------------------------------------------------------------------------------------------------     V-Ray Global Illumination   -----------------------------------------------------------------

				VRayGIBack = #()


				try
				(
					VRayGIObj=LPM_Fun.firstChildByType thePass "VRayGI"

					if(isvalidnode VRayGIObj)and(VRayGIObj.active) then
					(
						vr=renderers.current
						theRenderer=(classof vr) as string

						if (findString theRenderer "V_Ray" !=undefined) then
						(

							VRayGIBack[1] = vr.gi_on
							VRayGIBack[2] = vr.adv_irradmap_mode
							VRayGIBack[3] = vr.adv_irradmap_loadFileName
							VRayGIBack[4] = vr.adv_irradmap_saveFileName
							VRayGIBack[5] = vr.adv_irradmap_autoSave
							VRayGIBack[6] = vr.adv_irradmap_autoSaveFileName
							VRayGIBack[7] = vr.gi_irradmap_multipleViews

							VRayGIBack[8] = vr.lightcache_mode
							VRayGIBack[9] = vr.lightcache_loadFileName
							VRayGIBack[10] = vr.lightcache_saveFileName
							VRayGIBack[14] = vr.lightcache_autosaveFileName
							VRayGIBack[11] = vr.lightcache_autoSave
							VRayGIBack[12] = vr.lightcache_multipleViews

							VRayGIBack[13] = vr.options_dontRenderImage

							SetVrayGI VRayGIObj
						)
					)

				)
				catch
				(

				)




				---------------------------------------------------------------------------------------------------     HideRFWBack  SkipExistingImagesBack  -----------------------------------------------------------------


				HideRFWBack = 0
				SkipExistingImagesBack = 0

				try
				(
					TmpShowSkipButton = LPM_Fun.getIni "Settings" "ShowSkipButton" booleanClass false

					if TmpShowSkipButton then
					(
						TmpHideRFW = LPM_Fun.getIni "Settings" "HideRFW" booleanClass false
						TmpSkipExistingImages = LPM_Fun.getIni "Settings" "SkipExistingImages" booleanClass false

						if TmpHideRFW then
						(
							HideRFWBack = rendShowVFB
							rendShowVFB = false
						)

						if TmpSkipExistingImages then
						(
							SkipExistingImagesBack = skipRenderedFrames
							skipRenderedFrames = true
						)

					)
				)
				catch
				(
				)






				---------------------------------------------------------------------------------------------------     RenderElements Back    -----------------------------------------------------------------


				for i=1 to re.NumRenderElements() do
				(

					theEle=re.GetRenderElement (i-1)

					useVray=hasProperty theEle #vrayVFB

					try
					(
						elementBackup[i]=#(theEle.enabled,re.GetRenderElementFilename (i-1))
					)
					catch ()

					try
					(
						elementVrayBackup[i]=theEle.vrayVFB
					)
					catch ()

				)



				-------------------------------------------------------------------------------------------------------------------------  envProps Override Adjustment pass  -----------------------------------------------------------------------


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					ep=LPM_Fun.firstChildByType theAdjustmentPass "envProps"
					if(ep!=undefined) and (ep.initialized) and (ep.active) then
					(
						--elements backup
						-------------------------------------------------------------------------------------------------
						if(ep.elementOverride) then
						(
							re.SetElementsActive true
							for i=1 to re.NumRenderElements() do
							(
								theEle=re.GetRenderElement (i-1)
								useVray=hasProperty theEle #vrayVFB

								if((findItem ep.activeElement theEle.elementName)!=0) then
								(
									try
									(
										theEle.enabled=true
									)
									catch ()
									try
									(
										theEle.vrayVFB=true
									)
									catch ()

								)
								else
								(
									try
									(
										theEle.enabled=false
									)
									catch ()
									try
									(
										theEle.vrayVFB=false
									)
									catch ()

								)
							)
						)
						--effectbackUP
						-------------------------------------------------------------------------------------------------
						if(ep.effectOverride) then
						(
							for i=1 to numEffects do
							(
								theEffect=getEffect i
								AdjeffectBackup[i]=IsActive theEffect
								if((findItem ep.activeEffect theEffect.name)!=0) then
									setActive theEffect true
								else
									setActive theEffect false
							)
						)
						--AtmbackUp
						-------------------------------------------------------------------------------------------------
						if(ep.atmOverride) then
						(

							for i=1 to numAtmospherics  do
							(
								theAtm=getAtmospheric i
								AdjatmBackup[i]=IsActive theAtm
								if((findItem ep.activeAtm theAtm.name)!=0) then
									setActive theAtm true
								else
									setActive theAtm false
							)
						)
						--Envbackup
						-------------------------------------------------------------------------------------------------
						if(ep.backgroundOverride) then
						(
							AdjenvBackup=saveBG()
							backgroundColor=ep.bgColor
							environmentMap=ep.envMap
							useEnvironmentMap=ep.useEnvMap
							lightTintColor=ep.tint
							lightLevel=ep.level
							ambientColor=ep.ambient
						)
						if(ep.exposureOverride) then
						(
							case ep.exposureInt of
							(
								1: SceneExposureControl.exposureControl=undefined
								2: SceneExposureControl.exposureControl=Automatic_Exposure_Control()
								3: SceneExposureControl.exposureControl=Linear_Exposure_Control()
								4: SceneExposureControl.exposureControl=Logarithmic_Exposure_Control()
								5: SceneExposureControl.exposureControl=mr_Photographic_Exposure_Control()
								6: SceneExposureControl.exposureControl=Pseudo_Color_Exposure_Control()
							)
						)

					)


				)


				-------------------------------------------------------------------------------------------------------------------------  envProps Override -----------------------------------------------------------------------


				ep=LPM_Fun.firstChildByType thePass "envProps"
				if(ep!=undefined) and (ep.initialized) and (ep.active) then
				(
					--elements backup
					-------------------------------------------------------------------------------------------------
					if(ep.elementOverride) then
					(
						re.SetElementsActive true
						for i=1 to re.NumRenderElements() do
						(
							theEle=re.GetRenderElement (i-1)
							useVray=hasProperty theEle #vrayVFB

							if((findItem ep.activeElement theEle.elementName)!=0) then
							(
								try
								(
									theEle.enabled=true
								)
								catch ()
								try
								(
									theEle.vrayVFB=true
								)
								catch ()

							)
							else
							(
								try
								(
									theEle.enabled=false
								)
								catch ()
								try
								(
									theEle.vrayVFB=false
								)
								catch ()

							)
						)
					)
					--effectbackUP
					-------------------------------------------------------------------------------------------------
					if(ep.effectOverride) then
					(
							for i=1 to numEffects do
							(
								theEffect=getEffect i
								effectBackup[i]=IsActive theEffect
								if((findItem ep.activeEffect theEffect.name)!=0) then
									setActive theEffect true
								else
									setActive theEffect false
							)
					)
					--AtmbackUp
					-------------------------------------------------------------------------------------------------
					if(ep.atmOverride) then
					(

							for i=1 to numAtmospherics  do
							(
								theAtm=getAtmospheric i
								atmBackup[i]=IsActive theAtm
								if((findItem ep.activeAtm theAtm.name)!=0) then
									setActive theAtm true
								else
									setActive theAtm false
							)
					)
					--Envbackup
					-------------------------------------------------------------------------------------------------
					if(ep.backgroundOverride) then
					(
						envBackup=saveBG()
						backgroundColor=ep.bgColor
						environmentMap=ep.envMap
						useEnvironmentMap=ep.useEnvMap
						lightTintColor=ep.tint
						lightLevel=ep.level
						ambientColor=ep.ambient
					)
					if(ep.exposureOverride) then
					(
						case ep.exposureInt of
						(
							1: SceneExposureControl.exposureControl=undefined
							2: SceneExposureControl.exposureControl=Automatic_Exposure_Control()
							3: SceneExposureControl.exposureControl=Linear_Exposure_Control()
							4: SceneExposureControl.exposureControl=Logarithmic_Exposure_Control()
							5: SceneExposureControl.exposureControl=mr_Photographic_Exposure_Control()
							6: SceneExposureControl.exposureControl=Pseudo_Color_Exposure_Control()
						)
					)
				)


				-------------------------------------------------------------------------------------------------------------------------  Automask Override Adjustment pass  ---------------------------------------------

				try
				(
					if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
					(

						theAdjustmentPass = thePass.AdjustmentFor

						AutoMaskobj = LPM_Fun.firstChildByType thePass "AutoMask"
						AdjAutoMaskobj = LPM_Fun.firstChildByType theAdjustmentPass "AutoMask"

						if not ((isvalidnode AutoMaskobj)and(AutoMaskobj.active)) then
						(
							if(isvalidnode AdjAutoMaskobj)and(AdjAutoMaskobj.active) then
							(
								SetAutomask AdjAutoMaskobj
							)
						)
					)
				)
				catch
				(
				)

				-------------------------------------------------------------------------------------------------------------------------  Automask Override   -----------------------------------------------------------------------


				try
				(
					AutoMaskobj = LPM_Fun.firstChildByType thePass "AutoMask"

					if(isvalidnode AutoMaskobj)and(AutoMaskobj.active) then
					(
						SetAutomask AutoMaskobj
					)
				)
				catch
				(
				)






				---------------------------------------------------------------------------------------------------     Render Elements Path   --------------------------------------------------



				for i=1 to re.NumRenderElements() do
				(

					theEle=re.GetRenderElement (i-1)
					if(isPreviewMode) then
					(
						re.SetRenderElementFilename (i-1) ((getdir #preview) + "\\1.exr")
					)
					else
					(
						if theEle.enabled then
						(
							re.SetRenderElementFilename (i-1) (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot RendPreviewMode:isPreviewMode elementName:("" + theEle.elementname + "") )
						)

					)
				)

				---------------------------------------------------------------------------------------------------     Common props  Prescript Adjustment pass --------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor


					psCP=LPM_fun.firstChildByType  theAdjustmentPass "commonProps"

					if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active) then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.preScript)catch(getcurrentException())
						usePreRendScript = true
						preRendScript = psCp.preScript
					)

					if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.postScript)catch(getcurrentException())
						usePostRendScript = true
						postRendScript  = psCp.postScript
					)

					LPM_Render.execScriptNodes theAdjustmentPass #preRender

				)



				---------------------------------------------------------------------------------------------------     Common props  Prescript

				psCP=LPM_fun.firstChildByType  thePass "commonProps"
				if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active) then
				(
					global LPMData = #(thePass,theShot)
					--try(fileIn psCp.preScript)catch(getcurrentException())
					usePreRendScript = true
					preRendScript = psCp.preScript
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType theShot "commonProps"
					if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.preScript)catch(getcurrentException())
						usePreRendScript = true
						preRendScript = psCp.preScript

					)
				)
				if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
				(
					global LPMData = #(thePass,theShot)
					--try(fileIn psCp.postScript)catch(getcurrentException())
					usePostRendScript = true
					postRendScript  = psCp.postScript
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType  theShot "commonProps"
					if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.postScript)catch(getcurrentException())
						usePostRendScript = true
						postRendScript  = psCp.postScript
					)
				)


				----------------------------------------------------------------------------------------------   xrefScene backup   --------------------------------------------------------------------------------------

				xrefBackArray=#()




				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					xrefSceneProps = LPM_Fun.firstChildByType thePass.AdjustmentFor "xrefScene"

					if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
					(
						--backup the settings
						for i=1 to xrefs.getXRefFileCount() do
						(
							xrefBackArray[i] = (xrefs.getXRefFile i).disabled
						)
					)
				)
				else
				(
					xrefSceneProps = LPM_Fun.firstChildByType thePass "xrefScene"

					if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
					(
						--backup the settings
						for i=1 to xrefs.getXRefFileCount() do
						(
							xrefBackArray[i] = (xrefs.getXRefFile i).disabled
						)
					)
				)

				----------------------------------------------------------------------------------------------   xrefScene Adjustment   ---------------------------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					xrefSceneProps=LPM_Fun.firstChildByType thePass.AdjustmentFor "xrefScene"
					if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
					(
						--set the scenes
						for i=1 to xrefs.getXRefFileCount() do
						(
							theXref=(xrefs.getXRefFile i)
							if((findItem xrefSceneProps.fileNames theXref.fileName)!=0) then
								theXref.disabled=false
							else
								theXref.disabled=true
						)
					)
				)

				----------------------------------------------------------------------------------------------   xrefScene   ----------------------------------------------------------------------------------------------


				xrefSceneProps=LPM_Fun.firstChildByType thePass "xrefScene"
				if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
				(

					--set the scenes
					for i=1 to xrefs.getXRefFileCount() do
					(
						theXref=(xrefs.getXRefFile i)
						if((findItem xrefSceneProps.fileNames theXref.fileName)!=0) then
							theXref.disabled=false
						else
							theXref.disabled=true
					)
				)

				------------------------------------------------------------------------------------------------ final prepare --------------------------------------------------------------------------------

				-- Sends job to renderer dispatch to make any renderer specific last minuet adjustments
				filein (LPM_Dir+"renderer_dispatch.ms")

				-- Old Vray Functionality below, left in for saftey
				-- setVray rendOutputFilename thePass

				rendUseNet=false

				LPM_Render.execScriptNodes thePass #preRender

				format "Pre Processing took: % s\n" ((timeStamp() - preProcTime)/1000.0)

			)
		)

	),






	--RESTORE------------------------------------------------------------------------------------------------------------------------------------------------------------------



	fn fnPostRenderAction thePass theShot=
	(
		ts = timestamp()

		ts_properties = 0
		ts_rpreset = 0

		te_properties = 0
		te_rpreset = 0

		with redraw off
		(
			with animate off
			(

				-------------------------------------------------------------------------------------------------------------------------  postRender script  -----------------------------------------------------------------------
				LPM_Render.execScriptNodes thePass #postRender



				-------------------------------------------------------------------------------------------------------------------------  postRender script Adjustment pass  -----------------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					LPM_Render.execScriptNodes theAdjustmentPass #postRender
				)


				---------------------------------------------------------------------------------------------------     Common props  Postcript   ----------------------------------------------------------------------------------------

				psCP=LPM_fun.firstChildByType  thePass "commonProps"
				if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active) then
				(
					global LPMData = #(thePass,theShot)
					--try(fileIn psCp.preScript)catch(getcurrentException())
					usePreRendScript = commonSettings[29]
					preRendScript  = commonSettings[30]
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType theShot "commonProps"
					if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.preScript)catch(getcurrentException())
						usePreRendScript = commonSettings[29]
						preRendScript  = commonSettings[30]

					)
				)
				if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
				(
					global LPMData = #(thePass,theShot)
					--try(fileIn psCp.postScript)catch(getcurrentException())
					usePostRendScript = commonSettings[31]
					postRendScript  = commonSettings[32]
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType  theShot "commonProps"
					if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						--try(fileIn psCp.postScript)catch(getcurrentException())
						usePostRendScript = commonSettings[31]
						postRendScript  = commonSettings[32]
					)
				)


				--restore objects sets
				-------------------------------------------------------------------------------------------------

				ts_properties = timestamp()

				disablerefmsgs()

				for it in objBackup do
				(
					theNode=it[1]
					theNode.renderable=it[2]
					theNode.castshadows=it[3]
					theNode.receiveshadows=it[4]
					theNode.primaryVisibility=it[5]
					theNode.secondaryVisibility=it[6]
					theNode.motionBlurOn=it[7]
					theNode.renderOccluded=it[8]
					if theNode.material != it[9] then theNode.material=it[9]
					theNode.isHidden=it[10]
					setUserPropBuffer theNode it[11]

				)
				enablerefmsgs()

				-- Dabelow - Added to fix vertexcolor display error, this needs to be ouside the refmsg flags
				for it in objBackup do
				(
					theNode=it[1]
					theNode.boxmode = on
					theNode.boxmode = off
				)

-- 				redrawviews()
-- 				print "WTF"
				te_properties = timestamp()

				--restore light sets
				-------------------------------------------------------------------------------------------------

				for it in lightBackup do
				(
					theNode=it[1]
					try
					(
						theNode.on=it[2]
						--theNode.isHidden=not(it[2])
					)
					catch()

					try
					(
						theNode.isHidden = it[20]
					)
					catch()

					try
					(
						theNode.enabled = it[21]
					)
					catch()


					-----------    vray part

					try
					(
						theNode.baseObject.multiplier=it[3]
					)
					catch()

					try
					(
						theNode.color=it[4]
					)
					catch()

					try
					(
						theNode.baseObject.castShadows=it[5]
					)

					catch()

					try
					(
						theNode.baseObject.affect_diffuse=it[6]
					)
					catch()

					try
					(
						theNode.baseObject.affect_specualr=it[7]
					)
					catch()

					try
					(
						theNode.baseObject.affect_reflections=it[8]
					)
					catch()

					try
					(
						theNode.baseObject.texmap_on=it[18]
					)
					catch()

					try
					(
						theNode.baseObject.texmap=it[9]
					)
					catch()


					-----------    corona part


					try
					(
						theNode.baseObject.intensity=it[10]
					)
					catch()

					try
					(
						theNode.baseObject.castsShadows=it[13]
					)

					catch()

					try
					(
						theNode.baseObject.visibleDirectly=it[11]
					)
					catch()

					try
					(
						theNode.baseObject.visibleRefl=it[12]
					)
					catch()

					try
					(
						theNode.baseObject.colorMode=it[19]
					)
					catch()


					-----------    default part

					try
					(
						theNode.baseObject.affectDiffuse=it[14]
					)
					catch()

					try
					(
						theNode.baseObject.affectSpecular=it[15]
					)
					catch()

					try
					(
						theNode.baseObject.projectorMap=it[16]
					)
					catch()

					try
					(
						theNode.baseObject.projector=it[17]
					)
					catch()

				)




				--Generic Nodes
				genericNodes=for child in thePass.children where child.type=="generic" do
				(
					op=LPM_Operators.fngetByNode child
					if(op!=0) then
						op.fnPerformAction #postRender
				)

				--applyAtmospherics restore
				for it in applyAtmosphericsBackup do
				(
					theNode=it[1]
					theNode.applyAtmospherics=it[2]
				)



				------------------------------------------------------------------------------------------------------   AutoMask restore ---------------------------------------------------------------------------------

				try
				(
					AutoMaskobj = LPM_Fun.firstChildByType thePass "AutoMask"


					theAdjustmentPass = undefined
					AdjAutoMaskobj = undefined

					if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
					(
						theAdjustmentPass = thePass.AdjustmentFor
						AdjAutoMaskobj = LPM_Fun.firstChildByType theAdjustmentPass "AutoMask"
					)

					if ((isvalidnode AutoMaskobj)and(AutoMaskobj.active)) or ((isvalidnode AdjAutoMaskobj)and(AdjAutoMaskobj.active)) then
					(
						vr=renderers.current
						theRenderer=(classof vr) as string

						if (findString theRenderer "V_Ray" !=undefined) or (findString theRenderer "Corona" !=undefined) then
						(
							REManager = maxOps.GetCurRenderElementMgr()
							REcount = REManager.NumRenderElements()

							if elementBackup.count < REcount then
							(
								TmpDelta = (REcount - elementBackup.count)

								for i = 1 to TmpDelta do
								(
									j = TmpDelta - i + 1
									tmpEle = REManager.GetRenderElement (elementBackup.count + j - 1)
									REManager.RemoveRenderElement tmpEle
								)

							)
						)

					)
				)
				catch
				(

				)


				--exposure restore
				-------------------------------------------------------------------------------------------------
				SceneExposureControl.exposureControl=exposureBackup



				re = maxOps.GetCurRenderElementMgr()
				for i=1 to re.NumRenderElements() do
				(
					theEle=re.GetRenderElement (i-1)

					try
					(
						theEle.enabled=elementBackup[i][1]
					)
					catch()
					try
					(

						theEle.vrayVFB=elementVrayBackup[i]
					)
					catch()
					/*
					if(hasProperty theEle #vrayVFB) then
						theEle.vrayVFB=elementBackup[i][1]
					else
						theEle.enabled=elementBackup[i][1]
					if(elementBackUp[i][2]!=undefined) then
						re.SetRenderElementFilename (i-1) elementBackup[i][2]
					 */
				)





				-------------------------------------------------------------------------------------------------------------------------  Modifiers Override -----------------------------------------------------------------------


				tmp_Mod_obj_counter = 0

				ModifierOverNodes=for child in thePass.children where child.type=="ModifierOver" and(child.active==true) do
				(

					myObject = child.activeNode


					if(isvalidnode myObject) then
					(
						tmp_Mod_obj_counter += 1

						tmp_Mod_counter = 0
						for modi in myObject.modifiers do
						(
							tmp_Mod_counter += 1
							modi.enabled = ModifierBack[tmp_Mod_obj_counter][tmp_Mod_counter]
						)
					)



				)



				-------------------------------------------------------------------------------------------------------------------------  Modifiers Override Adjustment pass  -----------------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					tmp_Mod_obj_counter = 0

					ModifierOverNodes=for child in theAdjustmentPass.children where child.type=="ModifierOver" and(child.active==true) do
					(

						myObject = child.activeNode


						if(isvalidnode myObject) then
						(
							tmp_Mod_obj_counter += 1

							tmp_Mod_counter = 0
							for modi in myObject.modifiers do
							(
								tmp_Mod_counter += 1
								modi.enabled = AdjModifierBack[tmp_Mod_obj_counter][tmp_Mod_counter]
							)
						)

					)

				)




				----------------------------------------------------------------------------------------------- V-Ray Global Illumination Restore -------------------------------------------------------------------------------------------



				try
				(
					VRayGIObj=LPM_Fun.firstChildByType thePass "VRayGI"

					if(isvalidnode VRayGIObj)and(VRayGIObj.active) then
					(
						vr=renderers.current
						theRenderer=(classof vr) as string


						if (findString theRenderer "V_Ray" !=undefined) then
						(
							vr.gi_on = VRayGIBack[1]
							vr.adv_irradmap_mode = VRayGIBack[2]
							try
							(
								vr.adv_irradmap_loadFileName = VRayGIBack[3]
							)
							catch
							(
								vr.adv_irradmap_loadFileName = ""
							)

							try
							(
								vr.adv_irradmap_saveFileName = VRayGIBack[4]
							)
							catch
							(
								vr.adv_irradmap_saveFileName = ""
							)

							vr.adv_irradmap_autoSave = VRayGIBack[5]

							try
							(
								vr.adv_irradmap_autoSaveFileName = VRayGIBack[6]
							)
							catch
							(
								vr.adv_irradmap_autoSaveFileName = ""
							)

							vr.gi_irradmap_multipleViews = VRayGIBack[7]

							vr.lightcache_mode = VRayGIBack[8]

							try
							(
								vr.lightcache_loadFileName = VRayGIBack[9]
							)
							catch
							(
								vr.lightcache_loadFileName = ""
							)

							try
							(
								vr.lightcache_saveFileName = VRayGIBack[10]
							)
							catch
							(
								vr.lightcache_saveFileName = ""
							)
							try
							(
								vr.lightcache_autosaveFileName = VRayGIBack[14]
							)
							catch
							(
								vr.lightcache_autosaveFileName = ""
							)

							vr.lightcache_autoSave = VRayGIBack[11]
							vr.lightcache_multipleViews = VRayGIBack[12]

							vr.options_dontRenderImage = VRayGIBack[13]
						)
					)
				)
				catch
				(
				)



				---------------------------------------------------------------------------------------------------     V-Ray Global Illumination Adjustment pass Restore -----------------------------------------------------------------

				try
				(
					if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
					(
						theAdjustmentPass = thePass.AdjustmentFor

						AbjVRayGIObj=LPM_Fun.firstChildByType theAdjustmentPass "VRayGI"

						if(isvalidnode AbjVRayGIObj)and(AbjVRayGIObj.active) then
						(
							vr=renderers.current
							theRenderer=(classof vr) as string

							if (findString theRenderer "V_Ray" !=undefined) then
							(
								if AdjVRayGIBack.count >1 then
								(
									vr.gi_on = AdjVRayGIBack[1]
									vr.adv_irradmap_mode = AdjVRayGIBack[2]
									try
									(
										vr.adv_irradmap_loadFileName = AdjVRayGIBack[3]
									)
									catch
									(
										vr.adv_irradmap_loadFileName = ""
									)

									try
									(
										vr.adv_irradmap_saveFileName = AdjVRayGIBack[4]
									)
									catch
									(
										vr.adv_irradmap_saveFileName = ""
									)

									vr.adv_irradmap_autoSave = AdjVRayGIBack[5]
									try
									(
										vr.adv_irradmap_autoSaveFileName = AdjVRayGIBack[6]
									)
									catch
									(
										vr.adv_irradmap_autoSaveFileName = ""
									)

									vr.gi_irradmap_multipleViews = AdjVRayGIBack[7]

									vr.lightcache_mode = AdjVRayGIBack[8]
									try
									(
										vr.lightcache_loadFileName = AdjVRayGIBack[9]
									)
									catch
									(
										vr.lightcache_loadFileName = ""
									)

									try
									(
										vr.lightcache_saveFileName = AdjVRayGIBack[10]
									)
									catch
									(
										vr.lightcache_saveFileName = ""
									)

									try
									(
										vr.lightcache_autosaveFileName = AdjVRayGIBack[14]
									)
									catch
									(
										vr.lightcache_autosaveFileName = ""
									)


									vr.lightcache_autoSave = AdjVRayGIBack[11]
									vr.lightcache_multipleViews = AdjVRayGIBack[12]

									vr.options_dontRenderImage = AdjVRayGIBack[13]
								)

							)
						)
					)
				)
				catch
				(
				)



				--DistributedRender Restore
				-------------------------------------------------------------------------------------------------

				try
				(
					if LPM_Root.DistributedRender then
					(
						vr=renderers.current
						LocalDistributedRender = LPM_Fun.getIni "Settings" "UseDistributedRendering" booleanClass true


						theRenderer=(classof vr) as string
						useRend=0

						if (findString theRenderer "V_Ray" !=undefined) then
							useRend=1
						if(findstring theRenderer "Corona"!=undefined) then
							useRend=2



						case useRend of
						(
							1:
							(

								if  DistributedRenderBack != 0 then
								(
									vr.system_distributedRender = DistributedRenderBack
								)
							)
							2:
							(
								if  DistributedRenderBack != 0 then
								(
									vr.dr_enable = DistributedRenderBack
								)
							)
						)
					)
				)
				catch
				(

				)

				---------------------------------------------------------------------------------------------------     HideRFW  SkipExistingImages restore  -----------------------------------------------------------------


				try
				(
					if HideRFWBack != 0 then
					(
						rendShowVFB = HideRFWBack
					)

					if SkipExistingImagesBack != 0 then
					(
						skipRenderedFrames = SkipExistingImagesBack
					)
				)
				catch
				(
				)



				-------------------------------------------------------------------------------------------------------------------------  envProps Override restore -----------------------------------------------------------------------


				ep=LPM_Fun.firstChildByType thePass "envProps"
				if(ep!=undefined) and (ep.initialized) and (ep.active) then
				(
					--effect Restore
					-------------------------------------------------------------------------------------------------
					if(ep.effectOverride) then
					(
						for i=1 to numEffects do
						(
							theEffect=getEffect i
							setActive theEffect effectBackup[i]
						)
					)

					--Atm Restore
					-------------------------------------------------------------------------------------------------
					if(ep.atmOverride) then
					(
						for i=1 to numAtmospherics  do
						(
							theAtm=getAtmospheric i
							setActive theAtm atmBackup[i]
						)

					)
					if(ep.backgroundOverride) then
					(
						backgroundColor=envBackup[1]
						useEnvironmentMap=envBackup[2]
						environmentMap=envBackup[3]
						lightTintColor=envBackup[4]
						lightLevel=envBackup[5]
						ambientColor=envBackup[6]
					)

				)



				-------------------------------------------------------------------------------------------------------------------------  envProps Override Adjustment pass restore -----------------------------------------------------------------------


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					ep = undefined
					ep=LPM_Fun.firstChildByType theAdjustmentPass "envProps"
					if(ep!=undefined) and (ep.initialized) and (ep.active) then
					(
						--effect Restore
						-------------------------------------------------------------------------------------------------
						if(ep.effectOverride) then
						(
							for i=1 to numEffects do
							(
								theEffect=getEffect i
								setActive theEffect AdjeffectBackup[i]
							)
						)

						--Atm Restore
						-------------------------------------------------------------------------------------------------
						if(ep.atmOverride) then
						(
							for i=1 to numAtmospherics  do
							(
								theAtm=getAtmospheric i
								setActive theAtm AdjatmBackup[i]
							)

						)
						if(ep.backgroundOverride) then
						(
							backgroundColor=AdjenvBackup[1]
							useEnvironmentMap=AdjenvBackup[2]
							environmentMap=AdjenvBackup[3]
							lightTintColor=AdjenvBackup[4]
							lightLevel=AdjenvBackup[5]
							ambientColor=AdjenvBackup[6]
						)

					)
				)



				--------------------------------------------------------------------------------------------------------------------------- xref scenes restore
				if xrefBackArray != #() then--(isvalidnode xrefSceneProps) then
				(
					--backup the settings
					for i=1 to xrefBackArray.count do
					(
						 (xrefs.getXRefFile i).disabled=xrefBackArray[i]
					)
				)

				----------------------------------------------------------------------------------------------   xrefObjects   ----------------------------------------------------------------------------------------------

				--xrefObjProps=LPM_Fun.firstChildByType thePass "xrefObj"

				if xrefObjBackArray != #() then--(isvalidnode xrefObjProps) then
				(
					--backup the settings
					for i=1 to xrefObjBackArray.count do
					(
						 (objXRefMgr.GetRecord i).enabled=xrefObjBackArray[i]
					)

				)




				-------------------------------------------------------------------------------------------------------------------------  RenderSettings Override restore -----------------------------------------------------------------------

				ts_rpreset = timestamp()

				if(preRenderSettingsNew!=undefined) then
				(
					try
					(
						vr = renderers.current
						--cls=r.classid
						--if (cls[1]==1941615238 and cls[2]==2012806412) then r.showLastVFB()


						theRenderer=(classof vr) as string


						if ((findString theRenderer "V_Ray") != undefined) then
						(
							if vr.output_on then
							(
								vr.showLastVFB()
							)

						)
					)
					catch
					(
					)


					LPM_Fun.loadRenderPresetNew preRenderSettingsNew

				)

				if(preRenderSettings!=undefined)and(preRenderSettings!=0) then
				(

					LPM_Fun.loadRenderPreset preRenderSettings

				)





				-------------------------------------------------------------------------------------------------------------------------  RenderSettings Override Adjustment pass restore -----------------------------------------------------------------------

				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor


					if(AdjpreRenderSettingsNew!=undefined) then
					(
						try
						(
							vr = renderers.current
							--cls=r.classid
							--if (cls[1]==1941615238 and cls[2]==2012806412) then r.showLastVFB()


							theRenderer=(classof vr) as string


							if ((findString theRenderer "V_Ray") != undefined) then
							(
								if vr.output_on  then
								(
									vr.showLastVFB()
								)

							)
						)
						catch
						(
						)


						LPM_Fun.loadRenderPresetNew AdjpreRenderSettingsNew

					)

					if(AdjpreRenderSettings!=undefined)and(AdjpreRenderSettings!=0) then
					(

						LPM_Fun.loadRenderPreset AdjpreRenderSettings

					)
				)

				te_rpreset = timestamp()


				try
				(
					if vrfrbufBackup != 0 then
					(
						vr=renderers.current
						vr.output_on = vrfrbufBackup
					)

				)
				catch
				(

				)

				--restore common settings
				-------------------------------------------------------------------------------------------------
				rendTimeType=commonSettings[1]
				rendNThFrame=commonSettings[2]
				rendStart=commonSettings[3]
				rendEnd=commonSettings[4]
				rendFileNumberBase=commonSettings[5]
				rendPickupFrames=commonSettings[6]
				renderHeight=commonSettings[7]
				renderWidth=commonSettings[8]
				setRendApertureWidth commonSettings[9]
				renderPixelAspect=commonSettings[10]
				rendAtmosphere=commonSettings[11]
				renderEffects=commonSettings[12]
				renderDisplacements=commonSettings[13]
				rendColorCheck=commonSettings[14]
				rendFieldRender=commonSettings[15]
				rendHidden=commonSettings[16]
				rendSimplifyAreaLights=commonSettings[17]
				rendForce2Side=commonSettings[18]
				rendSuperBlack=commonSettings[19]
				RadiosityPreferences.useAdvancedLighting=commonSettings[20]
				RadiosityPreferences.computeAdvancedLighting=commonSettings[21]
				rendSaveFile=commonSettings[22]
				rendOutputFileName=commonSettings[23]
				skipRenderedFrames=commonSettings[24]
				rendUseNet=commonSettings[25]
				if(setRenderType!=undefined) then
					setRenderType commonSettings[26]
				fileOutGamma	=commonSettings[27]
				displayGamma=commonSettings[28]
				--restore viewport
				if(viewPortCamBack!=undefined) then
					viewport.setCamera viewportCamBack
				else
					viewport.setType viewportTypeBack


				if thePass.isAdjustment and (thePass.AdjustmentFor != undefined) then
				(
					theAdjustmentPass = thePass.AdjustmentFor

					LPM_Render.execScriptNodes theAdjustmentPass #postLPM
				)

				LPM_Render.execScriptNodes thePass #postLPM

				try
				(
					LPM_Root.PostRenderFrameScript = false
					LPM_Root.PostRenderFrameScriptText = ""
				)
				catch
				(
				)


				LPM_Root.PostConvertVrimg2exr = LPM_Fun.getIni "Settings" "PostConvertVrimg2exr" string "C:\\Program Files\\Chaos Group\\V-Ray\\3dsmax 2014 for x64\\tools\\vrimg2exr.exe"

				LPM_Root.PostConvert = false
				LPM_Root.PostConvertCompression = 3
				LPM_Root.PostConvertHalfFoat = false
				LPM_Root.PostConvertDatawindow = false

			)
		)


		propString = "object properties: " + ((te_properties-ts_properties)/1000.0) as string + "s"
		presetString = "renderer properties: " + ((te_rpreset-ts_rpreset)/1000.0) as string + "s"
		totalString = "total: " + ((timestamp()-ts)/1000.0) as string + "s"

		--print ("LPM post-render cleanup -- " + totalString + " | " + propString + " | " + presetString)
	)
)

fn LPM_hardwareRender thePass theShot:undefined=
(
	--create the floater
	LPM_Fun.init_LPM_renderProgress_Ro thePass theShot
	LPM_treeview_rollout.hideByPass thePass


	thePath=LPM_Fun.getPassPath LPM_Root thePass theShot:theShot RendPreviewMode:false elementName:""

	theFileName = (getFilenameFile thePath)

	thePath = getFilenamePath thePath
	thePath = substring thePath 1 (thePath.count-1)

	theType=LPM_Fun.uppercase(LPM_Root.fileType)

	_renderHeight=renderHeight
	_renderWidth=renderWidth
	_rendTimeType=rendTimeType
	_rendNThFrame=rendNThFrame
	_rendStart=rendStart
	_rendEnd=rendEnd
	_rendFileNumberBase=rendFileNumberBase
	_rendPickupFrames=rendPickupFrames

	flagContinue=true

	if(isvalidNode LPM_Root.renderCamera) then
		viewport.setCamera LPM_Root.renderCamera

	--for the pass
	cp=LPM_Fun.firstChildByType thePass "commonProps"
	if(cp!=undefined) and (cp.initialized) then
	(
		if(cp.timeOutputTgl) then
		(
			_rendTimeType=cp._rendTimeType
			_rendNThFrame=cp._rendNThFrame
			_rendStart=cp._rendStart
			_rendEnd=cp._rendEnd
			_rendFileNumberBase=cp._rendFileNumberBase
			_rendPickupFrames=cp._rendPickupFrames
		)
		if(cp.outputSizeTgl) then
		(
			_renderHeight=cp._renderHeight
			_renderWidth=cp._renderWidth
		)
		if(cp.cameraTgl) then
		(
			try(viewport.setCamera cp._Camera)catch()
		)
	)

	--for the shot
	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.initialized) then
		(
			if(cp.timeOutputTgl) then
			(
				_rendTimeType=cp._rendTimeType
				_rendNThFrame=cp._rendNThFrame
				_rendStart=cp._rendStart
				_rendEnd=cp._rendEnd
				_rendFileNumberBase=cp._rendFileNumberBase
				_rendPickupFrames=cp._rendPickupFrames
			)
			if(cp.outputSizeTgl) then
			(
				_renderHeight=cp._renderHeight
				_renderWidth=cp._renderWidth
			)
			if(cp.cameraTgl) then
			(
				try(viewport.setCamera cp._Camera)catch()
			)
		)
	)

	timesArray=#()
	case _rendTimeType of
	(
		1:
		(
			timesArray[1]=sliderTime
		)
		2:
		(
			timesArray=for i=animationRange.start to animationRange.end  by _rendNThFrame collect i
		)
		3:
		(
			timesArray=for i=_rendStart to _rendEnd by _rendNthFrame collect i
		)
		4:
		(
			tmpArray=LPM_Fun.stringToFrames _rendPickupFrames
			if(tmpArray==undefined) then
				flagContinue=false
			else
			(

				for it in tmpArray do
				(
					if(it.count ==1) then
						append timesArray (it[1] as time)
					else
						timesArray=timesArray + (for i=it[1] to it[2] collect (i as time))
				)
			)
		)
	)

	if(flagContinue==false) then
		Messagebox ((LPM_Fun.getname thePass.name) + " has an incorrectly formatted frame sequence")
	else
	(
		sliderTimeBack = sliderTime
		safeFrameBack=displaySafeFrames
		animationRangeBack = animationRange
		displaySafeFrames=false
		startTime=amin timesArray
		endTime= amax timesArray
		if(startTime < endTime) then
			animationRange= (interval startTime endTime)


		movieMode=false
		theType=LPM_Fun.upperCase theType
		if(theType=="MOV") or (theType=="AVI") then
			movieMode=true

		flag=true
		if(theShot!=undefined) then
			progressStart ("S:" +(LPM_fun.getName theShot.name) + " P: "+(LPM_fun.getName thePass.name))
		else
			progressStart ("P: "+(LPM_fun.getName thePass.name))

		try
		(
			createPreview outputAVI:true percentSize:100 rndLevel:#smoothhighlights start:startTime end:endTime
		)
		catch
		(
			createPreview()
		)

		CurCamName = ""

		if(theShot!=undefined) then
		(
			try
			(
				CurCamName = LPM_Fun.getName theShot.name
			)
			catch()
			CurCamName += "_"
		)

		TmpOneFolder = LPM_Fun.getIni "Settings" "OnePreviewFolder" booleanClass false

		if TmpOneFolder then
		(
			thePath = ""
			thePath = copy LPM_Root.rootdir
		)

		local fileToCopy = (getdir #preview) + "\\_scene.avi"
		local fileToSave =  ( thePath) + "\\previews\\" + theFileName + CurCamName + "001.avi"


		for i = 1 to 1000 while (doesfileexist fileToSave) do
		(
			TmpI_AsStr = i as string
			tmp_numb = case TmpI_AsStr.count of
			(
				1:
				(
					"00"+TmpI_AsStr
				)
				2:
				(
					"0"+TmpI_AsStr
				)
				default:
				(
					TmpI_AsStr
				)
			)
			fileToSave =  (thePath) + "\\previews\\" + theFileName + CurCamName + tmp_numb +".avi"
		)



		makedir (getFilenamePath fileToSave)
		copyFile fileToCopy fileToSave
		progressEnd()
		gc light:true

		displaySafeFrames=safeFrameBack
		animationRange = animationRangeBack
		sliderTime = sliderTimeBack
	)
	try (destroydialog LPM_renderProgress_Ro ) catch()
)
LPM_Render=LPM_RenderAPI()


fn LPM_renderPass thePass renderType theShot:undefined=
(
	if( maxOps.GetCurRenderElementMgr()==undefined) then
	(
		messagebox "Please disable active shade and enable production renderer." title:"Warning!"
	)
	else
	(
		--renderscenedialog.close()

		RndDialogOpened = false
		if renderSceneDialog.isopen() then
		(
			RndDialogOpened = true
			renderSceneDialog.close()
		)



		TmpPassName = LPM_Fun.generatePassName thePass


		-- let's use getLocalTime if available (since 2008 or with AVG)
		if ( classOf getLocalTime == MAXScriptFunction ) then
			startTime = getLocalTime()
		else
			startTime = timeStamp()

		LPM_Fun.init_LPM_renderProgress_Ro thePass theShot
		if(isvalidnode theShot) then
			format "===== S:% P:% =====\n"  (LPM_Fun.getName theShot.name) (TmpPassName)
		else format "===== P:% =====\n" (TmpPassName)

		--Pre render action
		isPreviewMode=((renderType==#preview)or(renderType==#previewHalf))
		LPM_Render.fnPreRenderAction thePass theShot isPreviewMode:isPreviewMode

		--Set settings based on render type
		-------------------------------------------------------------------------------------------------

		if(isPreviewMode) then
		(
			rendOutputFilename=LPM_Fun.getPreviewFile thePass
			LPM_Render.setVray rendOutputFilename thePass
			makeDir ((getDir #preview)+"\\"+maxFileName+"_"+"\\") all:true
			deleteFile rendOutputFilename
			rendTimeType=1
			rendUseNet=false

			if(renderType==#previewHalf) then
			(
				renderHeight=(renderHeight * (LPM_Root.previewSize as float) /100.0)
				renderWidth=(renderWidth * (LPM_Root.previewSize as float) / 100.0)
			)
		)

		if(renderType==#local) then
		(
			SetQuietMode LPM_Root.quietMode
		)

		--And go!!
		with defaultAction #logmsg
		(
			max quick render
		)

		SetQuietMode false

		LPM_Render.fnPostRenderAction thePass theShot

		if ( classOf getLocalTime == MAXScriptFunction ) then
		(
			endTime = getLocalTime()
			timeDifference = (getTimeDifference startTime endTime)
			hours = timeDifference[4]*24 + timeDifference[5]
			mins = timeDifference[6]
			secs = timeDifference[7]
		) else (
			endTime = timeStamp()
			secs=((endTime - startTime) / 1000.0)
			mins=(secs / 60) as integer
			hours = (secs / 3600) as integer
			secs=mod secs 60
		)




		if(isvalidnode theShot) then
		(
			if (hours > 0) then
				format "RenderTime: % Hours % Mins Shot:% Pass:% type:% \n"  hours mins (LPM_Fun.getName theShot.name) (TmpPassName) (renderType as string)
			else
				format "RenderTime: % Mins % Secs Shot:% Pass:% type:% \n"  mins secs (LPM_Fun.getName theShot.name) (TmpPassName) (renderType as string)
		) else (
			if (hours > 0) then
				format "RenderTime: % Hours % Mins Pass:% type:%\n" hours mins (TmpPassName)(renderType as string)
			else
				format "RenderTime: % Mins % Secs Pass:% type:%\n" mins secs (TmpPassName)(renderType as string)
		)

		try(destroyDialog LPM_renderProgress_Ro)catch()

		--update the compositor and the last 10 renders
		if(renderType==#preview or renderType==#previewHalf) then
		(	if(LPM_Compositor!=undefined) then
				if(LPM_Compositor.open) then
					LPM_Compositor.refresh()
			makedir ((getDir #preview)+"\\"+maxFileName+"_"+"\\Revisions\\")

			y=copy localtime
			for i=1 to y.count where y[i]=="/" or y[i]==":" or y[i]==" " do y[i]="_"
			renderFile=LPM_Fun.getPreviewFile thePass;
			newFile=(getfilenamepath renderFile+"Revisions\\")+(getfilenameFile renderFile )+y+(getfilenametype renderFile)
			try(copyfile renderFile newFile)catch();
		)

		if RndDialogOpened then
		(
			renderSceneDialog.open()
		)

	)
)

