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

CHOICE /C YN /M "Run Quorra with Support Information?"
IF ERRORLEVEL 2 timeout 1 >nul 2>&1
IF ERRORLEVEL 1 (
SET SUPPORT=True
echo SUPPORT > %temp%\Quorra_SUPPORT.tmp )

echo.

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
:: Removals by GUID
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
:: Toolbar Removals by GUID
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
IF EXIST %temp%\Quorra_SUPPORT.tmp DEL %temp%\Quorra_SUPPORT.tmp
IF EXIST %temp%\Quorra_GENREM.tmp DEL %temp%\Quorra_GENREM.tmp
IF EXIST %temp%\Quorra_GUIDREM.tmp DEL %temp%\Quorra_GUIDREM.tmp
IF EXIST %temp%\Quorra_TBGUIDREM.tmp DEL %temp%\Quorra_TBGUIDREM.tmp
IF EXIST %temp%\Quorra_NAMEREM.tmp DEL %temp%\Quorra_NAMEREM.tmp

endlocal
exit

:resumeScript
IF EXIST %temp%\Quorra_NEWSETUP.tmp SET NEWSETUP=True
IF EXIST %temp%\Quorra_REMOVALS.tmp SET REMOVALS=True
IF EXIST %temp%\Quorra_ICONS.tmp SET ICONS=True
IF EXIST %temp%\Quorra_TWEAKS.tmp SET TWEAKS=True
IF EXIST %temp%\Quorra_SUPPORT.tmp SET SUPPORT=True

IF EXIST %temp%\Quorra_GENREM.tmp GOTO :removalsGeneral
IF EXIST %temp%\Quorra_GUIDREM.tmp GOTO :removalsGUID
IF EXIST %temp%\Quorra_TBGUIDREM.tmp GOTO :removalsGUIDToolbars
IF EXIST %temp%\Quorra_NAMEREM.tmp GOTO :removalsNAME
