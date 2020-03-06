/*
Deadline job submission written by Jacob Jeziorski (www.JakubJeziorski.com)
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/

-- fnScript = "M:\\DeadlineRepository\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_Functions.ms"
-- icScript = "M:\\DeadlineRepository7\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_IdiotCheck.ms"


LpmSettingsFile = ( getdir #plugcfg + "\\LPM.ini" )
if doesFileExist LpmSettingsFile then
(
	try
	(
		fnScript = getINISetting LpmSettingsFile "Deadline_Options" "Deadline_Server"
	)
	catch()
)
else
(
	setINISetting LpmSettingsFile "Deadline_Options" "Deadline_Server" fnScript
)


global SMTDSettings, SMTDFunctions, SMTDIdiotCheck, SMTDtempSettings, SMTDLPMInterface

struct LPM_DeadlineAPI
(
	type="Deadline8.0",

	fn submit=
	(
		fnScript =@"M:\DeadlineRepository8\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms"
		icScript = @"M:\DeadlineRepository8\submission\3dsmax\Main\SubmitMaxToDeadline_IdiotCheck.ms"
		 
		rollout LPM_DeadlineSubmitRo "Deadline8.0" width:315 height:1
		(
			GroupBox grp_pool "Group and Priority" pos:[6,8] width:304 height:70
				label lbl_group "Group: " pos:[12,32]  height:13 tooltip:"Select the Pool to render in."
				dropdownList ddl_group "" pos:[56,28] width:135 height:21 tooltip:"Select the Group to render in."
				button btn_setLimits "Set limits" offset:[180,-27] width:88 align:#left enabled:false
				button btn_setLimitsClear "X" offset:[268,-26] width:20 align:#left enabled:false tooltip:"Clear limits"
				label lbl_priority "Priority:" pos:[12,54] width:34 height:13
				progressBar sld_priority "" pos:[56,52] width:188 height:18 range:[0,100,50] type:#integer
				spinner spn_priority "" pos:[254,52] width:47 height:16 type:#integer fieldwidth:35
						
			GroupBox grp_job "Job Options" pos:[6,80] width:304 height:246
				label lbl_chunk "Render Task Chunk Size (Frames Per Task):" pos:[12,100] width:211 height:13
				spinner spn_chunkSize "" pos:[254,100] width:47 height:16 range:[1,1000,1] type:#integer fieldwidth:35
				checkbox chk_limitEnabled "Limit No. of Machines Rendering Concurrently  " pos:[12,120] width:246 height:15
				spinner spn_machineLimit "" pos:[254,120] width:47 height:16 enabled:false range:[1,1000,1] type:#integer fieldwidth:35
				dropdownList ddl_OutOfOrderMethod "" pos:[12,140] width:200 height:21 items:#("First To Last (Forward)", "Every Nth, Then Forward", "Every Nth - Block Fill", "Every Nth - Half Raster Refine", "Last To First (Reverse)", "From Both Ends", "From Center", "From Both Ends And From Center", "Random")
				spinner spn_outOfOrderStep "Nth:" pos:[234,144] width:67 height:16 range:[2,1000,10] type:#integer fieldwidth:35
						
				checkbox chk_EnforceSequentialRendering "Enforce Sequential Rendering" pos:[12,165] width:166 height:15
				checkbox chk_rebuildElements "Rebuild Elements" width:122 height:15 offset:[-1,-2]
				checkbox chk_submitAsSuspended "Submit Job As Suspended" width:148 height:15 offset:[-1,-2]
				checkbox chk_autodelete "Delete Complete Job" width:122 height:15 offset:[-1,-2]
				dropdownList ddl_MaxVersionToForce "" width:293 height:21 items:#("-- Force 3ds Max Build --", "32bit", "64bit") offset:[-1,-2] 
				checkbox chk_autoStartupTimeout "Task Start Timeout ( in seconds ): " height:15 checked:true offset:[-1,-2]
				spinner spn_autoStartupTimeout "" range:[60,600,300] type:#integer width:50 offset:[50,-18]
				label lab_CustomComment " Job Comment: "  offset:[-2, 0 ]  align:#left height:15 width:77
 				edittext lab_CustomCommentField ""  offset:[70,-21 ] width:220 align:#left -- height:15

 				checkbox chk_overrideFrameRange "Override Framerange:"
 				spinner spn_overrideFrameRange1 "" 		range:[-10000,10000,0] offset:[-48,-18] 	type:#integer width:72 enabled:false
 				spinner spn_overrideFrameRange2 "to " 	range:[-10000,10000,0] offset:[45,-21] 		type:#integer width:72 enabled:false

  			-- Groupbox grp_tiles "Tile rendering Options" width:304 height:40 pos:[6,330]
  				-- checkbox chk_tileEnabled "Render as (4) Tiles" offset:[2, ( ( grp_tiles.height * -1 ) + 13 ) ]
  				-- spinner spn_tilesHeight "Height" 		range:[1,50,2] offset:[-20,-20] 	type:#integer width:50 enabled:false
  				-- spinner spn_tilesWidth 	"Width" 		range:[1,50,2] offset:[63,-21] 		type:#integer width:50 enabled:false 				
					
			GroupBox grp_options "Submission Options" pos:[6,330] width:304 height:160
				label lab_DeadlineUser " Deadline User: "  offset:[-2, ( ( grp_options.height * -1 ) + 15 ) ] width:77 align:#left --height:15
 				label lab_DeadlineUserField " Loading User... "  offset:[75,-21 ] style_sunkenedge:true width:212 align:#left height:15
				dropdownList ddl_SubmitExternalFilesMode "" offset:[0,0] width:289 height:21 items:#(" Do NOT copy Textures to Repository", " Copy LOCAL Textures to Repository", " Copy ALL Textures to Repository")
				checkbox chk_showvfb "Show VFB" offset:[0,-1]
				checkbox chk_elementsActive "Render elements enabled" offset:[-1,-2] checked:false
				checkbox chk_closeOnComplete "Close on complete" offset:[-1,-2] checked:true
				checkbox chk_autodraft "Autodraft" offset:[170,-56]
				checkbox chk_autodraftUpload "Autodraft Upload" offset:[170,-2] enabled:false
				checkbox chk_forceDefaultVFB "Disable Vray VFB" offset:[170,-2] tooltip:"Disables Vray Virtual Frame Buffer at Rendertime" --enabled:false
 				checkbox chkIgnoreFiles "Ignore Missing External Files" width:166 height:15 offset:[-1,0]
 				checkbox chkIgnoreDLL "Ignore Missing DLL(s)" width:166 height:15 offset:[-1,0]

			GroupBox grp_idiot "Error Handling" align:#left width:305 height:43 offset:[-8,5]--pos:[5,536]
				button btn_idiotCheck "Perform Idiot Check" align:#left across:3 height:20 width:146 offset:[-2,-32] tooltip:"Clears the content of the Log Window."
-- 				button btn_sanityCheck "Launch Scene Check" width:148 height:20 align:#left offset:[48,-32]
				checkbutton btn_holdOnSub "Hold on submit" width:148 height:20 align:#left offset:[48,-32]  tooltip:"Performs max hold before submitting, and will restore to on crash."
						
			GroupBox grp_submit "Submit" offset:[-200,0] width:305 height:66
				local bm_idiotCheckRed 		= bitmap 10 28 color:red
				local bm_idiotCheckGreen 	= bitmap 10 28 color:green
				local bm_idiotCheckBlue 	= bitmap 10 28 color:blue
				local bm_idiotCheckOrange 	= bitmap 10 28 color:orange
				imgTag img_idiotcheck_L bitmap:bm_idiotCheckBlue offset:[0,-57]
				button btn_submit "<< Please Wait >>" width:270 height:30 offset:[10,-35] align:#left enabled:false
				imgTag img_idiotcheck_R bitmap:bm_idiotCheckBlue offset:[280,-34]  align:#left
				progressBar prg_submitProgress2 "" offset:[-1,4] width:292 height:8 color:[0,200,0] --visible:false pos:[12,632]
 				progressBar prg_submitProgress "" offset:[-1,-4] width:292 height:8 color:[0,0,200] --visible:false pos:[12,632]


 			dotNetControl errorLog "system.windows.forms.RichTextBox" height:138 width:308 offset:[-9,10] --pos:[ 3 , 595 ]

			fn loadSettings =
			(
				--store settings as last settings
				
				SMTDSettings.PoolName 						= LPM_Fun.GetIni "Deadline Settings" "PoolName" string "3dsmax"
				SMTDSettings.Priority 						= LPM_Fun.GetIni "Deadline Settings" "Priority" integer 50
				SMTDSettings.ChunkSize 						= LPM_Fun.GetIni "Deadline Settings" "ChunkSize" integer 1
				SMTDSettings.LimitEnabled 					= LPM_Fun.GetIni "Deadline Settings" "LimitEnabled" booleanClass false
				SMTDSettings.machineLimit 					= LPM_Fun.GetIni "Deadline Settings" "machineLimit" integer 0
				
				SMTDSettings.OutOfOrderMethod 				= LPM_Fun.GetIni "Deadline Settings" "OutOfOrderMethod" string #normal
				SMTDSettings.OutOfOrderStep 				= LPM_Fun.GetIni "Deadline Settings" "OutOfOrderStep" integer 1
				SMTDSettings.SequentialJob 					= LPM_Fun.GetIni "Deadline Settings" "SequentialJob" booleanClass false
				SMTDSettings.SubmitAsSuspended 				= LPM_Fun.GetIni "Deadline Settings" "SubmitAsSuspended" booleanClass false
				SMTDSettings.AutoDelete 					= LPM_Fun.GetIni "Deadline Settings" "AutoDelete" booleanClass false
				SMTDSettings.MaxVersionToForce 				= LPM_Fun.GetIni "Deadline Settings" "MaxVersionToForce" string "none"
				SMTDSettings.SubmitExternalFilesMode 		= LPM_Fun.GetIni "Deadline Settings" "SubmitExternalFilesMode" integer 1
				SMTDSettings.ShowFrameBuffer 				= LPM_Fun.GetIni "Deadline Settings" "ShowFrameBuffer" booleanClass true
				SMTDSettings.IgnoreMissingExternalFiles 	= LPM_Fun.GetIni "Deadline Settings" "IgnoreMissingExternalFiles" booleanClass true
				SMTDSettings.IgnoreMissingDLLs 				= LPM_Fun.GetIni "Deadline Settings" "IgnoreMissingDLLs" booleanClass false
				try 
				(
					SMTDSettings.RebuildRenderElements 		= LPM_Fun.GetIni "Deadline Settings" "RebuildRenderElements" 	booleanClass true
					SMTDSettings.Comment 					= LPM_Fun.GetIni "Deadline Settings" "JobComment" 				string ""

					SMTDFunctions.CollectLimitGroups()
					SMTDSettings.LimitGroups
				)
				catch()
				--set controls to loaded state
				
				if (isValidNode $LPM_Deadline_Settings) then
				(
					localSettings 								= $LPM_Deadline_Settings
					SMTDSettings.PoolName 						= LPM_Fun.getProp localSettings "PoolName" 						string SMTDSettings.PoolName
					SMTDSettings.Priority 						= LPM_Fun.getProp localSettings "Priority" 						integer SMTDSettings.Priority
					SMTDSettings.ChunkSize 						= LPM_Fun.getProp localSettings "ChunkSize" 					integer SMTDSettings.ChunkSize
					SMTDSettings.LimitEnabled 					= LPM_Fun.getProp localSettings "LimitEnabled" 					booleanClass SMTDSettings.LimitEnabled
					SMTDSettings.machineLimit 					= LPM_Fun.getProp localSettings "machineLimit" 					integer SMTDSettings.machineLimit
					SMTDSettings.OutOfOrderMethod 				= LPM_Fun.getProp localSettings "OutOfOrderMethod" 				string SMTDSettings.OutOfOrderMethod
					SMTDSettings.OutOfOrderStep 				= LPM_Fun.getProp localSettings "OutOfOrderStep" 				integer SMTDSettings.OutOfOrderStep
					SMTDSettings.SequentialJob 					= LPM_Fun.getProp localSettings "SequentialJob" 				booleanClass SMTDSettings.SequentialJob
					SMTDSettings.SubmitAsSuspended 				= LPM_Fun.getProp localSettings "SubmitAsSuspended" 			booleanClass SMTDSettings.SubmitAsSuspended
					SMTDSettings.AutoDelete 					= LPM_Fun.getProp localSettings "AutoDelete" 					booleanClass SMTDSettings.AutoDelete
					SMTDSettings.MaxVersionToForce 				= LPM_Fun.getProp localSettings "MaxVersionToForce" 			string SMTDSettings.MaxVersionToForce
					SMTDSettings.SubmitExternalFilesMode 		= LPM_Fun.getProp localSettings "SubmitExternalFilesMode" 		integer SMTDSettings.SubmitExternalFilesMode
					SMTDSettings.ShowFrameBuffer 				= LPM_Fun.getProp localSettings "ShowFrameBuffer" 				booleanClass SMTDSettings.ShowFrameBuffer
					
					try 
					(
						SMTDSettings.RebuildRenderElements 		= LPM_Fun.getProp localSettings "RebuildRenderElements" 		booleanClass SMTDSettings.RebuildRenderElements
						SMTDSettings.IgnoreMissingExternalFiles = LPM_Fun.getProp localSettings "IgnoreMissingExternalFiles" 	booleanClass SMTDSettings.IgnoreMissingExternalFiles
						SMTDSettings.IgnoreMissingDLLs 			= LPM_Fun.getProp localSettings "IgnoreMissingDLLs" 			booleanClass SMTDSettings.IgnoreMissingDLLs
						SMTDSettings.Comment 					= LPM_Fun.getProp localSettings "JobComment" 					string SMTDSettings.Comment
						btn_holdOnSub.checked 					= LPM_Fun.getProp localSettings "HoldOnSubmit" 					string SMTDSettings.Comment
					)
					catch()
				)
				
				spn_chunkSize.value 					= SMTDSettings.ChunkSize
				chk_limitEnabled.state 					= spn_machineLimit.enabled = SMTDSettings.LimitEnabled
				spn_machineLimit.value 					= SMTDSettings.machineLimit

				local theVal 							= findItem #(#normal, #nth, #NthBlock, #NthRasterRefine, #reverse, #fromBothEnds, #FromCenter, #fromBothEndsAndCenter, #random) SMTDSettings.OutOfOrderMethod 
				if theVal == 0 do theVal = 1
				ddl_outOfOrderMethod.selection 			= theVal
				chk_submitAsSuspended.state 			= SMTDSettings.SubmitAsSuspended 
				chk_autoDelete.state 					= SMTDSettings.AutoDelete 
				spn_outOfOrderStep.value 				= SMTDSettings.OutOfOrderStep
				chk_EnforceSequentialRendering.state 	= SMTDSettings.SequentialJob

				theVal 									= findItem #("none", "32bit", "64bit") SMTDSettings.MaxVersionToForce 
				if theVal == 0 do versionVal = 1
				ddl_MaxVersionToForce.selection 		= theVal
				ddl_SubmitExternalFilesMode.selection 	= SMTDSettings.SubmitExternalFilesMode 
				chk_showvfb.state 						= SMTDSettings.ShowFrameBuffer
				
				chk_rebuildElements.state 				= SMTDSettings.RebuildRenderElements
				chkIgnoreFiles.state 					= SMTDSettings.IgnoreMissingExternalFiles
				chkIgnoreDLL.state 						= SMTDSettings.IgnoreMissingDLLs
				btn_holdOnSub.checked 					= LPM_Fun.GetIni "Deadline Settings" "HoldOnSubmit" booleanClass true			
				chk_forceDefaultVFB.checked 			= LPM_Fun.getIni "Settings" "VFBoffSetting" booleanClass true	

				-- lab_CustomCommentField.text 			= SMTDSettings.Comment
			)


			fn saveSettings =
			(
				--store settings as last settings
				LPM_Fun.SetIni "Deadline Settings" "PoolName" 					SMTDSettings.PoolName
				LPM_Fun.SetIni "Deadline Settings" "Priority" 					SMTDSettings.Priority
				LPM_Fun.SetIni "Deadline Settings" "ChunkSize"					SMTDSettings.ChunkSize
				LPM_Fun.SetIni "Deadline Settings" "LimitEnabled" 				SMTDSettings.LimitEnabled
				LPM_Fun.SetIni "Deadline Settings" "machineLimit" 				SMTDSettings.machineLimit
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderMethod" 			SMTDSettings.OutOfOrderMethod
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderStep" 			SMTDSettings.OutOfOrderStep
				LPM_Fun.SetIni "Deadline Settings" "SequentialJob" 				SMTDSettings.SequentialJob
				LPM_Fun.SetIni "Deadline Settings" "SubmitAsSuspended" 			SMTDSettings.SubmitAsSuspended
				LPM_Fun.SetIni "Deadline Settings" "AutoDelete" 				SMTDSettings.AutoDelete
				LPM_Fun.SetIni "Deadline Settings" "MaxVersionToForce" 			SMTDSettings.MaxVersionToForce
				LPM_Fun.SetIni "Deadline Settings" "SubmitExternalFilesMode" 	SMTDSettings.SubmitExternalFilesMode
				LPM_Fun.SetIni "Deadline Settings" "ShowFrameBuffer" 			SMTDSettings.ShowFrameBuffer
				
				LPM_Fun.SetIni "Deadline Settings" "RebuildRenderElements" 		SMTDSettings.RebuildRenderElements
				LPM_Fun.SetIni "Deadline Settings" "IgnoreMissingExternalFiles" SMTDSettings.IgnoreMissingExternalFiles
				LPM_Fun.SetIni "Deadline Settings" "IgnoreMissingDLLs" 			SMTDSettings.IgnoreMissingDLLs

 				LPM_Fun.SetIni "Deadline Settings" "RenderElementsEnabled" 		chk_elementsActive.checked --SMTDSettings.RenderElementsEnabled
	  			-- LPM_Fun.SetIni "Deadline Settings" "ExcludeWorkstations" 		chk_excludeWorkstations.checked --SMTDSettings.ExcludeWorkstations
				LPM_Fun.SetIni "Deadline Settings" "JobComment" 				lab_CustomCommentField.text
				LPM_Fun.SetIni "Deadline Settings" "HoldOnSubmit" 				btn_holdOnSub.checked
				LPM_Fun.SetIni "Settings" "VFBoffSetting" 						btn_holdOnSub.checked
-- 				chk_forceDefaultVFB.checked 			= LPM_Fun.getIni "Settings" "VFBoffSetting" booleanClass true
				--store settings in scene
				
				if (isValidNode $LPM_Deadline_Settings) then 
					localSettings = $LPM_Deadline_Settings
				else
				(
					localSettings = LPM_Fun.createNode "Deadline_Settings" "empty"
					localSettings.parent = $LPM_Root
				)

				LPM_Fun.setProp localSettings "PoolName"					SMTDSettings.PoolName
				LPM_Fun.setProp localSettings "Priority" 					SMTDSettings.Priority
				LPM_Fun.setProp localSettings "ChunkSize" 					SMTDSettings.ChunkSize
				LPM_Fun.setProp localSettings "LimitEnabled" 				SMTDSettings.LimitEnabled
				LPM_Fun.setProp localSettings "machineLimit"	 			SMTDSettings.machineLimit
				LPM_Fun.setProp localSettings "OutOfOrderMethod" 			SMTDSettings.OutOfOrderMethod
				LPM_Fun.setProp localSettings "OutOfOrderStep" 				SMTDSettings.OutOfOrderStep
				LPM_Fun.setProp localSettings "SequentialJob" 				SMTDSettings.SequentialJob
				LPM_Fun.setProp localSettings "SubmitAsSuspended" 			SMTDSettings.SubmitAsSuspended
				LPM_Fun.setProp localSettings "AutoDelete" 					SMTDSettings.AutoDelete
				LPM_Fun.setProp localSettings "MaxVersionToForce" 			SMTDSettings.MaxVersionToForce
				LPM_Fun.setProp localSettings "SubmitExternalFilesMode" 	SMTDSettings.SubmitExternalFilesMode
				LPM_Fun.setProp localSettings "ShowFrameBuffer" 			SMTDSettings.ShowFrameBuffer

				LPM_Fun.setProp localSettings "RebuildRenderElements" 		SMTDSettings.RebuildRenderElements
				LPM_Fun.setProp localSettings "IgnoreMissingExternalFiles" 	SMTDSettings.IgnoreMissingExternalFiles
				LPM_Fun.setProp localSettings "IgnoreMissingDLLs" 			SMTDSettings.IgnoreMissingDLLs

 				LPM_Fun.setProp localSettings "RenderElementsEnabled" 		chk_elementsActive.checked
	  			-- LPM_Fun.setProp localSettings "ExcludeWorkstations" 		chk_excludeWorkstations.checked
				LPM_Fun.setProp localSettings "JobComment" 					lab_CustomCommentField.text
-- 				LPM_Fun.setProp localSettings "HoldOnSubmit" 				btn_holdOnSub.checked

			)

			function getProjectINIfromFileOrPath arg_path = 
			(
				pathArr = filterstring arg_path @"\" 
				curINI = ""
				
				for i in 1 to pathArr.count do
				(
					if pathArr[i] == "Projects"	then
					(
						for j in 1 to ( i + 1 ) do (curINI+= ( pathArr[j] +  @"\" ) )
						
						curIni +=  @"Data\project.ini" 
						
						if ( doesfileexist curINI ) 
						then( return curINI )
						else ()
						
						exit
					)
				)
				
				return undefined
			)

			fn setLimitsRO = 
			(
				rollout LPM_DeadlineSubmit_setLimitsRO "Set Limits" width:225 height:300
				(
					label lab_1 "Select Limits" align:#left
					multilistbox mlt_theLimitGroups "" items:#("-- Loading --") height:10
					button btn_chooseLimits "Choose Selected Limits" width:205 align:#left
					
					fn resize_setLimitsRO curHeight = 
					(
						mlt_theLimitGroups.height = curHeight-50
						btn_chooseLimits.pos = [10,(curHeight-25)]
					)
					
					fn getLimitGroups =
					(
						SMTDFunctions.CollectLimitGroups()
						limitArr = SMTDSettings.LimitGroups
						return limitArr
					)
					
					fn saveLimitGroups = 
					(
						result = #()
						for selected in mlt_theLimitGroups.selection do
						(
							append result mlt_theLimitGroups.items[selected]
						)			
						
						SMTDSettings.LimitGroupsToUse = result
					)
					
					on LPM_DeadlineSubmit_setLimitsRO resized theSize do
					(
						resize_setLimitsRO theSize[2]
					)
					
					on LPM_DeadlineSubmit_setLimitsRO open do 
					(
						resize_setLimitsRO 300
						mlt_theLimitGroups.items = getLimitGroups()
					)
					
					on btn_chooseLimits pressed do
					(
						saveLimitGroups()
			 			destroyDialog LPM_DeadlineSubmit_setLimitsRO
					)
				)
				
				createDialog LPM_DeadlineSubmit_setLimitsRO lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) modal:true
			)

			function log_append arg_text arg_color =
			(

				curcolor = (dotNetClass "System.Drawing.Color").FromArgb 50 200 50  

				case arg_color of 
				(
					1:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 200 50 50 ) 	-- Red
					2:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 50 200 50 ) 	-- Green
					3:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 100 100 255 ) 	-- Blue
					4:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200 ) 	-- Gray
					5:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 255 169 0 ) 	-- Gold
				)

				errorlog.SelectionColor = errorlog.forecolor
				parsedTime 	= filterString localTime " "
				errorLog.appendText ( parsedTime[2] + " " + parsedTime[3] + ": " )
				errorlog.SelectionColor = curColor
				errorlog.appendText ( arg_text + "\n" )
				errorlog.ScrollToCaret()
				errorLog.update()
			)

			function log_init = 
			(
				errorlog.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 68 68 68
 				errorlog.Multiline 		= true --(dotNetClass "System.Boolean") true
 				errorlog.ReadOnly 		= true
 				errorlog.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200

				deadline_ini = @"C:\ProgramData\Thinkbox\Deadline8\deadline.ini"
		 		theNetworkRoot = getinisetting deadline_ini "Deadline" "NetworkRoot"

		 		log_append "Connected to deadline repository" 2
		 		log_append theNetworkRoot 4
			)

			function getLocalDeadlineUser = 
			(
				try
				(
					userFolder =  (dotNetClass "System.Environment").GetEnvironmentVariable "UserProfile"
					deadline_ini = userFolder + @"\AppData\Local\Thinkbox\Deadline8\deadline.ini"
					deadlineUser = ( getinisetting deadline_ini "Deadline" "user" )
					lab_DeadlineUserField.text = ( " " + deadlineUser )
					log_append ( "Submitting as user \" " + deadlineUser + " \"" ) 4
				)
				catch(
					lab_DeadlineUserField.text = "No user set in Deadline Monitor"
					log_append "Unable to load user" 5
				)
			)

			-- TODO: Finish this
			fn submit_preAction =
			(
				disablesceneredraw()

				struct SMTDtempSettingsStruct
				(
					recoveryHold 		= undefined,
					viewToRenderLock 	= undefined
				)

				SMTDtempSettings = SMTDtempSettingsStruct()
				SMTDtempSettings.viewToRenderLock = rendUseActiveView

				if btn_holdOnSub.checked
				then
				(
					SMTDtempSettings.recoveryHold = true
					log_append "Performing 3dsMax Hold" 2
					holdMaxFile()

				)

				rendUseActiveView = true
			)

			fn submit_postAction =
			(
				rendUseActiveView = SMTDtempSettings.viewToRenderLock

				enablesceneredraw()
				redrawviews()
			)

			fn submit_fail =
			(

				if SMTDtempSettings.recoveryHold == true
				then
				(
					rollout automaticRecoveryMessage "Auto-Recovery" width:300 height:50
					(
						label lab1 "Submission crashed, performing restore." align:#center offset:[0,8]
	  					label lab2 "Please wait..." offset:[0,-5]
					)
					
					rollout automaticRecoveryMessage2 "Auto-Recovery" width:300 height:70
					(
						label lab1 "LPM successfully recovered scene!" offset:[0,8]
	  					button btn1 "Great!" offset:[0,5] width:80 height:25
						
						on btn1 pressed do destroydialog automaticRecoveryMessage2
					)

					createdialog automaticRecoveryMessage

 					fetchmaxfile quiet:true

					destroydialog automaticRecoveryMessage
					createdialog automaticRecoveryMessage2

				)

				enablesceneredraw()
				redrawviews()
			)

			-- FUNCTIONS from SubmitMaxToDeadline --
			fn job_priority_update val =
			(
				if val <= 100 do
				(
					theRed = (255.0 - 255.0*val/100.0)*2.0
					if theRed > 255 do theRed = 255
					theGreen = 512.0*val/100.0
					if theGreen > 255 do theGreen = 255
					sld_priority.color = [theRed, theGreen, 0]
					sld_priority.value = spn_priority.value = val
				)
				val
			)	

			fn displayPoolsList =
			(
				if SMTDSettings.PoolsSort then
				(
					local tempArray = for i in SMTDSettings.Pools collect i
					ddl_pool.items = sort tempArray 
				)	
				else
				(
					ddl_pool.items = SMTDSettings.Pools
				)
				local theIndex = findItem ddl_pool.items SMTDSettings.PoolName
				if theIndex > 0 then 
					ddl_pool.selection = theIndex 
				else	
					ddl_pool.selection = 1
				
			)

			fn displayGroupsList =
			(
				local tempArray = for i in SMTDSettings.Groups collect i
				tempArray2 = join #("none") tempArray
				ddl_group.items = tempArray
				ddl_group.selection = 1
			)

			fn fn_updateSubmitButton =
			(
				renderCollect = LPM_Fun.getWhoToRender()
				btn_submitText = ( "<< Submit " + (renderCollect.count as string) + " passe(s) >>")
				btn_submit.text = btn_submitText
				log_append "Ready..." 2
			)

			fn runIdiotChecks = 
			(
				ts = timeStamp()

				log_append "Running idiot checks" 4

				checks = getpropnames SMTDIdiotCheck
				failcount = 0
				criticalFail = false
				resultsArray = #()

				for check in checks do
				(
					curCheck = getProperty SMTDIdiotCheck check
					curCheckResult = curCheck()
					
					if curCheckResult[1] == "fail"
					then
					(
						for result in curCheckResult[3] do 
						(
							failcount += 1

							if curCheckResult[2] == 1
							then ( criticalFail = true )
							else ()

							append resultsArray result
						)
					)
					else()
				)

				-- Print results to the log
				log_append ( "All checks took " + ( ( (timeStamp() - ts ) / 1000.000 ) as string ) + " seconds" ) 4
				for result in resultsArray do ( log_append result 5	)

				

				if failcount == 0
				then
				(
					log_append "Passed all checks!" 2
					img_idiotcheck_L.bitmap = bm_idiotCheckGreen
					img_idiotcheck_R.bitmap = bm_idiotCheckGreen
					btn_submit.enabled 		= true
				)
				else
				(
					log_append ( "Triggered " + ( failcount as string ) + " check(s)!" ) 1

					if criticalFail == false
					then
					(
						img_idiotcheck_L.bitmap = bm_idiotCheckOrange
						img_idiotcheck_R.bitmap = bm_idiotCheckOrange
						btn_submit.enabled = true
					)
					else
					(
						img_idiotcheck_L.bitmap = bm_idiotCheckRed
						img_idiotcheck_R.bitmap = bm_idiotCheckRed
						btn_submit.enabled = false
						print "HEY!"
					)
				)
			)

			function overrideFrameRangeEnable arg = 
			(
				spn_overrideFrameRange1.enabled 	= arg
				spn_overrideFrameRange2.enabled 	= arg
			)

			function tilesSpinnerEnable arg =
			(
				spn_tilesHeight.enabled 	= arg
				spn_tilesWidth.enabled 		= arg
			)

			function tilesCheckboxTextUpdate = 
			(
				num = (spn_tilesHeight.value * spn_tilesWidth.value )
				str = "Render as (" + ( num as string ) + ") Tiles"
				chk_tileEnabled.text = str
			)

			function generateMultiRegionData = 
			(
				data = #()

				x = spn_tilesWidth.value
				y = spn_tilesHeight.value
				tileNumber = 1

				for i in 1 to x do 
				(
					for j in 1 to y do 
					(
						nameStr = ( ( spn_tilesWidth.value as string ) + "x" + ( spn_tilesHeight.value as string ) + " Grid Tile #" + ( tileNumber as string ) )
						
						h1 = ( ( 1.0 / y ) * ( i - 1 ) )
						h2 = ( ( 1.0 / y ) * ( i ) )

						w1 = ( ( 1.0 / x ) * ( j - 1 ) )
						w2 = ( ( 1.0 / x ) * ( j ) )


						-- #(true, 0.0, 0.0, 0.25, 0.25, 1, 1, "4x4 Grid Tile #1", true) -- reference
						tile = #(true, w1, h1, w2, h2, 1, 1, nameStr, true)
						append data tile

						tileNumber += 1
					)
				)

				return data
			)

			function tilesSetData = 
			(

				if chk_tileEnabled.checked 
				then 
				(
					SMTDSettings.MultiRegionData 		= generateMultiRegionData()
					SMTDSettings.RegionRenderingMode 	= #singleFrameMultiRegion
					SMTDSettings.SingleTileJobDraft 	= true
					SMTDSettings.MultiRegionBackground	= #off
				)
				else
				(
					SMTDSettings.MultiRegionData 		= #()
					SMTDSettings.RegionRenderingMode 	= #none
					SMTDSettings.SingleTileJobDraft 	= false
				)

				print "test"
				print ( SMTDSettings.MultiRegionData as string )
			)

			--EVENT HANDLERS--
			on LPM_DeadlineSubmitRo resized arg do 
			(
				errorlog.height =  ( arg[2] - 623 )
			)

			on chk_overrideFrameRange changed state do 
			(
				overrideFrameRangeEnable state
			)

			on chk_tileEnabled changed state do 
			(
				tilesSpinnerEnable state

				tilesSetData()
			)

			on spn_tilesHeight changed value do 
			(
				tilesCheckboxTextUpdate()

				tilesSetData()
			)

			on spn_tilesWidth changed value do 
			(
				tilesCheckboxTextUpdate()

				tilesSetData()
			)

			on btn_idiotCheck pressed do 
			(	
				runIdiotChecks()
			)

			on chk_autodraft changed state do 
			(
				if state
				then 
				(
					chk_autodraftUpload.enabled = true
				)
				else
				(
					chk_autodraftUpload.enabled = false
					chk_autodraftUpload.checked = false
				)
			)

			on chk_autodraftUpload changed state do 
			(
				if state
				then 
				(
					pass = false
					projectINI = getProjectINIfromFileOrPath maxfilepath

					if projectINI != undefined 
					then 
					(
						propClient = ( getinisetting projectINI "Project" "nameclient" )
						propProject =( getinisetting projectINI "Project" "nameproject" )

						if propClient != "" and propProject != ""
						then
						(
							pass = true
						)
						else ()
					)

					if pass 
					then
					(
						log_append ( "Uploading to: " + propClient + @"\" + propProject + @"\" ) 4
					)
					else 
					(
						log_append ( "Unable to find project.ini upload data" ) 1
						chk_autodraftUpload.checked = false
					)
				)
			)

			on btn_setLimits pressed do 
			(
				setLimitsRO()
				btn_setLimits.text = ( ( SMTDSettings.LimitGroupsToUse.count as string ) + " Limits set")
				for limit in SMTDSettings.LimitGroupsToUse do 
				(
					log_append ( " \"" + limit + " \"" + " limit was added" ) 4
				)
			)

			on btn_setLimitsClear pressed do 
			(
				btn_setLimits.text = "Set limits"
				SMTDSettings.LimitGroupsToUse = #()
				log_append ( " Limits were cleared from submission" ) 4
			)

			on ddl_pool selected itm do 
			(
				SMTDSettings.PoolName = ddl_pool.selected
			)

			on ddl_group selected itm do 
			(
				SMTDSettings.group = ddl_group.selected
			)

			on sld_priority clicked value do
			(
				SMTDSettings.Priority= (job_priority_update value)
			)
			
			on spn_priority changed value do
			(	
				SMTDSettings.Priority= (job_priority_update value)
			)

			on spn_chunkSize changed value do 
			(
				SMTDSettings.ChunkSize = value
			)	

			on chk_limitEnabled changed state do 
			(
				SMTDSettings.LimitEnabled = state
				spn_machineLimit.enabled = state 
			)	
			
			on spn_machineLimit changed value do 
			(
				SMTDSettings.machineLimit = value
			)	

			on ddl_outOfOrderMethod selected itm do
			(
				theMethod= case itm of
				(
						1: #normal
						2: #nth
						3: #NthBlock
						4: #NthRasterRefine
						5: #reverse
						6: #fromBothEnds
						7: #fromCenter
						8: #fromBothEndsAndCenter
						9: #random
				)
				SMTDSettings.OutOfOrderMethod = theMethod
				spn_outOfOrderStep.enabled = itm >= 2 AND itm <= 4
			)

			on spn_outOfOrderStep changed value do 
			(
				SMTDSettings.OutOfOrderStep = value
			)	
				
			on chk_EnforceSequentialRendering changed state do 
			(
				SMTDSettings.SequentialJob = state
			)		
				
			on chk_submitAsSuspended changed state do 
			(
				SMTDSettings.SubmitAsSuspended = state
			)	

			on chk_autoDelete changed state do 
			(
				SMTDSettings.AutoDelete = state
			)	
		
			on chk_rebuildElements changed state do 
			(
				SMTDSettings.RebuildRenderElements = state
			)	
			
			on chkIgnoreFiles changed state do 
			(
				SMTDSettings.IgnoreMissingExternalFiles = state
			)	
			
			on chkIgnoreDLL changed state do 
			(
				SMTDSettings.IgnoreMissingDLLs = state
			)	
			
			on ddl_MaxVersionToForce selected itm do
			(
				case itm of
				(
					1: SMTDSettings.MaxVersionToForce = "none"
					2: SMTDSettings.MaxVersionToForce = "32bit"
					3: SMTDSettings.MaxVersionToForce = "64bit"
				)
			)
			
			on ddl_SubmitExternalFilesMode selected itm do
			(
				SMTDSettings.SubmitExternalFilesMode = ddl_SubmitExternalFilesMode.selection
			)
			
			on chk_showvfb changed state do 
			(
				SMTDSettings.ShowFrameBuffer = state
			)	
			
			on LPM_DeadlineSubmitRo open do
			(
				SMTDLPMInterface = LPM_DeadlineSubmitRo
 				LPM_DeadlineSubmitRo.height = 800

				log_init()
				loadSettings()
  				getLocalDeadlineUser()

				if SMTDSettings.Groups.count == 0 do SMTDFunctions.CollectGroups()
				displayGroupsList()

				log_append ( ( SMTDSettings.Groups.count as string ) + " groups found" ) 4

				runIdiotChecks()

				itm = ddl_outOfOrderMethod.selection
				spn_outOfOrderStep.enabled = itm >= 2 AND itm <= 4
				job_priority_update SMTDSettings.Priority
				btn_setLimits.enabled = true
				btn_setLimitsClear.enabled = true
				
				SMTDSettings.SubmitSceneMode = #reposave
				SMTDSettings.RestartRenderer = true
				SMTDSettings.RenderElementsUpdatePaths = true
				SMTDSettings.RenderElementsUpdateFileNames = true
				SMTDSettings.RenderElementsPermanentChanges = true
				SMTDSettings.ClearMaterialEditorOnSubmission = true
				SMTDSettings.ExportAdvancedRenderInfoVRay = true



				fn_updateSubmitButton()
			)

			on LPM_DeadlineSubmitRo close do
			(
				saveSettings()
			)

			on btn_sanityCheck pressed do
			(
				SMTD_PerformSanityCheck()
				
			)
			
			on btn_submit pressed do
			(
				log_append "Beginning Submission." 2
				ts = timeStamp()
				submit_preAction()

				try
				(
					renderSceneDialog.close()
					saveSettings()
					
					if SMTDSettings.RebuildRenderElements do
					(
						print "Rebuilding Render Elements"
						SMTDFunctions.RebuildRenderElements()
					)

					if chk_overrideFrameRange.checked 
					then 
					(
						-- TODO: use SMTDtempSettings
						rendStartHold = rendStart
						rendEndHoild = rendEnd
					)
					else()

					local reMgr = maxOps.getCurRenderElementMgr()
					stickyElementsActive = reMgr.GetElementsActive()

					if chk_elementsActive.checked
					then(
						reMgr.SetElementsActive true				
					) 
					else(
						reMgr.SetElementsActive false				
					)

					prg_submitProgress.value = 0

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
						if chk_overrideFrameRange.checked 
						then 
						(
							rendStart = spn_overrideFrameRange1.value
							rendEnd = spn_overrideFrameRange2.value
						)
						else()
							
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

							SMTDSettings.Comment = lab_CustomCommentField.text
							SMTDSettings.UserName = SMTDFunctions.GetDeadlineUser()

							SMTDSettings.StartJobTimeoutEnabled = chk_autoStartupTimeout.checked
							SMTDSettings.StartJobTimeoutSeconds = ( spn_autoStartupTimeout.value as string )

							-- Autodraft Stuff
							AutodraftEnabledVal = "False"
							AutodraftUploadVal 	= "False"

							if chk_autodraft.checked
							then ( AutodraftEnabledVal = "True" )

							if chk_autodraftUpload.checked
							then ( AutodraftUploadVal = "True" )

							SMTDSettings.ExtraInfoKeyValues = #( #( "AutoDraftEnabled", AutodraftEnabledVal ), #( "AutoDraftUpload", AutodraftUploadVal ) )

							SMTDSettings.group = ddl_group.selected
							
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
							--TODO:fail here?
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
		)

		theNetworkRoot = ""

		flag=false

			if doesFileExist fnScript then
			(
				try(destroydialog repositoryConnectDialog )catch()

				rollout repositoryConnectDialog "Establishing Repository Connection" width:550 height:50
				(
					label lab1 "Establishing Repository Connection" offset:[0,8]
 					label lab2 "Connecting..." offset:[0,-5]
 					label lab3 "" offset:[0,-5]
				)

				createdialog repositoryConnectDialog
				repositoryConnectDialog.lab1.text 	= ( "Loading: " + ( getfilenamefile fnScript ) )
				repositoryConnectDialog.lab2.text 	= ( "" + ( fnScript ) )
 				repositoryConnectDialog.lab1.enabled = false
				repositoryConnectDialog.lab1.enabled = true
				fileIn fnScript quiet:true

				repositoryConnectDialog.lab1.text 	= ( "Loading: " + ( getfilenamefile icScript ) )
				repositoryConnectDialog.lab2.text 	= ( "" + ( icScript ) )
 				repositoryConnectDialog.lab1.enabled = false
				repositoryConnectDialog.lab1.enabled = true
				fileIn icScript quiet:true
				
				flag=true
			)

		if(flag==false) then
		(
			try
			(
				message = ( "ERROR: Unable to load " + ( getfilenamefile fnScript ) ) 
				repositoryConnectDialog.lab1.text 	= message
			)
			catch (	message = ( "ERROR: Unable to load Unable to connect to repository" ) )
			
			return message	
		)
		
		destroydialog repositoryConnectDialog
		try(destroyDialog LPM_RenderRo)catch()

		createDialog LPM_DeadlineSubmitRo lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos LPM_DeadlineSubmitRo.width)
		SMTDLPMInterface = LPM_DeadlineSubmitRo
--      		return LPM_DeadlineSubmitRo
		return #SUCCESS
	)	
)

append LPM_NetworkPlugins (LPM_DeadlineAPI())
-- LPM_DeadlineAPI.submit()