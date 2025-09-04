; Background17b9ff ce60000
; fix bg colors
; set<br>
; gap := int

#Include <Misc>

; **owner**: *bool* or *hwnd*<br>
; **showIcon**: *bool*<br>
; **SysMenu**: *bool*<br>
; **AOT**: *bool*<br>
; **topBar**: *bool*<br>
; **resize**: *bool*<br>
; **maxBtn**: *bool*<br>
; **minBtn**: *bool*<br>
; **active**: *bool*<br>
; **disabled**: *bool*<br>
; **theme**: *bool*<br>
; **tool**: *bool*<br>
; **ownDialogs**: *bool* - no idea what the use would be<br>
; **minSize**: { x: *int*, y: *int* }<br>
; **maxSize**: { x: *int*, y: *int* }<br>
; **clickThrough**: *bool*<br>
; **transparency**: *int*[range(*0*, *255*)]<br>
; <br>
; **x**: *int* := 0<br>
; **y**: *int* := 0<br>
; **w**: *int* := 100<br>
; **h**: *int* := 100<br>
; **gap**: *int*<br>
; **ignoretextcolor**: *int*<br>
; **autoRight**: *bool* := true - ***moves right after adding any element***<br>

class betterui extends gui {
  opts := {}
  static newButtonPanel(data, onclick := (*) => unset, settingsobj := {}) {
    mainonclick := onclick
    if settingsobj.hasprop("rowLength")
      rowLength := settingsobj.rowLength
    else
      rowLength := 7

    ; if IsSet(baseui) {
    ;   obj := joinObjs(baseui.opts, obj)
    ;   ; WinGetPos(&x, &y, &w, &h, baseui)
    ;   ui := this(obj)
    ;   baseui.hide()
    ;   ui.show("NoActivate")
    ; } else
    ui := this(joinObjs({
      aot: 1,
      topbar: 1,
      resize: 1,
      showicon: 1,
      tool: 1,
      minBtn: 1,
      w: 200,
      h: 30,
    }, settingsobj))
    ; for key, ctrl in ui {

    ;   ctrl.Control("hide")
    ;   try ui.Delete(key) ; ?
    ;   try ctrl.RemoveProp(key) ; ?
    ;   try ui[key].RemoveProp() ; ?
    ;   try ui.RemoveProp(key) ; ?
    ;   try ui.Delete(key) ; ?
    ; }
    ui.ignoretextcolor := 1
    buttons := []
    loop data.length {
      item := data[A_Index]
      if Type(item) = "string"
        item := { name: item }
      try options := item.options
      catch
        options := ""
      try textoptions := item.textoptions
      catch
        textoptions := ""
      try onclick := item.onclick
      catch
        onclick := mainonclick
      try text := item.text
      catch
        text := unset
      if IsSet(text) {
        linesize := (item.text.Split("`n").length * 13) + 5
        item := item.Clone()
        ui.add("text", { text: item.text, options: "center h" linesize }, &text)
        .moveDown(linesize, 1)
        .moveLeft(1)
        try {
          for btnData in item.btns {
            ui.add("button", joinObjs({ text: "" }, btnData, { o: "w" ui.opts.w / (item.btns.length) }), &btn)
            try onclick := btnData.onclick
            catch
              onclick := mainonclick
            btn.OnEvent("click", onclick.bind(btndata, item, { text: text, btn: btn }))
          }
        }
        ui.moveUp(linesize, 1)
        text.setfont("c" (item.DeleteProp("c") || item.DeleteProp("color") || "aaaaaa"))
      } else {
        try {
          for btnData in item.btns {
            ui.add("button", joinObjs({ text: "" }, btnData, { o: "w" ui.opts.w / (item.btns.length) }), &btn)
            try onclick := btnData.onclick
            catch
              onclick := mainonclick
            btn.OnEvent("click", onclick.bind(btndata, item, { btn: btn }))
          }
        }
      }
      ; item.btn := btn
      if !IsSet(linesize)
        linesize := 0
      if mod(A_Index, rowLength) == 0 && A_Index != data.Length
        ui.newline(1)
        .newline(linesize + 5, 1)
      buttons.push(item)
    }
    ; if IsSet(baseui) {
    ;   WinGetPos(&x, &y, &w, &h, baseui)
    ;   baseui.destroy()
    ;   ui.show("NoActivate")
    ;   WinMove(x, y, w, h, ui)
    ; }
    return ui
  }

