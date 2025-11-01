#Include <base>
#Include <betterui>

fg(color?) {
  return IsSet(color) ? "[38;5;" . color . "m" : "[0m"
}
bg(color?) {
  return IsSet(color) ? "[48;5;" . color . "m" : "[0m"
}

if A_IsCompiled
  Print(fg(50) . "--- PROGRAM STARTED ---" fg(), fg(50), A_Args, fg())
_globals := {}
; #Include <debuggerDetector>

/*
	Name: Misc.ahk
	Version 0.3 (03.08.23)
	Created: 26.08.22
	Author: Descolada (https://www.autohotkey.com/boards/viewtopic.php?f=83&t=107759)
    Credit: Coco

	Range(stop)						=> Returns an iterable to count from 1..stop
	Range(start, stop [, step])		=> Returns an iterable to count from start to stop with step
	Swap(&a, &b)					=> Swaps the values of a and b
	Print(value?, func?, newline?) 	=> Prints the formatted value of a variable (number, string, array, map, object)
	RegExMatchAll(haystack, needleRegEx [, startingPosition := 1])
	    Returns all RegExMatch results (RegExMatchInfo objects) for needleRegEx in haystack
		in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
	Highlight(x?, y?, w?, h?, showTime:=0, color:="Red", d:=2)
		Highlights an area with a colorful border.
	MouseTip(x?, y?, color1:="red", color2:="blue", d:=4)
		Flashes a colorful highlight at a point for 2 seconds.
	WindowFromPoint(X, Y) 			=> Returns the window ID at screen coordinates X and Y.
	ConvertWinPos(X, Y, &outX, &outY, relativeFrom:=A_CoordModeMouse, relativeTo:="screen", winTitle?, winText?, excludeTitle?, excludeText?)
		Converts coordinates between screen, window and client.
	WinGetInfo(WinTitle:="", Verbose := 1, WinText:="", ExcludeTitle:="", ExcludeText:="", Separator := "`n")
		Gets info about a window (title, process name, location etc).
	GetCaretPos(&X?, &Y?, &W?, &H?)
		Gets the position of the caret with CaretGetPos, Acc or UIA.
	IntersectRect(l1, t1, r1, b1, l2, t2, r2, b2)
		Checks whether two rectangles intersect and if they do, then returns an object containing the
		rectangle of the intersection: {l:left, t:top, r:right, b:bottom}

*/

/**
 * Returns a sequence of numbers, starting from 1 by default, 
 * and increments by step 1 (by default), 
 * and stops at a specified end number.
 * Can be converted to an array with the method ToArray()
 * @param start The number to start with, or if 'end' is omitted then the number to end with
 * @param end The number to end with
 * @param step Optional: a number specifying the incrementation. Default is 1.
 * @returns {Iterable}
 * @example 
 * for v in Range(5)
 *     Print(v) ; Outputs "1 2 3 4 5"
 */
class Range {
  __New(start, end?, step := 1) {
    if !step
      throw(TypeError("Invalid 'step' parameter"))
    if !IsSet(end)
      end := start, start := 1
    if (end < start) && (step > 0)
      step := -step
    this.start := start, this.end := end, this.step := step
  }
  __Enum(varCount) {
    start := this.start - this.step, end := this.end, step := this.step, counter := 0
    EnumElements(&element) {
      start := start + step
      if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
        return false
      element := start
      return true
    }
    EnumIndexAndElements(&index, &element) {
      start := start + step
      if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
        return false
      index := ++counter
      element := start
      return true
    }
    return (varCount = 1) ? EnumElements : EnumIndexAndElements
  }
  /**
   * Converts the iterable into an array.
   * @returns {Array}
   * @example
   * Range(3).ToArray() ; returns [1,2,3]
   */
  ToArray() {
    r := []
    for v in this
      r.Push(v)
    return r
  }
}

/**
 * Swaps the values of two variables
 * @param a First variable
 * @param b Second variable
 */
Swap(&a, &b) {
  temp := a
  a := b
  b := temp
}

logPrints := 0
/**
 * Prints the formatted value of a variable (number, string, object).
 */
