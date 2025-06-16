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
del "%folderPath%/foldericon.ico" > nul
copy /Y /B "%iconPath%" "%folderPath%/foldericon.ico" > nul

:: Set the attributes for the folder and the desktop.ini file
attrib +s "%folderPath%"
attrib +h "%folderPath%\desktop.ini"
attrib +h "%folderPath%/foldericon.ico"

echo Folder icon set successfully.
endlocal
