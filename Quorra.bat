:: TODO: Implement alternate method for Windows 8.1 upgrade. Hoping to launch Windows Store to Upgrade page.
:: TODO: Add duplicate file detection to Temp Cleanup Script
:: TODO: Some form of Runtime update system, possibly launch Ninite or similar

@CLS
@ECHO OFF
setlocal enableextensions
CD /D "%HOMEDRIVE%%HOMEPATH%"
set SCRIPT_VERSION=0.0.2

:: Change these variables to match your setup, the default points to \\techpc\share\scripts with a subfolder called resources
set SHARE_HOST=techpc
set SHARE_NAME=share
set SHARE_SCRIPT_FOLDER=scripts
set SHARE_SCRIPT_RESOURCES_FOLDER=resources
set SHARE_MOUNT_DRIVE=Z:
set TIME_ZONE=Mountain Standard Time
set TIME_SERVER=time-a.nist.gov
set SUPPORT_NAME=Tech Support
set SUPPORT_PHONE=1-800-555-1234
set SUPPORT_URL=https://support.techsupport.ca
set SUPPORT_ICON_TEXT=Tech Support

:: Windows upgrade bits go in these folders, the structure should be included with this script
set SHARE_WIN10_FOLDER=updates\win10upgrade
set SHARE_WIN81_FOLDER=updates\win81upgrade

:: Are you a Microsoft partner? if so, an internal 8.1 upgrade solution will be implemented, if not an alernate manual upgrade method will be used.
set MS_PARTNER=FALSE

set WIN_NAME=undetected
set WIN_VER=undetected
set WIN_VER_NUM=undetected
set WIN=undetected
SET NEWSETUP=undecided
SET REMOVALS=undecided
SET ICONS=undecided
SET TWEAKS=undecided
SET TEMPCLEAN=undecided
SET SUPPORT=undecided
:: SET RUNTIMES=undecided

:: BatchGotAdmin - Check for administrative priveleges, attempt to elevate if not already
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%HOMEDRIVE%%HOMEPATH%"
    CD /D "%HOMEDRIVE%%HOMEPATH%"
:--------------------------------------

