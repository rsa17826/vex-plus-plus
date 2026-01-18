class_name Menu

var menu_data := {}
var full_save_path: String
var menu_index := 0
var parent: Node = null
var used_keys = []
var currentParent = []
var groups = []
var GROUP: FoldableGroup
func _init(_parent, save_path: String = "main") -> void:
  parent = _parent
  currentParent = [_parent]
  groups = []
  full_save_path = "user://" + save_path + \
  (" - EDITOR" if OS.has_feature("editor") else '') \
  +".sds"
  # var temp = sds.loadDataFromFile(full_save_path, {})
  # for k in temp:
  #   menu_data[k] = {
  #     "name": k,
  #     "user": temp[k],
  #   }
  # log.err(menu_data)

func reloadDataFromFile():
  var temp = sds.loadDataFromFile(full_save_path, {})
  # log.pp(temp)
  for k in menu_data:
    # log.err(k, k in temp)
    menu_data[k].newOption = k not in temp
    if 'newItem' in menu_data[k]:
      menu_data[k].newItem.visible = menu_data[k].newOption
    if k in temp:
      menu_data[k].user = temp[k]
    else:
      menu_data[k].user = menu_data[k].default
  if 'removeUnusedItemsFromMenuSaveFile' not in menu_data or !menu_data.removeUnusedItemsFromMenuSaveFile.user:
    for k in temp:
      if k not in menu_data:
        menu_data[k] = {
          "name": k,
          "user": temp[k],
        }

# add a add that is multiselect/singleselect/range but with images instead of text either from a list of images or a dir full of images
func _notification(what):
  if GROUP:
    GROUP.free()
# add optional icon to add_bool
func startGroup(name, tooltip=''):
  groups.append(name)
  _add_any("startGroup - " + '/'.join(groups), {
    "type": "startGroup",
    "shortName": name,
    "default": false,
    "tooltip": tooltip
  })
  # var group = FoldableContainer.new()
  # parent.add_child(group)
  # currentParent.append(group)
func endGroup():
  _add_any("endGroup" + groups.pop_back(), {
    "type": "endGroup",
    'default': null
  })
  # currentParent.pop_back()
# ADDS
func add_button(key, onclick: Callable, tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "button",
    "onclick": onclick,
    "default": null,
    "tooltip": tooltip
  })
func add_textarea(key, default='', placeholder:='', tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "textarea",
    "placeholder": placeholder,
    "default": default,
    "tooltip": tooltip
  })
func add_lineedit(key, default='', placeholder:='', tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "lineedit",
    "placeholder": placeholder,
    "default": default,
    "tooltip": tooltip
  })
func add_file(key, single: bool = false, default='', tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "file",
    "single": single,
    "default": default,
    "tooltip": tooltip
  })
func add_range(key, from, to, step: float = 1, default: float = 1, allow_lesser=false, allow_greater=false, tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "range",
    "from": from,
    "to": to,
    "step": step,
    "allow_lesser": allow_lesser,
    "allow_greater": allow_greater,
    "default": default,
    "tooltip": tooltip
  })
func add_named_spinbox(key, options, default, tooltip='') -> void:
  # return int
  _add_any(key, {
    "type": "named_spinbox",
    "options": options,
    "default": default,
    "tooltip": tooltip
  })
func add_spinbox(key, from, to, step: float = 1, default: float = 1, allow_lesser=false, allow_greater=false, rounded:=false, tooltip='') -> void:
  # return float|int
  _add_any(key, {
    "type": "spinbox",
    "from": from,
    "to": to,
    "step": step,
    "allow_lesser": allow_lesser,
    "allow_greater": allow_greater,
    "rounded": rounded,
    "default": default,
    "tooltip": tooltip
  })
func add_bool(key, default=false, tooltip='') -> void:
  # return bool
  _add_any(key, {
    "type": "bool",
    "default": default,
    "tooltip": tooltip
  })
func add_multi_select(key, options, default=[], tooltip='') -> void:
  # return list[str]
  _add_any(key, {
    "type": "multi select",
    "options": options.map(func(x): return str(x)),
    "default": default.map(func(x): return str(x)),
    "tooltip": tooltip
  })
