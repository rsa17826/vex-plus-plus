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
static var prettyPrint = true
static func saveDataToFile(p: String, data: Variant) -> void:
  FileAccess.open(p, FileAccess.WRITE_READ).store_string(saveData(data))
static func loadDataFromFile(p: String, ifUnset: Variant = null) -> Variant:
  var f = FileAccess.open(p, FileAccess.READ)
  if not f: return ifUnset
  var d = loadData(f.get_as_text())
  return d if d else ifUnset

static func saveData(val: Variant, _level=0) -> String:
  # print("saveData", val)
  var getIndent = func(_level):
    if not prettyPrint: return ""
    var indent = '\n'
    for i in range(_level):
      indent += '  '
    return indent
  match typeof(val):
    TYPE_COLOR:
      return "COLOR" + str(val).replace(" ", '')
    TYPE_RECT2:
      return "RECT2(" + str(val.position[0]) + "," + str(val.position[1]) + "," + str(val.size[0]) + "," + str(val.size[1]) + ")"
    TYPE_RECT2I:
      return "RECT2I(" + str(val.position[0]) + "," + str(val.position[1]) + "," + str(val.size[0]) + "," + str(val.size[1]) + ")"
    TYPE_STRING_NAME:
      return "STRNAME(" + str(val).replace("\\", "\\\\").replace(")", r"\)") + ")"
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
      return "STR(" + str(val).replace("\\", "\\\\").replace(")", r"\)") + ")"
    TYPE_BOOL:
      return "BOOL(" + str(val) + ")"
    TYPE_NIL:
      return "NULL()"
    TYPE_DICTIONARY:
      var data := ''
      _level += 1
      var hasKey = false
      for inner in val:
        hasKey = true
        data += getIndent.call(_level) + saveData(inner, _level) + saveData(val[inner], _level)
      _level -= 1
      return "DICT{" + data + getIndent.call(_level) + "}" if hasKey else "DICT{" + data + "}"
    TYPE_ARRAY:
      var data := ''
      _level += 1
      var hasKey = false
      for inner in val:
        hasKey = true
        data += getIndent.call(_level) + saveData(inner, _level)
      _level -= 1
      return "ARR[" + data + getIndent.call(_level) + "]" if hasKey else "ARR[" + data + "]"
  log.err(val, type_string(typeof(val)))
  return str(val)

static var remainingData = ''
static var unset = ":::" + randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"
static func randstr(length=10, fromchars="qwertyuiopasdfghjklzxcvbnm1234567890~!@#$%^&*()_+-={ }[']\\|;:\",.<>/?`"):
  var s = ''
  for i in range(length):
    s += (fromchars[randfrom(0, len(fromchars) - 1)])
  return s

static func randfrom(min: float, max: float) -> float:
  # if global.same(max, "unset"):
  #   return min[randfrom(0, len(min) - 1)]
  return int(randf() * (max - min + 1) + min)

const NUMREG = r"(?:nan|inf|-?\d+(?:\.\d+)?)"
const SEPREG = r"\s*,\s*"

