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
static func loadDataFromFile(p: String, ifUnset: Variant = null, progress=null) -> Variant:
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
static var slowRemainingData := ''
static var UNSET: String

const NUMREG = r"(?:nan|inf|-?\d+(?:\.\d+)?)"
const SEPREG = r"\s*,\s*"

static func loadData(d: String, progress=null) -> Variant:
  if not UNSET:
    UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"

  remainingData = d.strip_edges() if d else ""
  if not remainingData:
    return UNSET
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
  var getDataFind := func() -> String:
    var end = remainingData.find(")")
    var part = remainingData.substr(1, end - 1)
    remainingData = remainingData.substr(end + 1)
    return part
  # while UNSET in remainingData:
  #   UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"
  var _stack: Array

  while 1:
    if not remainingData:
      # log.warn(_stack, stack, 4)
      return _stack[len(_stack) - 1]
    # var getDataReg := func(reg: String, group:=0) -> String:
    #   var res = global.regMatch(remainingData, reg)
    #   if not res:
    #     breakpoint
    #     log.err(remainingData, 123123123, reg, stack)
    #     return UNSET
    #   remainingData = remainingData.substr(len(res[0]))
    #   # if len(remainingData) < 100:
    #   #   breakpoint
    #   #   log.err(remainingData)
    #   return res[group]
    # if not remainingData:
    #   log.err(remainingData, "current")
    #   breakpoint

    if global.starts_with(remainingData, ']') or global.starts_with(remainingData, '}'):
      remainingData = remainingData.substr(1)
      remainingData = remainingData.strip_edges()
      # log.pp("DADSADSA", remainingData)
      if not remainingData:
        # log.warn(_stack, stack, 1)
        # _stack.append(_stack[len(_stack) - 1])
        while len(_stack) >= 2:
          var thing1: Variant = _stack.pop_back()
          var lastItem = _stack[len(_stack) - 1]
          if lastItem == null:
            _stack[len(_stack) - 1] = thing1
          elif lastItem is Dictionary:
            for k: String in lastItem:
              if global.same(lastItem[k], UNSET):
                lastItem[k] = thing1
                break
          elif lastItem is Array:
            lastItem.append(thing1)
        # log.pp(_stack)
        return _stack[0]

      var dataToInsert: Variant = _stack.pop_back()
      var thingToPutDataIn: Variant = _stack.pop_back()
      # log.warn(thingToPutDataIn, dataToInsert)
      match typeof(thingToPutDataIn):
        TYPE_DICTIONARY:
          for k in thingToPutDataIn:
            if global.same(thingToPutDataIn[k], UNSET):
              thingToPutDataIn[k] = dataToInsert
              break
        TYPE_ARRAY:
          thingToPutDataIn.append(dataToInsert)

      _stack.append(thingToPutDataIn)
      # remainingData = remainingData
      # stack.append([remainingData, _stack])
      continue
    remainingData = remainingData.strip_edges()
    if not remainingData:
      log.err(remainingData, "current")
      breakpoint
    var type: String
    if global.starts_with(remainingData, "{"):
      type = "{"
    elif global.starts_with(remainingData, "["):
      type = "["
    else:
      type = remainingData.substr(0, remainingData.find("("))
    remainingData = remainingData.substr(len(type))
    # if type == UNSET:
    #   log.warn(remainingData)
    remainingData = remainingData.strip_edges()
    # log.pp("asdjhdash", type, remainingData)
    # log.pp(remainingData, type)
    var thisdata: Variant

    match type:
      "{":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append({})
      "INT":
        thisdata = getDataFind.call()
        thisdata = __int.call(thisdata)
      "FLOAT":
        thisdata = getDataFind.call()
        thisdata = __float.call(thisdata)
      "VEC2I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector2i(__int.call(thisdata[0]), __int.call(thisdata[1]))
      "VEC2":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector2(__float.call(thisdata[0]), __float.call(thisdata[1]))
      "VEC3I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector3i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]))
      "VEC3":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector3(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]))
      "COLOR":
        thisdata = (getDataFind.call().split(","))
        thisdata = Color(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2":
        thisdata = (getDataFind.call().split(","))
        thisdata = Rect2(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Rect2i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      "VEC4":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector4(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "VEC4I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector4i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      # "InputEventKey":
      #   thisdata = getDataReg.call(r"^\((" +
      #   NUMREG + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + r")\)", 1).split(",")
      #   var evt = InputEventKey.new()
      #   evt.set_keycode(int(thisdata[0]))
      #   evt.ctrl_pressed = thisdata[1] == "true"
      #   evt.alt_pressed = thisdata[2] == "true"
      #   evt.shift_pressed = thisdata[3] == "true"
      #   evt.meta_pressed = thisdata[4] == "true"
      #   thisdata = evt
      # "InputEventMouseButton":
      #   thisdata = getDataReg.call(r"^\((" +
      #   NUMREG + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + r")\)", 1).split(",")
      #   var evt = InputEventMouseButton.new()
      #   evt.set_button_index(int(thisdata[0]))
      #   evt.ctrl_pressed = thisdata[1] == "true"
      #   evt.alt_pressed = thisdata[2] == "true"
      #   evt.shift_pressed = thisdata[3] == "true"
      #   evt.meta_pressed = thisdata[4] == "true"
      #   thisdata = evt
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
        thisdata = thisdata.substr(1, thisdata.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        remainingData = remainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2)
      "STRNAME":
        thisdata = remainingData \
        .replace("\\\\", "ESCAPED" + UNSET) \
        .replace(r"\)", "PERIN" + UNSET) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
        thisdata = thisdata.substr(1, thisdata.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        remainingData = remainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2)
        thisdata = StringName(thisdata)
      "[":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append([])
      _:
        log.err("bad type", len(type), type, remainingData, 12312)
        breakpoint
        if type == UNSET:
          return UNSET
        return
    
    remainingData = remainingData.strip_edges()
    if !global.same(thisdata, UNSET):
      if len(_stack):
        var lastItem = _stack[len(_stack) - 1]
        if lastItem == null:
          _stack[len(_stack) - 1] = thisdata
        else:
          if lastItem is Dictionary:
            var innerDataFound := false
            for k in lastItem:
              if global.same(lastItem[k], UNSET):
                innerDataFound = true
                lastItem[k] = thisdata
                break
            if !innerDataFound:
              lastItem[thisdata] = UNSET
          elif lastItem is Array:
            lastItem.append(thisdata)
      else:
        # stack.append([remainingData, _stack])
        continue
        # # log.warn("no obj")
        # log.warn(out, stack, _stack, thisdata, 2)
        # return thisdata
    # log.pp(thisdata, out, remainingData, "_stack:", str(_stack))
    # if len(remainingData):
    # Push the current state back onto the stack for the next iteration
    # stack.append([remainingData, _stack])
    continue # ?

  return _stack[len(_stack) - 1]

# with prog bar
static func loadDataSlow(d: String, progress=null) -> Variant:
  if not UNSET:
    UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"

  slowRemainingData = d.strip_edges() if d else ""
  if not slowRemainingData:
    return UNSET
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
  var getDataFind := func() -> String:
    var end = slowRemainingData.find(")")
    var part = slowRemainingData.substr(1, end - 1)
    slowRemainingData = slowRemainingData.substr(end + 1)
    return part
  # while UNSET in slowRemainingData:
  #   UNSET = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"
  var maxProg = len(slowRemainingData)
  var i = 0
  var _stack: Array

  while 1:
    if progress:
      progress.call(maxProg - len(slowRemainingData), maxProg)
    if not slowRemainingData:
      # log.warn(_stack, stack, 4)
      return _stack[len(_stack) - 1]
    if progress and i % 800 == 0:
      await global.wait()
    i += 1
    # var getDataReg := func(reg: String, group:=0) -> String:
    #   var res = global.regMatch(slowRemainingData, reg)
    #   if not res:
    #     breakpoint
    #     log.err(slowRemainingData, 123123123, reg, stack)
    #     return UNSET
    #   slowRemainingData = slowRemainingData.substr(len(res[0]))
    #   # if len(remainingData) < 100:
    #   #   breakpoint
    #   #   log.err(remainingData)
    #   return res[group]
    # if not slowRemainingData:
    #   log.err(slowRemainingData, "current")
    #   breakpoint

    if global.starts_with(slowRemainingData, ']') or global.starts_with(slowRemainingData, '}'):
      slowRemainingData = slowRemainingData.substr(1).strip_edges()
      # log.pp("DADSADSA", remainingData)
      if not slowRemainingData:
        # log.warn(_stack, stack, 1)
        # _stack.append(_stack[len(_stack) - 1])
        while len(_stack) >= 2:
          var thing1: Variant = _stack.pop_back()
          var lastItem = _stack[len(_stack) - 1]
          if lastItem == null:
            _stack[len(_stack) - 1] = thing1
          elif lastItem is Dictionary:
            for k: String in lastItem:
              if global.same(lastItem[k], UNSET):
                lastItem[k] = thing1
                break
          elif lastItem is Array:
            lastItem.append(thing1)
        # log.pp(_stack)
        return _stack[0]

      var dataToInsert: Variant = _stack.pop_back()
      var thingToPutDataIn: Variant = _stack.pop_back()
      # log.warn(thingToPutDataIn, dataToInsert)
      match typeof(thingToPutDataIn):
        TYPE_DICTIONARY:
          for k in thingToPutDataIn:
            if global.same(thingToPutDataIn[k], UNSET):
              thingToPutDataIn[k] = dataToInsert
              break
        TYPE_ARRAY:
          thingToPutDataIn.append(dataToInsert)

      _stack.append(thingToPutDataIn)
      # remainingData = remainingData
      # stack.append([remainingData, _stack])
      continue
    slowRemainingData = slowRemainingData.strip_edges()
    if not slowRemainingData:
      log.err(slowRemainingData, "current")
      breakpoint
    var type: String
    if global.starts_with(slowRemainingData, "{"):
      type = "{"
    elif global.starts_with(slowRemainingData, "["):
      type = "["
    else:
      type = slowRemainingData.substr(0, slowRemainingData.find("("))
    slowRemainingData = slowRemainingData.substr(len(type))
    # if type == UNSET:
    #   log.warn(slowRemainingData)
    slowRemainingData = slowRemainingData.strip_edges()
    # log.pp("asdjhdash", type, remainingData)
    # log.pp(remainingData, type)
    var thisdata: Variant

    match type:
      "{":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append({})
      "INT":
        thisdata = getDataFind.call()
        thisdata = __int.call(thisdata)
      "FLOAT":
        thisdata = getDataFind.call()
        thisdata = __float.call(thisdata)
      "VEC2I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector2i(__int.call(thisdata[0]), __int.call(thisdata[1]))
      "VEC2":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector2(__float.call(thisdata[0]), __float.call(thisdata[1]))
      "VEC3I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector3i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]))
      "VEC3":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector3(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]))
      "COLOR":
        thisdata = (getDataFind.call().split(","))
        thisdata = Color(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2":
        thisdata = (getDataFind.call().split(","))
        thisdata = Rect2(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "RECT2I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Rect2i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      "VEC4":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector4(__float.call(thisdata[0]), __float.call(thisdata[1]), __float.call(thisdata[2]), __float.call(thisdata[3]))
      "VEC4I":
        thisdata = (getDataFind.call().split(","))
        thisdata = Vector4i(__int.call(thisdata[0]), __int.call(thisdata[1]), __int.call(thisdata[2]), __int.call(thisdata[3]))
      # "InputEventKey":
      #   thisdata = getDataReg.call(r"^\((" +
      #   NUMREG + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + r")\)", 1).split(",")
      #   var evt = InputEventKey.new()
      #   evt.set_keycode(int(thisdata[0]))
      #   evt.ctrl_pressed = thisdata[1] == "true"
      #   evt.alt_pressed = thisdata[2] == "true"
      #   evt.shift_pressed = thisdata[3] == "true"
      #   evt.meta_pressed = thisdata[4] == "true"
      #   thisdata = evt
      # "InputEventMouseButton":
      #   thisdata = getDataReg.call(r"^\((" +
      #   NUMREG + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + SEPREG +
      #   r"(?:true|false)" + r")\)", 1).split(",")
      #   var evt = InputEventMouseButton.new()
      #   evt.set_button_index(int(thisdata[0]))
      #   evt.ctrl_pressed = thisdata[1] == "true"
      #   evt.alt_pressed = thisdata[2] == "true"
      #   evt.shift_pressed = thisdata[3] == "true"
      #   evt.meta_pressed = thisdata[4] == "true"
      #   thisdata = evt
      "NULL":
        getDataFind.call()
        thisdata = null
      "BOOL":
        thisdata = getDataFind.call()
        # thisdata = getDataReg.call(r"\((true|false)\)", 1)
        thisdata = thisdata == "true"
      "STR":
        thisdata = slowRemainingData \
        .replace("\\\\", "ESCAPED" + UNSET) \
        .replace(r"\)", "PERIN" + UNSET) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
        thisdata = thisdata.substr(1, thisdata.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        slowRemainingData = slowRemainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2)
      "STRNAME":
        thisdata = slowRemainingData \
        .replace("\\\\", "ESCAPED" + UNSET) \
        .replace(r"\)", "PERIN" + UNSET) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
        thisdata = thisdata.substr(1, thisdata.find(")") - 1) # get the data from the start ( to the first real ), not escaped ), that were hid just above
        thisdata = thisdata.replace("ESCAPED" + UNSET, "\\\\").replace("PERIN" + UNSET, ")") # restore the hidden \ and )s
        slowRemainingData = slowRemainingData.substr(len(thisdata \
        .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
        ) + 2)
        thisdata = StringName(thisdata)
      "[":
        thisdata = UNSET
        # remainingData = remainingData.substr(1)
        _stack.append([])
      _:
        log.err("bad type", len(type), type, slowRemainingData, 12312)
        breakpoint
        if type == UNSET:
          return UNSET
        return
    
    slowRemainingData = slowRemainingData.strip_edges()
    if !global.same(thisdata, UNSET):
      if len(_stack):
        var lastItem = _stack[len(_stack) - 1]
        if lastItem == null:
          _stack[len(_stack) - 1] = thisdata
        else:
          if lastItem is Dictionary:
            var innerDataFound := false
            for k in lastItem:
              if global.same(lastItem[k], UNSET):
                innerDataFound = true
                lastItem[k] = thisdata
                break
            if !innerDataFound:
              lastItem[thisdata] = UNSET
          elif lastItem is Array:
            lastItem.append(thisdata)
      else:
        # stack.append([remainingData, _stack])
        continue
        # # log.warn("no obj")
        # log.warn(out, stack, _stack, thisdata, 2)
        # return thisdata
    continue # ?

  return _stack[len(_stack) - 1]

static func loadDataFromFileSlow(p: String, ifUnset: Variant = null, progress=null) -> Variant:
  var f := FileAccess.open(p, FileAccess.READ)
  if not f: return ifUnset
  var d: Variant = await loadDataSlow(f.get_as_text(), progress)
  return d if !global.same(d, UNSET) else ifUnset