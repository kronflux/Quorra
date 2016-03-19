@CLS
@ECHO OFF
setlocal enableextensions
CD /D "%HOMEDRIVE%%HOMEPATH%"
set SCRIPT_VERSION=0.0.1

:: Change these variables to match your setup, the default points to \\share\afk\scripts with a subfolder called resources
set SHARE_HOST=share
set SHARE_NAME=afk
set SHARE_SCRIPT_FOLDER=scripts
set SHARE_SCRIPT_RESOURCES_FOLDER=resources
set TIME_ZONE=Mountain Standard Time
set TIME_SERVER=time-a.nist.gov

:: Windows upgrade bits go in these folders, the structure should be included with this script
set SHARE_WIN10_FOLDER=updates\win10upgrade
set SHARE_WIN81_FOLDER=updates\win81upgrade

:: Are you a Microsoft partner? if so, an internal 8.1 upgrade solution will be implemented, if not an alernate manual upgrade method will be use.
set MS_PARTNER=TRUE

set WIN_NAME=undetected
set WIN_VER=undetected
set WIN_VER_NUM=undetected
set WIN=undetected
SET NEWSETUP=undecided
SET REMOVALS=undecided
SET ICONS=undecided
SET TWEAKS=undecided
SET SUPPORT=undecided

:: Check for administrative priveleges, attempt to elevate if not already
:-------------------------------------
::  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%HOMEDRIVE%%HOMEPATH%"
:--------------------------------------
color 03
title Quorra v%SCRIPT_VERSION%
:::    ___                             
:::   / _ \ _   _  ___  _ __ _ __ __ _ 
:::  | | | | | | |/ _ \| '__| '__/ _` |
:::  | |_| | |_| | (_) | |  | | | (_| |
:::   \__\_\\__,_|\___/|_|  |_|  \__,_|

for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
echo =======================================
echo.  Welcome to Quorra! Blah Blah Blah !
echo =======================================
echo.

echo Setting Time Zone to %TIME_ZONE%
tzutil /s "%TIME_ZONE%" >nul 2>&1
sc config W32Time start=auto >nul 2>&1
net start W32Time >nul 2>&1
timeout 1 >nul 2>&1

echo Setting Windows Time Server to %TIME_SERVER%
w32tm /config /syncfromflags:MANUAL /reliable:yes /update /manualpeerlist:%TIME_SERVER% >nul 2>&1

echo Synchronizing Time
w32tm /resync /rediscover >nul 2>&1

echo.

set Hour=%TIME:~0,2% 
if %Hour% GTR 12 (
    set/a Hour=%TIME:~0,2%-12
	set AMPM=PM
) else (
	set AMPM=AM
)
set Min=%TIME:~3,2%
set Sec=%TIME:~6,2%

set CUR_TIME=%Hour%:%Min%:%Sec% %AMPM%

set Year=%DATE:~-4%
set Month=%DATE:~3,2%
set Day=%DATE:~0,2%
if "%Day:~0,1%" == " " set Day=0%Day:~1,1%

set CUR_DATE=%Month%-%Day%-%Year%

for /f "delims=[] tokens=2" %%a in ('ping %SHARE_HOST% -n 1 ^| findstr "["') do (set SHARE_IP=%%a)
for /f "delims=[] tokens=2" %%a in ('ping %ComputerName% -n 1 ^| findstr "["') do (set IP=%%a)

FOR /f "tokens=4*" %%i IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| Find "ProductName"') DO set WIN_NAME=%%j
FOR /f "tokens=4 delims=[] " %%i IN ('ver') DO set WIN_VER_NUM=%%i

if %WIN_VER_NUM% EQU 6.0.6000 set WIN_VER=Microsoft Windows Vista %WIN_NAME% & set WIN=VISTA
if %WIN_VER_NUM% EQU 6.0.6001 set WIN_VER=Microsoft Windows Vista %WIN_NAME% SP1 & set WIN=VISTA
if %WIN_VER_NUM% EQU 6.0.6002 set WIN_VER=Microsoft Windows Vista %WIN_NAME% SP2 & set WIN=VISTA
if %WIN_VER_NUM% EQU 6.1.7600 set WIN_VER=Microsoft Windows 7 %WIN_NAME% & set WIN=SEVEN
if %WIN_VER_NUM% EQU 6.1.7601 set WIN_VER=Microsoft Windows 7 %WIN_NAME% SP1 & set WIN=SEVEN
if %WIN_VER_NUM% EQU 6.2.9200 set WIN_VER=Microsoft Windows 8 %WIN_NAME% & set WIN=EIGHT
if %WIN_VER_NUM% EQU 6.3.9200 set WIN_VER=Microsoft Windows 8.1 %WIN_NAME% & set WIN=EIGHTONE
if %WIN_VER_NUM% EQU 6.3.9600 set WIN_VER=Microsoft Windows 8.1 %WIN_NAME% Update 1 & set WIN=EIGHTONE
if %WIN_VER_NUM% EQU 10.0.10240 set WIN_VER=Microsoft Windows 10 %WIN_NAME% & set WIN=TEN
if %WIN_VER_NUM% EQU 10.0.10586 set WIN_VER=Microsoft Windows 10 %WIN_NAME% TH2 & set WIN=TEN

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set WinBit=32BIT || set WinBit=64BIT

echo Windows Information:
echo Edition: %WIN_VER%
echo Build Number: %WIN_VER_NUM%
if %WinBit%==32BIT ECHO Architecture: 32-Bit
if %WinBit%==64BIT ECHO Architecture: 64-Bit
echo System Date is: %CUR_DATE%
echo System Time is: %CUR_TIME%
echo Network IP: %IP%
echo Computer Name: %ComputerName%
echo Current User: %UserName%
echo.
echo Share Information:
echo Location: \\%SHARE_HOST%\%SHARE_NAME%
echo IP: %SHARE_IP%
echo.
echo Mounting share to drive Z
net use z: "\\%SHARE_IP%\%SHARE_NAME%" /user:Everyone /P:Yes >nul 2>&1
pushd "Z:\%SHARE_SCRIPT_FOLDER%" >nul 2>&1
CD /D "Z:\%SHARE_SCRIPT_FOLDER%" >nul 2>&1

echo.

:: Start Caffeine to prevent system from sleeping
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\caffeine.exe" (
start "" Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\caffeine.exe -noicon
)

:: Add script to system startup in case of unexpected reboot
echo Adding startup entry
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f >nul 2>&1

:: Disable UAC in case of unexpected reboot so script can resume with administrative priveleges without interaction
echo Disabling UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d 0x00000003 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableInstallerDetection" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableSecureUIAPaths" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableUIADesktopToggle" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ValidateAdminCodeSignatures" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

CALL :resumeScript

:preQuestions
CHOICE /C YN /M "Is this a new computer setup?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET NEWSETUP=True
SET REMOVALS=True
SET ICONS=True
SET TWEAKS=True
SET RUNTIMES=True
SET SUPPORT=True
echo NEWSETUP > %temp%\Quorra_NEWSETUP.tmp )

CHOICE /C YN /M "Run Quorra with Removals?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET REMOVALS=True
echo REMOVALS > %temp%\Quorra_REMOVALS.tmp )

CHOICE /C YN /M "Remove Desktop icons, Favorites and Pinned Taskbar Items?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET ICONS=True
echo ICONS > %temp%\Quorra_ICONS.tmp )

CHOICE /C YN /M "Run Quorra with Tweaks?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET TWEAKS=True
echo TWEAKS > %temp%\Quorra_TWEAKS.tmp )

::CHOICE /C YN /M "Run Quorra with Runtime Updates? (Adobe Reader, Flash, Java, Silverlight)"
::IF ERRORLEVEL 2 timeout 1 >nul 2>&1
::IF ERRORLEVEL 1 (
::SET RUNTIMES=True
::echo RUNTIMES > %temp%\Quorra_RUNTIMES.tmp )

::CHOICE /C YN /M "Run Quorra with Support Information?"
::IF ERRORLEVEL 2 timeout 1 >nul 2>&1
::IF ERRORLEVEL 1 (
::SET SUPPORT=True
::echo SUPPORT > %temp%\Quorra_SUPPORT.tmp )

echo.

:killTasks
:: Kill all unsecured applications
if "%REMOVALS%"=="True" (
ECHO Terminating all unprotected user started processes...

:: Add an if not and closing bracket to exclude additional processes from being terminated
for /f "skip=3 tokens=1" %%i in ('TASKLIST /FI "USERNAME eq %userdomain%\%username%" /FI "STATUS eq running"') do (
if not "%%i"=="caffeine.exe" (
if not "%%i"=="choice.exe" (
if not "%%i"=="cmd.exe" (
if not "%%i"=="conhost.exe" (
if not "%%i"=="explorer.exe" (
if not "%%i"=="rebecca.exe" (
if not "%%i"=="RuntimeBroker.exe" (
if not "%%i"=="ShellExperienceHost.exe" (
if not "%%i"=="sihost.exe" (
if not "%%i"=="svchost.exe" (
if not "%%i"=="tasklist.exe" (
if not "%%i"=="Taskmgr.exe" (
taskkill /f /t /im "%%i" >nul 2>&1
)))))))))))))

ECHO Process termination complete.
ECHO.
)

:removalsGeneral
:: General Removals
if "%REMOVALS%"=="True" (
echo GENREM > %temp%\Quorra_GENREM.tmp
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_general.bat" (
echo Starting General Removals
start "Quorra - General Removals" /wait Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_general.bat
echo General Removals Complete
if exist "%temp%\Quorra_GENREM.tmp" DEL "%temp%\Quorra_GENREM.tmp"
echo.
))

:removalsGUID
:: Removals by GUID method
if "%REMOVALS%"=="True" (
echo GUIDREM > %temp%\Quorra_GUIDREM.tmp
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_GUID.bat" (
echo Starting Removals by GUID
start "Quorra - GUID Removals" /wait Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_GUID.bat
echo Removals by GUID Complete
if exist "%temp%\Quorra_GUIDREM.tmp" DEL "%temp%\Quorra_GUIDREM.tmp"
echo.
))

:removalsGUIDToolbars
:: Toolbar Removals by GUID method
if "%REMOVALS%"=="True" (
echo TBGUIDREM > %temp%\Quorra_TBGUIDREM.tmp
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\toolbars_BHOs_to_target_by_GUID.bat" (
echo Starting Toolbar Removals by GUID
start "Quorra - Toolbar GUID Removals" /wait Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\toolbars_BHOs_to_target_by_GUID.bat
echo Toolbar Removals by GUID Complete
if exist "%temp%\Quorra_TBGUIDREM.tmp" DEL "%temp%\Quorra_TBGUIDREM.tmp"
echo.
))

:removalsNAME
:: Removals by Name method
if "%REMOVALS%"=="True" (
echo NAMEREM > %temp%\Quorra_NAMEREM.tmp
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_name.txt" (
ECHO Starting removals by name... This may take a while.
for /f "tokens=*" %%i in (Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_name.txt) DO (
    echo Searching for %%i...
    wmic product where "name like '%%i'" uninstall /nointeractive
)
ECHO Removals by name complete
if exist "%temp%\Quorra_NAMEREM.tmp" DEL "%temp%\Quorra_NAMEREM.tmp"
ECHO.
))

:removalsPS
:: Modern Windows App Removal
if "%REMOVALS%"=="True" (
echo PSREM > %temp%\Quorra_PSREM.tmp
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_3rd_party_modern_apps_to_target_by_name.ps1" (
ECHO Starting Modern App Removal...
powershell -noprofile -executionpolicy bypass -file "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_3rd_party_modern_apps_to_target_by_name.ps1"
ECHO Modern App Removal Complete
ECHO.
)
if exist "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_Microsoft_modern_apps_to_target_by_name.ps1" (
ECHO Starting Modern App Removal...
powershell -noprofile -executionpolicy bypass -file "Z:\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_Microsoft_modern_apps_to_target_by_name.ps1"
ECHO Modern App Removal Complete
if exist "%temp%\Quorra_PSREM.tmp" DEL "%temp%\Quorra_PSREM.tmp"
ECHO.
))

:removalsICONS
:: Remove unwanted links, shortcuts, pinned items
if "%ICONS%"=="True" (
DEL "%appdata%\Microsoft\Windows\Start Menu\Programs\Pc App Store.lnk" >nul 2>&1
DEL /F /Q "%AllUsersProfile%\Desktop\*.lnk" >nul 2>&1
DEL /F /Q "%AllUsersProfile%\Desktop\*.url" >nul 2>&1
DEL /F /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Games\*.lnk"
DEL /F /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\McAfee\*.lnk"
DEL /F /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Music, Photos and Videos\Snapfish.lnk" >nul 2>&1
DEL /F /Q "%systemdrive%\Users\Public\Desktop\*.lnk" >nul 2>&1
DEL /F /Q "%systemdrive%\Users\Public\Desktop\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Desktop\*.lnk" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Acer\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Favorites Bar\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\HP\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Links\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Microsoft Websites\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\MSN Websites\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Websites for United States\*.url" >nul 2>&1
DEL /F /Q "%UserProfile%\Favorites\Windows Live\*.url" >nul 2>&1
DEL /F /S /Q /A "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /f
REG DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f
RMDIR "%ProgramData%\Microsoft\Windows\Start Menu\Programs\McAfee" >nul 2>&1
RMDIR "%UserProfile%\Favorites\Acer" >nul 2>&1
RMDIR "%UserProfile%\Favorites\HP" >nul 2>&1
RMDIR "%UserProfile%\Favorites\Microsoft Websites" >nul 2>&1
RMDIR "%UserProfile%\Favorites\MSN Websites" >nul 2>&1
RMDIR "%UserProfile%\Favorites\Websites for United States" >nul 2>&1
RMDIR "%UserProfile%\Favorites\Windows Live" >nul 2>&1
RMDIR /S /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Amazon Weblink" >nul 2>&1
RMDIR /S /Q "%ProgramFiles%\Accessory Store" >nul 2>&1
RMDIR /S /Q "%ProgramFiles%\Amazon Weblink" >nul 2>&1
RMDIR /S /Q "%ProgramFiles%\Booking.com" >nul 2>&1
RMDIR /S /Q "%ProgramFiles(x86)%\Accessory Store" >nul 2>&1
RMDIR /S /Q "%ProgramFiles(x86)%\Amazon Weblink" >nul 2>&1
RMDIR /S /Q "%ProgramFiles(x86)%\Booking.com" >nul 2>&1
)

:tweakStuff
:: Common customizations, security enhancements, etc
if "%TWEAKS%"=="True" (
:: Show desktop wallpaper on Start screen (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "MotionAccentId_v1.00" /t REG_DWORD /d 0x000000db /f >nul 2>&1

:: Set start screen color to default (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "ColorSet_Version3" /t REG_DWORD /d 0x00000008 /f >nul 2>&1

:: List Desktop apps first in the Apps view when sorted by category (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "DesktopFirst" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Boot to Desktop (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "OpenAtLogon" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Show My Computer/This PC on Desktop
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Do not show Windows Store on Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StoreAppsOnTaskbar" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Do not constantly check whether disk is running low on space (Improves performance)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoLowDiskSpaceChecks /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Automatic Network Shortcut Resolution
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v LinkResolveIgnoreLinkInfo /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Search for Broken Shortcuts
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoResolveSearch /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Tracking of Broken Shortcuts
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoResolveTrack /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable using Web service to check for unknown file types
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoInternetOpenWith /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Aero Shake
reg add "HKCU\Software\Policies\Microsoft\Windows" /v NoWindowMinimizingShortcuts /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Enable NumLock by Default
reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_DWORD /d 0x00000002 /f >nul 2>&1

:: Add Copy To and Move To Context Menu Items
reg add "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" /ve /t REG_SZ /d "{C2FBB630-2971-11D1-A18C-00C04FD75D13}" /f >nul 2>&1
reg add "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" /ve /t REG_SZ /d "{C2FBB631-2971-11D1-A18C-00C04FD75D13}" /f >nul 2>&1

:: Disable Help Sticker Notifications
reg add "HKU\CUSTOM\Software\Policies\Microsoft\Windows\EdgeUI" /v "DisableHelpSticker" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Set Google as IE11 Default
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "DisplayName" /t REG_SZ /d "Google" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "FaviconURL" /t REG_SZ /d "https://www.google.ca/favicon.ico" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "FaviconURLFallback" /t REG_SZ /d "https://www.google.ca/favicon.ico" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "OSDFileURL" /t REG_SZ /d "http://www.iegallery.com/en-us/AddOns/DownloadAddOn?resourceId=813" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "ShowSearchSuggestions" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "SuggestionsURL" /t REG_SZ /d "http://clients5.google.com/complete/search?q=%7BsearchTerms%7D&client=ie8&mw=%7Bie:maxWidth%7D&sh=%7Bie:sectionHeight%7D&rh=%7Bie:rowHeight%7D&inputencoding=%7BinputEncoding%7D&outputencoding=%7BoutputEncoding%7D" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "SuggestionsURLFallback" /t REG_SZ /d "http://clients5.google.com/complete/search?hl=%7Blanguage%7D&q=%7BsearchTerms%7D&client=ie8&inputencoding=%7BinputEncoding%7D&outputencoding=%7BoutputEncoding%7D" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "TopResultURLFallback" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /v "URL" /t REG_SZ /d "https://www.google.ca/search?q=%7BsearchTerms%7D&sourceid=ie7&rls=com.microsoft:%7Blanguage%7D:%7Breferrer:source%7D&ie=%7BinputEncoding?%7D&oe=%7BoutputEncoding?%7D" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" /v "DefaultScope" /t REG_SZ /d "{89418666-DF74-4CAC-A2BD-B69FB4A0228A}" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Main" /v "Search Page" /t REG_SZ /d "https://www.google.ca/" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Main" /v "Start Page Redirect Cache" /t REG_SZ /d "https://www.google.ca/" /f >nul 2>&1

:: Attempt to Set Google as Edge Homepage
reg add "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "HomeButtonEnabled" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "HomeButtonPage" /t REG_SZ /d "https://www.google.ca/" /f >nul 2>&1
reg add "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "IE10TourShown" /t REG_SZ /d 0x00000001 /f >nul 2>&1

:: Hide Search Box on Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchBoxTaskbarMode" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Download updates from Microsoft and LAN
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode" /t REG_DWORD /d 0x00000002 /f >nul 2>&1

:: Disable Peer to Peer Updates
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Disable Diagnostic and usage data
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Disable Application Impact Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Disable Keylogger
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Open Explorer to This PC instead of Quick Access
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Remove Retail Demo
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{12D4C69E-24AD-4923-BE19-31321C43A767}" /f >nul 2>&1

:: Add Pin to Start to Context Menu
reg add "HKCR\*\shellex\ContextMenuHandlers\PintoStartScreen" /ve /t REG_SZ /d "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" /f >nul 2>&1

:: Disable Web Search from Start Menu
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Bing Search
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: LOL Why is Dr Watson still in Windows 10? Let's disable that...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\AeDebug" /f >nul 2>&1

:: Disable Fault Tolerant Heap (This is mostly for developers. Average user will never need this)
reg add "HKLM\SOFTWARE\Software\Microsoft\FTH" /v "Enabled" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Harden RPC
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RpcSs" /v "ListenOnInternet" /t REG_SZ /d "N" /f >nul 2>&1

:: Disable IPv6 as it ignores most Windows network security
reg add "HKLM\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0xfffffff /f >nul 2>&1

:: Disable DCOM
reg add "HKLM\Software\Microsoft\Ole" /v "EnableDCOM" /t REG_SZ /d "N" /f >nul 2>&1

:: Harden TCPIP Stack
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableAddressSharing" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicBacklogGrowthDelta" /t REG_DWORD /d 0x00000010 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "EnableDynamicBacklog" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "MaximumDynamicBacklog" /t REG_DWORD /d 0x00004000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "MinimumDynamicBacklog" /t REG_DWORD /d 0x00000010 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netbt\Parameters" /v "NoNameReleaseOnDemand" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "DisableIPSourceRouting" /t REG_DWORD /d 0x00000002 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "EnableAddrMaskReply" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "EnableDeadGWDetect" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "EnableMulticastForwarding" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "IPEnableRouter" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "KeepAliveTime" /t REG_DWORD /d 0x000493e0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "NoNameReleaseOnDemand" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "PerformRouterDiscovery" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "SynAttackProtect" /t REG_DWORD /d 0x00000002 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpMaxConnectResponseRetransmissions" /t REG_DWORD /d 0x00000002 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d 0x00000002 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpMaxHalfOpen" /t REG_DWORD /d 0x000001f4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpMaxHalfOpenRetried" /t REG_DWORD /d 0x00000190 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpMaxPortsExhausted" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Disable Windows Customer Experience Improvement Program
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Disable Third Party Browser Extensions in IE
reg add "HKCU\Software \Microsoft\Internet Explorer\Main" /v "Enable Browser Extensions" /t REG_SZ /d "no" /f >nul 2>&1

:: Disable automatically installing Web components
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "NoJITSetup" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "NoWebJITSetup" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Do not allow software to run if signature is invalid
reg add "HKLM\Software\Microsoft\Internet Explorer\Download" /v "CheckExeSignatures" /t REG_SZ /d "yes" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Download" /v "RunInvalidSignatures" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Use EdgeHTML in IE
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "DisableRandomFlighting" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "EnableLegacyEdgeSwitching" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Do not open links in Metro IE App, always use Desktop
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "ApplicationTileImmersiveActivation" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "AssociationActivationMode" /t REG_DWORD /d 0x00000002 /f >nul 2>&1

:: Set IGMP as send only as is rarely used and could pose a security risk
netsh interface ipv4 set global mldlevel=sendonly >nul 2>&1
)

:: Remove startup entry
echo Removing startup entry
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /f >nul 2>&1

:: Enable UAC
echo Enabling UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0x00000005 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d 0x00000003 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableInstallerDetection" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableSecureUIAPaths" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableUIADesktopToggle" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ValidateAdminCodeSignatures" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Unmount all network shares
echo Unmounting network share
net use * /delete /yes >nul 2>&1

echo Tidying Up

taskkill /f /t /im "caffeine.exe" >nul 2>&1
del "%appdata%\Microsoft\Windows\Recent\*.*" /q >nul 2>&1
del "%appdata%\microsoft\windows\recent\automaticdestinations\*.*" /q >nul 2>&1
rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351 >nul 2>&1

IF EXIST %temp%\Quorra_NEWSETUP.tmp DEL %temp%\Quorra_NEWSETUP.tmp
IF EXIST %temp%\Quorra_REMOVALS.tmp DEL %temp%\Quorra_REMOVALS.tmp
IF EXIST %temp%\Quorra_ICONS.tmp DEL %temp%\Quorra_ICONS.tmp
IF EXIST %temp%\Quorra_TWEAKS.tmp DEL %temp%\Quorra_TWEAKS.tmp
IF EXIST %temp%\Quorra_RUNTIMES.tmp DEL %temp%\Quorra_RUNTIMES.tmp
IF EXIST %temp%\Quorra_SUPPORT.tmp DEL %temp%\Quorra_SUPPORT.tmp
IF EXIST %temp%\Quorra_GENREM.tmp DEL %temp%\Quorra_GENREM.tmp
IF EXIST %temp%\Quorra_GUIDREM.tmp DEL %temp%\Quorra_GUIDREM.tmp
IF EXIST %temp%\Quorra_TBGUIDREM.tmp DEL %temp%\Quorra_TBGUIDREM.tmp
IF EXIST %temp%\Quorra_NAMEREM.tmp DEL %temp%\Quorra_NAMEREM.tmp
IF EXIST %temp%\Quorra_PSREM.tmp DEL %temp%\Quorra_PSREM.tmp

endlocal
exit

:resumeScript
IF EXIST %temp%\Quorra_NEWSETUP.tmp SET NEWSETUP=True
IF EXIST %temp%\Quorra_REMOVALS.tmp SET REMOVALS=True
IF EXIST %temp%\Quorra_ICONS.tmp SET ICONS=True
IF EXIST %temp%\Quorra_TWEAKS.tmp SET TWEAKS=True
IF EXIST %temp%\Quorra_RUNTIMES.tmp SET RUNTIMES=True
IF EXIST %temp%\Quorra_SUPPORT.tmp SET SUPPORT=True

IF EXIST %temp%\Quorra_GENREM.tmp GOTO :removalsGeneral
IF EXIST %temp%\Quorra_GUIDREM.tmp GOTO :removalsGUID
IF EXIST %temp%\Quorra_TBGUIDREM.tmp GOTO :removalsGUIDToolbars
IF EXIST %temp%\Quorra_NAMEREM.tmp GOTO :removalsNAME
IF EXIST %temp%\Quorra_PSREM.tmp GOTO :removalsPS
