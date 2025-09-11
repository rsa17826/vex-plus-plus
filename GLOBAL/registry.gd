class_name registry

static func readFile(p: String, key: String) -> Variant:
  var val = listFiles(p)
  return val[key] if key in val else null

static func fileExists(p: String, key: String) -> bool:
  return key in listFiles(p)
static func dirExists(p: String) -> bool:
  var cmd = [
    "-Command",
    "Get-ItemProperty -Path \"" + p + "\""
  ]

  var cmdout = []
  var err = OS.execute("powershell.exe", cmd, cmdout, true)
  # log.pp(cmdout)
  return err == 0

static func listFiles(p: String) -> Variant:
  p = format(p)
  if not validPath(p): return false
  var cmdout = []

  var cmd = [
    "-Command",
    "Get-ItemProperty -Path \"" + p + "\""
  ]

  var err = OS.execute("powershell.exe", cmd, cmdout, true)
  if err:
    log.err(cmd, cmdout, err)
  var vals = {}
  for thing in cmdout[0].split("\n"):
    thing = Array(global.regReplace(thing, "\r$|^\r", "").split(" : "))
    var k = thing.pop_front().strip_edges()
    var v = ' : '.join(thing)
    if not k and not v: continue
    vals[k] = v
    # log.pp(k, v)
  return vals

static func makeDir(p: String):
  p = format(p)
  if not validPath(p): return false
  var cmdout = []
  var cmd = [
    "-Command",
    "New-Item -Path \"" + p + "\" -force"
  ]
  log.warn('makeDir', cmd)
  var err = OS.execute("powershell.exe", cmd, cmdout, true)
  if err:
    printt(cmd[1], cmdout[0], err)
  return err

static func setFile(p: String, key: String, val: String):
  p = format(p)
  if not validPath(p): return false
  key = format(key)
  val = format(val)
  var cmdout = []
  var cmd = [
    "-Command",
    "New-ItemProperty -Path \"" + p + "\"" + \
    " -Name \"" + key + "\" -Value \"" + val + "\" -PropertyType String -force"
  ]

  log.warn('setFile', cmd)

  var err = OS.execute("powershell.exe", cmd, cmdout, true)
  if err:
    printt(cmd[1], cmdout[0], err)
  return err

static func format(thing: String):
  thing = thing.replace("\\\\", "\\")
  # thing = thing.replace("`", "``")
  thing = thing.replace(" ", "` ")
  # thing = thing.replace('"', "`\"")
  return thing

static func validPath(p: String) -> bool:
  if global.starts_with(p, "HKCU:") \
  or global.starts_with(p, "HKLM:") \
  :
    return true
  log.err("Invalid path: ", p)
  return false