Print(values*) {
  ; global A_DebuggerActive
  ; if !A_DebuggerActive
  ;   return MsgBox("unset")
  uniqueStringUsedForRegex := "uniqueStringUsedForRegex"
  static hEdit := 0, pfn, bkp
  if !hEdit {
    hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")
    user32 := DllCall("GetModuleHandle", "str", "user32.dll", "ptr")
    pfn := [
      '',
      ''
    ], bkp := [
      '',
      ''
    ]
    for i, fn in [
      "SetForegroundWindow",
      "ShowWindow"
    ] {
      pfn[i] := DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr")
      DllCall("VirtualProtect", "ptr", pfn[i], "ptr", 8, "uint", 0x40, "uint*", 0)
      bkp[i] := NumGet(pfn[i], 0, "int64")
    }
  }
  if (A_PtrSize = 8) { ; Disable SetForegroundWindow and ShowWindow.
    NumPut("int64", 0x0000C300000001B8, pfn[1], 0) ; return TRUE
    NumPut("int64", 0x0000C300000001B8, pfn[2], 0) ; return TRUE
  } else {
    NumPut("int64", 0x0004C200000001B8, pfn[1], 0) ; return TRUE
    NumPut("int64", 0x0008C200000001B8, pfn[2], 0) ; return TRUE
  }
  static cmds := {
    ListLines: 65406,
    ListVars: 65407,
    ListHotkeys: 65408,
    KeyHistory: 65409
  }
  DllCall("SendMessage", "ptr", A_ScriptHwnd, "uint", 0x111, "ptr", 65406, "ptr", 0)
  NumPut("int64", bkp[1], pfn[1], 0) ; Enable SetForegroundWindow.
  NumPut("int64", bkp[2], pfn[2], 0) ; Enable ShowWindow.
  text := WinGetTitle("ahk_id " hEdit)
  textToFind := "uniqueStringUsedForRegex := `"uniqueStringUsedForRegex`""
  idx := 0
  while text.includes(textToFind) {
    idx := text.IndexOf(textToFind) + textToFind.length
    text := text.substr(idx)
  }
  logdata(data) {
    if A_IsCompiled || logPrints {
      f.writeLine(path.join(A_ScriptDir, './logs/') '/' A_ScriptName '.ans', fg(25) "---------------------------------------------------`n" fg() data)
    }
    return data
  }
  if !idx {
    return OutputDebug(logdata(values.map(e => json.stringify(e)).join("`n").RegExReplace("`"(\[[34]8;5;\d+m|\[0m)`"\n?", '$1')))
  }
  templine := (WinGetTitle("ahk_id " hEdit)
  .SubString(1, idx))
  line := templine.RegExMatchAll("\r?\n0*(\d+?): ")
  line := line[line.Length - 1][1]
  fileat := templine.RegExMatchAll("\r?\n---- (.*)\r?\n") ; have to get better regex later
  try fileat := fileat[fileat.length - 1][1]
  catch
    fileat := fileat[1][1]
  ; MsgBox(JSON.stringify([[fileat*].map(e => [e*]), fileat.length]))
  out := []
  for val in values {
    if IsSet(val)
      out.push(IsObject(val) ? ToString(val) "`n" : val "`n")
  }
  fileat := fileat.RegexMatch("\\([^\\]+)\.ahk$")[1] ; only show file name and not full path
  lines := makeSameLength(' ', "--- " fileat " ---", "--- line " line ' ---')

  return OutputDebug(logdata(lines[1] '`n' lines[2] '`n' out.map((e, i) => i ": " e)
  .join("") "`n"))
}

; /**
;  * Prints the formatted value of a variable (number, string, object).
;  * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
;  * @param value Optional: the variable to print.
;  *     If omitted then new settings (output function and newline) will be set.
;  *     If value is an object/class that has a ToString() method, then the result of that will be printed.
;  * @param func Optional: the print function to use. Default is OutputDebug.
;  *     Not providing a function will cause the Print output to simply be returned as a string.
;  * @param newline Optional: the newline character to use (applied to the end of the value).
;  *     Default is newline (`n).
;  */
; Print(value?, func?, newline?) {
;   static p := OutputDebug, nl := "`n"
;   if IsSet(func)
;     p := func
;   if IsSet(newline)
;     nl := newline
;   if IsSet(value) {
;     val := IsObject(value) ? ToString(value) nl : value nl
;     return HasMethod(p) ? p(val) : val
;   }
;   return [p, nl]
; }

/**
 * Converts a value (number, array, object) to a string.
 * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
 * @param value Optional: the value to convert. 
 * @returns {String}
 */
ToString(val?) {
  if !IsSet(val)
    return "unset"
  valType := Type(val)
  switch valType, 0 {
    case "String":
      return "'" val "'"
    case "Integer", "Float":
      return val
    default:
      self := "", iter := "", out := ""
      try self := ToString(val.ToString()) ; if the object has ToString available, print it
      if valType != "Array" { ; enumerate object with key and value pair, except for array
        try {
          enum := val.__Enum(2)
          while (enum.Call(&val1, &val2))
            iter .= ToString(val1) ":" ToString(val2?) ", "
        }
      }
      if !IsSet(enum) { ; if enumerating with key and value failed, try again with only value
        try {
          enum := val.__Enum(1)
          while (enum.Call(&enumVal))
            iter .= ToString(enumVal?) ", "
        }
      }
      if !IsSet(enum) && (valType = "Object") && !self { ; if everything failed, enumerate Object props
        return JSON.stringify(val)
        ; for k, v in val.OwnProps()
        ;     iter .= SubStr(ToString(k), 2, -1) ":" ToString(v?) ", "
      }
      iter := SubStr(iter, 1, StrLen(iter) - 2)
      if !self && !iter && !((valType = "Array" && val.Length = 0) || (valType = "Map" && val.Count = 0) || (valType = "Object" && ObjOwnPropCount(val) = 0))
        return valType ; if no additional info is available, only print out the type
      else if self && iter
        out .= "value:" self ", iter:[" iter "]"
      else
        out .= self iter
      return (valType = "Object") ? "{" out "}" : (valType = "Array") ? "[" out "]" : valType "(" out ")"
  }
}

/**
 * Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
 * @param haystack The string whose content is searched.
 * @param needleRegEx The RegEx pattern to search for.
 * @param startingPosition If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
 * @returns {Array}
 */
RegExMatchAll(haystack, needleRegEx, startingPosition := 1) {
  out := [], end := StrLen(haystack) + 1
  while startingPosition < end && RegExMatch(haystack, needleRegEx, &outputVar, startingPosition)
    out.Push(outputVar), startingPosition := outputVar.Pos + (outputVar.Len || 1)
  return out
}

/**
 * Highlights an area with a colorful border. If called without arguments then all highlightings
 * are removed. This function also supports named parameters.
 * @param x Screen X-coordinate of the top left corner of the highlight
 * @param y Screen Y-coordinate of the top left corner of the highlight
 * @param w Width of the highlight
 * @param h Height of the highlight
 * @param showTime Can be one of the following:
 * * Unset - if highlighting exists then removes the highlighting, otherwise highlights for 2 seconds. This is the default value.
 * * 0 - Indefinite highlighting 
 * * Positive integer (eg 2000) - will highlight and pause for the specified amount of time in ms
 * * Negative integer - will highlight for the specified amount of time in ms, but script execution will continue
 * * "clear" - removes the highlighting unconditionally
 * @param color The color of the highlighting. Default is red.
 * @param d The border thickness of the highlighting in pixels. Default is 2.
 */
Highlight(x?, y?, w?, h?, showTime?, color := "Red", d := 2) {
  static guis := Map(), timers := Map()
  if IsSet(x) { ; if x is set then check whether a highlight already exists at those coords
    if IsObject(x) {
      d := x.HasOwnProp("d") ? x.d : d, color := x.HasOwnProp("color") ? x.color : color, showTime := x.HasOwnProp("showTime") ? x.showTime : showTime
      , h := x.HasOwnProp("h") ? x.h : h, w := x.HasOwnProp("w") ? x.w : h, y := x.HasOwnProp("y") ? x.y : y, x := x.HasOwnProp("x") ? x.x : unset
    }
    if !(IsSet(x) && IsSet(y) && IsSet(w) && IsSet(h))
      throw(ValueError("x, y, w and h arguments must all be provided for a highlight", -1))
    for k, v in guis {
      if k.x = x && k.y = y && k.w = w && k.h = h { ; highlight exists, so either remove it, or update
        if !IsSet(showTime) || (IsSet(showTime) && showTime = "clear")
          TryRemoveTimer(k), TryDeleteGui(k)
        else if showTime = 0
          TryRemoveTimer(k)
        else if IsInteger(showTime) {
          if showTime < 0 {
            if !timers.Has(k)
              timers[k] := Highlight.Bind(x, y, w, h)
            SetTimer(timers[k], showTime)
          } else {
            TryRemoveTimer(k)
            Sleep(showTime)
            TryDeleteGui(k)
          }
        } else
          throw(ValueError('Invalid showTime value "' (!IsSet(showTime) ? "unset" : IsObject(showTime) ? "{Object}" : showTime) '"', -1))
        return
      }
    }
  } else { ; if x is not set (eg Highlight()) then delete all highlights
    for k, v in timers
      SetTimer(v, 0)
    for k, v in guis
      v.Destroy()
    guis := Map(), timers := Map()
    return
  }

  if (showTime := showTime ?? 2000) = "clear"
    return
  else if !IsInteger(showTime)
    throw(ValueError('Invalid showTime value "' (!IsSet(showTime) ? "unset" : IsObject(showTime) ? "{Object}" : showTime) '"', -1))

  ; Otherwise this is a new highlight
  loc := {
    x: x,
    y: y,
    w: w,
    h: h
  }
  guis[loc] := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  GuiObj := guis[loc]
  GuiObj.BackColor := color
  iw := w + d, ih := h + d, w := w + d * 2, h := h + d * 2, x := x - d, y := y - d
  WinSetRegion("0-0 " w "-0 " w "-" h " 0-" h " 0-0 " d "-" d " " iw "-" d " " iw "-" ih " " d "-" ih " " d "-" d, GuiObj.Hwnd)
  GuiObj.Show("NA x" . x . " y" . y . " w" . w . " h" . h)

  if showTime > 0 {
    Sleep(showTime)
    TryDeleteGui(loc)
  } else if showTime < 0
    SetTimer(timers[loc] := Highlight.Bind(loc.x, loc.y, loc.w, loc.h), showTime)

  TryRemoveTimer(key) {
    if timers.Has(key)
      SetTimer(timers[key], 0), timers.Delete(key)
  }
  TryDeleteGui(key) {
    if guis.Has(key)
      guis[key].Destroy(), guis.Delete(key)
  }
}

/**
 * Flashes a colorful highlight at a point for 2 seconds.
 * @param x Screen X-coordinate for the highlight
 *     Omit x or y to highlight the current cursor position.
 * @param y Screen Y-coordinate for the highlight
 * @param color1 First color for the highlight. Default is red.
 * @param color2 Second color for the highlight. Default is blue.
 * @param d The border thickness of the highlighting in pixels. Default is 2.
 */
MouseTip(x?, y?, color1 := "red", color2 := "blue", d := 4) {
  if !(IsSet(x) && IsSet(y))
    MouseGetPos(&x, &y)
  loop 2 {
    Highlight(x - 10, y - 10, 20, 20, 500, color1, d)
    Highlight(x - 10, y - 10, 20, 20, 500, color2, d)
  }
  Highlight()
}

/**
 * Returns the window ID at screen coordinates X and Y. 
 * @param X Screen X-coordinate of the point
 * @param Y Screen Y-coordinate of the point
 */
WindowFromPoint(X, Y) { ; by SKAN and Linear Spoon
  return DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "Int64", Y << 32 | X), "UInt", 2)
}

/**
 * Converts coordinates between screen, window and client.
 * @param X X-coordinate to convert
 * @param Y Y-coordinate to convert
 * @param outX Variable where to store the converted X-coordinate
 * @param outY Variable where to store the converted Y-coordinate
 * @param relativeFrom CoordMode where to convert from. Default is A_CoordModeMouse.
 * @param relativeTo CoordMode where to convert to. Default is Screen.
 * @param winTitle A window title or other criteria identifying the target window. 
 * @param winText If present, this parameter must be a substring from a single text element of the target window.
 * @param excludeTitle Windows whose titles include this value will not be considered.
 * @param excludeText Windows whose text include this value will not be considered.
 */
ConvertWinPos(X, Y, &outX, &outY, relativeFrom := "", relativeTo := "screen", winTitle?, winText?, excludeTitle?, excludeText?) {
  relativeFrom := (relativeFrom == "") ? A_CoordModeMouse : relativeFrom
  if relativeFrom = relativeTo {
    outX := X, outY := Y
    return
  }
  hWnd := WinExist(winTitle?, winText?, excludeTitle?, excludeText?)

  switch relativeFrom, 0 {
    case "screen", "s":
      if relativeTo = "window" || relativeTo = "w" {
        DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
        outX := X - NumGet(RECT, 0, "Int"), outY := Y - NumGet(RECT, 4, "Int")
      } else {
        ; screen to client
        pt := Buffer(8), NumPut("int", X, pt), NumPut("int", Y, pt, 4)
        DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
        outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
      }
    case "window", "w":
      ; window to screen
      WinGetPos(&outX, &outY, , , hWnd)
      outX += X, outY += Y
      if relativeTo = "client" || relativeTo = "c" {
        ; screen to client
        pt := Buffer(8), NumPut("int", outX, pt), NumPut("int", outY, pt, 4)
        DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
        outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
      }
    case "client", "c":
      ; client to screen
      pt := Buffer(8), NumPut("int", X, pt), NumPut("int", Y, pt, 4)
      DllCall("ClientToScreen", "Int", hWnd, "Ptr", pt)
      outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
      if relativeTo = "window" || relativeTo = "w" { ; screen to window
        DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
        outX -= NumGet(RECT, 0, "Int"), outY -= NumGet(RECT, 4, "Int")
      }
  }
}

/**
 * Gets info about a window (title, process name, location etc)
 * @param WinTitle Same as AHK WinTitle
 * @param {number} Verbose How verbose the output should be (default is 1):
 *  0: Returns window title, hWnd, class, process name, PID, process path, screen position, min-max info, styles and ex-styles
 *  1: Additionally returns TransColor, transparency level, text (both hidden and not), statusbar text
 *  2: Additionally returns ClassNN names for all controls
 * @param WinText Same as AHK WinText
 * @param ExcludeTitle Same as AHK ExcludeTitle
 * @param ExcludeText Same as AHK ExcludeText
 * @param {string} Separator Linebreak character(s)
 * @returns {string} The info as a string. 
 * @example MsgBox(WinGetInfo("ahk_exe notepad.exe", 2))
 */
WinGetInfo(WinTitle := "", Verbose := 1, WinText := "", ExcludeTitle := "", ExcludeText := "", Separator := "`n") {
  if !(hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
    throw(TargetError("Target window not found!", -1))
  out := 'Title: '
  try out .= '"' WinGetTitle(hWnd) '"' Separator
  catch
    out .= "#ERROR" Separator
  out .= 'ahk_id ' hWnd Separator
  out .= 'ahk_class '
  try out .= WinGetClass(hWnd) Separator
  catch
    out .= "#ERROR" Separator
  out .= 'ahk_exe '
  try out .= WinGetProcessName(hWnd) Separator
  catch
    out .= "#ERROR" Separator
  out .= 'ahk_pid '
  try out .= WinGetPID(hWnd) Separator
  catch
    out .= "#ERROR" Separator
  out .= 'ProcessPath: '
  try out .= '"' WinGetProcessPath(hWnd) '"' Separator
  catch
    out .= "#ERROR" Separator
  out .= 'Screen position: '
  try {
    WinGetPos(&X, &Y, &W, &H, hWnd)
    out .= "x: " X " y: " Y " w: " W " h: " H Separator
  } catch
    out .= "#ERROR" Separator
  out .= 'MinMax: '
  try out .= ((minmax := WinGetMinMax(hWnd)) = 1 ? "maximized" : minmax = -1 ? "minimized" : "normal") Separator
  catch
    out .= "#ERROR" Separator

  static Styles := Map("WS_OVERLAPPED", 0x00000000, "WS_POPUP", 0x80000000, "WS_CHILD", 0x40000000, "WS_MINIMIZE", 0x20000000, "WS_VISIBLE", 0x10000000, "WS_DISABLED", 0x08000000, "WS_CLIPSIBLINGS", 0x04000000, "WS_CLIPCHILDREN", 0x02000000, "WS_MAXIMIZE", 0x01000000, "WS_CAPTION", 0x00C00000, "WS_BORDER", 0x00800000, "WS_DLGFRAME", 0x00400000, "WS_VSCROLL", 0x00200000, "WS_HSCROLL", 0x00100000, "WS_SYSMENU", 0x00080000, "WS_THICKFRAME", 0x00040000, "WS_GROUP", 0x00020000, "WS_TABSTOP", 0x00010000, "WS_MINIMIZEBOX", 0x00020000, "WS_MAXIMIZEBOX", 0x00010000, "WS_TILED", 0x00000000, "WS_ICONIC", 0x20000000, "WS_SIZEBOX", 0x00040000, "WS_OVERLAPPEDWINDOW", 0x00CF0000, "WS_POPUPWINDOW", 0x80880000, "WS_CHILDWINDOW", 0x40000000, "WS_TILEDWINDOW", 0x00CF0000, "WS_ACTIVECAPTION", 0x00000001, "WS_GT", 0x00030000)
  , ExStyles := Map("WS_EX_DLGMODALFRAME", 0x00000001, "WS_EX_NOPARENTNOTIFY", 0x00000004, "WS_EX_TOPMOST", 0x00000008, "WS_EX_ACCEPTFILES", 0x00000010, "WS_EX_TRANSPARENT", 0x00000020, "WS_EX_MDICHILD", 0x00000040, "WS_EX_TOOLWINDOW", 0x00000080, "WS_EX_WINDOWEDGE", 0x00000100, "WS_EX_CLIENTEDGE", 0x00000200, "WS_EX_CONTEXTHELP", 0x00000400, "WS_EX_RIGHT", 0x00001000, "WS_EX_LEFT", 0x00000000, "WS_EX_RTLREADING", 0x00002000, "WS_EX_LTRREADING", 0x00000000, "WS_EX_LEFTSCROLLBAR", 0x00004000, "WS_EX_CONTROLPARENT", 0x00010000, "WS_EX_STATICEDGE", 0x00020000, "WS_EX_APPWINDOW", 0x00040000, "WS_EX_OVERLAPPEDWINDOW", 0x00000300, "WS_EX_PALETTEWINDOW", 0x00000188, "WS_EX_LAYERED", 0x00080000, "WS_EX_NOINHERITLAYOUT", 0x00100000, "WS_EX_NOREDIRECTIONBITMAP", 0x00200000, "WS_EX_LAYOUTRTL", 0x00400000, "WS_EX_COMPOSITED", 0x02000000, "WS_EX_NOACTIVATE", 0x08000000)
  out .= 'Style: '
  try {
    out .= (style := WinGetStyle(hWnd)) " ("
    for k, v in Styles {
      if v && style & v {
        out .= k " | "
        style &= ~v
      }
    }
    out := RTrim(out, " |")
    if style
      out .= (SubStr(out, -1, 1) = "(" ? "" : ", ") "Unknown enum: " style
    out .= ")" Separator
  } catch
    out .= "#ERROR" Separator

  out .= 'ExStyle: '
  try {
    out .= (style := WinGetExStyle(hWnd)) " ("
    for k, v in ExStyles {
      if v && style & v {
        out .= k " | "
        style &= ~v
      }
    }
    out := RTrim(out, " |")
    if style
      out .= (SubStr(out, -1, 1) = "(" ? "" : ", ") "Unknown enum: " style
    out .= ")" Separator
  } catch
    out .= "#ERROR" Separator

  if Verbose {
    out .= 'TransColor: '
    try out .= WinGetTransColor(hWnd) Separator
    catch
      out .= "#ERROR" Separator
    out .= 'Transparent: '
    try out .= WinGetTransparent(hWnd) Separator
    catch
      out .= "#ERROR" Separator

    PrevDHW := DetectHiddenText(0)
    out .= 'Text (DetectHiddenText Off): '
    try out .= '"' WinGetText(hWnd) '"' Separator
    catch
      out .= "#ERROR" Separator
    DetectHiddenText(1)
    out .= 'Text (DetectHiddenText On): '
    try out .= '"' WinGetText(hWnd) '"' Separator
    catch
      out .= "#ERROR" Separator
    DetectHiddenText(PrevDHW)

    out .= 'StatusBar Text: '
    try out .= '"' StatusBarGetText(1, hWnd) '"' Separator
    catch
      out .= "#ERROR" Separator
  }
  if Verbose > 1 {
    out .= 'Controls (ClassNN): ' Separator
    try {
      for ctrl in WinGetControls(hWnd)
        out .= '`t' ctrl Separator
    } catch
      out .= "#ERROR" Separator
  }
  return SubStr(out, 1, -StrLen(Separator))
}

/**
 * Gets the position of the caret with UIA, Acc or CaretGetPos.
 * Credit: plankoe (https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/)
 * @param X Value is set to the screen X-coordinate of the caret
 * @param Y Value is set to the screen Y-coordinate of the caret
 * @param W Value is set to the width of the caret
 * @param H Value is set to the height of the caret
 */
GetCaretPos(&X?, &Y?, &W?, &H?) {
  /*
  	This implementation prefers CaretGetPos > Acc > UIA. This is mostly due to speed differences
  	between the methods and statistically it seems more likely that the UIA method is required the
  	least (Chromium apps support Acc as well).
  */

  ; Default caret
  savedCaret := A_CoordModeCaret
  CoordMode("Caret", "Screen")
  CaretGetPos(&X, &Y)
  CoordMode("Caret", savedCaret)
  if IsInteger(X) && (X | Y) != 0 {
    W := 4, H := 20
    return
  }

  ; Acc caret
  static _ := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
  try {
    idObject := 0xFFFFFFF8 ; OBJID_CARET
    if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", idObject &= 0xFFFFFFFF
    , "ptr", -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
    , "ptr*", oAcc := ComValue(9, 0)) = 0 {
      x := Buffer(4), y := Buffer(4), w := Buffer(4), h := Buffer(4)
      oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
      X := NumGet(x, 0, "int"), Y := NumGet(y, 0, "int"), W := NumGet(w, 0, "int"), H := NumGet(h, 0, "int")
      if (X | Y) != 0
        return
    }
  }

  ; UIA caret
  static IUIA := ComObject("{e22ad333-b25f-460c-83d0-0581107395c9}", "{34723aff-0c9d-49d0-9896-7ab52df8cd8a}")
  try {
    ComCall(8, IUIA, "ptr*", &FocusedEl := 0) ; GetFocusedElement
    /*
    	The current implementation uses only TextPattern GetSelections and not TextPattern2 GetCaretRange.
    	This is because TextPattern2 is less often supported, or sometimes reports being implemented
    	but in reality is not. The only downside to using GetSelections is that when text
    	is selected then caret position is ambiguous. Nevertheless, in those cases it most
    	likely doesn't matter much whether the caret is in the beginning or end of the selection.
    
    	If GetCaretRange is needed then the following code implements that:
    	ComCall(16, FocusedEl, "int", 10024, "ptr*", &patternObject:=0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPattern2 = 10024
    	if patternObject {
    		ComCall(10, patternObject, "int*", &IsActive:=1, "ptr*", &caretRange:=0), ObjRelease(patternObject) ; GetCaretRange
    		ComCall(10, caretRange, "ptr*", &boundingRects:=0), ObjRelease(caretRange) ; GetBoundingRectangles
    		if (Rect := ComValue(0x2005, boundingRects)).MaxIndex() = 3 { ; VT_ARRAY | VT_R8
    			X:=Round(Rect[0]), Y:=Round(Rect[1]), W:=Round(Rect[2]), H:=Round(Rect[3])
    			return
    		}
    	}
    */
    ComCall(16, FocusedEl, "int", 10014, "ptr*", &patternObject := 0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPattern = 10014
    if patternObject {
      ComCall(5, patternObject, "ptr*", &selectionRanges := 0), ObjRelease(patternObject) ; GetSelections
      ComCall(4, selectionRanges, "int", 0, "ptr*", &selectionRange := 0) ; GetElement
      ComCall(10, selectionRange, "ptr*", &boundingRects := 0), ObjRelease(selectionRange), ObjRelease(selectionRanges) ; GetBoundingRectangles
      if (Rect := ComValue(0x2005, boundingRects))
      .MaxIndex() = 3 { ; VT_ARRAY | VT_R8
        X := Round(Rect[0]), Y := Round(Rect[1]), W := Round(Rect[2]), H := Round(Rect[3])
        return
      }
    }
  }
}

/**
 * Checks whether two rectangles intersect and if they do, then returns an object containing the
 * rectangle of the intersection: {l:left, t:top, r:right, b:bottom}
 * Note 1: Overlapping area must be at least 1 unit. 
 * Note 2: Second rectangle starting at the edge of the first doesn't count as intersecting:
 *     {l:100, t:100, r:200, b:200} does not intersect {l:200, t:100, 400, 400}
 * @param l1 x-coordinate of the upper-left corner of the first rectangle
 * @param t1 y-coordinate of the upper-left corner of the first rectangle
 * @param r1 x-coordinate of the lower-right corner of the first rectangle
 * @param b1 y-coordinate of the lower-right corner of the first rectangle
 * @param l2 x-coordinate of the upper-left corner of the second rectangle
 * @param t2 y-coordinate of the upper-left corner of the second rectangle
 * @param r2 x-coordinate of the lower-right corner of the second rectangle
 * @param b2 y-coordinate of the lower-right corner of the second rectangle
 * @returns {Object}
 */
IntersectRect(l1, t1, r1, b1, l2, t2, r2, b2) {
  rect1 := Buffer(16), rect2 := Buffer(16), rectOut := Buffer(16)
  NumPut("int", l1, "int", t1, "int", r1, "int", b1, rect1)
  NumPut("int", l2, "int", t2, "int", r2, "int", b2, rect2)
  if DllCall("user32\IntersectRect", "Ptr", rectOut, "Ptr", rect1, "Ptr", rect2)
    return {
      l: NumGet(rectOut, 0, "Int"),
      t: NumGet(rectOut, 4, "Int"),
      r: NumGet(rectOut, 8, "Int"),
      b: NumGet(rectOut, 12, "Int")
    }
}

/**
 * calls a function with different arg counts until the call is sucessful
 * @param {Function} func func to call
 * @param {Any} args args to call the function with
 */
callFuncWithOptionalArgs(func, args*) {
  loop args.Length + 1
    try return func(args.sub(1, args.Length - A_Index + 1)*)
  garb := []
  loop 30 - args.Length {
    garb.push("")
    try return func([
      args,
      garb
    ].Flat()*)
  }

}

; /**
;  *
;  * @param {String} cmd cmd to run
;  * @param {String} dir working dir for the cmd
;  * @param {String} opts run opts
;  * @param {VarRef} err holds the usual output of the run call to check for errors
;  * @returns {String} the cmd return data
;  */
; RunRet(cmd, dir := A_ScriptDir, opts := "", &err := &err, timeout := 0, &pid := &pid) {
;   fileloc := A_ScriptDir "\jsutusedforcmdoutput " Random() ".txt"
;   f.write(fileloc, "")
;   Run("cmd.exe /c " cmd "> `"" fileloc "`"", dir, opts, &pid)
;   tempfunc := (pid, &out, *) {
;     if WinExist("ahk_pid " pid) {
;       WinKill("ahk_pid " pid)
;       if f.read(fileloc) != "" {
;         temp := FileRead(fileloc)
;         FileDelete(fileloc)
;         return out := temp
;       }
;       return out := 0
;     }
;   }.bind(pid, &out)
;   if timeout
;     SetTimer(tempfunc, -timeout)
;   while !IsSet(out) {
;     try if f.read(fileloc) != "" {
;       break
;     }
;     Sleep(10)
;   }
;   if f.read(fileloc) != "" {
;     ; err := RunWait("cmd.exe /c " cmd "> `"" A_ScriptDir "\My Temp File.txt`"", dir, opts)
;     temp := FileRead(fileloc)
;     try FileDelete(fileloc)
;     SetTimer((fileloc){
;       try FileDelete(fileloc)
;     }.bind(fileloc), -1000)
;     return temp
;   }
;   return out
; }
; RunRet(cmd, dir := A_ScriptDir, opts := "", &err := &err, timeout := 2000) {
;   fileloc:=A_ScriptDir "\My Temp File.txt"
;   f.write(fileloc, "")
;   SetTimer((*){

;   }, -timeout)
;   err := RunWait("cmd.exe /c " cmd "> `"" A_ScriptDir "\My Temp File.txt`"", dir, opts)
;   ; err := RunWait("cmd.exe /c " cmd "> `"" A_ScriptDir "\My Temp File.txt`"", dir, opts)
;   temp := FileRead(fileloc)
;   FileDelete(fileloc)
;   return temp
; }

/**
 * copy the file only if the file needs to be copied
 * @param {String} from file to copy
 * @param {String} to place to copy to
 */
fastCopyFile(from, to) {
  if !FileExist(from) {
    FileDelete(to)
    return
  }
  ; if FileExist(to)
  ;   if FileGetSize(from) == FileGetSize(to)
  ;     return
  if DirExist(path.info(to).parentdir) != "d" {
    try FileDelete(path.info(to).parentdir)
    DirCreate(path.info(to).parentdir)
  }
  FileCopy(from, to, 1)
}

_globals.fastDirCopyCurrentFileProgress := 0
/**
 * copy an entire dir but only the files that need to be updated
 * @param {String} from file to copy
 * @param {String} to place to copy to
 */
fastDirCopy(from, to, maxfiles := 0, &progress := &progress, ui?, &text := &text, &text2 := &text2) {
  if !maxfiles {
    from := path.info(from).abspath
    to := path.info(to).abspath
    _globals.fastDirCopyCurrentFileProgress := 0
    ui := betterui({
      aot: 1,
      w: A_ScreenWidth,
      h: 30,
      clickthrough: 1,
      transparency: 200
    })
    ui.add("text", {
      o: "center",
      t: path.info(from).relpath
    }, &text2)
    .newLine()
    ui.add("text", {
      o: "center"
    }, &text)
    .newLine()
    ui.add("progress", {}, &progress)
    ui.show("xcenter y30 NoActivate")
    loop files from '\*', 'fr' {
      maxfiles++
    }
  }
  loop files from '\*', "f" {
    _globals.fastDirCopyCurrentFileProgress++
    progress.value := _globals.fastDirCopyCurrentFileProgress / maxfiles * 100
    text.text := _globals.fastDirCopyCurrentFileProgress " / " maxfiles
    text2.text := path.info(from).relpath
    if _globals.fastDirCopyCurrentFileProgress = maxfiles
      ui.hide()
    fastCopyFile(path.join(A_LoopFileFullPath), path.join(A_LoopFileFullPath).replace(from, to))
  }
  loop files from '\*', "d" {
    DirCreate(path.join(A_LoopFileFullPath).replace(from, to))
    fastDirCopy(path.join(A_LoopFileFullPath), path.join(A_LoopFileFullPath).replace(from, to), maxfiles, &progress, ui, &text, &text2)
  }
}

/**
 * makes line1 and line2 the same length
 * @param {VarRef: string} line1 
 * @param {VarRef: string} line2 
 * @param {String} charToUse the char to fill with if the lengths are different
 */
makeSameLength(charToUse := " ", lines*) {
  maxLen := 0
  loop lines.Length {
    line := lines[A_Index]
    if line.length > maxLen
      maxLen := line.length
  }

  for k, line in obj := lines {
    loop ((maxLen - line.length) / 2) {
      line := charToUse . line . charToUse
    }
    if line.length != maxLen
      line .= charToUse

    lines[k] := line
  }
  return lines
}

/**
 * joins all objects into one
 * @param objs* - all objects to join
 */
joinObjs(objs*) {
  tempobj := objs[1]
  objs := objs.sub(2, -1)
  for temp in objs {
    for key, val in temp.OwnProps()
      tempobj.%key% := val
  }
  return tempobj
}

/**
 * moves the pointer relative to the screen instead of active window
 * @param x - x pos
 * @param y - y pos
 */
globalMouseMove(x, y) {
  DllCall("SetCursorPos", "int", x, "int", y)
}

rerange(val, low1, high1, low2, high2) {
  return ((val - low1) / (high1 - low1)) * (high2 - low2) + low2
}

MouseMoveDll(x, y, rel := 0) {
  if rel
    DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y)
  ; DllCall("mouse_event", "uint", 0x8000, "uint", rerange(x, 0, A_ScreenWidth, 0, 65535), "uint", rerange(y, 0, A_ScreenHeight, 0, 65535))
  else
    DllCall("mouse_event", "uint", 0x0001 | 0x8000, "uint", rerange(x, 0, A_ScreenWidth, 0, 65535), "uint", rerange(y, 0, A_ScreenHeight, 0, 65535))
}

; MouseClick([WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative]) => void
; MouseClickDll(){
;   DllCall("mouse_event", "uint", 0x0001 | 0x8000, "uint", rerange(x, 0, A_ScreenWidth, 0, 65535), "uint", rerange(y, 0, A_ScreenHeight, 0, 65535))
; }

SendDll(keys, Delay := A_KeyDelay, PressDuration := A_KeyDuration) {
  ; cant seem to send {up} or {del}
  if PressDuration = -1
    PressDuration := 20
  modifiers := []
  ;
  keys := String(keys)
  .RegExReplace("([+^#!]+)([^{]|\{.*?\})", (reg) {
    reps := []
    for rep in reg[1].split("") {
      rep := rep
        .Replace("^", "ctrl")
        .Replace("+", "shift")
        .Replace("!", "alt")
        .Replace("#", "lwin")
      reps.push(rep)
    }
    str := ''
    for rep in reps {
      str .= "{" rep " down}"
    }
    str .= reg[2]
    for rep in reps {
      str .= "{" rep " up}"
    }
    return str
  })
  .RegExMatchAll("[^{]|\{.*?\}").map(e => e[0])
  Print("keys", keys)
  for key in keys {
    down(key) {
      VK := Format("0x{:02X}", GetKeyVK(key))
      SC := Format("0x{:03X}", GetKeySC(key))
      DllCall("keybd_event", "UChar", VK, "UChar", SC, "Uint", 0, "UPtr", 0)
    }
    up(key) {
      VK := Format("0x{:02X}", GetKeyVK(key))
      SC := Format("0x{:03X}", GetKeySC(key))
      DllCall("keybd_event", "UChar", VK, "UChar", SC, "Uint", 2, "UPtr", 0)
    }
    if key.Length == 1 {
      switch key, 0 {
        case "^":
        default:

      }
      if key == "^" {
        modifiers.push("^")
      }
      down(key[1])
      sleep(PressDuration)
      up(key[1])
    } else if key.startsWith("{") {
      key := key.trim("{}").split(" ")
      if key.Length == 1 {
        down(key[1])
        sleep(PressDuration)
        up(key[1])
      } else if (key[2].RegExMatch("^\d+$")) {
        loop key[2] - 1 {
          down(key[1])
          sleep(PressDuration)
          up(key[1])
          sleep(delay)
        }
        down(key[1])
        sleep(PressDuration)
        up(key[1])
      } else if key[2] = "down" {
        down(key[1])
      } else if key[2] = "up" {
        up(key[1])
      }
    } else {
      print("SendDll ERROR", key)
    }
    sleep(delay)
  }
}
SendDllRaw(keys, Delay := A_KeyDelay, PressDuration := A_KeyDuration) {
  ; cant seem to send {up} or {del}
  if PressDuration = -1
    PressDuration := 20
  modifiers := []
  ;
  ; Print("keys", keys)
  for key in keys {
    down(key) {
      VK := Format("0x{:02X}", GetKeyVK(key))
      SC := Format("0x{:03X}", GetKeySC(key))
      DllCall("keybd_event", "UChar", VK, "UChar", SC, "Uint", 0, "UPtr", 0)
    }
    up(key) {
      VK := Format("0x{:02X}", GetKeyVK(key))
      SC := Format("0x{:03X}", GetKeySC(key))
      DllCall("keybd_event", "UChar", VK, "UChar", SC, "Uint", 2, "UPtr", 0)
    }
    if key.Length == 1 {
      down(key[1])
      if PressDuration
        sleep(PressDuration)
      up(key[1])
    } else {
      print("SendDll ERROR", key)
    }
    sleep(delay)
  }
}

class cache {
  cache := {}
  __New() {
  }
  has(thing) {
    this.lastdata := thing
    return this.cache.HasProp(thing) ? true : false ;
  }
  get() {
    item := this.cache.%this.lastdata%
    this.DeleteProp("lastdata")
    return IsSet(item) ? item : unset
  }
  set(val) {
    this.cache.%this.lastdata% := val
    this.DeleteProp("lastdata")
    return val
  }
}

class path {
  static joincache := cache()
  static infocache := cache()
  static join(paths*) {
    if path.joincache.has(JSON.stringify(paths)) {
      return path.joincache.get()
    }
    str := ''
    for p in paths {
      if p.startswith('/') or p.startswith('\') {
        p := 'c:' p
      }
      p := p.Replace("\", "/")
      str .= (str ? '/' : '') p
      .RegExReplace("/$", '')
      .RegExReplace("^/", '')
      .replace("/./", "/")
    }
    str := str.RegExReplace("/$", '')
    str := str.replace("/./", "/")
    while str.includes('/../') {
      str := str.RegExReplace("\/[^\/]+(?<!/\.\.)/\.\./", "/")
    }
    return path.joincache.set(str)
  }

  static exists(paths*) {
    return path.info(paths*).exists
  }
  static isdir(paths*) {
    return path.info(paths*).isdir
  }
  static isfile(paths*) {
    return path.info(paths*).isfile
  }
  static abspath(paths*) {
    return path.info(paths*).abspath
  }
  static relpath(paths*) {
    return path.info(paths*).relpath
  }
  static isAbs(paths*) {
    return path.info(paths*).isAbs
  }
  static isRel(paths*) {
    return path.info(paths*).isRel
  }
  static nameandext(paths*) {
    return path.info(paths*).nameandext
  }
  static ext(paths*) {
    return path.info(paths*).ext
  }
  static name(paths*) {
    return path.info(paths*).name
  }
  static parentdirname(paths*) {
    return path.info(paths*).parentdirname
  }
  static parentdir(paths*) {
    return path.info(paths*).parentdir
  }
  static info(paths*) {
    p := path.join(paths*)
    if path.infocache.has(p) {
      return path.infocache.get()
    }
    o := {
      exists: DirExist(p) || FileExist(p),
      isdir: DirExist(p),
      isfile: FileExist(p)
    }
    ;
    abspath := ''
    relpath := ''
    if p.RegExMatch("^[a-zA-Z]:")[0] {
      abspath := p
      relpath := '.' p[A_WorkingDir.length + 1, -1]
      o.isAbs := 1
      o.isRel := 0
      ; temppathWD := A_WorkingDir.Replace("\", "/").split("/")
      ; temppathREQ := p.Replace("\", "/").split("/")

    } else {
      o.isRel := 1
      o.isAbs := 0
      relpath := p
      abspath := path.join(A_WorkingDir, p)
    }
    o.absPath := abspath
    o.relPath := relpath
    ;
    p := abspath.split("/")
    o.nameandext := p[-1]
    o.ext := p[-1][2, -1].includes(".") ? p[-1].split(".")[-1] : ""
    o.name := o.nameandext.RegExReplace('\.' o.ext "$", "")
    o.parentdirname := p.length > 1 ? p[-2] : ""
    o.parentdir := p.sub(1, -2).join("/")
    return path.infocache.set(o)
  }
  static format(p) {
    return path.join(p)
  }
}

input(text?, ifUnset?, title?, options?, default?) {
  SetTimer(() {
    try WinSetAlwaysOnTop(1, 'a')
  }, -50)
  temp := InputBox(text?, title?, options?, default?)
  if temp.Result = "OK"
    return temp.Value
  return isset(ifUnset) ? ifUnset : unset
}

WinHasClass(win, class) {
  return WinGetList("ahk_class " class.RegExReplace("^ahk_class ", '')).includes(win)
}

; file
class F {
  static lastfile := ''
  /**
   * 
   * @param {string} path name of file to read from
   * @param {String} default text to return if file not found 
   * @returns {Buffer | String} 
   */
  static read(path, default := "", opts := "") {
    this.lastfile := path
    if !FileExist(path) {
      this.write(path, default)
    }
    return FileRead(path, opts)
  }

  /**
   * 
   * @param path name of the file to write to - blank for last read file
   * @param text text to write to the file
   */
  static write(p := this.lastfile, text := '') {
    this.lastfile := p
    p := path.info(p).abspath.RegExReplace('^\\', '').replace("/", "\")
    if p.includes("\")
      DirCreate(p.RegExReplace('\\[^\\]+$', ''))
    ; Print(path)
    try {
      f := FileOpen(p, "w")
      f.write(text)
      f.close()
    } catch Error as e {
      throw(Error(e.Message ' --- ' (p or "path is not set")))
    }
  }

  /**
   * 
   * @param path name of the file to write to
   * @param text text to write to the file
   */
  static writeLineToTop(path, text) {
    temp := this.read(path)
    if temp
      text := text '`n' temp
    this.write(path, text)
  }

  /**
   * 
   * @param path name of the file to write to
   * @param text text to write to the file
   */
  static writeLine(path, text) {
    temp := this.read(path)
    if temp
      text := temp '`n' text
    this.write(path, text)
  }
}

/************************************************************************
 * 增加了对true/false/null类型的支持, 保留了数值的类型
 * @description: JSON格式字符串序列化和反序列化, 修改自[HotKeyIt/Yaml](https://github.com/HotKeyIt/Yaml)
 * @author thqby, HotKeyIt
 * @date 2023/05/12
 * @version 1.0.5
 ***********************************************************************/

class JSON {
  static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)
  ; static null := "null", true := "true", false := "false"

  /**
   * Converts a AutoHotkey Object Notation JSON string into an object.
   * @param text A valid JSON string.
   * @param keepbooltype convert true/false/null to JSON.true / JSON.false / JSON.null where it's true, otherwise 1 / 0 / ''
   * @param as_map object literals are converted to map, otherwise to object
   */
  static parse(text, keepbooltype := false, as_map := true) {
    keepbooltype ? (_true := JSON.true, _false := JSON.false, _null := JSON.null) : (_true := true, _false := false, _null := "")
    as_map ? (map_set := (maptype := Map)
    .Prototype.Set) : (map_set := (obj, key, val) => obj.%key% := val, maptype := Object)
    NQ := "", LF := "", LP := 0, P := "", R := ""
    D := [
      C := (A := InStr(text := LTrim(text, " `t`r`n"), "[") = 1) ? [] : maptype()
    ], text := LTrim(SubStr(text, 2), " `t`r`n"), L := 1, N := 0, V := K := "", J := C, !(Q := InStr(text, '"') != 1) ? text := LTrim(text, '"') : ""
    loop parse text, '"' {
      Q := NQ ? 1 : !Q
      NQ := Q && (SubStr(A_LoopField, -3) = "\\\" || (SubStr(A_LoopField, -1) = "\" && SubStr(A_LoopField, -2) != "\\"))
      if !Q {
        if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
          continue
        else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || RegExMatch(t, "^-?\d*(\.\d*)?\s*[,\]\}]")) {
          loop parse t {
            if N && N--
              continue
            if InStr("`n`r `t", A_LoopField)
              continue
            else if InStr("{[", A_LoopField) {
              if !A && !V
                throw(Error("Malformed JSON - missing key.", 0, t))
              C := A_LoopField = "[" ? [] : maptype(), A ? D[L].Push(C) : map_set(D[L], K, C), D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
              continue
            } else if InStr("]}", A_LoopField) {
              if !A && V
                throw(Error("Malformed JSON - missing value.", 0, t))
              else if L = 0
                throw(Error("Malformed JSON - to many closing brackets.", 0, t))
              else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
            } else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
              if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+\.?\d*)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
                if A
                  C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
                else if V
                  map_set(C, K, R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R), K := V := ""
                else throw(Error("Malformed JSON - missing key.", 0, t))
              } else {
                ; Added support for comments without '"'
                if A_LoopField == '/' {
                  nt := SubStr(t, A_Index + 1, 1), N := 0
                  if nt == '/' {
                    if nt := InStr(t, '`n', , A_Index + 2)
                      N := nt - A_Index - 1
                  } else if nt == '*' {
                    if nt := InStr(t, '*/', , A_Index + 2)
                      N := nt + 1 - A_Index
                  } else nt := 0
                  if N
                    continue
                }
                throw(Error("Malformed JSON - unrecognized character-", 0, A_LoopField " in " t))
              }
            }
          }
        } else if InStr(t, ':') > 1
          throw(Error("Malformed JSON - unrecognized character-", 0, SubStr(t, 1, 1) " in " t))
      } else if NQ && (P .= A_LoopField '"', 1)
        continue
      else if A
        LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
      else if V
        LF := P A_LoopField, map_set(C, K, InStr(LF, "\") ? UC(LF) : LF), K := V := P := ""
      else
        LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
    }
    return J
    UC(S, e := 1) {
      static m := Map(Ord('"'), '"', Ord("a"), "`a", Ord("b"), "`b", Ord("t"), "`t", Ord("n"), "`n", Ord("v"), "`v", Ord("f"), "`f", Ord("r"), "`r")
      local v := ""
      ; Loop Parse S, "\"
      ;   If !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
      ;     v .= (t := InStr("ux", SubStr(A_LoopField, 1, 1)) ? SubStr(A_LoopField, 1, RegExMatch(A_LoopField, "i)^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K") - 1) : "") && RegexMatch(t, "i)^[ux][\da-f]+$") ? Chr(Abs("0x" SubStr(t, 2))) SubStr(A_LoopField, RegExMatch(A_LoopField, "i)^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")) : m.has(Ord(A_LoopField)) ? m[Ord(A_LoopField)] SubStr(A_LoopField, 2) : "\" A_LoopField, e := A_LoopField = "" ? e : !e
      loop parse S, "\"
        if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
          v .= (t := m.Get(SubStr(A_LoopField, 1, 1), 0)) ? t SubStr(A_LoopField, 2) :
            (t := RegExMatch(A_LoopField, "i)^(u[\da-f]{4}|x[\da-f]{2})\K")) ?
              Chr("0x" SubStr(A_LoopField, 2, t - 2)) SubStr(A_LoopField, t) : "\" A_LoopField,
          e := A_LoopField = "" ? e : !e
      ;
      return v
    }
  }

  /**
   * Converts a AutoHotkey Array/Map/Object to a Object Notation JSON string.
   * @param obj A AutoHotkey value, usually an object or array or map, to be converted.
   * @param expandlevel The level of JSON string need to expand, by default expand all.
   * @param space Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
   */
  static stringify(obj, expandlevel := unset, space := "  ") {
    if type(obj) = "string"
      return "`"" obj "`""
    expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
    return Trim(CO(obj, expandlevel))
    CO(O, J := 0, R := 0, Q := 0) {
      static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ": "
      if (OT := Type(O)) = "Array" {
        D := !R ? S1 : ""
        for key, value in O {
          F := (VT := IsSet(value) ? Type(value) : "unset") = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
          if !IsSet(value)
            value := {}
          Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
          D .= (J > R ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
        }
      } else {
        D := !R ? M1 : ""
        for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
          F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
          Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
          D .= (J > R ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
          if J = 0 && !R
            D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
        }
      }
      if J > R
        D .= "`n" CL(R + 1)
      if R = 0
        D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
      return D
    }
    ES(S) {
      switch Type(S) {
        case "Float":
          if (v := '', d := InStr(S, 'e'))
            v := SubStr(S, d), S := SubStr(S, 1, d - 1)
          if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
            S := Round(S, Max(1, d - InStr(S, ".") - 1))
          return S v
        case "Integer":
          return S
        case "String":
          S := StrReplace(S, "\", "\\")
          S := StrReplace(S, "`t", "\t")
          S := StrReplace(S, "`r", "\r")
          S := StrReplace(S, "`n", "\n")
          S := StrReplace(S, "`b", "\b")
          S := StrReplace(S, "`f", "\f")
          S := StrReplace(S, "`v", "\v")
          S := StrReplace(S, '"', '\"')
          return '"' S '"'
        default:
          return S == JSON.true ? "true" : S == JSON.false ? "false" : "Type." Type(s)
      }
    }
    CL(i) {
      loop (s := "", space ? i - 1 : 0)
        s .= space
      return s
    }
  }

  static minify(obj, expandlevel := unset, space := "  ") {
    expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
    return Trim(CO(obj, expandlevel))
    CO(O, J := 0, R := 0, Q := 0) {
      static M1 := "{", M2 := "}", S1 := "[", S2 := "]", C := ",", S := "- ", E := "", K := ":"
      if (OT := Type(O)) = "Array" {
        D := !R ? S1 : ""
        for key, value in O {
          F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
          Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
          D .= (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
        }
      } else {
        D := !R ? M1 : ""
        for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
          F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
          Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
          D .= (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
          if J = 0 && !R
            D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
        }
      }
      if R = 0
        D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
      return D
    }
    ES(S) {
      switch Type(S) {
        case "Float":
          if (v := '', d := InStr(S, 'e'))
            v := SubStr(S, d), S := SubStr(S, 1, d - 1)
          if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
            S := Round(S, Max(1, d - InStr(S, ".") - 1))
          return S v
        case "Integer":
          return S
        case "String":
          S := StrReplace(S, "\", "\\")
          S := StrReplace(S, "`t", "\t")
          S := StrReplace(S, "`r", "\r")
          S := StrReplace(S, "", "\n")
          S := StrReplace(S, "`b", "\b")
          S := StrReplace(S, "`f", "\f")
          S := StrReplace(S, "`v", "\v")
          S := StrReplace(S, '"', '\"')
          return '"' S '"'
        default:
          return S == JSON.true ? "true" : S == JSON.false ? "false" : "null"
      }
    }
  }
}

;
;################################################################################################
;        Takes a screenshot, names it and puts it in folder called "ScreenShots"
; This script is an edit of a previous screenshot script by Cruncher1, based almost
; entirely on the Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; I have updated it to AHKv2 by modifying it to use an edit of the GDI+ library
; updated for v2 by buliasz 21/11/2023, and extended it with functions to screenshot
; only one window, with various areas and rendering options available by Buzzerb
;
;
;          Gdip code available from: https://github.com/buliasz/AHKv2-Gdip
;   Gdip tutorial: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
;################################################################################################
;################################################################################################

; ; Whole Screen Capture:
;   screenshot.CaptureWholeScreen()

; ; Active Window Capture
;   screenshot.CaptureActiveWindow()

; ; Active Window Client Only Capture
;   screenshot.CaptureActiveWindow(true)

; ; Active Window Rendered Capture
;   screenshot.CaptureRenderedActiveWindow()

; ; Active Window Rendered Client Only Capture
;   screenshot.CaptureRenderedActiveWindow(true)

;#####################################################################################
; Screenshot Functions:
;#####################################################################################
; OnExit(shutdown(A_ExitReason, ExitCode) {
;   screenshot.__Gdip_Shutdown(screenshot.pToken)
;   return 1
; },)
; class screenshot {
;   static pToken := screenshot.__Gdip_Startup()
;   static CaptureWholeScreen(filepath := A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png") {
;     pBitmap := screenshot.__Gdip_BitmapFromScreen()
;     ;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
;     screenshot.__Gdip_SaveBitmapToFile(pBitmap, filepath)
;     screenshot.__Gdip_DisposeImage(pBitmap)
;     return
;   }

;   static CaptureActiveWindow(clientOnly := false, filepath := A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png") {
;     activeHWND := WinExist("A")
;     if clientOnly {
;       pBitmap := screenshot.__Gdip_ClientAreaBitmapFromHWND(activeHWND)
;     } else {
;       pBitmap := screenshot.__Gdip_BitmapFromHWND(activeHWND)
;     }

;     ;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
;     screenshot.__Gdip_SaveBitmapToFile(pBitmap, filepath)
;     screenshot.__Gdip_DisposeImage(pBitmap)
;     return
;   }

;   static CaptureRenderedActiveWindow(clientOnly := false, filepath := A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png")
;   ; NOTE: This function uses flags in calls to windows DLLs that are either not officially documented or ENTIRELY UNDOCUMENTED
;   ; As such, behavior may vary or change at any time
;   ; Rendered capture is also significantly slower, so should be avoided where possible
;   ; That said this is in my experience the most accurate window capture method across various apps
;   ; USE AT YOUR OWN RISK
;   {
;     userConfirm := MsgBox("This function uses undocumented flags for the Windows function PrintWindow. Behavior may be unexpected or change at any time. USE AT YOUR OWN RISK. Press OK if you accept to continue."
;       , "WARNING!", "OKCancel Icon! 256 4096")
;     if (userConfirm = "OK") {
;       activeHWND := WinExist("A")
;       if clientOnly {
;         pBitmap := screenshot.__Gdip_RenderedClientAreaBitmapFromHWND(activeHWND)
;       } else {
;         pBitmap := screenshot.__Gdip_RenderedBitmapFromHWND(activeHWND)
;       }
;       screenshot.__Gdip_SaveBitmapToFile(pBitmap, filepath)
;       screenshot.__Gdip_DisposeImage(pBitmap)
;     }
;     return
;   }

;   ;#####################################################################################
;   ; Extension GDI+ Functions for Screenshots:
;   ;#####################################################################################
;   ; extended by Buzzerb 21/11/2023
;   ;
;   ; Inclues functions to screenshot only the client area of an application, and to use
;   ; an unofficially documented PrintWindow flag to get a rendered screenshot of an application
;   ; which is required by most hardware accelerated apps to screenshot correctly

;   ;#####################################################################################
;   ; Modified GDI+ function to get bitmap of just the client areas of the window

;   ; Function				Gdip_ClientAreaBitmapFromHWND
;   ; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap of just its client area
;   ;						Note that the
;   ;
;   ; hwnd					handle to the window to get a bitmap from
;   ;
;   ; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;   ;
;   ; notes					Window must not be not minimised in order to get a handle to it's client area

;   static __Gdip_ClientAreaBitmapFromHWND(hwnd) {
;     screenshot.__WinGetClientRect(hwnd, , , &Width, &Height)
;     hbm := screenshot.__CreateDIBSection(Width, Height), hdc := screenshot.__CreateCompatibleDC(), obm := screenshot.__SelectObject(hdc, hbm)
;     screenshot.__PrintWindow(hwnd, hdc, 1)
;     pBitmap := screenshot.__Gdip_CreateBitmapFromHBITMAP(hbm)
;     screenshot.__SelectObject(hdc, obm), screenshot.__DeleteObject(hbm), screenshot.__DeleteDC(hdc)
;     return pBitmap
;   }

;   ;#####################################################################################
;   ; Modified GDI+ function to get bitmap of a window post rendering
;   ; WARNING: THIS USES A PrintWindow FLAG THAT IS NOT OFFICIALLY DOCUMENTED AND ONLY AVAILABLE IN WIN 8.1 AND HIGHER
;   ; DUE TO THE UNDOCUMENTED NATURE, THE BEHAVIOUR OF THIS SCRIPT MAY CHANGE AT ANY TIME

;   ; Function				Gdip_RenderedBitmapFromHWND
;   ; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap
;   ;						of that window post rendering. This is necessary for most hardware accelerated
;   ;						applications to get a screenshot that is not blank or corrupted. Note that the
;   ;						area screenshotted includes the non-client area, which may include the drop shadow
;   ;						often present in modern themes as a border. To avoid this, try capturing the client area
;   ;						only, using Gdip_RenderedClientAreaBitmapFromHWND
;   ;
;   ; hwnd					handle to the window to get a bitmap from
;   ;
;   ; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;   ;
;   ; notes					Window must not be not minimised in order to get a handle to it's client area

;   static __Gdip_RenderedBitmapFromHWND(hwnd) {
;     screenshot.__WinGetRect(hwnd, , , &Width, &Height)
;     hbm := screenshot.__CreateDIBSection(Width, Height), hdc := screenshot.__CreateCompatibleDC(), obm := screenshot.__SelectObject(hdc, hbm)
;     screenshot.__PrintWindow(hwnd, hdc, 2)
;     pBitmap := screenshot.__Gdip_CreateBitmapFromHBITMAP(hbm)
;     screenshot.__SelectObject(hdc, obm), screenshot.__DeleteObject(hbm), screenshot.__DeleteDC(hdc)
;     return pBitmap
;   }

;   ;#####################################################################################
;   ; Modified GDI+ function to get bitmap of just the client area of a window post rendering
;   ; WARNING: THIS USES A PrintWindow FLAG THAT IS ENTIRELY UNDOCUMENTED. USE AT YOUR OWN RISK
;   ; DUE TO THE  ENTIRELY UNDOCUMENTED NATURE, THE BEHAVIOUR OF THIS SCRIPT MAY CHANGE AT ANY TIME

;   ; Function				Gdip_RenderedClientAreaBitmapFromHWND
;   ; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap
;   ;						of just that window's client area post rendering. This is necessary for most
;   ;						hardware accelerated applications to get a screenshot that is not blank or corrupted.
;   ;
;   ; hwnd					handle to the window to get a bitmap from
;   ;
;   ; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;   ;
;   ; notes					Window must not be not minimised in order to get a handle to it's client area

;   static __Gdip_RenderedClientAreaBitmapFromHWND(hwnd) {
;     screenshot.__WinGetClientRect(hwnd, , , &Width, &Height)
;     hbm := screenshot.__CreateDIBSection(Width, Height), hdc := screenshot.__CreateCompatibleDC(), obm := screenshot.__SelectObject(hdc, hbm)
;     screenshot.__PrintWindow(hwnd, hdc, 3)
;     pBitmap := screenshot.__Gdip_CreateBitmapFromHBITMAP(hbm)
;     screenshot.__SelectObject(hdc, obm), screenshot.__DeleteObject(hbm), screenshot.__DeleteDC(hdc)
;     return pBitmap
;   }

;   ;#####################################################################################
;   ; Basic function to get a rectangle of the client area of an application
;   ; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
;   ; and the modified version of the above, WinGetRect as found in GDI+ for v2
;   static __WinGetClientRect(hwnd, &x := "", &y := "", &w := "", &h := "") {
;     Ptr := A_PtrSize ? "UPtr" : "UInt"
;     screenshot.__CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
;     ; VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
;     DllCall("GetClientRect", "Ptr", hwnd, "Ptr", winRect)
;     DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", winRect)
;     x := NumGet(winRect, 0, "UInt")
;     y := NumGet(winRect, 4, "UInt")
;     w := NumGet(winRect, 8, "UInt")
;     h := NumGet(winRect, 12, "UInt")
;   }

;   ;################################################################################################
;   ; All that follows are copied from the GDI+ library updated for v2 by buliasz 21/11/20231
;   ;
;   ; v1.61
;   ;
;   ;#####################################################################################
;   ;#####################################################################################
;   ; FUNCTIONS
;   ;#####################################################################################

;   ; Function				BitBlt
;   ; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle
;   ;						of pixels from the specified source device context into a destination device context.
;   ;
;   ; dDC					handle to destination DC
;   ; dx					x-coord of destination upper-left corner
;   ; dy					y-coord of destination upper-left corner
;   ; dw					width of the area to copy
;   ; dh					height of the area to copy
;   ; sDC					handle to source DC
;   ; sx					x-coordinate of source upper-left corner
;   ; sy					y-coordinate of source upper-left corner
;   ; Raster				raster operation code
;   ;
;   ; return				if the function succeeds, the return value is nonzero
;   ;
;   ; notes					if no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;   ;
;   ; BLACKNESS				= 0x00000042
;   ; NOTSRCERASE			= 0x001100A6
;   ; NOTSRCCOPY			= 0x00330008
;   ; SRCERASE				= 0x00440328
;   ; DSTINVERT				= 0x00550009
;   ; PATINVERT				= 0x005A0049
;   ; SRCINVERT				= 0x00660046
;   ; SRCAND				= 0x008800C6
;   ; MERGEPAINT			= 0x00BB0226
;   ; MERGECOPY				= 0x00C000CA
;   ; SRCCOPY				= 0x00CC0020
;   ; SRCPAINT				= 0x00EE0086
;   ; PATCOPY				= 0x00F00021
;   ; PATPAINT				= 0x00FB0A09
;   ; WHITENESS				= 0x00FF0062
;   ; CAPTUREBLT			= 0x40000000
;   ; NOMIRRORBITMAP		= 0x80000000

;   static __BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster := "") {
;     return DllCall("gdi32\BitBlt"
;       , "UPtr", dDC
;       , "Int", dx
;       , "Int", dy
;       , "Int", dw
;       , "Int", dh
;       , "UPtr", sDC
;       , "Int", sx
;       , "Int", sy
;       , "UInt", Raster ? Raster : 0x00CC0020)
;   }

;   ;#####################################################################################

;   ; Function				Gdip_BitmapFromScreen
;   ; Description			Gets a gdi+ bitmap from the screen
;   ;
;   ; Screen				0 = All screens
;   ;						Any numerical value = Just that screen
;   ;						x|y|w|h = Take specific coordinates with a width and height
;   ; Raster				raster operation code
;   ;
;   ; return					if the function succeeds, the return value is a pointer to a gdi+ bitmap
;   ;						-1:		one or more of x,y,w,h not passed properly
;   ;
;   ; notes					if no raster operation is specified, then SRCCOPY is used to the returned bitmap

;   static __Gdip_BitmapFromScreen(Screen := 0, Raster := "") {
;     hhdc := 0
;     if (Screen = 0) {
;       _x := DllCall("GetSystemMetrics", "Int", 76)
;       _y := DllCall("GetSystemMetrics", "Int", 77)
;       _w := DllCall("GetSystemMetrics", "Int", 78)
;       _h := DllCall("GetSystemMetrics", "Int", 79)
;     } else if (SubStr(Screen, 1, 5) = "hwnd:") {
;       Screen := SubStr(Screen, 6)
;       if !WinExist("ahk_id " Screen) {
;         return -2
;       }
;       screenshot.__WinGetRect(Screen, , , &_w, &_h)
;       _x := _y := 0
;       hhdc := screenshot.__GetDCEx(Screen, 3)
;     } else if IsInteger(Screen) {
;       M := screenshot.__GetMonitorInfo(Screen)
;       _x := M.Left, _y := M.Top, _w := M.Right - M.Left, _h := M.Bottom - M.Top
;     } else {
;       S := StrSplit(Screen, "|")
;       _x := S[1], _y := S[2], _w := S[3], _h := S[4]
;     }

;     if (_x = "") || (_y = "") || (_w = "") || (_h = "") {
;       return -1
;     }

;     chdc := screenshot.__CreateCompatibleDC()
;     hbm := screenshot.__CreateDIBSection(_w, _h, chdc)
;     obm := screenshot.__SelectObject(chdc, hbm)
;     hhdc := hhdc ? hhdc : screenshot.__GetDC()
;     screenshot.__BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
;     screenshot.__ReleaseDC(hhdc)

;     pBitmap := screenshot.__Gdip_CreateBitmapFromHBITMAP(hbm)

;     screenshot.__SelectObject(chdc, obm)
;     screenshot.__DeleteObject(hbm)
;     screenshot.__DeleteDC(hhdc)
;     screenshot.__DeleteDC(chdc)
;     return pBitmap
;   }

;   ;#####################################################################################

;   ; Function				Gdip_BitmapFromHWND
;   ; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;   ;
;   ; hwnd					handle to the window to get a bitmap from
;   ;
;   ; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;   ;
;   ; notes					Window must not be not minimised in order to get a handle to it's client area

;   static __Gdip_BitmapFromHWND(hwnd) {
;     screenshot.__WinGetRect(hwnd, , , &Width, &Height)
;     hbm := screenshot.__CreateDIBSection(Width, Height), hdc := screenshot.__CreateCompatibleDC(), obm := screenshot.__SelectObject(hdc, hbm)
;     screenshot.__PrintWindow(hwnd, hdc)
;     pBitmap := screenshot.__Gdip_CreateBitmapFromHBITMAP(hbm)
;     screenshot.__SelectObject(hdc, obm), screenshot.__DeleteObject(hbm), screenshot.__DeleteDC(hdc)
;     return pBitmap
;   }

;   ;#####################################################################################

;   ; Function				CreateRect
;   ; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;   ;
;   ; RectF		 			Name to call the RectF object
;   ; x						x-coordinate of the upper left corner of the rectangle
;   ; y						y-coordinate of the upper left corner of the rectangle
;   ; w						Width of the rectangle
;   ; h						Height of the rectangle
;   ;
;   ; return				No return value
;   static __CreateRect(&Rect, x, y, w, h) {
;     Rect := Buffer(16)
;     NumPut("UInt", x, "UInt", y, "UInt", w, "UInt", h, Rect)
;   }
;   ;#####################################################################################

;   ; Function				CreateDIBSection
;   ; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;   ;
;   ; w						width of the bitmap to create
;   ; h						height of the bitmap to create
;   ; hdc					a handle to the device context to use the palette from
;   ; bpp					bits per pixel (32 = ARGB)
;   ; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;   ;
;   ; return				returns a DIB. A gdi bitmap
;   ;
;   ; notes					ppvBits will receive the location of the pixels in the DIB

;   static __CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0) {
;     hdc2 := hdc ? hdc : screenshot.__GetDC()
;     bi := Buffer(40, 0)

;     NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)

;     hbm := DllCall("CreateDIBSection"
;       , "UPtr", hdc2
;       , "UPtr", bi.Ptr
;       , "UInt", 0
;       , "UPtr*", &ppvBits
;       , "UPtr", 0
;       , "UInt", 0, "UPtr")

;     if (!hdc) {
;       screenshot.__ReleaseDC(hdc2)
;     }
;     return hbm
;   }

;   ;#####################################################################################

;   ; Function				PrintWindow
;   ; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;   ;
;   ; hwnd					A handle to the window that will be copied
;   ; hdc					A handle to the device context
;   ; Flags					Drawing options
;   ;
;   ; return				if the function succeeds, it returns a nonzero value
;   ;
;   ; PW_CLIENTONLY			= 1

;   static __PrintWindow(hwnd, hdc, Flags := 0) {
;     return DllCall("PrintWindow", "UPtr", hwnd, "UPtr", hdc, "UInt", Flags)
;   }

;   ;#####################################################################################

;   ; Function				CreateCompatibleDC
;   ; Description			This function creates a memory device context (DC) compatible with the specified device
;   ;
;   ; hdc					Handle to an existing device context
;   ;
;   ; return				returns the handle to a device context or 0 on failure
;   ;
;   ; notes					if this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

;   static __CreateCompatibleDC(hdc := 0) {
;     return DllCall("CreateCompatibleDC", "UPtr", hdc)
;   }

;   ;#####################################################################################
;   ; Function				SelectObject
;   ; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;   ;
;   ; hdc					Handle to a DC
;   ; hgdiobj				A handle to the object to be selected into the DC
;   ;
;   ; return				if the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;   ;
;   ; notes					The specified object must have been created by using one of the following functions
;   ;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;   ;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;   ;						Font - CreateFont, CreateFontIndirect
;   ;						Pen - CreatePen, CreatePenIndirect
;   ;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;   ;
;   ; notes					if the selected object is a region and the function succeeds, the return value is one of the following value
;   ;
;   ; SIMPLEREGION			= 2 Region consists of a single rectangle
;   ; COMPLEXREGION			= 3 Region consists of more than one rectangle
;   ; NULLREGION			= 1 Region is empty

;   static __SelectObject(hdc, hgdiobj) {
;     return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
;   }

;   ;#####################################################################################

;   ; Function				DeleteObject
;   ; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;   ;						After the object is deleted, the specified handle is no longer valid
;   ;
;   ; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;   ;
;   ; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

;   static __DeleteObject(hObject) {
;     return DllCall("DeleteObject", "UPtr", hObject)
;   }

;   ;#####################################################################################

;   ; Function				GetDC
;   ; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;   ;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.
;   ;
;   ; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
;   ;
;   ; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

;   static __GetDC(hwnd := 0) {
;     return DllCall("GetDC", "UPtr", hwnd)
;   }

;   ;#####################################################################################

;   ; DCX_CACHE = 0x2
;   ; DCX_CLIPCHILDREN = 0x8
;   ; DCX_CLIPSIBLINGS = 0x10
;   ; DCX_EXCLUDERGN = 0x40
;   ; DCX_EXCLUDEUPDATE = 0x100
;   ; DCX_INTERSECTRGN = 0x80
;   ; DCX_INTERSECTUPDATE = 0x200
;   ; DCX_LOCKWINDOWUPDATE = 0x400
;   ; DCX_NORECOMPUTE = 0x100000
;   ; DCX_NORESETATTRS = 0x4
;   ; DCX_PARENTCLIP = 0x20
;   ; DCX_VALIDATE = 0x200000
;   ; DCX_WINDOW = 0x1

;   static __GetDCEx(hwnd, flags := 0, hrgnClip := 0) {
;     return DllCall("GetDCEx", "UPtr", hwnd, "UPtr", hrgnClip, "Int", flags)
;   }

;   ;#####################################################################################

;   ; Function				ReleaseDC
;   ; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;   ;
;   ; hdc					Handle to the device context to be released
;   ; hwnd					Handle to the window whose device context is to be released
;   ;
;   ; return				1 = released
;   ;						0 = not released
;   ;
;   ; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;   ;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.

;   static __ReleaseDC(hdc, hwnd := 0) {
;     return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
;   }

;   ;#####################################################################################

;   ; Function				DeleteDC
;   ; Description			The DeleteDC function deletes the specified device context (DC)
;   ;
;   ; hdc					A handle to the device context
;   ;
;   ; return				if the function succeeds, the return value is nonzero
;   ;
;   ; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

;   static __DeleteDC(hdc) {
;     return DllCall("DeleteDC", "UPtr", hdc)
;   }

;   ;#####################################################################################

;   ; Function:				Gdip_SaveBitmapToFile
;   ; Description:			Saves a bitmap to a file in any supported format onto disk
;   ;
;   ; pBitmap				Pointer to a bitmap
;   ; sOutput				The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
;   ; Quality				if saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;   ;
;   ; return				if the function succeeds, the return value is zero, otherwise:
;   ;						-1 = Extension supplied is not a supported file format
;   ;						-2 = Could not get a list of encoders on system
;   ;						-3 = Could not find matching encoder for specified file format
;   ;						-4 = Could not get WideChar name of output file
;   ;						-5 = Could not save file to disk
;   ;
;   ; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

;   static __Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality := 75) {
;     _p := 0

;     SplitPath(sOutput, , , &extension := "")
;     if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
;       return -1
;     }
;     extension := "." extension

;     DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount := 0, "uint*", &nSize := 0)
;     ci := Buffer(nSize)
;     DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
;     if !(nCount && nSize) {
;       return -2
;     }

;     loop nCount {
;       address := NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "UPtr")
;       sString := StrGet(address, "UTF-16")
;       if !InStr(sString, "*" extension)
;         continue

;       pCodec := ci.Ptr + idx
;       break
;     }

;     if !pCodec {
;       return -3
;     }

;     if (Quality != 75) {
;       Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality

;       if RegExMatch(extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
;         DllCall("gdiplus\GdipGetEncoderParameterListSize", "UPtr", pBitmap, "UPtr", pCodec, "uint*", &nSize)
;         EncoderParameters := Buffer(nSize, 0)
;         DllCall("gdiplus\GdipGetEncoderParameterList", "UPtr", pBitmap, "UPtr", pCodec, "UInt", nSize, "UPtr", EncoderParameters.Ptr)
;         nCount := NumGet(EncoderParameters, "UInt")
;         loop nCount {
;           elem := (24 + (A_PtrSize ? A_PtrSize : 4)) * (A_Index - 1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
;           if (NumGet(EncoderParameters, elem + 16, "UInt") = 1) && (NumGet(EncoderParameters, elem + 20, "UInt") = 6) {
;             _p := elem + EncoderParameters.Ptr - pad - 4
;             NumPut("UInt", Quality, NumGet(NumPut("UInt", 4, NumPut("UInt", 1, _p + 0) + 20), "UInt"))
;             break
;           }
;         }
;       }
;     }

;     _E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)

;     return _E ? -5 : 0
;   }

;   ;#####################################################################################

;   static __Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette := 0) {
;     DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap := 0)
;     return pBitmap
;   }

;   ;#####################################################################################
;   ; Create resources
;   ;#####################################################################################

;   static __Gdip_DisposeImage(pBitmap) {
;     return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
;   }

;   ;#####################################################################################
;   ; Extra functions
;   ;#####################################################################################

;   static __Gdip_Startup() {
;     if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
;       throw(Error("Could not load GDI+ library"))
;     }

;     si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
;     NumPut("UInt", 1, si)
;     DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "UPtr", si.Ptr, "UPtr", 0)
;     if (!pToken) {
;       throw(Error("Gdiplus failed to start. Please ensure you have gdiplus on your system"))
;     }

;     return pToken
;   }

