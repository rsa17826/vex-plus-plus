;@Ahk2Exe-SetMainIcon ../pole.ico
#Requires AutoHotkey v2.0
#SingleInstance Force
; A_DebuggerName
#Include *i <AutoThemed>

#Include <compiledArgFixer>

try TraySetIcon("icon.ico")
SetWorkingDir(A_ScriptDir)

#Include <Misc>
#Include <protocol>

; @name terst
; @regex \}\)\s+\.\s+Reverse
; @replace }).Reverse
; @endregex

if A_ScriptDir = "D:\godotgames\vex\launcher" and A_UserName = 'user' {
  aotMsgBox("don't run from here")
  ExitApp()
}

if FileExist('@setup.bat') {
  FileDelete('@setup.bat')
}

logPrints := 1
apiUrl := "https://api.github.com/repos/rsa17826/vex-plus-plus/releases"
doingSomething := 0
releases := 0
selfPath := A_ScriptDir '\' (A_IsCompiled ? "vex++.exe" : "vex++.cmd")

validGameArgs := A_Args.filter(e => ![
  "offline",
  "tryupdate",
  "update",
  "silent",
  "registerProtocols",
  "createFileAssociations",
].includes(e)).filter(e => !e.startsWith("vex++:"))

settings := JSON.parse(f.read('launcherData/settings.json', '{}'), , 0)
gettings := OptObj(settings)
saveSettings()
saveSettings() {
  global gettings
  gettings := OptObj(settings)
  temp := JSON.stringify(settings)
  f.write('launcherData/settings.json', temp)
}

SILENT := A_Args.includes("silent")
OFFLINE := A_Args.includes("offline")

