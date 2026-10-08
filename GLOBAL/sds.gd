class_name sds
# SimpleDataStorage

# func _init() -> void:
#   var startData = {
#     1: Vector2(
#       1,
#       1
#     ),
#     "2": 15.1,
#     "3))\\\\\\)": [
#       5,
#       5.0,
#       1,
#       Vector3i(
#         INF,
#         1, NAN
#       ),
#       null,
#       true,
#       false,
#       INF,
#       NAN
#     ],
#     "ASDASDDS": "enddata"
#   }
#   var data1 = saveData(startData)
#   log.pp(startData, data1)
#   log.pp(loadData(data1))
static var prettyPrint: bool = true
static func saveDataToFile(p: String, data: Variant) -> void:
  var file := FileAccess.open(p, FileAccess.WRITE_READ)
  if file:
    file.store_string(saveData(data).strip_edges())
  else:
    log.err("failed to save file ", p)

# fix recursion
static func saveData(val: Variant, _level:=0) -> String:
  # print("saveData", val)
  var getIndent := func(level: int) -> String:
    if not prettyPrint: return ""
    var indent := '\n'
    for i in range(level):
      indent += '  '
    return indent
  if val is InputEventKey:
    return "InputEventKey(" + str(val.physical_keycode) + "," + str(val.ctrl_pressed) + "," + str(val.alt_pressed) + "," + str(val.shift_pressed) + "," + str(val.meta_pressed) + ")"
  elif val is InputEventMouseButton:
    return "InputEventMouseButton(" + str(val.button_index) + "," + str(val.ctrl_pressed) + "," + str(val.alt_pressed) + "," + str(val.shift_pressed) + "," + str(val.meta_pressed) + ")"
  else:
    match typeof(val):
      TYPE_COLOR:
        return "COLOR" + str(val).replace(" ", '')
      TYPE_RECT2:
        return "RECT2(" + str(val.position[0]) + "," + str(val.position[1]) + "," + str(val.size[0]) + "," + str(val.size[1]) + ")"
      TYPE_RECT2I:
        return "RECT2I(" + str(val.position[0]) + "," + str(val.position[1]) + "," + str(val.size[0]) + "," + str(val.size[1]) + ")"
      TYPE_STRING_NAME:
        return "STRNAME(" + str(val).replace("\\", "\\\\").replace(")", "\\)") + ")"
      TYPE_VECTOR4:
        return "VEC4" + str(val).replace(" ", '')
      TYPE_VECTOR4I:
        return "VEC4I" + str(val).replace(" ", '')
      TYPE_INT:
        return "INT(" + str(val) + ")"
      TYPE_FLOAT:
        return "FLOAT(" + str(val) + ")"
      TYPE_VECTOR2:
        return "VEC2(" + str(val.x) + "," + str(val.y) + ")"
      TYPE_VECTOR2I:
        return "VEC2I(" + str(val.x) + "," + str(val.y) + ")"
      TYPE_VECTOR3:
        return "VEC3(" + str(val.x) + "," + str(val.y) + "," + str(val.z) + ")"
      TYPE_VECTOR3I:
        return "VEC3I(" + str(val.x) + "," + str(val.y) + "," + str(val.z) + ")"
      TYPE_STRING:
        return "STR(" + str(val).replace("\\", "\\\\").replace(")", "\\)") + ")"
      TYPE_BOOL:
        return "BOOL(" + str(val) + ")"
      TYPE_NIL:
        return "NULL()"
      TYPE_DICTIONARY:
        var data := ''
        _level += 1
        var hasKey := false
        for inner: Variant in val:
          hasKey = true
          data += getIndent.call(_level) + saveData(inner, _level) + saveData(val[inner], _level)
        _level -= 1
        return "{" + data + getIndent.call(_level) + "}" if hasKey else "{" + data + "}"
      TYPE_ARRAY:
        var data := ''
        _level += 1
        var hasKey := false
        for inner: Variant in val:
          hasKey = true
          data += getIndent.call(_level) + saveData(inner, _level)
        _level -= 1
        return "[" + data + getIndent.call(_level) + "]" if hasKey else "[" + data + "]"
  log.err(val, type_string(typeof(val)))
  return str(val)

static var remainingData := ''
static var RemainingData := []
static var UNSET: String

