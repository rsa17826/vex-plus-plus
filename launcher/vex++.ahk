;@Ahk2Exe-SetMainIcon ../pole.ico
#Requires AutoHotkey v2.0
#SingleInstance Force

#Include *i <AutoThemed>

try TraySetIcon("icon.ico")
SetWorkingDir(A_ScriptDir)
#Include *i <vars>

#Include <Misc>

#Include *i <betterui> ; betterui

#Include *i <textfind> ; FindText, setSpeed, doClick

; @name terst
; @regex \}\)\s+\.\s+Reverse
; @replace }).Reverse
; @endregex

ui := Gui("+AlwaysOnTop")
ui.OnEvent("Close", GuiClose)
ui.Add("Text", , "Vex++ Version Manager")

apiUrl := "https://api.github.com/repos/rsa17826/vex-plus-plus/releases"
newestExeVersion := "4.5.beta6"
doingSomething := 0
versionListView := ui.Add("ListView", "vVersionList w290 h300", [
  "Version",
  "Status",
  "Run",
])
if FileExist("c.bat") and F.read("updating self") != 'silent' {
  aotMsgBox("launcher update was successful")
}
try FileDelete("c.bat")
try DirDelete("temp", 1)
try FileDelete("vex++ offline.lnk")
FileCreateShortcut(A_ScriptDir "\vex++.exe", "vex++ offline.lnk", A_ScriptDir, "offline")
DirCreate("launcherData")
if not FileExist("launcherData/launcherVersion") {
  try FileCreateShortcut(A_ScriptDir "\vex++.exe", A_startup "/vex++ updater.lnk", A_ScriptDir, "tryupdate silent")
}
releases := 0
loadReleases() {
  global releases
  if releases
    return
  releases := FetchReleases(apiUrl)
}

selfUpdate := A_Args.join(" ").includes("update")
silent := A_Args.join(" ").includes("silent")
offline := A_Args.join(" ").includes("offline")

if A_Args.join(" ").includes("tryupdate") {
  loadReleases()
  if F.read("launcherData/launcherVersion") != releases.Length {
    selfUpdate := 1
  }
}
if selfUpdate {
  loadReleases()
  UpdateSelf()
  ExitApp()
}

if FileExist("updating self") {
  if FileExist('temp.zip') {
    if F.read("updating self") == 'silent' {
      FileDelete("updating self")
      FileDelete("temp.zip")
    } else {
      FileDelete("updating self")
      FileDelete("temp.zip")
      aotMsgBox("failed while updating the launcher!!!")
    }
  } else {
    loadReleases()
    F.write("launcherData/launcherVersion", releases.Length)
    if F.read("updating self") == 'silent' {
      FileDelete("updating self")
      ExitApp()
    }
    FileDelete("updating self")
  }
}
else {
  if FileExist('temp.zip') {
    FileDelete("temp.zip")
    aotMsgBox("failed while installing a game version!!")
  }
}
hasProcessRunning() {
  ; if the game process is running
  if FileExist("game data/process") {
    pid := F.read("game data/process")
    if !pid {
      return 0
    }
    if WinExist("ahk_pid " pid) {
      ; if the game process is vex
      if WinGetProcessName("ahk_pid " pid) == "vex.exe" {
        hasExtraArgs := 0
        for arg in A_Args {
          if arg == "offline"
            continue
          hasExtraArgs := 1
          break
        }
        ; if there is args to pass to the game then return 1 else close the game and run normally
        if hasExtraArgs {
          WinActivate("ahk_pid " pid)
          return 1
        } else {
          WinClose("ahk_pid " pid)
          return 0
        }
      }
    }
    return 0
  }
}

if hasProcessRunning() and F.read("launcherData/lastRanVersion.txt") {
  args := ""
  for arg in A_Args {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  run('"' . path.join(A_ScriptDir, "game data/vex.exe") . '"' . args, path.join(A_ScriptDir, "versions", F.read("launcherData/lastRanVersion.txt")))
  ExitApp()
}

sfi(p, i) {
  DirCreate(p)
  try FileDelete(path.join(p, "foldericon.ico"))
  run('sfi.bat -p "' p '" -i "' i '"', , 'hide')
}

sfi(path.join(A_ScriptDir, 'launcherData'), path.join(A_ScriptDir, "icons", "exes.ico"))
sfi(path.join(A_ScriptDir, 'launcherData/exes'), path.join(A_ScriptDir, "icons", "exes.ico"))
loop files A_ScriptDir "\icons\*.ico" {
  p := path.join(A_ScriptDir, 'game data', path.info(A_LoopFileFullPath).name)
  if DirExist(p) {
    sfi(p, A_LoopFileFullPath)
  }
}

DirCreate("versions")
ui.Title := "Vex++ Version Manager"
ui.Show("AutoSize")
; Define the GitHub API URL for fetching releases
addedVersions := []
listedVersions := []
; Fetch the releases from the GitHub API
loop files A_ScriptDir "/versions/*", 'D' {
  dirname := path.info(A_LoopFileFullPath).nameandext
  versionName := dirname
  versionPath := "versions/" versionName
  status := offline ? "" : "LocalOnly"
  addedVersions.push(versionName)
  ; Add the version to the ListView
  listedVersions.push({
    version: versionName,
    status: status,
    runtext: "Run version " versionName
  })
  versionListView.Add("", versionName, status, "Run version " versionName) ;, getExeVersion(versionPath, () => '???'))
}

