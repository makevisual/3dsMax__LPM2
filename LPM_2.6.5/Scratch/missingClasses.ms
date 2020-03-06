clearlistener()

fn getMissingPluginClasses = 
(
	str = stringStream ""
	apropos "*missing*" to:str
	seek str 0
	missingClasses = #()
	while not (eof str) do
	(
		ln = readLine str
		tk = filterString ln " "
		if tk.count == 4 then (
			clsName = tk[1]
			try
			(
				val = (execute clsName)
				sc = superClassOf val
				if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then
				(
					append missingClasses val
				)
				else ()
			)
			catch ()
		)
		else ()
	)
	return missingClasses
)

fn getMissingPlugins =
(
	c = 0
	foundMissing = #()
	for j = 1 to cls.count do (
		cc = cls[j]
		ci = getClassInstances cc
		if ci.count > 0 then (
			format "%: Found % instances of %: %\n" j ci.count cc ci
			for i = 1 to ci.count do (
				-- get current class
				myClass = classOf cc
				append foundMissing myClass
				-- get list of all subclasses
				allClasses = myClass.classes
				for k = 1 to allClasses.count do (
					-- search for useful replacement
					if allClasses[k].creatable then (
						-- create new instance of default (first) class
						newInst = createInstance allClasses[k]
						try (
							-- replace all instances (requires 3ds Max 2008+ or AVG extensions)
							q = replaceInstances ci[i] newInst
							c += 1
							-- and exit for k loop
							exit
						) catch (
							format "Error replacing %\n" ci[i]
							format "Exception: %\n" (getCurrentException())
						)
					)
				) -- end: for k
				-- todo: what happens if NO useful replacement was found?
			) -- end: for i
		) -- end: if
	) -- end: for j
)

getMissingPlugins()