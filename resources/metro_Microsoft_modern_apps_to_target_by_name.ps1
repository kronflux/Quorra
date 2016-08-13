# Script to remove a lot of the pre-loaded Microsoft Metro "modern app" bloatware
# Initial creation by Garacesh at:  http://www.edugeek.net/forums/windows-10/161433-windows-10-removal-off-preinstalled-apps-bulk-sans-store.html#post1398039
# Modified for use with the Tron project by /u/vocatus on reddit.com/r/TronScript
# Modified again for use with the Quorra/OEM_Cleanup project

# Add take ownership module
Import-Module -DisableNameChecking $PSScriptRoot\take-own.psm1

$ErrorActionPreference = "SilentlyContinue"

echo "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

echo "Removing Default Windows Apps"

$appPackages = @(

	# Microsoft Apps

	"Microsoft.3DBuilder"
	"Microsoft.Advertising.Xaml"
	"Microsoft.BingFinance"
	"Microsoft.BingFoodAndDrink"
	"Microsoft.BingHealthAndFitness"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingTranslator"
	"Microsoft.BingTravel"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.FreshPaint"
	"Microsoft.Getstarted"
	"Microsoft.MicrosoftJackpot"
	"Microsoft.MicrosoftJigsaw"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MicrosoftSudoku"
	"Microsoft.MinecraftUWP"
	"Microsoft.MovieMoments"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.OneConnect"
	"Microsoft.SkypeApp"
	"Microsoft.SkypeWiFi"
	"Microsoft.Studios.Wordament"
	"Microsoft.Taptiles"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsCamera"
	"Microsoft.WindowsFeedback"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsPhone"
	"Microsoft.XboxApp"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"MicrosoftMahjong"
	"Windows.ContactSupport"

	# Third Party Apps

	"4DF9E0F8.Netflix"
	"9E2F88E3.Twitter"
	"D52A8D61.FarmVille2CountryEscape"
	"ClearChannelRadioDigital.iHeartRadio"
	"Flipboard.Flipboard"
	"GAMELOFTSA.Asphalt8Airborne"
	"king.com.CandyCrushSaga"
	"king.com.CandyCrushSodaSaga"
	"PandoraMediaInc.29680B314EFC2"
	"ShazamEntertainmentLtd.Shazam"
	"TheNewYorkTimes.NYTCrossword"
	
	# Disabled Removals

	#"Microsoft.AAD.BrokerPlugin"
	#"Microsoft.AccountsControl"
	#"Microsoft.Appconnector"
	#"Microsoft.BioEnrollment"
	#"Microsoft.ConnectivityStore"
	#"Microsoft.DesktopAppInstaller"
	#"Microsoft.LockApp"
	#"Microsoft.Messaging"
	#"Microsoft.MicrosoftEdge"
	#"Microsoft.MicrosoftStickyNotes"
	#"Microsoft.NET.Native.Framework.1.3"
	#"Microsoft.NET.Native.Runtime.1.3"
	#"Microsoft.People"
	#"Microsoft.PPIProjection"
	#"Microsoft.StorePurchaseApp"
	#"Microsoft.VCLibs.140.00"
	#"Microsoft.Windows.Apprep.ChxApp"
	#"Microsoft.Windows.CloudExperienceHost"
	#"Microsoft.Windows.ContentDeliveryManager"
	#"Microsoft.Windows.Cortana"
	#"Microsoft.Windows.ParentalControls"
	#"Microsoft.Windows.Photos"
	#"Microsoft.Windows.SecondaryTileExperience"
	#"Microsoft.Windows.ShellExperienceHost"
	#"Microsoft.WindowsCalculator"
	#"Microsoft.WindowsCamera"
	#"microsoft.windowscommunicationsapps"
	#"Microsoft.WindowsSoundRecorder"
	#"Microsoft.WindowsStore"
	#"Microsoft.XboxGameCallableUI"
	#"Microsoft.XboxIdentityProvider"
	#"windows.immersivecontrolpanel"
	#"Windows.MiracastView"
	#"Windows.PrintDialog"

)

foreach ($appPackage in $appPackages) {
	echo "Attempting to remove $appPackage"

    Get-AppxPackage -AllUsers -Name $appPackage | Remove-AppxPackage | Out-Null
	Get-AppxPackage -AllUsers | Where-Object Name -In $appPackage | Remove-AppxPackage | Out-Null

    Get-AppXProvisionedPackage -Online | where DisplayName -EQ $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppxProvisionedPackage -Online | Where-Object Name -In $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null

	Remove-AppxPackage $(Get-AppxPackage | where {$_.name -like "*" + $appPackage + "*"}).PackageFullName | Out-Null

}
