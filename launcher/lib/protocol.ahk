#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <base>
; #Include <admin>

class PROTO {
  static path := A_IsCompiled ? "`"" A_ScriptFullPath "`" `"%1`"" : "`"" A_AhkPath "`" `"" A_ScriptFullPath "`" `"%1`""

  /**
   * copies the string to add in the about:config to allow this to work in firefox
   * @param proto the protocol to listen for
   * @returns {String} returns and copies the text required to enable in firefox
   */
  static howToAdd(proto) {
    return A_Clipboard := "network.protocol-handler.external." proto
  }

  /**
   * listens for the protocol to be called
   * @param proto the protocol to listen for
   * @param cb the function to call when the protocol is triggered
   * @returns {Integer} returns true if the protocol was registered successfully
   */
  static add(proto, cb, force := 0) {
    ; print(this.path, "path", A_ScriptFullPath, this.isSelf(proto), proto)
    if A_Args.Has(1) {
      temp := A_Args[1].RegExMatch("^([^:]+):(.*)$")
      temp := [
        temp[1],
        temp[2]
      ]
      if temp[1] = proto {
        loop
          if RegExMatch(temp[2], "i)(?<=%)[\da-f]{1,2}", &hex)
            temp[2] := StrReplace(temp[2], "%" hex[0], Chr("0x" . hex[0]))
          else break
        try {
          cb(temp[2], temp[1])
        } catch {
          cb(temp[2])
        }
      }
    }
    if this.isSelf(proto) {
      return 1
    }
    if this.exists(proto) {
      if !this.isPathStillValid(proto) {
        RegWrite("URL:" proto, "REG_SZ", "HKCR\" proto)
        RegWrite("", "REG_SZ", "HKCR\" proto, "URL Protocol")
        RegWrite("open", "REG_SZ", "HKCR\" proto "\shell")
        RegWrite(this.path, "REG_SZ", "HKCR\" proto "\shell\open\command")
        ; this.howToAdd(proto)
        return 1
      } else {
        if this.errorOnAddFailure
          throw(Error("Protocol already exists for " proto "`nisAHKScript: " this.isAHKScript(proto) "`ncurrent path: " this.pathFor(proto)))
        return 0
      }
    }
    RegWrite("URL:" proto, "REG_SZ", "HKCR\" proto)
    RegWrite("", "REG_SZ", "HKCR\" proto, "URL Protocol")
    RegWrite("open", "REG_SZ", "HKCR\" proto "\shell")
    RegWrite(this.path, "REG_SZ", "HKCR\" proto "\shell\open\command")
    ; this.howToAdd(proto)
    return 1
  }

  /**
   * @param proto the protocol to check for
   * @returns {Integer} returns true if the protocol has been registered
   */
  static exists(proto) {
    try return !!RegRead("HKCR\" proto "\shell")
    return false
  }

  /**
   * @param proto the protocol to remove
   * @returns {Number} returns true if it was removed successfully
   */
  static remove(proto) {
    try RegDelete("HKCR\" proto)
    if this.errorOnAddFailure and this.exists(proto) {
      A_Clipboard := "HKCR\" proto
      Run("regedit")
      throw(Error("failed to remove " proto " at " A_ScriptFullPath))
    }
    return !this.exists(proto)
  }

  /**
   * @param proto the protocol to check
   * @returns {Integer} returns true if the protocol was registered to this script
   */
  static isSelf(proto) {
    try return RegRead("HKCR\" proto "\shell\open\command") == this.path
    return 0
  }

  /**
   * set to 0 to handle errors manually, set to 1 to show error message on error
   */
  static errorOnAddFailure := 1

  /**
   * @param {String} proto the protocol to check
   * @returns {Integer} returns 1 if the protocol is attached to an ahk script
   */
  static isAHKScript(proto) {
    return RegRead("HKCR\" proto "\shell\open\command").startsWith(A_IsCompiled ? "`"" : "`"" A_AhkPath "`" `"")
  }

  static isPathStillValid(proto) {
    text := this.pathFor(proto)
    return text and !!FileExist(text)
  }

  /**
   * @param {String} proto the protocol to check
   * @returns {Integer | String} returns the path to the ahk file that the protocol is attached to or 0 if none
   */
  static pathFor(proto) {
    start := A_IsCompiled ? "`"" : "`"" A_AhkPath "`" `""
    try text := RegRead("HKCR\" proto "\shell\open\command")
    if !IsSet(text) || !text.startsWith(start)
      return 0
    return text[start.length + 1, -7]
  }

  /**
   * @returns {Integer} returns 1 if the script was called from a protocol being triggered
   */
  calledFromProto() {
    return !!A_Args.Has(1)
  }
}
