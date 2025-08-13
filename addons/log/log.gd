@tool
extends Object
class_name log
# @noregex
static func assoc(opts: Dictionary, key: String, val):
  var _opts = opts.duplicate(true)
  _opts[key] = val
  return _opts

## prefix ###########################################################################

static func log_prefix(stack, colored:=false):
  if len(stack) > 1:
    var call_site = stack[1]
    var basename = call_site.source.get_file().get_basename()
    var line_num = str(call_site.get("line", 0))
    if call_site.source.match("*/addons/*"):
      return (getcolor("red") if colored else '') \
      +"<" + basename + ":" + line_num + ">: " \
      + (getcolor("end") if colored else '')
    else:
      return (getcolor("lightblue") if colored else '') \
      +"[" + basename + ":" + line_num + "]: " \
      + (getcolor("end") if colored else '')
  # print_rich(stack, "asdkahsdjkasdkasdkh")
  return (getcolor("magenta") if colored else '') \
  +"[???]: " \
  + (getcolor("end") if colored else '')
## colors ###########################################################################

# terminal safe colors:
# - black
# - red
# - green
# - yellow
# - blue
# - magenta
# - pink
# - purple
# - cyan
# - white
# - orange
# - gray

static var COLORS_TERMINAL_SAFE = {
  "SRC": "cyan",
  "ADDONS": "red",
  "TEST": "green",
  ",": "red",
  "(": "red",
  ")": "red",
  "[": "red",
  "]": "red",
  "{": "red",
  "}": "red",
  "&": "orange",
  "^": "orange",
  "dict_key": "magenta",
  "vector_value": "green",
  "class_name": "magenta",
  TYPE_NIL: "pink",
  TYPE_BOOL: "blue",
  TYPE_INT: "green",
  TYPE_FLOAT: "green",
  TYPE_STRING: "purple",
  TYPE_VECTOR2: "green",
  TYPE_VECTOR2I: "green",
  TYPE_RECT2: "green",
  TYPE_RECT2I: "green",
  TYPE_VECTOR3: "green",
  TYPE_VECTOR3I: "green",
  TYPE_TRANSFORM2D: "pink",
  TYPE_VECTOR4: "green",
  TYPE_VECTOR4I: "green",
  TYPE_PLANE: "pink",
  TYPE_QUATERNION: "pink",
  TYPE_AABB: "pink",
  TYPE_BASIS: "pink",
  TYPE_TRANSFORM3D: "pink",
  TYPE_PROJECTION: "pink",
  TYPE_COLOR: "pink",
  TYPE_STRING_NAME: "pink",
  TYPE_NODE_PATH: "pink",
  TYPE_RID: "pink",
  TYPE_OBJECT: "pink",
  TYPE_CALLABLE: "pink",
  TYPE_SIGNAL: "pink",
  TYPE_DICTIONARY: "pink",
  TYPE_ARRAY: "pink",
  TYPE_PACKED_BYTE_ARRAY: "pink",
  TYPE_PACKED_INT32_ARRAY: "pink",
  TYPE_PACKED_INT64_ARRAY: "pink",
  TYPE_PACKED_FLOAT32_ARRAY: "pink",
  TYPE_PACKED_FLOAT64_ARRAY: "pink",
  TYPE_PACKED_STRING_ARRAY: "pink",
  TYPE_PACKED_VECTOR2_ARRAY: "pink",
  TYPE_PACKED_VECTOR3_ARRAY: "pink",
  TYPE_PACKED_COLOR_ARRAY: "pink",
  TYPE_MAX: "pink",
  }

