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

ui := Gui()
ui.OnEvent("Close", GuiClose)
ui.Add("Text", , "Vex++ Version Manager")
versionListView := ui.Add("ListView", "vVersionList w250 h300", [
  "Version",
  "Status",
  "Run",
])

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
  if a.version.RegExMatch("^\d+$") && s.version.RegExMatch("^\d+$") {
    if a.status == "LocalOnly" and s.status != "LocalOnly" {
      return 1
    }
    if s.status == "LocalOnly" and a.status != "LocalOnly" {
      return -1
    }
    return a.version - s.version
  }
  if a.version.RegExMatch("^\d+$") {
    return 1
  }
  return -1
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
ui.Show("AutoSize")

LV_DoubleClick(LV, RowNumber) {
  Row := A_EventInfo
  Column := LV_SubItemHitTest(versionListView.hwnd)
  RowText := LV.GetText(RowNumber) ; Get the text from the row's first field.
  if Column == 2 {
    DownloadSelected()
  }
  if Column == 3 {
    runSelectedVersion()
  }
}

runSelectedVersion() {
  selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0]
  exe := path.join(A_ScriptDir, "vex.console.exe")
  ; print(path.join(path.info(exe).parentdir, "versions", selectedVersion))
  run(exe, path.join(path.info(exe).parentdir, "versions", selectedVersion))
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

DownloadAll(*) {
  ; Loop through each release to download and extract the ZIP file
  for release in releases {
    if DirExist("versions/" release.tag_name)
      continue
    ; Construct the download URL for the ZIP file
    try {
      url := release.assets[release.assets.find(e => e.browser_download_url.endsWith("windows.zip"))].browser_download_url
    } catch {
      MsgBox("failed to find download url VERION " . release.tag_name)
      continue
    }
    DirCreate("versions/" release.tag_name)

    ; Download the ZIP file
    Download(url, "temp.zip")

    ; Unzip the downloaded file into a temporary folder
    unzip("temp.zip", "temp")

    ; Move the extracted vex.pck file to the version folder
    try FileMove("temp\vex.pck", "versions/" release.tag_name "\vex.pck")
    catch {
      DirDelete("versions/" release.tag_name)
      MsgBox("failed to find vex.pck file VERISON " . release.tag_name)
      continue
    }

    ; Clean up temporary files
    FileDelete("temp.zip")
    DirDelete("temp", 1)
  }
  Reload()
}

; Handle the download button click
DownloadSelected(*) {
  selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0]
  ToolTip("finding download url " selectedVersion)

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
    DirCreate("versions/" selectedVersion)
    ToolTip("Downloading " selectedVersion)
    Download(url, "temp.zip")
    unzip("temp.zip", "temp")

    ToolTip("moving files " selectedVersion)
    try {
      FileMove("temp\vex.pck", "versions/" selectedVersion "\vex.pck")
      ToolTip("Successfully downloaded and installed version " selectedVersion ".")
      Sleep(1000)
    } catch {
      MsgBox("Failed to find vex.pck file for version " selectedVersion ".")
      DirDelete("versions/" selectedVersion)
    }

    ToolTip("Cleaning up " selectedVersion)
    ; Clean up temporary files
    FileDelete("temp.zip")
    DirDelete("temp", 1)
  } else {
    MsgBox("Failed to find download URL for version " selectedVersion ".")
  }
  argReload()
  return
}

; Function to fetch releases from the GitHub API
FetchReleases(apiUrl) {
  ; Use UrlDownloadToFile to get the JSON response
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

; Close the GUI when the user exits
GuiClose(*) {
  ExitApp()
}