;   static __Gdip_Shutdown(pToken) {
;     DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
;     hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
;     if (!hModule) {
;       ; throw(Error("GDI+ library was unloaded before shutdown"))
;     }
;     if (!DllCall("FreeLibrary", "UPtr", hModule)) {
;       ; throw(Error("Could not free GDI+ library"))
;     }

;     return 0
;   }

;   ; Prepend = 0; The new operation is applied before the old operation.
;   ; Append = 1; The new operation is applied after the old operation.

;   ; ======================================================================================================================
;   ; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx
;   ; by 'just me'
;   ; https://autohotkey.com/boards/viewtopic.php?f=6&t=4606
;   ; ======================================================================================================================

;   static __GetMonitorInfo(MonitorNum) {
;     Monitors := screenshot.__MDMF_Enum()
;     for k, v in Monitors {
;       if (v.Num = MonitorNum) {
;         return v
;       }
;     }
;   }

;   ; ----------------------------------------------------------------------------------------------------------------------
;   ; Name ..........: MDMF - Multiple Display Monitor Functions
;   ; Description ...: Various functions for multiple display monitor environments
;   ; Tested with ...: AHK 1.1.32.00 (A32/U32/U64) and 2.0-a108-a2fa0498 (U32/U64)
;   ; Original Author: just me (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4606)
;   ; Mod Authors ...: iPhilip, guest3456
;   ; Changes .......: Modified to work with v2.0-a108 and changed 'Count' key to 'TotalCount' to avoid conflicts
;   ; ................ Modified MDMF_Enum() so that it works under both AHK v1 and v2.
;   ; ................ Modified MDMF_EnumProc() to provide Count and Primary keys to the Monitors array.
;   ; ................ Modified MDMF_FromHWND() to allow flag values that determine the function's return value if the
;   ; ................    window does not intersect any display monitor.
;   ; ................ Modified MDMF_FromPoint() to allow the cursor position to be returned ByRef if not specified and
;   ; ................    allow flag values that determine the function's return value if the point is not contained within
;   ; ................    any display monitor.
;   ; ................ Modified MDMF_FromRect() to allow flag values that determine the function's return value if the
;   ; ................    rectangle does not intersect any display monitor.
;   ;................. Modified MDMF_GetInfo() with minor changes.
;   ; ----------------------------------------------------------------------------------------------------------------------
;   ;
;   ; ======================================================================================================================
;   ; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx =======================
;   ; ======================================================================================================================
;   ; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
;   ; ======================================================================================================================
;   static __MDMF_Enum(HMON := "") {
;     static EnumProc := CallbackCreate(screenshot.__MDMF_EnumProc)
;     static Monitors := Map()
;     if (HMON = "") { ; new enumeration
;       Monitors := Map("TotalCount", 0)
;       if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", ObjPtr(Monitors), "Int")
;         return False
;     }
;     return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
;   }
;   ; ======================================================================================================================
;   ;  Callback function that is called by the MDMF_Enum function.
;   ; ======================================================================================================================
;   static __MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
;     Monitors := ObjFromPtrAddRef(ObjectAddr)
;     Monitors[HMON] := screenshot.__MDMF_GetInfo(HMON)
;     Monitors["TotalCount"]++
;     if (Monitors[HMON].Primary) {
;       Monitors["Primary"] := HMON
;     }
;     return true
;   }

