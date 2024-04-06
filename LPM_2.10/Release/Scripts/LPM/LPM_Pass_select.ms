LPMPassSelectRollDocked = true
LPMPassSelectRollPos = [600,600]
close_btn_pressed = false

 tmppos = [0,0]
 
OpenLPMPassSelectRollOnStart = LPM_Fun.getIni "Settings" "OpenLPMPassSelectRollOnStart" booleanClass undefined
 
if LPMPassSelectRoll != undefined then
(
	tmppos = getdialogpos LPMPassSelectRoll
 )

 if OpenLPMPassSelectRollOnStart == undefined then
 (
	TmpShow = queryBox "Open LPM Pass Select window on start?" title:"First run"
	if TmpShow then
	(
		OpenLPMPassSelectRollOnStart = true
		LPM_Fun.setIni "Settings" "OpenLPMPassSelectRollOnStart" true
	)
	else
	(
		OpenLPMPassSelectRollOnStart = false
		LPM_Fun.setIni "Settings" "OpenLPMPassSelectRollOnStart" false
	)
 )
 
if (tmppos == [0,0]) and (OpenLPMPassSelectRollOnStart) then
(

	fn read_LPM_Pass_Settings = 
	(
		if not doesFileExist ((getDir #plugCFG) + "\\LPM_Pass_Settings.ini") then
		(
			try
			(
				var_settingsFile_LPM_Pass = (getDir #plugCFG) + "\\LPM_Pass_Settings.ini"
				
				temp_flag = case LPMPassSelectRollDocked of
				(
					true:1
					false:0
					default:1
				)
				setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollDocked" (temp_flag as string)
				
				
				setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_x" (LPMPassSelectRollPos[1] as string)
				setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_y" (LPMPassSelectRollPos[2] as string)
				
			)
			catch
			(
			)
		)
		else
		(
			var_settingsFile_LPM_Pass = (getDir #plugCFG) + "\\LPM_Pass_Settings.ini"
			
			temp_flag = execute (getINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollDocked")
			if temp_flag==1 then
			(
				LPMPassSelectRollDocked = true
			)
			else
			(
				LPMPassSelectRollDocked = false
			)
			
			
			LPMPassSelectRollPos[1] = execute (getINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_x")--getboolval created "[Maps collecting options]"
			LPMPassSelectRollPos[2] = execute (getINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_y")--getboolval created "[HDRI maps collecting options]"
			
		)
		
		#(LPMPassSelectRollDocked,LPMPassSelectRollPos[1],LPMPassSelectRollPos[2])
	)

	fn write_LPM_Pass_Settings = 
	(
		
		try
		(
			var_settingsFile_LPM_Pass = (getDir #plugCFG) + "\\LPM_Pass_Settings.ini"
			
			temp_flag = case LPMPassSelectRollDocked of
			(
				true:1
				false:0
				default:1
			)
			setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollDocked" (temp_flag as string)
			
			
			setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_x" (LPMPassSelectRollPos[1] as string)
			setINISetting var_settingsFile_LPM_Pass "LPM_Pass_Settings" "LPMPassSelectRollPos_y" (LPMPassSelectRollPos[2] as string)
			
		)
		catch
		(
		)
		
	)

	fn dotNetColor clr =
	(
		(dotNetClass "System.Drawing.Color").fromARGB clr.r clr.g clr.b
	)

	fn SetDDLColor =
	(
		TmpCurUIColor = "Light"
		
		CurUIColorCol = colorMan.getColor #timeSliderBg
		if CurUIColorCol[1] < 0.6 then
		(
			TmpCurUIColor = "Dark"
		)
		
		TmpBackColor = dotNetColor (color 225 225 225)
		TmpFontColor = dotNetColor (color 0 0 0)
		
		if (TmpCurUIColor == "Dark") then
		(
			TmpBackColor = dotNetColor (color 85 85 85)
			TmpFontColor = dotNetColor (color 200 200 200)
		)
		
		#(TmpBackColor,TmpFontColor)
	)
	
	fn LPMPassSelectUpdateList DDL_Passes =
	(
		
		try
		(
			passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
			namesArray=for it in passArray collect (LPM_Fun.getName it.name)
			
			DDL_Passes.items.Clear ()
			
			for i = 1 to namesArray.count do
			(
				DDL_Passes.items.add (LPM_Fun.generatePassName passArray[i])  ---namesArray[i]
				if LPM_activePass != undefined then
				(
					if LPM_activePass == passArray[i] then
					(
						DDL_Passes.SelectedIndex = i-1
					)
				)
			)
			
			--if namesArray.count>0 then
			--(
			--	DDL_Passes.SelectedIndex = 0
			--)
		)
		catch
		(
			DDL_Passes.items.Clear ()
			DDL_Passes.items.add "Passes List"
			DDL_Passes.SelectedIndex = 0
		)
		
	)


	rollout LPMPassSelectRoll "LPM Pass Select" width:220 height:34
	(
		dotNetControl DDL_Passes "system.windows.forms.ComboBox" pos:[2,5] width:180 height:21
			
		button dock_btn "-" pos:[204,16] width:15 height:14 images:#(iconPath+"minimize_btn.bmp",undefined,1,1,1,1,1,true)
		button close_btn " X" pos:[204,2] width:15 height:14 images:#(iconPath+"Close_btn.bmp",undefined,1,1,1,1,1,true)
		checkbutton ckbView "V" pos:[183,5] width:21 height:21 images:#(iconPath+"Preview_pass_btn.bmp",undefined,2,2,1,2,1,true)
		
		fn UpdateLPMPassSelectRoll =
		(
			LPMPassSelectUpdateList DDL_Passes
		)
		
		on LPMPassSelectRoll open do 
		(
			read_LPM_Pass_Settings()
			
			tmpColor = SetDDLColor()
			
			DDL_Passes.backColor = tmpColor[1]
			DDL_Passes.ForeColor = tmpColor[2]
			
			LPMPassSelectUpdateList DDL_Passes
			
		)
		
		on dock_btn pressed do 
		(
			
			cui.FloatDialogBar LPMPassSelectRoll
			cui.UnRegisterDialogBar LPMPassSelectRoll
			LPMPassSelectRollDocked = false
			
			setdialogpos LPMPassSelectRoll LPMPassSelectRollPos
			
			cui.RegisterDialogBar LPMPassSelectRoll style:#(#cui_dock_all, #cui_floatable, #cui_handles)
		)
		
		on close_btn pressed do 
		(
			
			close_btn_pressed = true
			
			if ((cui.getDockState LPMPassSelectRoll) == #cui_floatable) then
			(
				
				LPMPassSelectRollPos = getdialogpos LPMPassSelectRoll
				LPMPassSelectRollDocked = false
			)
			else
			(
				LPMPassSelectRollDocked = true
			)
			write_LPM_Pass_Settings()
			
			cui.FloatDialogBar LPMPassSelectRoll
			cui.UnRegisterDialogBar LPMPassSelectRoll
			DestroyDialog LPMPassSelectRoll
		)
		
		on LPMPassSelectRoll close do 
		(
			if not close_btn_pressed then
			(
				
				LPMPassSelectRollPos = getdialogpos LPMPassSelectRoll
				LPMPassSelectRollDocked = false
				
				write_LPM_Pass_Settings()
			)
		)
		
		on ckbView changed state do
		(
			if state then
			(
				try
				(
					LPM_treeview_rollout.hideByActivePass()
				)
				catch()
			)
			
			if (not (keyboard.shiftPressed)) then
			(
				ckbView.state = false
			)
		)
		
		On DDL_Passes Click do
		(
			LPMPassSelectUpdateList DDL_Passes
		)
		
		on DDL_Passes SelectionChangeCommitted do-- SelectedIndexChanged do
		(
			try
			(
				tmpIndex = DDL_Passes.SelectedIndex +1
				
				passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
				
				if passArray[tmpIndex] != undefined then
				(
					LPM_activePass = passArray[tmpIndex]
					try
					(
						LPM_treeview_rollout.updatePassDDL()
					)
					catch()
					
					if ckbView.state then
					(
						try
						(
							LPM_treeview_rollout.hideByActivePass()
						)
						catch()
					)
				)
			)
			catch
			(
			)
		)
		
	)


	CreateDialog LPMPassSelectRoll  minSize:[220,34] maxSize:[220,34]

	--if LPMPassSelectRollDocked then
	--(
	--	cui.RegisterDialogBar LPMPassSelectRoll style:#(#cui_dock_horz, #cui_floatable, #cui_handles)
	--	cui.DockDialogBar LPMPassSelectRoll #cui_dock_top
	--)
	--else
	--(
		setdialogpos LPMPassSelectRoll LPMPassSelectRollPos
		cui.RegisterDialogBar LPMPassSelectRoll style:#(#cui_dock_all, #cui_floatable, #cui_handles)
	--)width:180 height:21
)