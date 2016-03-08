@echo off
echo Pokki Removal Started

rmdir /S "%LOCALAPPDATA%\Pokki" /Q >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Pokki /f >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PokkiDownloadHelper /f >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "Pokki" /f >nul 2>&1
reg delete HKCU\Software\Pokki /f >nul 2>&1
reg delete HKCR\AllFileSystemObjects\shell\pokki /f >nul 2>&1
reg delete HKCR\lnkfile\shell\pokki /f >nul 2>&1
reg delete HKCU\Software\Classes\Drive\shell\pokki /f >nul 2>&1
reg delete HKCU\Software\Classes\Directory\shell\pokki /f >nul 2>&1
reg delete HKCR\Pokki.PokkiDownloadHelper /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{4eb3fc20-7158-4dd5-a08e-707541e9341c}" /f >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\UFH\SHC /f >nul 2>&1
reg delete HKCR\CLSID\{A75BE48D-BF58-4A8B-B96C-F9A09DFB9844} /f >nul 2>&1
reg delete HKCR\pokki /f >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Pokki_Start_Menu /f >nul 2>&1
del /F /Q "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Pokki Start Menu.lnk" >nul 2>&1
del /F /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Pokki Start Menu.lnk" >nul 2>&1

echo Pokki Removal Complete
echo.
echo WildTangent and Games Removal Started

for /r "%ProgramFiles%\Acer Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Acer Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\Acer Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Acer Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\ASUS Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\ASUS Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\ASUS Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\ASUS Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\Dell Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Dell Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\Dell Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Dell Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\Gateway Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Gateway Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\Gateway Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Gateway Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\HP Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\HP Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\HP Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\HP Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\Lenovo Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Lenovo Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\Lenovo Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\Lenovo Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\TOSHIBA Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\TOSHIBA Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\TOSHIBA Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\TOSHIBA Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\WildTangent" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildTangent" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\WildTangent" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildTangent" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\WildTangent Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildTangent Games" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\WildTangent Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildTangent Games" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

for /r "%ProgramFiles%\WildGames" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildGames" %%i in (Uninstall.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles%\WildGames" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1
for /r "%ProgramFiles(x86)%\WildGames" %%i in (Uninstaller.exe) do ( if exist "%%i" "%%i" /silent ) >nul 2>&1

ECHO Starting InstallShield and NSIS removals...

echo Acer
:: Acer Backup Manager
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{9DDDF20E-9FD1-4434-A43E-E7889DBC9420}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{9DDDF20E-9FD1-4434-A43E-E7889DBC9420}\setup.exe" -runfromtemp -l0x0409 -removeonly >nul 2>&1
)
echo CyberLink
:: CyberLink LabelPrint
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{C59C179C-668D-49A9-B6EA-0121CCFC1243}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{C59C179C-668D-49A9-B6EA-0121CCFC1243}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink Media Suite 10
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{1FBF6C24-C1fD-4101-A42B-0C564F9E8E79}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{1FBF6C24-C1fD-4101-A42B-0C564F9E8E79}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink MediaEspresso
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{E3739848-5329-48E3-8D28-5BBD6E8BE384}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{E3739848-5329-48E3-8D28-5BBD6E8BE384}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink Photo Director 3
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{39337565-330E-4ab6-A9AE-AC81E0720B10}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{39337565-330E-4ab6-A9AE-AC81E0720B10}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: Cyberlink PhotoDirector 5
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{5A454EC5-217A-42a5-8CE1-2DDEC4E70E01}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{5A454EC5-217A-42a5-8CE1-2DDEC4E70E01}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink Power Media Player 14
if exist "%ProgramFiles(x86)%\NSIS Uninstall Information\{32C8E300-BDB4-4398-92C2-E9B7D8A233DB}\Setup.exe" (
"%ProgramFiles(x86)%\NSIS Uninstall Information\{32C8E300-BDB4-4398-92C2-E9B7D8A233DB}\Setup.exe" /S _?=C:\PROGRA~2\NSISUN~1\{32C8E300-BDB4-4398-92C2-E9B7D8A233DB} >nul 2>&1
)
:: CyberLink Power2Go 8
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{2A87D48D-3FDF-41fd-97CD-A1E370EFFFE2}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{2A87D48D-3FDF-41fd-97CD-A1E370EFFFE2}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink PowerBackup
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{ADD5DB49-72CF-11D8-9D75-000129760D75}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{ADD5DB49-72CF-11D8-9D75-000129760D75}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink PowerDirector 10
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{B0B4F6D2-F2AE-451A-9496-6F2F6A897B32}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{B0B4F6D2-F2AE-451A-9496-6F2F6A897B32}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink PowerDirector 12
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{E1646825-D391-42A0-93AA-27FA810DA093}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{E1646825-D391-42A0-93AA-27FA810DA093}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink PowerDVD 12
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{B46BEA36-0B71-4A4E-AE41-87241643FA0A}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{B46BEA36-0B71-4A4E-AE41-87241643FA0A}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: CyberLink YouCam
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{01FB4998-33C4-4431-85ED-079E3EEFE75D}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{01FB4998-33C4-4431-85ED-079E3EEFE75D}\Setup.exe" /s /z-uninstall >nul 2>&1
)
if exist "%ProgramFiles(x86)%\NSIS Uninstall Information\{A9CEDD6E-4792-493e-BB35-D86D2E188A5A}\Setup.exe" (
"%ProgramFiles(x86)%\NSIS Uninstall Information\{A9CEDD6E-4792-493e-BB35-D86D2E188A5A}\Setup.exe" /S _?=C:\PROGRA~2\NSISUN~1\{A9CEDD6E-4792-493e-BB35-D86D2E188A5A} >nul 2>&1
)

echo Lenovo
:: Lenovo Energy Manager
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{AC768037-7079-4658-AC24-2897650E0ABE}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{AC768037-7079-4658-AC24-2897650E0ABE}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo Mobile Phone Wireless Import
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{DFB2E0D6-8DDE-49A4-B8F7-03C14DACCBA6}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{DFB2E0D6-8DDE-49A4-B8F7-03C14DACCBA6}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo Onekey Theater
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{91CC5BAE-A098-40D3-A43B-C0DC7CE263FE}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{91CC5BAE-A098-40D3-A43B-C0DC7CE263FE}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo PhoneCompanion
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{0F82EA83-B0C5-4AB9-9695-DFE92C5FD57B}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{0F82EA83-B0C5-4AB9-9695-DFE92C5FD57B}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo Photo Master
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{BC94C56A-3649-420C-8756-2ADEBE399D33}\Setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{BC94C56A-3649-420C-8756-2ADEBE399D33}\Setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo PowerDVD10
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{DEC235ED-58A4-4517-A278-C41E8DAEAB3B}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{DEC235ED-58A4-4517-A278-C41E8DAEAB3B}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo Updates
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{A2E1E9F0-0B68-4166-8C7F-85B563B84DF4}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{A2E1E9F0-0B68-4166-8C7F-85B563B84DF4}\setup.exe" /s /z-uninstall >nul 2>&1
)
:: Lenovo User Manuals
if exist "%ProgramFiles(x86)%\InstallShield Installation Information\{F07C2CF8-4C53-4EC3-8162-A6221E36EB88}\setup.exe" (
"%ProgramFiles(x86)%\InstallShield Installation Information\{F07C2CF8-4C53-4EC3-8162-A6221E36EB88}\setup.exe" /s /z-uninstall >nul 2>&1
)

exit