;   ; ======================================================================================================================
;   ; Retrieves information about a display monitor.
;   ; ======================================================================================================================
;   static __MDMF_GetInfo(HMON) {
;     MIEX := Buffer(40 + (32 << !!1))
;     NumPut("UInt", MIEX.Size, MIEX)
;     if DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX.Ptr, "Int") {
;       return { Name: (Name := StrGet(MIEX.Ptr + 40, 32)) ; CCHDEVICENAME = 32
;         , Num: RegExReplace(Name, ".*(\d+)$", "$1")
;         , Left: NumGet(MIEX, 4, "Int") ; display rectangle
;         , Top: NumGet(MIEX, 8, "Int") ; "
;         , Right: NumGet(MIEX, 12, "Int") ; "
;         , Bottom: NumGet(MIEX, 16, "Int") ; "
;         , WALeft: NumGet(MIEX, 20, "Int") ; work area
;         , WATop: NumGet(MIEX, 24, "Int") ; "
;         , WARight: NumGet(MIEX, 28, "Int") ; "
;         , WABottom: NumGet(MIEX, 32, "Int") ; "
;         , Primary: NumGet(MIEX, 36, "UInt") } ; contains a non-zero value for the primary monitor.
;     }
;     return False
;   }

;   ; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
;   static __WinGetRect(hwnd, &x := "", &y := "", &w := "", &h := "") {
;     Ptr := A_PtrSize ? "UPtr" : "UInt"
;     screenshot.__CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
;     ;VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
;     DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", winRect)
;     x := NumGet(winRect, 0, "UInt")
;     y := NumGet(winRect, 4, "UInt")
;     w := NumGet(winRect, 8, "UInt") - x
;     h := NumGet(winRect, 12, "UInt") - y
;   }
; }

