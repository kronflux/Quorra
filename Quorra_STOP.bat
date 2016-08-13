@CLS
@ECHO OFF
setlocal enableextensions
CD /D "%HOMEDRIVE%%HOMEPATH%"

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
title Quorra Stop Script
echo Quorra Stop Script
echo Press any key to remove Quorra startup items (useful if Quorra won't stop launching on startup)
pause >nul 2>&1

IF EXIST %temp%\Quorra_NEWSETUP.tmp DEL %temp%\Quorra_NEWSETUP.tmp
IF EXIST %temp%\Quorra_REMOVALS.tmp DEL %temp%\Quorra_REMOVALS.tmp
IF EXIST %temp%\Quorra_ICONS.tmp DEL %temp%\Quorra_ICONS.tmp
IF EXIST %temp%\Quorra_TWEAKS.tmp DEL %temp%\Quorra_TWEAKS.tmp
IF EXIST %temp%\Quorra_TEMPCLEAN.tmp DEL %temp%\Quorra_TEMPCLEAN.tmp
IF EXIST %temp%\Quorra_RUNTIMES.tmp DEL %temp%\Quorra_RUNTIMES.tmp
IF EXIST %temp%\Quorra_SUPPORT.tmp DEL %temp%\Quorra_SUPPORT.tmp
IF EXIST %temp%\Quorra_GENREM.tmp DEL %temp%\Quorra_GENREM.tmp
IF EXIST %temp%\Quorra_GUIDREM.tmp DEL %temp%\Quorra_GUIDREM.tmp
IF EXIST %temp%\Quorra_TBGUIDREM.tmp DEL %temp%\Quorra_TBGUIDREM.tmp
IF EXIST %temp%\Quorra_NAMEREM.tmp DEL %temp%\Quorra_NAMEREM.tmp
IF EXIST %temp%\Quorra_PSREM.tmp DEL %temp%\Quorra_PSREM.tmp
IF EXIST %temp%\Quorra_TMPREM.tmp DEL %temp%\Quorra_TMPREM.tmp
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Quorra /f >nul 2>&1

echo Removals complete.
echo Press any key to exit.
pause >nul 2>&1
endlocal
exit
