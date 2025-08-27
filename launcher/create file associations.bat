@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal

rem Define the file extension
set "fileExtension=vex++"

rem Get the path to the current directory where the script is located
set "appPath=%~dp0vex++.exe"

rem Create the file association
assoc .%fileExtension%="vex++ map file"
ftype "vex++ map file"="%appPath%" "offline" "%%1"

rem Optional: Display a message to confirm the association
echo File association for .%fileExtension% created with %appPath%.
pause
endlocal