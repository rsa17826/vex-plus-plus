@echo off
del "%~dp0vex++ offline.lnk" 2> nul

echo Enter 1 to use the compiled version of the launcher
echo Enter 2 to use the ahk version
set /p input=": "

if "%input%"=="1" (
  goto compiled
) else (
  goto ahk
)

:ahk
mkdir "%~dp0ahk"
echo .
echo .
echo .
echo downloading AutoHotkey...
PowerShell -Command "Invoke-WebRequest 'https://www.autohotkey.com/download/2.1/AutoHotkey_2.1-alpha.18.zip' -OutFile '%~dp0ahk.zip'"
echo unzipping AutoHotkey...
PowerShell -Command "Expand-Archive -Path '%~dp0ahk.zip' -DestinationPath '%~dp0ahk\' -Force"
rmdir /S /Q "%~dp0ahk\UX"
del "%~dp0ahk.zip"
del "%~dp0ahk\AutoHotkey.chm"
del "%~dp0ahk\WindowSpy.ahk"
del "%~dp0ahk\license.txt"
del "%~dp0ahk\install.cmd"
del "%~dp0ahk\AutoHotkey32.exe"
del "%~dp0vex++.exe"
start "" "%~dp0ahk\AutoHotkey64.exe" "%~dp0vex++.ahk"
goto eof

:compiled
del vex++.cmd
del vex++.ahk
rmdir /S /Q "%~dp0lib"
start "" "%~dp0vex++.exe"
goto eof

:eof
