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
  FileAccess.open(p, FileAccess.WRITE_READ).store_string(saveData(data))
static func loadDataFromFile(p: String, ifUnset: Variant = null) -> Variant:
  var f := FileAccess.open(p, FileAccess.READ)
  if not f: return ifUnset
  var d: Variant = loadData(f.get_as_text())
  return d if !global.same(d, UNSET) else ifUnset

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
static var UNSET: String

const NUMREG = r"(?:nan|inf|-?\d+(?:\.\d+)?)"
const SEPREG = r"\s*,\s*"

static func loadData(d: String) -> Variant:
  UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"
  var stack := []
  remainingData = d.strip_edges() if d else ""
  if not remainingData:
    return UNSET
  while UNSET in remainingData:
    UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"
  # Initialize the stack with the initial state
  stack.append({"remainingData": remainingData, "_stack": []})
  var _stack: Array
  while stack.size() > 0:
    # log.pp(stack)
    var current: Dictionary = stack.pop_back()
    remainingData = current["remainingData"]
    _stack = current["_stack"]

    if not remainingData:
      # log.warn(_stack, stack, 4)
      return _stack[len(_stack) - 1]

    var getDataReg := func(reg: String, group:=0) -> String:
      var res = global.regMatch(remainingData, reg)
      if not res:
        log.pp(remainingData)
        breakpoint
      remainingData = remainingData.substr(len(res[0]))
      return res[group]
    var getDataFind := func() -> String:
      var end = remainingData.find(")")
      var part = remainingData.substr(1, end - 1)
      remainingData = remainingData.substr(end + 1)
      return part

    if global.starts_with(remainingData, ']') or global.starts_with(remainingData, '}'):
      remainingData = remainingData.substr(1)
      remainingData = remainingData.strip_edges()
      # log.pp("DADSADSA", remainingData)
      if not remainingData:
        # log.warn(_stack, stack, 1)
        # _stack.append(_stack[len(_stack) - 1])
        while len(_stack) >= 2:
          var thing1: Variant = _stack.pop_back()
          if len(_stack):
            match typeof(_stack[len(_stack) - 1]):
              TYPE_NIL:
                _stack[len(_stack) - 1] = thing1
              TYPE_DICTIONARY:
                for k: String in _stack[len(_stack) - 1]:
                  if global.same(_stack[len(_stack) - 1][k], UNSET):
                    _stack[len(_stack) - 1][k] = thing1
                    break
              TYPE_ARRAY:
                _stack[len(_stack) - 1].append(thing1)
          else:
            stack.append({"remainingData": remainingData, "_stack": _stack})
            continue
        # log.pp(_stack)
        return _stack[0]

      var dataToInsert: Variant = _stack.pop_back()
      var thingToPutDataIn: Variant = _stack.pop_back()
      # log.warn(thingToPutDataIn, dataToInsert)
      match typeof(thingToPutDataIn):
        TYPE_DICTIONARY:
          for k: String in thingToPutDataIn:
            if global.same(thingToPutDataIn[k], UNSET):
              thingToPutDataIn[k] = dataToInsert
              break
        TYPE_ARRAY:
          thingToPutDataIn.append(dataToInsert)

      _stack.append(thingToPutDataIn)
      # remainingData = remainingData.strip_edges()
      stack.append({"remainingData": remainingData, "_stack": _stack})
      continue

    var type: String = getDataReg.call(r"^[A-Za-z]+[\dA-Za-z]*|\[|\{")
    remainingData = remainingData.strip_edges()
    # log.pp("asdjhdash", type, remainingData)
    # log.pp(remainingData, type)
    var thisdata: Variant

    var __int := func(num: Variant) -> Variant:
      if num == "inf":
        return INF
      if num == "nan":
        return NAN
      return int(num)

    var __float := func(num: Variant) -> float:
      if num == "inf":
        return INF
      if num == "nan":
        return NAN
      return float(num)
  
    match type:
      "{":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append({})
      "INT":
        thisdata = getDataFind.call()
        thisdata = __int.call(thisdata.strip_edges())
      "FLOAT":
        thisdata = getDataFind.call()
        thisdata = __float.call(thisdata.strip_edges())
      "VEC2I":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector2i(__int.call(thisdata[0]), __int.call(thisdata[1]))
      "VEC2":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector2(__float.call(thisdata[0]), __float.call(thisdata[1]))
      "VEC3I":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector3i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]))
      "VEC3":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector3(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]))
      "COLOR":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Color(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Rect2(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2I":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Rect2i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      "VEC4":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector4(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "VEC4I":
        thisdata = (getDataFind.call().split(",") as Array).map(func(e): return e.strip_edges())
        thisdata = Vector4i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      "InputEventKey":
        thisdata = getDataReg.call(r"^\((" +
        NUMREG + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + r")\)", 1).split(",")
        var evt = InputEventKey.new()
        evt.set_keycode(int(thisdata[0]))
        evt.ctrl_pressed = thisdata[1] == "true"
        evt.alt_pressed = thisdata[2] == "true"
        evt.shift_pressed = thisdata[3] == "true"
        evt.meta_pressed = thisdata[4] == "true"
        thisdata = evt
      "InputEventMouseButton":
        thisdata = getDataReg.call(r"^\((" +
        NUMREG + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + SEPREG +
        r"(?:true|false)" + r")\)", 1).split(",")
        var evt = InputEventMouseButton.new()
        evt.set_button_index(int(thisdata[0]))
        evt.ctrl_pressed = thisdata[1] == "true"
        evt.alt_pressed = thisdata[2] == "true"
        evt.shift_pressed = thisdata[3] == "true"
        evt.meta_pressed = thisdata[4] == "true"
        thisdata = evt
      "NULL":
        getDataFind.call()
        thisdata = null
      "BOOL":
        thisdata = getDataFind.call()
        # thisdata = getDataReg.call(r"\((true|false)\)", 1)
        thisdata = thisdata == "true"
      "STR":
        thisdata = remainingData \
        .replace("\\\\", "ESCAPED" + UNSET) \
        .replace(r"\)", "PERIN" + UNSET) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
        # thisdata = getDataFind.call()
        thisdata = remainingData.substr(1, remainingData.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        # log.pp(thisdata, "thisdata", len(thisdata))
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        remainingData = remainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2) # add 2 because the regex gets group 1 instead of 0, so the 2 is for the () aound the data
      "STRNAME":
        thisdata = remainingData \
        .replace("\\\\", "ESCAPED" + UNSET) \
        .replace(r"\)", "PERIN" + UNSET) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
        # thisdata = getDataFind.call()
        thisdata = remainingData.substr(1, remainingData.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        # thisdata = global.regMatch(thisdata, r"\(([^)]*)\)")[1] # get the data from the start ( to the first real ), not escaped ), that were hid just above
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        remainingData = remainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2) # add 2 because the regex gets group 1 instead of 0, so the 2 is for the () aound the data
        thisdata = StringName(thisdata)
      "[":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append([])
      _:
        breakpoint
        return log.err(type, remainingData)

    remainingData = remainingData.strip_edges()
    if !global.same(thisdata, UNSET):
      if len(_stack):
        match typeof(_stack[len(_stack) - 1]):
          TYPE_NIL:
            _stack[len(_stack) - 1] = thisdata
          TYPE_DICTIONARY:
            var innerDataFound := false
            for k: String in _stack[len(_stack) - 1]:
              if global.same(_stack[len(_stack) - 1][k], UNSET):
                innerDataFound = true
                _stack[len(_stack) - 1][k] = thisdata
                break
            if !innerDataFound:
              _stack[len(_stack) - 1][thisdata] = UNSET
          TYPE_ARRAY:
            _stack[len(_stack) - 1].append(thisdata)
      else:
        stack.append({"remainingData": remainingData, "_stack": _stack})
        continue
        # # log.warn("no obj")
        # log.warn(out, stack, _stack, thisdata, 2)
        # return thisdata
    # log.pp(thisdata, out, remainingData, "_stack:", str(_stack))
    # if len(remainingData):
    # Push the current state back onto the stack for the next iteration
    stack.append({"remainingData": remainingData, "_stack": _stack})

  return _stack[len(_stack) - 1]
