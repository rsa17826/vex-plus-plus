#Requires AutoHotkey v2.0
#SingleInstance Force

#Include *i <AutoThemed>

try TraySetIcon("icon.ico")
SetWorkingDir(A_ScriptDir)
#Include *i <vars>

#Include <Misc>

#Include *i <betterui> ; betterui

; #Include *i <CMD> ; CMD - cmd.exe - broken?

data := {
  names: {},
  out: {},
  nots: {}
}
lines := f.read("./test.down").replace("`r", "").split("`n")

names := lines.map((e) => e.RegExMatch("in (\w+) (.*)")).filter(e => e)
data.ret := ''
__ID__ := 0

for name in names {
  __ID__ += 1
  data.names.%name[1]% := __ID__
  switch (name[2]) {
    case "input.down":
      ret("
      (
        {
          __X__
          STR(y)FLOAT(-175.0)
          STR(w)FLOAT(1.0)
          STR(h)FLOAT(1.0)
          STR(r)FLOAT(270.0)
          STR(id)STR(input detector)
          STRNAME(options){
            STR(action)INT(2)
            STR(signalOutputId)INT(3)
          }
        }
      )")
    case "area":
      ret("
      (
        {
          __X__
          STR(y)FLOAT(-455.0)
          STR(w)FLOAT(0.1)
          STR(h)FLOAT(0.1)
          STR(r)FLOAT(0.0)
          STR(id)STR(area trigger)
          STRNAME(options){
            STR(signalOutputId)INT(__ID__)
            STR(color)STR(#fff)
          }
        }
      )".replace("__ID__", data.names.%name[1]%))
    default:
      MsgBox("Error" JSON.stringify(name))
  }
}

names := lines.map((e) => e.RegExMatch("out (\w+)")).filter(e => e)
__ID__ := 0
for name in names {
  __ID__ += 1
  data.out.%name[1]% := __ID__ + 100
  ret("
  (
    {
      __X__
      STR(y)FLOAT(-500.0)
      STR(w)FLOAT(1)
      STR(h)FLOAT(1)
      STR(r)FLOAT(0.0)
      STR(id)STR(path)
      STRNAME(options){
        STR(path)STR(0,100)
        STR(endReachedAction)INT(0)
        STR(startOnLoad)BOOL(false)
        STR(startWhenSignalReceived)BOOL(false)
        STR(startWhileSignalReceived)BOOL(true)
        STR(signalInputId)INT(__ID__)
        STR(restart)INT(0)
        STR(forwardSpeed)INT(150)
        STR(backwardSpeed)INT(150)
        STR(color)STR(#fff)
      }
    }
  )".replace("__ID__", data.out.%name[1]%))
}
names := lines.map((e) => e.RegExMatch("not (\w+)")).filter(e => e)
__ID__ := 0
for name in names {
  __ID__ += 1
  data.nots.%name[1]% := __ID__ + 200
  ret("
  (
    {
      __X__
      STR(y)FLOAT(-175.0)
      STR(w)FLOAT(1.0)
      STR(h)FLOAT(1.0)
      STR(r)FLOAT(0.0)
      STR(id)STR(not gate)
      STRNAME(options){
        STR(signalInputId)INT(__ID__)
        STR(signalOutputId)INT(__ID__)
        STR(color)STR(#fff)
      }
    }
  
  )".replace("__ID__", data.names.%name[1]%, , , 1).replace("__ID__", data.nots.%name[1]%, , , 1))
}
names := lines.map((e) => e.RegExMatch("if (.+):(.+)")).filter(e => e)
__ID__ := -100
for name in names {
  ; __ID__ += 1
  _path := []
  for thing in name[1].Trim().split(" ") {
    if thing = 'not' {
      _path.push("not")
    }
    else if thing = 'and' {
      _path.push("and")
    }
    else {
      if data.names.HasProp(thing.replace("!", '', , , 1)) {
        if thing.startsWith("!") {
          thing := thing.replace("!", '', , , 1)
          ret("
          (
            {
              __X__
              STR(y)FLOAT(-175.0)
              STR(w)FLOAT(1.0)
              STR(h)FLOAT(1.0)
              STR(r)FLOAT(0.0)
              STR(id)STR(not gate)
              STRNAME(options){
                STR(signalInputId)INT(__ID__)
                STR(signalOutputId)INT(__ID__) 
                STR(color)STR(#fff)
              }
            }
          )".replace("__ID__", data.names.%thing%, , , 1).replace("__ID__", data.nots.%thing%, , , 1))
          _path.push(data.nots.%thing%)
          ; _path.push([
          ;   data.names.%thing%,
          ;   data.nots.%thing%,
          ; ])
        } else {
          if data.names.HasProp(thing) {
            _path.push(data.names.%thing%)
          }
        }
      }
      else {
        MsgBox("error" JSON.stringify([
          thing,
          name[1]
        ]))
      }
    }
  }

  dataToRet := ''
  lastUsedId := __ID__
  while _path.length {
    thing := _path.RemoveAt(1)
    if thing = "and" {
      text := "
      (
        {
          __X__
          STR(y)FLOAT(25.0)
          STR(w)FLOAT(1.0)
          STR(h)FLOAT(1.0)
          STR(r)FLOAT(0.0)
          STR(id)STR(and gate)
          STRNAME(options){
            STR(signalAInputId)INT(__ID__) 
            STR(signalBInputId)INT(__ID__) 
            STR(signalOutputId)INT(__ID__)
            STR(color)STR(#fff)
          }
        }
      )"
      if dataToRet.includes("__ID__") {
        __ID__ += 1
        dataToRet := dataToRet.replace("__ID__", __ID__, , , 1)
        text := text.replace("__ID__", __ID__, , , 1)
        lastUsedId := __ID__
      }
      dataToRet .= (text.replace("__ID__", lastUsedId, , , 1).replace("__ID__", _path.RemoveAt(1), , , 1))
    } else {
      lastUsedId := thing
    }
  }
  names := name[2].Trim().split(" ")
  switch names[1] {
    case "send":
      dataToRet := dataToRet.replace("__ID__", data.out.%names[2]%, , , 1)
    default:
      if dataToRet.includes("__ID__") {
        __ID__ += 1
        dataToRet := dataToRet.replace("__ID__", __ID__, , , 1)
        lastUsedId := __ID__
      }
  }
  ret(dataToRet)
}

ret(a) {
  static x := 0
  while a.includes("__X__") {
    x += 50
    a := a.replace("__X__", "STR(x)FLOAT(" x ")", , , 1)
  }
  data.ret .= a '`n`n'
}
f.write("./out.sds", "
(
  [
    {
      STR(x)FLOAT(250.0)
      STR(y)FLOAT(-265.0)
    }
)" data.ret "]")
print(names)