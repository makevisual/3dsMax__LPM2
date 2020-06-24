clearListener()
print (timeStamp())

nukeFilePath = @"Y:\Projects\Meccano - Fall 2020\SPOT__Meccano_30s\SHOT_Intro-010\Comps\Composite\Meccano_30s__SHOT_Intro-010__Composite_v001.nk"

struct nukeDataStr
(
	-- properties read from nuke script
	name 					= undefined,
	first_frame 			= undefined,
	last_frame 				= undefined,
	format 					= undefined,

	-- properties inferred from nuke script
	resolution				= undefined,
	shot_name 				= undefined,
	shot_dir 				= undefined,
	project_name			= undefined,
	project_dir				= undefined,
	reference_dir 			= undefined,
	output_dir 				= undefined,

	end 					= "end"
)

function getFileData arg_nukeData arg_nukeFilePath arg_filePart  = 
(
	--arg_nukeData: the nukeData object to return the information on
	--arg_nukeFilePath: the path of the nuke script 
	--arg_filePart: the part of the file to index 

	nukeData = nukeDataStr()
	nukeFile = openFile arg_nukeFilePath mode:"r"
	nukeFileParts = #()

	while not eof nukeFile do
	(
		if (readLine nukeFile) == arg_filePart then exit   
	)
	
	while not eof nukeFile do
	(
		curline = (readLine nukeFile)
	
		if curline == "}" then exit  
		else
		(
			append nukeFileParts curline
		)
	)
	
	close nukeFile
	
	-- Search throuh the entries for certian file types and add them to the data object
	for nukeFilePart in nukeFileParts do 
	(
	  	curEntry = nukeFilePart
		curEntryParts = ( filterstring curEntry " " )
	
		if curEntryParts[1] == "name" 			then nukeData.name 			= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
		if curEntryParts[1] == "first_frame" 	then nukeData.first_frame 	= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
		if curEntryParts[1] == "last_frame" 	then nukeData.last_frame 	= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
		if curEntryParts[1] == "format" 		then nukeData.format 		= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
	)
)

function inferFileData arg_nukeData = 
(
	-- Find Project Dir Shot name and Project Name
	nukeFilePath= arg_nukeData.name
	pathParts 		= filterstring nukeFilePath @"/"  -- Slash may need to be switched?
	projectPath = "" 
	for i in 1 to pathParts.count do 
	(
		projectPath += ( pathParts[i] + @"\" )

		if pathParts[i] == "Projects"
		then
		(
		projectPath += ( pathParts[ (i+1 ) ] + @"\" )
		arg_nukeData.project_dir = projectPath
		arg_nukeData.project_name = pathParts[ (i+1 ) ]
		arg_nukeData.shot_name = pathParts[ (i+3 ) ]
		arg_nukeData.shot_dir = ( projectPath + pathParts[ (i+2 ) ] + @"\" + pathParts[ (i+3 )] + @"\")
		exit
		)
	)

	-- Find Resolution 
	formatParts = filterstring nukeData.format " "
	nukeData.resolution = [( formatParts[1] as float ),( formatParts[2] as float ) ]


	nukeData.reference_dir = ( nukeData.shot_dir + @"Reference\v001\" )
	nukeData.output_dir = ( nukeData.shot_dir + @"Image_Sequences\" )

)

nukeData = nukeDataStr() 						-- Create a Nuke Data Object 
getFileData nukeData nukeFilePath "Root {"  	-- Populate it with data from the file 
inferFileData nukeData 							--Infer the rest of the data



print nukedata.name 		
print nukedata.first_frame 
print nukedata.last_frame 	
print nukedata.format 		
print nukedata.resolution	
print nukedata.shot_name 	
print nukedata.shot_dir 	
print nukedata.project_name
print nukedata.project_dir	
print nukedata.reference_dir 
print nukedata.output_dir 	