class_name Menu
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var menu_data := {}
var full_save_path: String
var menu_index := 0
var parent = null

var used_keys = []
var currentParent = []
var GROUP = FoldableGroup.new()
func _init(_parent, save_path: String = "main") -> void:
  parent = _parent
  currentParent = [_parent]
  full_save_path = "user://" + save_path + \
  (" - EDITOR" if OS.has_feature("editor") else '') \
  +".sds"
  var temp = sds.loadDataFromFile(full_save_path, {})
  for k in temp:
    menu_data[k] = {
      "name": k,
      "user": temp[k],
    }
  # #log.pp("loading", _parent.name, save_path)

# add a add that is multiselect/singleselect/range but with images instead of text either from a list of images or a dir full of images
# add optional icon to add_bool
func startGroup(name):
  _add_any("startGroup" + name, {
    "type": "startGroup",
    "name": name,
    'default': null
  })
  # var group = FoldableContainer.new()
  # parent.add_child(group)
  # currentParent.append(group)
func endGroup():
  _add_any("endGroup" + str(randf()), {
    "type": "endGroup",
    'default': null
  })
  # currentParent.pop_back()
# ADDS
func add_range(key, from, to, step: float = 1, default: float = 1, allow_lesser=false, allow_greater=false) -> void:
  # return float|int
  _add_any(key, {
    "type": "range",
    "from": from,
    "to": to,
    "step": step,
    "allow_lesser": allow_lesser,
    "allow_greater": allow_greater,
    "default": default
  })
func add_named_spinbox(key, options, default) -> void:
  # return int
  _add_any(key, {
    "type": "named_spinbox",
    "options": options,
    "default": default
  })
func add_spinbox(key, from, to, step: float = 1, default: float = 1, allow_lesser=false, allow_greater=false) -> void:
  # return float|int
  _add_any(key, {
    "type": "spinbox",
    "from": from,
    "to": to,
    "step": step,
    "allow_lesser": allow_lesser,
    "allow_greater": allow_greater,
    "default": default
  })

func add_bool(key, default=false) -> void:
  # return bool
  _add_any(key, {
    "type": "bool",
    "default": default
  })

func add_multi_select(key, options, default=[]) -> void:
  # return list[str]
  _add_any(key, {
    "type": "multi select",
    "options": options.map(func(x): return str(x)),
    "default": default.map(func(x): return str(x))
  })
func add_rgba(key, default: int) -> void:
  # return list[str]
  _add_any(key, {
    "type": "rgba",
    "default": default
  })
func add_rgb(key, default: int) -> void:
  # return list[str]
  _add_any(key, {
    "type": "rgb",
    "default": default
  })
func add_single_select(key, options, default) -> void:
  # return str
  _add_any(key, {
    "type": "single select",
    "options": options.map(func(x): return str(x)),
    "default": int(default)
  })
func add_named_range(key, options, default) -> void:
  # return int|float
  _add_any(key, {
    "type": "named range",
    "options": options,
    "default": str(default)
  })

func clear():
  menu_data = {}
  save()

const path = "res://GLOBAL/menu things/"

func get_all_data():
  var newobj = {}
  for key in menu_data.keys():
    if "user" in menu_data[key]:
      newobj[key] = menu_data[key]["user"]
    else:
      newobj[key] = menu_data[key]["default"]
  return newobj

signal onchanged