static var COLORS_PRETTY_V1 = {
  "SRC": "aquamarine",
  "ADDONS": "peru",
  "TEST": "green_yellow",
  ",": "crimson",
  "(": "crimson",
  ")": "crimson",
  "[": "crimson",
  "]": "crimson",
  "{": "crimson",
  "}": "crimson",
  "&": "coral",
  "^": "coral",
  "dict_key": "cadet_blue",
  "vector_value": "cornflower_blue",
  "class_name": "cadet_blue",
  TYPE_NIL: "pink",
  TYPE_BOOL: "pink",
  TYPE_INT: "cornflower_blue",
  TYPE_FLOAT: "cornflower_blue",
  TYPE_STRING: "dark_gray",
  TYPE_VECTOR2: "cornflower_blue",
  TYPE_VECTOR2I: "cornflower_blue",
  TYPE_RECT2: "cornflower_blue",
  TYPE_RECT2I: "cornflower_blue",
  TYPE_VECTOR3: "cornflower_blue",
  TYPE_VECTOR3I: "cornflower_blue",
  TYPE_TRANSFORM2D: "pink",
  TYPE_VECTOR4: "cornflower_blue",
  TYPE_VECTOR4I: "cornflower_blue",
  TYPE_PLANE: "pink",
  TYPE_QUATERNION: "pink",
  TYPE_AABB: "pink",
  TYPE_BASIS: "pink",
  TYPE_TRANSFORM3D: "pink",
  TYPE_PROJECTION: "pink",
  TYPE_COLOR: "pink",
  TYPE_STRING_NAME: "pink",
  TYPE_NODE_PATH: "pink",
  TYPE_RID: "pink",
  TYPE_OBJECT: "pink",
  TYPE_CALLABLE: "pink",
  TYPE_SIGNAL: "pink",
  TYPE_DICTIONARY: "pink",
  TYPE_ARRAY: "pink",
  TYPE_PACKED_BYTE_ARRAY: "pink",
  TYPE_PACKED_INT32_ARRAY: "pink",
  TYPE_PACKED_INT64_ARRAY: "pink",
  TYPE_PACKED_FLOAT32_ARRAY: "pink",
  TYPE_PACKED_FLOAT64_ARRAY: "pink",
  TYPE_PACKED_STRING_ARRAY: "pink",
  TYPE_PACKED_VECTOR2_ARRAY: "pink",
  TYPE_PACKED_VECTOR3_ARRAY: "pink",
  TYPE_PACKED_COLOR_ARRAY: "pink",
  TYPE_MAX: "pink",
  }

static func color_scheme(opts={}):
  return log.COLORS_TERMINAL_SAFE
  # return log.COLORS_PRETTY_V1

static func color_wrap(s, opts={}):
  var use_color = opts.get("use_color", true)
  var colors = opts.get("color_scheme", color_scheme(opts))

  if use_color:
    var color = opts.get("color")
    if not color:
      var s_type = opts.get("typeof", typeof(s))
      if s_type is String:
        # type overwrites
        color = colors.get(s_type)
      elif s_type is int and s_type == TYPE_STRING:
        # specific strings/punctuation
        var s_trimmed = s.strip_edges()
        if s_trimmed in colors:
          color = colors.get(s_trimmed)
        else:
          # fallback string color
          color = colors.get(s_type)
      else:
        # all other types
        color = colors.get(s_type)

    if color == null:
      log.pp("log.gd could not determine color for object: %s type: (%s)" % [str(s), typeof(s)])

    return "[color=%s]%s[/color]" % [color, s]
  else:
    return s

## to_pretty ###########################################################################

# TODO read from config
static var max_array_size = 2000