sudo(text) {
  text := "
  (
  #NoTrayIcon

  )" . text
  f.write("./sudocmdrunning.ahk", text)
  RunWait("*RunAs " A_AhkPath ' "' A_WorkingDir '/sudocmdrunning.ahk' '"')
  FileDelete('./sudocmdrunning.ahk')
}

argReload(arglist := A_Args) {
  args := ""
  for arg in arglist {
    args .= ' "' . StrReplace(arg, '"', '\"') . '"'
  }
  Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"' . args)
  ExitApp()
}

AnyFile(files*) {
  for file in files {
    if FileExist(file)
      return file
  }
}

; createFileAssoc(fileExt, programPath, typeName := fileExt " file") {
;   RegWrite(typeName, "REG_EXPAND_SZ", "HKEY_CLASSES_ROOT\" fileExt "file", "")
;   RegWrite("`"" programPath "`"" "`"%1`"", "REG_EXPAND_SZ", "HKEY_CLASSES_ROOT\" fileExt "file\shell\open\command", "")
;   RegWrite(fileExt "file", "REG_EXPAND_SZ", "HKEY_CLASSES_ROOT\." fileExt, "")
; }

/**
 * makes all object properties optional and returns a default instead of throwing an error if key doesnt exist
 */
class OptObj extends Object {
  __New(obj, default := 0) {
    joinObjs(this._, obj)
    this.__default := IsSet(default) ? default : unset
  }
  _ := {}
  __default := 0
  ; __Set(Key, Params, Value) {
  ;   this._.%key% := Value
  ; }
  __Get(Key, Params) {
    trywrap(obj) {
      if type(obj) == Type({})
        return OptObj(obj)
      return obj
    }
    if Params.length
      try return trywrap(this._.%key%?.[Params*] ?? this.__default)
      catch
        return trywrap(this.__default)
    return trywrap(this._.%key% ?? this.__default)
  }
}

class OnNewWindow {
  static started := 0
  static cbs := []
  __New(func) {
    if not OnNewWindow.started {
      DllCall("RegisterShellHookWindow", "UInt", A_ScriptHWND)

      OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), (wParam, lParam, *) {
        if (wParam = 1) {
          for cb in OnNewWindow.cbs {
            cb(lParam)
          }
        }
      })
      OnNewWindow.started := 1
    }
    OnNewWindow.cbs.push(func)
  }
}

