/*
Lukas Lepicovsky / Jakub Jeziorski
L Pass Manager
lukashi@gmail.com
www.lukashi.com

	
	
	
	Modified by grover_gol ( http://gg3dcg.ru/ ) for Altspace  ( http://altspace.com/ )  2015
	
	
*/


macroscript LPM category:"Altspace" icon:#("LPM",1)
(
	if doesfileexist "$MAX/scripts/LPM/include_altspace.ms" then
	(
		filein "$MAX/scripts/LPM/include_altspace.ms"
	)
	else
	(
		filein "$MAX/scripts/LPM/include.ms"
	)
	
)


--render preview macro script
macroscript LPM_RenderPass category:"Altspace" icon:#("LPM_100",1) tooltip:"Renders the Active Pass, defaults to max render when a pass is not found."
(

	if(isvalidnode LPM_activePass) then
	(
			LPM_renderPass LPM_activePass #preview
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			if doesfileexist "$MAX/scripts/LPM/include_altspace.ms" then
			(
				filein "$MAX/scripts/LPM/include_altspace.ms"
			)
			else
			(
				filein "$MAX/scripts/LPM/include.ms"
			)
			
			messagebox "LPM Data found, but no pass has been picked.  Please pick a pass and hit render again."
			
		)
		else
			max quick render
	)
	
)

--render previewHalf macro script
macroscript LPM_RenderPassHalf category:"Altspace" icon:#("LPM_50",1) tooltip:"Renders the Active Pass at half resolution, defaults to max render when a pass is not found."
(

	if(isvalidnode LPM_activePass) then
	(
		LPM_renderPass LPM_activePass #previewHalf
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			if doesfileexist "$MAX/scripts/LPM/include_altspace.ms" then
			(
				filein "$MAX/scripts/LPM/include_altspace.ms"
			)
			else
			(
				filein "$MAX/scripts/LPM/include.ms"
			)
			messagebox "LPM Data found, but no pass has been picked.  Please pick a pass and hit render again."
		)
		else
			max quick render
	)
)

