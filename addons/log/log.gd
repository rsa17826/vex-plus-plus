@tool
extends Object
class_name log

static func assoc(opts: Dictionary, key: String, val):
  var _opts = opts.duplicate(true)
  _opts[key] = val
  return _opts

## prefix ###########################################################################

static func log_prefix(stack):
  if len(stack) > 1:
    var call_site = stack[1]
    var basename = call_site.source.get_file().get_basename()
    var line_num = str(call_site.get("line", 0))
    if call_site.source.match("*/test/*"):
      return "{" + basename + ":" + line_num + "}: "
    elif call_site.source.match("*/addons/*"):
      return "<" + basename + ":" + line_num + ">: "
    else:
      return "[" + basename + ":" + line_num + "]: "

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
  TYPE_BOOL: "pink",
  TYPE_INT: "green",
  TYPE_FLOAT: "green",
  TYPE_STRING: "pink",
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
      print("log.gd could not determine color for object: %s type: (%s)" % [str(s), typeof(s)])

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

## public print fns ###########################################################################

static func pp(...msgs) -> void:
  var m = log.to_printable(msgs, {stack=get_stack()})
  print_rich(m)

static func info(...msgs) -> void:
  var m = log.to_printable(msgs, {stack=get_stack()})
  print_rich(m)

static func log(...msgs) -> void:
  var m = log.to_printable(msgs, {stack=get_stack()})
  print_rich(m)

static func prn(...msgs) -> void:
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true})
  print_rich(m)

static func warn(...msgs) -> void:
  var rich_msgs = msgs.duplicate()
  rich_msgs.push_front("[color=yellow][WARN][/color]")
  print_rich(log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  push_warning(m)

static func err(...msgs) -> void:
  var rich_msgs = msgs.duplicate()
  rich_msgs.push_front("[color=red][ERR][/color]")
  print_rich(log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  push_error(m)

static func error(...msgs) -> void:
  var rich_msgs = msgs.duplicate()
  rich_msgs.push_front("[color=red][ERR][/color]")
  print_rich(log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
  var m = log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
  push_error(m)