if ((
  A_Args.includes("registerProtocols")
  || A_Args.includes("createFileAssociations")
) and not A_IsAdmin) {
  args := ""
  for arg in A_Args {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  if A_IsCompiled
    Run('*RunAs "' A_ScriptFullPath . '"' . args, A_WorkingDir)
  else
    Run('*RunAs "' . A_AhkPath . '" "' . A_ScriptFullPath . '"' . args, A_WorkingDir)
  ExitApp()
}

if PROTO.isSelf('vex++') or A_Args.includes("registerProtocols")
  PROTO.add("vex++", (data) {
    try {
      data := data.split('/')
      switch data[1] {
        case "downloadMap":
          data.RemoveAt(1)
          if data.length == 3 {
            if runVersion(data[1], [
              '--downloadMap',
              data.join('/'),
              '--loadMap',
              data[3]
            ])
              ExitApp(0)
            else
              ExitApp(-1)
          }
          else {
            logerr("failed to download level " data.join("/") ' is not the correct length!!')
          }
        default:
          logerr("nothing found for `"" data[1] "`"`ndata received:`n" data.join('/'))
      }
    } catch Error as e
      logerr(data, e)
  }, 1)
fileAssocs := [
  'Vex++ map file="' selfPath '" "offline" "%1"'
]
RunWait('cmd /c ftype > "' A_Temp '/ftypeData"', , 'hide')
ftypeData := f.read(A_Temp '/ftypeData').Replace('`r', '`n').split('`n')
FileDelete(A_Temp '/ftypeData')
if fileAssocs.find(p => !ftypeData.includes(p)) {
  if !FileExist("CREATE FILE ASSOCIATIONS.lnk")
    FileCreateShortcut(
      selfPath
      , "CREATE FILE ASSOCIATIONS.lnk", , "createFileAssociations")
} else {
  try FileDelete("CREATE FILE ASSOCIATIONS.lnk")
}
if [
  'vex++'
].find(p => !PROTO.isSelf(p)) {
  if !FileExist("CREATE PROTOCOL HANDLER.lnk")
    FileCreateShortcut(
      selfPath
      , "CREATE PROTOCOL HANDLER.lnk", , "registerProtocols")
} else {
  try FileDelete("CREATE PROTOCOL HANDLER.lnk")
}
if A_Args.includes("createFileAssociations") {
  data := "
  (
if exist "%~dp0vex++.exe" (
  set "appPath=%~dp0vex++.exe"
`) else if exist "%~dp0vex++.cmd" (
  set "appPath=%~dp0vex++.cmd"
`) else (
  echo Error: Neither vex++.exe nor vex++.cmd found in the script directory.
  pause
  exit /b
`)
set "fileExtension=vex++"
assoc .%fileExtension%="vex++ map file"
ftype "vex++ map file"="%appPath%" "offline" "%%1"
  )"
  f.write("./temp.bat", data)
  RunWait("*runas temp.bat")
  Sleep(100)
  FileDelete("./temp.bat")
  RunWait('cmd /c ftype > "' A_Temp '/ftypeData"', , 'hide')
  ftypeData := f.read(A_Temp '/ftypeData').Replace('`r', '').split('`n')
  FileDelete(A_Temp '/ftypeData')
  if !fileAssocs.find(p => !ftypeData.includes(p)) {
    try FileDelete("CREATE FILE ASSOCIATIONS.lnk")
  }
}
if (A_Args.includes("registerProtocols")
|| A_Args.includes("createFileAssociations"))
  ExitApp()

if FileExist("c.bat") and F.read("updating self") != 'silent' {
  aotMsgBox("launcher update was successful")
  FileDelete("c.bat")
}
if FileExist("updating self") {
  if FileExist('temp.zip') {
    if F.read("updating self") == 'silent' {
      silent := 1
    }
    FileDelete("updating self")
    FileDelete("temp.zip")
    logerr("failed while updating the launcher!!!")
    try DirDelete("temp", 1)
    FileDelete("c.bat")
    ExitApp(-1)
  } else {
    loadReleases()
    F.write("launcherData/launcherVersion", releases.Length)
    if F.read("updating self") == 'silent' {
      FileDelete("updating self")
      try DirDelete("temp", 1)
      FileDelete("c.bat")
      ExitApp(0)
    }
    FileDelete("updating self")
    try DirDelete("temp", 1)
  }
}
else {
  if FileExist('temp.zip') {
    FileDelete("temp.zip")
    logerr("failed while installing a game version!!")
  }
}

try FileDelete("vex++ offline.lnk")
FileCreateShortcut(selfPath, "vex++ offline.lnk", A_ScriptDir, "offline")
DirCreate("launcherData")
DirCreate("game data")
DirCreate("versions")
if not FileExist("launcherData/launcherVersion") {
  try FileCreateShortcut(A_ScriptDir "\vex++.exe", A_startup "/vex++ updater.lnk", A_ScriptDir, "tryupdate silent")
}
icon(s, e := unset) {
  if !IsSet(e)
    e := s
  if path.isdir(s)
    sfi(path.join(A_ScriptDir, s), path.join(A_ScriptDir, "icons", e ".ico"))
}

icon("logs")
icon("versions", "exes")
icon("lib", "exes")
icon("launcherData", 'exes')
icon("launcherData/exes", 'exes')
icon("icons", 'exes')
icon("ahk")
icon("game data", "editorIcon")
loop files A_ScriptDir "\icons\*.ico" {
  p := path.join(A_ScriptDir, 'game data', path.name(A_LoopFileFullPath))
  if DirExist(p) {
    sfi(p, A_LoopFileFullPath)
  }
}

if A_Args.includes("tryupdate") {
  loadReleases()
  if F.read("launcherData/launcherVersion") != releases.Length {
    UpdateSelf()
  }
}
if A_Args.includes("update") {
  loadReleases()
  UpdateSelf()
}
if A_Args.includes("version") {
  try {
    gameVersion := A_Args[A_Args.IndexOf("version") + 1]
    gameVersion := String(gameVersion)
    if not FileExist(path.join(A_ScriptDir, "versions", gameVersion, "vex.pck")) {
      loadReleases()
      DownloadSelected(1, gameVersion)
    }
    runVersion(gameVersion)
  } catch Error as e {
    logerr("Could not get game version from command line.", e)
  }
}
if [
  "update",
  "version",
  'tryupdate',
  "registerProtocols",
].find(e => A_Args.includes(e)) {
  ExitApp()
}
; if a vex++ file has been opened direct it to the last ran game version if the game is still open
if hasProcessRunning() and F.read("launcherData/lastRanVersion.txt") {
  args := ""
  for arg in validGameArgs {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  ; args .= ' ' F.read("launcherData/defaultArgs.txt")
  run('"' . path.join(A_ScriptDir, "game data/vex.exe") . '"' . args, path.join(A_ScriptDir, "versions", F.read("launcherData/lastRanVersion.txt")))
  ExitApp()
}

; setup gui
{
  ui := Gui("+AlwaysOnTop")
  ui.OnEvent("Close", GuiClose)
  ui.Add("Text", , "Vex++ Version Manager")
  versionListView := ui.Add("ListView", "vVersionList w290 h300", [
    "Version",
    "Status",
    "Run",
  ])
  ui.Title := "Vex++ Version Manager"

  ; load local versions
  localVersionList := []
  listedVersions := []
  loop files A_ScriptDir "/versions/*", 'D' {
    dirname := path.info(A_LoopFileFullPath).nameandext
    versionName := dirname
    versionPath := "versions/" versionName
    status := OFFLINE ? "" : "LocalOnly"
    localVersionList.push(versionName)
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

  ; show ui
  ui.Show("AutoSize")

  ; load online releases
  if !OFFLINE {
    loadReleases()
    newUpdateAvailable := F.read("launcherData/launcherVersion") != releases.Length
    for release in releases {
      versionName := release.tag_name
      versionPath := "versions/" versionName
      status := DirExist(versionPath) ? "Installed" : "Not Installed"
      if idx := localVersionList.IndexOf(versionName) {
        versionListView.Modify(idx, "Col2", "Installed")
        versionListView.Modify(idx, "Col3", "Run version " versionName)
        listedVersions[idx].status := "Installed"
        listedVersions[idx].runtext := "Run version " versionName
      } else {
        localVersionList.push(versionName)
        listedVersions.push({
          version: versionName,
          status: status,
          runtext: ""
        })
        versionListView.Add("", versionName, status, '')
      }
    }
  }
  ; default args textedit
  guiCtrl := ui.Add("Edit", 'w290', F.read("launcherData/defaultArgs.txt"))
  guiCtrl.OnEvent("change", (elem, *) {
    F.write("launcherData/defaultArgs.txt", elem.text)
  })
  GuiSetPlaceholder(guiCtrl, "extra game arguments go here")
  ; open launcher log btn
  if FileExist(path.info('./logs/vex++.exe.ans').abspath) {
    guiCtrl := ui.Add("Button", , "open launcher log")
    guiCtrl.OnEvent("Click", (*) {
      run(path.info('./logs/vex++.exe.ans').abspath)
    })
  }
  ; open game logs folder btn
  guiCtrl := ui.Add("Button", FileExist(path.info('./logs/vex++.exe.ans').abspath) ? 'y+-23 x+5' : '', "open game logs folder")
  guiCtrl.OnEvent("Click", (*) {
    run(A_AppData "\Godot\app_userdata\vex\logs\")
  })

  ; launcher update btn
  guiCtrl := ui.AddText("x10 y+-13 BackgroundTrans", '')
  if not OFFLINE {
    guiCtrl := ui.Add("Button", '', "Download All Versions")
    guiCtrl.OnEvent("Click", DownloadAll)
    if newUpdateAvailable
      guiCtrl := ui.Add("Button", '', "new launcher version available - click to update")
    else
      guiCtrl := ui.Add("Button", '', "launcher is up to date")
    guiCtrl.OnEvent("Click", UpdateSelf)
  }
  guiCtrl := ui.Add("Button", '', "open game data folder")
  guiCtrl.OnEvent("Click", (*) {
    run(A_ScriptDir)
  })
  guiCtrl := ui.Add("Button", '', "try fix new maps for old versions")
  guiCtrl.OnEvent("Click", (*) {
    global doingSomething
    if doingSomething {
      aotMsgBox("already doing something, wait till done")
      return
    }
    doingSomething := 1
    loop files "./game data/maps/*", 'd' {
      settingsPath := path.join(A_LoopFileFullPath, "options.sds")
      if !FileExist(settingsPath)
        continue
      data := f.read(settingsPath)
      if !data.includes("{") {
        logerr(data, settingsPath, "not a valid settings file")
        continue
      }
      if !data.includes("STR(author)STR(") {
        data := data.Replace("{", "{STR(author)STR()", , , 1)
      }
      if !data.includes("STR(version)INT(") {
        data := data.Replace("{", "{STR(version)INT(-1)", , , 1)
      }
      f.write(settingsPath, data)
    }
    doingSomething := 0
  })

  ; check for updates on startup checkbox
  updateOnBoot := FileExist(A_startup '/vex++ updater.lnk')
  guiCtrl := ui.AddCheckbox((updateOnBoot ? "+Checked" : '') '', "check for updates on startup")
  guiCtrl.OnEvent("Click", (elem, info) {
    print(elem, info)
    global updateOnBoot
    updateOnBoot := elem.Value
    try FileDelete(A_startup "/vex++ updater.lnk")
    if updateOnBoot {
      FileCreateShortcut(A_ScriptDir "\vex++.exe", A_startup "/vex++ updater.lnk", A_ScriptDir, "tryupdate silent")
    }
  })
  guiCtrl := ui.AddCheckbox((gettings.openGameConsole ? "+Checked" : '') '', "open console with game`nbreaks opening different version from inside game")
  guiCtrl.OnEvent("Click", (elem, info) {
    print(elem, info)
    settings.openGameConsole := elem.Value
    saveSettings()
  })
  sortVersionList()
  ; SetTimer(sortVersionList)
  ; update ui size
  ui.Show("AutoSize")
}

sortVersionList() {
  global listedVersions
  i := 0
  listedVersions := sortList(listedVersions)
  for thing in listedVersions {
    i += 1
    versionListView.Modify(i, "Col1", thing.version)
    versionListView.Modify(i, "Col2", thing.status)
    versionListView.Modify(i, "Col3", thing.runtext)
  }

  versionListView.ModifyCol(2)
  versionListView.ModifyCol(3)
  sortList(list) {
    lastRanVersion := F.read("launcherData/lastRanVersion.txt")
    return list.sort((a, s) {
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
    }).Reverse()
  }

}

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
    F.write("updating self", SILENT ? "silent" : "normal")
    tryCount := 0
    while (1) {
      try {
        tryCount += 1
        DownloadFile(url, "temp.zip", , !SILENT)
        break
      } catch Error as e {
        print("ERROR", "at updating self", e.Message, e.Line, e.Extra, e.Stack)
        if (tryCount > 10) {
          print("ERROR", "tryCount > 10 at updating self", e.Message, e.Line, e.Extra, e.Stack)
          FileDelete("updating self")
          try FileDelete("temp.zip")
          ExitApp(-1)
        }
        Sleep(10000)
      }
    }
    unzip("temp.zip", "temp")
    FileDelete("temp.zip")

    ; if script doesnt exist then don't update it
    if A_IsCompiled {
      try FileDelete("temp/vex++.ahk")
      try FileDelete("temp/vex++.cmd")
      try DirDelete("temp/lib", 1)
      try DirDelete("temp/ahk", 1)
    } else {
      try FileDelete('temp/vex++.exe')
    }
    try FileDelete('temp/@setup.bat')
    ; remove all pngs and imports as only icos are needed
    loop files "temp/icons/*.png", 'f'
      try FileDelete(A_LoopFileFullPath)
    loop files "temp/icons/*.import", 'f'
      try FileDelete(A_LoopFileFullPath)

    F.write("./c.bat", "
    (
@echo off
timeout /t 1 /nobreak >nul
xcopy /y /i /s /e ".\temp\*" ".\"

    )" (A_IsCompiled ? "start `"`" `"" selfPath '"' : '"' selfPath '"'))
    run("cmd /c c.bat", , "hide")
    ExitApp(0)
  }
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
runSelectedVersion() {
  runVersion(selectedVersion := ListViewGetContent("Selected", versionListView, ui).RegExMatch("\S+(?=\s)")[0])
  F.write("launcherData/lastRanVersion.txt", selectedVersion)
  ExitApp()
}
runVersion(gameVersion, newArgs := []) {
  global doingSomething
  if doingSomething {
    aotMsgBox("already doing something, wait till done")
    return
  }
  doingSomething := 1
  if !path.info(A_ScriptDir, "versions", gameVersion, "vex.pck").isfile
    return logerr("The selected version is not valid! " path.info(A_ScriptDir, "versions", gameVersion, "vex.pck").abspath)

  try {
    ; if hasProcessRunning() {
    ;   pid := F.read("game data/process")
    ;   if pid {
    ;     try {
    ;       ProcessClose(WinGetProcessName("ahk_pid " pid))
    ;       WinWaitClose("ahk_pid " pid)
    ;     }
    ;   }
    ; }
    ; consoleIsBlocked := 0
    try {
      exeVersion := getExeVersion(gameVersion, () {
        exeVersion := tryInput("Enter the exe version number.", '', '', "", "")
        p := path.join(A_ScriptDir, "versions", gameVersion, "exeVersion.txt")
        if exeVersion and not SILENT
          F.write(p, exeVersion)
        return exeVersion
      })
      if !exeVersion {
        doingSomething := 0
        logerr("ERROR", "Could not find the required executable version at A_Args.includes(`"version`")")
      }
      ; try {
      if gettings.openGameConsole
        FileCopy(
          path.join(A_ScriptDir, "launcherData/exes", exeVersion, "vex.console.exe"),
          path.join(A_ScriptDir, "game data/vex.console.exe"),
          1
        )
      ; } catch {
      ;   consoleIsBlocked := 1
      ; }
      i := 0
      while i < 10 {
        try {
          FileCopy(
            path.join(A_ScriptDir, "launcherData/exes", exeVersion, "vex.exe"),
            path.join(A_ScriptDir, "game data/vex.exe"),
            1
          )
          break
        } catch {
          i += 1
          sleep(400)
        }
      }
      if i >= 10 {
        print("ERROR", "start version 3")
      }
    }
    catch Error as e {
      logerr("Could not copy the required file at runSelectedVersion start version 2", e)
    }
    args := ""
    for arg in validGameArgs {
      args .= ' "' . StrReplace(arg, '"', '\"') . '"'
    }
    args .= ' ' F.read("launcherData/defaultArgs.txt")
    for arg in newArgs {
      args .= ' "' . StrReplace(arg, '"', '\"') . '"'
    }
    ; if consoleIsBlocked {
    ;   args .= ' RESTART_LAUNCHER'
    ;   run('"' . path.join(A_ScriptDir, "game data/vex.exe") . '"' . args, path.join(A_ScriptDir, "versions", gameVersion))
    ; } else {
    run('"' . path.join(A_ScriptDir, "game data/vex" (gettings.openGameConsole ? ".console" : '') ".exe") . '"' . args, path.join(A_ScriptDir, "versions", gameVersion))
    return 1
    ; }
  }
  catch Error as e {
    logerr("error while running runVersion gameVersion " gameVersion, e)
  }
}
updateRow(row, version?, status?, runtext?) {
  if not IsSet(versionListView)
    return
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
    if (release.tag_name = selectedVersion) {
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
    } catch Error as e {
      message := [
        "Failed to find vex.pck file",
        ""
      ]
      print("ERROR", "Failed to find vex.pck file at DownloadSelected", e.Message, e.Line, e.Extra, e.Stack)
      DirDelete("versions/" selectedVersion, 1)
    }
    targetFile := FileOpen(A_ScriptDir '/temp/vex.exe', "r")
    targetBuff := Buffer()
    targetBuff.Size := targetFile.Length
    target := targetFile.RawRead(targetBuff, targetFile.Length)

    updateRow(row, , "finding correct exe version", "")
    ; _f := FileOpen("D:\Games\vex++\tempEXECMP", "w", "UTF-16-RAW")
    ; _f.write(target)
    ; _f.close()
    loop files A_ScriptDir "/launcherData/exes/*", 'D' {
      updateRow(row, , "checking - " A_LoopFileName, "")
      print("reading file: " A_LoopFileName)
      testFile := FileOpen(A_LoopFileFullPath '/vex.exe', "r")
      testBuff := Buffer()
      testBuff.Size := testFile.Length
      target := testFile.RawRead(testBuff, testFile.Length)
      if BufferEqual(targetBuff, testBuff) {
        version := A_LoopFileName
        updateRow(row, , "found correct exe version - " A_LoopFileName, "")
        print("found correct exe version - " A_LoopFileName)
        sleep(500)
        break
      }
    }
    if IsSet(version) {
      F.write("versions/" selectedVersion "/exeVersion.txt", version)
    } else {
      version := selectedVersion
      i := 2
      while DirExist("launcherData/exes/" version) {
        version := selectedVersion " - " i
        i += 1
      }
      DirCreate("launcherData/exes/" selectedVersion)
      FileCopy("temp/vex.exe", "launcherData/exes/" selectedVersion '/vex.exe')
      FileCopy("temp/vex.console.exe", "launcherData/exes/" selectedVersion '/vex.console.exe')
      F.write("versions/" selectedVersion "/exeVersion.txt", version)
    }
    ; version := getExeVersion(selectedVersion)
    ; Clean up temporary files
    FileDelete("temp.zip")
    DirDelete("temp", 1)
    updateRow(row, , message*)
  } else {
    listedVersions[row].status = "Failed"
    versionListView.Modify(row, "Col2", "Failed")
    logerr("Failed to find download URL for version " selectedVersion ".")
  }
  doingSomething := 0
}

; Function to fetch releases from the GitHub API
FetchReleases(apiUrl) {
  rand := random()
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
        Download(apiUrl "?page=" i "&rand=" rand, jsonFile)
        break
      } catch Error as e {
        print("ERROR", "at FetchReleases", e.Message, e.Line, e.Extra, e.Stack)
        if (tryCount > 10) {
          print("ERROR", "tryCount > 10 at FetchReleases", e.Message, e.Line, e.Extra, e.Stack)
          ExitApp(-1)
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

;

bufferEqual(Buf1, Buf2) {
  return Buf1.Size == Buf2.Size && DllCall("msvcrt\memcmp", "Ptr", Buf1, "Ptr", Buf2, "Ptr", Buf1.Size)
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
        for arg in validGameArgs {
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

sfi(p, i) {
  DirCreate(p)
  try FileDelete(path.join(p, "foldericon.ico"))
  run('sfi.bat -p "' p '" -i "' i '"', , 'hide')
}

getExeVersion(version, default?) {
  p := path.join(A_ScriptDir, "versions", version, "exeVersion.txt")
  if FileExist(p) {
    exever := F.read(p)
    if DirExist(path.join(A_ScriptDir, "launcherData/exes", exever))
      return exever
    inp := tryInput("exe version `"" exever "`" not found", '', '', "", "")
    if inp {
      F.write(p, inp)
      return inp
    }
    return
  }
  if IsSet(default)
    return default()
  exeVersion := tryInput("Enter the exe version number.", '', '', "", "")
  if exeVersion and not SILENT
    F.write(p, exeVersion)
  return exeVersion
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

loadReleases() {
  global releases
  if releases
    return
  releases := FetchReleases(apiUrl)
}

tryInput(text?, ifUnset?, title?, options?, default?) {
  if SILENT {
    return IsSet(default) ? default : unset
  }
  return input(text?, ifUnset?, title?, options?, default?)
}
logerr(msgs*) {
  msgs := msgs.map((e) => e is Error ? (e.Message, e.Line, e.Extra, e.Stack) : e)
  print("ERROR", msgs, "A_LastError: ", A_LastError)
  if !SILENT {
    aotMsgBox(msgs.join(" - "), "ERROR")
  }
}

GuiClose(*) {
  ExitApp()
}
