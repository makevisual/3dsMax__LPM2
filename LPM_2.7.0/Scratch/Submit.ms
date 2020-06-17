function submit_action
(
-- 	log_append "Beginning Submission." 2
-- 	ts = timeStamp()
-- 	submit_preAction()

	try
	(
-- 		renderSceneDialog.close()
-- 		saveSettings()
		
-- 		if SMTDSettings.RebuildRenderElements do
-- 		(
-- 			print "Rebuilding Render Elements"
-- 			SMTDFunctions.RebuildRenderElements()
-- 		)

-- 		if chk_overrideFrameRange.checked 
-- 		then 
-- 		(
-- 			-- TODO: use SMTDtempSettings
-- 			rendStartHold = rendStart
-- 			rendEndHoild = rendEnd
-- 		)
-- 		else()

-- 		local reMgr = maxOps.getCurRenderElementMgr()
-- 		stickyElementsActive = reMgr.GetElementsActive()

-- 		if chk_elementsActive.checked
-- 		then(
-- 			reMgr.SetElementsActive true				
-- 		) 
-- 		else(
-- 			reMgr.SetElementsActive false				
-- 		)

-- 		prg_submitProgress.value = 0

		renderCollect = LPM_Fun.getWhoToRender()
		flag=true
		for i=1 to renderCollect.count where flag do
		(
			SMTDLPMInterface.prg_submitProgress2.value=5

			ts2 = timestamp()
			prg_submitProgress.value = (100*(i-1))/renderCollect.count
			submission_report = ("Submitting Pass - " + (LPM_Fun.getName renderCollect[i][1].name) +"  ( " + (i as string) + " of "+ (renderCollect.count as string) + " )" )
			log_append submission_report 4


			--Pre render action
			SMTDLPMInterface.prg_submitProgress2.value=10

			LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
			thePass=renderCollect[i][1]
			theShot=renderCollect[i][2]

			SMTDLPMInterface.prg_submitProgress2.value=20

			-- Set the framerange if chosen 
-- 			if chk_overrideFrameRange.checked 
-- 			then 
-- 			(
-- 				rendStart = spn_overrideFrameRange1.value
-- 				rendEnd = spn_overrideFrameRange2.value
-- 			)
-- 			else()
				
			-- Prepare Deadline Job
			try
			(
				TmpPass = renderCollect[i][1]
				TmpPassName = (LPM_Fun.getName TmpPass.name)
				
				if TmpPass.isAdjustment and (TmpPass.AdjustmentFor != undefined) then
				(
					TmpPassName = "["+(LPM_Fun.getName (TmpPass.AdjustmentFor.name)) + "]" + TmpPassName
				)
				
				if (theShot==undefined) then 
				(
					SMTDSettings.JobName = ( (getfilenamefile (maxfilename)) + " | P: "+TmpPassName)
				)
				else
				(
					SMTDSettings.JobName = ( (getfilenamefile (maxfilename)) + " | Sh: "+(LPM_Fun.getName renderCollect[i][2].name)+" | P: "+TmpPassName)
				)

-- 				SMTDSettings.Comment = lab_CustomCommentField.text
-- 				SMTDSettings.UserName = SMTDFunctions.GetDeadlineUser()

-- 				SMTDSettings.StartJobTimeoutEnabled = chk_autoStartupTimeout.checked
-- 				SMTDSettings.StartJobTimeoutSeconds = ( spn_autoStartupTimeout.value as string )

				-- Autodraft Stuff
-- 				AutodraftEnabledVal = "False"
-- 				AutodraftUploadVal 	= "False"

-- 				if chk_autodraft.checked
-- 				then ( AutodraftEnabledVal = "True" )

-- 				if chk_autodraftUpload.checked
-- 				then ( AutodraftUploadVal = "True" )

-- 				SMTDSettings.ExtraInfoKeyValues = #( #( "AutoDraftEnabled", AutodraftEnabledVal ), #( "AutoDraftUpload", AutodraftUploadVal ) )

-- 				SMTDSettings.group = ddl_group.selected
				
				-- Deadline LPM override stuff
				stickySMTDSettings = copy SMTDSettings

				if LPM_SMTDSettings.active then 
				(
					-- Priority Override
					if LPM_SMTDSettings.priorityOn then 
					(
						-- Priority Offset
						if LPM_SMTDSettings.priorityOffsetOn then 
						(
							newPriority = ( SMTDSettings.Priority + LPM_SMTDSettings.priorityOffset )
							if newPriority > 99 then newPriority = 99
							if newPriority < 1 then newPriority = 1

							SMTDSettings.Priority = newPriority
						)

						-- Priority Absolute
						if LPM_SMTDSettings.priorityAbsoluteOn then 
						(
							newPriority = ( LPM_SMTDSettings.priorityAbsolute )
							if newPriority > 99 then newPriority = 99
							if newPriority < 1 then newPriority = 1

							SMTDSettings.Priority = newPriority
						)
					)

					if LPM_SMTDSettings.taskSizeOn then 
					(
						SMTDSettings.ChunkSize = LPM_SMTDSettings.taskSize
					)

					if LPM_SMTDSettings.submitGroupOn then 
					(
						SMTDSettings.group = LPM_SMTDSettings.submitGroup
					)
					
					if LPM_SMTDSettings.submitLimitsOn then 
					(
						SMTDSettings.LimitGroupsToUse = LPM_SMTDSettings.submitLimits
					)
				)
			)
			catch
			(
				submit_fail()
			)

			SMTDLPMInterface.prg_submitProgress2.value=30

			-- Submit Deadline Job
			local result = SMTDFunctions.SubmitJob()
			
			if result != #success do
			(
				flag = false
				messagebox ("Error while submitting to Deadline (error code: "+result+")")
			)

			SMTDLPMInterface.prg_submitProgress2.value=80

			SMTDSettings = stickySMTDSettings 					-- Put SMTDsettings back to normal
			reMgr.SetElementsActive stickyElementsActive 		-- Put render elements settings back to normal
			if chk_overrideFrameRange.checked 
			then 
			(
				-- TODO: use SMTDtempSettings
				rendStartHold = rendStart
				rendEndHoild = rendEnd
			)
			else()

			log_append "Restoring Scene to pre submission state..." 4

			LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
			if(keyboard.escPressed) then flag=false

			SMTDLPMInterface.prg_submitProgress2.value=100
			log_append  ("time (s) " +((timeStamp() - ts2)/1000.000) as string ) 4
		)
		
			try(
				grp_submit.text = "Submit"

				case flag of 
				(
					true: ( log_append "Submission complete!" 2 )
					false: ( log_append "Submission Stopped!" 3 )
				)

				prg_submitProgress.value = 100
				log_append ( "Total running time (s): " + ( (timeStamp() - ts ) / 1000.000 ) as string ) 4
			
			sleep 1.25

				if chk_closeOnComplete.checked == true 
				then ( destroydialog LPM_DeadlineSubmitRo )
				else ( prg_submitProgress.visible = false )

			)catch()

		try(destroydialog LPM_DeadlineSubmitRo)catch()

			submit_postAction()

	)
	catch
	(
		submit_fail()
	)
)