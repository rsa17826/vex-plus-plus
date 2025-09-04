@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
  echo Requesting administrative privileges...
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

setlocal

set "fileExtension=vex++"

if exist "%~dp0vex++.exe" (
  set "appPath=%~dp0vex++.exe"
) else if exist "%~dp0vex++.cmd" (
  set "appPath=%~dp0vex++.cmd"
) else (
  echo Error: Neither vex++.exe nor vex++.cmd found in the script directory.
  pause
  exit /b
)

assoc .%fileExtension%="vex++ map file"
ftype "vex++ map file"="%appPath%" "offline" "%%1"

echo File association for .%fileExtension% created with %appPath%.
pause
endlocal