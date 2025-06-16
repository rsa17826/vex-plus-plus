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
versionListView := ui.Add("ListView", "vVersionList w290 h300", [
  "Version",
  "Status",
  "Run",
])
try FileDelete("c.bat")
try DirDelete("temp", 1)
if FileExist("launcher.exe") and FileExist("vex++.exe") {
  try FileDelete("launcher.exe")
}
if not FileExist("vex++ offline.lnk") {
  FileCreateShortcut(A_ScriptDir "\vex++.exe", "vex++ offline.lnk", A_ScriptDir, "offline")
}
offline := A_Args.join(" ").includes("offline")
DirCreate("versions")
ui.Title := "Vex++ Version Manager"
ui.Show()
; Populate the ListView with versions and their statuses
; Define the GitHub API URL for fetching releases
apiUrl := "https://api.github.com/repos/rsa17826/vex-plus-plus/releases"
addedVersions := []
listedVersions := []
; Fetch the releases from the GitHub API
loop files A_ScriptDir "/versions/*", 'D' {
  dirname := path.info(A_LoopFileFullPath).nameandext
  ; if relnames.includes(dirname)
  ;   continue
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
  versionListView.Add("", versionName, status, "Run version " versionName)
}

versionListView.OnEvent("DoubleClick", LV_DoubleClick)

versionListView.ModifyCol(2)
versionListView.ModifyCol(3)
if !offline {
  releases := FetchReleases(apiUrl)
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
for thing in listedVersions.sort((a, s) {
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
  return StrCompare(a.name, s.name, "Logical")
}).Reverse() {
  i += 1
  versionListView.Modify(i, "Col1", thing.version)
  versionListView.Modify(i, "Col2", thing.status)
  versionListView.Modify(i, "Col3", thing.runtext)
}

versionListView.ModifyCol(2)
versionListView.ModifyCol(3)
ogcButtonDownloadSelectedVersion := ui.Add("Button", , "Download All Versions")
ogcButtonDownloadSelectedVersion.OnEvent("Click", DownloadAll)
ogcButtonDownloadSelectedVersion := ui.Add("Button", , "Update Self")
ogcButtonDownloadSelectedVersion.OnEvent("Click", UpdateSelf)
ui.Show("AutoSize")

UpdateSelf(*) {
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
    ToolTip("Downloading...")
    Download(url, "temp.zip")
    unzip("temp.zip", "temp")
    FileDelete("temp.zip")

    ; if script doesnt exist then don't update it
    if !FileExist("vex++.ahk")
      try FileDelete("temp/vex++.ahk")

    F.write("./c.bat", "
    (
@echo off
timeout /t 1 /nobreak >nul
xcopy /y /i ".\temp\*" ".\"
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

runSelectedVersion() {
  selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0]
  exe := path.join(A_ScriptDir, "exe", "vex.console.exe")
  ; print(path.join(path.info(exe).parentdir, "versions", selectedVersion))
  args := ""
  for arg in A_Args {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  run('"' . exe . '"' . args, path.join(path.info(exe).parentdir, "versions", selectedVersion))
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
  ; Find the release corresponding to the selected version
  for release in releases {
    ; print(release.tag_name, selectedVersion)
    if (release.tag_name = selectedVersion) {
      url := release.assets[release.assets.find(e => e.browser_download_url.endsWith("windows.zip"))].browser_download_url
      break
    }
  }

  ; Download and extract the selected version
  if (url) {
    updateRow(row, , "Downloading...")
    DirCreate("versions/" selectedVersion)
    Download(url, "temp.zip")
    unzip("temp.zip", "temp")
    try {
      FileMove("temp\vex.pck", "versions/" selectedVersion "\vex.pck", 1)
      updateRow(row, , "Installed", "Run version " selectedVersion)
    } catch {
      updateRow(row, , "Failed to find vex.pck file", "")
      DirDelete("versions/" selectedVersion, 1)
    }

    ; Clean up temporary files
    FileDelete("temp.zip")
    DirDelete("temp", 1)
  } else {
    listedVersions[row].status = "Failed"
    versionListView.Modify(row, "Col2", "Failed")
    MsgBox("Failed to find download URL for version " selectedVersion ".")
  }
}

; Function to fetch releases from the GitHub API
FetchReleases(apiUrl) {
  ret := []
  i := 0
  while 1 {
    i += 1
    jsonFile := A_Temp "\releases.json"
    Download(apiUrl "?page=" i, jsonFile)

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

  return ret
}

GuiClose(*) {
  ExitApp()
}
