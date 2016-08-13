:: This script is an adaptation of Tron's temp cleanup as well as my own, in time
:: I hope to add the duplicate file finding methods from Tron as well as some other additions
pushd "%HOMEDRIVE%%HOMEPATH%"
CD /D "%HOMEDRIVE%%HOMEPATH%"
@cls
@echo off

for /D %%x in ("%SystemDrive%\Users\*") do (
	del /F /S /Q "%%x\*.blf" >nul 2>&1
	del /F /S /Q "%%x\*.regtrans-ms" >nul 2>&1
	del /F /S /Q "%%x\AppData\LocalLow\Sun\Java\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\JumpListIcons\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Local Storage\http*.*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Internet Explorer\Recovery\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Terminal Server Client\Cache\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Caches\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Explorer\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\History\low\*" /AH >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\INetCache\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WER\ReportArchive\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WER\ReportQueue\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WebCache\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Local\Temp\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Roaming\Adobe\Flash Player\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Roaming\Macromedia\Flash Player\*" >nul 2>&1
	del /F /S /Q "%%x\AppData\Roaming\Microsoft\Windows\Recent\*" >nul 2>&1
	del /F /S /Q "%%x\Recent\*" >nul 2>&1
	del /F /Q "%%x\Documents\*.tmp" >nul 2>&1
)

for %%i in (NVIDIA,ATI,AMD,Dell,Intel,HP) do (
	rmdir /S /Q "%SystemDrive%\%%i" >nul 2>&1
)

if exist "%ProgramFiles%\Nvidia Corporation\Installer2" rmdir /s /q "%ProgramFiles%\Nvidia Corporation\Installer2"
if exist "%ALLUSERSPROFILE%\NVIDIA Corporation\NetService" del /f /q "%ALLUSERSPROFILE%\NVIDIA Corporation\NetService\*.exe"

if exist %SystemDrive%\MSOCache rmdir /S /Q %SystemDrive%\MSOCache

if exist %SystemDrive%\RECYCLER rmdir /s /q %SystemDrive%\RECYCLER
if exist %SystemDrive%\$Recycle.Bin rmdir /s /q %SystemDrive%\$Recycle.Bin

reg delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f

echo. >> %LOGPATH%\%LOGFILE%
if exist "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportArchive" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportArchive"
if exist "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportQueue" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportQueue"

if exist "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Scans\History\Results\Quick" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Scans\History\Results\Quick"
if exist "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Scans\History\Results\Resource" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Scans\History\Results\Resource"

if exist "%ALLUSERSPROFILE%\Microsoft\Search\Data\Temp" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Search\Data\Temp"

del /F /Q %WINDIR%\*.log >nul 2>&1
del /F /Q %WINDIR%\*.txt >nul 2>&1

echo %WIN_VER% | findstr /i /c:"server" >NUL && del /F /Q %WINDIR%\Logs\CBS\* >nul 2>&1

echo Deleting Temporary Files, Cookies and History
if exist "%appdata%\Microsoft\Windows\Recent" del /f /q "%appdata%\Microsoft\Windows\Recent\*.*"
if exist "%appdata%\Microsoft\Windows\Recent Items" del /f /q "%appdata%\Microsoft\Windows\Recent Items\*.*"
if exist "%appdata%\Microsoft\Windows\Recent\automaticdestinations" del /f /q "%appdata%\Microsoft\Windows\Recent\automaticdestinations\*.*"
if exist "%appdata%\Microsoft\Windows\Cookies" del /f /q "%appdata%\Microsoft\Windows\Cookies\*.*"
if exist "%appdata%\Microsoft\Windows\Cookies\Low" del /f /q "%appdata%\Microsoft\Windows\Cookies\Low\*.*"
if exist "%appdata%\Microsoft\Windows\Cookies\INetCookies" del /f /q "%appdata%\Microsoft\Windows\Cookies\INetCookies\*.*"
if exist "%localappdata%\Temp" del /f /q "%localappdata%\Temp\*.*"
if exist "%localappdata%\Microsoft\Windows\History" del /f /q "%localappdata%\Microsoft\Windows\History\*.*"
if exist "%localappdata%\Microsoft\Windows\Caches" del /f /q "%localappdata%\Microsoft\Windows\Caches\*.*"
if exist "%localappdata%\Microsoft\Windows\INetCache" del /f /q "%localappdata%\Microsoft\Windows\INetCache\*.*"
if exist "%windir%\temp" del /f /q "C:WINDOWS\temp\*.*"
if exist "%windir%\tmp" del /f /q "C:\WINDOWS\tmp\*.*"
if exist "%homedrive%\tmp" del /f /q "C:\tmp\*.*"
if exist "%homedrive%\temp" del /f /q "C:\temp\*.*"
if exist "%temp%" del /f /q "%temp%\*.*"
if exist "%tmp%" del /f /q "%tmp%\*.*"
if exist "%windir%\ff*.tmp" del C:\WINDOWS\ff*.tmp /f /q
if exist "%windir%\ShellIconCache" del /f /q "C:\WINDOWS\ShellI~1\*.*"

echo Deleting Registry Entries
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist /f
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs /f
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /f
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths /va /f
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

Clearing Explorer Recents
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1

exit /b
