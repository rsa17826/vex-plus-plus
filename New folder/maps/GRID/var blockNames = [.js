var blockNames = [
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
function b({ x, y, name }) {
  return `  {
    STR(x)FLOAT(0.0)
    STR(y)FLOAT(0.0)
    STR(w)FLOAT(1.00000004470348)
    STR(h)FLOAT(1.00000004470348)
    STR(r)FLOAT(0.0)
    STR(id)STR(basic)
    STR(options){
      STR(color)STR(#fff)
    }
  }`
    .replace("STR(x)FLOAT(0.0)", "STR(x)FLOAT(" + x * 200 + ")")
    .replace("STR(y)FLOAT(0.0)", "STR(y)FLOAT(" + y * 200 + ")")
    .replace("STR(id)STR(basic)", "STR(id)STR(" + name + ")")
}
var file = {}
var opts = `{
  STR(start)STR(hub)
  STR(author)STR()
  STR(description)STR()
  STR(version)INT(41)
  STR(stages){
    `
for (var j in blockNames) {
  j = Number(j)
  file[j] = { blocks: [] }
  opts += `STR(__NAME__){
      STR(color)INT(7)
      STR(changeSpeedOnSlopes)BOOL(false)
    }`.replace("__NAME__", blockNames[j])

  for (var i in blockNames) {
    i = Number(i)
    file[j].blocks.push(b({ x: i + 1, y: 0, name: blockNames[0] }))
  }
  for (var jj in blockNames) {
    file[j].blocks
    jj = Number(jj)
    file[j].blocks.push(b({ x: j + 1, y: 1, name: blockNames[j] }))
    file[j].blocks.push(b({ x: j + 1, y: 1, name: blockNames[jj] }))
  }
  file[j].blocks =
    `[
      {
        STR(x)FLOAT(0.0)
        STR(y)FLOAT(-200.0)
      }` +
    file[j].blocks.join("\n") +
    "]"
}
opts += ` }
}`
f.write("options.sds", opts)
for (var ff of file) {
  f.write(ff.name + ".sds", ff.blocks)
}
log(file)