class Time {
  static to(num, to, from := Time.ms) {
    return num * to / from
  }
  static ms := 1
  static millisecond := Time.ms
  static microsecond := 1000 / Time.ms
  static nanosecond := 1000 / Time.microsecond
  static picosecond := 1000 / Time.nanosecond
  static femtosecond := 1000 / Time.picosecond
  static format(time) {
    ms := floor(mod(time, 1000))
    s := floor(mod(time / 1000, 60))
    m := floor(mod(time / 60000, 60))

    ; formattedTime := Format("{:02X}:{:02X}:{:03X}", m, s, ms)
    return m ':' s '.' ms

  }
  static sec := 1000 * Time.ms
  static second := Time.sec
  static min := 60 * Time.sec
  static Minutes := Time.min
  static hr := 60 * Time.min
  static hour := Time.hr
  static day := 24 * Time.hr
  static week := 7 * Time.day
  static fortnight := 14 * Time.day
  static month := 30.4375 * Time.day
  static year := 365.25 * Time.day
  static decade := 10 * Time.year
  static century := 100 * Time.year
  static millennium := 1000 * Time.year
}

class timer {
  startTime := 0
  timerLength := 0
  __New(timerLength, name := '') {
    this.startTime := A_TickCount
    this.timerLength := timerLength
    this.name := name
  }
  expired() {
    if A_TickCount > this.startTime + this.timerLength
      return True
    return False
  }
  restart() {
    this.startTime := A_TickCount
  }
  printTimeLeft() {
    print(this.name "TIME LEFT: " this.timerLength - (A_TickCount - this.startTime))
  }
  expire() {
    this.startTime -= this.timerLength
  }
}
class Stopwatch {
  startTime := 0
  __New(name := '') {
    this.startTime := A_TickCount
    this.name := name
  }
  restart() {
    this.startTime := A_TickCount
  }
  getTime() {
    return A_TickCount - this.startTime
  }
  printTimePassed() {
    print(this.name "TIME PASSED: " A_TickCount - this.startTime)
  }
}