func add_rgba(key, default: int, tooltip='') -> void:
  # return list[str]
  _add_any(key, {
    "type": "rgba",
    "default": default,
    "tooltip": tooltip
  })
func add_rgb(key, default: int, tooltip='') -> void:
  # return list[str]
  _add_any(key, {
    "type": "rgb",
    "default": default,
    "tooltip": tooltip
  })
func add_single_select(key, options, default, tooltip='') -> void:
  # return str
  _add_any(key, {
    "type": "single select",
    "options": options.map(func(x): return str(x)),
    "default": int(default),
    "tooltip": tooltip
  })
func add_named_range(key, options, default, tooltip='') -> void:
  # return int|float
  _add_any(key, {
    "type": "named range",
    "options": options,
    "default": str(default),
    "tooltip": tooltip
  })

func clear():
  menu_data = {}
  save()

const path = "res://GLOBAL/menu things/"

func get_all_data():
  var newobj = {}
  for key in menu_data.keys():
    # if 'type' in menu_data[key] and menu_data[key].type in ['startGroup', 'endGroup']: continue
    if 'type' in menu_data[key] and menu_data[key].type in ['endGroup']: continue
    if "user" in menu_data[key]:
      newobj[key] = menu_data[key].user
    else:
      newobj[key] = menu_data[key].default
  return newobj

signal onchanged(changedOption: String)

func spaces_to_camel_case(space_string: String):
  var words = space_string.split(" ")
  var camel_case_string = words[0].to_lower()
  for word in words.slice(1):
    camel_case_string += word
  return camel_case_string
func camel_case_to_spaces(camel_case_string: String):
  if not camel_case_string:
    return camel_case_string
  var result := camel_case_string[0].to_lower()
  for i in range(1, camel_case_string.length()):
    var char := camel_case_string[i]
    if char in 'QWERTYUIOPASDFGHJKLZXCVBNM':
      result += " " + char.to_lower()
    else:
      result += char
  return result.lstrip(' ')
var mainVBox: VBoxContainer
var emitChanges := false
func reloadUi():
  mainVBox.remove_child(parent)
  mainVBox.replace_by(parent)
  mainVBox.queue_free()
  for c in parent.get_children():
    c.queue_free()
  show_menu()
var firstTime = true
func show_menu():
  emitChanges = false
  if GROUP:
    GROUP.free()
    GROUP = null
  if firstTime:
    startGroup("menu options")
    add_bool("dontCollapseGroups", false)
    # add_bool("onlyExpandSingleGroup", false)
    add_bool("saveExpandedGroups", true)
    add_bool("loadExpandedGroups", true)
    add_single_select("menuOptionNameFormat", [
      'unchanged',
      "spaces",
      "SHOUTY SPACES CASE",
      "snake_case",
      "SHOUTY_SNAKE_CASE",
      "camelCase"
    ], 0)
    add_bool("removeUnusedItemsFromMenuSaveFile", false)
    add_button("reload menu from file", func():
      reloadDataFromFile()
      reloadUi()
    )
    add_button("mark all as viewed", func():
      save()
      reloadDataFromFile()
    )
    endGroup()
    firstTime = false
  reloadDataFromFile()
  mainVBox = VBoxContainer.new()
  mainVBox.size_flags_horizontal = 3
  mainVBox.size_flags_vertical = 3
  parent.replace_by(mainVBox)
  var searchBar: LineEdit = preload("res://GLOBAL/menu things/search.tscn").instantiate()
  var updateSearch = func(e):
    for child: NestedSearchable in parent.get_children():
      child.updateSearch(e)
  searchBar.text_changed.connect(updateSearch)
  mainVBox.add_child(searchBar)
  mainVBox.add_child(parent)
  currentParent = [parent]
  var keys = menu_data.keys()
  var arr = []
  # for key in keys:
  #   arr.append(key)
  var data = get_all_data()
  var formatName = func formatName(name):
    match data.menuOptionNameFormat:
      0: return name
      1: return camel_case_to_spaces(name.to_camel_case())
      2: return camel_case_to_spaces(name.to_camel_case()).to_upper()
      3: return name.to_snake_case()
      4: return name.to_snake_case().to_upper()
      5: return name.to_camel_case()

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
    if thing.type == "endGroup":
      currentParent.pop_back()
    else:
      var node = load(path + thing.type + "/main.tscn").instantiate()
      node.thisText = formatName.call(thing.name)
      node.onchanged.connect((func(node):
        __changed.call(thing.name, node)
      ).bind(node)
      )
      node.init(thing, menu_data, formatName, node)
      if thing.type != "startGroup":
        var newItem := preload(path + "newItem.tscn").instantiate()
        newItem.visible = thing.newOption
        newItem.get_node("Button").pressed.connect((func(node, name):
          __changed.call(thing.name, node)
        ).bind(node, thing.name))
        if thing.newOption:
          for parentNode in currentParent.slice(1):
            parentNode.get_parent().folded = false
        thing.newItem = newItem
        node.add_child(newItem)
        __changed.call(thing.name, node)
      currentParent[len(currentParent) - 1].add_child(node)
      if 'postInit' in node:
        node.postInit.call(currentParent)

  # #log.pp(arr)
  # await global.wait(1000)
  emitChanges = true
  # set_deferred("emitChanges", true)

