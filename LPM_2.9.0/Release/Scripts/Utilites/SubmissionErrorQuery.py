# Imports
import os
import configparser 
from collections import namedtuple
import datetime

timeRange = [[2023,8,2], [2023,8,2]]
timeRange = [None, None]

# Class for holding parsed information for an error report
class ReportInformation:
    def __init__(self, user, date_year, date_month, date_day, errorCount):
        self.user 			= user
        self.date_year 		= date_year
        self.date_month 	= date_month
        self.date_day 		= date_day
        self.errorCount 	= errorCount

# Class for holding parsed user information. This is intended to hold the collected 'ReportInformation' list, and can also have additional info stored.
class userReportsInformation:
	def __init__(self, user, reports, fileCount, errorCount, errorRate):
		self.user 			= user
		self.reports 		= reports
		self.fileCount 		= fileCount
		self.errorCount 	= errorCount
		self.errorRate 		= errorRate

# Function for populating the ReportInformation class with the appropriate data. Returns a populated instance of the ReportInformation class.
def generateReport(argUser, argReportFile):

	reportFileParts = argReportFile.split ("__")
	
	# populate all properties
	date_year 	= None
	date_month 	= None
	date_day 	= None
	errorCount 	= None

	# Parse the date onto the props
	dateFileParts 	= reportFileParts[0].split ("_")
	date_year 		= dateFileParts[0]
	date_month 		= dateFileParts[1]
	date_day 		= dateFileParts[2]

	# Parse the error count to a prop as an integer
	errorCount = ( int ( reportFileParts[2].replace (".toml", "")))

	# Generate the report
	curReport = ReportInformation(argUser, date_year, date_month, date_day, errorCount)

	return curReport

# Function for returning the deadline repository ( currently hardcoded!!! ). Returns a filepath.
def getDeadlineRepo():

	# Declare Vars
	deadlineRepo = None  

	# !! Looks like configparser has some issues with the Deadline .ini file, assigning the path manually !!

	# programDataDir = os.environ.get('ProgramData')
	# DLini = ( programDataDir + "\\Thinkbox\\Deadline10\\deadline.ini" )
	# config = configparser.ConfigParser()
	# config.read("C:\\ProgramData\\Thinkbox\\Deadline10\\deadline.ini")  ## <---- here
	# deadlineRepo = config.get('Deadline','NetworkRoot')
	
	# Manual path
	deadlineRepo = R"M:\DeadlineRepository10\reports\MAKE\LPM"

	return deadlineRepo

# Function for collecting all the user folders in the deadline repoitorys error folder. Returns a list names of folders.
def getUsers():
	
	# Get the repository and collect the users within it
	lpmSubmissionReportDir = getDeadlineRepo()
	curUsers = [folder for folder in os.listdir(lpmSubmissionReportDir) if os.path.isdir(os.path.join(lpmSubmissionReportDir, folder))]

	return curUsers

# Function for collecting the filenames of all the user report files from a passed user folder name. Returns a list of filenames.
def collectUserReports(user):

	# Declare Vars
	repoDir		= getDeadlineRepo()			# this will always return the desired Deadline Repository
	userDir 	= (repoDir + "\\" + user)	# this is the current users folder
	validExt 	= ".toml" 					# this is the extension for valid error report file types
	curReports 	= [] 						# a new empty list for the errors 
	curReports 	= [] 						# a new empty list for the errors 
	
	# Get a list of all files with the specified extension in the folder
	file_list = [file for file in os.listdir(userDir) if file.endswith(validExt)]

	# Loop through the files of each report
	for file in file_list:
		
		# generate a userReport for each report file
		newUserReport = generateReport(user, file)







		# add it to the reports list
		curReports.append(newUserReport)



####--------- add date filter in here