getConsole(wd?, opts?, CMDPATH := "C:\Windows\system32\cmd.exe") {
  prevDetectHiddenWindows := A_DetectHiddenWindows
  DetectHiddenWindows(1)
  list := WinGetList(CMDPATH).join(",")
  Run(CMDPATH, wd?, opts?)
  pid := WinExist("A")
  while list = WinGetList(CMDPATH).join(",") {
  }
  print(list, WinGetList(CMDPATH))
  win := WinGetList(CMDPATH)[WinGetList(CMDPATH).find(e => !list.includes(e))]
  DetectHiddenWindows(prevDetectHiddenWindows)
  return win
}

isEmpty(p, filesOnly := 1) {
  p := path.info(p).abspath
  loop files p "\*", (filesOnly ? "fr" : "fdr") {
    return 0
  }
  return 1
}

class MakeLink {
  __New(from, to, type) {
    switch type {
      case MakeLink.hardlink:
        return RunWait('cmd /c "mklink /H "' path.info(to).abspath '" "' path.info(from).abspath '""', , "hide")
      case MakeLink.junction:
        return RunWait('cmd /c "mklink /J "' path.info(to).abspath '" "' path.info(from).abspath '""', , "hide")
      case MakeLink.symlink:
        if path.info(from).isdir
          return RunWait('cmd /c "mklink /D "' path.info(to).abspath '" "' path.info(from).abspath '""', , "hide")
        return RunWait('cmd /c "mklink "' path.info(to).abspath '" "' path.info(from).abspath '""', , "hide")
      default:
        throw("invalid type " type)
    }
  }
  static hardlink := 0
  static junction := 2
  static symlink := 1
}

confirm(text, title?) {
  return MsgBox(text, title?, 0x4 | 0x1000) = "yes"
}
listCursors() {
  arr := []
  loop reg, "HKEY_CURRENT_USER\Control Panel\Cursors\Schemes" {
    arr.push(A_LoopRegName)
  }
  return arr
}
addCursorScheme(Scheme, SchemeFolder) {
  KeyNames := [
    "Arrow",
    "Help",
    "AppStarting",
    "Wait",
    "Crosshair",
    "IBeam",
    "NWPen",
    "No",
    "SizeNS",
    "SizeWE",
    "SizeNWSE",
    "SizeNESW",
    "SizeAll",
    "UpArrow",
    "Hand",
    "Pin",
    "Person"
  ]
  KEYpath := "HKEY_CURRENT_USER\Control Panel\Cursors"
  SPI_SETCURSORS := 0x0057

  RegCreateKey("HKEY_CURRENT_USER\Control Panel\Cursors\Schemes")

  RegWrite(Scheme, "REG_SZ", KEYpath)
  for val in KeyNames {
    cursorFile := SchemeFolder . "\" . val . ".cur"
    if not FileExist(cursorFile)
      cursorFile := SchemeFolder . "\" . val . ".ani"
    if (FileExist(cursorFile)) {
      RegWrite(cursorFile, "REG_EXPAND_SZ", KEYpath, val)
    }
  }

  DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
}
setCursors(Scheme) {
  KeyNames := [
    "Arrow",
    "Help",
    "AppStarting",
    "Wait",
    "Crosshair",
    "IBeam",
    "NWPen",
    "No",
    "SizeNS",
    "SizeWE",
    "SizeNWSE",
    "SizeNESW",
    "SizeAll",
    "UpArrow",
    "Hand",
    "Pin",
    "Person"
  ]
  KEYpath := "HKEY_CURRENT_USER\Control Panel\Cursors"
  SPI_SETCURSORS := 0x0057

  SchemeVals := RegRead("HKEY_CURRENT_USER\Control Panel\Cursors\Schemes", Scheme)
  if (!SchemeVals) {
    SchemeVals := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\Cursors\Schemes", Scheme)
  }
  SchemeVals := SchemeVals.split(",")

  if (SchemeVals.Length > 0) {
    RegWrite(Scheme, "REG_SZ", KEYpath)
  }

  for index, val in SchemeVals {
    RegWrite(val, "REG_EXPAND_SZ", KEYpath, KeyNames[index])
  }
  DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", "0", "UInt", 0, "UInt", "0")
}

; Function to unzip a file
unzip(zipFile, outputDir) {
  DirCreate(outputDir)
  RunWait(A_ComSpec ' /c "powershell -command Expand-Archive -Path ' zipFile ' -DestinationPath ' outputDir ' -Force"', , "hide")
}
; DllCall("GetCommandLine", "str")

/*
by Bruttosozialprodukt
https://autohotkey.com/board/topic/101007-super-simple-download-with-progress-bar/
*/
/************************************************************************
 * @file: WinHttpRequest.ahk
 * @description: 网络请求库
 * @author thqby
 * @date 2021/08/01
 * @version 0.0.18
 ***********************************************************************/

class WinHttpRequest {
  static AutoLogonPolicy := {
    Always: 0,
    OnlyIfBypassProxy: 1,
    Never: 2
  }
  static Option := {
    UserAgentString: 0,
    URL: 1,
    URLCodePage: 2,
    EscapePercentInURL: 3,
    SslErrorIgnoreFlags: 4,
    SelectCertificate: 5,
    EnableRedirects: 6,
    UrlEscapeDisable: 7,
    UrlEscapeDisableQuery: 8,
    SecureProtocols: 9,
    EnableTracing: 10,
    RevertImpersonationOverSsl: 11,
    EnableHttpsToHttpRedirects: 12,
    EnablePassportAuthentication: 13,
    MaxAutomaticRedirects: 14,
    MaxResponseHeaderSize: 15,
    MaxResponseDrainSize: 16,
    EnableHttp1_1: 17,
    EnableCertificateRevocationCheck: 18,
    RejectUserpwd: 19
  }
  static PROXYSETTING := {
    PRECONFIG: 0,
    DIRECT: 1,
    PROXY: 2
  }
  static SETCREDENTIALSFLAG := {
    SERVER: 0,
    PROXY: 1
  }
  static SecureProtocol := {
    SSL2: 0x08,
    SSL3: 0x20,
    TLS1: 0x80,
    TLS1_1: 0x200,
    TLS1_2: 0x800,
    All: 0xA8
  }
  static SslErrorFlag := {
    UnknownCA: 0x0100,
    CertWrongUsage: 0x0200,
    CertCNInvalid: 0x1000,
    CertDateInvalid: 0x2000,
    Ignore_All: 0x3300
  }

  __New(UserAgent := unset) {
    (this.whr := ComObject('WinHttp.WinHttpRequest.5.1')).Option[0] := IsSet(UserAgent) ? UserAgent : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68'
  }