func sort_dict_to_arr(dict):
  var temp_keys: Array = dict.keys()
  var sorted_keys = temp_keys.duplicate_deep().map(func(x): return int(x))
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
  var ec=emitChanges
  match menu_data[name].type:
    "button":
      if ec:
        if 'newItem' in menu_data[name]:
          menu_data[name].newItem.visible=false
        save(name)
        return
    "startGroup":
      if ec:
        if 'newItem' in menu_data[name]:
          menu_data[name].newItem.visible=false
        save(name)
        return
    "range":
      menu_data[name].user=node.get_node("HSlider").value
      var val=node.get_node("HSlider").value
      if !fmod(menu_data[name].step, 1):
        val=int(val)
      node.get_node("slider value").text=str(val)
    "spinbox":
      if node.get_node("HSlider").rounded:
        menu_data[name].user=int(node.get_node("HSlider").value)
      else:
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
      # log.pp(node.get_node("HSlider").color)
    "rgb":
      var c=node.get_node("HSlider").color
      menu_data[name].user=c.to_rgba32() # global.join(',', c.r, c.g, c.b)
    "file":
      await global.wait()
      if not node:
        # log.err(node, name)
        return
      menu_data[name].user=node.get_node("FileDialog").files
      node.get_node("Button").tooltip_text='selected file: ' + menu_data[name].user
    "lineedit":
      menu_data[name].user=node.get_node("LineEdit").text
    "textarea":
      menu_data[name].user=node.get_node("TextEdit").text
    _:
      log.err("cant save type: " + menu_data[name].type)
  if ec:
    if 'newItem' in menu_data[name]:
      menu_data[name].newItem.visible=false
    onchanged.emit(name)
    save(name)
  )

class __changed_proxy:
  static func __changed_proxy(msg="ZZZDEF", msg2="ZZZDEF", msg3="ZZZDEF", msg4="ZZZDEF", msg5="ZZZDEF", msg6="ZZZDEF", msg7="ZZZDEF"):
    var arr = [msg, msg2, msg3, msg4, msg5, msg6, msg7].filter(func(x):
      return !global.same(x, "ZZZDEF")
    )
    # log.pp(arr)
    arr[-1].call(arr[ - 3], arr[ - 2])
# end __changed_proxy

func save(name: String = ''):
  if name:
    var data = sds.loadDataFromFile(full_save_path, {})
    data[name] = menu_data[name].user if 'user' in menu_data[name] else menu_data[name].default
    sds.saveDataToFile(full_save_path, data)
  else:
    sds.saveDataToFile(full_save_path, get_all_data())

func debug(): pass
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
  # var userdata = menu_data[key].user if "user" in menu_data[key] else obj.default
  var user = menu_data[key].user if 'user' in menu_data[key] else obj.default
  menu_data[key] = obj.merged(menu_data[key], true)
  menu_data[key].user = user
  menu_data[key].newOption = false
  if !("user" in menu_data[key]):
    menu_data[key].newOption = true
  # menu_data[key].user = userdata
  # save()