color 03
title Quorra v%SCRIPT_VERSION%
:::                     ____
:::                    / __ \
:::                   | |  | |_   _  ___  _ __ _ __ __ _
:::                   | |  | | | | |/ _ \| '__| '__/ _` |
:::                   | |__| | |_| | (_) | |  | | | (_| |
:::                    \___\_\\__,_|\___/|_|  |_|  \__,_|

for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
echo  ============================================================================
echo.       Welcome to Quorra! A Junk Cleanup, System Setup and Tweak Script
echo.                          Written by Richard M
echo  ============================================================================
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
net use %SHARE_MOUNT_DRIVE% "\\%SHARE_IP%\%SHARE_NAME%" /user:Everyone /P:Yes >nul 2>&1
pushd "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%" >nul 2>&1
CD /D "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%" >nul 2>&1

echo.

:: Start Caffeine to prevent system from sleeping
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\caffeine.exe" (
start "" %SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\caffeine.exe -noicon
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
:: SET RUNTIMES=True
SET SUPPORT=True
echo NEWSETUP > %temp%\Quorra_NEWSETUP.tmp )

IF NOT "%REMOVALS%"=="True" (
CHOICE /C YN /M "Run Quorra with Removals?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET REMOVALS=True
echo REMOVALS > %temp%\Quorra_REMOVALS.tmp
))

IF NOT "%ICONS%"=="True" (
CHOICE /C YN /M "Remove Desktop icons, Favorites and Pinned Taskbar Items?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET ICONS=True
echo ICONS > %temp%\Quorra_ICONS.tmp
))

IF NOT "%ICONS%"=="True" (
CHOICE /C YN /M "Run Quorra with Tweaks?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET TWEAKS=True
echo TWEAKS > %temp%\Quorra_TWEAKS.tmp
))

CHOICE /C YN /M "Run a temp files cleanup after removal step? (Runs whether or not Removals are selected)"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET TEMPCLEAN=True
echo TEMPCLEAN > %temp%\Quorra_TEMPCLEAN.tmp )

::CHOICE /C YN /M "Run Quorra with Runtime Updates? (Adobe Reader, Flash, Java, Silverlight)"
::IF ERRORLEVEL 2 timeout 1 >nul 2>&1
::IF ERRORLEVEL 1 (
::SET RUNTIMES=True
::echo RUNTIMES > %temp%\Quorra_RUNTIMES.tmp )

CHOICE /C YN /M "Run Quorra with Support Information?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET SUPPORT=True
echo SUPPORT > %temp%\Quorra_SUPPORT.tmp )

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
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_general.bat" (
echo Starting General Removals
start "Quorra - General Removals" /wait %SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_general.bat
echo General Removals Complete
if exist "%temp%\Quorra_GENREM.tmp" DEL "%temp%\Quorra_GENREM.tmp"
echo.
))

:removalsGUID
:: Removals by GUID method
if "%REMOVALS%"=="True" (
echo GUIDREM > %temp%\Quorra_GUIDREM.tmp
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_GUID.bat" (
echo Starting Removals by GUID
start "Quorra - GUID Removals" /wait %SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_GUID.bat
echo Removals by GUID Complete
if exist "%temp%\Quorra_GUIDREM.tmp" DEL "%temp%\Quorra_GUIDREM.tmp"
echo.
))

:removalsGUIDToolbars
:: Toolbar Removals by GUID method
if "%REMOVALS%"=="True" (
echo TBGUIDREM > %temp%\Quorra_TBGUIDREM.tmp
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\toolbars_BHOs_to_target_by_GUID.bat" (
echo Starting Toolbar Removals by GUID
start "Quorra - Toolbar GUID Removals" /wait %SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\toolbars_BHOs_to_target_by_GUID.bat
echo Toolbar Removals by GUID Complete
if exist "%temp%\Quorra_TBGUIDREM.tmp" DEL "%temp%\Quorra_TBGUIDREM.tmp"
echo.
))

:removalsNAME
:: Removals by Name method
if "%REMOVALS%"=="True" (
echo NAMEREM > %temp%\Quorra_NAMEREM.tmp
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_name.txt" (
ECHO Starting removals by name... This may take a while.
for /f "tokens=*" %%i in (%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\programs_to_target_by_name.txt) DO (
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
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_3rd_party_modern_apps_to_target_by_name.ps1" (
ECHO Starting Modern App Removal...
Powershell -noprofile -ExecutionPolicy Bypass -File "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_3rd_party_modern_apps_to_target_by_name.ps1"
ECHO Modern App Removal Complete
ECHO.
)
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_Microsoft_modern_apps_to_target_by_name.ps1" (
ECHO Starting Modern App Removal...
Powershell -noprofile -ExecutionPolicy Bypass -File "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\metro_Microsoft_modern_apps_to_target_by_name.ps1"
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
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /f
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

:: Set Read-Only on File Explorer in Pinned Items, Delete all other pins, unset Read-Only
IF NOT EXIST "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk" (
COPY /Y "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\File Explorer.lnk" "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk"
)
ATTRIB +R +S +H "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk" >nul 2>&1
DEL /S /Q "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" >nul 2>&1
ATTRIB -R -S -H "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk" >nul 2>&1
if exist "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk" (
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\Favorites" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /t REG_BINARY /d 006401000032001f80c827341f105c1042aa032ee45287d6681e0000002500efbe120000006576b6a982f4d101bcf020ab82f4d101140056003100000000000c49225211005461736b42617200400009000400efbe0c4922520c4922522e000000fb760100000002000000000000000000000000000000b196e8005400610073006b0042006100720000001600da003200970100001643cc36200046494c4545587e312e4c4e4b00007c0009000400efbe0c4922520c4922522e000000007701000000010000000000000000005200000000007f81cc00460069006c00650020004500780070006c006f007200650072002e006c006e006b00000040007300680065006c006c00330032002e0064006c006c002c002d003200320030003600370000001c00420000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f00770073002e004500780070006c006f0072006500720000001c000000ff /f >nul 2>&1
))

:tempCleanup
:: Temporary files cleanup
if "%TEMPCLEAN%"=="True" (
echo TMPREM > %temp%\Quorra_TMPREM.tmp
if exist "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\TempFileCleanup.bat" (
echo Starting Temporary Files Cleanup
start "Quorra - Temp File Cleanup" /wait %SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\TempFileCleanup.bat
echo Temporary Files Cleanup Complete
if exist "%temp%\Quorra_TMPREM.tmp" DEL "%temp%\Quorra_TMPREM.tmp"
))

:tweakStuff
:: Common customizations, security enhancements, etc
if "%TWEAKS%"=="True" (
:: Show desktop wallpaper on Start screen (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "MotionAccentId_v1.00" /t REG_DWORD /d 0x000000db /f >nul 2>&1

:: List Desktop apps first in the Apps view when sorted by category (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "DesktopFirst" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Boot to Desktop (Windows 8)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "OpenAtLogon" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Show My Computer/This PC on Desktop
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Do not show Windows Store on Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StoreAppsOnTaskbar" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

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

:: Open Explorer to This PC instead of Quick Access
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Remove Retail Demo
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{12D4C69E-24AD-4923-BE19-31321C43A767}" /f >nul 2>&1

:: Add Pin to Start to Context Menu
reg add "HKCR\*\shellex\ContextMenuHandlers\PintoStartScreen" /ve /t REG_SZ /d "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" /f >nul 2>&1

:: Disable Windows Customer Experience Improvement Program
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0x00000000 /f >nul 2>&1

:: Disable Third Party Browser Extensions in IE
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Enable Browser Extensions" /t REG_SZ /d "no" /f >nul 2>&1

:: Disable automatically installing Web components
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "NoJITSetup" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "NoWebJITSetup" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Use EdgeHTML in IE
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "DisableRandomFlighting" /t REG_DWORD /d 0x00000001 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "EnableLegacyEdgeSwitching" /t REG_DWORD /d 0x00000001 /f >nul 2>&1

:: Do not open links in Metro IE App, always use Desktop
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "ApplicationTileImmersiveActivation" /t REG_DWORD /d 0x00000000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "AssociationActivationMode" /t REG_DWORD /d 0x00000002 /f >nul 2>&1

)

IF "%SUPPORT%"=="True" (
:: Add support information to Desktop and System Properties
echo Adding support information to system
copy  /y "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\support.ico" "%public%\support.ico"
copy /y "%SHARE_MOUNT_DRIVE%\%SHARE_SCRIPT_FOLDER%\%SHARE_SCRIPT_RESOURCES_FOLDER%\support.bmp" "%WinDir%\support.bmp"

attrib +h +s "%public%\support.ico"
attrib +h +s "%WinDir%\support.bmp"

echo [InternetShortcut] > "%public%\Desktop\%SUPPORT_ICON_TEXT%.url"
echo URL=%SUPPORT_URL% >> "%public%\Desktop\%SUPPORT_ICON_TEXT%.url"
echo IconFile=%public%\support.ico >> "%public%\Desktop\%SUPPORT_ICON_TEXT%.url"
echo IconIndex=0 >> "%public%\Desktop\%SUPPORT_ICON_TEXT%.url"

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /v Manufacturer /t REG_SZ /d "%SUPPORT_NAME%" /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /v SupportPhone /t REG_SZ /d "%SUPPORT_PHONE%" /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /v SupportURL /t REG_SZ /d "%SUPPORT_URL%" /f >nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /v Logo /t REG_EXPAND_SZ /d "%WinDir%\support.bmp" /f >nul 2>&1
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

:: Kill the caffeine.exe process
echo Killing Caffeine Process
taskkill /f /t /im "caffeine.exe" >nul 2>&1

:: Set theme to Aero default
IF "%NEWSETUP%"=="True" (
explorer.exe "%WinDir%\Resources\Themes\aero.theme" >nul 2>&1
)

:: Restart explorer.exe
ECHO Restarting Explorer
taskkill /f /im explorer.exe >nul 2>&1
timeout 2 >nul 2>&1
echo. | Runas /profile /user:%ComputerName%\%UserName% explorer.exe >nul 2>&1
tasklist /fi "imagename eq explorer.exe" |find ":" > nul
if errorlevel 2 start explorer.exe >nul 2>&1
if errorlevel 1 timeout 1 >nul 2>&1

:: Remove recent file entry and remove leftover temp files from Quorra
echo Tidying Up

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
IF EXIST %temp%\Quorra_TMPREM.tmp DEL %temp%\Quorra_TMPREM.tmp

endlocal
exit

:resumeScript
IF EXIST %temp%\Quorra_NEWSETUP.tmp SET NEWSETUP=True
IF EXIST %temp%\Quorra_REMOVALS.tmp SET REMOVALS=True
IF EXIST %temp%\Quorra_ICONS.tmp SET ICONS=True
IF EXIST %temp%\Quorra_TEMPCLEAN.tmp SET TEMPCLEAN=True
IF EXIST %temp%\Quorra_TWEAKS.tmp SET TWEAKS=True
IF EXIST %temp%\Quorra_RUNTIMES.tmp SET RUNTIMES=True
IF EXIST %temp%\Quorra_SUPPORT.tmp SET SUPPORT=True

IF EXIST %temp%\Quorra_GENREM.tmp GOTO :removalsGeneral
IF EXIST %temp%\Quorra_GUIDREM.tmp GOTO :removalsGUID
IF EXIST %temp%\Quorra_TBGUIDREM.tmp GOTO :removalsGUIDToolbars
IF EXIST %temp%\Quorra_NAMEREM.tmp GOTO :removalsNAME
IF EXIST %temp%\Quorra_PSREM.tmp GOTO :removalsPS
IF EXIST %temp%\Quorra_TMPREM.tmp GOTO :tempCleanup