static func loadData(d=null, _stack:=[], out=null, getDictVal=false) -> Variant:
  if d: remainingData = d.strip_edges()
  while unset in remainingData:
    unset = ":::" + randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"

  if not remainingData:
    # log.warn(_stack)
    return out
  var getData = func(reg, group=0):
    var res = global.regMatch(remainingData, reg)
    remainingData = remainingData.substr(len(res[0]))
    return res[group]
  if global.starts_with(remainingData, ']') or global.starts_with(remainingData, '}'):
    remainingData = remainingData.substr(1)
    remainingData = remainingData.strip_edges()
    # log.pp("DADSADSA", remainingData)
    if not remainingData:
      # log.warn(_stack)
      return out
    var dataToInsert = _stack.pop_back()
    var thingToPutDataIn = _stack.pop_back()
    # log.warn(thingToPutDataIn, dataToInsert)
    match typeof(thingToPutDataIn):
      TYPE_DICTIONARY:
        for k in thingToPutDataIn:
          if global.same(thingToPutDataIn[k], unset):
            thingToPutDataIn[k] = dataToInsert
            break
      TYPE_ARRAY:
        thingToPutDataIn.append(dataToInsert)
    _stack.append(thingToPutDataIn)
    # remainingData = remainingData.strip_edges()
    return loadData(remainingData, _stack, _stack[len(_stack) - 1], getDictVal)
  var type = getData.call(r"^[A-Z]+[\dA-Z]*")
  remainingData = remainingData.strip_edges()
  # log.pp(remainingData, type)
  var thisdata
  var __int = func(num):
    if num == "inf":
      return INF
    if num == "nan":
      return NAN
    return int(num)
  var __float = func(num):
    if num == "inf":
      return INF
    if num == "nan":
      return NAN
    return float(num)
  match type:
    "DICT":
      thisdata = unset
      remainingData = remainingData.substr(1)
      out = {}
      _stack.append(out)
    "INT":
      thisdata = __int.call(getData.call(r"^\((" + NUMREG + r")\)", 1))
    "FLOAT":
      thisdata = __float.call(getData.call(r"^\((" + NUMREG + r")\)", 1))
    "VEC2I":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector2i(__int.call(thisdata.split(",")[0]), __int.call(thisdata.split(",")[1]))
    "VEC2":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector2(__float.call(thisdata.split(",")[0]), __float.call(thisdata.split(",")[1]))
    "VEC3I":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector3i(__int.call(thisdata.split(",")[0]), __int.call(thisdata.split(",")[1]), __int.call(thisdata.split(",")[2]))
    "VEC3":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector3(__float.call(thisdata.split(",")[0]), __float.call(thisdata.split(",")[1]), __float.call(thisdata.split(",")[2]))
    "COLOR":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Color(__float.call(thisdata.split(",")[0]), __float.call(thisdata.split(",")[1]), __float.call(thisdata.split(",")[2]), __float.call(thisdata.split(",")[3]))
    "RECT2":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Rect2(__float.call(thisdata.split(",")[0]), __float.call(thisdata.split(",")[1]), __float.call(thisdata.split(",")[2]), __float.call(thisdata.split(",")[3]))
    "RECT2I":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Rect2i(__int.call(thisdata.split(",")[0]), __int.call(thisdata.split(",")[1]), __int.call(thisdata.split(",")[2]), __int.call(thisdata.split(",")[3]))
    "VEC4":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector4(__float.call(thisdata.split(",")[0]), __float.call(thisdata.split(",")[1]), __float.call(thisdata.split(",")[2]), __float.call(thisdata.split(",")[3]))
    "VEC4I":
      thisdata = getData.call(r"^\((" + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + SEPREG + NUMREG + r")\)", 1)
      thisdata = Vector4i(__int.call(thisdata.split(",")[0]), __int.call(thisdata.split(",")[1]), __int.call(thisdata.split(",")[2]), __int.call(thisdata.split(",")[3]))
    "NULL":
      getData.call(r"\(\)")
      thisdata = null
    "BOOL":
      thisdata = getData.call(r"\((true|false)\)", 1)
      thisdata = thisdata == "true"
    "STR":
      thisdata = remainingData \
      .replace("\\\\", "ESCAPED" + unset) \
      .replace(r"\)", "PERIN" + unset) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
      thisdata = global.regMatch(thisdata, r"\(([^)]+)\)")[1] # get the data from the start ( to the first real ), not escaped ), that were hid just above
      thisdata = thisdata.replace("ESCAPED" + unset, "\\").replace("PERIN" + unset, ")") # restore the hidden \ and )s
      remainingData = remainingData.substr(len(thisdata \
      .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
      ) + 2) # add 2 because the regex gets group 1 instead of 0, so the 2 is for the () aound the data
    "STRNAME":
      thisdata = remainingData \
      .replace("\\\\", "ESCAPED" + unset) \
      .replace(r"\)", "PERIN" + unset) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
      thisdata = global.regMatch(thisdata, r"\(([^)]+)\)")[1] # get the data from the start ( to the first real ), not escaped ), that were hid just above
      thisdata = thisdata.replace("ESCAPED" + unset, "\\").replace("PERIN" + unset, ")") # restore the hidden \ and )s
      remainingData = remainingData.substr(len(thisdata \
      .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
      ) + 2) # add 2 because the regex gets group 1 instead of 0, so the 2 is for the () aound the data
      thisdata = StringName(thisdata)
    "ARR":
      thisdata = unset
      out = []
      remainingData = remainingData.substr(1)
      _stack.append(out)
    _:
      return log.err(type, remainingData)
  remainingData = remainingData.strip_edges()
  if !global.same(thisdata, unset):
    if len(_stack):
      match typeof(_stack[len(_stack) - 1]):
        TYPE_NIL:
          out = thisdata
        TYPE_DICTIONARY:
          var innerDataFound = false
          for k in out:
            if global.same(out[k], unset):
              innerDataFound = true
              out[k] = thisdata
              break
          if !innerDataFound:
            out[thisdata] = unset
        TYPE_ARRAY:
          out.append(thisdata)
    else:
      # log.warn("no obj")
      return thisdata
  # log.pp(thisdata, out, remainingData, "_stack:", str(_stack))
  # if len(remainingData):
  return loadData(remainingData, _stack, out, getDictVal)
  # return out
