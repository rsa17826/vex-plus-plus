class_name Data

func _init() -> void:
  var data1 = string(
    {
      1: Vector2(
        1,
        1
      ),
      "2": 15.1,
      "3))\\\\\\)": [
      5,
      5.0,
      1
    ],
    "ASDASDDS": "enddata"
    }
  )
  log.pp(data1)
  # var data2 = parse(data1.strip_edges())
  # log.pp(parse(data1.strip_edges()))
  # log.pp(parse(data1.strip_edges()))
  # log.pp(parse(data1.strip_edges()))
  log.pp(parse(string("asda")))

func string(val: Variant, _level=0) -> String:
  var getIndent = func():
    var indent = ''
    for i in range(_level):
      indent += ' '
    indent += '\n'
    return indent

  match typeof(val):
    TYPE_INT:
      return "INT(" + str(val) + ")"
    TYPE_FLOAT:
      return "FLOAT(" + str(val) + ")"
    TYPE_VECTOR2I:
      return "VEC2I(" + str(val.x) + "," + str(val.y) + ")"
    TYPE_VECTOR2:
      return "VEC2(" + str(val.x) + "," + str(val.y) + ")"
    TYPE_STRING:
      return "STR(" + str(val).replace("\\", "\\\\").replace(")", r"\)") + ")"
    TYPE_BOOL:
      return "BOOL(" + str(val) + ")"
    TYPE_DICTIONARY:
      var data := ''
      _level += 1
      for inner in val:
        data += getIndent.call() + string(inner, _level) + string(val[inner], _level)
      _level -= 1
      return "DICT{" + data + "\n}"
    TYPE_ARRAY:
      var data := ''
      _level += 1
      for inner in val:
        data += getIndent.call() + string(inner, _level)
      _level -= 1
      return "ARR[" + data + "\n]"
  log.err(val, type_string(typeof(val)))
  return str(val)

var data = ''
var unset = ":::" + global.randstr(10, "qwertyuiopasdfghjklzxcvbnm1234567890") + ":::"

func parse(d=null, _stack:=[], out=null, getDictVal=false) -> Variant:
  if d: data = d.strip_edges()
  if not data:
    # log.warn(_stack)
    return out
  var getData = func(reg, group=0):
    var res = global.regMatch(data, reg)
    data = data.substr(len(res[0]))
    return res[group]
  if global.starts_with(data, ']') or global.starts_with(data, '}'):
    data = data.substr(1)
    data = data.strip_edges()
    # log.pp("DADSADSA", data)
    if not data:
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
    return parse(data, _stack, _stack[len(_stack) - 1], getDictVal)
  var type = getData.call(r"^[A-Z]+[\dA-Z]*")
  # log.pp(data, type)
  var thisdata
  match type:
    "DICT":
      thisdata = unset
      data = data.substr(1)
      out = {}
      _stack.append(out)
    "INT":
      thisdata = int(getData.call(r"^\((\d+(?:\.\d+)?)\)", 1))
    "FLOAT":
      thisdata = float(getData.call(r"^\((\d+(?:\.\d+)?)\)", 1))
    "VEC2I":
      thisdata = getData.call(r"^\((\d+(?:\.\d+)?,\d+(?:\.\d+)?)\)", 1)
      thisdata = Vector2(int(thisdata.split(",")[0]), int(thisdata.split(",")[1]))
    "VEC2":
      thisdata = getData.call(r"^\((\d+(?:\.\d+)?,\d+(?:\.\d+)?)\)", 1)
      thisdata = Vector2(float(thisdata.split(",")[0]), float(thisdata.split(",")[1]))
    "STR":
      thisdata = data \
      .replace("\\\\", "ESCAPED" + unset) \
      .replace(r"\)", "PERIN" + unset) # replace the escaped escapes, then replace the escaped )s with data not used in the saved data to let the regex detect the real ending )
      thisdata = global.regMatch(thisdata, r"\(([^)]+)\)")[1] # get the data from the start ( to the first real ), not escaped ), that were hid just above
      thisdata = thisdata.replace("ESCAPED" + unset, "\\").replace("PERIN" + unset, ")") # restore the hidden \ and )s
      data = data.substr(len(thisdata \
      .replace("\\", "\\\\").replace(")", r"\)") # re expand the replacements to make same length as the escaped chars would be
      ) + 2) # add 2 because the regex gets group 1 instead of 0, so the 2 is for the () aound the data
    "ARR":
      thisdata = unset
      out = []
      data = data.substr(1)
      _stack.append(out)
    _:
      return log.err(type, data)
  data = data.strip_edges()
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
      return thisdata
  # log.pp(thisdata, out, data, "_stack:", str(_stack))
  # if len(data):
  return parse(data, _stack, out, getDictVal)
  # return out