func show_menu():
  currentParent = [parent]
  var keys = menu_data.keys()
  var arr = []
  # for key in keys:
  #   arr.append(key)
  for key in keys:
    if key not in used_keys:
      #log.pp("INVALID KEY IN USER OPTIONS:", key)
      continue
    # #log.pp(menu_data[key], key)
    while menu_data[key].menu_index > len(arr): arr.append(null)
    # #log.pp(arr)
    arr[menu_data[key].menu_index - 1] = menu_data[key]
    arr[menu_data[key].menu_index - 1].name = key
    # #log.pp(arr)
  for thing in arr:
    if "user" not in thing:
      thing["user"] = thing["default"]
    match thing.type:
      "startGroup":
        var group = FoldableContainer.new()
        group.folded = true
        group.foldable_group = GROUP
        group.title = thing.name.substr(len("startGroup"))
        var vbox = VBoxContainer.new()
        group.add_child(vbox)
        currentParent[len(currentParent) - 1].add_child(group)
        currentParent.append(vbox)
      "endGroup":
        currentParent.pop_back()
      "range":
        var node = preload(path + "range.tscn").instantiate()
        node.get_node("Label").text = thing["name"]
        var range_node = node.get_node("HSlider")
        range_node.min_value = thing["from"]
        range_node.max_value = thing["to"]
        range_node.tick_count = (abs(thing["to"] - thing["from"]) / thing.step) + 1 if (abs(thing["to"] - thing["from"]) / thing.step) + 1 < 20 else 0
        range_node.step = thing["step"]
        range_node.value = thing["user"]
        range_node.allow_greater = thing["allow_greater"]
        range_node.allow_lesser = thing["allow_lesser"]
        range_node.value_changed.connect(__changed.bind(thing.name, node))
        __changed.call(thing.name, node)
        log.pp(currentParent)
        currentParent[len(currentParent) - 1].add_child(node)
      "spinbox":
        #       dd_any(key, {
        #   "type": "spinbox",
        #   "from": from,
        #   "to": to,
        #   "step": step,
        #   "allow_lesser": allow_lesser,
        #   "allow_greater": allow_greater,
        #   "default": default
        # })
        var node = preload(path + "spinbox.tscn").instantiate()
        node.get_node("Label").text = thing["name"]
        var range_node = node.get_node("HSlider")
        range_node.min_value = thing["from"]
        range_node.max_value = thing["to"]
        range_node.step = thing["step"]
        range_node.value = thing["user"]
        range_node.allow_greater = thing["allow_greater"]
        range_node.allow_lesser = thing["allow_lesser"]
        range_node.value_changed.connect(__changed.bind(thing.name, node))
        __changed.call(thing.name, node)
        currentParent[len(currentParent) - 1].add_child(node)
      "bool":
        var node = preload(path + "bool.tscn").instantiate()
        node.get_node("Label").text = thing["name"]
        node.get_node("CheckButton").button_pressed = thing["user"]
        node.get_node("CheckButton").toggled.connect(__changed.bind(thing.name, node))
        currentParent[len(currentParent) - 1].add_child(node)
      "multi select":
        var node = preload(path + "multi select.tscn").instantiate()
        # node.get_node("optbtn/Label").text = thing["name"]
        var select = node.get_node("optbtn/OptionButton")
        select.text = thing.name
        node.options = thing["options"]
        node.selected = thing.user
        node.option_changed.connect(__changed.bind(thing.name, node))
        # for sel in thing["user"]:
        #   var t = Texture2D.new()
        #   t.create_placeholder()
        #   # path + "images/check.png"
        #   select.set_item_icon(thing["options"].find(sel), t)
        # select.value = thing["user"] if "user" in thing else thing["default"]
        # select.value_changed.connect(s.__changed.bind(thing.name, select))
        currentParent[len(currentParent) - 1].add_child(node)
      "rgba":
        var node: Control = preload(path + "color.tscn").instantiate()
        var colorSelect := node.get_node("HSlider")
        # var c = thing.user.split(",")
        # if len(c) != 4:
        #   c = thing.default.split(",")
        # colorSelect.color = Color(c[0], c[1], c[2], c[3])
        node.get_node("Label").text = thing.name
        colorSelect.color = Color.hex(int(thing.user))
        colorSelect.popup_closed.connect(__changed.bind(thing.name, node))
        currentParent[len(currentParent) - 1].add_child(node)
      "rgb":
        var node: Control = preload(path + "color.tscn").instantiate()
        var colorSelect := node.get_node("HSlider")
        colorSelect.edit_alpha = false
        node.get_node("Label").text = thing.name
        # var c = thing.user.split(",")
        # if len(c) != 4:
        #   c = thing.default.split(",")
        colorSelect.color = Color.hex(int(thing.user))
        # colorSelect.color = Color.from_string(thing.user, thing.default)
        colorSelect.popup_closed.connect(__changed.bind(thing.name, node))
        currentParent[len(currentParent) - 1].add_child(node)
      "single select":
        var node = preload(path + "single select.tscn").instantiate()
        node.get_node("Label").text = thing["name"]
        # node.get_node("OptionButton").value = str(thing["user"])
        var select = node.get_node("OptionButton")
        select.clear()
        for opt in thing.options:
          select.add_item(opt)
        select.select(int(thing.user) if "user" in thing else 0)
        select.item_selected.connect(__changed.bind(thing.name, node))

        currentParent[len(currentParent) - 1].add_child(node)
      "named_spinbox":
        log.err("named spinbox is not working yet, use single_select or named range")
        return
        # var newarr = sort_dict_to_arr(thing.options)
        # #log.pp(newarr)

        # var node = preload(path + "named spinbox.tscn").instantiate()
        # node.get_node("Label").text = thing["name"]
        # # node.get_node("OptionButton").value = str(thing["user"])
        # var select = node.get_node("OptionButton")
        # select.clear()
        # for opt in newarr:
        #   select.add_item(opt[1])
        # select.value_changed.connect(__changed.bind(thing.name, node))

        # currentParent[len(currentParent)-1].add_child(node)
      "named range":
        var newarr = sort_dict_to_arr(thing.options)
        var node = preload(path + "named range.tscn").instantiate()
        node.get_node("Label").text = thing["name"]
        var range_node = node.get_node("HSlider")
        range_node.min_value = newarr[0][0]
        range_node.max_value = newarr[-1][0]
        range_node.tick_count = (range_node.max_value - range_node.min_value) + 1
        range_node.step = 1
        range_node.value = float(thing["user"])
        range_node.value_changed.connect(__changed.bind(thing.name, node))
        __changed.call(thing.name, node)
        currentParent[len(currentParent) - 1].add_child(node)

      _:
        log.warn("no method is set to add", thing.type)
  # #log.pp(arr)