#	reportsInTimeRange = []
#
#	if ( dateTimeStart == None ) and ( dateTimeEnd == None ):
#		reportsInTimeRange = userReports
#
#	if ( dateTimeStart != None ) and ( dateTimeEnd == None ):
#
#		filteredUserReports = []
#
#		for userReport in userReports:
#
#			for report in userReport.reports:
#
#				if int(report.date_year) >= dateTimeStart[0] and int(report.date_month) >= dateTimeStart[1] and int(report.date_day) >= dateTimeStart[2]:
#					
#					filteredUserReports.append(report)
#
#			userReport.reports = filteredUserReports
#
#			updateUserReportData(userReport)
#
#			reportsInTimeRange.append(userReport)
#
#		pass
#
#	if ( dateTimeStart == None ) and ( dateTimeEnd != None ):
#		
#		for userReport in userReports:
#
#			# print (userReport.user)
#
#			for report in userReport.reports:
#
#				if int(report.date_year) <= dateTimeEnd[0] and int(report.date_month) <= dateTimeEnd[1] and int(report.date_day) <= dateTimeEnd[2]:
#
#					filteredUserReports.append(report)
#
#			userReport.reports = filteredUserReports
#
#		pass
#
#	if ( dateTimeStart != None ) and ( dateTimeEnd != None ):
#
#		for userReport in userReports:
#
#			print (userReport.user)
#
#			for report in userReport.reports:
#
#				if int(report.date_year) >= dateTimeStart[0] and int(report.date_month) >= dateTimeStart[1] and int(report.date_day) >= dateTimeStart[2] and int(report.date_year) <= dateTimeEnd[0] and int(report.date_month) <= dateTimeEnd[1] and int(report.date_day) <= dateTimeEnd[2]:
#					
#					filteredUserReports.append(report)
#
#			userReport.reports = filteredUserReports
#
#		pass




















	# return the collected reports
	return curReports

def updateUserReportData(userReport):

		# Required class information
		curErrorCount 	= 0

		# Tally report file count and assign it
		userReport.curFileCount = len(userReport.reports)

		# Tally error count and assign it
		for report in userReport.reports: 
			#print(report.errorCount)
			curErrorCount += report.errorCount

		userReport.ErrorCount = curErrorCount

		# Calculate error rate and assign it ( try for divide by zero )
		try:
			userReport.errorRate = ( userReport.ErrorCount / userReport.curFileCount )
		except:
			userReport.errorRate = 0

# Gets the users, and for each user it collects the reports, then adds all of those together and returns all the users reports sorted as 'userReports'
def collectAllUserReports():
	
	curUsers 	= getUsers()
	userReports = []

	for user in curUsers: 

		# Required class information
		curUser 		= None
		curReports  	= None
		curFileCount 	= None
		curErrorCount 	= 0
		curErrorRate  	= None

		# Collect user
		curUser 		= user

		# Collect Reports, and add them to the reports list
		curReports 		= collectUserReports(user)

		# Tally report file count
		curFileCount = len(curReports)

		# Tally error count
		for report in curReports: 
			#print(report.errorCount)
			curErrorCount += report.errorCount

		# create a user report, and populate it with information
		curUserReport = userReportsInformation(curUser, curReports, curFileCount, curErrorCount, curErrorRate)
		userReports.append(curUserReport)

		# Calculate error rate
		curUserReport.errorRate = ( curErrorCount / curFileCount )

	return userReports

def analyzeReports(reports):
	for report in reports:
		print("----", report.user, "----")
		print("Total Report Count:	 	", 	report.fileCount)
		print("Total Error Count: 		", 	report.errorCount)
		print("Error Rate: 			", 	report.errorRate)	

def generateCSVtext(userReports):

	# declare Vars
	entryStr = "user,submissions,total error count,error rate\n"

	# generate the string for the file
	for report in userReports:

		print (report.user,report.fileCount,report.errorCount,report.errorRate)

		entryStr += report.user
		entryStr += ","
		entryStr += str(report.fileCount)
		entryStr += ","
		entryStr += str(report.errorCount)
		entryStr += ","
		entryStr += str(report.errorRate)
		entryStr += "\n"

	return entryStr

def generateCSV(reports):

	# Generate the output string based on time arguments passed
	outStr = generateCSVtext(reports)

	# Parse the CSV output directory
	repoDir 		= getDeadlineRepo()
	csvOutDir 		= repoDir.replace ("\\LPM", "\\LPM_UserReports")
	current_datetime = datetime.datetime.now()
	current_datetime_str = current_datetime.strftime("%Y_%m_%d__%H-%M-%S")

	# See if the folder exists, and make it if it does not
	if os.path.exists(csvOutDir) and os.path.isdir(csvOutDir):
		pass
	else:
		os.mkdir(csvOutDir)

	# Parse the CSV output filename and filepath
	csvFilename 	= ( "LPM_Users_Reports__" + current_datetime_str + ".csv" )
	csvOutFilePath 	= ( csvOutDir + "\\" + csvFilename )

	# write the entryStr to the csvOutFilePath
	with open(csvOutFilePath, 'w') as file:
		file.write(outStr)

	print("----", "CSV File export", "----")
	print(csvOutFilePath)


# Collect all user reports, analyze them, and generate a csv that has the data collected for a spreadsheet
allUserReports = collectAllUserReports()

# Call this function for a quick readout and analysis of all the reports
analyzeReports(allUserReports)

# generateCSV(allUserReports)