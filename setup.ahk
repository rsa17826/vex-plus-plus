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
aexepath := confirm("open console?") ? A_ScriptDir '/vex.console.exe' : A_ScriptDir '/vex.exe'
try {
  createFileAssoc("vex++", aexepath, "vex++ map file")
  createFileAssoc(extension, programName, exepath, fileTypeName := extension " file") {
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
    set("HKEY_LOCAL_MACHINE\SOFTWARE\" programName "\Capabilities", {
      ApplicationDescription: "" programName "",
      ApplicationIcon: "" exepath ",0",
      ApplicationName: "" programName ""
    })
    data := {}
    data.%extension% := programName
    set("HKEY_LOCAL_MACHINE\SOFTWARE\" programName "\Capabilities\FileAssociations", data)
    ; set("HKEY_LOCAL_MACHINE\SOFTWARE\" programName "\Capabilities\URLAssociations", {
    ;   ftp: "" programName "",
    ;   http: "" programName "",
    ;   https: "" programName ""
    ; })
    set("HKEY_LOCAL_MACHINE\SOFTWARE\RegisteredApplications", {
      %programName%: "Software\" programName "\Capabilities",
    })

    data := {
      FriendlyTypeName: fileTypeName
    }
    data.%"@"% := programName
    set("HKEY_LOCAL_MACHINE\Software\Classes\" programName "", data)
    set("HKEY_LOCAL_MACHINE\Software\Classes\" programName "\shell", {})
    set("HKEY_LOCAL_MACHINE\Software\Classes\" programName "\shell\open", {})
    data := {
      FriendlyTypeName: fileTypeName
    }
    data.%"@"% := "`"" exepath "`" `"%1`""

    set("HKEY_LOCAL_MACHINE\Software\Classes\" programName "\shell\open\command", data)
  }
} catch Error as e {
  if A_IsAdmin {
    MsgBox("Error: cannot create file association.`n" e.Message)
    ExitApp()
  } else {
    args := ""
    for arg in A_Args {
      args .= ' "' . StrReplace(arg, '"', '\"') . '"'
    }
    Run('*RunAs "' . A_AhkPath . '" "' . A_ScriptFullPath . '"' . args, A_WorkingDir)
    ExitApp()
  }
}
