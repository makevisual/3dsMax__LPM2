---- LPM_2.6.5 ----
-- Date: 2020-03-23
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

---- LPM_2.6.4 ----
-- Date: 2019-09-03
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

---- LPM_2.6.0 ----
-- Date: 2017-10-11
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Tyson change: optimizedLoadRenderPreset was enabling ref messages before re-enabling modifiers, which was causing unnecessary
re-triggers of notification events throughout max (triggering tflow resims, etc). I moved enableRefMsgs() to the end

---- LPM_2.5.4 ----
-- Date: 2017-03-24
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Sped up idiot checks
Added new idiot checks
 Hair Farm render settings
 Progressive renderer warning
 Camera view lock warning
added hold on submit, which if enabled will automatically restore your scene if the script crashes while submitting.
Added support for the Vray VFB
Added a control to blanket disable the vray VFB if wanted
Fixed viewport display vertex display bug that showed up post preview
Sped up submission
Made logging more verbose to help troubleshoot long or troublesome submissions

---- LPM_2.5.3 ----
-- Date: 2016-12-03
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

---- LPM_2.5.2 ----
-- Date: 2016-08-25
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Added VRay DR auto-set on launch - restart dr slaves on render end: true - setting for distributed rendering reliablitly.

---- LPM_2.5.1 ----
-- Date: 2016-08-01
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

Configured to run completly off of a network
Configured to work with 3dsMax 2017 and the new UI elements
Fixed error loading Deadline user
Fixed UI bug - Unable to click in job comment
Fixed UI bug - Job comment being "Super Sticky" and spreadding around into places it shouldnt be
default rendertype now set to passes

---------------------------------------------
TODO:
note property on passes
delete shots bug
Add Tiles to the network renderer

---- LPM_2.4.3 ----
-- Date: 2016-05-12
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

---- LPM_2.4.2 ----
-- Date: 2016-03-28
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

---- LPM_2.4.1 ----
-- Date: 2016-03-24
-- Modifications by: Tyson Ibele
-- Change Log:

Optimized render preset loading (approx 10x faster on heavy scenes)
Optimized post-render material assignment 

---- LPM_2.4.0 ----
-- Date: 2016-02-22
--Modifications by: Tyson Ibele
--Change Log:

Force render element generation on LPM open

---- LPM_2.3.3 ----
-- Date: 2016-01-14
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:

idiot check - checks if any render elements are set to active, when they should all be disabled
idiot check - elements enabled with no elements in the scene warning
Fix trailing A in submission name
submitter - Rebuild elements on by default
beauty pass quick script - make mattes default to being reflective
beauty pass quick script - added reflectors object set
an override property was added to the light set that enables / disables visibility on vray lights withing a try / catch for saftey.

---- LPM_2.3.1 ----
-- Date: 2015-11-24
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Added Default render elements auto creation utility
Added render elements utilities to the menubar ( AO / Depth tools )
Added Element default pass quickscript
Set default pass naming value to $Shot\$APass$Pass$Element\$APass$Pass$Element
	This allows the render elements to be placed in subfolders
Frame Range Submit override settings added

---- LPM_2.2.6 ----
-- Date: 2015-10-30
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Fixed group deadline override and submission conflict bug
Made comment field sticky
Brought back the progressbar, and changed placement
Cleaned up some Junk DNA and organized layout

---- LPM_2.2.5 ----
-- Date: 2015-10-29
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Fixed bug with vray override built from presets not working.
Fixed vray storing properties under expert tabs, not saving when using "render override" with a vray renderer
'Fixed' crash when attempting to submit to network render, when not connected to the network

---- LPM_2.2.4 ----
-- Date: 2015-09-10
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Fixed removing passes out of sequence bug
made output location auto generate for valid scenes
made output location button/set options

---- LPM_2.2.3 ----
-- Date: 2015-09-02
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Fixed bug in preview mode
Fixed default RPF override camera settings in both Rpf Quickscripts
( fix or disable Vray Frame Buffer on the farm ) got to the bottom of the issue