  request(url, method := 'GET', post_data?, headers := {}) {
    this.Open(method, url)
    for k, v in headers.OwnProps()
      this.SetRequestHeader(k, v)
    this.Send(post_data?)
    return this.ResponseText
  }
  enableRequestEvents(Enable := true) {
    static vtable := init_vtable()
    if !Enable
      return this._ievents := this._ref := 0
    if this._ievents
      return
    IConnectionPointContainer := ComObjQuery(pwhr := ComObjValue(this.whr), '{B196B284-BAB4-101A-B69C-00AA00341D07}')
    DllCall('ole32\CLSIDFromString', 'str', '{F97F4E15-B787-4212-80D1-D380CBBF982E}', 'ptr', IID_IWinHttpRequestEvents := Buffer(16))
    ComCall(4, IConnectionPointContainer, 'ptr', IID_IWinHttpRequestEvents, 'ptr*', IConnectionPoint := ComValue(0xd, 0)) ; IConnectionPointContainer->FindConnectionPoint
    IWinHttpRequestEvents := Buffer(3 * A_PtrSize)
    NumPut('ptr', vtable.Ptr, 'ptr', ObjPtr(this), 'ptr', ObjPtr(IWinHttpRequestEvents), IWinHttpRequestEvents)
    ComCall(5, IConnectionPoint, 'ptr', IWinHttpRequestEvents, 'uint*', &dwCookie := 0) ; IConnectionPoint->Advise
    this._ievents := {
      __Delete: (*) => ComCall(6, IConnectionPoint, 'uint', dwCookie)
    }
    static init_vtable() {
      vtable := Buffer(A_PtrSize * 7), offset := vtable.Ptr
      for nParam in StrSplit('3113213')
        offset := NumPut('ptr', CallbackCreate(EventHandler.Bind(A_Index), , Integer(nParam)), offset)
      vtable.DefineProp('__Delete', {
        call: __Delete
      })
      return vtable
      static EventHandler(index, this, arg1 := 0, arg2 := 0) {
        if (index < 4) {
          IEvents := NumGet(this, A_PtrSize * 2, 'ptr')
          if index == 1
            NumPut('ptr', this, arg2)
          if index == 3
            ObjRelease(IEvents)
          else ObjAddRef(IEvents)
          return 0
        }
        req := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))
        req.readyState := index - 2
        switch index {
          case 4: ; OnResponseStart
            try req.OnResponseStart(arg1, StrGet(arg2, 'utf-16'))
          case 5: ; OnResponseDataAvailable
            try req.OnResponseDataAvailable(
              NumGet((pSafeArray := NumGet(arg1, 'ptr')) + 8 + A_PtrSize, 'ptr'),
              NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint'))
          case 6: ; OnResponseFinished
            try req._ref := 0, req.OnResponseFinished()
          case 7: ; OnError
            try req.readyState := req._ref := 0, req.OnError(arg1, StrGet(arg2, 'utf-16'))
        }
      }
      static __Delete(this) {
        loop 7
          CallbackFree(NumGet(this, (A_Index - 1) * A_PtrSize, 'ptr'))
      }
    }
  }

  ;#region IWinHttpRequest https://learn.microsoft.com/en-us/windows/win32/winhttp/iwinhttprequest-interface
  SetProxy(ProxySetting, ProxyServer, BypassList) => this.whr.SetProxy(ProxySetting, ProxyServer, BypassList)
  SetCredentials(UserName, Password, Flags) => this.whr.SetCredentials(UserName, Password, Flags)
  SetRequestHeader(Header, Value) => this.whr.SetRequestHeader(Header, Value)
  GetResponseHeader(Header) => this.whr.GetResponseHeader(Header)
  GetAllResponseHeaders() => this.whr.GetAllResponseHeaders()
  Send(Body?) => (this._ievents && this._ref := this, this.whr.Send(Body?))
  Open(verb, url, async := false) {
    this.readyState := 0
    this.whr.Open(verb, url, async)
    this.readyState := 1
  }
  WaitForResponse(Timeout := -1) => this.whr.WaitForResponse(Timeout)
  Abort() => (this._ref := this.readyState := 0, this.whr.Abort())
  SetTimeouts(ResolveTimeout := 0, ConnectTimeout := 60000, SendTimeout := 30000, ReceiveTimeout := 30000) => this.whr.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
  SetClientCertificate(ClientCertificate) => this.whr.SetClientCertificate(ClientCertificate)
  SetAutoLogonPolicy(AutoLogonPolicy) => this.whr.SetAutoLogonPolicy(AutoLogonPolicy)

  Status => this.whr.Status
  StatusText => this.whr.StatusText
  ResponseText => this.whr.ResponseText
  ResponseBody {
    get {
      pSafeArray := ComObjValue(t := this.whr.ResponseBody)
      pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
      cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
      return ClipboardAll(pvData, cbElements)
    }
  }
  ResponseStream => this.whr.responseStream
  Option[Opt] {
    get => this.whr.Option[Opt]
    set => (this.whr.Option[Opt] := Value)
  }
  Headers {
    get {
      m := Map(), m.Default := ''
      loop parse this.GetAllResponseHeaders(), '`r`n'
        if (p := InStr(A_LoopField, ':'))
          m[SubStr(A_LoopField, 1, p - 1)] .= LTrim(SubStr(A_LoopField, p + 1))
      return m
    }
  }
  /**
   * The OnError event occurs when there is a run-time error in the application.
   * @prop {(this,errCode,errDesc)=>void} OnError
   */
  OnError := 0
  /**
   * The OnResponseDataAvailable event occurs when data is available from the response.
   * @prop {(this,safeArray)=>void} OnResponseDataAvailable
   */
  OnResponseDataAvailable := 0
  /**
   * The OnResponseStart event occurs when the response data starts to be received.
   * @prop {(this,status,contentType)=>void} OnResponseDataAvailable
   */
  OnResponseStart := 0
  /**
   * The OnResponseFinished event occurs when the response data is complete.
   * @prop {(this)=>void} OnResponseDataAvailable
   */
  OnResponseFinished := 0
  ;#endregion

  readyState := 0, whr := 0, _ievents := 0
  static __New() {
    if this != WinHttpRequest
      return
    this.DeleteProp('__New')
    for prop in [
      'OnError',
      'OnResponseDataAvailable',
      'OnResponseStart',
      'OnResponseFinished'
    ]
      this.Prototype.DefineProp(prop, {
        set: make_setter(prop)
      })
    make_setter(prop) => (this, value := 0) => value && (this.DefineProp(prop, {
      call: value
    }), this.enableRequestEvents())
  }
}
/**
 * Asynchronous download, you can get the download progress, and call the specified function after the download is complete
 * @param {String} URL The URL address to be downloaded, including the http(s) header
 * @param {String} Filename File path to save. If omit, download to memory
 * @param {(whrOrErr)=>void} OnFinished Download finished callback function
 * @param {(downloaded_size, total_size)=>void} OnProgress Download progress callback function
 * @return {WinHttpRequest} A WinHttpRequest instance, can be used to terminate the download
 * @example
 * url := "https://www.autohotkey.com/download/ahk-v2.exe"
 * Persistent()
 * DownloadAsync(url,,
 *   (req) => (Persistent(0), ToolTip(), (req is OSError) ? MsgBox('Error:' req.Message) : MsgBox('size: ' req.ResponseBody.Size)),
 *   (s, t) => ToolTip('downloading: ' s '/' t))
 */
DownloadAsync(URL, Filename?, OnFinished := 0, OnProgress := 0, headers := {}) {
  totalsize := -1, file := size := 0, err := OSError(0, -1)
  if IsSet(Filename) && !(file := FileOpen(Filename, 'w-wd'))
    throw OSError()
  req := WinHttpRequest(), req.Open('GET', URL, true)
  if (OnProgress) {
    req.OnResponseDataAvailable := (self, pvData, cbElements) => OnProgress(size += cbElements, totalsize)
    req2 := WinHttpRequest()
    req2.OnResponseFinished := (whr) => totalsize := Integer(whr.GetResponseHeader('Content-Length'))
    req2.OnError := finished
    req2.Open('HEAD', URL, false)
    for k in headers.OwnProps()
      req2.SetRequestHeader(k, headers.%k%)
    req2.Send()
    if totalsize == 0 {
      req2 := WinHttpRequest()
      req2.OnResponseFinished := (whr) => totalsize := Integer(whr.GetResponseHeader('Content-Length'))
      req2.OnError := finished
      req2.Open('HEAD', URL, true)
      req2.Send()
    }
  }
  req.OnError := req.OnResponseFinished := finished
  for k in headers.OwnProps()
    req.SetRequestHeader(k, headers.%k%)
  req.Send()
  return req

  finished(self, msg := 0, data := 0) {
    if (msg) {
      if file
        file.Close(), FileDelete(Filename)
      err.Message := data, err.Number := msg, err.Extra := URL
      try OnFinished(err)
    } else {
      if file {
        pSafeArray := ComObjValue(body := self.whr.ResponseBody)
        pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
        cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
        file.RawWrite(pvData, cbElements), file.Close()
      }
      try OnFinished(self)
    }
    OnFinished := file := 0
  }
}
DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, headers := {}) {
  ;Check if the file already exists and if we must not overwrite it
  ;The label that updates the progressbar
  LastSize := 0
  LastSizeTick := 0
  ; ProgressGuiText2 := ''
  ; ProgressGuiText := ''
  __UpdateProgressBar := (CurrentSize, FinalSize) { ; V1toV2: Added bracket
    ;Get the current filesize and tick
    try {

      ; CurrentSize := FileGetSize(SaveFileAs) ;FileGetSize wouldn't return reliable results
      CurrentSizeTick := A_TickCount
      ;Calculate the downloadspeed
      Speed := "?"
      try Speed := Round((max(CurrentSize, 1) / 1024 - max(LastSize, 1) / 1024) / ((max(CurrentSizeTick, 1) - max(LastSizeTick, 1)) / 1000) / 100) . " Kb/s"
      ;Save the current filesize and tick for the next time
      LastSizeTick := CurrentSizeTick
      LastSize := CurrentSize
      ;Calculate percent done
      PercentDone := Floor(CurrentSize / max(FinalSize, 1) * 100)
      if PercentDone > 100 {
        print('PercentDone > 100', PercentDone)
        PercentDone := "???"
      } else {
        gocProgress.Value := PercentDone
      }
      ;Update the ProgressBar
      ; ProgressGui.Title := "Downloading " SaveFileAs " 〰" PercentDone "`%ㄱ"
      ProgressGuiText.text := "Downloading...  (" Speed ")"
      ProgressGuiText2.text := PercentDone "`% Done"
      ProgressGui.Show("AutoSize NoActivate")
    } catch Error as e {
      if IsSet(PercentDone)
        print("Error while updating progress bar. ", e.Message, e.Line, e.Extra, e.Stack, "PercentDone", PercentDone)
      else
        print("Error while updating progress bar. ", e.Message, e.Line, e.Extra, e.Stack, "PercentDone", "unset")
      ; if PercentDone >= 100 {
      ;   try {
      ;     SetTimer(__UpdateProgressBar, 0)
      ;   }
      ; }
    }
    return
  } ; V1toV2: Added bracket in the end
  if (!Overwrite && FileExist(SaveFileAs))
    return
  dd := 0
  done := (*) {
    dd := 1
  }
  ;Check if the user wants a progressbar
  if (UseProgressBar) {
    ProgressGui := Gui("ToolWindow -Sysmenu Disabled AlwaysOnTop +E0x20 -Border -Caption")
    ProgressGui.Title := UrlToFile
    ProgressGui.SetFont("Bold")
    ProgressGuiText := ProgressGui.AddText("x0 w200 Center", "Downloading...")
    ProgressGuiText2 := ProgressGui.AddText("x0 w200 Center", 0 "`% Done")
    gocProgress := ProgressGui.AddProgress("x10 w180 h20")
    ProgressGui.Show("AutoSize NoActivate")
    DownloadAsync(UrlToFile, SaveFileAs, done, __UpdateProgressBar, headers)
  }
  while !dd {
    Sleep(100)
  }
  if (UseProgressBar) {
    ProgressGui.Destroy()
  }
  return
}
; DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, headers := {}) {
;   ;Check if the file already exists and if we must not overwrite it
;   ;The label that updates the progressbar
;   LastSize := 0
;   LastSizeTick := 0
;   ; ProgressGuiText2 := ''
;   ; ProgressGuiText := ''
;   __UpdateProgressBar := () { ; V1toV2: Added bracket
;     ;Get the current filesize and tick
;     try {

;       CurrentSize := 0 ;FileGetSize(SaveFileAs) ;FileGetSize wouldn't return reliable results
;       CurrentSizeTick := A_TickCount
;       ;Calculate the downloadspeed
;       Speed := Round((CurrentSize / 1024 - LastSize / 1024) / ((CurrentSizeTick - LastSizeTick) / 1000)) . " Kb/s"
;       ;Save the current filesize and tick for the next time
;       LastSizeTick := CurrentSizeTick
;       LastSize := 0
;       try LastSize := FileGetSize(SaveFileAs)
;       ;Calculate percent done
;       PercentDone := Floor(CurrentSize / FinalSize * 100)
;       ;Update the ProgressBar
;       ; ProgressGui.Title := "Downloading " SaveFileAs " 〰" PercentDone "`%ㄱ"
;       ProgressGuiText.text := "Downloading...  (" Speed ")"
;       gocProgress.Value := PercentDone
;       ProgressGuiText2.text := PercentDone "`% Done"
;       ProgressGui.Show("AutoSize NoActivate")
;     } catch Error as e {
;       logerr("Error while updating progress bar. ", e)
;       try print("Error while updating progress bar. ", e, "PercentDone", PercentDone)
;       ; if PercentDone >= 100 {
;       ;   try {
;       ;     SetTimer(__UpdateProgressBar, 0)
;       ;   }
;       ; }
;     }
;     return
;   } ; V1toV2: Added bracket in the end
;   if (!Overwrite && FileExist(SaveFileAs))
;     return
;   ;Check if the user wants a progressbar
;   if (UseProgressBar) {
;     ;Initialize the WinHttpRequest Object
;     WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
;     ;Download the headers
;     WebRequest.Open("HEAD", UrlToFile)
;     WebRequest.Send()
;     ;Store the header which holds the file size in a variable:
;     FinalSize := WebRequest.GetResponseHeader("Content-Length")
;     ;Create the progressbar and the timer
;     ProgressGui := Gui("ToolWindow -Sysmenu Disabled AlwaysOnTop +E0x20 -Border -Caption")
;     ProgressGui.Title := UrlToFile
;     ProgressGui.SetFont("Bold")
;     ProgressGuiText := ProgressGui.AddText("x0 w200 Center", "Downloading...")
;     ProgressGuiText2 := ProgressGui.AddText("x0 w200 Center", 0 "`% Done")
;     gocProgress := ProgressGui.AddProgress("x10 w180 h20")
;     ProgressGui.Show("AutoSize NoActivate")
;     SetTimer(__UpdateProgressBar, 100)
;   }
;   ;Download the file
;   WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
;   WebRequest.Open("GET", UrlToFile, 1)
;   for h in headers.OwnProps() {
;     WebRequest.SetRequestHeader(h, headers.%h%)
;   }
;   WebRequest.Send()
;   while 1 {
;     print(WebRequest.ResponseBody.maxIndex())
;     Sleep(100)
;   }
;   a := WebRequest.ResponseBody
;   if FileExist(SaveFileAs)
;     FileDelete(SaveFileAs)
;   uBytes := WebRequest.ResponseBody
;   cLen := uBytes.maxIndex()
;   fileHandle := fileOpen(SaveFileAs, "w")
;   f := Buffer(cLen, 0) ; V1toV2: if 'f' is a UTF-16 string, use 'VarSetStrCapacity(&f, cLen)'
;   loop cLen
;     NumPut("UChar", uBytes[a_index - 1], f, a_index - 1)
;   err := fileHandle.rawWrite(f)
;   ; FileAppend(WebRequest.ResponseBody, SaveFileAs, "RAW")
;   if WebRequest.Status == 200 {
;   } else {
;     throw Error("Download failed: " WebRequest.Status " - " WebRequest.StatusText)
;   }

;   ; Download(UrlToFile, SaveFileAs)
;   ;Remove the timer and the progressbar because the download has finished
;   if (UseProgressBar) {
;     ProgressGui.Destroy()
;     SetTimer(__UpdateProgressBar, 0)
;   }
;   return
; }

GuiSetPlaceholder(guiCtrlOrHwnd, Cue) {
  if !(guiCtrlOrHwnd is Integer) {
    guiCtrlOrHwnd := guiCtrlOrHwnd.hwnd
  }
  static EM_SETCUEBANNER := (0x1500 + 1)
  return DllCall("User32.dll\SendMessageW", "Ptr", guiCtrlOrHwnd, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

aotMsgBox(Text := '', Title := A_ScriptName, Options := 0) {
  MsgBox(Text, Title, Options | 0x1000)
}