versionListView.OnEvent("DoubleClick", LV_DoubleClick)

versionListView.ModifyCol(2)
versionListView.ModifyCol(3)
ui.Show("AutoSize")
newUpdateAvailable := 0
if !offline {
  loadReleases()
  if F.read("launcherData/launcherVersion") != releases.Length {
    newUpdateAvailable := 1
  }
  for release in releases {
    versionName := release.tag_name
    versionPath := "versions/" versionName
    status := DirExist(versionPath) ? "Installed" : "Not Installed"
    if idx := addedVersions.IndexOf(versionName) {
      versionListView.Modify(idx, "Col2", "Installed")
      versionListView.Modify(idx, "Col3", "Run version " versionName)
      listedVersions[idx].status := "Installed"
      listedVersions[idx].runtext := "Run version " versionName
    } else {
      addedVersions.push(versionName)
      listedVersions.push({
        version: versionName,
        status: status,
        runtext: ""
      })
      versionListView.Add("", versionName, status, '')
    }
  }
}
i := 0
lastRanVersion := F.read("launcherData/lastRanVersion.txt")
for thing in listedVersions.sort((a, s) {
  if lastRanVersion {
    if a.version == lastRanVersion and s.version != lastRanVersion {
      return 1
    }
    if s.version == lastRanVersion and a.version != lastRanVersion {
      return -1
    }
  }
  if a.status == "LocalOnly" and s.status != "LocalOnly" {
    return 1
  }
  if s.status == "LocalOnly" and a.status != "LocalOnly" {
    return -1
  }
  if a.version.RegExMatch("^\d+$") && s.version.RegExMatch("^\d+$") {
    return a.version - s.version
  }
  if a.version.RegExMatch("^\d+$") {
    return 1
  } else if s.version.RegExMatch("^\d+$") {
    return -1
  }
  return StrCompare(a.version, s.version, "Logical")
}).Reverse() {
  i += 1
  versionListView.Modify(i, "Col1", thing.version)
  versionListView.Modify(i, "Col2", thing.status)
  versionListView.Modify(i, "Col3", thing.runtext)
}

versionListView.ModifyCol(2)
versionListView.ModifyCol(3)
guiCtrl := ui.Add("Edit", 'w290', F.read("launcherData/defaultArgs.txt"))
guiCtrl.OnEvent("change", (elem, *) {
  F.write("launcherData/defaultArgs.txt", elem.text)
})

GuiSetPlaceholder(guiCtrl, "extra game arguments go here")

if not offline {
  guiCtrl := ui.Add("Button", , "Download All Versions")
  guiCtrl.OnEvent("Click", DownloadAll)
  if newUpdateAvailable
    guiCtrl := ui.Add("Button", , "new launcher version available - click to update")
  else
    guiCtrl := ui.Add("Button", , "launcher is up to date")
  guiCtrl.OnEvent("Click", UpdateSelf)
}
updateOnBoot := FileExist(A_startup '/vex++ updater.lnk')
guiCtrl := ui.AddCheckbox(updateOnBoot ? "+Checked" : '', "check for updates on startup")
guiCtrl.OnEvent("Click", (elem, info) {
  print(elem, info)
  global updateOnBoot
  updateOnBoot := elem.Value
  try FileDelete(A_startup "/vex++ updater.lnk")
  if updateOnBoot {
    FileCreateShortcut(A_ScriptDir "\vex++.exe", A_startup "/vex++ updater.lnk", A_ScriptDir, "tryupdate silent")
  }
})
ui.Show("AutoSize")