# returns the passed object as a decorated string
static func to_pretty(msg, opts={}):
  var newlines = opts.get("newlines", false)
  var use_color = opts.get("use_color", true)
  var indent_level = opts.get("indent_level", 0)
  if not "indent_level" in opts:
    opts.indent_level = indent_level

  var omit_vals_for_keys = ["layer_0/tile_data"]
  if not is_instance_valid(msg) and typeof(msg) == TYPE_OBJECT:
    return str(msg)
  if msg is InputEvent: # for InputEventMouseButton
    return type_string(typeof(msg))
  if msg is Object and msg.has_method("to_pretty"):
    return log.to_pretty(msg.to_pretty(), opts)
  elif msg is Object and msg.has_method("data"):
    return log.to_pretty(msg.data(), opts)
  elif msg is Object and msg.has_method("to_printable"):
    return log.to_pretty(msg.to_printable(), opts)
  elif msg is Array or msg is PackedStringArray:
    if len(msg) > max_array_size:
      pp("[DEBUG]: truncating large array. total:", len(msg))
      msg = msg.slice(0, max_array_size - 1)
      if newlines:
        msg.append("...")

    var tmp = log.color_wrap("[ ", opts)
    var last = len(msg) - 1
    for i in range(len(msg)):
      if newlines and last > 1:
        tmp += "\n\t"
      tmp += log.to_pretty(msg[i],
        # duplicate here to prevent indenting-per-msg
        # e.g. when printing an array of dictionaries
        opts.duplicate(true))
      if i != last:
        tmp += log.color_wrap(", ", opts)
    tmp += log.color_wrap(" ]", opts)
    return tmp
  elif msg is Dictionary:
    var tmp = log.color_wrap("{ ", opts)
    var ct = len(msg)
    var last
    if len(msg) > 0:
      last = msg.keys()[-1]
    for k in msg.keys():
      var val
      if k in omit_vals_for_keys:
        val = "..."
      else:
        opts.indent_level += 1
        val = log.to_pretty(msg[k], opts)
      if newlines and ct > 1:
        tmp += "\n\t" \
          + range(indent_level) \
          .map(func(_i): return "\t") \
            .reduce(func(a, b): return str(a, b), "")
      if use_color:
        var key = log.color_wrap('"%s"' % k, assoc(opts, "typeof", "dict_key"))
        tmp += "%s: %s" % [key, val]
      else:
        tmp += '"%s": %s' % [k, val]
      if last and str(k) != str(last):
        tmp += log.color_wrap(", ", opts)
    tmp += log.color_wrap(" }", opts)
    return tmp
  elif msg is String:
    if msg == "":
      return '""'
    # could check for supported tags in the string (see list above)
    # if msg.contains("["):
    #   msg = "<ACTUAL-TEXT-REPLACED>"
    return log.color_wrap(msg, opts)
  elif msg is StringName:
    return str(log.color_wrap("&", opts), '"%s"' % msg)
  elif msg is NodePath:
    return str(log.color_wrap("^", opts), '"%s"' % msg)
  elif msg is PackedScene:
    if msg.resource_path != "":
      return str(log.color_wrap("PackedScene:", opts), '%s' % msg.resource_path.get_file())
    else:
      return log.color_wrap(msg, opts)
  elif msg is Vector2 or msg is Vector2i:
    if use_color:
      return '%s%s%s%s%s' % [
        log.color_wrap("("),
        log.color_wrap(msg.x, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.y, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(")"),
        ]
    else:
      return '(%s,%s)' % [msg.x, msg.y]
  elif msg is Vector3 or msg is Vector3i:
    if use_color:
      return '%s%s%s%s%s%s%s' % [
        log.color_wrap("("),
        log.color_wrap(msg.x, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.y, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.z, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(")"),
        ]
    else:
      return '(%s,%s,%s)' % [msg.x, msg.y, msg.z]
  elif msg is Vector4 or msg is Vector4i:
    if use_color:
      return '%s%s%s%s%s%s%s%s%s' % [
        log.color_wrap("("),
        log.color_wrap(msg.x, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.y, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.z, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(","),
        log.color_wrap(msg.w, assoc(opts, "typeof", "vector_value")),
        log.color_wrap(")"),
        ]
    else:
      return '(%s,%s,%s,%s)' % [msg.x, msg.y, msg.z, msg.w]
  elif msg is RefCounted:
    if msg.get_script() != null and msg.get_script().resource_path != "":
      return log.color_wrap(msg.get_script().resource_path.get_file(), assoc(opts, "typeof", "class_name"))
    else:
      return log.color_wrap(msg.get_class(), assoc(opts, "typeof", "class_name"))
  else:
    return log.color_wrap(msg, opts)

## to_printable ###########################################################################

static func to_printable(msgs, opts={}):
  var newmsgs = []
  for msg in msgs:
    if typeof(msg) == typeof(""):
      newmsgs.append('"' + msg + '"')
    else:
      newmsgs.append(msg)
    newmsgs.append('-')
  msgs = newmsgs
  if len(msgs):
    msgs.remove_at(len(msgs) - 1)
  var stack = opts.get("stack", [])
  var pretty = opts.get("pretty", true)
  var newlines = opts.get("newlines", false)
  var m = ""
  if len(stack) > 0:
    var prefix = log.log_prefix(stack)
    var prefix_type
    if prefix != null and prefix[0] == "[":
      prefix_type = "SRC"
    elif prefix != null and prefix[0] == "{":
      prefix_type = "TEST"
    elif prefix != null and prefix[0] == "<":
      prefix_type = "ADDONS"
    if pretty:
      m += log.color_wrap(prefix, assoc(opts, "typeof", prefix_type))
    else:
      m += prefix
  for msg in msgs:
    # add a space between msgs
    if pretty:
      m += "%s " % log.to_pretty(msg, opts)
    else:
      m += "%s " % str(msg)
  return m.trim_suffix(" ")

static func getcolor(color: String):
  match color.to_lower():
    "end":
      return "[/color]"
    "nc":
      return "[/color]"
    _: return '[color=' + color + ']'

static func spaces(count: int) -> String:
  var s = ''
  for i in range(count):
    s += ' '
  return s

static func format_int_with_commas(number: Variant) -> String:
  var rest = '.' + str(number).split(".")[1] if number is float else ''
  number = str(int(floor(number)))
  for i in range(
    number.length() - (3
    ), (1 if number.begins_with('-') else 0), -3
  ):
    number = number.insert(i, ',')
  return number + rest

static func coloritem(item: Variant, tab: int = -2, isarrafterdict: bool = false, lastitemwasovermax: bool = false) -> String:
  var wrapat: int = 60
  tab += 2
  if not is_instance_valid(item) and str(item) == "<Freed Object>":
    return getcolor("red") + "<Freed Object>" + getcolor("end")
  if item == null:
    return getcolor("blue") + "null" + getcolor("end")
    
  if item is Callable:
    return getcolor("RED") + "<" + "function" + " " + getcolor("BOLD") + getcolor("BLUE") + str(item) + getcolor("END") + getcolor("RED") + ">" + getcolor("END")

  if item is StringName:
    return getcolor("darkorange") + "&\"" + getcolor("END") + getcolor("purple") + str(item) + getcolor("END") + getcolor("darkorange") + '"' + getcolor("END")
    # return getcolor("darkorange") + "&" + getcolor("END") + getcolor("purple") + '"' + str(item) + '"' + getcolor("END")
  if item is String:
    return getcolor("purple") + '"' + str(item) + '"' + getcolor("END")
  if item is int or item is float:
    return getcolor("GREEN") + format_int_with_commas(item) + getcolor("END")

  if item is Dictionary:
    if not item:
      return getcolor("orange") + "{ }" + getcolor("end")
    if len(JSON.stringify(item)) + tab < wrapat:
      var text = getcolor("orange") \
      # + "\n"
      + (spaces(tab) if not isarrafterdict else "") \
      +"{ " \
      + getcolor("END")
      var arr = []
      for k in item:
        var v = item[k]
        arr.append(getcolor("purple") + (
          '"' + k + '"' if k is String else coloritem(k, tab)
        ) + getcolor("END") + " " + getcolor("orange") + ": " + getcolor("END") + coloritem(v, tab, true))

      text += (getcolor("orange") + "," + getcolor("END") + " ").join(
        arr
      )
      text += getcolor("orange") \
      +" }" \
      + getcolor("END")
      return text
    else:
      var text = getcolor("orange") \
      # + "\n"
      + ("" if isarrafterdict else spaces(tab)) \
      +"{" \
      + getcolor("END") \
      +"\n  " + spaces(tab)
      var arr = []
      for k in item:
        var v = item[k]
        arr.append(getcolor("purple") + (
          coloritem(k, tab)
        ) + getcolor("END") + getcolor("orange") + ": " + getcolor("END") + coloritem(v, tab, true))
      text += (
        (getcolor("orange") + "," + getcolor("END") + "\n  " + spaces(tab)).join(
          arr
        )
      )
      text += " \n" \
      + getcolor("orange") \
      + spaces(tab) \
      +"}" \
      + getcolor("END")
      return text
  if item is Array or item is PackedStringArray:
    var prefix = ''
    var postfix = ''
    if item is PackedStringArray:
      prefix = getcolor("darkgreen") + "PackedStringArray(" + getcolor("END")
    if prefix: postfix = getcolor("darkgreen") + ")" + getcolor("END")
    if not item:
      return prefix + getcolor("orange") + "[ ]" + getcolor("end") + postfix
    if len(JSON.stringify(item)) + tab < wrapat:
      var text = getcolor("orange") \
      + ("" if isarrafterdict else spaces(tab)) \
      +"[ " \
      + getcolor("END") \
      + (\
        (getcolor("orange") + "," + getcolor("END") + " ").join(
          (item as Array).map(
            func(newitem):
              return coloritem(newitem, tab),
          )
        )
      ) \
      + getcolor("orange") \
      +" ]" \
      + getcolor("END")
      return prefix + text + postfix
    else:
      var text = getcolor("orange") \
      + ("" if isarrafterdict else spaces(tab)) \
      +"[\n" \
      + getcolor("END") \
      + (
        (getcolor("orange") + "," + getcolor("END") + "\n").join(
          (item as Array).map(
            func(newitem): return (
              "  " + spaces(tab)
              # if newitem is String \
              # or newitem is int \
              # or newitem is float \
              # else ""
            ) \
            + coloritem(newitem, tab),
          )
        )
      ) + getcolor("orange") \
      +"\n" \
      + spaces(tab) \
      +"]" \
      + getcolor("END")
      return prefix + text + postfix
  if item is Vector2 or item is Vector2i:
    return getcolor("darkgreen") \
    + ("Vector2i" if item is Vector2i else "Vector2") + "(" + \
    getcolor("end") + coloritem(item.x) + getcolor("darkgreen") \
    +", " \
    + getcolor("end") + coloritem(item.y) + getcolor("darkgreen") \
    +")" + getcolor("end")
  if item is bool:
    return getcolor("blue") + str(item) + getcolor("end")
  if item is Color:
    return getcolor("darkgreen") + "Color(" + getcolor("end") + (
      getcolor("pink") if item.r < .66 else
      getcolor("red")
    ) + str(item.r) + getcolor("orange") + ', ' + getcolor("end") + (
      getcolor("lightgreen") if item.g < .66 else
      getcolor("green")
    ) + str(item.g) + getcolor("orange") + ', ' + getcolor("end") + (
      getcolor("lightblue") if item.b < .66 else
      getcolor("blue")
    ) + str(item.b) + getcolor("orange") + ', ' + getcolor("end") \
    + getcolor("white") + str(item.a) + getcolor("end") \
    + getcolor("darkgreen") + ')' + getcolor("end")
    # return getcolor("darkgreen") + "Color(" + getcolor("end") + (
    #   getcolor("white") if item.r < .33 else
    #   getcolor("pink") if item.r < .66 else
    #   getcolor("red")
    # ) + str(item.r) + getcolor("orange") + ', ' + getcolor("end") + (
    #   getcolor("white") if item.g < .33 else
    #   getcolor("lightgreen") if item.g < .66 else
    #   getcolor("green")
    # ) + str(item.g) + getcolor("orange") + ', ' + getcolor("end") + (
    #   getcolor("white") if item.b < .33 else
    #   getcolor("lightblue") if item.b < .66 else
    #   getcolor("blue")
    # ) + str(item.b) + getcolor("orange") + ', ' + getcolor("end") \
    # + getcolor("white") + str(item.a) + getcolor("end") \
    # + getcolor("darkgreen") + ')' + getcolor("end")

  if item is Node:
    var color = getcolor(
      'blue' if item is Node2D else
      'green' if item is Control else
      'red' if item is Node3D else
      'white' if item is Node else 'black'
    )
    # var color = getcolor(
    #   'lightblue' if item is Node2D else
    #   'lightgreen' if item is Control else
    #   'pink' if item is Node3D else
    #   'white' if item is Node else 'black'
    # )
    return getcolor("red") + "<" + getcolor("end") + color + str(item) \
    .replace(":", getcolor("red") + ":" + color) \
    .replace("<", '') \
    .replace("#", getcolor("end") + getcolor("darkred") + "#") \
    .replace(">", getcolor("end") + getcolor("red") + ">") \
    + getcolor('end')
  print("UNSET ITEM TYPE: " + type_string(typeof(item)) + ' - ' + str(item))
  return spaces(tab) + '"' + str(item) + '"'

## public print fns ###########################################################################

static func pp(...msgs) -> void:
  print_rich(
    log_prefix(get_stack(), true) + " - ".join(msgs.map(coloritem)),
  )
static func info(...msgs) -> void:
  var m = log_prefix(get_stack(), true) + " - ".join(msgs.map(coloritem))
  print_rich(m)

static func warn(...msgs) -> void:
  print_rich("[color=yellow][WARN][/color]: " + log_prefix(get_stack(), true) + " - ".join(msgs.map(coloritem)))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  push_warning(m)

static func err(...msgs) -> void:
  print_rich("[color=red][ERR][/color]: " + log_prefix(get_stack(), true) + " - ".join(msgs.map(coloritem)))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  if not Engine.is_editor_hint():
    ToastParty.error(m)
  push_error(m)

static func error(...msgs) -> void:
  print_rich("[color=red][ERR][/color]: " + log_prefix(get_stack(), true) + " - ".join(msgs.map(coloritem)))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  if not Engine.is_editor_hint():
    ToastParty.error(m)
  push_error(m)
# [global:1956]: [ Vector2(1,412.115234375, -,1023.69079589844), Vector2(1,539.82604980469, -895.979919433594) ]