---- LPM_2.2.2 ----
-- Date: 2015-08-31
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Added quickscript passes for
 - Beauty
 - AO Adjustment
 - AO Pass
 - RPFindex Adjustment
 - RPFindex Pass
 - Falloff Adjustment
 - Shadow Pass
 - Reflection Light
 - Reflection Dark
 - Krakatoa Pass
 - FumeFX Pass

---- LPM_2.2.1 ----
-- Date: 2015-08-28
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Completed Deadline Override

---- LPM_2.1.5 ----
-- Date: 2015-08-19
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Added Deadline Override
Submission of task size is and has now fixed
Updated icon colors
Fixed submission and update bugs

---- LPM_2.1.4 ----
-- Date: 2015-08-18
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Changed "Enabled" icons from white to green
Added 'remove limits' button to clear them out after ones are chosen
Fixed autodraft button update, and submission bug
Add timers back into submitter
Made the redo 'Idiot check' button work....
Added timer to idiot check
color warn for submitting as suspended
Made default pass creation use the appropriate function ( with all objects and lights disabled )
add autodraft upload check to prevent submitting an upload without valid destination

---- LPM_2.1.3 ----
-- Date: 2015-08-17
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Set default pass naming value to "$Shot\$APass$Pass\$APass$Pass_"
Set default filetype to .exr
Fixed hidden UI buttons for create object set
added disabled object and light set wildcards to default pass creation
added custom comment on submission
added limit groups utility to the submitter
added startup StartJobTimeout control to submitter
added startup StartJobTimeoutEnabled to SMTDSettings in SubmitMaxToDeadline_Functions.ms ( Altering original SMTDSettings class!!!! )
added startup StartJobTimeoutSeconds to SMTDSettings in SubmitMaxToDeadline_Functions.ms ( Altering original SMTDSettings class!!!! )
Autodraft enabled
Autodraft Upload enabled

---- LPM_2.1.2 ----
-- Date: 2015-08-14
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Built versioning script ( located in the administrative folder ) for aid in versioning the softare.
Added many many features to the deadline submitter
Corrected Delimiter bug with deadline 7.1 
Moved Camera selection DDL back into the treeview
Moved Resolution DDL back into the treeview
Moved Rendermode DDL back into the treeview
Removed the autospace buttons when scaling the ui
Rebuild the Deadline 7.1 submitter UI
Sucsussfully merged the Vray operator added by Tyson Ibele
Fixed vray operator icons bug
Fixed vray operator colors bug

---- LPM_2.1.1 ----
-- Date: 2015-08-10
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
Initial hybridization of LPM++ ( Developed for MAKE ( www.makevisual.com )) and LPM2 created by grover gol for Altspace, both of which were derived from LPM 1.09 by Lucas Lepicovsky
LPM++ Deadline 7.1 submitter hybridized with LPM2 Deadline 7 submitter as well.

---- LPM_2.1.0 ----
-- Date: 2015-08-6
-- Modifications by: grover gol ( http://www.grovergol.com/ )
-- Change Log:
LPM is the render pass manager for 3ds Max, which was developed by me in Altspace.
It significantly simplifies the process of creating and managing render passes.
With the intuitive user interface you can quickly create an unlimited number of passes in a single output file.
LPM is easy to install and configure, it’s based on native Max script and works with 3ds Max 2012 and above.
It supports network rendering using Autodesk Backburner and Thinkbox Deadline, and does not require separate installation on a render farm’s computers.
LPM supports all popular rendering systems, including V-Ray 3.0 and Corona renderer.
LPM provides a large variety of different settings in each pass, making possibilities limitless, also the handy system of file naming templates lets you easily find your rendered output.

Thanks to all who participated in “lpm_pro_v1.096_max2014_beta1” developing (Lukas Lepicovsky, Jakub Jeziorski, Mike Samoilov, John Martini, Royce Ghost).
It was good start for me in august 2014.