#Requires AutoHotkey v2.0
#SingleInstance Force

#Include *i <AutoThemed>

try TraySetIcon("icon.ico")
SetWorkingDir(A_ScriptDir)
#Include *i <vars>

#Include <Misc>

#Include *i <betterui> ; betterui

#Include *i <textfind> ; FindText, setSpeed, doClick

; #Include *i <CMD> ; CMD - cmd.exe - broken?

blockNames := [
  "basic",
  "single spike",
  "10x spike",
  "updown",
  "downup",
  "water",
  "solar",
  "slope",
  "pushable box",
  "microwave",
  "locked box",
  "glass",
  "leftright",
  "falling",
  "bouncy",
  "spark counterClockwise",
  "spark clockwise",
  "inner level",
  "goal",
  "buzsaw",
  "bouncing buzsaw",
  "cannon",
  "checkpoint",
  "closing spikes",
  "Gravity Down Lever",
  "Gravity up Lever",
  "speed Up Lever",
  "growing buzsaw",
  "key",
  "light switch",
  "pole",
  "Pole Quadrant",
  "Pulley",
  "Quadrant",
  "Rotating Buzzsaw",
  "Scythe",
  "star",
  "death boundary",
  "block death boundary",
  "nowj",
  "falling spike",
  "portal",
]
b(a) {

  return "
  (
  

    {
    STR(x)FLOAT(0.0)
    STR(y)FLOAT(0.0)
    STR(w)FLOAT(1.00000004470348)
    STR(h)FLOAT(1.00000004470348)
    STR(r)FLOAT(0.0)
    STR(id)STR(basic)
    STR(options){
      STR(color)STR(#fff)
    }
  }

    )"
  .replace("STR(x)FLOAT(0.0)", "STR(x)FLOAT(" . a.x * 200 ")")
  .replace("STR(y)FLOAT(0.0)", "STR(y)FLOAT(" . a.y * 200 ")")
  .replace("STR(id)STR(basic)", "STR(id)STR(" . a.name ")")
}
_file := {}
opts := "
(
{
  STR(start)STR(hub)
  STR(author)STR()
  STR(description)STR()
  STR(version)INT(41)
  STR(stages){
  STR(hub){
    STR(color)INT(7)
    STR(changeSpeedOnSlopes)BOOL(false)
}
)"
for (j in Range(blockNames.Length)) {
  _file.%j% := {
    blocks: "
  (
  [
  {
    STR(x)FLOAT(200.0)
    STR(y)FLOAT(-75.0)
  }
 )"
  }
  opts .= "
  (
    STR(__NAME__){
    STR(color)INT(7)
    STR(changeSpeedOnSlopes)BOOL(false)
  }
)".replace("__NAME__", blockNames[j])

  for (i in Range(blockNames.Length)) {
    _file.%j%.blocks .= (b({
      x: i,
      y: 0,
      name: blockNames[1]
    }))
  }
  for (jj in Range(blockNames.Length)) {
    _file.%j%.blocks
    _file.%j%.blocks .= (b({
      x: jj + 1,
      y: 1,
      name: blockNames[jj]
    }))
    _file.%j%.blocks .= (b({
      x: jj + 1,
      y: 1,
      name: blockNames[j]
    }))
  }
  _file.%j%.blocks .= "]"
}
opts .= "
(

 }
}
 )"
f.write("options.sds", opts)
f.write("hub.sds", "
(
[
  {
    STR(x)FLOAT(100.0)
    STR(y)FLOAT(-75.0)
  }
)" .
  blockNames.map((a, i) {
    return "
  (

    {
    STR(x)FLOAT(0.0)
    STR(y)FLOAT(0.0)
    STR(w)FLOAT(1.00000004470348)
    STR(h)FLOAT(1.00000004470348)
    STR(r)FLOAT(0.0)
    STR(id)STR(inner level)
    STR(options){
      STR(color)STR(#fff)
      STR(level)STR(#fff)
    }
  }
    )"
    .replace("STR(x)FLOAT(0.0)", "STR(x)FLOAT(" . i * 100 ")")
    .replace("STR(level)STR(#fff)", "STR(level)STR(" . a ")")
  }).join("`n")
  ']'
)
for (ff in Range(blockNames.Length)) {
  f.write(blockNames[ff] ".sds", _file.%ff%.blocks)
}