const NUMREG = r"(?:nan|inf|-?\d+(?:\.\d+)?)"
const SEPREG = r"\s*,\s*"

static func loadDataFromFile(p: String, ifUnset: Variant = null) -> Variant:
  var f := FileAccess.open(p, FileAccess.READ)
  if not f: return ifUnset
  var d: Variant = loadData(f.get_as_text())
  return d if !global.same(d, UNSET) else ifUnset

static func _num(s: String) -> float:
  match s:
    "inf": return INF
    "-inf": return -INF
    "nan": return NAN
  return s.to_float()

static func _int(s: String) -> Variant:
  match s:
    "inf": return INF
    "-inf": return -INF
    "nan": return NAN
  return s.to_int()

# pos is just after the "(". returns [string, posAfterClosingParen]
static func _readStr(d: String, pos: int) -> Array:
  var end := d.find(")", pos)
  var slice := d.substr(pos, end - pos)
  if not slice.contains("\\"):
    return [slice, end + 1]
  # slow path: single left-to-right unescape (\x -> x)
  var out := ""
  var i := pos
  var runStart := pos
  while true:
    var c := d.unicode_at(i)
    if c == 92: # backslash
      out += d.substr(runStart, i - runStart)
      out += d[i + 1]
      i += 2
      runStart = i
    elif c == 41: # )
      out += d.substr(runStart, i - runStart)
      return [out, i + 1]
    else:
      i += 1
  return []

static func loadData(d: String) -> Variant:
  if not UNSET:
    UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"

  var n := d.length()
  var pos := 0
  var root: Variant = UNSET
  var stack: Array = [] # frames: [container, pendingKey, hasPendingKey]

  while true:
    while pos < n and d.unicode_at(pos) <= 32:
      pos += 1
    if pos >= n: break

    var c := d.unicode_at(pos)
    var value: Variant

    if c == 123 or c == 91: # { [
      stack.append([ {} if c == 123 else [], null, false])
      pos += 1
      continue
    elif c == 125 or c == 93: # } ]
      pos += 1
      value = stack.pop_back()[0] # ERROR here if closer with no opener
    else:
      var open := d.find("(", pos)
      var tag := d.substr(pos, open - pos)
      pos = open + 1
      if tag == "STR" or tag == "STRNAME":
        var r := _readStr(d, pos)
        pos = r[1]
        value = r[0] if tag == "STR" else StringName(r[0])
      else:
        var close := d.find(")", pos)
        var body := d.substr(pos, close - pos)
        pos = close + 1
        match tag:
          "INT": value = _int(body)
          "FLOAT": value = _num(body)
          "BOOL": value = body == "true"
          "NULL": value = null
          "VEC2":
            var f := body.split_floats(",")
            value = Vector2(f[0], f[1])
          "VEC3":
            var f := body.split_floats(",")
            value = Vector3(f[0], f[1], f[2])
          "VEC4":
            var f := body.split_floats(",")
            value = Vector4(f[0], f[1], f[2], f[3])
          "COLOR":
            var f := body.split_floats(",")
            value = Color(f[0], f[1], f[2], f[3])
          "RECT2":
            var f := body.split_floats(",")
            value = Rect2(f[0], f[1], f[2], f[3])
          "VEC2I":
            var s := body.split(",")
            value = Vector2i(s[0].to_int(), s[1].to_int())
          "VEC3I":
            var s := body.split(",")
            value = Vector3i(s[0].to_int(), s[1].to_int(), s[2].to_int())
          "VEC4I":
            var s := body.split(",")
            value = Vector4i(s[0].to_int(), s[1].to_int(), s[2].to_int(), s[3].to_int())
          "RECT2I":
            var s := body.split(",")
            value = Rect2i(s[0].to_int(), s[1].to_int(), s[2].to_int(), s[3].to_int())
          _:
            log.err("bad type", tag, d.substr(pos - len(tag) - 1, 50))
            breakpoint
            return UNSET

    if stack.is_empty():
      root = value
      continue

    var fr: Array = stack[-1]
    if fr[0] is Array:
      fr[0].append(value)
    elif fr[2]:
      fr[0][fr[1]] = value
      fr[2] = false
    else:
      fr[1] = value
      fr[2] = true

  return root
