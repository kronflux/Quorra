# Script to remove a lot of the pre-loaded Microsoft Metro "modern app" bloatware
# Initial creation by Garacesh at:  http://www.edugeek.net/forums/windows-10/161433-windows-10-removal-off-preinstalled-apps-bulk-sans-store.html#post1398039
# Modified for use with the Tron project by /u/vocatus on reddit.com/r/TronScript
Import-Module -DisableNameChecking $PSScriptRoot\take-own.psm1

$ErrorActionPreference = "SilentlyContinue"

echo "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

echo "Removing Default Windows Apps"

$appPackages = @(

	# Microsoft Apps

	"Microsoft.3DBuilder"                    			# '3DBuilder' app
	"Microsoft.BingFinance"                  			# 'Money' app - Financial news
	"Microsoft.BingFoodAndDrink"             			# 'Food and Drink' app
	"Microsoft.BingHealthAndFitness"         			# 'Health and Fitness' app
	"Microsoft.BingTranslator"               			# 'Translator' app - Bing Translate
	"Microsoft.BingTravel"                   			# 'Travel' app
	"Microsoft.FreshPaint"                   			# 'Canvas' app
	"Microsoft.Getstarted"                   			# 'Get Started' link
	"Microsoft.MicrosoftJackpot"            			# 'Jackpot' app
	"Microsoft.MicrosoftJigsaw"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"			# Solitaire collection
	"Microsoft.MicrosoftSudoku"
	"Microsoft.MinecraftUWP"							# Minecraft for Windows 10 app
	"Microsoft.MovieMoments"
	"Microsoft.Office.OneNote"               			# 'Onenote' app
	"Microsoft.Office.Sway"                  			# 'Sway' app
	"Microsoft.SkypeApp"                     			# 'Get Skype' link
	"Microsoft.SkypeWiFi"
	"Microsoft.Studios.Wordament"
	"Microsoft.Taptiles"
	"Microsoft.WindowsAlarms"                			# 'Alarms and Clock' app
	"Microsoft.WindowsFeedback"              			# 'Feedback' functionality
	"Microsoft.WindowsPhone"                 			# 'Phone Companion' app
	"Microsoft.XboxApp"
	"Microsoft.ZuneMusic"								# 'Groove Music' app
	"Microsoft.ZuneVideo"                    			# Groove Music
	"MicrosoftMahjong"
	"Windows.ContactSupport"

	# Third Party Apps

	"9E2F88E3.Twitter"                        			# Twitter app
	"AdobeSystemsIncorporated.AdobePhotoshopExpress"
	"ClearChannelRadioDigital.iHeartRadio"
	"Flipboard.Flipboard"
	"king.com.CandyCrushSaga"
	"king.com.CandyCrushSodaSaga"            			# Candy Crush app
	"ShazamEntertainmentLtd.Shazam"

	# Disabled Removals

	#"Microsoft.Appconnector"
	#"Microsoft.BingNews"                     			# 'Generic news' app
	#"Microsoft.BingSports"                   			# 'Sports' app - Sports news
	#"Microsoft.BingWeather"                  			# 'Weather' app
	#"Microsoft.BioEnrollment"
	#"Microsoft.CommsPhone"                   			# 'Phone' app
	#"Microsoft.ConnectivityStore"
	#"Microsoft.MicrosoftEdge"							# 'Edge' browser app
	#"Microsoft.Windows.Cortana"						# 'Cortana' search assistant
	#"Microsoft.Windows.Photos"							# 'Photos' app
	#"Microsoft.WindowsAlarms"                			# 'Alarms and Clock' app
	#"Microsoft.WindowsCalculator"						# 'Calculator' app
	#"microsoft.windowscommunicationsapps"
	#"Microsoft.WindowsMaps"							# 'Maps' app
	#"Microsoft.WindowsSoundRecorder"					# 'Sound Recorder' app
	#"Microsoft.WindowsStore"							# Windows Store
	#"Microsoft.XboxGameCallableUI"
	#"Microsoft.XboxIdentityProvider"
)

foreach ($appPackage in $appPackages) {
    Get-AppxPackage -Name $appPackage -AllUsers | Remove-AppxPackage | Out-Null
	Get-AppxPackage –AllUsers | Where-Object Name -In $appPackage | Remove-AppxPackage | Out-Null
    Get-AppXProvisionedPackage -Online | where DisplayName -EQ $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppxProvisionedPackage -Online | Where-Object Name -In $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null
	remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*" + $appPackage + "*"}).PackageFullName | Out-Null
}
