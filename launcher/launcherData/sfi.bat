@echo off
setlocal

:: Initialize variables
set "folderPath="
set "iconPath="

:: Parse command-line arguments
:parseArgs
if "%~1"=="" goto endParse
if "%~1"=="-p" (
  set "folderPath=%~2"
  shift
  shift
) else if "%~1"=="-i" (
  set "iconPath=%~2"
  shift
  shift
) else (
  echo Invalid argument: %~1
  goto endParse
)
goto parseArgs

:endParse
:: Replace / with \ in folderPath and iconPath
set "folderPath=%folderPath:/=\%"
set "iconPath=%iconPath:/=\%"

if "%folderPath:~-1%" == "/" set "folderPath=%folderPath:~0,-1%"
if "%folderPath:~-1%" == "\" set "folderPath=%folderPath:~0,-1%"
:: Check if both arguments are provided
if "%folderPath%"=="" (
  echo Folder path is required. Use -p to specify it.
  exit /b 1
)

if "%iconPath%"=="" (
  echo Icon path is required. Use -i to specify it.
  exit /b 1
)

:: Create the desktop.ini file
(
echo [.ShellClassInfo]
echo IconFile=foldericon.ico
echo IconIndex=0
) > "%folderPath%\desktop.ini"

set "iconFilePath=%folderPath%\foldericon.ico"

if exist "%iconPath%" (
  echo Copying icon file...
  echo %iconPath%
  echo %iconFilePath%
  copy /Y /B "%iconPath%" "%iconFilePath%"
) else (
  echo Icon file not found: %iconPath%
  exit /b 1
)

:: Set the attributes for the folder and the desktop.ini file
attrib +s "%folderPath%"
attrib +h "%folderPath%\desktop.ini"
attrib +h "%iconFilePath%"

echo Folder icon set successfully.
endlocal
