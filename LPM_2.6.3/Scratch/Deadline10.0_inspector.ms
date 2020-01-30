fn SMTDSettingsJobInspect =
(
	-- Custom
	SMTDSettings.JobName 					= LPM_deadlineInfo.dl_jobName
	SMTDSettings.UserName 					= LPM_deadlineInfo.dl_user
	SMTDSettings.Comment  					= LPM_deadlineInfo.dl_jobComment
	SMTDSettings.group 						= LPM_deadlineInfo.dl_groupChosen
	SMTDSettings.LimitGroupsToUse 			= LPM_deadlineInfo.dl_limitsChosen
	SMTDSettings.SubmitAsSuspended 			= LPM_deadlineInfo.sticky_submitAsSuspended
	SMTDSettings.JobIsInterruptible 		= LPM_deadlineInfo.dl_interruptible
	SMTDSettings.TaskTimeoutEnabled 		= LPM_deadlineInfo.dl_taskTimeoutEnabled
	SMTDSettings.TaskTimeout		 		= LPM_deadlineInfo.dl_taskTimeoutSeconds
	SMTDSettings.DraftTemplate 				= LPM_deadlineInfo.draft_templateChosen


	-- Default
	SMTDSettings.SubmitExternalFilesMode 
	SMTDSettings.IgnoreMissingExternalFiles
	SMTDSettings.IgnoreMissingDLLs
	SMTDSettings.RestartMax 		

	-- Stamdalone
	 	-- if
		LPM_deadlineInfo.framerange_overrideEnabled		-- Completed
		LPM_deadlineInfo.framerange_overrideRange		-- Completed

	 	-- if
		LPM_deadlineInfo.sticky_frameBufferMode

		-- if
		LPM_deadlineInfo.sticky_renderElementsExr

		-- HOLD


	clearlistener()

	print "[ JOB NAME ]"
	print SMTDSettings.JobName

	print "[ JOB COMMENT ]"
	print SMTDSettings.Comment 

	print "[ JOB USERNAME ]"
	print SMTDSettings.UserName

	print "[ JOB BATCH ]"
	print LPM_deadlineInfo.dl_batchName --Bootstrapped

	print "[ PRIORITY ]"
	print SMTDSettings.Priority

	print "[ GROUP ]"
	print SMTDSettings.group 

	print "[ LIMITS ]"
	print SMTDSettings.LimitGroupsToUse

	print "[ SUSPENDED ]"
	print SMTDSettings.SubmitAsSuspended

	print "[ OVERRIDE FRAMERANGE ]"
	print LPM_deadlineInfo.framerange_overrideEnabled  	-- custom
	print LPM_deadlineInfo.framerange_overrideRange
-- 	print LPM_deadlineInfo.framerange_overrideRange[1] 	-- custom
-- 	print LPM_deadlineInfo.framerange_overrideRange[2] 	-- custom

	print "[ FILES TO COPY ]"
	print SMTDSettings.SubmitExternalFilesMode 

	print "[ FRAME BUFFER ]"
	print LPM_deadlineInfo.sticky_frameBufferMode -- custom

	print "[ RENDER ELEMENTS IN EXR ]"
	print LPM_deadlineInfo.sticky_renderElementsExr -- custom

	print "[ IGNORE MISSING EXTERNAL FILES ]"
	print SMTDSettings.IgnoreMissingExternalFiles

	print "[ RESTART 3DSMAX BETWEEN FRAMES ]"
	print SMTDSettings.RestartMax

	print "[ IGNORE MISSING DLL FILES ]"
	print SMTDSettings.IgnoreMissingDLLs

	print "[ INTERRUPTABLE ]"
	print SMTDSettings.JobIsInterruptible
	print LPM_deadlineInfo.dl_interruptiblePercentage --Bootstrapped

	print "[ TASK TIMEOUT ]"
 	print SMTDSettings.TaskTimeoutEnabled 	
 	print SMTDSettings.TaskTimeout		 	

	print "[ TASK CHUNK SIZE ]"
	print SMTDSettings.ChunkSize

	print "[ TASK ORDER ]"
	print SMTDSettings.OutOfOrderMethod 	
	print SMTDSettings.OutOfOrderStep 	

	print "[ AUTODRAFT ]"
	print SMTDSettings.DraftTemplate

	"---end---"
)

SMTDSettingsJobInspect()