  ignoretextcolor := 0
  darkmode := !RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 1)
  defaultWindowPadding := 5
  __New(opts) {
    this.opts := {}
    this.templastw := 0
    this.templasth := 0
    ; this.currentlinelength := 0
    ;
    ; this.ButtonColour := "010409"
    ; this.ButtonOutlineColour := "010409"
    ; this.ActiveButtonColour := "1b1a20"
    ; this.SentButtonColour := "553b6b"
    ; this.ToggledButtonColour := "553b6a" ; don't set exactly the same as SentButtonColour
    ; this.TextColour := "8b949e"
    ;

    this.gap := opts.deleteprop("gap") || 0
    this.autoright := opts.hasprop("autoright") ? opts.deleteprop("autoright") : 1
    super.__new("", "", this)

    ; ___SetWindowAttribute(this)

    ; ___SetWindowAttribute(this)
    ; this.BackColor := "2A2A2E"
    ; this.color := "010409"

    this.setopts(opts)
    this.startpos := {
      x: opts.deleteprop("x") || 0,
      y: opts.deleteprop("y") || 0,
    }
    this.lastdata := {
      x: this.startpos.x,
      y: this.startpos.y,
      w: opts.deleteprop("w") || 100,
      h: opts.deleteprop("h") || 100,
      linesize: 1,
    }
  }

  ; __property[name] {
  ;   set => this[name] := value
  ;   get => this[name]
  ; }
  ; setdark() {
  ;   SetWindowTheme(this)
  ; }

  setStart(x, y) {
    RegExMatch(x, "(\d+(?:\.\d+)?)(x)?", &x)
    RegExMatch(y, "(\d+(?:\.\d+)?)(x)?", &y)
    if x.2
      x := (x.1 * (this.lastdata.w + this.gap))
    else
      x := x.0
    if y.2
      y := (y.1 * (this.lastdata.w + this.gap))
    else
      y := y.0
    this.startpos.x := this.lastdata.x := x
    this.startpos.y := this.lastdata.y := y
    this.goToStart()
  }
  moveStart(x, y) {
    laststartx := this.startpos.x
    laststarty := this.startpos.y
    this.setStart(x, y)
    this.startpos.x += laststartx
    this.startpos.y += laststarty
    this.gotostart()
    this.__addstartgap()
  }
  goToStart() {
    this.lastdata.x := this.startpos.x
    this.lastdata.y := this.startpos.y
    this.__addstartgap()
  }

  ; addTextInBox(text, data) {
  ;   ; add y center
  ;   ct := this.AddProgress(data . " -Wrap Center", text)
  ;   ct := this.AddText(data . " xp yp -Wrap BackgroundTrans Center", text)
  ;   return this
  ; }

  /**
   * type: *enum*[ActiveX, Button, Checkbox, ComboBox, Custom, DateTime, DropDownList, Edit, GroupBox, Hotkey, Link, ListBox, ListView, MonthCal, Picture, Progress, Radio, Slider, StatusBar, Tab, Tab2, Tab3, Text, TreeView, UpDown]<br>
   * <br>
   * {<br>
   *   *t*ext: string|?<br>
   *   *o*ptions: string|?<br>
   * }<br>
   * <br>
   * **&elem**: *varRef* - ***return the element***<br>
   */
  add(type, obj, &elem?) {

    opts := obj.deleteprop("o") || obj.deleteprop("options") || ""
    text := obj.deleteprop("t") || obj.deleteprop("text") || ""
    RegExMatch(opts, "w(\d+(?:\.\d+)?)(x)?", &w)
    RegExMatch(opts, "h(\d+(?:\.\d+)?)(x)?", &h)
    templastx := this.lastdata.x
    if this.templastw {
      this.lastdata.w := this.templastw
      this.lastdata.h := this.templasth
    }
    this.templastw := this.lastdata.w
    this.templasth := this.lastdata.h
    if w {
      if !w.2
        this.lastdata.w := w.1
      if w.2
        opts := StrReplace(opts, w.0, 'w' . (w.1 * (this.lastdata.w + this.gap)) - this.gap)
    }
    if h {
      if !h.2 {
        this.lastdata.h := h.1
      }
      if h.2 {
        opts := StrReplace(opts, h.0, 'h' . (h.1 * this.lastdata.h))
        if h.1 > this.lastdata.linesize
          this.lastdata.linesize := h.1
      }
    }
    ; this.currentlinelength += this.lastdata.h
    this.__addstartgap()
    switch type {

      ; case "addTextInBox":
      ;   this.addTextInBox(text, "w" . this.lastdata.w . " h" . this.lastdata.h . ' x' . this.lastdata.x . ' y' . this.lastdata.y . " " . opts)
default:
      ct := super.add.call(this, type, "w" . this.lastdata.w . " h" . this.lastdata.h . ' x' . this.lastdata.x . ' y' . this.lastdata.y . " " . opts, text)
    }
    elem := ct
    ControlGetPos(&x, &y, &newW, &newH, ct)
    this.lastdata.y := y
    if w ;and w.2
      this.lastdata.x := x + newW - this.lastdata.w
    else
      this.lastdata.w := newW
    if h and h.2
      this.lastdata.h := newH / h.1
    else
      this.lastdata.h := newH
    if !this.autoright
      this.lastdata.x := templastx
    else
      this.moveRight()

    return this
  }
  setSize(w := this.lastdata.w, h := this.lastdata.h) {
    this.lastdata.w := w
    this.lastdata.h := h
    return this
  }
  __addstartgap() {
    if this.lastdata.x == this.startpos.x
      this.lastdata.x += this.gap > this.defaultWindowPadding ? this.gap : this.defaultWindowPadding
    if this.lastdata.y == this.startpos.y
      this.lastdata.y += this.gap > this.defaultWindowPadding ? this.gap : this.defaultWindowPadding
  }
  newLine(lineCount := 1, px := 0) {
    this.__addstartgap()
    this.lastdata.y += px == 1 ? lineCount :
      ; this.currentlinelength
      ((this.lastdata.h * this.lastdata.linesize) + this.gap) * lineCount
    this.lastdata.x := this.startpos.x
    this.lastdata.linesize := 1
    ; this.currentlinelength := 0
    return this
  }
  moveUp(steps := 1, px := 0) {
    this.__addstartgap()
    this.lastdata.y -= px ? steps : (this.lastdata.h + this.gap) * steps
    return this
  }
  moveDown(steps := 1, px := 0) {
    this.__addstartgap()
    this.lastdata.y += px ? steps : (this.lastdata.h + this.gap) * steps
    return this
  }
  moveLeft(steps := 1, px := 0) {
    this.__addstartgap()
    this.lastdata.x -= px ? steps : (this.lastdata.w + this.gap) * steps
    return this
  }
  moveRight(steps := 1, px := 0) {
    this.__addstartgap()
    this.lastdata.x += px ? steps : (this.lastdata.w + this.gap) * steps
    return this
  }
  show(opts := "") {
    this.lastdata.y += this.lastdata.h
    this.lastdata.x -= this.defaultwindowpadding
    this.lastdata.y -= this.defaultwindowpadding
    this.add("edit", {
      options: "w" . 0 . ' h' . this.gap . ' x' . this.lastdata.x - 5
    })
    DarkColors := Map("Background", "0x202020", "Controls", "0x404040", "Font", "0xE0E0E0")

    PreferredAppMode := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

    if (VerCompare(A_OSVersion, "10.0.17763") >= 0) {
      DWMWA_USE_IMMERSIVE_DARK_MODE := 19
      if (VerCompare(A_OSVersion, "10.0.18985") >= 0) {
        DWMWA_USE_IMMERSIVE_DARK_MODE := 20
      }
      uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
      SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
      FlushMenuThemes := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
      if this.darkmode {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
        DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
        DllCall(FlushMenuThemes)
        if !this.BackColor
          this.BackColor := DarkColors["Background"]
      }
    }
    GWL_WNDPROC := -4
    GWL_STYLE := -16
    ES_MULTILINE := 0x0004
    LVM_GETTEXTCOLOR := 0x1023
    LVM_SETTEXTCOLOR := 0x1024
    LVM_GETTEXTBKCOLOR := 0x1025
    LVM_SETTEXTBKCOLOR := 0x1026
    LVM_GETBKCOLOR := 0x1000
    LVM_SETBKCOLOR := 0x1001
    LVM_GETHEADER := 0x101F
    GetWindowLong := A_PtrSize == 8 ? "GetWindowLongPtr" : "GetWindowLong"
    SetWindowLong := A_PtrSize == 8 ? "SetWindowLongPtr" : "SetWindowLong"
    Init := False
    LV_Init := False

    Mode_Explorer := "DarkMode_Explorer"
    Mode_CFD := "DarkMode_CFD"
    Mode_ItemsView := "DarkMode_ItemsView"
    if this.darkmode
      for hWnd, GuiCtrlObj in this {
        if GuiCtrlObj.HasProp("BackColor")
          continue
        switch GuiCtrlObj.Type {
          case "Button", "CheckBox", "ListBox", "UpDown":
          {
            DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
          }
          case "ComboBox", "DDL":
          {
            DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
          }
          case "Edit":
          {
            if (DllCall("user32\" GetWindowLong, "Ptr", GuiCtrlObj.hWnd, "Int", GWL_STYLE) & ES_MULTILINE) {
              DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
            } else {
              DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
            }
          }
          case "ListView":
          {
            if !(LV_Init) {
              LV_TEXTCOLOR := SendMessage(LVM_GETTEXTCOLOR, 0, 0, GuiCtrlObj.hWnd)
              LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
              LV_BKCOLOR := SendMessage(LVM_GETBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
              LV_Init := True
            }
            GuiCtrlObj.Opt("-Redraw")
            if this.darkmode {
              SendMessage(LVM_SETTEXTCOLOR, 0, DarkColors["Font"], GuiCtrlObj.hWnd)
              SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
              SendMessage(LVM_SETBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
            } else {
              SendMessage(LVM_SETTEXTCOLOR, 0, LV_TEXTCOLOR, GuiCtrlObj.hWnd)
              SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
              SendMessage(LVM_SETBKCOLOR, 0, LV_BKCOLOR, GuiCtrlObj.hWnd)
            }

            DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)

            ; To color the selection - scrollbar turns back to normal
            ;DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_ItemsView, "Ptr", 0)

            ; Header Text needs some NM_CUSTOMDRAW coloring
            LV_Header := SendMessage(LVM_GETHEADER, 0, 0, GuiCtrlObj.hWnd)
            DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", Mode_ItemsView, "Ptr", 0)
            GuiCtrlObj.Opt("+Redraw")
          }
        }
      }

    if !(Init) {
      TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
      ; https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm#ExSubclassGUI
      WindowProcNew := CallbackCreate(___WindowProc(hwnd, uMsg, wParam, lParam) {
        critical()
        WM_CTLCOLOREDIT := 0x0133
        WM_CTLCOLORLISTBOX := 0x0134
        WM_CTLCOLORBTN := 0x0135
        WM_CTLCOLORSTATIC := 0x0138
        DC_BRUSH := 18
        if (this.darkmode) {
          switch uMsg {
            case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
              DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
              DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Controls"])
              DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Controls"], "UInt")
              return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
            case WM_CTLCOLORBTN:
              DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Background"], "UInt")
              return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
            case WM_CTLCOLORSTATIC:
              DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
              DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Background"])
              if !this.ignoretextcolor
                return TextBackgroundBrush
          }
        }
        return DllCall("user32\CallWindowProc", "Ptr", WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
      }) ; Avoid fast-mode for subclassing.
      WindowProcOld := DllCall("user32\" SetWindowLong, "Ptr", this.Hwnd, "Int", GWL_WNDPROC, "Ptr", WindowProcNew, "Ptr")
      Init := True
    }

    super.show.call(this, opts)
  }

  ; **owner**: *bool* or *hwnd* or *taskbar*<br>
  ; **showIcon**: *bool*<br>
  ; **SysMenu**: *bool*<br>
  ; **AOT**: *bool*<br>
  ; **topBar**: *bool*<br>
  ; **resize**: *bool*<br>
  ; **maxBtn**: *bool*<br>
  ; **minBtn**: *bool*<br>
  ; **active**: *bool*<br>
  ; **disabled**: *bool* i think this removes the item from the alt tab menu<br>
  ; **theme**: *bool*<br>
  ; **tool**: *bool*<br>
  ; **ownDialogs**: *bool* - no idea what the use would be<br>
  ; **minSize**: { x: *int*, y: *int* }<br>
  ; **maxSize**: { x: *int*, y: *int* }<br>
  ; **clickThrough**: *bool*<br>
  ; **transparency**: *int*[range(*0*, *255*)]<br>
  setopts(opts) {
    this.opts := joinObjs(this.opts, opts)
    tr := ""
    if (opts.hasprop("clickthrough") and opts.clickthrough) and (opts.hasprop("aot") and opts.aot) {
      str .= "+owner " . WinExist("ahk_class Shell_TrayWnd") . " "
    } else {
      if (opts.hasprop("owner") and opts.owner !== 1 and opts.owner !== 0)
        if opts.owner == "taskbar"
          str .= "+Owner " . WinExist("ahk_class Shell_TrayWnd") . ' '
        else
          str .= "+Owner " . opts.owner . ' '
      else
        str .= ((opts.hasprop("showicon") and opts.showicon) ? "-" : "+") "Owner "
    }
    str .= ((opts.hasprop("SysMenu") and opts.SysMenu) ? "+" : "-") "SysMenu "
    str .= ((opts.hasprop("aot") and opts.aot) ? "+" : "-") "AlwaysOnTop "
    if opts.hasprop("clickthrough") and (!opts.hasprop("transparency"))
      opts.transparency := 255
    str .= ((opts.hasprop("topbar") and opts.topbar) ? "+" : "-") "Border "
    str .= ((opts.hasprop("topbar") and opts.topbar) ? "+" : "-") "Caption "
    str .= ((opts.hasprop("active") and opts.active) ? "+" : "-") "LastFound "
    str .= ((opts.hasprop("resize") and opts.resize) ? "+" : "-") "resize "
    str .= ((opts.hasprop("maxbtn") and opts.maxbtn) ? "+" : "-") "MaximizeBox "
    str .= ((opts.hasprop("minbtn") and opts.minbtn) ? "+" : "-") "MinimizeBox "
    str .= ((opts.hasprop("disabled") and opts.disabled) ? "+" : "-") "Disabled "
    str .= ((opts.hasprop("theme") and opts.theme) ? "+" : "-") "Theme "
    str .= ((opts.hasprop("tool") and opts.tool) ? "+" : "-") "ToolWindow "
    str .= ((opts.hasprop("owndialogs") and opts.owndialogs) ? "+" : "-") "OwnDialogs " ; ?
    str .= ((opts.hasprop("clickthrough") and opts.clickthrough) ? "+" : "-") "E0x20 "

    if (opts.hasprop("minsize") and opts.minsize) {
      str .= "MinSize" . (opts.hasprop("minsize") and opts.minsize).x . "x" . opts.minsize.y . ' '
    }
    if (opts.hasprop("maxsize") and opts.maxsize) {
      str .= "MaxSize" . (opts.hasprop("maxsize") and opts.maxsize).x . "x" . opts.maxsize.y . ' '
    }

    print("created new ui", str)
    this.opt(str)
    if (opts.hasprop("transparency"))
      WinSetTransparent(opts.transparency, this.Hwnd)
    return this
  }
}
