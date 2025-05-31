;@Ahk2Exe-SetMainIcon pole.ico
#Requires AutoHotkey v2.0
#SingleInstance Force

; must include
#Include *i <AutoThemed>
#Include <admin>
#include <vars>

#Include <base> ; Array as base, Map as base, String as base, File as F, JSON

#Include <Misc> ; print, range, swap, ToString, RegExMatchAll, Highlight, MouseTip, WindowFromPoint, ConvertWinPos, WinGetInfo, GetCaretPos, IntersectRect
SetWorkingDir(A_ScriptDir)
exepath := A_ScriptDir '/vex.console.exe'
MyApp := "vex plus plus"
MyAppURL := MyApp
extensions := [
  "vex++"
]
set(key, data) {
  try RegDeleteKey(key)
  RegCreateKey(key)
  for k, v in data.OwnProps() {
    if k == "@"
      RegWrite(v, "REG_SZ", key)
    else
      RegWrite(v, "REG_SZ", key, k)
  }
}
set("HKEY_LOCAL_MACHINE\SOFTWARE\" MyApp "\Capabilities", {
  ApplicationDescription: "" MyApp "",
  ApplicationIcon: "" exepath ",0",
  ApplicationName: "" MyApp ""
})

data := {}
for k in extensions {
  data.%k% := MyAppURL
}
set("HKEY_LOCAL_MACHINE\SOFTWARE\" MyApp "\Capabilities\FileAssociations", data)
; set("HKEY_LOCAL_MACHINE\SOFTWARE\" MyApp "\Capabilities\URLAssociations", {
;   ftp: "" MyAppURL "",
;   http: "" MyAppURL "",
;   https: "" MyAppURL ""
; })
set("HKEY_LOCAL_MACHINE\SOFTWARE\RegisteredApplications", {
  %MyApp%: "Software\" MyApp "\Capabilities",
})
data := {
  FriendlyTypeName: "" MyApp " Document"
}
data.%"@"% := "" MyApp " Document"
set("HKEY_LOCAL_MACHINE\Software\Classes\" MyAppURL "", data)
set("HKEY_LOCAL_MACHINE\Software\Classes\" MyAppURL "\shell", {})
set("HKEY_LOCAL_MACHINE\Software\Classes\" MyAppURL "\shell\open", {})
data := {
  FriendlyTypeName: "" MyApp " Document"
}
data.%"@"% := "`"" exepath "`" `"%1`""

set("HKEY_LOCAL_MACHINE\Software\Classes\" MyAppURL "\shell\open\command", data)
; run("ms-settings:defaultbrowsersettings")
; run("ms-settings:defaultapps")
; if 0 {
;   FileInstall("browser selector icon.ico", "*")
; }
