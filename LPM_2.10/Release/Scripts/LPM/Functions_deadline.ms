Struct LPM_FunctionsDeadlineStr
(

	-- Gets the automatic Deadline Path
	function LPM_FunDeadline =
	(
		try 	( return (dotNetClass "System.Environment").GetEnvironmentVariable "DEADLINE_REPOSITORY_PATH" )
		catch 	( return "DEADLINE_REPOSITORY_PATH Environment Variable not set" )
	),

	function test = ( print "LPM_FunctionsDeadline Loaded")
)

LPM_FunDeadline=(LPM_FunctionsDeadlineStr())

--LPM_FunDeadline.LPM_FunDeadline()