UpdateSelf(*) {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  doingSomething := 1
  maxVersion := 0
  url := ''
  for release in releases {
    ; print(release.tag_name, selectedVersion)
    try if release.tag_name > maxVersion {
      maxVersion := release.tag_name
      url := release.assets[release.assets.find(e => e.browser_download_url.endsWith("launcher.zip"))].browser_download_url
    }
  }
  if (url) {
    ; ToolTip("Downloading...")
    F.write("updating self", silent ? "silent" : "normal")
    tryCount := 0
    while (1) {
      try {
        tryCount += 1
        DownloadFile(url, "temp.zip", , !silent)
        break
      } catch {
        if (tryCount > 10) {
          FileDelete("updating self")
          try FileDelete("temp.zip")
          ExitApp()
        }
        Sleep(10000)
      }
    }
    unzip("temp.zip", "temp")
    FileDelete("temp.zip")

    ; if script doesnt exist then don't update it
    if !FileExist("vex++.ahk")
      try FileDelete("temp/vex++.ahk")
    ; remove all pngs as only icos are needed and imports
    loop files "temp/icons/*.png", 'f'
      try FileDelete(A_LoopFileFullPath)
    loop files "temp/icons/*.import", 'f'
      try FileDelete(A_LoopFileFullPath)

    F.write("./c.bat", "
    (
@echo off
timeout /t 1 /nobreak >nul
xcopy /y /i /s /e ".\temp\*" ".\"
start vex++.exe
    )")
    run("cmd /c c.bat", , "hide")
    ExitApp()
  }
}

LV_DoubleClick(LV, RowNumber) {
  Column := LV_SubItemHitTest(versionListView.hwnd)
  RowText := LV.GetText(RowNumber) ; Get the text from the row's first field.
  if Column == 2 {
    DownloadSelected(RowNumber)
  }
  if Column == 3 {
    runSelectedVersion()
  }
}

getExeVersion(version, default?) {
  p := path.join(A_ScriptDir, "versions", version, "exeVersion.txt")
  if FileExist(p) {
    exever := F.read(p)
    if DirExist(path.join(A_ScriptDir, "launcherData/exes", exever))
      return exever
    inp := input("exe version `"" exever "`" not found", '', '', "", newestExeVersion)
    if inp {
      F.write(p, inp)
      return inp
    }
    return
  }
  if IsSet(default)
    return default()
  exeVersion := input("Enter the exe version number.", '', '', "", newestExeVersion)
  if exeVersion
    F.write(p, exeVersion)
  return exeVersion
  ; if IsInteger(version) {
  ;   if version < 57
  ;     return 4.4
  ;   return 4.5
  ; }
}

runSelectedVersion() {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  doingSomething := 1
  selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0]
  if !path.info(A_ScriptDir, "versions", selectedVersion, "vex.pck").isfile
    return aotMsgBox("The selected version is not valid!", "Error", 0x30)

  exeVersion := getExeVersion(selectedVersion, () {
    ; if ListViewGetContent("Selected", versionListView, ui).includes("Installed") {
    exeVersion := input("Enter the exe version number.", '', '', "", newestExeVersion)
    p := path.join(A_ScriptDir, "versions", selectedVersion, "exeVersion.txt")
    if exeVersion
      F.write(p, exeVersion)
    return exeVersion
    ; }
  })
  if !exeVersion {
    doingSomething := 0
    return
    ; aotMsgBox("Could not find the required executable version.")
  }
  ; aotMsgBox('exeVersion ' exeVersion)
  if !hasProcessRunning() {
    try {
      FileCopy(
        path.join(A_ScriptDir, "launcherData/exes", exeVersion, "vex.console.exe"),
        path.join(A_ScriptDir, "game data/vex.console.exe"),
        1
      )
      FileCopy(
        path.join(A_ScriptDir, "launcherData/exes", exeVersion, "vex.exe"),
        path.join(A_ScriptDir, "game data/vex.exe"),
        1
      )
    }
    catch {
      aotMsgBox("Could not copy the required file, make sure there is no other vex++ instance running and try again.", "ERROR")
    }
  }
  ; print(path.join(path.info(exe).parentdir, "versions", selectedVersion))
  args := ""
  for arg in A_Args {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  args .= ' ' F.read("launcherData/defaultArgs.txt")
  F.write("launcherData/lastRanVersion.txt", selectedVersion)
  run('"' . path.join(A_ScriptDir, "game data/vex.console.exe") . '"' . args, path.join(A_ScriptDir, "versions", selectedVersion))
  ExitApp()
}

LV_SubitemHitTest(HLV) {
  ; To run this with AHK_Basic change all DllCall types "Ptr" to "UInt", please.
  ; HLV - ListView's HWND
  static LVM_SUBITEMHITTEST := 0x1039
  POINT := Buffer(8, 0)
  ; Get the current cursor position in screen coordinates
  DllCall("User32.dll\GetCursorPos", "Ptr", POINT.Ptr)
  ; Convert them to client coordinates related to the ListView
  DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", POINT.Ptr)
  ; Create a LVHITTESTINFO structure (see below)
  LVHITTESTINFO := Buffer(24, 0)
  ; Store the relative mouse coordinates
  NumPut("Int", NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0)
  NumPut("Int", NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4)
  ; Send a LVM_SUBITEMHITTEST to the ListView
  if (type(LVHITTESTINFO) = "Buffer") {
    ErrorLevel := SendMessage(LVM_SUBITEMHITTEST, 0, LVHITTESTINFO, , "ahk_id " HLV)
  } else {
    ErrorLevel := SendMessage(LVM_SUBITEMHITTEST, 0, StrPtr(LVHITTESTINFO), , "ahk_id " HLV)
  }
  ; If no item was found on this position, the return value is -1
  if (ErrorLevel = -1)
    return 0
  ; Get the corresponding subitem (column)
  Subitem := NumGet(LVHITTESTINFO, 16, "Int") + 1
  return Subitem
}

updateRow(row, version?, status?, runtext?) {
  if IsSet(version) {
    listedVersions[row].version := version
    versionListView.Modify(row, "Col1", listedVersions[row].version)
  }
  if IsSet(status) {
    listedVersions[row].status := status
    versionListView.Modify(row, "Col2", listedVersions[row].status)
  }
  if IsSet(runtext) {
    listedVersions[row].runtext := runtext
    versionListView.Modify(row, "Col3", listedVersions[row].runtext)
  }
  versionListView.ModifyCol(2)
  versionListView.ModifyCol(3)
}

DownloadAll(*) {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  ; Loop through each release to download and extract the ZIP file
  i := 0
  for thing in listedVersions {
    i += 1
    if DirExist("versions/" thing.version)
      continue
    DownloadSelected(i, thing.version)
  }
}

; Handle the download button click
DownloadSelected(Row, selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0]) {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  doingSomething := 1
  ; Find the release corresponding to the selected version
  for release in releases {
    ; print(release.tag_name, selectedVersion)
    if (release.tag_name = selectedVersion) {
      ; url := release.assets.find(e => e.browser_download_url.endsWith("pck.zip"))
      ; if !url
      url := release.assets.find(e => e.browser_download_url.endsWith("windows.zip"))
      if url
        url := release.assets[url].browser_download_url
      break
    }
  }

  ; Download and extract the selected version
  if (url) {
    updateRow(row, , "Downloading...")
    DirCreate("versions/" selectedVersion)
    DownloadFile(url, "temp.zip")
    updateRow(row, , "Unzipping...")
    unzip("temp.zip", "temp")
    updateRow(row, , "moving files")
    try {
      FileMove("temp\vex.pck", "versions/" selectedVersion "\vex.pck", 1)
      message := [
        "Installed",
        "Run version " selectedVersion
      ]
    } catch {
      message := [
        "Failed to find vex.pck file",
        ""
      ]
      DirDelete("versions/" selectedVersion, 1)
    }
    target := FileRead(A_ScriptDir '/temp/vex.exe', "UTF-16-RAW")
    updateRow(row, , "finding correct exe version", "")
    ; _f := FileOpen("D:\Games\vex++\tempEXECMP", "w", "UTF-16-RAW")
    ; _f.write(target)
    ; _f.close()
    loop files A_ScriptDir "/launcherData/exes/*", 'D' {
      ; aotMsgBox("reading file: " A_LoopFileName)
      if FileRead(A_LoopFileFullPath "/vex.exe", "UTF-16-RAW") == target {
        version := A_LoopFileName
        break
      }
    }
    if IsSet(version)
      F.write("versions/" selectedVersion "/exeVersion.txt", version)
    else
      version := getExeVersion(selectedVersion)
    ; Clean up temporary files
    FileDelete("temp.zip")
    DirDelete("temp", 1)
    updateRow(row, , message*)
  } else {
    listedVersions[row].status = "Failed"
    versionListView.Modify(row, "Col2", "Failed")
    aotMsgBox("Failed to find download URL for version " selectedVersion ".")
  }
  doingSomething := 0
}

; Function to fetch releases from the GitHub API
FetchReleases(apiUrl) {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  doingSomething := 1
  ret := []
  i := 0
  while 1 {
    i += 1
    jsonFile := A_Temp "\releases.json"
    tryCount := 0
    while (1) {
      try {
        tryCount += 1
        Download(apiUrl "?page=" i, jsonFile)
        break
      } catch {
        if (tryCount > 10) {
          ExitApp()
        }
        Sleep(10000)
      }
    }

    ; Read the JSON file
    data := FileRead(jsonFile)

    ; Parse the JSON to extract release information
    releases := JSON.parse(data, 0, 0)
    try {
      if !releases.Length {
        break
      }
      for rel in releases {
        ret.push(rel)
      }
      try FileDelete(jsonFile)
    }
    catch
      break
  }
  ; Clean up the temporary JSON file
  try FileDelete(jsonFile)
  doingSomething := 0
  return ret
}

GuiClose(*) {
  ExitApp()
}