func sort_dict_to_arr(dict):
  var temp_keys = dict.keys()
  var sorted_keys = JSON.parse_string(JSON.stringify(temp_keys)).map(func(x): return int(x))
  sorted_keys.sort()
  var temp_vals = dict.values()
  # #log.pp(temp_keys)
  # #log.pp(temp_vals)
  # #log.pp(sorted_keys)
  var newarr = []
  for temp_key in sorted_keys:
    newarr.append([temp_key, temp_vals[temp_keys.find(temp_key)]])
  return newarr

# the signal fails to call this when not inside a class and classes cant use external vars so i had to make a temp class then bind it outside
var __changed = __changed_proxy.__changed_proxy.bind(func __changed(name, node):
  #log.pp("changed ", node, name)
  match menu_data[name].type:
    "range":
      menu_data[name].user=node.get_node("HSlider").value
      node.get_node("slider value").text=str(node.get_node("HSlider").value)
    "spinbox":
      menu_data[name].user=node.get_node("HSlider").value
    "named range":
      var arr=sort_dict_to_arr(menu_data[name].options)
      var selected_option=arr.filter(func(x):
        return x[0] == node.get_node("HSlider").value)[0]
      menu_data[name].user=node.get_node("HSlider").value
      node.get_node("slider value").text=selected_option[1]
    "bool":
      menu_data[name].user=node.get_node("CheckButton").button_pressed
    "multi select":
      menu_data[name].user=node.selected
    "single select":
      menu_data[name].user=int(node.get_node("OptionButton").selected)
    "rgba":
      var c=node.get_node("HSlider").color
      menu_data[name].user=c.to_rgba32() # global.join(',', c.r, c.g, c.b, c.a)
      log.pp(node.get_node("HSlider").color)
    "rgb":
      var c=node.get_node("HSlider").color
      menu_data[name].user=c.to_rgba32() # global.join(',', c.r, c.g, c.b)
    _:
      log.err("cant save type: " + menu_data[name].type)
  onchanged.emit()
  save())

class __changed_proxy:
  static func __changed_proxy(msg="ZZZDEF", msg2="ZZZDEF", msg3="ZZZDEF", msg4="ZZZDEF", msg5="ZZZDEF", msg6="ZZZDEF", msg7="ZZZDEF"):
    var arr = [msg, msg2, msg3, msg4, msg5, msg6, msg7].filter(func(x):
      return !global.same(x, "ZZZDEF")
    )
    # #log.pp(arr)
    arr[-1].call(arr[ - 3], arr[ - 2])
# end __changed_proxy

func save():
  sds.saveDataToFile(full_save_path, get_all_data())

func debug():
  pass
  #log.pp("menu_data", menu_data)
  #log.pp("get_all_data", get_all_data())

func _object_assign(obj1, obj2):
  for key in obj2.keys():
    obj1[key] = obj2[key]
  return obj1

func _object_assign_new(obj1, obj2):
  for key in obj2.keys():
    if !obj1.has(key):
      obj1[key] = obj2[key]
  return obj1

func _add_any(key, obj):
  if key in used_keys:
    log.err("key already exists", key)
    return
  else:
    used_keys.append(key)
  menu_index += 1
  # #log.pp(key, menu_index)
  obj.menu_index = menu_index
  if !key in menu_data or !menu_data[key]:
    menu_data[key] = {}
  var userdata = menu_data[key]["user"] if "user" in menu_data[key] else obj.default
  menu_data[key] = obj
  menu_data[key].user = userdata
  if "user" not in menu_data[key]:
    menu_data[key]["user"] = obj.default
  save()
