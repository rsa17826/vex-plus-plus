extends Control
# var lastarr = []
var alllevels
const defaultlevelcodespath = 'res://defaultcodes/2.txt'
func _ready() -> void:
  # fetchnewlevels()
  var file = FileAccess.open(defaultlevelcodespath, FileAccess.READ)
  var filetext
  if file:
    filetext = file.get_as_text()
    if !filetext:
      log.error('no text found in file')
      filetext = ''
  else:
    log.error('no file found')
    filetext = ''
  var reg = RegEx.new()
  reg.compile('(?<code>(?:-?[\\d+.]+,){6,}\\d+)')
  var codes = reg.search_all(filetext)
  var loadedcodes = []
  for code in codes:
    var codestr = code.get_string('code')
    if codestr in loadedcodes: continue
    loadedcodes.append(codestr)
  if !filetext:
    log.error('no codes found in file')
    return
  checkalllevelsforvalidity(loadedcodes)

const resize2rotatefalse = [4, 0, 3, 9, 10, 11, 13, 14, 15, 17, 18, 42, 45]
const resize1rotatefalse = [20, 24, 43, 16, 1, 2, 8]
const resize1rotatetrue = [22]
const resize0rotatefalse = [44, 26, 12, 5, 41, 28, 29, 30, 34, 35, 36, 38, 39, 40, 46]
const resize0rotatetrue = [27, 25, 23, 21, 19, 7, 6, 31, 33, 32]

const levelswitherrorspath = 'user://saves/levels with errors'

func writefile(path, text, asjson=true):
  log.pp(1)
  FileAccess.open(path, FileAccess.WRITE_READ).store_string(JSON.stringify(text) if asjson else text)

func checkislevelvalid(maincode):
  var code: Array = maincode.split(',')
  code = code.map(func(a):
    return int(a))
  if !arrget(code, 2):
    log.error('should never reach here', 'player', maincode.substr(0, 30))
    return false
  if !arrget(code, 2):
    log.error('should never reach here', 'goal', maincode.substr(0, 30))
    return false
  while len(code) > 3:
    if code[0] in resize1rotatetrue:
      if !arrget(code, 5): return false
    elif code[0] in resize2rotatefalse:
      if !arrget(code, 5): return false
    elif code[0] in resize1rotatefalse:
      if !arrget(code, 4): return false
    elif code[0] in resize0rotatefalse:
      if !arrget(code, 3): return false
    elif code[0] in resize0rotatetrue:
      if !arrget(code, 4): return false
    else:
      var arr = readfile(levelswitherrorspath)
      if !arr:
        arr = []
      arr.append(maincode)
      writefile(levelswitherrorspath, arr)
      return false
  return true
func readfile(path, asjson=true):
  log.pp(2)
  var file = FileAccess.open(path, FileAccess.READ)
  if !file:
    FileAccess.open(path, FileAccess.WRITE_READ).store_string('')
    return null
  return JSON.parse_string(file.get_as_text()) if asjson else file.get_as_text()

func checkalllevelsforvalidity(loadedcodes):
  var arr = readfile(levelswitherrorspath)
  if !arr:
    arr = []
  var arr2 = []
  if !arr2:
    arr2 = []
  for code in loadedcodes:
    if checkislevelvalid(code):
      arr2.append(code)
    else:
      arr.append(code)
  writefile(levelswitherrorspath, global.arr.unique(arr))
  writefile(levelswitherrorspath + '1', global.arr.unique(arr2))

func arrget(arr, count):
  var newarr = []
  for i in range(count):
    if arr.size() == 0: return null
    newarr.append(arr[0])
    arr.remove_at(0)
  # lastarr.append(newarr)
  return newarr
