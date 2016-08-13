# Script to remove a lot of the pre-loaded 3rd-party Metro "modern app" bloatware
# Initial creation by /u/kronflux
# Method created by Garacesh at:  http://www.edugeek.net/forums/windows-10/161433-windows-10-removal-off-preinstalled-apps-bulk-sans-store.html#post1398039
# Modified for use with the Tron project by /u/vocatus on reddit.com/r/TronScript
# Modified again for use with the Quorra/OEM_Cleanup project

# Add take ownership module
Import-Module -DisableNameChecking $PSScriptRoot\take-own.psm1

$ErrorActionPreference = "SilentlyContinue"

echo "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

echo "Removing Third Party Windows Apps"

$appPackages = @(

	# Third Party Apps

	"06DAC6F6.StumbleUpon"
	"134D4F5B.Box"
	"1430GreenfieldTechnologie.PuzzleTouch"
	"26720RandomSaladGamesLLC.HeartsDeluxe"
	"26720RandomSaladGamesLLC.SimpleSolitaire"
	"29982CsabaHarmath.UnCompress"
	"4AE8B7C2.Booking.comPartnerEdition"
	"7906AAC0.TOSHIBACanadaPartners"
	"7906AAC0.ToshibaCanadaWarrantyService"
	"7digitalLtd.7digitalMusicStore"
	"9E2F88E3.Twitter"
	"A34E4AAB.YogaChef"
	"AccuWeather.AccuWeatherforWindows8"
	"AcerIncorporated.AcerExplorer"
	"AcerIncorporated.GatewayExplorer"
	"AD2F1837.HP"
	"AdobeSystemsIncorporated.AdobePhotoshopExpress"
	"AdobeSystemsIncorporated.AdobeRevel"
	"Amazon.com.Amazon"
	"AppUp.IntelAppUpCatalogueAppWorldwideEdition"
	"ASUSCloudCorporation.MobileFileExplorer"
	"B9ECED6F.ASUSGIFTBOX"
	"BD9B8345.AlbumbySony"
	"BD9B8345.MusicbySony"
	"BD9B8345.Socialife"
	"BD9B8345.VAIOCare"
	"BD9B8345.VAIOMessageCenter"
	"ChaChaSearch.ChaChaPushNotification"
	"ClearChannelRadioDigital.iHeartRadio"
	"CrackleInc.Crackle"
	"CyberLinkCorp.ac.AcerCrystalEye"
	"CyberLinkCorp.ac.SocialJogger"
	"CyberLinkCorp.hs.YouCamforHP"
	"CyberLinkCorp.id.PowerDVDforLenovoIdea"
	"DailymotionSA.Dailymotion"
	"DellInc.DellShop"
	"E046963F.LenovoCompanion"
	"E046963F.LenovoSupport"
	"E0469640.CameraMan"
	"E0469640.DeviceCollaboration"
	"E0469640.LenovoRecommends"
	"E0469640.YogaCameraMan"
	"E0469640.YogaPhoneCompanion"
	"E0469640.YogaPicks"
	"eBayInc.eBay"
	"EncyclopaediaBritannica.EncyclopaediaBritannica"
	"esobiIncorporated.newsXpressoMetro"
	"Evernote.Evernote"
	"Evernote.Skitch"
	"F5080380.ASUSPhotoDirector"
	"F5080380.ASUSPowerDirector"
	"FilmOnLiveTVFree.FilmOnLiveTVFree"
	"fingertappsASUS.FingertappsInstrumentsrecommendedb"
	"fingertappsasus.FingertappsOrganizerrecommendedbyA"
	"fingertappsASUS.JigsWarrecommendedbyASUS"
	"FingertappsInstruments"
	"FingertappsOrganizer"
	"Flipboard.Flipboard"
	"FreshPaint"
	"GameGeneticsApps.FreeOnlineGamesforLenovo"
	"GAMELOFTSA.SharkDash"
	"GettingStartedwithWindows8"
	"HPConnectedMusic"
	"HPConnectedPhotopoweredbySnapfish"
	"HPRegistration"
	"JigsWar"
	"KasperskyLab.KasperskyNow"
	"KindleforWindows8"
	"MAGIX.MusicMakerJam"
	"McAfee"
	"McAfeeInc.05.McAfeeSecurityAdvisorforASUS"
	"Microsoft.MinecraftUWP"
	"MobileFileExplorer"
	"MusicMakerJam"
	"NAMCOBANDAIGamesInc.PAC-MANChampionshipEditionDXfo"
	"NAVER.LINEwin8"
	"Netflix"
	"PinballFx2"
	"PublicationsInternational.iCookbookSE"
	"RandomSaladGamesLLC.GinRummyProforHP"
	"ShazamEntertainmentLtd.Shazam"
	"sMedioforHP.sMedio360"
	"sMedioforToshiba.TOSHIBAMediaPlayerbysMedioTrueLin"
	"SymantecCorporation.NortonStudio"
	"TelegraphMediaGroupLtd.TheTelegraphforLenovo"
	"TheNewYorkTimes.NYTCrossword"
	"toolbar"
	"TripAdvisorLLC.TripAdvisorHotelsFlightsRestaurants"
	"TuneIn.TuneInRadio"
	"UptoElevenDigitalSolution.mysms-Textanywhere"
	"Weather.TheWeatherChannelforHP"
	"Weather.TheWeatherChannelforLenovo"
	"WildTangentGames"
	"YouSendIt.HighTailForLenovo"
	"ZinioLLC.Zinio"
	"zuukaInc.iStoryTimeLibrary"

)

foreach ($appPackage in $appPackages) {
	echo "Attempting to remove $appPackage"

    Get-AppxPackage -AllUsers -Name $appPackage | Remove-AppxPackage | Out-Null
	Get-AppxPackage -AllUsers | Where-Object Name -In $appPackage | Remove-AppxPackage | Out-Null

    Get-AppXProvisionedPackage -Online | where DisplayName -EQ $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppxProvisionedPackage -Online | Where-Object Name -In $appPackage | Remove-AppxProvisionedPackage -Online | Out-Null

	Remove-AppxPackage $(Get-AppxPackage | where {$_.name -like "*" + $appPackage + "*"}).PackageFullName | Out-Null

}
