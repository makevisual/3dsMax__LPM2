# NewVersion.py build by Aaron Dabelow theonlyaaron@gmail.com for aiding in versioning maxscripts and their installers
# Source information block must be updated each time the script is run to specify the original and new versions
# Update elements block must be updated for each script that this is used for. It is designed to help version easily

import shutil
from datetime import date

# Source information to be populated throughout the installation
versionedBy = "Aaron Dabelow theonlyaaron@gmail.com"
srcVersion = "2.6.4"
newVersion = "2.6.5"
curDir = "U:/Git/aarond/3dsMax__LPM2/"
folderName = "LPM_"

# Copy the current state to a new directory
srcVersionDir = curDir + folderName + srcVersion + "/"
newVersionDir = curDir + folderName + newVersion + "/"
shutil.copytree(srcVersionDir, newVersionDir, symlinks=False, ignore=None)

# Update elements within the new script
verNumberStr = "LPM_VersionNumber = \"" + newVersion + "\""
readmeFile = open(newVersionDir + "Release/Scripts/LPM/" + "VersionNumber.ms", 'w')
readmeFile.write(verNumberStr)
readmeFile.close()

# Update Readme
readmeFile = open(srcVersionDir + "readme.txt", 'r')
contentsOld = readmeFile.read()
readmeFile.close()

contentsNew = "---- " + folderName + newVersion + " ----\n"
contentsNew += "-- Date: " + str(date.today()) + "\n"
contentsNew += "-- Modifications by: " + versionedBy + "\n"
contentsNew += "-- Change Log:\n"
contentsNew += "\n"
contents = contentsNew + contentsOld

readmeFile = open(newVersionDir + "readme.txt", 'w')
readmeFile.write(contents)
readmeFile.close()

# Update Installer
installerFile = open(curDir + "install_2016.bat", 'w')
commandStr = (R"call %~dp0" + folderName + newVersion + "\\" + "install_2016.bat")
installerFile.write(commandStr)
installerFile.close()

print"Complete!"
